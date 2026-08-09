import 'dart:async';
import 'dart:developer';
import 'dart:math' show max, min;
import '../../../components/components.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:collection/collection.dart';

import '../../../data/services/chord_service.dart';
import '../../../data/services/pdf_note_extractor.dart';
import '../../../data/services/pdf_note_service.dart';
import '../cubit/song_cubit.dart';
import 'chord_badge_layout.dart';

/// App-level controller for programmatic zoom on the active PDF viewer.
///
/// This is a thin wrapper â€” the backing pdfrx controller is held inside
/// [_SongPdfViewerState] and its methods are wired here on creation.
class PdfViewerController {
  VoidCallback? zoomIn;
  VoidCallback? zoomOut;
  VoidCallback? fitToPage;
}

/// Native Flutter PDF viewer backed by `pdfrx` that renders bundled PDF assets.
///
/// Chord badges are rendered as Flutter [Positioned] widgets inside a [Stack]
/// overlaid on each page, so no WebView or JavaScript is needed.
class SongPdfViewer extends StatefulWidget {
  final String? pdfPath;
  final bool showChord;
  final Map<int, List<ChordData>>? chords;
  final int transposeStep;
  final int baseTransposeOffset;
  final String chordAccidentalMode;
  final bool twoPageMode;
  final bool verticalScrolling;
  final int chordFontSizePercent;
  final int chordFillOpacityPercent;
  final int chordPaddingPercent;
  final int chordOffsetPercent;
  final bool isEditMode;
  final Function(Map<int, List<ChordData>>)? onChordsChanged;
  final PdfViewerController? viewerController;
  final VoidCallback? onNextSong;
  final VoidCallback? onPreviousSong;

  const SongPdfViewer({
    super.key,
    this.pdfPath,
    this.showChord = false,
    this.chords,
    this.transposeStep = 0,
    this.baseTransposeOffset = 0,
    this.chordAccidentalMode = ChordService.accidentalSharp,
    this.twoPageMode = false,
    this.verticalScrolling = false,
    this.chordFontSizePercent = 100,
    this.chordFillOpacityPercent = 94,
    this.chordPaddingPercent = 100,
    this.chordOffsetPercent = 100,
    this.isEditMode = false,
    this.onChordsChanged,
    this.viewerController,
    this.onNextSong,
    this.onPreviousSong,
  });

  @override
  State<SongPdfViewer> createState() => _SongPdfViewerState();
}

class _SongPdfViewerState extends State<SongPdfViewer>
    with SingleTickerProviderStateMixin {
  /// pdfrx viewer controller used for zoom / page navigation.
  final _pdfCtrl = pdfrx.PdfViewerController();

  /// Default pdfrx page margin â€” the app does not override it, so the
  /// layouts and fit computations use the same 8 px all around.
  static const double _pageMargin = 8.0;

  /// Global service for note extraction and caching.
  final _noteService = PdfNoteService();

  PdfDocumentRequest? _pdfRequest;

  /// Cached page layouts to avoid O(N) list creation in _buildLayout on every call.
  pdfrx.PdfPageLayout? _cachedLayout;
  String? _cachedLayoutKey;

  /// True while we are waiting for the first [onViewerReady] after a new PDF
  /// is requested. Reset to false once the initial fit-to-page has been done,
  /// so that subsequent [onViewerReady] calls caused by [invalidate] (e.g.
  /// when chord overlay is toggled) do NOT reset the user's zoom/scroll.
  bool _needsInitialFit = false;

  /// Song-navigation fade transition ---
  late final AnimationController _navFadeCtrl;
  late final Animation<double> _navOpacity;

  /// Incremented on every pdfPath change so stale fade completions are ignored.
  int _pathGeneration = 0;

  /// Incremented to force pdfrx to recreate the viewer if first-load readiness
  /// stalls before the controller attaches.
  int _viewerInstance = 0;

  /// The path generation that most recently reached pdfrx onViewerReady.
  int? _viewerReadyGeneration;

  Timer? _viewerReadyWatchdog;
  String? _metadataPrimedSourceId;
  final Set<String> _noteStatsLogged = <String>{};

  /// True while the viewer is transitioning between PDFs (fading out/in).
  /// Used to prevent rendering new chords on the old PDF document.
  bool _isTransitioning = false;

  /// Controls whether the PDF should be visible (true) or hidden (false).
  /// PDF stays hidden until fit-to-page completes, then animates to visible.
  bool _pdfFullyVisible = false;

  /// 0-based index of the page that is currently visible (or the left
  /// page of the visible pair in two-page mode).  In normal mode this
  /// is the only visible page; in two-page mode the right-hand page
  /// is `_currentPageIndex + 1`.
  int _currentPageIndex = 0;

  /// Total page count of the currently loaded document, for navigation.
  int _totalPageCount = 0;

  // Swipe gesture state for page/song navigation.
  double _swipeStartX = 0;
  double _swipeStartY = 0;
  DateTime _swipeStartTime = DateTime.now();

  /// Cached [pdfrx.PdfViewerParams] for the current configuration.
  ///
  /// This MUST be stable across rebuilds: pdfrx compares its `params`
  /// field by identity in `didUpdateWidget` and re-applies the layout
  /// (which invalidates the entire page tree) whenever a new instance
  /// is detected.  Recreating `params` in `build()` would therefore put
  /// the viewer in a perpetual rebuild loop and the PDF would never
  /// reach a stable, visible state.
  ///
  /// The params are (re)created in `didChangeDependencies` (for the
  /// initial build and theme changes) and in `didUpdateWidget` (only
  /// when `showChord` flips, since `pageOverlaysBuilder` is the only
  /// widget-driven field).
  pdfrx.PdfViewerParams? _cachedParams;

  @override
  void initState() {
    super.initState();
    _navFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _navOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _navFadeCtrl, curve: Curves.easeOut));
    _wireController();
    _parsePdfPath();
  }

  @override
  void dispose() {
    _viewerReadyWatchdog?.cancel();
    _navFadeCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SongPdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewerController != oldWidget.viewerController) {
      _wireController();
    }
    if (oldWidget.pdfPath != widget.pdfPath) {
      _parsePdfPath();
      // The onViewerReady closure captures the path generation and
      // source id; rebuild params so the new PDF reports readiness
      // through the up-to-date closure.
      _cachedParams = null;
    }
    if (oldWidget.twoPageMode != widget.twoPageMode ||
        oldWidget.verticalScrolling != widget.verticalScrolling) {
      // Layout changed â€” PdfViewer is rebuilt via new key on assetPath,
      // but twoPageMode/verticalScrolling need a setState.
      _needsInitialFit = true;
      // Invalidate cached params so the next build creates fresh params
      // with the correct layout mode.  Without this the old params (which
      // may have different scrollPhysics or layoutPages) are reused.
      _cachedParams = null;
      setState(() {});
    }
    if (oldWidget.showChord != widget.showChord ||
        oldWidget.chords != widget.chords ||
        oldWidget.transposeStep != widget.transposeStep ||
        oldWidget.baseTransposeOffset != widget.baseTransposeOffset ||
        oldWidget.chordAccidentalMode != widget.chordAccidentalMode ||
        oldWidget.chordFontSizePercent != widget.chordFontSizePercent ||
        oldWidget.chordFillOpacityPercent != widget.chordFillOpacityPercent ||
        oldWidget.chordPaddingPercent != widget.chordPaddingPercent ||
        oldWidget.chordOffsetPercent != widget.chordOffsetPercent) {
      // showChord flips the pageOverlaysBuilder; pdfrx compares the
      // whole params by identity, so we must hand it a fresh instance
      // (and bump the version so `_buildLayout` re-computes the
      // chord overlay offsets).
      if (oldWidget.showChord != widget.showChord) {
        _cachedParams = null;
      }
      setState(() {});
      // pdfrx's _widgetUpdated returns early (without calling _invalidate) when
      // the document key is unchanged, so the pageOverlaysBuilder closure change
      // is invisible to pdfrx. Force a redraw of the overlay layer explicitly.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _invalidatePdfIfReady();
      });
    }
  }

  void _wireController() {
    final ctrl = widget.viewerController;
    if (ctrl == null) return;
    ctrl.zoomIn = _zoomIn;
    ctrl.zoomOut = _zoomOut;
    ctrl.fitToPage = _fitToPage;
  }

  void _parsePdfPath() {
    final path = widget.pdfPath;
    if (path == null) {
      // Starting a transition to null (no PDF)
      _pathGeneration++;
      _cachedLayout = null;
      _cachedLayoutKey = null;
      _needsInitialFit = false;
      _viewerReadyGeneration = null;
      _viewerReadyWatchdog?.cancel();
      _pdfFullyVisible = false;
      _isTransitioning = true; // Start transition
      _currentPageIndex = 0;
      _totalPageCount = 0;
      // Quick fade out
      _navFadeCtrl.value = 1.0;
      _navFadeCtrl.duration = const Duration(milliseconds: 150);
      _navFadeCtrl.forward(from: 0); // Fade out current
      _navFadeCtrl.addListener(_onFadeCompleteForNull);
      if (mounted) setState(() => _pdfRequest = null);
      return;
    }
    final newRequest = PdfDocumentRequest.parse(path);
    final oldRequest = _pdfRequest;

    // Check if it's the same request - if so, no transition needed
    if (oldRequest != null && _samePdfRequest(oldRequest, newRequest)) {
      // Same PDF, just refresh if needed
      if (!_pdfCtrl.isReady) {
        _needsInitialFit = true;
        _viewerReadyGeneration = null;
        _scheduleViewerReadyWatchdog(_pathGeneration);
      }
      return;
    }

    // Different PDF - start transition
    _pathGeneration++;
    _cachedLayout = null;
    _cachedLayoutKey = null;
    _needsInitialFit = true;
    _viewerReadyGeneration = null;
    _viewerReadyWatchdog?.cancel();
    _metadataPrimedSourceId = null;
    _noteStatsLogged.clear();
    _isTransitioning = true;
    _currentPageIndex = 0;
    _totalPageCount = 0;

    // Clear note extraction cache when PDF changes
    _NoteExtractionCache.clear();

    // Hide the viewer immediately when changing songs
    _pdfFullyVisible = false;

    // Start fade out animation if there was a previous PDF
    if (oldRequest != null) {
      // Capture the generation so the .then() callback can reject
      // itself if a newer _parsePdfPath call happened in the
      // meantime (stale-closure race).
      final capturedGeneration = _pathGeneration;
      // Set controller to fade-out position (value=1, opacity=0)
      _navFadeCtrl.value = 1.0;
      // Animate fade out over 150ms (fast portion of 300ms total)
      _navFadeCtrl.duration = const Duration(milliseconds: 150);
      _navFadeCtrl.forward(from: 0).then((_) {
        if (!mounted || capturedGeneration != _pathGeneration) return;
        // Invalidate the cached params so the next build creates
        // fresh params with the NEW _pdfRequest.  Without this the
        // onViewerReady closure still captures the old sourceId
        // and pdfrx's _onViewerReady sourceId check fails, which
        // prevents _pdfFullyVisible from ever becoming true.
        _cachedParams = null;
        setState(() {
          _pdfRequest = newRequest;
          _isTransitioning = false;
        });
        // Schedule watchdog for the new PDF
        _scheduleViewerReadyWatchdog(_pathGeneration);
      });
    } else {
      // No previous PDF, just show the new one hidden
      if (mounted) setState(() => _pdfRequest = newRequest);
      _navFadeCtrl.value = 0.0;
      _isTransitioning = false;
      _scheduleViewerReadyWatchdog(_pathGeneration);
    }
  }

  void _scheduleViewerReadyWatchdog(int generation, {int attempt = 0}) {
    _viewerReadyWatchdog?.cancel();
    _viewerReadyWatchdog = Timer(const Duration(milliseconds: 700), () {
      if (!mounted || generation != _pathGeneration) return;
      // Viewer-ready already fired and the fit finished — no help needed.
      if (_viewerReadyGeneration == generation || !_needsInitialFit) {
        return;
      }

      if (attempt >= 2) {
        log(
          'PDF viewer-ready watchdog gave up after $attempt recreations',
          name: 'SongPdfViewer',
        );
        // Force the PDF visible so the user isn't stuck on a blank
        // screen.  A mis-aligned PDF is better than nothing.
        if (mounted) {
          _pdfFullyVisible = true;
          _isTransitioning = false;
          _navFadeCtrl.duration = const Duration(milliseconds: 300);
          _navFadeCtrl.reverse(from: 1.0);
          setState(() {});
        }
        return;
      }

      log(
        'PDF viewer-ready watchdog recreating viewer (attempt ${attempt + 1})',
        name: 'SongPdfViewer',
      );
      setState(() {
        _viewerInstance++;
        _cachedLayout = null;
        _cachedLayoutKey = null;
      });
      _scheduleViewerReadyWatchdog(generation, attempt: attempt + 1);
    });
  }

  /// Fallback mechanism to ensure fit-to-page is called even if onViewerReady
  /// doesn't fire due to pdfrx timing issues. Retries until controller is ready.
  void _scheduleFitWithFallback() {
    _retryFitUntilReady(maxAttempts: 8, intervalMs: 50);
  }

  /// Retry fit-to-page until controller is ready or max attempts reached.
  /// This ensures the PDF is shown even if onViewerReady timing is off.
  void _retryFitUntilReady({
    required int maxAttempts,
    required int intervalMs,
  }) async {
    int attempts = 0;
    final generation = _pathGeneration;

    while (attempts < maxAttempts) {
      if (!mounted || generation != _pathGeneration) return;

      // Check if controller is ready
      if (_pdfCtrl.isReady && _needsInitialFit) {
        // Get render box dimensions
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize && box.size.width > 0) {
          if (!_fitToPageInstant()) {
            await Future.delayed(Duration(milliseconds: intervalMs));
            attempts++;
            continue;
          }
          _invalidatePdfIfReady();
          if (mounted && generation == _pathGeneration) {
            _pdfFullyVisible = true;
            _isTransitioning = false;
            _navFadeCtrl.duration = const Duration(milliseconds: 300);
            _navFadeCtrl.reverse(from: 1.0);
            setState(() {});
          }
          log(
            'PDF fit succeeded after $attempts attempts',
            name: 'SongPdfViewer',
          );
          return;
        }
      }

      await Future.delayed(Duration(milliseconds: intervalMs));
      attempts++;
    }

    // Final attempt even without controller ready check
    if (mounted && generation == _pathGeneration && _needsInitialFit) {
      if (_pdfCtrl.isReady) {
        if (_fitToPageInstant()) {
          _invalidatePdfIfReady();
        }
      }
      // Show the PDF even if the fit failed â€” a visible but
      // mis-aligned PDF is better than nothing.
      _pdfFullyVisible = true;
      _isTransitioning = false;
      _navFadeCtrl.duration = const Duration(milliseconds: 300);
      _navFadeCtrl.reverse(from: 1.0);
      setState(() {});
    }
  }

  void _onFadeCompleteForNull() {
    if (_navFadeCtrl.isCompleted && widget.pdfPath == null) {
      _isTransitioning = false;
      _navFadeCtrl.removeListener(_onFadeCompleteForNull);
    }
  }

  bool _samePdfRequest(PdfDocumentRequest a, PdfDocumentRequest b) {
    return a.assetPath == b.assetPath &&
        a.sourceId == b.sourceId &&
        a.startPage == b.startPage &&
        a.pageCount == b.pageCount &&
        a.isFile == b.isFile;
  }

  void _onViewerReady(
    pdfrx.PdfDocument? document,
    pdfrx.PdfViewerController ctrl,
    int generation,
    String sourceId,
  ) {
    if (document == null) return;
    final request = _pdfRequest;
    if (request == null ||
        generation != _pathGeneration ||
        request.sourceId != sourceId) {
      return;
    }
    _viewerReadyGeneration = generation;
    _viewerReadyWatchdog?.cancel();
    // Mark the fit as in-flight so the watchdog can tell "fit still running"
    // apart from "fit never started" â€” only the latter needs viewer recreation.
    // The master PDF may contain dozens of songs; the navigator
    // (and the `_goToPage` clamp) must report the *song's* page
    // count, not the document's.  When `request.pageCount` is set
    // (the usual case) it equals the number of pages that belong
    // to this song; otherwise we fall back to "everything from
    // `startPage` to the end of the document".
    _totalPageCount =
        request.pageCount ??
        (document.pages.length - request.startPage + 1).clamp(1, 1 << 30);
    // `_currentPageIndex` is 0-based and relative to the start of
    // the song's page range, so the first page of the song is
    // always index 0 â€” not `startPage - 1` (which would point at
    // the last page of the previous song in the master PDF).
    _currentPageIndex = 0;
    _primeDetectedMetadataFromFirstPage(document, request);

    // Use a more robust way to wait for the viewer to have a valid size.
    // Reopening the page often involves layout animations or multiple passes.
    _waitForValidSizeAndFit(ctrl, generation);
  }

  void _primeDetectedMetadataFromFirstPage(
    pdfrx.PdfDocument document,
    PdfDocumentRequest request,
  ) {
    final sourceId = request.sourceId;
    if (_metadataPrimedSourceId == sourceId) return;
    _metadataPrimedSourceId = sourceId;
    if (document.pages.isEmpty) return;
    final pageIndex = (request.startPage - 1).clamp(
      0,
      document.pages.length - 1,
    );
    final firstPage = document.pages[pageIndex];
    unawaited(_loadNotePositionsAndInfos(firstPage));
  }

  void _waitForValidSizeAndFit(
    pdfrx.PdfViewerController ctrl,
    int generation,
  ) async {
    final stableSize = await _waitForStableViewerSize(ctrl, generation);
    if (!mounted || generation != _pathGeneration) {
      return;
    }

    // The viewer's RenderBox never reached a stable size (e.g. the app was
    // starved by other work during startup).  The controller still knows its
    // own view size, so attempt the fit anyway â€” a correctly-fitted PDF is
    // better than a permanently invisible one.  This closes the "blank PDF
    // on first load" stall.
    if (stableSize == null && ctrl.isReady && _needsInitialFit) {
      if (!_fitToPageInstant()) {
        _scheduleFitWithFallback();
        return;
      }
      await Future.microtask(() {});
      if (mounted && generation == _pathGeneration) {
        _invalidatePdfIfReady();
        setState(() {});
      }
    } else if (stableSize == null) {
      return;
    }

    // Use a microtask to perform the fit immediately after size is available
    // instead of a hard 100ms delay.
    if (_needsInitialFit) {
      if (!_fitToPageInstant()) {
        _scheduleFitWithFallback();
        return;
      }

      // Use a single frame delay instead of 60ms for the invalidate.
      await Future.microtask(() {});
      if (mounted && generation == _pathGeneration) {
        _invalidatePdfIfReady();
        setState(() {}); // Force overlay rebuild after fit
      }
    }

    // PDF is now fully fitted. Trigger fade-in animation.
    if (mounted && generation == _pathGeneration) {
      _pdfFullyVisible = true;
      _isTransitioning = false;
      // Controller value is at 1.0 (end of fade-out). Call reverse() to animate 1.0 â†’ 0.0.
      // This produces fade-in effect: opacity increases as value decreases.
      _navFadeCtrl.duration = const Duration(milliseconds: 300);
      _navFadeCtrl.reverse(from: 1.0);
    }
  }

  Future<Size?> _waitForStableViewerSize(
    pdfrx.PdfViewerController ctrl,
    int generation, {
    int maxFrames = 45,
    int requiredStableFrames = 2,
  }) async {
    Size? lastSize;
    var stableFrames = 0;

    for (var frame = 0; frame < maxFrames; frame++) {
      if (!mounted || generation != _pathGeneration) return null;

      final box = context.findRenderObject() as RenderBox?;
      if (ctrl.isReady &&
          box != null &&
          box.hasSize &&
          box.size.width > 0 &&
          box.size.height > 0) {
        final size = box.size;
        if (lastSize != null &&
            (size.width - lastSize.width).abs() < 0.5 &&
            (size.height - lastSize.height).abs() < 0.5) {
          stableFrames++;
        } else {
          stableFrames = 0;
        }
        lastSize = size;

        if (stableFrames >= requiredStableFrames) {
          return size;
        }
      }

      await WidgetsBinding.instance.endOfFrame;
    }

    return lastSize;
  }

  void _zoomIn() {
    if (!_pdfCtrl.isReady) return;
    _pdfCtrl.zoomUp();
  }

  void _zoomOut() {
    if (!_pdfCtrl.isReady) return;
    _pdfCtrl.zoomDown();
  }

  /// Animated fit-to-page for the user-facing "Fit" button (200 ms).
  void _fitToPage() {
    if (!_pdfCtrl.isReady) return;
    final page = _pdfCtrl.pageNumber ?? _pdfRequest?.startPage ?? 1;
    final matrix = _tryCalcFitMatrix(pageNumber: page);
    if (matrix == null) {
      _scheduleFitWithFallback();
      return;
    }
    _pdfCtrl.goTo(matrix);
  }

  /// Instant fit-to-page used on viewer-ready and after explicit
  /// page navigation to avoid the animated double-zoom flicker that
  /// occurs when onLayoutInitialized and onViewerReady both try to
  /// set the zoom/position.  Fits to [_currentPageIndex] so two-page
  /// mode centres on the left page of the current pair.
  bool _fitToPageInstant() {
    if (!_pdfCtrl.isReady) return false;
    final page = (_pdfRequest?.startPage ?? 1) + _currentPageIndex;
    final matrix = _tryCalcFitMatrix(pageNumber: page);
    if (matrix == null) return false;
    _needsInitialFit = false;
    _pdfCtrl.goTo(matrix, duration: Duration.zero);
    return true;
  }

  /// Mode-dependent zoom policy shared by the initial fit (via
  /// [pdfrx.PdfViewerSizeDelegateProviderLegacy.calculateInitialZoom]) and
  /// every later fit ([_tryCalcFitMatrix]).
  ///
  /// * **single-page** — fit the whole page to the window: the page fits
  ///   fully inside the viewport (the binding constraint is the smallest
  ///   side of the screen), centered.
  /// * **two-page** — autofit the whole spread: both pages fit fully inside
  ///   the viewport (portrait or landscape), no rotate-to-landscape prompt.
  /// * **vertical** — fit the song's first page fully into the viewport;
  ///   every page scrolls vertically underneath at the same scale.
  double _fitZoomForSize(Size viewSize, Size documentSize) {
    final safeW = max(viewSize.width - _pageMargin * 2, 1.0);
    final safeH = max(viewSize.height - _pageMargin * 2, 1.0);
    return min(
      safeW / max(documentSize.width, 1.0),
      safeH / max(documentSize.height, 1.0),
    );
  }

  /// The layout rect of the song's first page (absolute [startPage]), used
  /// by single-page/vertical fits as the "fit to window" target.
  Rect? _firstSongPageRect() {
    final layout = _pdfCtrl.layout;
    final request = _pdfRequest;
    if (request == null || layout.pageLayouts.isEmpty) return null;
    final index = (request.startPage - 1).clamp(
      0,
      layout.pageLayouts.length - 1,
    );
    return layout.pageLayouts[index];
  }

  Matrix4? _tryCalcFitMatrix({required int pageNumber}) {
    try {
      if (!_pdfCtrl.isReady) return null;
      final viewSize = _pdfCtrl.viewSize;
      if (viewSize.width <= 0 || viewSize.height <= 0) return null;

      if (widget.twoPageMode) {
        // Fit the whole pair (both pages fully visible) — same matrix the
        // initial zoom applies, so navigation never changes the scale.
        final doc = _pdfCtrl.documentSize;
        if (doc.width <= 0 || doc.height <= 0) return null;
        final zoom = _fitZoomForSize(viewSize, doc);
        return _pdfCtrl.calcMatrixFor(
          Offset(doc.width / 2, doc.height / 2),
          zoom: zoom,
          viewSize: viewSize,
        );
      }
      if (widget.verticalScrolling) {
        // Fit the song's first page fully into the viewport; the remaining
        // pages scroll underneath at the same scale.
        final page = _firstSongPageRect();
        if (page == null || page.width <= 0 || page.height <= 0) return null;
        final zoom = _fitZoomForSize(viewSize, Size(page.width, page.height));
        return _pdfCtrl.calcMatrixFor(
          page.center,
          zoom: zoom,
          viewSize: viewSize,
        );
      }
      // Single-page mode: fit the whole page into the viewport (the binding
      // constraint is the smallest side of the screen).
      return _pdfCtrl.calcMatrixForFit(pageNumber: pageNumber);
    } on TypeError catch (error, stackTrace) {
      log(
        'PDF fit skipped because pdfrx controller is not fully attached yet',
        name: 'SongPdfViewer',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  void _invalidatePdfIfReady() {
    try {
      if (!_pdfCtrl.isReady) return;
      _pdfCtrl.invalidate();
    } on TypeError {
      // pdfrx can detach the controller between isReady and invalidate while
      // swapping documents. A later viewer-ready pass will redraw the overlay.
    }
  }

  /// Load and cache note positions AND infos for [page] from the PDF text layer.
  /// This combines the extraction into a single call for better performance.
  Future<
    ({
      Map<int, NotePosition> positions,
      List<NoteInfo> infos,
      String? detectedKey,
      double? detectedTempo,
    })
  >
  _loadNotePositionsAndInfos(pdfrx.PdfPage page) async {
    final request = _pdfRequest;
    if (request == null) {
      return (
        positions: <int, NotePosition>{},
        infos: <NoteInfo>[],
        detectedKey: null,
        detectedTempo: null,
      );
    }

    final result = await _noteService.loadNotePositionsAndInfos(
      page,
      request.assetPath,
    );
    final statKey = '${request.sourceId}#${page.pageNumber}';
    if (!_noteStatsLogged.contains(statKey)) {
      _noteStatsLogged.add(statKey);
      final noteCount = result.infos.where((n) => n.isNote).length;
      final holdCount = result.infos.where((n) => n.isDot).length;
      final restCount = result.infos.where((n) => n.isRest).length;
      log(
        'Note extraction ${request.assetPath} p${page.pageNumber}: total=${result.infos.length}, notes=$noteCount, holds=$holdCount, rests=$restCount',
        name: 'SongPdfViewer',
      );
    }

    // Automatically update the PDF key and tempo if detected in the text layer
    if (result.detectedKey != null || result.detectedTempo != null) {
      final requestSourceId = request.sourceId;
      // Use a post-frame callback to avoid state updates during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pdfRequest?.sourceId == requestSourceId) {
          final cubit = context.read<SongCubit>();
          if (result.detectedKey != null) {
            cubit.updatePdfKey(result.detectedKey);
          }
          if (result.detectedTempo != null) {
            cubit.updatePdfTempo(result.detectedTempo!);
          }
        }
      });
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final request = _pdfRequest;

    if (request == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Pilih lagu untuk menampilkan PDF.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final theme = Theme.of(context);
    final requestGeneration = _pathGeneration;
    // The params are cached in state so their identity stays stable
    // across rebuilds.  pdfrx compares `widget.params` by identity in
    // `didUpdateWidget` and tears down + re-lays out the page tree
    // when it sees a new instance â€” recreating params in `build()`
    // would put the viewer in a perpetual rebuild loop and the PDF
    // would never settle on a visible state.  See [_cachedParams].
    final params = _cachedParams ??= pdfrx.PdfViewerParams(
      // White like the paper so the area below a short page blends into
      // the sheet instead of showing a contrasting strip.
      backgroundColor: const Color(0xFFFFFFFF),
      layoutPages: _buildLayout,
      onViewerReady: (document, ctrl) =>
          _onViewerReady(document, ctrl, requestGeneration, request.sourceId),
      // Always provide the overlay builder (never null) so chord badges
      // can fade out on toggle-off instead of vanishing instantly; the
      // badge TweenAnimationBuilder animates toward showChord's target.
      pageOverlaysBuilder: _buildPageOverlays,
      sizeDelegateProvider: pdfrx.PdfViewerSizeDelegateProviderLegacy(
        maxScale: 3.5,
        // pdfrx applies this zoom synchronously inside onLayoutInitialized â€”
        // BEFORE onViewerReady and before its own _goToPage positioning.
        // That removes the old race where pdfrx's default cover-scale zoom
        // (or a stalled fit) could win over the app's intended fit and leave
        // the initial view tiny, mis-scaled, or invisible.  The callback
        // reads the layout/document size that pdfrx has already computed.
        calculateInitialZoom: (document, controller, fitZoom, coverZoom) {
          try {
            if (!controller.isReady) return null;
            final viewSize = controller.viewSize;
            if (viewSize.width <= 0 || viewSize.height <= 0) return null;
            if (widget.twoPageMode) {
              // Fit the whole spread (both pages fully visible).
              final documentSize = controller.documentSize;
              if (documentSize.width <= 0 || documentSize.height <= 0) {
                return null;
              }
              return _fitZoomForSize(viewSize, documentSize);
            }
            // Single-page & vertical: fit the song's first page fully into
            // the viewport (smallest side of the screen is the constraint).
            final layout = controller.layout;
            if (layout.pageLayouts.isEmpty) return null;
            final pageIndex = (request.startPage - 1).clamp(
              0,
              layout.pageLayouts.length - 1,
            );
            final page = layout.pageLayouts[pageIndex];
            if (page.width <= 0 || page.height <= 0) return null;
            return _fitZoomForSize(viewSize, Size(page.width, page.height));
          } catch (_) {
            return null;
          }
        },
      ),
      // Do NOT set scrollPhysics here â€” pdfrx uses its own
      // FixedOverscrollPhysics which works with its internal
      // scroll/zoom system.  Overriding it with
      // ClampingScrollPhysics breaks vertical scrolling and
      // pinch-to-zoom.
    );

    // Force recreation when the requested range OR the viewing mode changes
    // so pdfrx applies initialPageNumber, rebuilds the page layout against
    // the right pages, and re-runs the deterministic initial-fit zoom for the
    // new mode (single/two-page/vertical).  A mode switch therefore gets a
    // fresh, correctly-fitted viewer instead of pdfrx's onLayoutUpdate
    // "preserve current zoom" behavior fighting the new layout.
    final modeToken = widget.twoPageMode
        ? '2'
        : widget.verticalScrolling
        ? 'v'
        : '1';
    final viewerKey = ValueKey(
      '${request.sourceId}#p${request.startPage}#n${request.pageCount}#m$modeToken#v$_viewerInstance',
    );

    final viewer = request.isFile
        ? pdfrx.PdfViewer.file(
            request.assetPath,
            key: viewerKey,
            controller: _pdfCtrl,
            useProgressiveLoading: false,
            initialPageNumber: request.startPage,
            params: params,
          )
        : pdfrx.PdfViewer.asset(
            request.assetPath,
            key: viewerKey,
            controller: _pdfCtrl,
            useProgressiveLoading: false,
            initialPageNumber: request.startPage,
            params: params,
          );

    return SizedBox.expand(
      child: OrientationBuilder(
        builder: (context, orientation) {
          return AnimatedBuilder(
            animation: _navFadeCtrl,
            child: viewer,
            builder: (context, child) {
              // Only show the PDF when _pdfFullyVisible is true.
              // Before that, keep it hidden (opacity 0).
              final opacity = _pdfFullyVisible ? _navOpacity.value : 0.0;
              final pdfWidget = Opacity(opacity: opacity, child: child);

              // Two-page mode works in BOTH orientations: the layout places
              // the two pages side by side and the initial fit scales the
              // whole spread into the viewport, so no rotate-to-landscape
              // prompt is needed (previously shown in portrait).

              // Vertical-scroll mode: no navigator pill (the user
              // scrolls the whole document instead).
              if (widget.verticalScrolling) {
                return pdfWidget;
              }

              // Normal mode and two-page mode: add a compact
              // corner navigator and wrap the viewer in a Listener
              // so vertical swipes navigate pages and horizontal
              // swipes navigate songs.
              if (_totalPageCount > 1) {
                final step = widget.twoPageMode ? 2 : 1;
                final maxIndex = widget.twoPageMode
                    ? ((_totalPageCount - 1) ~/ 2) * 2
                    : _totalPageCount - 1;
                final canGoPrev = _currentPageIndex > 0;
                final canGoNext = _currentPageIndex + step <= maxIndex;
                final displayIndex = widget.twoPageMode
                    ? '${_currentPageIndex ~/ 2 + 1}/${(_totalPageCount / 2).ceil()}'
                    : '${_currentPageIndex + 1}/$_totalPageCount';
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Listener(
                      onPointerDown: _onSwipeStart,
                      onPointerUp: _onSwipeEnd,
                      child: pdfWidget,
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: _PdfPageNavigator(
                        theme: theme,
                        label: displayIndex,
                        canGoPrev: canGoPrev,
                        canGoNext: canGoNext,
                        onPrev: () => unawaited(
                          _goToPage(_currentPageIndex - step),
                        ),
                        onNext: () => unawaited(
                          _goToPage(_currentPageIndex + step),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return pdfWidget;
            },
          );
        },
      ),
    );
  }

  /// Switch to a new page in the current PDF with a smooth
  /// cross-fade transition: the current page fades out, the
  /// layout is rebuilt for the new page, the viewer is
  /// re-fitted, and the new page fades back in.  In two-page
  /// mode the same animation runs but the layout is built for
  /// the new pair.  In vertical-scroll mode the layout already
  /// shows every page, so the swap still runs (and the user
  /// sees the new page come into view centred).
  Future<void> _goToPage(int newIndex) async {
    if (newIndex == _currentPageIndex) return;
    // In two-page mode navigation moves in pairs; clamp to the highest
    // valid pair start so the user can never land on a lone odd page
    // unless it is the document's last page.
    final maxIndex = widget.twoPageMode
        ? ((_totalPageCount - 1) ~/ 2) * 2
        : _totalPageCount - 1;
    final clamped = newIndex.clamp(0, maxIndex);
    if (clamped == _currentPageIndex) return;

    // Phase 1: fade out the current page.  `_navOpacity` is a
    // tween from 1.0 (visible) to 0.0 (hidden); `forward()` drives
    // the controller 0 â†’ 1 so the tween output goes 1 â†’ 0.
    _navFadeCtrl.stop();
    _navFadeCtrl.duration = const Duration(milliseconds: 120);
    await _navFadeCtrl.forward(from: 0);
    if (!mounted) return;

    // Phase 2: swap the page.  Wrapped in setState so the build
    // picks up the new `_currentPageIndex` and the layout cache
    // is invalidated.
    setState(() {
      _currentPageIndex = clamped;
      _cachedLayout = null;
      _cachedLayoutKey = null;
    });

    // Wait one frame so pdfrx's internal layout pass runs with the
    // new page rect before we ask it to fit.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    _invalidatePdfIfReady();
    _fitToPageInstant();

    // Phase 3: fade in the new page.  `reverse()` drives the
    // controller 1 â†’ 0, which makes the tween output 0 â†’ 1.
    _navFadeCtrl.duration = const Duration(milliseconds: 180);
    await _navFadeCtrl.reverse(from: 1);
  }

  void _onSwipeStart(PointerDownEvent event) {
    _swipeStartX = event.position.dx;
    _swipeStartY = event.position.dy;
    _swipeStartTime = DateTime.now();
  }

  void _onSwipeEnd(PointerUpEvent event) {
    final dx = event.position.dx - _swipeStartX;
    final dy = event.position.dy - _swipeStartY;
    final elapsed =
        DateTime.now().difference(_swipeStartTime).inMilliseconds;
    if (elapsed == 0 || elapsed > 600) return;

    final vx = dx / elapsed * 1000;
    final vy = dy / elapsed * 1000;
    const minVelocity = 400.0; // px/s
    const minDistance = 80.0; // px

    if (vx.abs() > minVelocity &&
        dx.abs() > minDistance &&
        vx.abs() > vy.abs()) {
      // Horizontal swipe â†’ navigate songs.
      if (vx > 0) {
        widget.onNextSong?.call();
      } else {
        widget.onPreviousSong?.call();
      }
    } else if (vy.abs() > minVelocity &&
        dy.abs() > minDistance &&
        vy.abs() > vx.abs()) {
      // Vertical swipe â†’ navigate pages within the current song
      // (page pairs in two-page mode).
      final step = widget.twoPageMode ? 2 : 1;
      if (dy < 0) {
        unawaited(_goToPage(_currentPageIndex + step));
      } else {
        unawaited(_goToPage(_currentPageIndex - step));
      }
    }
  }

  /// Custom layout function implementing the three viewing modes.
  ///
  /// pdfrx requires one [Rect] per page in [pages] (indexed by
  /// position).  The document size is the size of the scrollable
  /// area; pages outside it are clipped.
  ///
  /// Modes:
  ///   * **vertical** (`widget.verticalScrolling`): every page is
  ///     stacked top-to-bottom at the document's widest page width.
  ///     The user scrolls vertically through the song.
  ///   * **two-page** (`widget.twoPageMode`): the page at
  ///     `_currentPageIndex` and the next page are placed side-by-side
  ///     in any orientation; the initial fit scales the whole spread
  ///     into the viewport so both pages are visible at once.  The
  ///     user navigates by pair with the prev/next controls.
  ///   * **normal** (default): every page is placed in a horizontal
  ///     row at the document's tallest page height.  The build method
  ///     uses [PdfViewerController.goToPage] to scroll the viewer to
  ///     `_currentPageIndex`, so the user always sees exactly the
  ///     current page and navigates with the prev/next controls.
  pdfrx.PdfPageLayout _buildLayout(
    List<pdfrx.PdfPage> pages,
    pdfrx.PdfViewerParams params,
  ) {
    final request = _pdfRequest;
    if (request == null) {
      return pdfrx.PdfPageLayout(pageLayouts: [], documentSize: Size.zero);
    }

    // Filter to the page range the cubit asked for (1-based, inclusive
    // start, exclusive end).  Pages outside this range are parked at
    // extreme negative coordinates so they are out of the scrollable
    // area and not hit by the user's gestures.
    final int startPage = request.startPage;
    final int endPage = request.pageCount != null
        ? startPage + request.pageCount!
        : pages.length + 1;

    // Cache key: includes every input that affects geometry.
    // The page signature is a lightweight hash (O(1) per page)
    // rather than the old O(N) string concatenation of every
    // page's number, width and height.
    var pageHash = pages.length;
    for (final page in pages) {
      pageHash = pageHash * 31 + page.pageNumber;
      pageHash = pageHash * 31 + page.width.round();
      pageHash = pageHash * 31 + page.height.round();
    }
    final layoutKey =
        '${request.sourceId}#s$startPage#e$endPage#p$_currentPageIndex#v${widget.verticalScrolling}#t${widget.twoPageMode}#m${params.margin}#ph$pageHash';
    if (_cachedLayout != null && _cachedLayoutKey == layoutKey) {
      return _cachedLayout!;
    }

    final visiblePages = pages
        .where(
          (page) => page.pageNumber >= startPage && page.pageNumber < endPage,
        )
        .toList();
    if (visiblePages.isEmpty) {
      _cachedLayout = pdfrx.PdfPageLayout(
        pageLayouts: const <Rect>[],
        documentSize: const Size(100, 100),
      );
      return _cachedLayout!;
    }

    final margin = params.margin;
    final currentIndex = _currentPageIndex.clamp(0, visiblePages.length - 1);
    final current = visiblePages[currentIndex];
    final next = (currentIndex + 1 < visiblePages.length)
        ? visiblePages[currentIndex + 1]
        : null;

    final Map<int, Rect> visibleRects = {};
    Size documentSize;

    if (widget.verticalScrolling) {
      // Vertical scroll: every page stacked at the document's widest
      // width.  The user scrolls the whole document vertically.
      final width =
          visiblePages.fold(0.0, (w, p) => max(w, p.width)) + margin * 2;
      double y = margin;
      for (final page in visiblePages) {
        visibleRects[page.pageNumber] = Rect.fromLTWH(
          (width - page.width) / 2,
          y,
          page.width,
          page.height,
        );
        y += page.height + margin;
      }
      documentSize = Size(width, y);
    } else if (widget.twoPageMode) {
      // Two-page spread: current page on the left, next page on the
      // right.  When there is no next page (e.g. last odd page) we
      // just render the single current page; the build method shows
      // a placeholder if needed.
      final left = current;
      final right = next;
      if (right != null) {
        final pairWidth = left.width + right.width + margin * 3;
        final pairHeight = max(left.height, right.height) + margin * 2;
        visibleRects[left.pageNumber] = Rect.fromLTWH(
          margin,
          margin,
          left.width,
          left.height,
        );
        visibleRects[right.pageNumber] = Rect.fromLTWH(
          margin + left.width + margin,
          margin,
          right.width,
          right.height,
        );
        documentSize = Size(pairWidth, pairHeight);
      } else {
        visibleRects[left.pageNumber] = Rect.fromLTWH(
          margin,
          margin,
          left.width,
          left.height,
        );
        documentSize = Size(
          left.width + margin * 2,
          left.height + margin * 2,
        );
      }
    } else {
      // Normal mode: only the current page is on-screen.  All
      // other pages are parked far off-screen so the scrollable
      // area is exactly one page wide â€” the user never sees more
      // than the page they are on.  ClampingScrollPhysics on the
      // PdfViewerParams prevents overscroll into the parked pages.
      // When the user navigates with prev/next, `_goToPage`
      // updates `_currentPageIndex`, invalidates the cached layout,
      // and re-fits the viewer to the new page.
      visibleRects[current.pageNumber] = Rect.fromLTWH(
        margin,
        margin,
        current.width,
        current.height,
      );
      documentSize = Size(
        current.width + margin * 2,
        current.height + margin * 2,
      );
    }

    if (documentSize.isEmpty) {
      documentSize = const Size(100, 100);
    }

    // Assemble one Rect per page (pdfrx contract): pages in the
    // requested range get their computed rect; everything else is
    // parked far off-screen so it is out of the scrollable area and
    // not hit by the user's gestures.  Rect.zero must NOT be used â€” a
    // zero-dimension rect causes pdfrx to compute a degenerate (NaN)
    // hit-test transform matrix (1/0 â†’ NaN).
    final pageLayouts = [
      for (final page in pages)
        visibleRects[page.pageNumber] ??
            Rect.fromLTWH(
              -page.width * 100,
              -page.height * 100,
              page.width,
              page.height,
            ),
    ];

    _cachedLayout = pdfrx.PdfPageLayout(
      pageLayouts: pageLayouts,
      documentSize: documentSize,
    );
    _cachedLayoutKey = layoutKey;

    return _cachedLayout!;
  }

  List<Widget> _buildPageOverlays(
    BuildContext context,
    Rect pageRectInViewer,
    pdfrx.PdfPage page,
  ) {
    if (_isTransitioning) return [];
    final request = _pdfRequest;
    if (request == null) return [];

    // PERFORMANCE: pdfrx invokes this callback for *every* page in
    // the document, even pages that are parked off-screen at
    // (-w*100, -h*100) by our custom layout.  Building chord
    // overlays for those pages is pure waste (the widgets never
    // paint, but State objects are still allocated).  Skip them.
    final expectedPageNumber = request.startPage + _currentPageIndex;
    final isCurrentPage = page.pageNumber == expectedPageNumber;
    final isNextPageInTwoPageMode = widget.twoPageMode &&
        page.pageNumber == expectedPageNumber + 1;
    if (!isCurrentPage && !isNextPageInTwoPageMode) return [];

    // Map absolute PDF page number â†’ song-relative page number (1-based).
    final songPage = page.pageNumber - request.startPage + 1;
    final allChords = widget.chords ?? const <int, List<ChordData>>{};
    final pageChords = allChords[songPage] ?? const <ChordData>[];
    if (pageChords.isEmpty && !widget.isEditMode) return [];

    return [
      // IgnorePointer lets tap / swipe gestures pass through to the PDF viewer
      // underneath. The web version uses CSS pointer-events: none on the chord
      // layer in viewer mode for the same reason.
      IgnorePointer(
        ignoring: !widget.isEditMode,
        child: _ChordOverlay(
          page: page,
          songPage: songPage,
          chords: pageChords,
          allChords: allChords,
          transposeStep: widget.transposeStep,
          baseTransposeOffset: widget.baseTransposeOffset,
          chordAccidentalMode: widget.chordAccidentalMode,
          chordFontSizePercent: widget.chordFontSizePercent,
          chordFillOpacityPercent: widget.chordFillOpacityPercent,
          chordPaddingPercent: widget.chordPaddingPercent,
          chordOffsetPercent: widget.chordOffsetPercent,
          pageRectInViewer: pageRectInViewer,
          showChord: widget.showChord,
          isEditMode: widget.isEditMode,
          onChordEdited: widget.onChordsChanged,
          loadNotePositionsAndInfos: _loadNotePositionsAndInfos,
        ),
      ),
    ];
  }
}

/// Compact floating navigator rendered at the bottom-right corner of
/// the PDF viewer when the document has more than one page.  Uses
/// up/down buttons so the user can navigate pages with a tap or
/// with vertical swipe gestures (which are detected by the
/// [Listener] that wraps the PDF viewer).
class _PdfPageNavigator extends StatelessWidget {
  const _PdfPageNavigator({
    required this.theme,
    required this.label,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  final ThemeData theme;
  final String label;
  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.88),
        borderRadius: context.appRadius(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up_rounded),
            onPressed: canGoPrev ? onPrev : null,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            visualDensity: VisualDensity.compact,
            tooltip: 'Halaman sebelumnya',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurfaceVariant,
                fontSize: context.appFontSize(10),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            onPressed: canGoNext ? onNext : null,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            visualDensity: VisualDensity.compact,
            tooltip: 'Halaman berikutnya',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chord overlay
// ---------------------------------------------------------------------------

/// Asynchronously loads note positions for [page] and renders chord badges.
class _ChordOverlay extends StatefulWidget {
  final pdfrx.PdfPage page;
  final int songPage;
  final List<ChordData> chords;
  final Map<int, List<ChordData>> allChords;
  final int transposeStep;
  final int baseTransposeOffset;
  final String chordAccidentalMode;
  final int chordFontSizePercent;
  final int chordFillOpacityPercent;
  final int chordPaddingPercent;
  final int chordOffsetPercent;
  final Rect pageRectInViewer;
  final bool isEditMode;
  final Function(Map<int, List<ChordData>>)? onChordEdited;
  final Future<
    ({
      Map<int, NotePosition> positions,
      List<NoteInfo> infos,
      String? detectedKey,
      double? detectedTempo,
    })
  >
  Function(pdfrx.PdfPage)
  loadNotePositionsAndInfos;

  const _ChordOverlay({
    required this.page,
    required this.songPage,
    required this.chords,
    required this.allChords,
    required this.transposeStep,
    required this.baseTransposeOffset,
    required this.chordAccidentalMode,
    required this.chordFontSizePercent,
    required this.chordFillOpacityPercent,
    required this.chordPaddingPercent,
    required this.chordOffsetPercent,
    required this.pageRectInViewer,
    required this.showChord,
    this.isEditMode = false,
    this.onChordEdited,
    required this.loadNotePositionsAndInfos,
  });

  final bool showChord;

  @override
  State<_ChordOverlay> createState() => _ChordOverlayState();
}

/// Data holder for combined note extraction results.
class _NoteExtractionResult {
  final Map<int, NotePosition> positions;
  final List<NoteInfo> infos;

  const _NoteExtractionResult({required this.positions, required this.infos});
}

class _NoteRow {
  _NoteRow({required this.rowIndex, required this.rowY, required this.notes});

  final int rowIndex;
  final double rowY;
  final List<NoteInfo> notes;

  NoteInfo get first => notes.first;
  NoteInfo get last => notes.last;
}

/// Cache for note extraction results to avoid redundant Future creation.
class _NoteExtractionCache {
  static final Map<String, Future<_NoteExtractionResult>> _futures = {};

  static String _cacheKey(String sourceId, int pageNumber) =>
      '$sourceId#$pageNumber';

  static Future<_NoteExtractionResult>? getExisting(
    String sourceId,
    int pageNumber,
  ) {
    return _futures[_cacheKey(sourceId, pageNumber)];
  }

  static void set(
    String sourceId,
    int pageNumber,
    Future<_NoteExtractionResult> future,
  ) {
    _futures[_cacheKey(sourceId, pageNumber)] = future;
  }

  /// Clear cache when PDF changes
  static void clear() {
    _futures.clear();
  }
}

class _ChordOverlayState extends State<_ChordOverlay> {
  Future<_NoteExtractionResult>? _extractionFuture;
  String _extractionSourceId = '';

  // Cache for _extractRows to avoid O(nÂ²) row clustering on every rebuild.
  List<NoteInfo>? _cachedRowsKey;
  List<_NoteRow>? _cachedRows;

  /// Returns cached row extraction result, recomputing only when the
  /// underlying note-infos list changes identity.
  List<_NoteRow> _extractRowsCached(List<NoteInfo> noteInfos) {
    if (identical(_cachedRowsKey, noteInfos) && _cachedRows != null) {
      return _cachedRows!;
    }
    _cachedRowsKey = noteInfos;
    _cachedRows = _extractRows(noteInfos);
    return _cachedRows!;
  }

  @override
  void initState() {
    super.initState();
    _startExtraction();
  }

  void _startExtraction() {
    // Use asset path from the request stored at the parent widget level
    final request = context
        .findAncestorStateOfType<_SongPdfViewerState>()
        ?._pdfRequest;
    final sourceId = request?.sourceId ?? request?.assetPath ?? '';
    _extractionSourceId = sourceId;
    final pageNumber = widget.page.pageNumber;

    // Check if we have a cached future for this page
    final existingFuture = _NoteExtractionCache.getExisting(
      sourceId,
      pageNumber,
    );
    if (existingFuture != null) {
      _extractionFuture = existingFuture;
      return;
    }

    // Create and cache new future
    _extractionFuture = widget
        .loadNotePositionsAndInfos(widget.page)
        .then(
          (result) => _NoteExtractionResult(
            positions: result.positions,
            infos: result.infos,
          ),
        );
    _NoteExtractionCache.set(sourceId, pageNumber, _extractionFuture!);
  }

  @override
  void didUpdateWidget(_ChordOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final request = context
        .findAncestorStateOfType<_SongPdfViewerState>()
        ?._pdfRequest;
    final sourceId = request?.sourceId ?? request?.assetPath ?? '';
    if (oldWidget.page.pageNumber != widget.page.pageNumber ||
        sourceId != _extractionSourceId) {
      _startExtraction();
    }
  }

  /// Sentinel noteIdx values matching gyschordweb's NOTE_IDX_BEFORE / NOTE_IDX_AFTER.
  static const _noteIdxBefore = ChordSpecialIndices.before;
  static const _noteIdxAfter = ChordSpecialIndices.after;
  static const _rowStartBase = -2000000;
  static const _rowEndBase = 2000000;

  int _noteIdxForRowStart(int rowIndex) => _rowStartBase - rowIndex;
  int _noteIdxForRowEnd(int rowIndex) => _rowEndBase + rowIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: widget.pageRectInViewer.size,
      child: FutureBuilder<_NoteExtractionResult>(
        future: _extractionFuture,
        builder: (context, snapshot) {
          final positions = snapshot.data?.positions;
          final infos = snapshot.data?.infos ?? [];

          final extractionDone =
              snapshot.connectionState == ConnectionState.done ||
              snapshot.hasError;
          final effectivePositions = positions != null && positions.isNotEmpty
              ? Map<int, NotePosition>.from(positions)
              : <int, NotePosition>{};

          if (!extractionDone &&
              effectivePositions.isEmpty &&
              widget.chords.isNotEmpty) {
            return const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          // Resolve sentinel positions for intro/outro chords.
          if (positions != null && positions.isNotEmpty) {
            final sortedKeys = positions.keys.toList()..sort();
            final firstPos = positions[sortedKeys.first]!;
            final lastPos = positions[sortedKeys.last]!;
            effectivePositions[_noteIdxBefore] = (
              xPct: (firstPos.xPct - 2.5).clamp(1.0, 99.0),
              yPct: firstPos.yPct,
            );
            effectivePositions[_noteIdxAfter] = (
              xPct: (lastPos.xPct + 2.5).clamp(1.0, 99.0),
              yPct: lastPos.yPct,
            );

            for (final row in _extractRowsCached(infos)) {
              effectivePositions[_noteIdxForRowStart(row.rowIndex)] = (
                xPct: (row.first.xPct - 2.5).clamp(1.0, 99.0),
                yPct: row.first.yPct,
              );
              effectivePositions[_noteIdxForRowEnd(row.rowIndex)] = (
                xPct: (row.last.xPct + 2.5).clamp(1.0, 99.0),
                yPct: row.last.yPct,
              );
            }
          }

          if (effectivePositions.isEmpty) return const SizedBox.shrink();

          // Build chord badges
          final chordBadges = <Widget>[];
          for (final chord in widget.chords) {
            final position = _positionForChord(chord, effectivePositions);
            if (position != null) {
              chordBadges.add(_buildBadge(context, chord, position));
            }
          }

          // In edit mode, also render note targets using the same data
          if (widget.isEditMode) {
            return RepaintBoundary(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Note targets (clickable in edit mode)
                  ..._buildNoteTargets(infos),
                  // Chord badges
                  ...chordBadges,
                ],
              ),
            );
          }

          return RepaintBoundary(
            child: Stack(clipBehavior: Clip.none, children: chordBadges),
          );
        },
      ),
    );
  }

  List<Widget> _buildNoteTargets(List<NoteInfo> noteInfos) {
    if (noteInfos.isEmpty) return [];

    final pageSize = widget.pageRectInViewer.size;
    final targets = <Widget>[];

    // Add intro sentinel (before first note)
    if (noteInfos.isNotEmpty) {
      final first = noteInfos.first;
      final introXPct = (first.xPct - 2.5).clamp(1.0, 99.0);
      targets.add(
        _buildNoteTarget(
          noteIdx: _noteIdxBefore,
          xPct: introXPct,
          yPct: first.yPct,
          label: 'â–¸',
          title: 'Intro / sebelum lagu',
          pageSize: pageSize,
        ),
      );
    }

    // Add note targets for each detected note
    for (final noteInfo in noteInfos) {
      final label = noteInfo.isNote
          ? noteInfo.str
          : (noteInfo.isDot
                ? (noteInfo.str == '.' ? 'Â·' : noteInfo.str)
                : noteInfo.str);
      targets.add(
        _buildNoteTarget(
          noteIdx: noteInfo.idx,
          xPct: noteInfo.xPct,
          yPct: noteInfo.yPct,
          label: label,
          title: 'Note #${noteInfo.idx}',
          pageSize: pageSize,
        ),
      );
    }

    // Add per-row sentinels so each line can have starter/ending chords.
    for (final row in _extractRowsCached(noteInfos)) {
      final rowStartXPct = (row.first.xPct - 2.5).clamp(1.0, 99.0);
      final rowEndXPct = (row.last.xPct + 2.5).clamp(1.0, 99.0);
      targets.add(
        _buildNoteTarget(
          noteIdx: _noteIdxForRowStart(row.rowIndex),
          xPct: rowStartXPct,
          yPct: row.first.yPct,
          label: 'â–¸',
          title: 'Row ${row.rowIndex + 1} start',
          pageSize: pageSize,
        ),
      );
      targets.add(
        _buildNoteTarget(
          noteIdx: _noteIdxForRowEnd(row.rowIndex),
          xPct: rowEndXPct,
          yPct: row.last.yPct,
          label: 'â—‚',
          title: 'Row ${row.rowIndex + 1} end',
          pageSize: pageSize,
        ),
      );
    }

    // Add outro sentinel (after last note)
    if (noteInfos.isNotEmpty) {
      final last = noteInfos.last;
      final outroXPct = (last.xPct + 2.5).clamp(1.0, 99.0);
      targets.add(
        _buildNoteTarget(
          noteIdx: _noteIdxAfter,
          xPct: outroXPct,
          yPct: last.yPct,
          label: 'â—‚',
          title: 'Outro / setelah lagu',
          pageSize: pageSize,
        ),
      );
    }

    return targets;
  }

  List<_NoteRow> _extractRows(List<NoteInfo> noteInfos) {
    if (noteInfos.isEmpty) return const [];

    final sorted = List<NoteInfo>.from(noteInfos)
      ..sort((a, b) {
        final yCmp = b.rowY.compareTo(a.rowY);
        if (yCmp != 0) return yCmp;
        return a.xPct.compareTo(b.xPct);
      });

    final rows = <_NoteRow>[];
    const tolerance = 2.0;
    for (final info in sorted) {
      final row = rows.firstWhereOrNull(
        (candidate) => (candidate.rowY - info.rowY).abs() < tolerance,
      );
      if (row != null) {
        row.notes.add(info);
      } else {
        rows.add(
          _NoteRow(rowIndex: rows.length, rowY: info.rowY, notes: [info]),
        );
      }
    }

    for (final row in rows) {
      row.notes.sort((a, b) => a.xPct.compareTo(b.xPct));
    }

    return rows;
  }

  NotePosition? _positionForChord(
    ChordData chord,
    Map<int, NotePosition> positions,
  ) {
    final exact = positions[chord.noteIdx];
    if (exact != null) return exact;
    if (positions.isEmpty || chord.noteIdx < 0) return null;

    // Match gyschordweb: any noteIdx beyond the detected notes is treated as
    // an outro placement, not only the explicit NOTE_IDX_AFTER sentinel.
    final sortedKeys =
        positions.keys.where((key) => key >= 0 && key != _noteIdxAfter).toList()
          ..sort();
    if (sortedKeys.isEmpty) return null;
    if (chord.noteIdx >= sortedKeys.length) {
      final lastPos = positions[sortedKeys.last]!;
      return (xPct: (lastPos.xPct + 2.5).clamp(1.0, 99.0), yPct: lastPos.yPct);
    }
    return null;
  }

  Widget _buildNoteTarget({
    required int noteIdx,
    required double xPct,
    required double yPct,
    required String label,
    required String title,
    required Size pageSize,
  }) {
    final x = xPct / 100.0 * pageSize.width;
    final y = yPct / 100.0 * pageSize.height;

    // Check if this note already has a chord
    final existingChord = widget.chords
        .where((c) => c.noteIdx == noteIdx)
        .firstOrNull;

    return Positioned(
      left: x,
      top: y,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: GestureDetector(
          onTap: () =>
              _showNoteChordDialog(context, noteIdx, existingChord?.chord),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: existingChord != null
                  ? Colors.blue.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: context.appRadius(3),
              border: Border.all(
                color: existingChord != null ? Colors.blue : Colors.grey,
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: context.appFontSize(10),
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNoteChordDialog(
    BuildContext context,
    int noteIdx,
    String? existingChord,
  ) {
    final controller = TextEditingController(text: existingChord ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Note #$noteIdx'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Masukkan chord (contoh: C, C#, Bb, Fdim)',
            labelText: 'Chord',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'.tr()),
          ),
          TextButton(
            onPressed: () {
              final chordText = controller.text.trim();
              if (chordText.isEmpty) {
                // Remove chord if empty
                _removeChord(noteIdx);
              } else {
                // Add or update chord
                _addOrUpdateChord(noteIdx, chordText);
              }
              Navigator.pop(context);
            },
            child: Text('Simpan'.tr()),
          ),
        ],
      ),
    );
  }

  void _addOrUpdateChord(int noteIdx, String chordText) {
    final currentPage = widget.songPage;
    final updatedChords = _copyAllChords();

    // Mirror gyschordweb: Untranspose the user's input before saving to database.
    // This ensures that state.currentChords always stays in the "Source Key" (Family Chord).
    final untransposedChord = ChordService.untransposeChord(
      chordText,
      widget.transposeStep,
      baseTransposeOffset: widget.baseTransposeOffset,
      accidentalMode: widget.chordAccidentalMode,
    );

    // Remove existing chord for this note if any
    updatedChords[currentPage] = (updatedChords[currentPage] ?? [])
        .where((c) => c.noteIdx != noteIdx)
        .toList();

    // Add the new chord
    updatedChords[currentPage]!.add(
      ChordData(noteIdx: noteIdx, chord: untransposedChord, page: currentPage),
    );
    updatedChords[currentPage]!.sort((a, b) => a.noteIdx.compareTo(b.noteIdx));

    widget.onChordEdited?.call(updatedChords);
  }

  void _removeChord(int noteIdx) {
    final currentPage = widget.songPage;
    final updatedChords = _copyAllChords();

    // Remove the chord for this note
    updatedChords[currentPage] = (updatedChords[currentPage] ?? [])
        .where((c) => c.noteIdx != noteIdx)
        .toList();

    widget.onChordEdited?.call(updatedChords);
  }

  Map<int, List<ChordData>> _copyAllChords() {
    return {
      for (final entry in widget.allChords.entries)
        entry.key: List<ChordData>.from(entry.value),
    };
  }

  Widget _buildBadge(BuildContext context, ChordData chord, NotePosition pos) {
    final pageSize = widget.pageRectInViewer.size;
    final layout = calculateChordBadgeLayout(
      notePosition: pos,
      renderedPageSize: pageSize,
      pdfPageSize: Size(widget.page.width, widget.page.height),
      fontSizePercent: widget.chordFontSizePercent,
      paddingPercent: widget.chordPaddingPercent,
      offsetPercent: widget.chordOffsetPercent,
    );

    final label = ChordService.transposeChord(
      chord.chord,
      widget.transposeStep,
      baseTransposeOffset: widget.baseTransposeOffset,
      accidentalMode: widget.chordAccidentalMode,
    );

    final opacity = widget.chordFillOpacityPercent / 100.0;
    final theme = Theme.of(context);
    final bgColor = theme.colorScheme.primaryContainer.withValues(
      alpha: opacity,
    );
    final fgColor = theme.colorScheme.onPrimaryContainer;

    // Edit mode visual indicator
    final borderColor = widget.isEditMode
        ? theme.colorScheme.error
        : Colors.transparent;
    final borderWidth = widget.isEditMode ? 2.0 : 0.0;

    // Fade badges in when chords turn on and out when they turn off.
    // The overlay builder stays mounted (never null) so the fade-out can
    // actually play before the next rebuild settles on the hidden state.
    // NOTE: the Positioned must stay the direct child of the page Stack â€”
    // wrapping it in Opacity breaks ParentData â€” so the animation lives
    // INSIDE the Positioned.
    return Positioned(
      left: layout.center.dx,
      top: layout.center.dy,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: widget.showChord ? 0.0 : 1.0,
          end: widget.showChord ? 1.0 : 0.0,
        ),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        child: FractionalTranslation(
          // Match gyschordweb: center both horizontally and vertically (translate -50%, -50%)
          translation: const Offset(-0.5, -0.5),
          child: GestureDetector(
            onTap: widget.isEditMode
                ? () => _showEditDialog(context, chord)
                : null,
            child: Container(
              padding: layout.padding,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: context.appRadius(3),
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: layout.fontSize,
                  color: fgColor,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        builder: (context, opacity, child) =>
            Opacity(opacity: opacity, child: child),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ChordData chord) {
    final controller = TextEditingController(text: chord.chord);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('edit_chord_title'.tr()),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Chord',
            hintText: 'e.g., C, Am, G7',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addOrUpdateChord(chord.noteIdx, controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: Text('Save'.tr()),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal helpers removed (moved to PdfNoteService)
// ---------------------------------------------------------------------------

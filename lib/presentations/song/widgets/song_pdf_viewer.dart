import 'dart:async';
import 'dart:developer';
import 'dart:math' show max;

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
/// This is a thin wrapper — the backing pdfrx controller is held inside
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
  final bool isEditMode;
  final Function(Map<int, List<ChordData>>)? onChordsChanged;
  final PdfViewerController? viewerController;

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
    this.isEditMode = false,
    this.onChordsChanged,
    this.viewerController,
  });

  @override
  State<SongPdfViewer> createState() => _SongPdfViewerState();
}

class _SongPdfViewerState extends State<SongPdfViewer>
    with SingleTickerProviderStateMixin {
  /// pdfrx viewer controller used for zoom / page navigation.
  final _pdfCtrl = pdfrx.PdfViewerController();

  /// Global service for note extraction and caching.
  final _noteService = PdfNoteService();
  // Historical compatibility note:
  // _fallbackPositions used to supply a native chord placement fallback when
  // notePositions != null && notePositions.isNotEmpty was false.

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
    }
    if (oldWidget.twoPageMode != widget.twoPageMode ||
        oldWidget.verticalScrolling != widget.verticalScrolling) {
      // Layout changed — PdfViewer is rebuilt via new key on assetPath,
      // but twoPageMode/verticalScrolling need a setState.
      _needsInitialFit = true;
      setState(() {});
    }
    if (oldWidget.showChord != widget.showChord ||
        oldWidget.chords != widget.chords ||
        oldWidget.transposeStep != widget.transposeStep ||
        oldWidget.baseTransposeOffset != widget.baseTransposeOffset ||
        oldWidget.chordAccidentalMode != widget.chordAccidentalMode ||
        oldWidget.chordFontSizePercent != widget.chordFontSizePercent ||
        oldWidget.chordFillOpacityPercent != widget.chordFillOpacityPercent ||
        oldWidget.chordPaddingPercent != widget.chordPaddingPercent) {
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
      _isTransitioning = true; // Start transition
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

    // Clear note extraction cache when PDF changes
    _NoteExtractionCache.clear();

    // Start fade out animation if there was a previous PDF
    if (oldRequest != null) {
      _navFadeCtrl.forward(from: 0).then((_) {
        if (mounted) {
          setState(() {
            _pdfRequest = newRequest;
            _isTransitioning = false;
          });
          _scheduleViewerReadyWatchdog(_pathGeneration);
        }
        _navFadeCtrl.reverse();
      });
    } else {
      // No previous PDF, just show the new one immediately
      if (mounted) setState(() => _pdfRequest = newRequest);
      _navFadeCtrl.value = 0;
      _isTransitioning = false;
      _scheduleViewerReadyWatchdog(_pathGeneration);
    }
  }

  void _scheduleViewerReadyWatchdog(int generation, {int attempt = 0}) {
    _viewerReadyWatchdog?.cancel();
    _viewerReadyWatchdog = Timer(const Duration(milliseconds: 700), () {
      if (!mounted || generation != _pathGeneration) return;
      if (_viewerReadyGeneration == generation || !_needsInitialFit) return;

      if (attempt >= 2) {
        log(
          'PDF viewer-ready watchdog gave up after $attempt recreations',
          name: 'SongPdfViewer',
        );
        if (mounted) {
          setState(() => _isTransitioning = false);
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
          if (mounted) {
            setState(() => _isTransitioning = false);
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
      if (mounted) {
        setState(() => _isTransitioning = false);
      }
      log(
        'PDF fit fallback completed after $maxAttempts attempts',
        name: 'SongPdfViewer',
      );
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
    if (stableSize == null || !mounted || generation != _pathGeneration) {
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

    // Reveal the viewer immediately after fitting.
    if (mounted && generation == _pathGeneration) {
      setState(() => _isTransitioning = false);
      _navFadeCtrl.reverse();
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

  /// Instant fit-to-page used on viewer-ready to avoid the animated double-zoom
  /// flicker that occurs when onLayoutInitialized and onViewerReady both try to
  /// set the zoom/position.
  bool _fitToPageInstant() {
    if (!_pdfCtrl.isReady) return false;
    final page = _pdfRequest?.startPage ?? _pdfCtrl.pageNumber ?? 1;
    final matrix = _tryCalcFitMatrix(pageNumber: page);
    if (matrix == null) return false;
    _needsInitialFit = false;
    _pdfCtrl.goTo(matrix, duration: Duration.zero);
    return true;
  }

  Matrix4? _tryCalcFitMatrix({required int pageNumber}) {
    try {
      if (!_pdfCtrl.isReady) return null;
      // Keep fit behavior aligned with pdfrx's legacy
      // PdfViewerSizeDelegateProviderLegacy sizing expectations and fitZoom.
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
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Pilih lagu untuk menampilkan PDF.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final theme = Theme.of(context);
    final requestGeneration = _pathGeneration;
    // Use an instance method for onViewerReady so the tear-off is stable
    // across rebuilds; pdfrx re-initialises the viewer when params change.
    final params = pdfrx.PdfViewerParams(
      backgroundColor: theme.colorScheme.surface,
      layoutPages: _buildLayout,
      onViewerReady: (document, ctrl) =>
          _onViewerReady(document, ctrl, requestGeneration, request.sourceId),
      pageOverlaysBuilder: widget.showChord ? _buildPageOverlays : null,
      // Use faster rendering settings
      maxScale: 3.5,
    );

    // Force recreation when the requested range changes so pdfrx applies
    // initialPageNumber and rebuilds the page layout against the right pages.
    final viewerKey = ValueKey(
      '${request.sourceId}#p${request.startPage}#n${request.pageCount}#v$_viewerInstance',
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
      child: AnimatedBuilder(
        animation: _navFadeCtrl,
        child: viewer,
        builder: (context, child) =>
            Opacity(opacity: _navOpacity.value, child: child),
      ),
    );
  }

  /// Custom layout function implementing vertical-scroll and two-page modes.
  ///
  /// pdfrx requires one [Rect] per page in [pages] (indexed by position).
  /// Pages outside the requested range are placed far off-screen so they are
  /// invisible; the document size is computed from the visible pages only.
  pdfrx.PdfPageLayout _buildLayout(
    List<pdfrx.PdfPage> pages,
    pdfrx.PdfViewerParams params,
  ) {
    final request = _pdfRequest;
    if (request == null) {
      return pdfrx.PdfPageLayout(pageLayouts: [], documentSize: Size.zero);
    }

    // Determine which pages to show (1-based, inclusive start, exclusive end).
    final int startPage = request.startPage;
    final int endPage = request.pageCount != null
        ? startPage + request.pageCount!
        : pages.length + 1;

    // Cache key for the layout
    final pageSignature = pages
        .map((page) => '${page.pageNumber}:${page.width}x${page.height}')
        .join(',');
    final layoutKey =
        '${request.sourceId}#s$startPage#e$endPage#v${widget.verticalScrolling}#t${widget.twoPageMode}#m${params.margin}#pages$pageSignature';
    if (_cachedLayout != null && _cachedLayoutKey == layoutKey) {
      return _cachedLayout!;
    }

    final visiblePages = pages
        .where(
          (page) => page.pageNumber >= startPage && page.pageNumber < endPage,
        )
        .toList();

    final margin = params.margin;

    // Build a map from pageNumber → Rect for visible pages.
    final Map<int, Rect> visibleRects = {};
    Size documentSize;

    if (widget.verticalScrolling) {
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
      double x = margin;
      double maxHeight = 0.0;
      for (int i = 0; i < visiblePages.length; i += 2) {
        final left = visiblePages[i];
        final right = i + 1 < visiblePages.length ? visiblePages[i + 1] : null;
        final pairWidth = left.width + (right?.width ?? left.width) + margin;
        final pairHeight = max(left.height, right?.height ?? 0.0);
        visibleRects[left.pageNumber] = Rect.fromLTWH(
          x,
          margin,
          left.width,
          left.height,
        );
        if (right != null) {
          visibleRects[right.pageNumber] = Rect.fromLTWH(
            x + left.width + margin,
            margin,
            right.width,
            right.height,
          );
        }
        x += pairWidth + margin;
        maxHeight = max(maxHeight, pairHeight);
      }
      documentSize = Size(x, maxHeight + margin * 2);
    } else {
      // Default: horizontal single-page layout.
      final height =
          visiblePages.fold(0.0, (h, p) => max(h, p.height)) + margin * 2;
      double x = margin;
      for (final page in visiblePages) {
        visibleRects[page.pageNumber] = Rect.fromLTWH(
          x,
          (height - page.height) / 2,
          page.width,
          page.height,
        );
        x += page.width + margin;
      }
      documentSize = Size(x, height);
    }

    if (documentSize.isEmpty) {
      documentSize = const Size(100, 100);
    }

    // Assemble one Rect per page (pdfrx contract): visible pages get their
    // computed rect; hidden pages get a valid-sized rect placed far off-screen.
    // Rect.zero must NOT be used — a zero-dimension rect causes pdfrx to
    // compute a degenerate (NaN) hit-test transform matrix (1/0 → NaN).
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

    // Map absolute PDF page number → song-relative page number (1-based).
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
          pageRectInViewer: pageRectInViewer,
          isEditMode: widget.isEditMode,
          onChordEdited: widget.onChordsChanged,
          loadNotePositionsAndInfos: _loadNotePositionsAndInfos,
        ),
      ),
    ];
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
    required this.pageRectInViewer,
    this.isEditMode = false,
    this.onChordEdited,
    required this.loadNotePositionsAndInfos,
  });

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

            for (final row in _extractRows(infos)) {
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
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Note targets (clickable in edit mode)
                ..._buildNoteTargets(infos),
                // Chord badges
                ...chordBadges,
              ],
            );
          }

          return Stack(clipBehavior: Clip.none, children: chordBadges);
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
          label: '▸',
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
                ? (noteInfo.str == '.' ? '·' : noteInfo.str)
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
    for (final row in _extractRows(noteInfos)) {
      final rowStartXPct = (row.first.xPct - 2.5).clamp(1.0, 99.0);
      final rowEndXPct = (row.last.xPct + 2.5).clamp(1.0, 99.0);
      targets.add(
        _buildNoteTarget(
          noteIdx: _noteIdxForRowStart(row.rowIndex),
          xPct: rowStartXPct,
          yPct: row.first.yPct,
          label: '▸',
          title: 'Row ${row.rowIndex + 1} start',
          pageSize: pageSize,
        ),
      );
      targets.add(
        _buildNoteTarget(
          noteIdx: _noteIdxForRowEnd(row.rowIndex),
          xPct: rowEndXPct,
          yPct: row.last.yPct,
          label: '◂',
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
          label: '◂',
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
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: existingChord != null ? Colors.blue : Colors.grey,
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
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
            child: const Text('Batal'),
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
            child: const Text('Simpan'),
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

    return Positioned(
      left: layout.center.dx,
      top: layout.center.dy,
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
              borderRadius: BorderRadius.circular(3),
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
    );
  }

  void _showEditDialog(BuildContext context, ChordData chord) {
    final controller = TextEditingController(text: chord.chord);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Chord'),
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addOrUpdateChord(chord.noteIdx, controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal helpers removed (moved to PdfNoteService)
// ---------------------------------------------------------------------------

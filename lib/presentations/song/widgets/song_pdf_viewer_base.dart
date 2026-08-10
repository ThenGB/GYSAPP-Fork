import 'dart:async';
import 'dart:developer';
import 'dart:math' show max, min;

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfrx/pdfrx.dart' as pdfrx;

import '../../../components/components.dart';
import '../../../data/services/chord_service.dart';
import '../../../data/services/pdf_note_extractor.dart';
import '../../../data/services/pdf_note_service.dart';
import '../cubit/song_cubit.dart';
import 'chord_badge_layout.dart';

class PdfViewerController {
  VoidCallback? zoomIn;
  VoidCallback? zoomOut;
  VoidCallback? fitToPage;
}

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
  final _pdfCtrl = pdfrx.PdfViewerController();
  static const double _pageMargin = 8.0;
  final _noteService = PdfNoteService();

  PdfDocumentRequest? _pdfRequest;
  pdfrx.PdfPageLayout? _cachedLayout;
  String? _cachedLayoutKey;
  bool _needsInitialFit = false;

  late final AnimationController _navFadeCtrl;
  late final Animation<double> _navOpacity;

  /// Any async operation that can change the fitted matrix captures this
  /// generation. It changes for both PDF swaps and layout-mode changes, so a
  /// late single-page fit can never overwrite a newer two-page/vertical fit.
  int _fitGeneration = 0;
  int _viewerInstance = 0;
  int? _viewerReadyGeneration;

  Timer? _viewerReadyWatchdog;
  String? _metadataPrimedSourceId;
  final Set<String> _noteStatsLogged = <String>{};

  bool _isTransitioning = false;
  bool _pdfFullyVisible = false;
  int _currentPageIndex = 0;
  int _totalPageCount = 0;

  double _swipeStartX = 0;
  double _swipeStartY = 0;
  DateTime _swipeStartTime = DateTime.now();

  /// Raw pointer bookkeeping so pinch/zoom gestures never masquerade as a
  /// navigation swipe: once a second pointer joins, navigation is refused for
  /// the whole gesture session, and it resets only when every finger lifts.
  int _activePointers = 0;
  bool _multiPointerSeen = false;

  // Navigation swipe contract (deliberately conservative for elderly users):
  // a swipe must cover at least ~110dp within 500ms, move faster than
  // 600dp/s, and be at least 1.8x dominant on one axis. Zooming, pinching,
  // and chord editing always refuse to navigate.
  static const double _swipeMinDistance = 110;
  static const double _swipeMinVelocity = 600;
  static const Duration _swipeMaxElapsed = Duration(milliseconds: 500);
  static const double _swipeAxisRatio = 1.8;
  static const double _swipeZoomBlockThreshold = 1.05;

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
      _cachedParams = null;
    }
    if (oldWidget.twoPageMode != widget.twoPageMode ||
        oldWidget.verticalScrolling != widget.verticalScrolling) {
      final generation = ++_fitGeneration;
      _viewerReadyGeneration = null;
      _viewerReadyWatchdog?.cancel();
      _needsInitialFit = true;
      _cachedLayout = null;
      _cachedLayoutKey = null;
      _cachedParams = null;
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || generation != _fitGeneration) return;
        _invalidatePdfIfReady();
        _scheduleFitWithFallback(generation: generation);
        _scheduleViewerReadyWatchdog(generation);
      });
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
      if (oldWidget.showChord != widget.showChord) {
        _cachedParams = null;
      }
      setState(() {});
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
      _fitGeneration++;
      _cachedLayout = null;
      _cachedLayoutKey = null;
      _needsInitialFit = false;
      _viewerReadyGeneration = null;
      _viewerReadyWatchdog?.cancel();
      _pdfFullyVisible = false;
      _isTransitioning = true;
      _currentPageIndex = 0;
      _totalPageCount = 0;
      _navFadeCtrl.value = 1.0;
      _navFadeCtrl.duration = const Duration(milliseconds: 150);
      _navFadeCtrl.forward(from: 0);
      _navFadeCtrl.addListener(_onFadeCompleteForNull);
      if (mounted) setState(() => _pdfRequest = null);
      return;
    }

    final newRequest = PdfDocumentRequest.parse(path);
    final oldRequest = _pdfRequest;
    if (oldRequest != null && _samePdfRequest(oldRequest, newRequest)) {
      if (!_pdfCtrl.isReady) {
        _needsInitialFit = true;
        _viewerReadyGeneration = null;
        _scheduleViewerReadyWatchdog(_fitGeneration);
      }
      return;
    }

    final generation = ++_fitGeneration;
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
    _NoteExtractionCache.clear();
    _pdfFullyVisible = false;

    if (oldRequest != null) {
      _navFadeCtrl.value = 1.0;
      _navFadeCtrl.duration = const Duration(milliseconds: 150);
      _navFadeCtrl.forward(from: 0).then((_) {
        if (!mounted || generation != _fitGeneration) return;
        _cachedParams = null;
        setState(() {
          _pdfRequest = newRequest;
          _isTransitioning = false;
        });
        _scheduleViewerReadyWatchdog(generation);
      });
    } else {
      if (mounted) setState(() => _pdfRequest = newRequest);
      _navFadeCtrl.value = 0.0;
      _isTransitioning = false;
      _scheduleViewerReadyWatchdog(generation);
    }
  }

  void _scheduleViewerReadyWatchdog(int generation, {int attempt = 0}) {
    _viewerReadyWatchdog?.cancel();
    _viewerReadyWatchdog = Timer(const Duration(milliseconds: 700), () {
      if (!mounted || generation != _fitGeneration) return;
      if (_viewerReadyGeneration == generation || !_needsInitialFit) return;

      if (attempt >= 2) {
        log(
          'PDF viewer-ready watchdog gave up after $attempt recreations',
          name: 'SongPdfViewer',
        );
        if (mounted && generation == _fitGeneration) {
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

  void _scheduleFitWithFallback({int? generation}) {
    _retryFitUntilReady(
      maxAttempts: 8,
      intervalMs: 50,
      generation: generation ?? _fitGeneration,
    );
  }

  Future<void> _retryFitUntilReady({
    required int maxAttempts,
    required int intervalMs,
    required int generation,
  }) async {
    var attempts = 0;
    while (attempts < maxAttempts) {
      if (!mounted || generation != _fitGeneration) return;
      if (_pdfCtrl.isReady && _needsInitialFit) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize && box.size.width > 0) {
          if (!_fitToPageInstant(generation: generation)) {
            await Future.delayed(Duration(milliseconds: intervalMs));
            attempts++;
            continue;
          }
          _invalidatePdfIfReady();
          if (mounted && generation == _fitGeneration) {
            _pdfFullyVisible = true;
            _isTransitioning = false;
            _navFadeCtrl.duration = const Duration(milliseconds: 300);
            _navFadeCtrl.reverse(from: 1.0);
            setState(() {});
          }
          return;
        }
      }
      await Future.delayed(Duration(milliseconds: intervalMs));
      attempts++;
    }

    if (mounted && generation == _fitGeneration && _needsInitialFit) {
      if (_pdfCtrl.isReady && _fitToPageInstant(generation: generation)) {
        _invalidatePdfIfReady();
      }
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
        generation != _fitGeneration ||
        request.sourceId != sourceId) {
      return;
    }
    _viewerReadyGeneration = generation;
    _viewerReadyWatchdog?.cancel();
    _totalPageCount =
        request.pageCount ??
        (document.pages.length - request.startPage + 1)
            .clamp(1, 1 << 30)
            .toInt();
    _currentPageIndex = 0;
    _primeDetectedMetadataFromFirstPage(document, request);
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
    final pageIndex = (request.startPage - 1)
        .clamp(0, document.pages.length - 1)
        .toInt();
    unawaited(_loadNotePositionsAndInfos(document.pages[pageIndex]));
  }

  Future<void> _waitForValidSizeAndFit(
    pdfrx.PdfViewerController ctrl,
    int generation,
  ) async {
    final stableSize = await _waitForStableViewerSize(ctrl, generation);
    if (!mounted || generation != _fitGeneration) return;

    if (stableSize == null && ctrl.isReady && _needsInitialFit) {
      if (!_fitToPageInstant(generation: generation)) {
        _scheduleFitWithFallback(generation: generation);
        return;
      }
      await Future.microtask(() {});
      if (mounted && generation == _fitGeneration) {
        _invalidatePdfIfReady();
        setState(() {});
      }
    } else if (stableSize == null) {
      return;
    }

    if (_needsInitialFit) {
      if (!_fitToPageInstant(generation: generation)) {
        _scheduleFitWithFallback(generation: generation);
        return;
      }
      await Future.microtask(() {});
      if (mounted && generation == _fitGeneration) {
        _invalidatePdfIfReady();
        setState(() {});
      }
    }

    if (mounted && generation == _fitGeneration) {
      _pdfFullyVisible = true;
      _isTransitioning = false;
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
      if (!mounted || generation != _fitGeneration) return null;
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
        if (stableFrames >= requiredStableFrames) return size;
      }
      await WidgetsBinding.instance.endOfFrame;
    }
    return lastSize;
  }

  void _zoomIn() {
    if (_pdfCtrl.isReady) _pdfCtrl.zoomUp();
  }

  void _zoomOut() {
    if (_pdfCtrl.isReady) _pdfCtrl.zoomDown();
  }

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

  bool _fitToPageInstant({int? generation}) {
    final expectedGeneration = generation ?? _fitGeneration;
    if (!_pdfCtrl.isReady || expectedGeneration != _fitGeneration) return false;
    final page = (_pdfRequest?.startPage ?? 1) + _currentPageIndex;
    final matrix = _tryCalcFitMatrix(pageNumber: page);
    if (matrix == null || expectedGeneration != _fitGeneration) return false;
    _needsInitialFit = false;
    _pdfCtrl.goTo(matrix, duration: Duration.zero);
    return true;
  }

  double _fitZoomForSize(Size viewSize, Size documentSize) {
    final safeW = max(viewSize.width - _pageMargin * 2, 1.0);
    final safeH = max(viewSize.height - _pageMargin * 2, 1.0);
    return min(
      safeW / max(documentSize.width, 1.0),
      safeH / max(documentSize.height, 1.0),
    );
  }

  Rect? _firstSongPageRect() {
    final layout = _pdfCtrl.layout;
    final request = _pdfRequest;
    if (request == null || layout.pageLayouts.isEmpty) return null;
    final index = (request.startPage - 1)
        .clamp(0, layout.pageLayouts.length - 1)
        .toInt();
    return layout.pageLayouts[index];
  }

  Matrix4? _tryCalcFitMatrix({required int pageNumber}) {
    try {
      if (!_pdfCtrl.isReady) return null;
      final viewSize = _pdfCtrl.viewSize;
      if (viewSize.width <= 0 || viewSize.height <= 0) return null;

      if (widget.twoPageMode) {
        final document = _pdfCtrl.documentSize;
        if (document.width <= 0 || document.height <= 0) return null;
        final zoom = _fitZoomForSize(viewSize, document);
        return _pdfCtrl.calcMatrixFor(
          Offset(document.width / 2, document.height / 2),
          zoom: zoom,
          viewSize: viewSize,
        );
      }
      if (widget.verticalScrolling) {
        final page = _firstSongPageRect();
        if (page == null || page.width <= 0 || page.height <= 0) return null;
        final zoom = _fitZoomForSize(viewSize, Size(page.width, page.height));
        return _pdfCtrl.calcMatrixFor(
          page.center,
          zoom: zoom,
          viewSize: viewSize,
        );
      }
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
      if (_pdfCtrl.isReady) _pdfCtrl.invalidate();
    } on TypeError {
      // A later viewer-ready pass will redraw after document replacement.
    }
  }

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
    if (_noteStatsLogged.add(statKey)) {
      final noteCount = result.infos.where((n) => n.isNote).length;
      final holdCount = result.infos.where((n) => n.isDot).length;
      final restCount = result.infos.where((n) => n.isRest).length;
      log(
        'Note extraction ${request.assetPath} p${page.pageNumber}: total=${result.infos.length}, notes=$noteCount, holds=$holdCount, rests=$restCount',
        name: 'SongPdfViewer',
      );
    }

    if (result.detectedKey != null || result.detectedTempo != null) {
      final sourceId = request.sourceId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pdfRequest?.sourceId == sourceId) {
          final cubit = context.read<SongCubit>();
          if (result.detectedKey != null) cubit.updatePdfKey(result.detectedKey);
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
    final requestGeneration = _fitGeneration;
    final params = _cachedParams ??= pdfrx.PdfViewerParams(
      backgroundColor: const Color(0xFFFFFFFF),
      layoutPages: _buildLayout,
      onViewerReady: (document, ctrl) =>
          _onViewerReady(document, ctrl, requestGeneration, request.sourceId),
      pageOverlaysBuilder: _buildPageOverlays,
      sizeDelegateProvider: pdfrx.PdfViewerSizeDelegateProviderLegacy(
        maxScale: 3.5,
        calculateInitialZoom: (document, controller, fitZoom, coverZoom) {
          try {
            if (!controller.isReady) return null;
            final viewSize = controller.viewSize;
            if (viewSize.width <= 0 || viewSize.height <= 0) return null;
            if (widget.twoPageMode) {
              final documentSize = controller.documentSize;
              if (documentSize.width <= 0 || documentSize.height <= 0) {
                return null;
              }
              return _fitZoomForSize(viewSize, documentSize);
            }
            final layout = controller.layout;
            if (layout.pageLayouts.isEmpty) return null;
            final pageIndex = (request.startPage - 1)
                .clamp(0, layout.pageLayouts.length - 1)
                .toInt();
            final page = layout.pageLayouts[pageIndex];
            if (page.width <= 0 || page.height <= 0) return null;
            return _fitZoomForSize(viewSize, Size(page.width, page.height));
          } catch (_) {
            return null;
          }
        },
      ),
    );

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
      child: OrientationBuilder(
        builder: (context, orientation) {
          return AnimatedBuilder(
            animation: _navFadeCtrl,
            child: viewer,
            builder: (context, child) {
              final opacity = _pdfFullyVisible ? _navOpacity.value : 0.0;
              final pdfWidget = Opacity(opacity: opacity, child: child);
              if (widget.verticalScrolling) return pdfWidget;

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
                      onPointerMove: _onSwipeMove,
                      onPointerUp: _onSwipeEnd,
                      onPointerCancel: _onSwipeCancel,
                      child: pdfWidget,
                    ),
                    if (widget.twoPageMode &&
                        orientation == Orientation.portrait)
                      const Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: _RotateLandscapeHint(),
                      ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: _PdfPageNavigator(
                        theme: theme,
                        label: displayIndex,
                        canGoPrev: canGoPrev,
                        canGoNext: canGoNext,
                        onPrev: () =>
                            unawaited(_goToPage(_currentPageIndex - step)),
                        onNext: () =>
                            unawaited(_goToPage(_currentPageIndex + step)),
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

  Future<void> _goToPage(int newIndex) async {
    if (newIndex == _currentPageIndex) return;
    final maxIndex = widget.twoPageMode
        ? ((_totalPageCount - 1) ~/ 2) * 2
        : _totalPageCount - 1;
    final clamped = newIndex.clamp(0, maxIndex).toInt();
    if (clamped == _currentPageIndex) return;

    final generation = _fitGeneration;
    _navFadeCtrl.stop();
    _navFadeCtrl.duration = const Duration(milliseconds: 120);
    await _navFadeCtrl.forward(from: 0);
    if (!mounted || generation != _fitGeneration) return;

    setState(() {
      _currentPageIndex = clamped;
      _cachedLayout = null;
      _cachedLayoutKey = null;
    });
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || generation != _fitGeneration) return;
    _invalidatePdfIfReady();
    _fitToPageInstant(generation: generation);
    _navFadeCtrl.duration = const Duration(milliseconds: 180);
    await _navFadeCtrl.reverse(from: 1);
  }

  void _onSwipeStart(PointerDownEvent event) {
    _activePointers++;
    if (_activePointers > 1) {
      // A second finger means pinch/zoom intent: never navigate this session.
      _multiPointerSeen = true;
    }
    if (_activePointers == 1) {
      _multiPointerSeen = false;
      _swipeStartX = event.position.dx;
      _swipeStartY = event.position.dy;
      _swipeStartTime = DateTime.now();
    }
  }

  void _onSwipeMove(PointerMoveEvent event) {
    // no-op: the reference point stays the DOWN position, so a slow drag
    // followed by a fast fling still counts as one gesture.
  }

  void _onSwipeCancel(PointerCancelEvent event) {
    _activePointers = max(_activePointers - 1, 0);
    if (_activePointers == 0) _multiPointerSeen = false;
  }

  /// Whether the viewer is zoomed in beyond ~5% over the fitted page.
  /// While zoomed, a drag must pan the page instead of navigating.
  bool _isZoomedBeyondFit() {
    try {
      if (!_pdfCtrl.isReady) return false;
      final fitZoom = _fitZoomReference();
      if (fitZoom == null || fitZoom <= 0) return false;
      return _pdfCtrl.currentZoom > fitZoom * _swipeZoomBlockThreshold;
    } catch (_) {
      return false;
    }
  }

  /// The zoom scale that fits the current layout into the viewport:
  /// document fit for two-page mode, current page fit otherwise.
  double? _fitZoomReference() {
    try {
      if (!_pdfCtrl.isReady) return null;
      final viewSize = _pdfCtrl.viewSize;
      if (viewSize.width <= 0 || viewSize.height <= 0) return null;
      if (widget.twoPageMode) {
        final document = _pdfCtrl.documentSize;
        if (document.width <= 0 || document.height <= 0) return null;
        return _fitZoomForSize(viewSize, document);
      }
      final page = _currentPageRect();
      if (page == null || page.width <= 0 || page.height <= 0) return null;
      return _fitZoomForSize(viewSize, Size(page.width, page.height));
    } catch (_) {
      return null;
    }
  }

  Rect? _currentPageRect() {
    final layout = _pdfCtrl.layout;
    if (layout.pageLayouts.isEmpty) return null;
    final pageNumber = _pdfCtrl.pageNumber ?? _pdfRequest?.startPage ?? 1;
    final index = (pageNumber - 1).clamp(0, layout.pageLayouts.length - 1);
    return layout.pageLayouts[index];
  }

  void _onSwipeEnd(PointerUpEvent event) {
    _activePointers = max(_activePointers - 1, 0);
    final pointerWasLifted = _activePointers == 0;
    if (pointerWasLifted) {
      final wasMultiPointer = _multiPointerSeen;
      _multiPointerSeen = false;
      _evaluateSwipe(event.position, wasMultiPointer);
    }
  }

  void _evaluateSwipe(Offset position, bool wasMultiPointer) {
    // Never navigate while editing chords, after a pinch/zoom gesture, or
    // when the page is zoomed beyond fit (a drag there must pan).
    if (widget.isEditMode || wasMultiPointer || _isZoomedBeyondFit()) return;

    final dx = position.dx - _swipeStartX;
    final dy = position.dy - _swipeStartY;
    final elapsed = DateTime.now().difference(_swipeStartTime);
    if (elapsed <= Duration.zero || elapsed > _swipeMaxElapsed) return;
    final seconds = elapsed.inMilliseconds / 1000;
    final vx = dx / seconds;
    final vy = dy / seconds;

    if (vx.abs() > _swipeMinVelocity &&
        dx.abs() > _swipeMinDistance &&
        vx.abs() > vy.abs() * _swipeAxisRatio) {
      if (vx > 0) {
        widget.onNextSong?.call();
      } else {
        widget.onPreviousSong?.call();
      }
    } else if (vy.abs() > _swipeMinVelocity &&
        dy.abs() > _swipeMinDistance &&
        vy.abs() > vx.abs() * _swipeAxisRatio) {
      final step = widget.twoPageMode ? 2 : 1;
      if (dy < 0) {
        unawaited(_goToPage(_currentPageIndex + step));
      } else {
        unawaited(_goToPage(_currentPageIndex - step));
      }
    }
  }

  pdfrx.PdfPageLayout _buildLayout(
    List<pdfrx.PdfPage> pages,
    pdfrx.PdfViewerParams params,
  ) {
    final request = _pdfRequest;
    if (request == null) {
      return pdfrx.PdfPageLayout(pageLayouts: [], documentSize: Size.zero);
    }

    final startPage = request.startPage;
    final endPage = request.pageCount != null
        ? startPage + request.pageCount!
        : pages.length + 1;
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
    final currentIndex = _currentPageIndex
        .clamp(0, visiblePages.length - 1)
        .toInt();
    final current = visiblePages[currentIndex];
    final next = currentIndex + 1 < visiblePages.length
        ? visiblePages[currentIndex + 1]
        : null;
    final visibleRects = <int, Rect>{};
    Size documentSize;

    if (widget.verticalScrolling) {
      final width =
          visiblePages.fold(0.0, (w, p) => max(w, p.width)) + margin * 2;
      var y = margin;
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
        documentSize = Size(left.width + margin * 2, left.height + margin * 2);
      }
    } else {
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

    if (documentSize.isEmpty) documentSize = const Size(100, 100);
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

    final expectedPageNumber = request.startPage + _currentPageIndex;
    final isCurrentPage = page.pageNumber == expectedPageNumber;
    final isNextPageInTwoPageMode =
        widget.twoPageMode && page.pageNumber == expectedPageNumber + 1;
    if (!isCurrentPage && !isNextPageInTwoPageMode) return [];

    final songPage = page.pageNumber - request.startPage + 1;
    final allChords = widget.chords ?? const <int, List<ChordData>>{};
    final pageChords = allChords[songPage] ?? const <ChordData>[];
    if (pageChords.isEmpty && !widget.isEditMode) return [];

    return [
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

class _RotateLandscapeHint extends StatelessWidget {
  const _RotateLandscapeHint();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isIndonesian =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'id';
    return Center(
      child: Material(
        color: colors.inverseSurface.withValues(alpha: 0.90),
        borderRadius: context.appRadius(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.screen_rotation_alt_rounded,
                size: 17,
                color: colors.onInverseSurface,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  isIndonesian
                      ? 'Putar ke landscape untuk 2 halaman'
                      : 'Rotate to landscape for two pages',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onInverseSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
            tooltip: 'Halaman Sebelumnya',
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
            tooltip: 'Halaman Berikutnya',
          ),
        ],
      ),
    );
  }
}

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
  > Function(pdfrx.PdfPage) loadNotePositionsAndInfos;

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

class _NoteExtractionCache {
  static final Map<String, Future<_NoteExtractionResult>> _futures = {};

  static String _cacheKey(String sourceId, int pageNumber) =>
      '$sourceId#$pageNumber';

  static Future<_NoteExtractionResult>? getExisting(
    String sourceId,
    int pageNumber,
  ) => _futures[_cacheKey(sourceId, pageNumber)];

  static void set(
    String sourceId,
    int pageNumber,
    Future<_NoteExtractionResult> future,
  ) {
    _futures[_cacheKey(sourceId, pageNumber)] = future;
  }

  static void clear() => _futures.clear();
}

class _ChordOverlayState extends State<_ChordOverlay> {
  Future<_NoteExtractionResult>? _extractionFuture;
  String _extractionSourceId = '';
  List<NoteInfo>? _cachedRowsKey;
  List<_NoteRow>? _cachedRows;

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
    final request = context
        .findAncestorStateOfType<_SongPdfViewerState>()
        ?._pdfRequest;
    final sourceId = request?.sourceId ?? request?.assetPath ?? '';
    _extractionSourceId = sourceId;
    final pageNumber = widget.page.pageNumber;
    final existing = _NoteExtractionCache.getExisting(sourceId, pageNumber);
    if (existing != null) {
      _extractionFuture = existing;
      return;
    }
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

          if (positions != null && positions.isNotEmpty) {
            final sortedKeys = positions.keys.toList()..sort();
            final firstPos = positions[sortedKeys.first]!;
            final lastPos = positions[sortedKeys.last]!;
            effectivePositions[_noteIdxBefore] = (
              xPct: (firstPos.xPct - 2.5).clamp(1.0, 99.0).toDouble(),
              yPct: firstPos.yPct,
            );
            effectivePositions[_noteIdxAfter] = (
              xPct: (lastPos.xPct + 2.5).clamp(1.0, 99.0).toDouble(),
              yPct: lastPos.yPct,
            );
            for (final row in _extractRowsCached(infos)) {
              effectivePositions[_noteIdxForRowStart(row.rowIndex)] = (
                xPct: (row.first.xPct - 2.5).clamp(1.0, 99.0).toDouble(),
                yPct: row.first.yPct,
              );
              effectivePositions[_noteIdxForRowEnd(row.rowIndex)] = (
                xPct: (row.last.xPct + 2.5).clamp(1.0, 99.0).toDouble(),
                yPct: row.last.yPct,
              );
            }
          }

          if (effectivePositions.isEmpty) return const SizedBox.shrink();
          final badges = <Widget>[];
          for (final chord in widget.chords) {
            final position = _positionForChord(chord, effectivePositions);
            if (position != null) {
              badges.add(_buildBadge(context, chord, position));
            }
          }

          if (widget.isEditMode) {
            return RepaintBoundary(
              child: Stack(
                clipBehavior: Clip.none,
                children: [..._buildNoteTargets(infos), ...badges],
              ),
            );
          }
          return RepaintBoundary(
            child: Stack(clipBehavior: Clip.none, children: badges),
          );
        },
      ),
    );
  }

  List<Widget> _buildNoteTargets(List<NoteInfo> noteInfos) {
    if (noteInfos.isEmpty) return [];
    final pageSize = widget.pageRectInViewer.size;
    final targets = <Widget>[];
    final first = noteInfos.first;
    targets.add(
      _buildNoteTarget(
        noteIdx: _noteIdxBefore,
        xPct: (first.xPct - 2.5).clamp(1.0, 99.0).toDouble(),
        yPct: first.yPct,
        label: '▷',
        title: 'Intro / sebelum lagu',
        pageSize: pageSize,
      ),
    );

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

    for (final row in _extractRowsCached(noteInfos)) {
      targets.add(
        _buildNoteTarget(
          noteIdx: _noteIdxForRowStart(row.rowIndex),
          xPct: (row.first.xPct - 2.5).clamp(1.0, 99.0).toDouble(),
          yPct: row.first.yPct,
          label: '▷',
          title: 'Row ${row.rowIndex + 1} start',
          pageSize: pageSize,
        ),
      );
      targets.add(
        _buildNoteTarget(
          noteIdx: _noteIdxForRowEnd(row.rowIndex),
          xPct: (row.last.xPct + 2.5).clamp(1.0, 99.0).toDouble(),
          yPct: row.last.yPct,
          label: '◁',
          title: 'Row ${row.rowIndex + 1} end',
          pageSize: pageSize,
        ),
      );
    }

    final last = noteInfos.last;
    targets.add(
      _buildNoteTarget(
        noteIdx: _noteIdxAfter,
        xPct: (last.xPct + 2.5).clamp(1.0, 99.0).toDouble(),
        yPct: last.yPct,
        label: '◁',
        title: 'Outro / setelah lagu',
        pageSize: pageSize,
      ),
    );
    return targets;
  }

  List<_NoteRow> _extractRows(List<NoteInfo> noteInfos) {
    if (noteInfos.isEmpty) return const [];
    final sorted = List<NoteInfo>.from(noteInfos)
      ..sort((a, b) {
        final yCompare = b.rowY.compareTo(a.rowY);
        if (yCompare != 0) return yCompare;
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
    final sortedKeys = positions.keys.where((key) => key >= 0).toList()..sort();
    if (sortedKeys.isEmpty) return null;
    if (chord.noteIdx >= sortedKeys.length) {
      final lastPos = positions[sortedKeys.last]!;
      return (
        xPct: (lastPos.xPct + 2.5).clamp(1.0, 99.0).toDouble(),
        yPct: lastPos.yPct,
      );
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
                _removeChord(noteIdx);
              } else {
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
    final untransposedChord = ChordService.untransposeChord(
      chordText,
      widget.transposeStep,
      baseTransposeOffset: widget.baseTransposeOffset,
      accidentalMode: widget.chordAccidentalMode,
    );
    updatedChords[currentPage] = (updatedChords[currentPage] ?? [])
        .where((c) => c.noteIdx != noteIdx)
        .toList();
    updatedChords[currentPage]!.add(
      ChordData(noteIdx: noteIdx, chord: untransposedChord, page: currentPage),
    );
    updatedChords[currentPage]!.sort((a, b) => a.noteIdx.compareTo(b.noteIdx));
    widget.onChordEdited?.call(updatedChords);
  }

  void _removeChord(int noteIdx) {
    final currentPage = widget.songPage;
    final updatedChords = _copyAllChords();
    updatedChords[currentPage] = (updatedChords[currentPage] ?? [])
        .where((c) => c.noteIdx != noteIdx)
        .toList();
    widget.onChordEdited?.call(updatedChords);
  }

  Map<int, List<ChordData>> _copyAllChords() => {
    for (final entry in widget.allChords.entries)
      entry.key: List<ChordData>.from(entry.value),
  };

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
    final bgColor = theme.colorScheme.primaryContainer.withValues(alpha: opacity);
    final fgColor = theme.colorScheme.onPrimaryContainer;
    final borderColor = widget.isEditMode
        ? theme.colorScheme.error
        : Colors.transparent;

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
                border: Border.all(
                  color: borderColor,
                  width: widget.isEditMode ? 2 : 0,
                ),
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

import 'dart:async';
import 'dart:developer';
import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart' as pdfrx;

import '../../../data/services/chord_service.dart';
import '../../../data/services/pdf_note_extractor.dart';

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
  final ValueChanged<String?>? onPdfKeyDetected;
  final ValueChanged<double>? onPdfTempoDetected;
  final VoidCallback? onPageChanged;
  final VoidCallback? onPreviousSong;
  final VoidCallback? onNextSong;

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
    this.onPdfKeyDetected,
    this.onPdfTempoDetected,
    this.onPageChanged,
    this.onPreviousSong,
    this.onNextSong,
  });

  @override
  State<SongPdfViewer> createState() => _SongPdfViewerState();
}

class _SongPdfViewerState extends State<SongPdfViewer>
    with SingleTickerProviderStateMixin {
  /// pdfrx viewer controller used for zoom / page navigation.
  final _pdfCtrl = pdfrx.PdfViewerController();

  /// Per-page note position caches loaded from the PDF text layer.
  /// Key: absolute page number (1-based) within the PDF document.
  final Map<int, Map<int, NotePosition>> _noteCache = {};

  _PdfDocumentRequest? _pdfRequest;

  // --- Song-navigation fade+scale transition ---
  late final AnimationController _navFadeCtrl;
  late final Animation<double> _navOpacity;
  late final Animation<double> _navScale;

  /// Monotonically-increasing counter used to cancel stale navigation callbacks
  /// when the user navigates again before the previous fade-out completes.
  int _navGen = 0;

  @override
  void initState() {
    super.initState();
    _navFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _navOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _navFadeCtrl, curve: Curves.easeOut),
    );
    _navScale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _navFadeCtrl, curve: Curves.easeOut),
    );
    _wireController();
    _parsePdfPath();
  }

  @override
  void dispose() {
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
        if (mounted && _pdfCtrl.isReady) _pdfCtrl.invalidate();
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
      if (mounted) setState(() => _pdfRequest = null);
      return;
    }
    final newRequest = _PdfDocumentRequest.parse(path);
    if (_pdfRequest == null) {
      // First load — show immediately with no transition.
      _noteCache.clear();
      if (mounted) setState(() => _pdfRequest = newRequest);
      return;
    }
    // Song navigation — fade out, swap PDF, then fade in (in onViewerReady).
    _navGen++;
    final thisGen = _navGen;
    // Use whenComplete so the callback always runs, even if the animation is
    // superseded by a newer navigation. orCancel.then with onError would skip
    // setState when the ticker was cancelled by rapid navigation.
    _navFadeCtrl.forward(from: _navFadeCtrl.value).whenComplete(() {
      if (!mounted || _navGen != thisGen) return;
      _noteCache.clear();
      setState(() => _pdfRequest = newRequest);
    });
  }

  void _zoomIn() => _pdfCtrl.zoomUp();
  void _zoomOut() => _pdfCtrl.zoomDown();

  /// Animated fit-to-page for the user-facing "Fit" button (200 ms).
  void _fitToPage() {
    if (!_pdfCtrl.isReady) return;
    final page = _pdfCtrl.pageNumber ?? _pdfRequest?.startPage ?? 1;
    final matrix = _pdfCtrl.calcMatrixForFit(pageNumber: page);
    _pdfCtrl.goTo(matrix);
  }

  /// Instant fit-to-page used on viewer-ready to avoid the animated double-zoom
  /// flicker that occurs when onLayoutInitialized and onViewerReady both try to
  /// set the zoom/position.
  void _fitToPageInstant() {
    if (!_pdfCtrl.isReady) return;
    final page = _pdfCtrl.pageNumber ?? _pdfRequest?.startPage ?? 1;
    final matrix = _pdfCtrl.calcMatrixForFit(pageNumber: page);
    _pdfCtrl.goTo(matrix, duration: Duration.zero);
  }

  /// Load and cache note positions for [page] from the PDF text layer.
  Future<Map<int, NotePosition>> _loadNotePositions(pdfrx.PdfPage page) async {
    final n = page.pageNumber;
    if (_noteCache.containsKey(n)) return _noteCache[n]!;
    try {
      final rawText = await page.loadText();
      if (rawText == null) {
        log('page=$n: loadText returned null', name: 'SongPdfViewer.noteExtract');
        return _noteCache[n] = {};
      }
      final positions = extractNotePositions(rawText, page.width, page.height);
      log(
        'page=$n: extracted ${positions.length} positions '
        '(textLen=${rawText.fullText.length})',
        name: 'SongPdfViewer.noteExtract',
      );
      return _noteCache[n] = positions;
    } catch (e, st) {
      log('page=$n: $e\n$st', name: 'SongPdfViewer.noteExtract');
      return _noteCache[n] = {};
    }
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
    return AnimatedBuilder(
      animation: _navFadeCtrl,
      child: pdfrx.PdfViewer.asset(
          request.assetPath,
          key: ValueKey(widget.pdfPath),
          controller: _pdfCtrl,
          initialPageNumber: request.startPage,
          params: pdfrx.PdfViewerParams(
            // Match the web app's viewer-shell-background which uses the theme's
            // surface color. Without this, pdfrx defaults to a white background.
            backgroundColor: theme.colorScheme.surface,
            sizeDelegateProvider: pdfrx.PdfViewerSizeDelegateProviderLegacy(
              calculateInitialZoom: (_, _, fitZoom, _) => fitZoom,
            ),
            layoutPages: _buildLayout,
            onViewerReady: (_, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                // Use instant fit to avoid the animated double-zoom flicker that
                // results from onLayoutInitialized (sets zoom only) and this
                // callback (sets both zoom+position) both running on first render.
                _fitToPageInstant();
                // Fade back in after the PDF is ready and positioned.
                _navFadeCtrl.reverse();
              });
            },
            onPageChanged: (pageNumber) {
              if (pageNumber != null) widget.onPageChanged?.call();
            },
            pageOverlaysBuilder: widget.showChord ? _buildPageOverlays : null,
        ),
      ),
      builder: (context, child) => Opacity(
        opacity: _navOpacity.value,
        child: Transform.scale(
          scale: _navScale.value,
          child: child,
        ),
      ),
    );
  }

  /// Custom layout function implementing vertical-scroll and two-page modes.
  pdfrx.PdfPageLayout _buildLayout(
    List<pdfrx.PdfPage> pages,
    pdfrx.PdfViewerParams params,
  ) {
    final request = _pdfRequest;
    
    // Filter pages to only include those in the requested range
    // This prevents large master PDFs from laying out all pages unnecessarily
    List<pdfrx.PdfPage> filteredPages = pages;
    if (request != null && request.pageCount != null) {
      final startIdx = request.startPage - 1; // Convert to 0-based
      final endIdx = startIdx + request.pageCount!;
      filteredPages = pages
          .where((p) => p.pageNumber >= startIdx && p.pageNumber < endIdx)
          .toList();
    }

    final margin = params.margin;
    if (widget.verticalScrolling) {
      // Vertical layout: pages stacked top-to-bottom.
      final width = filteredPages.fold(0.0, (w, p) => max(w, p.width)) + margin * 2;
      final pageLayouts = <Rect>[];
      double y = margin;
      for (final page in filteredPages) {
        pageLayouts.add(
          Rect.fromLTWH((width - page.width) / 2, y, page.width, page.height),
        );
        y += page.height + margin;
      }
      return pdfrx.PdfPageLayout(
        pageLayouts: pageLayouts,
        documentSize: Size(width, y),
      );
    } else if (widget.twoPageMode) {
      // Two-page (facing pages) layout: pairs of pages side by side.
      final pageLayouts = <Rect>[];
      double x = margin;
      double maxHeight = 0.0;
      for (int i = 0; i < filteredPages.length; i += 2) {
        final left = filteredPages[i];
        final right = i + 1 < filteredPages.length ? filteredPages[i + 1] : null;
        final pairWidth = left.width + (right?.width ?? left.width) + margin;
        final pairHeight = max(left.height, right?.height ?? 0.0);
        pageLayouts.add(Rect.fromLTWH(x, margin, left.width, left.height));
        if (right != null) {
          pageLayouts.add(
            Rect.fromLTWH(
              x + left.width + margin,
              margin,
              right.width,
              right.height,
            ),
          );
        }
        x += pairWidth + margin;
        maxHeight = max(maxHeight, pairHeight);
      }
      return pdfrx.PdfPageLayout(
        pageLayouts: pageLayouts,
        documentSize: Size(x, maxHeight + margin * 2),
      );
    } else {
      // Default: horizontal single-page layout.
      final height = filteredPages.fold(0.0, (h, p) => max(h, p.height)) + margin * 2;
      final pageLayouts = <Rect>[];
      double x = margin;
      for (final page in filteredPages) {
        pageLayouts.add(
          Rect.fromLTWH(x, (height - page.height) / 2, page.width, page.height),
        );
        x += page.width + margin;
      }
      return pdfrx.PdfPageLayout(
        pageLayouts: pageLayouts,
        documentSize: Size(x, height),
      );
    }
  }

  List<Widget> _buildPageOverlays(
    BuildContext context,
    Rect pageRectInViewer,
    pdfrx.PdfPage page,
  ) {
    final chords = widget.chords;
    final request = _pdfRequest;
    if (chords == null || chords.isEmpty || request == null) return [];

    // Map absolute PDF page number → song-relative page number (1-based).
    final songPage = page.pageNumber - request.startPage + 1;
    final pageChords = chords[songPage];
    if (pageChords == null || pageChords.isEmpty) return [];

    return [
      // IgnorePointer lets tap / swipe gestures pass through to the PDF viewer
      // underneath. The web version uses CSS pointer-events: none on the chord
      // layer in viewer mode for the same reason.
      IgnorePointer(
        ignoring: !widget.isEditMode,
        child: _ChordOverlay(
          page: page,
          chords: pageChords,
          transposeStep: widget.transposeStep,
          baseTransposeOffset: widget.baseTransposeOffset,
          chordAccidentalMode: widget.chordAccidentalMode,
          chordFontSizePercent: widget.chordFontSizePercent,
          chordFillOpacityPercent: widget.chordFillOpacityPercent,
          chordPaddingPercent: widget.chordPaddingPercent,
          pageRectInViewer: pageRectInViewer,
          isEditMode: widget.isEditMode,
          onChordEdited: widget.onChordsChanged,
          loadNotePositions: _loadNotePositions,
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
  final List<ChordData> chords;
  final int transposeStep;
  final int baseTransposeOffset;
  final String chordAccidentalMode;
  final int chordFontSizePercent;
  final int chordFillOpacityPercent;
  final int chordPaddingPercent;
  final Rect pageRectInViewer;
  final bool isEditMode;
  final Function(Map<int, List<ChordData>>)? onChordEdited;
  final Future<Map<int, NotePosition>> Function(pdfrx.PdfPage)
  loadNotePositions;

  const _ChordOverlay({
    required this.page,
    required this.chords,
    required this.transposeStep,
    required this.baseTransposeOffset,
    required this.chordAccidentalMode,
    required this.chordFontSizePercent,
    required this.chordFillOpacityPercent,
    required this.chordPaddingPercent,
    required this.pageRectInViewer,
    this.isEditMode = false,
    this.onChordEdited,
    required this.loadNotePositions,
  });

  @override
  State<_ChordOverlay> createState() => _ChordOverlayState();
}

class _ChordOverlayState extends State<_ChordOverlay> {
  late Future<Map<int, NotePosition>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loadNotePositions(widget.page);
  }

  @override
  void didUpdateWidget(_ChordOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.pageNumber != widget.page.pageNumber) {
      _future = widget.loadNotePositions(widget.page);
    }
  }

  /// Sentinel noteIdx values matching gyschordweb's NOTE_IDX_BEFORE / NOTE_IDX_AFTER.
  static const _noteIdxBefore = -1;
  static const _noteIdxAfter = 99999;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: widget.pageRectInViewer.size,
      child: FutureBuilder<Map<int, NotePosition>>(
        future: _future,
        builder: (context, snapshot) {
          final notePositions = snapshot.data;
          final effectivePositions = {
            ..._fallbackPositions(widget.chords),
            if (notePositions != null) ...notePositions,
          };

          // Resolve sentinel positions for intro/outro chords.
          // NOTE_IDX_BEFORE (-1): just before the first note.
          // NOTE_IDX_AFTER (99999): just after the last note.
          if (notePositions != null && notePositions.isNotEmpty) {
            final sortedKeys = notePositions.keys.toList()..sort();
            final firstPos = notePositions[sortedKeys.first]!;
            final lastPos = notePositions[sortedKeys.last]!;
            effectivePositions[_noteIdxBefore] = (
              xPct: (firstPos.xPct - 2.5).clamp(1.0, 99.0),
              yPct: firstPos.yPct,
            );
            effectivePositions[_noteIdxAfter] = (
              xPct: (lastPos.xPct + 2.5).clamp(1.0, 99.0),
              yPct: lastPos.yPct,
            );
          }

          if (effectivePositions.isEmpty) return const SizedBox.shrink();
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (final chord in widget.chords)
                if (effectivePositions.containsKey(chord.noteIdx))
                  _buildBadge(
                    context,
                    chord,
                    effectivePositions[chord.noteIdx]!,
                  ),
            ],
          );
        },
      ),
    );
  }

  Map<int, NotePosition> _fallbackPositions(List<ChordData> chords) {
    if (chords.isEmpty) return {};
    final sorted = List<ChordData>.from(chords)
      ..sort((a, b) => a.noteIdx.compareTo(b.noteIdx));
    const columns = 4;
    const leftPadding = 12.0;
    const rightPadding = 12.0;
    const topPadding = 10.0;
    const bottomPadding = 18.0;
    final rowCount = ((sorted.length + columns - 1) ~/ columns).clamp(1, 12);
    final positions = <int, NotePosition>{};

    for (var i = 0; i < sorted.length; i++) {
      final column = i % columns;
      final row = i ~/ columns;
      final xPct = columns == 1
          ? 50.0
          : leftPadding +
                column * ((100.0 - leftPadding - rightPadding) / (columns - 1));
      final yPct = rowCount == 1
          ? topPadding
          : topPadding +
                row *
                    ((100.0 - topPadding - bottomPadding) /
                        (rowCount - 1).clamp(1, 12));
      positions[sorted[i].noteIdx] = (
        xPct: xPct.clamp(4.0, 96.0),
        yPct: yPct.clamp(4.0, 96.0),
      );
    }

    return positions;
  }

  Widget _buildBadge(BuildContext context, ChordData chord, NotePosition pos) {
    final pageSize = widget.pageRectInViewer.size;
    // Match gyschordweb: NOTE_CHORD_Y_OFFSET_PCT = 2.5
    const chordYOffsetPercent = 2.5;
    final x = pos.xPct / 100.0 * pageSize.width;
    // Apply offset above the note (like gyschordweb: pos.yPct - yOffset)
    final y = (pos.yPct - chordYOffsetPercent) / 100.0 * pageSize.height;

    final label = ChordService.transposeChord(
      chord.chord,
      widget.transposeStep,
      baseTransposeOffset: widget.baseTransposeOffset,
      accidentalMode: widget.chordAccidentalMode,
    );

    final baseFontSize = 10.0 * widget.chordFontSizePercent / 100.0;
    final basePadding = 2.0 * widget.chordPaddingPercent / 100.0;
    final opacity = widget.chordFillOpacityPercent / 100.0;
    final theme = Theme.of(context);
    final bgColor = theme.colorScheme.primaryContainer.withValues(alpha: opacity);
    final fgColor = theme.colorScheme.onPrimaryContainer;
    
    // Edit mode visual indicator
    final borderColor = widget.isEditMode 
        ? theme.colorScheme.error 
        : Colors.transparent;
    final borderWidth = widget.isEditMode ? 2.0 : 0.0;

    return Positioned(
      left: x,
      top: y,
      child: FractionalTranslation(
        // Match gyschordweb: only horizontal centering (translateX -50%)
        // No vertical centering since offset is already applied above
        translation: const Offset(-0.5, 0),
        child: GestureDetector(
          onTap: widget.isEditMode ? () => _showEditDialog(context, chord) : null,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: basePadding * 2,
              vertical: basePadding,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: baseFontSize,
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
                widget.onChordEdited?.call({
                  chord.page: [
                    for (final c in widget.chords)
                      if (c.noteIdx == chord.noteIdx)
                        ChordData(noteIdx: c.noteIdx, chord: controller.text, page: c.page)
                      else
                        c,
                  ],
                });
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
// Internal helpers
// ---------------------------------------------------------------------------

/// Parsed PDF path with optional `#page=N&pages=M` fragment.
///
/// Example: `assets/data/pdf/kr/001.pdf#page=3&pages=2`
class _PdfDocumentRequest {
  const _PdfDocumentRequest({
    required this.assetPath,
    required this.startPage,
    required this.pageCount,
  });

  final String assetPath;
  final int startPage;
  final int? pageCount;

  static _PdfDocumentRequest parse(String value) {
    final normalized = value.replaceAll('\\', '/');
    final fragmentIndex = normalized.indexOf('#');
    if (fragmentIndex < 0) {
      return _PdfDocumentRequest(
        assetPath: normalized,
        startPage: 1,
        pageCount: null,
      );
    }

    final assetPath = normalized.substring(0, fragmentIndex);
    final fragment = normalized.substring(fragmentIndex + 1);

    // Supports query-style fragment: page=N&pages=M
    final params = Uri.splitQueryString(fragment);
    final startPage = int.tryParse(params['page'] ?? '') ?? 1;
    final pageCount = int.tryParse(params['pages'] ?? '');

    return _PdfDocumentRequest(
      assetPath: assetPath,
      startPage: startPage,
      pageCount: pageCount,
    );
  }
}

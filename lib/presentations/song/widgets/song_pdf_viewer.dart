import 'dart:async';
import 'dart:developer';
import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:collection/collection.dart';

import '../../../data/services/chord_service.dart';
import '../../../data/services/pdf_note_extractor.dart';
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

  /// Per-page note position caches loaded from the PDF text layer.
  /// Key: absolute page number (1-based) within the PDF document.
  final Map<int, Map<int, NotePosition>> _noteCache = {};

  /// Per-page note info caches loaded from the PDF text layer (for edit mode).
  /// Key: absolute page number (1-based) within the PDF document.
  final Map<int, List<NoteInfo>> _noteInfoCache = {};

  _PdfDocumentRequest? _pdfRequest;

  /// True while we are waiting for the first [onViewerReady] after a new PDF
  /// is requested. Reset to false once the initial fit-to-page has been done,
  /// so that subsequent [onViewerReady] calls caused by [invalidate] (e.g.
  /// when chord overlay is toggled) do NOT reset the user's zoom/scroll.
  bool _needsInitialFit = false;

  /// Song-navigation fade transition ---
  late final AnimationController _navFadeCtrl;
  late final Animation<double> _navOpacity;

  @override
  void initState() {
    super.initState();
    _navFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
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
      _noteInfoCache.clear();
      _needsInitialFit = true;
      if (mounted) setState(() => _pdfRequest = newRequest);
      return;
    }
    // Song navigation — fade out, swap PDF, then fade in (in onViewerReady).
    _navFadeCtrl.forward(from: _navFadeCtrl.value).whenComplete(() {
      if (!mounted) return;
      _noteCache.clear();
      _noteInfoCache.clear();
      _needsInitialFit = true;
      setState(() => _pdfRequest = newRequest);
    });
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
        log(
          'page=$n: loadText returned null',
          name: 'SongPdfViewer.noteExtract',
        );
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

  /// Load and cache note infos for [page] from the PDF text layer (for edit mode).
  Future<List<NoteInfo>> _loadNoteInfos(pdfrx.PdfPage page) async {
    final n = page.pageNumber;
    if (_noteInfoCache.containsKey(n)) return _noteInfoCache[n]!;
    try {
      final rawText = await page.loadText();
      if (rawText == null) {
        log(
          'page=$n: loadText returned null',
          name: 'SongPdfViewer.noteExtract',
        );
        return _noteInfoCache[n] = [];
      }
      final infos = extractNoteInfos(rawText, page.width, page.height);
      log(
        'page=$n: extracted ${infos.length} note infos '
        '(textLen=${rawText.fullText.length})',
        name: 'SongPdfViewer.noteExtract',
      );
      return _noteInfoCache[n] = infos;
    } catch (e, st) {
      log('page=$n: $e\n$st', name: 'SongPdfViewer.noteExtract');
      return _noteInfoCache[n] = [];
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
        controller: _pdfCtrl,
        initialPageNumber: request.startPage,
        params: pdfrx.PdfViewerParams(
          // Match the web app's viewer-shell-background which uses the theme's
          // surface color. Without this, pdfrx defaults to a white background.
          backgroundColor: theme.colorScheme.surface,
          layoutPages: _buildLayout,
          onViewerReady: (_, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              // Only fit-to-page on the FIRST ready event after a new PDF is
              // loaded. Subsequent onViewerReady calls (e.g. from invalidate
              // after chord/transpose changes) must NOT reset the user's zoom.
              if (_needsInitialFit) {
                _needsInitialFit = false;
                _fitToPageInstant();
              }
              // Fade back in after the PDF is ready and positioned.
              _navFadeCtrl.reverse();
            });
          },
          pageOverlaysBuilder: widget.showChord ? _buildPageOverlays : null,
        ),
      ),
      builder: (context, child) => Opacity(
        opacity: _navOpacity.value,
        child: child,
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

    // Determine which pages to show (1-based, inclusive start, exclusive end).
    final int startPage = request?.startPage ?? 1;
    final int endPage = request?.pageCount != null
        ? startPage + request!.pageCount!
        : pages.length + 1;

    final visiblePages = pages
        .where((p) => p.pageNumber >= startPage && p.pageNumber < endPage)
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
        final right =
            i + 1 < visiblePages.length ? visiblePages[i + 1] : null;
        final pairWidth = left.width + (right?.width ?? left.width) + margin;
        final pairHeight = max(left.height, right?.height ?? 0.0);
        visibleRects[left.pageNumber] =
            Rect.fromLTWH(x, margin, left.width, left.height);
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
            Rect.fromLTWH(-page.width * 100, -page.height * 100, page.width, page.height),
    ];

    return pdfrx.PdfPageLayout(
      pageLayouts: pageLayouts,
      documentSize: documentSize,
    );
  }

  List<Widget> _buildPageOverlays(
    BuildContext context,
    Rect pageRectInViewer,
    pdfrx.PdfPage page,
  ) {
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
          loadNotePositions: _loadNotePositions,
          loadNoteInfos: _loadNoteInfos,
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
  final Future<Map<int, NotePosition>> Function(pdfrx.PdfPage)
  loadNotePositions;
  final Future<List<NoteInfo>> Function(pdfrx.PdfPage) loadNoteInfos;

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
    required this.loadNotePositions,
    required this.loadNoteInfos,
  });

  @override
  State<_ChordOverlay> createState() => _ChordOverlayState();
}

class _ChordOverlayState extends State<_ChordOverlay> {
  late Future<Map<int, NotePosition>> _future;
  late Future<List<NoteInfo>> _noteInfosFuture;

  @override
  void initState() {
    super.initState();
    _future = widget.loadNotePositions(widget.page);
    _noteInfosFuture = widget.loadNoteInfos(widget.page);
  }

  @override
  void didUpdateWidget(_ChordOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.pageNumber != widget.page.pageNumber) {
      _future = widget.loadNotePositions(widget.page);
      _noteInfosFuture = widget.loadNoteInfos(widget.page);
    }
  }

  /// Sentinel noteIdx values matching gyschordweb's NOTE_IDX_BEFORE / NOTE_IDX_AFTER.
  static const _noteIdxBefore = ChordSpecialIndices.before;
  static const _noteIdxAfter = ChordSpecialIndices.after;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: widget.pageRectInViewer.size,
      child: FutureBuilder<Map<int, NotePosition>>(
        future: _future,
        builder: (context, positionSnapshot) {
          // Don't render anything until positions are fully resolved.
          // Showing _fallbackPositions while loading causes wrong chord
          // placement (evenly-spaced grid instead of note-aligned positions).
          if (positionSnapshot.connectionState != ConnectionState.done) {
            return const SizedBox.shrink();
          }
          final notePositions = positionSnapshot.data;
          final effectivePositions =
              notePositions != null && notePositions.isNotEmpty
              ? Map<int, NotePosition>.from(notePositions)
              : _fallbackPositions(widget.chords);

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

          // Build chord badges
          final chordBadges = <Widget>[];
          for (final chord in widget.chords) {
            final position = _positionForChord(chord, effectivePositions);
            if (position != null) {
              chordBadges.add(_buildBadge(context, chord, position));
            }
          }

          // In edit mode, also load and render note targets
          if (widget.isEditMode) {
            return FutureBuilder<List<NoteInfo>>(
              future: _noteInfosFuture,
              builder: (context, noteInfosSnapshot) {
                final noteInfos = noteInfosSnapshot.data ?? [];
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Note targets (clickable in edit mode)
                    ..._buildNoteTargets(noteInfos),
                    // Chord badges
                    ...chordBadges,
                  ],
                );
              },
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
          : (noteInfo.isDot ? '·' : noteInfo.str);
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

    // Remove existing chord for this note if any
    updatedChords[currentPage] = (updatedChords[currentPage] ?? [])
        .where((c) => c.noteIdx != noteIdx)
        .toList();

    // Add the new chord
    updatedChords[currentPage]!.add(
      ChordData(noteIdx: noteIdx, chord: chordText, page: currentPage),
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

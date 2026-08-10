import 'package:flutter/material.dart';

import '../../../data/services/chord_service.dart';
import 'song_pdf_viewer_base.dart' as base;

export 'song_pdf_viewer_base.dart' hide SongPdfViewer;

/// Stable public shell around the PDF viewer.
///
/// A PDF layout-mode change (1 page / 2 pages / vertical) gets a fresh pdfrx
/// viewer State. This is deliberate: pdfrx keeps initial-fit/controller state
/// internally, and reusing the same instance allowed a late fit from the old
/// layout to overwrite the newly selected two-page fit.
class SongPdfViewer extends StatelessWidget {
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
  final base.PdfViewerController? viewerController;
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
  Widget build(BuildContext context) {
    final layoutMode = verticalScrolling
        ? 'vertical'
        : (twoPageMode ? 'two-page' : 'single-page');

    return base.SongPdfViewer(
      // The source plus layout mode are an explicit state boundary. Page/chord
      // updates can still reuse the same viewer; only changes that invalidate
      // pdfrx's fitting assumptions recreate it.
      key: ValueKey('song-pdf:$pdfPath:$layoutMode'),
      pdfPath: pdfPath,
      showChord: showChord,
      chords: chords,
      transposeStep: transposeStep,
      baseTransposeOffset: baseTransposeOffset,
      chordAccidentalMode: chordAccidentalMode,
      twoPageMode: twoPageMode,
      verticalScrolling: verticalScrolling,
      chordFontSizePercent: chordFontSizePercent,
      chordFillOpacityPercent: chordFillOpacityPercent,
      chordPaddingPercent: chordPaddingPercent,
      chordOffsetPercent: chordOffsetPercent,
      isEditMode: isEditMode,
      onChordsChanged: onChordsChanged,
      viewerController: viewerController,
      onNextSong: onNextSong,
      onPreviousSong: onPreviousSong,
    );
  }
}

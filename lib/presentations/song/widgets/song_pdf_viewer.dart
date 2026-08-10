import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/chord_service.dart';
import '../cubit/song_cubit.dart';
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
    final songState = context.watch<SongCubit>().state;
    final chordEnabled = songState.bookCode != 'HYMNE';
    final isFlat = chordAccidentalMode == ChordService.accidentalFlat;

    return Stack(
      fit: StackFit.expand,
      children: [
        base.SongPdfViewer(
          // The source plus layout mode are an explicit state boundary. Page /
          // chord updates can still reuse the same viewer; only changes that
          // invalidate pdfrx's fitting assumptions recreate it.
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
        ),
        if (chordEnabled)
          Positioned(
            top: 12,
            right: 70,
            child: Material(
              elevation: 3,
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHigh
                  .withValues(alpha: 0.94),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: PopupMenuButton<String>(
                tooltip: isFlat ? 'Notasi Flat (♭)' : 'Notasi Sharp (♯)',
                initialValue: chordAccidentalMode,
                onSelected: context
                    .read<SongCubit>()
                    .setChordAccidentalMode,
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: ChordService.accidentalSharp,
                    child: _AccidentalChoice(symbol: '♯', label: 'Sharp'),
                  ),
                  PopupMenuItem<String>(
                    value: ChordService.accidentalFlat,
                    child: _AccidentalChoice(symbol: '♭', label: 'Flat'),
                  ),
                ],
                child: SizedBox.square(
                  dimension: 38,
                  child: Center(
                    child: Text(
                      isFlat ? '♭' : '♯',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AccidentalChoice extends StatelessWidget {
  const _AccidentalChoice({required this.symbol, required this.label});

  final String symbol;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            symbol,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$label ($symbol)'),
      ],
    );
  }
}

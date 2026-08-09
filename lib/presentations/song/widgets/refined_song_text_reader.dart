import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/components.dart';
import '../../../data/services/chord_service.dart';
import '../../../data/services/chord_text_layout.dart';
import '../../../data/services/pdf_note_service.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../domain/entity/song/song_entity.dart';
import '../cubit/song_cubit.dart';

/// Dedicated text-only reading surface.
///
/// Native platforms first use the same PDF note/lyric alignment pipeline as
/// gyschordweb: noteIdx -> PDF note row -> lyric line -> 0..1 horizontal
/// position. The proportional fallback is retained only when PDF extraction is
/// unavailable (and on Web, where PdfNoteService's disk cache is not used).
class RefinedSongTextReader extends StatefulWidget {
  const RefinedSongTextReader({super.key, required this.onOpenMenu});

  final VoidCallback onOpenMenu;

  @override
  State<RefinedSongTextReader> createState() => _RefinedSongTextReaderState();
}

class _RefinedSongTextReaderState extends State<RefinedSongTextReader> {
  int _verseIndex = 0;
  String? _songIdentity;
  String? _chordLayoutKey;
  Future<List<ChordedTextLine>>? _chordLayoutFuture;

  Song? _currentSong(SongState state) {
    if (state.songs.isEmpty) return null;
    final index = state.pageIndex.clamp(0, state.songs.length - 1);
    return state.songs[index];
  }

  void _syncSong(Song? song) {
    final identity = song == null ? null : '${song.code}:${song.number}';
    if (identity == _songIdentity) return;
    _songIdentity = identity;
    _verseIndex = 0;
    _chordLayoutKey = null;
    _chordLayoutFuture = null;
  }

  Future<List<ChordedTextLine>> _alignedChordLayout(SongState state) {
    final pdfPath = state.currentPdfPath;
    if (kIsWeb || pdfPath == null || state.currentChords.isEmpty) {
      return Future.value(const <ChordedTextLine>[]);
    }

    final key = '$pdfPath#${state.currentChords.hashCode}';
    if (_chordLayoutKey == key && _chordLayoutFuture != null) {
      return _chordLayoutFuture!;
    }

    _chordLayoutKey = key;
    final request = PdfDocumentRequest.parse(pdfPath);
    _chordLayoutFuture = PdfNoteService().loadChordedLines(
      pdfPath: request.assetPath,
      startPage: request.startPage,
      pageCount: request.pageCount,
      chords: state.currentChords,
    );
    return _chordLayoutFuture!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongCubit, SongState>(
      builder: (context, state) {
        final song = _currentSong(state);
        _syncSong(song);
        if (song == null) {
          return _EmptyTextReader(onOpenMenu: widget.onOpenMenu);
        }

        final verses = song.verses.isEmpty ? const [''] : song.verses;
        final verseIndex = _verseIndex.clamp(0, verses.length - 1);
        final lines = verses[verseIndex]
            .split('\n')
            .map((line) => line.trimRight())
            .where((line) => line.trim().isNotEmpty)
            .toList(growable: false);

        final allChords = state.currentChords.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        final flattened = allChords.expand((entry) => entry.value).toList()
          ..sort((a, b) => a.noteIdx.compareTo(b.noteIdx));
        final verseChords = state.showChord
            ? chordsForVerse(flattened, verseIndex, verses.length)
            : const <ChordData>[];
        final fallbackByLine = distributeChordsToLines(
          verseChords,
          lines.length,
        );

        return Material(
          color: context.colorScheme.surface,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _TextReaderHeader(
                  song: song,
                  state: state,
                  onOpenMenu: widget.onOpenMenu,
                ),
                Expanded(
                  child: FutureBuilder<List<ChordedTextLine>>(
                    future: state.showChord
                        ? _alignedChordLayout(state)
                        : Future.value(const <ChordedTextLine>[]),
                    initialData: const <ChordedTextLine>[],
                    builder: (context, snapshot) => _ReadingViewport(
                      state: state,
                      song: song,
                      verseIndex: verseIndex,
                      verseCount: verses.length,
                      lines: lines,
                      alignedLines:
                          snapshot.data ?? const <ChordedTextLine>[],
                      fallbackChordsByLine: fallbackByLine,
                      onPreviousVerse: verseIndex > 0
                          ? () => setState(() => _verseIndex = verseIndex - 1)
                          : null,
                      onNextVerse: verseIndex + 1 < verses.length
                          ? () => setState(() => _verseIndex = verseIndex + 1)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TextReaderHeader extends StatelessWidget {
  const _TextReaderHeader({
    required this.song,
    required this.state,
    required this.onOpenMenu,
  });

  final Song song;
  final SongState state;
  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final cubit = context.read<SongCubit>();
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.98),
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.42),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Menu',
            onPressed: onOpenMenu,
            icon: const Icon(Icons.menu_rounded),
          ),
          IconButton(
            tooltip: _label(context, 'Pujian Sebelumnya', 'Previous Hymn'),
            onPressed: cubit.goToPreviousSong,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${song.code ?? ''} ${song.number ?? ''}'.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  song.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: _label(context, 'Pujian Berikutnya', 'Next Hymn'),
            onPressed: cubit.goToNextSong,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
          _TextReaderMenu(state: state),
        ],
      ),
    );
  }
}

class _TextReaderMenu extends StatelessWidget {
  const _TextReaderMenu({required this.state});

  final SongState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SongCubit>();
    final chordEnabled = state.bookCode != 'HYMNE';
    final isFlat = state.chordAccidentalMode == ChordService.accidentalFlat;

    return PopupMenuButton<String>(
      tooltip: _label(context, 'Pilihan Tampilan', 'Viewer Options'),
      icon: const Icon(Icons.tune_rounded),
      onSelected: (value) {
        switch (value) {
          case 'pdf':
            cubit.changeMode();
            break;
          case 'chord':
            cubit.toggleChord();
            break;
          case 'accidental':
            cubit.toggleAccidentalMode();
            break;
          case 'midi':
            cubit.toggleAudio();
            break;
          case 'appearance':
            _showAppearance(context, cubit);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'pdf',
          child: _MenuRow(
            icon: Icons.picture_as_pdf_outlined,
            label: _label(context, 'Kembali ke PDF', 'Back to PDF'),
          ),
        ),
        PopupMenuItem(
          value: 'chord',
          enabled: chordEnabled,
          child: _MenuRow(
            icon: state.showChord
                ? Icons.music_note_rounded
                : Icons.music_off_rounded,
            label: 'Chord',
            emphasized: state.showChord,
          ),
        ),
        PopupMenuItem(
          value: 'accidental',
          enabled: chordEnabled,
          child: _MenuRow(
            leadingText: isFlat ? '♭' : '♯',
            label: isFlat ? 'Flat (♭)' : 'Sharp (♯)',
            emphasized: chordEnabled,
          ),
        ),
        PopupMenuItem(
          value: 'midi',
          child: _MenuRow(
            icon: state.showAudio
                ? Icons.graphic_eq_rounded
                : Icons.piano_outlined,
            label: 'MIDI',
            emphasized: state.showAudio,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'appearance',
          child: _MenuRow(
            icon: Icons.format_align_center_rounded,
            label: _label(context, 'Tampilan Lirik', 'Lyrics Appearance'),
          ),
        ),
      ],
    );
  }

  void _showAppearance(BuildContext context, SongCubit cubit) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const _TextAppearanceSheet(),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    this.icon,
    this.leadingText,
    required this.label,
    this.emphasized = false,
  });

  final IconData? icon;
  final String? leadingText;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: leadingText != null
              ? Text(
                  leadingText!,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : Icon(
                  icon,
                  size: 19,
                  color: emphasized ? colors.primary : colors.onSurfaceVariant,
                ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: emphasized ? colors.primary : colors.onSurface,
            fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ReadingViewport extends StatelessWidget {
  const _ReadingViewport({
    required this.state,
    required this.song,
    required this.verseIndex,
    required this.verseCount,
    required this.lines,
    required this.alignedLines,
    required this.fallbackChordsByLine,
    required this.onPreviousVerse,
    required this.onNextVerse,
  });

  final SongState state;
  final Song song;
  final int verseIndex;
  final int verseCount;
  final List<String> lines;
  final List<ChordedTextLine> alignedLines;
  final List<List<ChordData>> fallbackChordsByLine;
  final VoidCallback? onPreviousVerse;
  final VoidCallback? onNextVerse;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final textTheme = state.getTextThemeByFontName(state.defaultFont);
    final baseStyle = textTheme.bodyLarge?.copyWith(
      color: colors.onSurface,
      fontSize: context.appFontSize(18) * state.defaultTextScale,
      height: state.defaultTextHeight,
      fontWeight: FontWeight.w500,
    );
    final byIndexFallback = buildVerseChordFallback(
      song.verses,
      alignedLines,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
            child: Align(
              alignment: _verticalAlignment(state.lyricsVerticalAlign),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 880),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOutCubic,
                      child: Column(
                        key: ValueKey('${song.code}-${song.number}-$verseIndex'),
                        crossAxisAlignment: _horizontalAlignment(
                          state.lyricsTextAlign,
                        ),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (verseCount > 1) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primaryContainer.withValues(
                                  alpha: 0.65,
                                ),
                                borderRadius: context.appRadius(999),
                              ),
                              child: Text(
                                _label(
                                  context,
                                  'Bait ${verseIndex + 1} dari $verseCount',
                                  'Verse ${verseIndex + 1} of $verseCount',
                                ),
                                style: context.textTheme.labelMedium?.copyWith(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                          for (var index = 0; index < lines.length; index++) ...[
                            _AnchoredLyricLine(
                              lyric: lines[index],
                              placements: _placementsForLine(
                                index,
                                lines[index],
                                byIndexFallback,
                              ),
                              transposeStep: state.transposeStep,
                              baseTransposeOffset: state.baseTransposeOffset,
                              accidentalMode: state.chordAccidentalMode,
                              lyricStyle: baseStyle,
                              textAlign: _textAlign(state.lyricsTextAlign),
                            ),
                            SizedBox(height: 12 * state.defaultTextHeight),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 92,
          child: Row(
            children: [
              IconButton.filledTonal(
                tooltip: _label(context, 'Bait Sebelumnya', 'Previous Verse'),
                onPressed: onPreviousVerse,
                icon: const Icon(Icons.keyboard_arrow_up_rounded),
              ),
              const Spacer(),
              if (state.showChord)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh.withValues(alpha: 0.92),
                    borderRadius: context.appRadius(999),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    '${state.chordAccidentalMode == ChordService.accidentalFlat ? '♭' : '♯'} · ${state.activeKeyLabel.trim().isEmpty ? '—' : state.activeKeyLabel}',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              const Spacer(),
              IconButton.filledTonal(
                tooltip: _label(context, 'Bait Berikutnya', 'Next Verse'),
                onPressed: onNextVerse,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<TextChordPlacement> _placementsForLine(
    int index,
    String lyric,
    List<ChordedTextLine?> byIndexFallback,
  ) {
    if (!state.showChord) return const [];
    final aligned = resolveChordedLineForVerseLine(
      lyric,
      index,
      alignedLines,
      byIndexFallback,
    );
    if (aligned != null && aligned.chords.isNotEmpty) {
      return aligned.chords;
    }
    if (index >= fallbackChordsByLine.length) return const [];
    return fallbackPlacementsForLine(fallbackChordsByLine[index]);
  }
}

class _AnchoredLyricLine extends StatelessWidget {
  const _AnchoredLyricLine({
    required this.lyric,
    required this.placements,
    required this.transposeStep,
    required this.baseTransposeOffset,
    required this.accidentalMode,
    required this.lyricStyle,
    required this.textAlign,
  });

  final String lyric;
  final List<TextChordPlacement> placements;
  final int transposeStep;
  final int baseTransposeOffset;
  final String accidentalMode;
  final TextStyle? lyricStyle;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = math.max(40.0, constraints.maxWidth);
        final base = lyricStyle ?? context.textTheme.bodyLarge!;
        final naturalPainter = TextPainter(
          text: TextSpan(text: lyric, style: base.copyWith(height: 1)),
          textDirection: direction,
          maxLines: 1,
        )..layout();
        final naturalWidth = math.max(1.0, naturalPainter.width);
        final widthScale = math.min(1.0, maxWidth / naturalWidth);
        final fittedFontSize = (base.fontSize ?? 18) * widthScale.clamp(0.55, 1);
        final fittedStyle = base.copyWith(fontSize: fittedFontSize);
        final fittedPainter = TextPainter(
          text: TextSpan(text: lyric, style: fittedStyle.copyWith(height: 1)),
          textDirection: direction,
          maxLines: 1,
        )..layout();
        final textWidth = math.min(maxWidth, fittedPainter.width);
        final origin = switch (textAlign) {
          TextAlign.right || TextAlign.end => maxWidth - textWidth,
          TextAlign.center => (maxWidth - textWidth) / 2,
          _ => 0.0,
        };
        final chordStyle = context.textTheme.labelLarge?.copyWith(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.w900,
          height: 1,
        );

        final chordWidgets = <Widget>[];
        var previousRight = -double.infinity;
        for (final placement in placements) {
          final label = ChordService.transposeChord(
            placement.chord,
            transposeStep,
            baseTransposeOffset: baseTransposeOffset,
            accidentalMode: accidentalMode,
          );
          final chordPainter = TextPainter(
            text: TextSpan(text: label, style: chordStyle),
            textDirection: direction,
            maxLines: 1,
          )..layout();
          var left = origin + placement.safePosition * textWidth;
          left = math.max(left, previousRight + 5);
          left = left.clamp(
            0.0,
            math.max(0.0, maxWidth - chordPainter.width),
          );
          previousRight = left + chordPainter.width;
          chordWidgets.add(
            Positioned(
              left: left,
              top: 0,
              child: Text(label, style: chordStyle),
            ),
          );
        }

        return SizedBox(
          width: maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (placements.isNotEmpty)
                SizedBox(
                  height: 20,
                  child: Stack(clipBehavior: Clip.none, children: chordWidgets),
                ),
              Text(
                lyric,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                textAlign: textAlign,
                style: fittedStyle,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TextAppearanceSheet extends StatelessWidget {
  const _TextAppearanceSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongCubit, SongState>(
      builder: (context, state) {
        final cubit = context.read<SongCubit>();
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _label(context, 'Tampilan Lirik', 'Lyrics Appearance'),
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'left',
                      icon: const Icon(Icons.format_align_left_rounded),
                      label: Text(_label(context, 'Kiri', 'Left')),
                    ),
                    ButtonSegment(
                      value: 'center',
                      icon: const Icon(Icons.format_align_center_rounded),
                      label: Text(_label(context, 'Tengah', 'Center')),
                    ),
                    ButtonSegment(
                      value: 'right',
                      icon: const Icon(Icons.format_align_right_rounded),
                      label: Text(_label(context, 'Kanan', 'Right')),
                    ),
                  ],
                  selected: {state.lyricsTextAlign},
                  onSelectionChanged: (selection) =>
                      cubit.changeLyricsTextAlign(selection.first),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'top',
                      icon: const Icon(Icons.vertical_align_top_rounded),
                      label: Text(_label(context, 'Atas', 'Top')),
                    ),
                    ButtonSegment(
                      value: 'center',
                      icon: const Icon(Icons.vertical_align_center_rounded),
                      label: Text(_label(context, 'Tengah', 'Center')),
                    ),
                    ButtonSegment(
                      value: 'bottom',
                      icon: const Icon(Icons.vertical_align_bottom_rounded),
                      label: Text(_label(context, 'Bawah', 'Bottom')),
                    ),
                  ],
                  selected: {state.lyricsVerticalAlign},
                  onSelectionChanged: (selection) =>
                      cubit.changeLyricsVerticalAlign(selection.first),
                ),
                const SizedBox(height: 14),
                Text(
                  _label(context, 'Ukuran Teks', 'Text Size'),
                  style: context.textTheme.labelLarge,
                ),
                Slider(
                  value: state.defaultTextScale.clamp(0.8, 1.8),
                  min: 0.8,
                  max: 1.8,
                  divisions: 20,
                  onChanged: cubit.changeTextScale,
                ),
                Text(
                  _label(context, 'Jarak Baris', 'Line Height'),
                  style: context.textTheme.labelLarge,
                ),
                Slider(
                  value: state.defaultTextHeight.clamp(1.1, 2.0),
                  min: 1.1,
                  max: 2.0,
                  divisions: 18,
                  onChanged: cubit.changeTextHeight,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyTextReader extends StatelessWidget {
  const _EmptyTextReader({required this.onOpenMenu});

  final VoidCallback onOpenMenu;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: FilledButton.tonalIcon(
            onPressed: onOpenMenu,
            icon: const Icon(Icons.library_music_outlined),
            label: Text(_label(context, 'Pilih Pujian', 'Choose Hymn')),
          ),
        ),
      ),
    );
  }
}

String _label(BuildContext context, String id, String en) {
  return Localizations.localeOf(context).languageCode == 'id' ? id : en;
}

CrossAxisAlignment _horizontalAlignment(String value) => switch (value) {
  'left' => CrossAxisAlignment.start,
  'right' => CrossAxisAlignment.end,
  _ => CrossAxisAlignment.center,
};

Alignment _verticalAlignment(String value) => switch (value) {
  'top' => Alignment.topCenter,
  'bottom' => Alignment.bottomCenter,
  _ => Alignment.center,
};

TextAlign _textAlign(String value) => switch (value) {
  'left' => TextAlign.left,
  'right' => TextAlign.right,
  _ => TextAlign.center,
};

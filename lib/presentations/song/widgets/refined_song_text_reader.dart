import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/components.dart';
import '../../../data/services/chord_service.dart';
import '../../../data/services/chord_text_layout.dart';
import '../../../domain/entity/song/song_entity.dart';
import '../cubit/song_cubit.dart';

/// A focused text-only hymn reader that is independent from the PDF viewer.
///
/// Keeping this surface separate prevents PDF layout callbacks from disturbing
/// lyric/chord layout and lets text mode use its own centered reading model.
class RefinedSongTextReader extends StatefulWidget {
  const RefinedSongTextReader({super.key, required this.onOpenMenu});

  final VoidCallback onOpenMenu;

  @override
  State<RefinedSongTextReader> createState() => _RefinedSongTextReaderState();
}

class _RefinedSongTextReaderState extends State<RefinedSongTextReader> {
  int _verseIndex = 0;
  String? _songIdentity;

  void _syncSong(Song? song) {
    final identity = song == null ? null : '${song.code}:${song.number}';
    if (identity == _songIdentity) return;
    _songIdentity = identity;
    _verseIndex = 0;
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
        final safeVerse = _verseIndex.clamp(0, verses.length - 1);
        if (safeVerse != _verseIndex) _verseIndex = safeVerse;
        final lines = verses[safeVerse]
            .split('\n')
            .map((line) => line.trimRight())
            .where((line) => line.trim().isNotEmpty)
            .toList();

        final allChords = state.currentChords.entries
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        final flattened = allChords.expand((entry) => entry.value).toList()
          ..sort((a, b) => a.noteIdx.compareTo(b.noteIdx));
        final verseChords = state.showChord
            ? chordsForVerse(flattened, safeVerse, verses.length)
            : const <ChordData>[];
        final perLine = distributeChordsToLines(verseChords, lines.length);

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
                  onPreviousSong: context.read<SongCubit>().goToPreviousSong,
                  onNextSong: context.read<SongCubit>().goToNextSong,
                ),
                Expanded(
                  child: _ReadingViewport(
                    state: state,
                    song: song,
                    verseIndex: safeVerse,
                    verseCount: verses.length,
                    lines: lines,
                    chordsByLine: perLine,
                    onPreviousVerse: safeVerse > 0
                        ? () => setState(() => _verseIndex--)
                        : null,
                    onNextVerse: safeVerse + 1 < verses.length
                        ? () => setState(() => _verseIndex++)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Song? _currentSong(SongState state) {
    if (state.songs.isEmpty) return null;
    final index = state.pageIndex.clamp(0, state.songs.length - 1);
    return state.songs[index];
  }
}

class _TextReaderHeader extends StatelessWidget {
  const _TextReaderHeader({
    required this.song,
    required this.state,
    required this.onOpenMenu,
    required this.onPreviousSong,
    required this.onNextSong,
  });

  final Song song;
  final SongState state;
  final VoidCallback onOpenMenu;
  final VoidCallback onPreviousSong;
  final VoidCallback onNextSong;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
            tooltip: _previousSongLabel(context),
            onPressed: onPreviousSong,
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
                    letterSpacing: 0.8,
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
            tooltip: _nextSongLabel(context),
            onPressed: onNextSong,
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
      tooltip: _readerMenuLabel(context),
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
            _showTextAppearance(context);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'pdf',
          child: _MenuRow(
            icon: Icons.picture_as_pdf_outlined,
            label: _pdfModeLabel(context),
          ),
        ),
        PopupMenuItem(
          value: 'chord',
          enabled: chordEnabled,
          child: _MenuRow(
            icon: state.showChord
                ? Icons.check_circle_rounded
                : Icons.music_note_outlined,
            label: _chordLabel(context),
            emphasized: state.showChord,
          ),
        ),
        PopupMenuItem(
          value: 'accidental',
          enabled: chordEnabled,
          child: _MenuRow(
            leadingText: isFlat ? '♭' : '♯',
            label: isFlat ? _flatLabel(context) : _sharpLabel(context),
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
            label: _appearanceLabel(context),
          ),
        ),
      ],
    );
  }

  void _showTextAppearance(BuildContext context) {
    final cubit = context.read<SongCubit>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
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
    required this.chordsByLine,
    required this.onPreviousVerse,
    required this.onNextVerse,
  });

  final SongState state;
  final Song song;
  final int verseIndex;
  final int verseCount;
  final List<String> lines;
  final List<List<ChordData>> chordsByLine;
  final VoidCallback? onPreviousVerse;
  final VoidCallback? onNextVerse;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final horizontal = _horizontalAlignment(state.lyricsTextAlign);
    final vertical = _verticalAlignment(state.lyricsVerticalAlign);
    final textTheme = state.getTextThemeByFontName(state.defaultFont);
    final baseStyle = textTheme.bodyLarge?.copyWith(
      color: colors.onSurface,
      fontSize: context.appFontSize(18) * state.defaultTextScale,
      height: state.defaultTextHeight,
      fontWeight: FontWeight.w500,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 104),
            child: Align(
              alignment: vertical,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOutCubic,
                    child: Column(
                      key: ValueKey('${song.code}-${song.number}-$verseIndex'),
                      crossAxisAlignment: horizontal,
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
                              _verseCounter(context, verseIndex + 1, verseCount),
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
                            placements: index < chordsByLine.length &&
                                    state.showChord
                                ? fallbackPlacementsForLine(chordsByLine[index])
                                : const [],
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
        Positioned(
          left: 16,
          right: 16,
          bottom: 92,
          child: Row(
            children: [
              IconButton.filledTonal(
                tooltip: _previousVerseLabel(context),
                onPressed: onPreviousVerse,
                icon: const Icon(Icons.keyboard_arrow_up_rounded),
              ),
              const Spacer(),
              if (state.showChord)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh.withValues(alpha: 0.92),
                    borderRadius: context.appRadius(999),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    '${state.chordAccidentalMode == ChordService.accidentalFlat ? '♭' : '♯'} · ${state.activeKeyLabel ?? '—'}',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              const Spacer(),
              IconButton.filledTonal(
                tooltip: _nextVerseLabel(context),
                onPressed: onNextVerse,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
            ],
          ),
        ),
      ],
    );
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = math.max(40.0, constraints.maxWidth);
        final base = lyricStyle ?? context.textTheme.bodyLarge!;
        final painter = TextPainter(
          text: TextSpan(text: lyric, style: base.copyWith(height: 1)),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        final naturalWidth = math.max(1.0, painter.width);
        final widthScale = math.min(1.0, maxWidth / naturalWidth);
        final fittedFont = (base.fontSize ?? 18) * math.max(0.70, widthScale);
        final fittedStyle = base.copyWith(fontSize: fittedFont);
        final fittedPainter = TextPainter(
          text: TextSpan(text: lyric, style: fittedStyle.copyWith(height: 1)),
          textDirection: TextDirection.ltr,
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
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout();
          var left = origin + placement.safePosition * textWidth;
          left = math.max(left, previousRight + 5);
          left = left.clamp(0.0, math.max(0.0, maxWidth - chordPainter.width));
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
                SizedBox(height: 20, child: Stack(children: chordWidgets)),
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
                  _appearanceLabel(context),
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
                      label: Text(_leftLabel(context)),
                    ),
                    ButtonSegment(
                      value: 'center',
                      icon: const Icon(Icons.format_align_center_rounded),
                      label: Text(_centerLabel(context)),
                    ),
                    ButtonSegment(
                      value: 'right',
                      icon: const Icon(Icons.format_align_right_rounded),
                      label: Text(_rightLabel(context)),
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
                      label: Text(_topLabel(context)),
                    ),
                    ButtonSegment(
                      value: 'center',
                      icon: const Icon(Icons.vertical_align_center_rounded),
                      label: Text(_centerLabel(context)),
                    ),
                  ],
                  selected: {
                    state.lyricsVerticalAlign == 'bottom'
                        ? 'center'
                        : state.lyricsVerticalAlign,
                  },
                  onSelectionChanged: (selection) =>
                      cubit.changeLyricsVerticalAlign(selection.first),
                ),
                const SizedBox(height: 14),
                Text(_textSizeLabel(context), style: context.textTheme.labelLarge),
                Slider(
                  value: state.defaultTextScale.clamp(0.8, 1.8),
                  min: 0.8,
                  max: 1.8,
                  divisions: 20,
                  onChanged: cubit.changeTextScale,
                ),
                Text(_lineHeightLabel(context), style: context.textTheme.labelLarge),
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
            label: Text(_chooseSongLabel(context)),
          ),
        ),
      ),
    );
  }
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

String _readerMenuLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Pilihan Tampilan'
        : 'Viewer Options';
String _pdfModeLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Kembali ke PDF'
        : 'Back to PDF';
String _chordLabel(BuildContext context) => 'Chord';
String _sharpLabel(BuildContext context) => 'Sharp (♯)';
String _flatLabel(BuildContext context) => 'Flat (♭)';
String _appearanceLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Tampilan Lirik'
        : 'Lyrics Appearance';
String _verseCounter(BuildContext context, int current, int total) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Bait $current dari $total'
        : 'Verse $current of $total';
String _previousSongLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Pujian Sebelumnya'
        : 'Previous Hymn';
String _nextSongLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Pujian Berikutnya'
        : 'Next Hymn';
String _previousVerseLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Bait Sebelumnya'
        : 'Previous Verse';
String _nextVerseLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Bait Berikutnya'
        : 'Next Verse';
String _leftLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id' ? 'Kiri' : 'Left';
String _centerLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id' ? 'Tengah' : 'Center';
String _rightLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id' ? 'Kanan' : 'Right';
String _topLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id' ? 'Atas' : 'Top';
String _textSizeLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Ukuran Teks'
        : 'Text Size';
String _lineHeightLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Jarak Baris'
        : 'Line Height';
String _chooseSongLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Pilih Pujian'
        : 'Choose Hymn';

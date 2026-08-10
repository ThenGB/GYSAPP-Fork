import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/chord_service.dart';
import '../../../data/services/chord_text_layout.dart';
import '../../../data/services/pdf_note_service.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../domain/entity/song/song_entity.dart';
import '../cubit/song_cubit.dart';

/// Refined text-only hymn reader.
///
/// Chord placement follows the same idea used by gyschordweb: resolve the
/// chord to a PDF-note/lyric anchor first, map that anchor to a character in
/// the lyric, then keep the chord attached to that character when the lyric
/// wraps onto multiple visual rows. Proportional noteIdx placement is only the
/// fallback when PDF text/note extraction is unavailable.
class RefinedSongTextReader extends StatefulWidget {
  const RefinedSongTextReader({super.key, required this.onOpenMenu});

  final VoidCallback onOpenMenu;

  @override
  State<RefinedSongTextReader> createState() => _RefinedSongTextReaderState();
}

class _RefinedSongTextReaderState extends State<RefinedSongTextReader> {
  int _verseIndex = 0;
  String? _songIdentity;
  String? _layoutKey;
  Future<List<ChordedTextLine>>? _layoutFuture;

  Song? _currentSong(SongState state) {
    if (state.songs.isEmpty) return null;
    return state.songs[state.pageIndex.clamp(0, state.songs.length - 1)];
  }

  void _syncSong(Song? song) {
    final identity = song == null ? null : '${song.code}:${song.number}';
    if (_songIdentity == identity) return;
    _songIdentity = identity;
    _verseIndex = 0;
    _layoutKey = null;
    _layoutFuture = null;
  }

  Future<List<ChordedTextLine>> _alignedLayout(SongState state) {
    final path = state.currentPdfPath;
    if (kIsWeb || path == null || state.currentChords.isEmpty) {
      return Future.value(const <ChordedTextLine>[]);
    }
    final key = '$path#${state.currentChords.hashCode}';
    if (_layoutKey == key && _layoutFuture != null) return _layoutFuture!;

    final request = PdfDocumentRequest.parse(path);
    _layoutKey = key;
    _layoutFuture = PdfNoteService().loadChordedLines(
      pdfPath: request.assetPath,
      startPage: request.startPage,
      pageCount: request.pageCount,
      chords: state.currentChords,
    );
    return _layoutFuture!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongCubit, SongState>(
      builder: (context, state) {
        final song = _currentSong(state);
        _syncSong(song);
        if (song == null) {
          return _EmptyReader(onOpenMenu: widget.onOpenMenu);
        }

        final verses = song.verses.isEmpty ? const [''] : song.verses;
        final verseIndex = _verseIndex.clamp(0, verses.length - 1);
        final verseText = verses[verseIndex];
        final rawLines = verseText
            .split('\n')
            .map((line) => line.trimRight())
            .toList(growable: false);
        final nonEmptyLines = rawLines
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
          nonEmptyLines.length,
        );

        return Material(
          color: context.colorScheme.surface,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _ReaderHeader(
                  song: song,
                  state: state,
                  onOpenMenu: widget.onOpenMenu,
                ),
                Expanded(
                  child: FutureBuilder<List<ChordedTextLine>>(
                    future: state.showChord
                        ? _alignedLayout(state)
                        : Future.value(const <ChordedTextLine>[]),
                    initialData: const <ChordedTextLine>[],
                    builder: (context, snapshot) => _ReadingViewport(
                      state: state,
                      song: song,
                      verseIndex: verseIndex,
                      verseCount: verses.length,
                      verseText: verseText,
                      rawLines: rawLines,
                      alignedLines:
                          snapshot.data ?? const <ChordedTextLine>[],
                      fallbackByLine: fallbackByLine,
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

class _ReaderHeader extends StatelessWidget {
  const _ReaderHeader({
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
            color: colors.outlineVariant.withValues(alpha: 0.34),
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
          _ReaderMenu(state: state),
        ],
      ),
    );
  }
}

class _ReaderMenu extends StatelessWidget {
  const _ReaderMenu({required this.state});

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
            emphasized: true,
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
        child: const _AppearanceSheet(),
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
    required this.verseText,
    required this.rawLines,
    required this.alignedLines,
    required this.fallbackByLine,
    required this.onPreviousVerse,
    required this.onNextVerse,
  });

  final SongState state;
  final Song song;
  final int verseIndex;
  final int verseCount;
  final String verseText;
  final List<String> rawLines;
  final List<ChordedTextLine> alignedLines;
  final List<List<ChordData>> fallbackByLine;
  final VoidCallback? onPreviousVerse;
  final VoidCallback? onNextVerse;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final textTheme = state.getTextThemeByFontName(state.defaultFont);
    final lyricStyle = textTheme.bodyLarge?.copyWith(
      color: colors.onSurface,
      fontSize: context.appFontSize(18) * state.defaultTextScale,
      height: state.defaultTextHeight,
      fontWeight: state.fontBold ? FontWeight.w700 : FontWeight.w500,
    );

    // Scope the fallback to the current verse only. The previous implementation
    // passed every verse and could reuse line-index matches from a different
    // stanza when two verses had different line structures.
    final byIndexFallback = buildVerseChordFallback([verseText], alignedLines);
    var nonEmptyIndex = 0;

    final lyricWidgets = <Widget>[];
    for (final line in rawLines) {
      if (line.trim().isEmpty) {
        lyricWidgets.add(SizedBox(height: 12 * state.defaultTextHeight));
        continue;
      }
      final lineIndex = nonEmptyIndex++;
      final aligned = resolveChordedLineForVerseLine(
        line,
        lineIndex,
        alignedLines,
        byIndexFallback,
      );
      final placements = !state.showChord
          ? const <TextChordPlacement>[]
          : (aligned != null && aligned.chords.isNotEmpty)
          ? aligned.chords
          : (lineIndex < fallbackByLine.length
                ? fallbackPlacementsForLine(fallbackByLine[lineIndex])
                : const <TextChordPlacement>[]);
      lyricWidgets.add(
        _AdaptiveLyricLine(
          lyric: line,
          placements: placements,
          transposeStep: state.transposeStep,
          baseTransposeOffset: state.baseTransposeOffset,
          accidentalMode: state.chordAccidentalMode,
          lyricStyle: lyricStyle,
          textAlign: _textAlign(state.lyricsTextAlign),
        ),
      );
      lyricWidgets.add(SizedBox(height: 9 * state.defaultTextHeight));
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 104),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max(0, constraints.maxHeight),
                    ),
                    child: Align(
                      alignment: _verticalAlignment(state.lyricsVerticalAlign),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 190),
                            switchInCurve: Curves.easeOutCubic,
                            child: Container(
                              key: ValueKey(
                                '${song.code}-${song.number}-$verseIndex',
                              ),
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: constraints.maxWidth < 430 ? 18 : 28,
                                vertical: constraints.maxWidth < 430 ? 22 : 30,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerLow.withValues(
                                  alpha: 0.86,
                                ),
                                borderRadius: context.appRadius(24),
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(
                                    alpha: 0.42,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.shadow.withValues(alpha: 0.06),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: SelectionArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: _horizontalAlignment(
                                    state.lyricsTextAlign,
                                  ),
                                  children: [
                                    if (verseCount > 1) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colors.primaryContainer
                                              .withValues(alpha: 0.72),
                                          borderRadius: context.appRadius(999),
                                        ),
                                        child: Text(
                                          _label(
                                            context,
                                            'Bait ${verseIndex + 1} dari $verseCount',
                                            'Verse ${verseIndex + 1} of $verseCount',
                                          ),
                                          style: context.textTheme.labelMedium
                                              ?.copyWith(
                                                color:
                                                    colors.onPrimaryContainer,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                    ...lyricWidgets,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          left: 14,
          right: 14,
          bottom: 88,
          child: Row(
            children: [
              IconButton.filledTonal(
                tooltip: _label(context, 'Bait Sebelumnya', 'Previous Verse'),
                onPressed: onPreviousVerse,
                icon: const Icon(Icons.keyboard_arrow_up_rounded),
              ),
              const Spacer(),
              if (state.showChord && state.bookCode != 'HYMNE')
                Material(
                  color: colors.surfaceContainerHigh.withValues(alpha: 0.96),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: colors.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: context.read<SongCubit>().toggleAccidentalMode,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Text(
                        '${state.chordAccidentalMode == ChordService.accidentalFlat ? '♭' : '♯'} · ${state.activeKeyLabel.trim().isEmpty ? '—' : state.activeKeyLabel}',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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
}

class _AdaptiveLyricLine extends StatelessWidget {
  const _AdaptiveLyricLine({
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

  double _measure(String value, TextStyle style, TextDirection direction) {
    if (value.isEmpty) return 0;
    final painter = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: direction,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  List<_VisualRow> _wrapRows(
    double maxWidth,
    TextStyle style,
    TextDirection direction,
  ) {
    final tokens = RegExp(r'\S+\s*').allMatches(lyric).toList();
    if (tokens.isEmpty) {
      return [_VisualRow(text: lyric, start: 0, end: lyric.length)];
    }

    final rows = <_VisualRow>[];
    var buffer = '';
    var start = tokens.first.start;
    for (final token in tokens) {
      final value = token.group(0) ?? '';
      final candidate = '$buffer$value';
      if (buffer.isNotEmpty &&
          _measure(candidate.trimRight(), style, direction) > maxWidth) {
        final visible = buffer.trimRight();
        rows.add(
          _VisualRow(text: visible, start: start, end: start + visible.length),
        );
        start = token.start;
        buffer = value;
      } else {
        if (buffer.isEmpty) start = token.start;
        buffer = candidate;
      }
    }
    final visible = buffer.trimRight();
    if (visible.isNotEmpty) {
      rows.add(
        _VisualRow(text: visible, start: start, end: start + visible.length),
      );
    }
    return rows.isEmpty
        ? [_VisualRow(text: lyric, start: 0, end: lyric.length)]
        : rows;
  }

  int _characterOffsetFor(
    double position,
    TextStyle style,
    TextDirection direction,
  ) {
    if (lyric.isEmpty) return 0;
    final painter = TextPainter(
      text: TextSpan(text: lyric, style: style.copyWith(height: 1)),
      textDirection: direction,
      maxLines: 1,
    )..layout();
    if (painter.width <= 0) return 0;
    return painter
        .getPositionForOffset(
          Offset(position.clamp(0.0, 1.0) * painter.width, 0),
        )
        .offset
        .clamp(0, lyric.length);
  }

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final baseStyle = lyricStyle ?? context.textTheme.bodyLarge!;
    final chordStyle = context.textTheme.labelLarge?.copyWith(
      color: context.colorScheme.primary,
      fontWeight: FontWeight.w900,
      height: 1,
    );
    final resolved = placements
        .map(
          (placement) => _ResolvedPlacement(
            label: ChordService.transposeChord(
              placement.chord,
              transposeStep,
              baseTransposeOffset: baseTransposeOffset,
              accidentalMode: accidentalMode,
            ),
            characterOffset: _characterOffsetFor(
              placement.safePosition,
              baseStyle,
              direction,
            ),
          ),
        )
        .toList(growable: false);

    final alignment = switch (textAlign) {
      TextAlign.right || TextAlign.end => Alignment.centerRight,
      TextAlign.center => Alignment.center,
      _ => Alignment.centerLeft,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = math.max(40.0, constraints.maxWidth);
        final rows = _wrapRows(maxWidth, baseStyle, direction);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final row in rows)
              Align(
                alignment: alignment,
                child: Builder(
                  builder: (context) {
                    final rowWidth = _measure(
                      row.text,
                      baseStyle.copyWith(height: 1),
                      direction,
                    ).clamp(1.0, maxWidth);
                    final rowPlacements = resolved
                        .where(
                          (placement) =>
                              placement.characterOffset >= row.start &&
                              placement.characterOffset <= row.end,
                        )
                        .toList(growable: false);
                    final positioned = <({String label, double left, double width})>[];
                    var previousRight = -double.infinity;
                    for (final placement in rowPlacements) {
                      final localOffset =
                          (placement.characterOffset - row.start).clamp(
                            0,
                            row.text.length,
                          );
                      final prefix = row.text.substring(0, localOffset);
                      final anchor = _measure(
                        prefix,
                        baseStyle.copyWith(height: 1),
                        direction,
                      );
                      final labelWidth = _measure(
                            placement.label,
                            chordStyle ?? const TextStyle(),
                            direction,
                          ) +
                          4;
                      var left = anchor - labelWidth / 2;
                      left = left.clamp(
                        0.0,
                        math.max(0.0, rowWidth - labelWidth),
                      );
                      if (left < previousRight + 5) {
                        left = math.min(
                          math.max(0.0, rowWidth - labelWidth),
                          previousRight + 5,
                        );
                      }
                      previousRight = left + labelWidth;
                      positioned.add((
                        label: placement.label,
                        left: left,
                        width: labelWidth,
                      ));
                    }

                    return SizedBox(
                      width: rowWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (positioned.isNotEmpty)
                            SizedBox(
                              height: 21,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  for (final chord in positioned)
                                    Positioned(
                                      left: chord.left,
                                      top: 0,
                                      child: Text(
                                        chord.label,
                                        style: chordStyle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          Text(
                            row.text,
                            textAlign: textAlign,
                            softWrap: false,
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                            style: baseStyle,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _VisualRow {
  const _VisualRow({required this.text, required this.start, required this.end});

  final String text;
  final int start;
  final int end;
}

class _ResolvedPlacement {
  const _ResolvedPlacement({
    required this.label,
    required this.characterOffset,
  });

  final String label;
  final int characterOffset;
}

class _AppearanceSheet extends StatelessWidget {
  const _AppearanceSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongCubit, SongState>(
      builder: (context, state) {
        final cubit = context.read<SongCubit>();
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
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
                DropdownButtonFormField<String>(
                  initialValue: state.availableFonts.contains(state.defaultFont)
                      ? state.defaultFont
                      : state.availableFonts.first,
                  decoration: InputDecoration(
                    labelText: _label(context, 'Jenis Huruf', 'Font'),
                  ),
                  items: [
                    for (final font in state.availableFonts)
                      DropdownMenuItem(value: font, child: Text(font)),
                  ],
                  onChanged: (font) {
                    if (font != null) cubit.changeFont(font);
                  },
                ),
                const SizedBox(height: 14),
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
                  onSelectionChanged: (value) =>
                      cubit.changeLyricsTextAlign(value.first),
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
                  onSelectionChanged: (value) =>
                      cubit.changeLyricsVerticalAlign(value.first),
                ),
                const SizedBox(height: 14),
                _SliderSetting(
                  label: _label(context, 'Ukuran Teks', 'Text Size'),
                  value: state.defaultTextScale.clamp(0.8, 1.8),
                  min: 0.8,
                  max: 1.8,
                  onChanged: cubit.changeTextScale,
                ),
                _SliderSetting(
                  label: _label(context, 'Jarak Baris', 'Line Height'),
                  value: state.defaultTextHeight.clamp(1.1, 2.0),
                  min: 1.1,
                  max: 2.0,
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

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: context.textTheme.labelLarge),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

class _EmptyReader extends StatelessWidget {
  const _EmptyReader({required this.onOpenMenu});

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

String _label(BuildContext context, String id, String en) =>
    Localizations.localeOf(context).languageCode.toLowerCase() == 'id' ? id : en;

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

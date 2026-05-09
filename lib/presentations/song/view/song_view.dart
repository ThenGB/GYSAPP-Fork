// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/services/chord_service.dart';
import '../../../domain/entity/song/song_entity.dart';
import '../../../router/router.dart';
import '../../presentations.dart';
import '../widgets/draggable_midi_controls.dart';
import '../widgets/song_pdf_viewer.dart';

@RoutePage()
class SongView extends StatefulWidget {
  const SongView({super.key});

  @override
  State<SongView> createState() => _SongViewState();
}

class _SongViewState extends State<SongView> {
  late final cubit = context.read<SongCubit>();
  late final int _initialPageIndex = _resolveInitialPageIndex();
  late final PageController pageController = PageController(
    initialPage: _initialPageIndex,
  )..addListener(pageListener);

  late int currentPageIndex = _initialPageIndex;
  int _currentVerseIndex = 0;

  int _resolveInitialPageIndex() {
    try {
      final index = cubit.state.histories.last.index;
      if (cubit.state.songs.length > index) {
        return index;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Map<int, List<ChordData>>? _currentChords;
  String? _currentPdfPath;

  void pageListener() {
    final newIndex = pageController.page?.round() ?? currentPageIndex;
    if (newIndex != currentPageIndex) {
      setState(() {
        currentPageIndex = newIndex;
        _currentVerseIndex = 0;
      });
      cubit.changePage(newIndex, 0);
      _loadChordData();
      _loadPdfForCurrentSong();
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadChordData();
    _loadPdfForCurrentSong();
  }

  Future<void> _loadChordData() async {
    if (currentPageIndex >= cubit.state.songs.length) return;
    final song = cubit.state.songs[currentPageIndex];
    final chords = await cubit.loadChordData(song);
    if (mounted) {
      setState(() {
        _currentChords = chords;
      });
    }
  }

  Future<void> _loadPdfForCurrentSong() async {
    if (currentPageIndex >= cubit.state.songs.length) return;
    final song = cubit.state.songs[currentPageIndex];
    final pdfPath = await cubit.getPdfPath(song.code ?? '', song.number ?? '');
    if (mounted) {
      setState(() {
        _currentPdfPath = pdfPath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SongCubit, SongState>(
      listenWhen: (previous, current) =>
          previous.pageIndex != current.pageIndex ||
          previous.bookCode != current.bookCode ||
          previous.playOnlyFavorite != current.playOnlyFavorite,
      listener: (context, state) {
        setState(() {
          currentPageIndex = state.pageIndex;
          _currentVerseIndex = state.verseIndex;
        });
        _loadChordData();
        _loadPdfForCurrentSong();
        if (!pageController.hasClients) return;
        pageController.jumpToPage(state.pageIndex);
      },
      builder: (context, state) {
        final textMode = state.isImageMode == true;
        final colors = Theme.of(context).colorScheme;
        final isFavorite =
            state.songs.isNotEmpty && currentPageIndex < state.songs.length
            ? cubit.isSongFavorite(state.songs[currentPageIndex])
            : false;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.primary,
            surfaceTintColor: Colors.transparent,
            shape: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.list_alt_rounded),
              tooltip: 'Selector nomor pujian',
              onPressed: _openSongSelector,
            ),
            title: _SongHeaderTitle(
              number: state.getSongNumberAt(currentPageIndex),
              title: state.getSongTitleAt(currentPageIndex),
              familyChord: state.originalFamilyChord,
              pdfKey: state.originalPdfKey,
              accidentalMode: state.chordAccidentalMode,
              baseTransposeOffset: state.baseTransposeOffset,
              canGoPrevious: currentPageIndex > 0,
              canGoNext: currentPageIndex < state.songs.length - 1,
              onPrevious: _goToPreviousSong,
              onNext: _goToNextSong,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu_rounded),
                tooltip: 'Menu',
                onPressed: openDashboardDrawer,
              ),
              IconButton(
                icon: Icon(
                  state.showAudio ? Icons.volume_up : Icons.volume_off,
                  color: state.showAudio
                      ? colors.secondary
                      : colors.onSurface.withValues(alpha: 0.4),
                ),
                tooltip: state.showAudio
                    ? 'Sembunyikan MIDI'
                    : 'Tampilkan MIDI',
                onPressed: () => cubit.toggleAudio(),
              ),
              IconButton(
                icon: Icon(
                  state.showChord ? Icons.music_note : Icons.music_off,
                  color: state.showChord
                      ? colors.secondary
                      : colors.onSurface.withValues(alpha: 0.4),
                ),
                tooltip: state.showChord
                    ? 'Sembunyikan chord'
                    : 'Tampilkan chord',
                onPressed: () => cubit.toggleChord(),
              ),
              IconButton(
                icon: Icon(
                  textMode
                      ? Icons.picture_as_pdf_rounded
                      : Icons.article_outlined,
                ),
                tooltip: textMode ? 'Mode PDF' : 'Mode teks',
                onPressed: cubit.changeMode,
              ),
              if (textMode)
                IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  tooltip: 'Pengaturan lirik',
                  onPressed: _openLyricsSettings,
                ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'fav':
                      if (currentPageIndex < state.songs.length) {
                        cubit.modifyFavorite(
                          state.songs[currentPageIndex],
                          playOnlyFav: false,
                        );
                      }
                      break;
                    case 'copy':
                      _copyCurrentVerse(state);
                      break;
                    case 'share':
                      _shareCurrentSong(state);
                      break;
                    case 'notes':
                      router.push(SongNotesListRoute(cubit: context.read()));
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'fav',
                    child: Row(
                      children: [
                        Text('Favorite'.tr()),
                        const Spacer(),
                        Icon(
                          isFavorite
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(value: 'copy', child: Text('Copy'.tr())),
                  PopupMenuItem(value: 'share', child: Text('Share'.tr())),
                  PopupMenuItem(
                    value: 'notes',
                    child: Text('See all notes'.tr()),
                  ),
                ],
              ),
            ],
          ),
          body: Stack(
            children: [
              // PDF Viewer
              PageView.builder(
                controller: pageController,
                itemCount: state.songs.length,
                itemBuilder: (context, index) {
                  final song = state.songs[index];
                  if (textMode) {
                    return _SongTextPage(
                      song: song,
                      fontFamily: state.defaultFont,
                      textScale: state.defaultTextScale,
                      textHeight: state.defaultTextHeight,
                      fontBold: state.fontBold,
                      textAlign: state.lyricsTextAlign,
                      verticalAlign: state.lyricsVerticalAlign,
                      verseIndex: _currentVerseIndex,
                      onPreviousVerse: _previousVerse,
                      onNextVerse: () => _nextVerse(song),
                    );
                  }
                  return const SizedBox();
                },
              ),

              // Single persistent PDF viewer (not per-page, WebView/JS is not reloaded on song switch)
              if (!textMode && _currentPdfPath != null)
                SongPdfViewer(
                  key: const ValueKey('pdf_viewer'),
                  pdfPath: _currentPdfPath,
                  showChord: state.showChord,
                  chords: _currentChords,
                  transposeStep: state.transposeStep,
                  baseTransposeOffset: state.baseTransposeOffset,
                  chordAccidentalMode: state.chordAccidentalMode,
                  twoPageMode: state.pdfTwoPageMode,
                  verticalScrolling: state.pdfVerticalScrolling,
                  chordFontSizePercent: state.chordFontSizePercent,
                  chordFillOpacityPercent: state.chordFillOpacityPercent,
                  chordPaddingPercent: state.chordPaddingPercent,
                  onPdfKeyDetected: cubit.updatePdfKey,
                  onPdfTempoDetected: cubit.setDefaultTempo,
                ),

              // Draggable MIDI Controls
              if (state.showAudio)
                AnimatedBuilder(
                  animation: cubit.midiEngine,
                  builder: (context, child) {
                    final midiState = cubit.midiEngine.state;
                    return DraggableMidiControls(
                      nowPlayingTitle: state.getSongTitleAt(currentPageIndex),
                      isPlaying: midiState.isPlaying,
                      isLoading: midiState.isLoading,
                      position: midiState.position,
                      duration: midiState.duration,
                      transposeStep: state.transposeStep,
                      currentKey: state.activeKeyLabel,
                      availableKeys: state.transposeKeyOptions,
                      tempoBpm: state.tempoBpm,
                      midiInstrument: state.midiInstrument,
                      soundFont: state.soundFont,
                      availableSoundFonts: const [
                        'GeneralUser-GS.sf2',
                        'TimGM6mb.sf2',
                      ],
                      availableInstruments: cubit.midiEngine.instruments,
                      onPlayPause: () => cubit.togglePlayPause(),
                      onStop: () => cubit.stop(),
                      onSeek: (seconds) =>
                          cubit.seek(Duration(seconds: seconds.toInt())),
                      onTranspose: (semitones) => cubit.setTranspose(semitones),
                      onKeySelected: cubit.setTransposeKey,
                      onTempo: (bpm) => cubit.setTempo(bpm),
                      onInstrument: cubit.setMidiInstrument,
                      onSoundFont: cubit.setSoundFont,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _copyCurrentVerse(SongState state) async {
    if (currentPageIndex >= state.songs.length) return;
    final song = state.songs[currentPageIndex];
    final text = '${song.number} - ${song.title}';
    await Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(msg: 'Copied to clipboard'.tr());
  }

  void _shareCurrentSong(SongState state) {
    if (currentPageIndex >= state.songs.length) return;
    final song = state.songs[currentPageIndex];
    final text = '${song.number} - ${song.title}';
    Share.share(text, subject: song.title);
  }

  Future<void> _openLyricsSettings() {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return BlocBuilder<SongCubit, SongState>(
          bloc: cubit,
          builder: (context, state) {
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                Text(
                  'Pengaturan lirik',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: state.availableFonts.contains(state.defaultFont)
                      ? state.defaultFont
                      : state.availableFonts.first,
                  decoration: const InputDecoration(labelText: 'Font'),
                  items: state.availableFonts
                      .map(
                        (font) => DropdownMenuItem<String>(
                          value: font,
                          child: Text(font),
                        ),
                      )
                      .toList(),
                  onChanged: (font) {
                    if (font != null) cubit.changeFont(font);
                  },
                ),
                const SizedBox(height: 16),
                _LyricsSlider(
                  label: 'Ukuran',
                  value: state.defaultTextScale,
                  min: 0.8,
                  max: 2.4,
                  divisions: 16,
                  displayValue: '${(state.defaultTextScale * 100).round()}%',
                  onChanged: cubit.changeTextScale,
                ),
                _LyricsSlider(
                  label: 'Spacing',
                  value: state.defaultTextHeight,
                  min: 1.0,
                  max: 2.4,
                  divisions: 14,
                  displayValue: state.defaultTextHeight.toStringAsFixed(1),
                  onChanged: cubit.changeTextHeight,
                ),
                const SizedBox(height: 8),
                _LyricsChoiceGroup(
                  label: 'Horizontal',
                  value: state.lyricsTextAlign,
                  options: const {
                    'left': 'Kiri',
                    'center': 'Tengah',
                    'right': 'Kanan',
                  },
                  onSelected: cubit.changeLyricsTextAlign,
                ),
                const SizedBox(height: 8),
                _LyricsChoiceGroup(
                  label: 'Vertikal',
                  value: state.lyricsVerticalAlign,
                  options: const {
                    'top': 'Atas',
                    'center': 'Tengah',
                    'bottom': 'Bawah',
                  },
                  onSelected: cubit.changeLyricsVerticalAlign,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openSongSelector() {
    router.push(
      SongListRoute(
        books: () => cubit.state.songBook,
        currentBook: () =>
            cubit.state.currentSong ??
            SongBook(code: cubit.state.bookCode, songs: const []),
        favoriteBooks: () => cubit.state.favoriteSongBook,
        initialSearchText: cubit.state.searchTerms,
        onSearchTermsChanged: cubit.onSearchTermsChanged,
        onChangeBookCode: (bookCode) {
          cubit.changeBookcode(bookCode);
          _jumpToSongIndex(0);
        },
        onTapPageNumber: (pageNumber) {
          final index = cubit.state.songs.indexWhere(
            (song) => song.number == pageNumber,
          );
          router.maybePop();
          _jumpToSongIndex(index < 0 ? 0 : index);
        },
        onTapFavorite: (song) {
          cubit.changeBookcode(song.code ?? cubit.state.bookCode);
          final index = cubit.state.songs.indexWhere(
            (item) => item.code == song.code && item.number == song.number,
          );
          router.maybePop();
          _jumpToSongIndex(index < 0 ? 0 : index);
        },
        isFavorite: cubit.isSongFavorite,
        onFavorite: (song) => cubit.modifyFavorite(song, playOnlyFav: false),
        onBack: () => router.maybePop(),
        onPlayFavorite: () {
          if (cubit.state.isAudioPlaying) {
            cubit.pause();
          } else {
            cubit.play();
          }
        },
      ),
    );
  }

  void _previousVerse() {
    setState(() {
      if (_currentVerseIndex > 0) _currentVerseIndex--;
    });
  }

  void _nextVerse(Song song) {
    setState(() {
      if (_currentVerseIndex < song.verses.length - 1) _currentVerseIndex++;
    });
  }

  void _jumpToSongIndex(int index) {
    if (index < 0 || index >= cubit.state.songs.length) return;
    setState(() {
      currentPageIndex = index;
      _currentVerseIndex = 0;
    });
    cubit.changePage(index, 0);
    _loadChordData();
    if (!pageController.hasClients) return;
    pageController.jumpToPage(index);
  }

  void _goToPreviousSong() => _animateToSongIndex(currentPageIndex - 1);

  void _goToNextSong() => _animateToSongIndex(currentPageIndex + 1);

  void _animateToSongIndex(int index) {
    if (index < 0 || index >= cubit.state.songs.length) return;
    setState(() {
      currentPageIndex = index;
    });
    cubit.changePage(index, 0);
    _loadChordData();
    _loadPdfForCurrentSong();
    if (!pageController.hasClients) return;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }
}

class _SongHeaderTitle extends StatelessWidget {
  final String? number;
  final String title;
  final String? familyChord;
  final String? pdfKey;
  final String accidentalMode;
  final int baseTransposeOffset;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _SongHeaderTitle({
    required this.number,
    required this.title,
    required this.familyChord,
    required this.pdfKey,
    required this.accidentalMode,
    required this.baseTransposeOffset,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: canGoPrevious ? 1.0 : 0.0,
          child: IconButton(
            tooltip: 'Pujian sebelumnya',
            onPressed: canGoPrevious ? onPrevious : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
        ),
        Flexible(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Container(
              key: ValueKey('$number-$title'),
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    [
                      if ((number ?? '').isNotEmpty) number,
                      title,
                    ].whereType<String>().join(' - '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                    ),
                  ),
                  if (familyChord != null)
                    Text(
                      'Family ${ChordService.formatChordForDisplay(familyChord!, accidentalMode: accidentalMode, baseTransposeOffset: baseTransposeOffset)}${pdfKey == null ? '' : ' / PDF $pdfKey'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.72),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Opacity(
          opacity: canGoNext ? 1.0 : 0.0,
          child: IconButton(
            tooltip: 'Pujian berikutnya',
            onPressed: canGoNext ? onNext : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ),
      ],
    );
  }
}

class _SongTextPage extends StatelessWidget {
  final Song song;
  final String fontFamily;
  final double textScale;
  final double textHeight;
  final bool fontBold;
  final String textAlign;
  final String verticalAlign;
  final int verseIndex;
  final VoidCallback? onPreviousVerse;
  final VoidCallback? onNextVerse;

  const _SongTextPage({
    required this.song,
    required this.fontFamily,
    required this.textScale,
    required this.textHeight,
    required this.fontBold,
    required this.textAlign,
    required this.verticalAlign,
    required this.verseIndex,
    this.onPreviousVerse,
    this.onNextVerse,
  });

  TextAlign _resolveTextAlign() {
    switch (textAlign) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  MainAxisAlignment _resolveVerticalAlign() {
    switch (verticalAlign) {
      case 'center':
        return MainAxisAlignment.center;
      case 'bottom':
        return MainAxisAlignment.end;
      default:
        return MainAxisAlignment.start;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verses = song.verses;
    final hasVerses = verses.isNotEmpty;
    final safeIndex = hasVerses ? verseIndex.clamp(0, verses.length - 1) : 0;
    final currentVerse = hasVerses ? verses[safeIndex] : null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -160) {
          onNextVerse?.call();
        } else if (velocity > 160) {
          onPreviousVerse?.call();
        }
      },
      child: SelectionArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight - 28)
                            .clamp(0, double.infinity)
                            .toDouble(),
                      ),
                      child: Column(
                        mainAxisAlignment: _resolveVerticalAlign(),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (hasVerses) ...[
                            Text(
                              'Bait ${safeIndex + 1} dari ${verses.length}',
                              textAlign: _resolveTextAlign(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.5,
                                ),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentVerse!,
                              textAlign: _resolveTextAlign(),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontFamily: fontFamily,
                                fontSize: 16 * textScale,
                                height: textHeight,
                                fontWeight: fontBold
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ] else
                            Text(
                              'Teks lagu belum tersedia.',
                              textAlign: _resolveTextAlign(),
                              style: theme.textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (hasVerses && verses.length > 1)
              Container(
                padding: EdgeInsets.only(
                  bottom: 12 + MediaQuery.paddingOf(context).bottom,
                  left: 20,
                  right: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: safeIndex > 0 ? onPreviousVerse : null,
                      icon: const Icon(Icons.keyboard_arrow_up, size: 20),
                      label: const Text('Atas'),
                    ),
                    TextButton.icon(
                      onPressed: safeIndex < verses.length - 1
                          ? onNextVerse
                          : null,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                      label: const Text('Bawah'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LyricsSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _LyricsSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: textTheme.bodyMedium)),
            Text(displayValue, style: textTheme.bodySmall),
          ],
        ),
        Slider(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _LyricsChoiceGroup extends StatelessWidget {
  final String label;
  final String value;
  final Map<String, String> options;
  final ValueChanged<String> onSelected;

  const _LyricsChoiceGroup({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.entries
              .map(
                (entry) => ChoiceChip(
                  label: Text(entry.value),
                  selected: value == entry.key,
                  onSelected: (_) => onSelected(entry.key),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

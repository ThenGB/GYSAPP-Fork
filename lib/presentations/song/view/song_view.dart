// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
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
  bool _isChordEditMode = false;

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
  late String _currentBookCode = cubit.state.bookCode;
  final _pdfViewerController = PdfViewerController();

  void pageListener() {
    final newIndex = pageController.page?.round() ?? currentPageIndex;
    if (newIndex != currentPageIndex) {
      setState(() {
        currentPageIndex = newIndex;
        _currentVerseIndex = 0;
      });
      cubit.changePage(newIndex, 0);
      // Note: PDF/chord loading is handled by BlocConsumer listener
      // to avoid duplicate loading and race conditions
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openSongSelector();
    });
  }

  Future<void> _loadChordData() async {
    if (currentPageIndex >= cubit.state.songs.length) return;
    final song = cubit.state.songs[currentPageIndex];
    final expectedCode = song.code;
    final expectedNumber = song.number;
    final chords = await cubit.loadChordData(song);
    if (!mounted) return;
    // Discard result if the user navigated to a different song while loading.
    if (currentPageIndex >= cubit.state.songs.length) return;
    final current = cubit.state.songs[currentPageIndex];
    if (current.code != expectedCode || current.number != expectedNumber) return;
    setState(() {
      _currentChords = chords;
    });
  }

  Future<void> _loadPdfForCurrentSong() async {
    if (currentPageIndex >= cubit.state.songs.length) return;
    final song = cubit.state.songs[currentPageIndex];
    final expectedCode = song.code;
    final expectedNumber = song.number;
    final pdfPath = await cubit.getPdfPath(song.code ?? '', song.number ?? '');
    if (!mounted) return;
    // Discard result if the user navigated to a different song while loading.
    if (currentPageIndex >= cubit.state.songs.length) return;
    final current = cubit.state.songs[currentPageIndex];
    if (current.code != expectedCode || current.number != expectedNumber) return;
    setState(() {
      _currentPdfPath = pdfPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SongCubit, SongState>(
      listenWhen: (previous, current) =>
          previous.pageIndex != current.pageIndex ||
          previous.bookCode != current.bookCode ||
          previous.songBook != current.songBook ||
          previous.showChord != current.showChord ||
          (previous.songs.isEmpty && current.songs.isNotEmpty),
      listener: (context, state) {
        final safePageIndex = state.songs.isEmpty
            ? 0
            : state.pageIndex.clamp(0, state.songs.length - 1).toInt();
        final newBookCode = state.bookCode;
        final songsJustLoaded =
            state.songs.isNotEmpty && _currentPdfPath == null;
        // True when the actual song changed (not just showChord or other UI)
        final songChanged =
            safePageIndex != currentPageIndex || newBookCode != _currentBookCode;

        setState(() {
          currentPageIndex = safePageIndex;
          _currentVerseIndex = state.verseIndex;
          _currentBookCode = newBookCode;
          // Clear stale chord data immediately so the new song never briefly
          // shows chords that belong to the previous song.
          if (songChanged) _currentChords = null;
        });

        // Sync the PageController so the visible page matches the state.
        // This fixes the case where the controller was created before songs
        // were available and ended up stuck on page 0.
        if (songsJustLoaded &&
            pageController.hasClients &&
            pageController.page?.round() != safePageIndex) {
          pageController.jumpToPage(safePageIndex);
        }

        _loadChordData();
        // Load PDF when the song changed OR when we have never loaded a PDF
        // (e.g. songs just became available after initState ran too early).
        if (songChanged || _currentPdfPath == null) _loadPdfForCurrentSong();
      },
      builder: (context, state) {
        final textMode = state.isImageMode == true;
        final colors = Theme.of(context).colorScheme;

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
              onEditTriggered: _toggleChordEditMode,
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
              if (!textMode)
                IconButton(
                  icon: const Icon(Icons.fit_screen_rounded),
                  tooltip: 'Fit halaman',
                  onPressed: _fitPdfToPage,
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
                Positioned.fill(
                  child: SongPdfViewer(
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
                    isEditMode: _isChordEditMode,
                    onChordsChanged: (updatedChords) {
                      setState(() {
                        _currentChords = updatedChords;
                      });
                      cubit.detectAndUpdateFamilyChord(updatedChords);
                    },
                    viewerController: _pdfViewerController,
                  ),
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
                      autoNextMode: state.playlistAutoNextMode,
                      onPlayPause: () => cubit.togglePlayPause(),
                      onLoopModeCycle: cubit.cycleLoopMode,
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
    SharePlus.instance.share(ShareParams(text: text, subject: song.title));
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
                  initialValue: state.availableFonts.contains(state.defaultFont)
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
        initialSearchText: cubit.state.searchTerms,
        onSearchTermsChanged: cubit.onSearchTermsChanged,
        onChangeBookCode: (bookCode) {
          cubit.changeBookcode(bookCode);
        },
        onTapPageNumber: (pageNumber) async {
          // Find the song in the currently selected book and open it.
          final song = cubit.state.songs.firstWhereOrNull(
            (s) => s.number == pageNumber,
          );
          router.maybePop();
          if (song != null) {
            final bookCode = song.code ?? cubit.state.bookCode;
            final book = cubit.state.songBook.firstWhere(
              (book) => book.code == bookCode,
              orElse: () => SongBook(code: bookCode, songs: const []),
            );
            final index = book.songs.indexWhere(
              (item) => item.code == song.code && item.number == song.number,
            );
            if (index >= 0) {
              setState(() {
                currentPageIndex = index;
                _currentBookCode = bookCode;
                _currentChords = null;
              });
              if (pageController.hasClients) {
                pageController.jumpToPage(index);
              }
              cubit.openSong(song);
            }
          }
        },
        onOpenSong: (song) async {
          // Handle page jump directly to avoid BlocConsumer listener timing issues
          router.maybePop();
          final bookCode = song.code ?? cubit.state.bookCode;
          final book = cubit.state.songBook.firstWhere(
            (book) => book.code == bookCode,
            orElse: () => SongBook(code: bookCode, songs: const []),
          );
          final index = book.songs.indexWhere(
            (item) => item.code == song.code && item.number == song.number,
          );
          if (index >= 0) {
            setState(() {
              currentPageIndex = index;
              _currentBookCode = bookCode;
              _currentChords = null;
            });
            if (pageController.hasClients) {
              pageController.jumpToPage(index);
            }
            cubit.openSong(song);
          }
        },
        onBack: () => router.maybePop(),
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

  void _goToPreviousSong() => _animateToSongIndex(currentPageIndex - 1);

  void _goToNextSong() => _animateToSongIndex(currentPageIndex + 1);

  void _animateToSongIndex(int index) async {
    if (index < 0 || index >= cubit.state.songs.length) return;
    setState(() => currentPageIndex = index);
    await _loadPdfForCurrentSong();
    if (pageController.hasClients) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
    cubit.changePage(index, 0);
  }

  void _fitPdfToPage() => _pdfViewerController.fitToPage?.call();

  void _toggleChordEditMode() {
    setState(() {
      _isChordEditMode = !_isChordEditMode;
    });
  }
}

class _SongHeaderTitle extends StatefulWidget {
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
  final VoidCallback? onEditTriggered;

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
    this.onEditTriggered,
  });

  @override
  State<_SongHeaderTitle> createState() => _SongHeaderTitleState();
}

class _SongHeaderTitleState extends State<_SongHeaderTitle> {
  int _tapCount = 0;
  DateTime? _lastTapTime;
  static const int _requiredTaps = 10;
  static const Duration _tapWindow = Duration(milliseconds: 2000);

  void _handleTap() {
    final now = DateTime.now();

    // Reset tap count if too much time has passed
    if (_lastTapTime != null && now.difference(_lastTapTime!) > _tapWindow) {
      _tapCount = 0;
    }

    _tapCount++;
    _lastTapTime = now;

    // Check if we've reached the required tap count
    if (_tapCount >= _requiredTaps) {
      _tapCount = 0;
      _lastTapTime = null;
      widget.onEditTriggered?.call();

      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chord edit mode enabled'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: widget.canGoPrevious ? 1.0 : 0.0,
          child: IconButton(
            tooltip: 'Pujian sebelumnya',
            onPressed: widget.canGoPrevious ? widget.onPrevious : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
        ),
        Flexible(
          child: GestureDetector(
            onTap: _handleTap,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Container(
                key: ValueKey('${widget.number}-${widget.title}'),
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
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
                        if ((widget.number ?? '').isNotEmpty) widget.number,
                        widget.title,
                      ].whereType<String>().join(' - '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                    if (widget.familyChord != null)
                      Text(
                        'Family ${ChordService.formatChordForDisplay(widget.familyChord!, accidentalMode: widget.accidentalMode, baseTransposeOffset: widget.baseTransposeOffset)}${widget.pdfKey == null ? '' : ' / PDF ${widget.pdfKey}'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant.withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: widget.canGoNext ? 1.0 : 0.0,
          child: IconButton(
            tooltip: 'Pujian berikutnya',
            onPressed: widget.canGoNext ? widget.onNext : null,
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

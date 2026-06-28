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
import '../../../data/services/midi_engine_service.dart';
import '../../../domain/entity/song/song_entity.dart';
import '../../../router/router.dart';
import '../widgets/draggable_midi_controls.dart';
import '../../presentations.dart';
import '../widgets/song_pdf_viewer.dart';

const double _songTextMaxContentWidth = 920;

@RoutePage()
class SongView extends StatefulWidget {
  const SongView({super.key});

  @override
  State<SongView> createState() => _SongViewState();
}

bool shouldRenderChordForSongState(SongState state) {
  return state.bookCode != 'HYMNE' && state.showChord;
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
      // Note: PDF/chord/MIDI loading is handled by Cubit and BlocConsumer
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
    if (cubit.state.songs.isNotEmpty && cubit.state.currentPdfPath == null) {
      cubit.changePage(currentPageIndex, _currentVerseIndex);
    }
    // Chords are now managed by cubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openSongSelector();
    });
  }

  // _loadChordData removed, managed by SongCubit

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SongCubit, SongState>(
          listenWhen: (previous, current) =>
              previous.pageIndex != current.pageIndex ||
              previous.bookCode != current.bookCode ||
              previous.songBook != current.songBook ||
              previous.showChord != current.showChord ||
              previous.currentPdfPath != current.currentPdfPath ||
              (previous.songs.isEmpty && current.songs.isNotEmpty),
          listener: (context, state) {
            final safePageIndex = state.songs.isEmpty
                ? 0
                : state.pageIndex.clamp(0, state.songs.length - 1).toInt();
            final newBookCode = state.bookCode;
            final songsJustLoaded =
                state.songs.isNotEmpty && state.currentPdfPath == null;
            // True when the actual song changed
            final songChanged =
                safePageIndex != currentPageIndex ||
                newBookCode != _currentBookCode;

            setState(() {
              currentPageIndex = safePageIndex;
              _currentVerseIndex = state.verseIndex;
              _currentBookCode = newBookCode;
              if (newBookCode == 'HYMNE' && _isChordEditMode) {
                _isChordEditMode = false;
              }
            });

            // Sync the PageController so the visible page matches the state.
            if ((songsJustLoaded || songChanged) && pageController.hasClients) {
              if (pageController.page?.round() != safePageIndex) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (pageController.hasClients &&
                      pageController.page?.round() != safePageIndex) {
                    pageController.jumpToPage(safePageIndex);
                  }
                });
              }
            }
          },
        ),
      ],
      child: BlocBuilder<SongCubit, SongState>(
        buildWhen: (previous, current) =>
            previous.isImageMode != current.isImageMode ||
            previous.bookCode != current.bookCode ||
            previous.showAudio != current.showAudio,
        builder: (context, state) {
          final textMode = state.isImageMode == true;
          final colors = Theme.of(context).colorScheme;
          final chordToggleEnabled = state.bookCode != 'HYMNE';

          return Scaffold(
            backgroundColor: colors.surface,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: colors.surface.withValues(alpha: 0.88),
              foregroundColor: colors.onSurface,
              surfaceTintColor: Colors.transparent,
              toolbarHeight: 64,
              leading: IconButton(
                icon: const Icon(Icons.menu_outlined),
                tooltip: 'Menu',
                onPressed: openDashboardDrawer,
              ),
              title: BlocBuilder<SongCubit, SongState>(
                buildWhen: (prev, curr) =>
                    prev.pageIndex != curr.pageIndex ||
                    prev.bookCode != curr.bookCode ||
                    prev.songs != curr.songs ||
                    prev.originalFamilyChord != curr.originalFamilyChord ||
                    prev.originalPdfKey != curr.originalPdfKey ||
                    prev.chordAccidentalMode != curr.chordAccidentalMode ||
                    prev.baseTransposeOffset != curr.baseTransposeOffset,
                builder: (context, state) => _SongHeaderTitle(
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
                  onTapTitle: _openSongSelector,
                  onEditTriggered: _toggleChordEditMode,
                ),
              ),
              actions: [
                BlocBuilder<SongCubit, SongState>(
                  buildWhen: (prev, curr) => prev.showAudio != curr.showAudio,
                  builder: (context, state) => IconButton(
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
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'copy':
                        _copyCurrentVerse(cubit.state);
                        break;
                      case 'share':
                        _shareCurrentSong(cubit.state);
                        break;
                      case 'notes':
                        router.push(SongNotesListRoute(cubit: context.read()));
                        break;
                      case 'toggleChord':
                        if (chordToggleEnabled) {
                          cubit.toggleChord();
                        }
                        break;
                      case 'fit':
                        _fitPdfToPage();
                        break;
                      case 'lyrics':
                        _openLyricsSettings();
                        break;
                      case 'twoPage':
                        cubit.setPdfTwoPageMode(!state.pdfTwoPageMode);
                        break;
                      case 'verticalScroll':
                        cubit.setPdfVerticalScrolling(
                          !state.pdfVerticalScrolling,
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (chordToggleEnabled)
                      PopupMenuItem(
                        value: 'toggleChord',
                        child: Text(
                          state.showChord
                              ? 'Sembunyikan chord'
                              : 'Tampilkan chord',
                        ),
                      ),
                    if (!textMode) ...[
                      const PopupMenuItem(
                        value: 'fit',
                        child: Text('Fit halaman'),
                      ),
                      PopupMenuItem(
                        value: 'twoPage',
                        child: Text(
                          state.pdfTwoPageMode
                              ? 'Mode satu halaman'
                              : 'Mode dua halaman',
                        ),
                      ),
                      PopupMenuItem(
                        value: 'verticalScroll',
                        child: Text(
                          state.pdfVerticalScrolling
                              ? 'Scroll horizontal'
                              : 'Scroll vertikal',
                        ),
                      ),
                    ],
                    if (textMode)
                      const PopupMenuItem(
                        value: 'lyrics',
                        child: Text('Pengaturan lirik'),
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
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.surfaceContainerHighest.withValues(
                            alpha: 0.22,
                          ),
                          colors.surfaceContainerLow.withValues(alpha: 0.4),
                          colors.surface,
                        ],
                      ),
                    ),
                  ),
                ),
                // Text mode layer
                if (textMode)
                  BlocBuilder<SongCubit, SongState>(
                    buildWhen: (prev, curr) =>
                        prev.pageIndex != curr.pageIndex ||
                        prev.bookCode != curr.bookCode ||
                        prev.defaultFont != curr.defaultFont ||
                        prev.defaultTextScale != curr.defaultTextScale ||
                        prev.defaultTextHeight != curr.defaultTextHeight ||
                        prev.lyricsTextAlign != curr.lyricsTextAlign ||
                        prev.lyricsVerticalAlign != curr.lyricsVerticalAlign ||
                        prev.songs != curr.songs,
                    builder: (context, state) => RepaintBoundary(
                      child: PageView.builder(
                        controller: pageController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: state.songs.length,
                        itemBuilder: (context, index) {
                          final song = state.songs[index];
                          return RepaintBoundary(
                            child: _SongTextPage(
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
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Separate PDF Viewer layer
                if (!textMode)
                  BlocBuilder<SongCubit, SongState>(
                    buildWhen: (prev, curr) =>
                        prev.currentPdfPath != curr.currentPdfPath ||
                        prev.showChord != curr.showChord ||
                        prev.currentChords != curr.currentChords ||
                        prev.transposeStep != curr.transposeStep ||
                        prev.baseTransposeOffset != curr.baseTransposeOffset ||
                        prev.pdfTwoPageMode != curr.pdfTwoPageMode ||
                        prev.pdfVerticalScrolling !=
                            curr.pdfVerticalScrolling ||
                        prev.chordFontSizePercent !=
                            curr.chordFontSizePercent ||
                        prev.chordFillOpacityPercent !=
                            curr.chordFillOpacityPercent ||
                        prev.chordPaddingPercent != curr.chordPaddingPercent,
                    builder: (context, state) {
                      if (state.currentPdfPath == null) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox.expand(
                          child: RepaintBoundary(
                            child: SongPdfViewer(
                              key: const ValueKey('pdf_viewer_instance'),
                              pdfPath: state.currentPdfPath,
                              showChord: shouldRenderChordForSongState(state),
                              chords: state.currentChords,
                              transposeStep: state.transposeStep,
                              baseTransposeOffset: state.baseTransposeOffset,
                              chordAccidentalMode: state.chordAccidentalMode,
                              twoPageMode: state.pdfTwoPageMode,
                              verticalScrolling: state.pdfVerticalScrolling,
                              chordFontSizePercent: state.chordFontSizePercent,
                              chordFillOpacityPercent:
                                  state.chordFillOpacityPercent,
                              chordPaddingPercent: state.chordPaddingPercent,
                              isEditMode: chordToggleEnabled && _isChordEditMode,
                              onChordsChanged: (updatedChords) {
                                cubit.detectAndUpdateFamilyChord(updatedChords);
                              },
                              viewerController: _pdfViewerController,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // PDF/audio loading indicators
                BlocBuilder<SongCubit, SongState>(
                  buildWhen: (prev, curr) =>
                      prev.isAudioLoading != curr.isAudioLoading ||
                      prev.isPdfLoading != curr.isPdfLoading,
                  builder: (context, state) {
                    if (!state.isAudioLoading && !state.isPdfLoading) {
                      return const SizedBox.shrink();
                    }

                    return Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.isPdfLoading)
                            Container(
                              width: double.infinity,
                              color: colors.primaryContainer.withValues(
                                alpha: 0.88,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Text(
                                'Preparing local PDF for offline access...',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colors.onPrimaryContainer,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          if (state.isPdfLoading)
                            LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colors.primary,
                              ),
                            ),
                          if (state.isAudioLoading)
                            LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colors.secondary.withValues(alpha: 0.5),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                if (state.showAudio)
                  BlocBuilder<SongCubit, SongState>(
                    buildWhen: (prev, curr) =>
                        prev.isAudioPlaying != curr.isAudioPlaying ||
                        prev.isAudioLoading != curr.isAudioLoading ||
                        prev.transposeStep != curr.transposeStep ||
                        prev.tempoBpm != curr.tempoBpm ||
                        prev.playlistAutoNextMode != curr.playlistAutoNextMode,
                    builder: (context, midiState) {
                      return StreamBuilder<MidiPlaybackState>(
                        stream: cubit.midiEngine.stateStream,
                        initialData: const MidiPlaybackState(),
                        builder: (context, snapshot) {
                          final ms = snapshot.data ?? const MidiPlaybackState();
                          return DraggableMidiControls(
                            key: const ValueKey('midi_overlay'),
                            isPlaying: midiState.isAudioPlaying || ms.isPlaying,
                            isLoading: midiState.isAudioLoading || ms.isLoading,
                            position: ms.position,
                            duration: ms.duration,
                            transposeStep: midiState.transposeStep,
                            currentKey: midiState.activeKeyLabel,
                            availableKeys: midiState.transposeKeyOptions,
                            tempoBpm: midiState.tempoBpm,
                            autoNextMode: midiState.playlistAutoNextMode,
                            onPlayPause: () => cubit.togglePlayPause(),
                            onLoopModeCycle: () => cubit.cycleLoopMode(),
                            onSeek: (v) => cubit.seek(
                              Duration(milliseconds: (v * 1000).round()),
                            ),
                            onTranspose: (v) => cubit.setTranspose(v),
                            onKeySelected: (v) => cubit.setTransposeKey(v),
                            onTempo: (v) => cubit.setTempo(v),
                            onPreviousSong: _goToPreviousSong,
                            onNextSong: _goToNextSong,
                            showChord: midiState.showChord,
                            chordToggleEnabled: midiState.bookCode != 'HYMNE',
                            onToggleChord: () => cubit.toggleChord(),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
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
          buildWhen: (prev, curr) =>
              prev.defaultFont != curr.defaultFont ||
              prev.defaultTextScale != curr.defaultTextScale ||
              prev.defaultTextHeight != curr.defaultTextHeight ||
              prev.lyricsTextAlign != curr.lyricsTextAlign ||
              prev.lyricsVerticalAlign != curr.lyricsVerticalAlign ||
              prev.availableFonts != curr.availableFonts,
          builder: (context, state) {
            final colors = Theme.of(context).colorScheme;
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primaryContainer.withValues(alpha: 0.55),
                        colors.surfaceContainerHighest,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.65),
                    ),
                  ),
                  child: Text(
                    'Pengaturan lirik',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
    if (cubit.state.bookCode == 'HYMNE') return;
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
  final VoidCallback onTapTitle;
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
    required this.onTapTitle,
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
  double _screenWidth = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenWidth = MediaQuery.sizeOf(context).width;
  }

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
    final screenWidth = _screenWidth;
    final compact = screenWidth < 430;
    final titleMaxWidth = screenWidth < 420
        ? screenWidth * 0.42
        : screenWidth < 600
        ? screenWidth * 0.52
        : (screenWidth * 0.58).clamp(260, 520).toDouble();
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.canGoPrevious)
          IconButton(
            visualDensity: compact ? VisualDensity.compact : null,
            tooltip: 'Pujian sebelumnya',
            onPressed: widget.onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
        Flexible(
          child: GestureDetector(
            onTap: widget.onTapTitle,
            onLongPress: _handleTap,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Container(
                key: ValueKey('${widget.number}-${widget.title}'),
                constraints: BoxConstraints(maxWidth: titleMaxWidth),
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 12,
                  vertical: compact ? 7 : 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.surfaceContainerHighest.withValues(alpha: 0.7),
                      colors.surfaceContainerLow.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.56),
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
                        fontSize: 15,
                      ),
                    ),
                    if (widget.familyChord != null)
                      Text(
                        'Family ${ChordService.formatChordForDisplay(widget.familyChord!, accidentalMode: widget.accidentalMode, baseTransposeOffset: widget.baseTransposeOffset)}${widget.pdfKey == null ? '' : ' / PDF ${widget.pdfKey}'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
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
        if (widget.canGoNext)
          IconButton(
            visualDensity: compact ? VisualDensity.compact : null,
            tooltip: 'Pujian berikutnya',
            onPressed: widget.onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
      ],
    );
  }
}

class _SongTextPage extends StatefulWidget {
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

  @override
  State<_SongTextPage> createState() => _SongTextPageState();
}

class _SongTextPageState extends State<_SongTextPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _verseAnimCtrl;
  late final Animation<double> _verseFadeAnim;
  late final Animation<Offset> _verseSlideAnim;

  @override
  void initState() {
    super.initState();
    _verseAnimCtrl = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    );
    _verseFadeAnim = CurvedAnimation(
      parent: _verseAnimCtrl,
      curve: Curves.easeOut,
    );
    _verseSlideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _verseAnimCtrl,
      curve: Curves.easeOutCubic,
    ));
    _verseAnimCtrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_SongTextPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.verseIndex != widget.verseIndex) {
      _verseAnimCtrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _verseAnimCtrl.dispose();
    super.dispose();
  }

  TextAlign _resolveTextAlign() {
    switch (widget.textAlign) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  MainAxisAlignment _resolveVerticalAlign() {
    switch (widget.verticalAlign) {
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
    final verses = widget.song.verses;
    final hasVerses = verses.isNotEmpty;
    final safeIndex =
        hasVerses ? widget.verseIndex.clamp(0, verses.length - 1) : 0;
    final currentVerse = hasVerses ? verses[safeIndex] : null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -160) {
          widget.onNextVerse?.call();
        } else if (velocity > 160) {
          widget.onPreviousVerse?.call();
        }
      },
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -160) {
          widget.onNextVerse?.call();
        } else if (velocity > 160) {
          widget.onPreviousVerse?.call();
        }
      },
      child: SelectionArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 420;
                  final horizontalPadding = compact ? 14.0 : 20.0;
                  final cardMaxWidth = constraints.maxWidth > 980
                      ? _songTextMaxContentWidth
                      : constraints.maxWidth;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      20,
                      horizontalPadding,
                      8,
                    ),
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
                          Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: cardMaxWidth,
                              ),
                              child: Container(
                                padding: EdgeInsets.fromLTRB(
                                  compact ? 14 : 18,
                                  compact ? 12 : 14,
                                  compact ? 14 : 18,
                                  compact ? 14 : 18,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      theme.colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.58),
                                      theme.colorScheme.surfaceContainerLow
                                          .withValues(alpha: 0.82),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    compact ? 14 : 18,
                                  ),
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: hasVerses
                                    ? FadeTransition(
                                        opacity: _verseFadeAnim,
                                        child: SlideTransition(
                                          position: _verseSlideAnim,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                'Bait ${safeIndex + 1} dari ${verses.length}',
                                                textAlign: _resolveTextAlign(),
                                                style: theme
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .primary
                                                          .withValues(
                                                              alpha: 0.6),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                currentVerse!,
                                                textAlign: _resolveTextAlign(),
                                                style: theme
                                                    .textTheme.bodyLarge
                                                    ?.copyWith(
                                                      fontFamily:
                                                          widget.fontFamily,
                                                      fontSize:
                                                          16 * widget.textScale,
                                                      height: widget.textHeight,
                                                      fontWeight: widget
                                                              .fontBold
                                                          ? FontWeight.w700
                                                          : FontWeight.w400,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Teks lagu belum tersedia.',
                                        textAlign: _resolveTextAlign(),
                                        style: theme.textTheme.bodyMedium,
                                      ),
                              ),
                            ),
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
                      onPressed:
                          safeIndex > 0 ? widget.onPreviousVerse : null,
                      icon: const Icon(Icons.keyboard_arrow_up, size: 20),
                      label: const Text('Atas'),
                    ),
                    Text(
                      '${safeIndex + 1}/${verses.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: safeIndex < verses.length - 1
                          ? widget.onNextVerse
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
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.65),
                  ),
                  selectedColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.65),
                  showCheckmark: false,
                  onSelected: (_) => onSelected(entry.key),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

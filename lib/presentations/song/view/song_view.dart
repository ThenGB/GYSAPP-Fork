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
import '../widgets/midi_engine_webview.dart';
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

  void pageListener() {
    final newIndex = pageController.page?.round() ?? currentPageIndex;
    if (newIndex != currentPageIndex) {
      setState(() {
        currentPageIndex = newIndex;
      });
      cubit.changePage(newIndex, 0);
      _loadChordData();
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongCubit, SongState>(
      builder: (context, state) {
        final showHeaderTransport =
            state.showAudio && MediaQuery.sizeOf(context).width >= 760;
        final textMode = state.isImageMode == true;
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.list_alt_rounded),
              tooltip: 'Selector nomor pujian',
              onPressed: _openSongSelector,
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.getSongTitleAt(currentPageIndex),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (state.originalFamilyChord != null)
                  Text(
                    'Family ${ChordService.normalizeChord(
                      state.originalFamilyChord!,
                      accidentalMode: state.chordAccidentalMode,
                    )}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withValues(alpha: 0.72),
                    ),
                  ),
              ],
            ),
            actions: [
              if (showHeaderTransport)
                AnimatedBuilder(
                  animation: cubit.midiEngine,
                  builder: (context, child) {
                    final midiState = cubit.midiEngine.state;
                    return _HeaderMidiControls(
                      isPlaying: midiState.isPlaying,
                      isLoading: midiState.isLoading,
                      position: midiState.position,
                      duration: midiState.duration,
                      onPlayPause: () => cubit.togglePlayPause(),
                      onStop: () => cubit.stop(),
                      onSeek: (seconds) =>
                          cubit.seek(Duration(seconds: seconds.round())),
                    );
                  },
                ),
              // Audio toggle
              IconButton(
                icon: Icon(
                  state.showAudio ? Icons.volume_up : Icons.volume_off,
                  color: state.showAudio
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).disabledColor,
                ),
                onPressed: () => cubit.toggleAudio(),
              ),
              // Chord toggle
              IconButton(
                icon: Icon(
                  state.showChord ? Icons.music_note : Icons.music_off,
                  color: state.showChord
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).disabledColor,
                ),
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
              // More options
              PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 'fav':
                      if (currentPageIndex < state.songs.length) {
                        cubit.modifyFavorite(state.songs[currentPageIndex],
                            playOnlyFav: false);
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
                          cubit.isSongFavorite(state.songs[currentPageIndex])
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'copy',
                    child: Text('Copy'.tr()),
                  ),
                  PopupMenuItem(
                    value: 'share',
                    child: Text('Share'.tr()),
                  ),
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
                      textScale: state.defaultTextScale,
                      textHeight: state.defaultTextHeight,
                      fontBold: state.fontBold,
                    );
                  }
                  return FutureBuilder<String?>(
                    future:
                        cubit.getPdfPath(song.code ?? '', song.number ?? ''),
                    builder: (context, snapshot) {
                      final pdfPath = snapshot.data;
                      if (pdfPath == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return SongPdfViewer(
                        pdfPath: pdfPath,
                        showChord: state.showChord,
                        chords: _currentChords,
                        transposeStep: state.transposeStep,
                        chordAccidentalMode: state.chordAccidentalMode,
                      );
                    },
                  );
                },
              ),

              // Hidden MIDI Engine WebView
              MidiEngineWebView(
                service: cubit.midiEngine,
              ),

              // Draggable MIDI Controls
              if (state.showAudio && !showHeaderTransport)
                AnimatedBuilder(
                  animation: cubit.midiEngine,
                  builder: (context, child) {
                    final midiState = cubit.midiEngine.state;
                    return DraggableMidiControls(
                      isPlaying: midiState.isPlaying,
                      isLoading: midiState.isLoading,
                      position: midiState.position,
                      duration: midiState.duration,
                      transposeStep: state.transposeStep,
                      tempoBpm: state.tempoBpm,
                      onPlayPause: () => cubit.togglePlayPause(),
                      onStop: () => cubit.stop(),
                      onSeek: (seconds) =>
                          cubit.seek(Duration(seconds: seconds.toInt())),
                      onTranspose: (semitones) => cubit.setTranspose(semitones),
                      onTempo: (bpm) => cubit.setTempo(bpm),
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

  void _jumpToSongIndex(int index) {
    if (index < 0 || index >= cubit.state.songs.length) return;
    setState(() {
      currentPageIndex = index;
    });
    cubit.changePage(index, 0);
    _loadChordData();
    if (!pageController.hasClients) return;
    pageController.jumpToPage(index);
  }
}

class _HeaderMidiControls extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final double position;
  final double duration;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final ValueChanged<double> onSeek;

  const _HeaderMidiControls({
    required this.isPlaying,
    required this.isLoading,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onStop,
    required this.onSeek,
  });

  String _formatTime(double seconds) {
    final minute = seconds ~/ 60;
    final second = (seconds % 60).toInt();
    return '$minute:${second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 300,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Stop',
            visualDensity: VisualDensity.compact,
            onPressed: onStop,
            icon: const Icon(Icons.stop_rounded),
          ),
          IconButton(
            tooltip: isPlaying ? 'Pause' : 'Play',
            visualDensity: VisualDensity.compact,
            onPressed: isLoading ? null : onPlayPause,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow),
          ),
          Text(_formatTime(position), style: theme.textTheme.bodySmall),
          Expanded(
            child: Slider(
              value: duration > 0 ? position.clamp(0, duration) : 0,
              max: duration > 0 ? duration : 1,
              onChanged: duration > 0 ? onSeek : null,
            ),
          ),
          SizedBox(
            width: 38,
            child: Text(
              _formatTime(duration),
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _SongTextPage extends StatelessWidget {
  final Song song;
  final double textScale;
  final double textHeight;
  final bool fontBold;

  const _SongTextPage({
    required this.song,
    required this.textScale,
    required this.textHeight,
    required this.fontBold,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verses = song.verses;
    return SelectionArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          32 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Text(
            '${song.number ?? ''} - ${song.title ?? ''}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          if (verses.isEmpty)
            Text(
              'Teks lagu belum tersedia.',
              style: theme.textTheme.bodyMedium,
            )
          else
            ...verses.indexed.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Text(
                  entry.$2,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16 * textScale,
                    height: textHeight,
                    fontWeight: fontBold ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../data/services/chord_service.dart';
import '../../../data/services/local_asset_service.dart';
import '../../../data/services/midi_engine_service.dart';
import '../../../domain/entity/song/song_entity.dart';
import '../../../domain/entity/song_history/song_history.dart';
import '../../../domain/entity/song_note/song_note.dart';
import '../../../domain/repository/song_repository.dart';
import 'song_state.dart';

export 'song_state.dart';

class SongCubit extends HydratedCubit<SongState> {
  final SongRepository songRepository;
  final LocalAssetService _assetService;
  final MidiEngineService _midiEngine;

  MidiEngineService get midiEngine => _midiEngine;

  bool get isSelectingSong => state.selectedSong != null;

  StreamSubscription<MidiPlaybackState>? _midiStateSub;
  Timer? _debouncer;

  SongCubit(
    this.songRepository,
    this._assetService,
    this._midiEngine,
  ) : super(const SongState()) {
    _setupMidiStreams();
    getData().then((_) {
      _midiEngine.initialize();
      _preloadCurrentSongMidi();
    });
  }

  void _setupMidiStreams() {
    _midiStateSub = _midiEngine.stateStream.listen((midiState) {
      // Convert MidiPlaybackState to relevant SongState updates
      if (midiState.isPlaying != state.isAudioPlaying) {
        emit(state.copyWith(isAudioPlaying: midiState.isPlaying));
      }
      if (midiState.isLoading != state.isAudioLoading) {
        emit(state.copyWith(isAudioLoading: midiState.isLoading));
      }
    });
  }

  Future<void> getData() async {
    final response = await songRepository.getData();
    response.fold(
      (failure) {
        Fluttertoast.cancel();
        Fluttertoast.showToast(msg: failure.message);
      },
      (res) {
        emit(state.copyWith(songBook: res));
      },
    );
  }

  // ─── MIDI Playback ────────────────────────────────────────────

  Future<void> _preloadCurrentSongMidi() async {
    if (state.songs.isEmpty) return;
    final song = state.songs[state.pageIndex];
    await _loadMidiForSong(song);
  }

  Future<void> _loadMidiForSong(Song song) async {
    if (!state.showAudio) return;

    final midiPath =
        await _assetService.getMidiPath(song.code ?? '', song.number ?? '');
    if (midiPath == null) {
      emit(state.copyWith(
        isAudioLoading: false,
        showAudio: false,
      ));
      return;
    }

    emit(state.copyWith(isAudioLoading: true));
    await _midiEngine.loadMidi(
      midiPath,
      transpose: state.transposeStep,
      instrument: state.midiInstrument,
      autoplay: false,
    );
    emit(state.copyWith(isAudioLoading: false));
  }

  void play() {
    if (state.showAudio) {
      _midiEngine.play();
      emit(state.copyWith(isAudioPlaying: true));
    }
  }

  void pause() {
    _midiEngine.pause();
    emit(state.copyWith(isAudioPlaying: false));
  }

  void stop() {
    _midiEngine.stop();
    emit(state.copyWith(isAudioPlaying: false));
  }

  void seek(Duration position) {
    _midiEngine.seek(position.inSeconds.toDouble());
  }

  void togglePlayPause() {
    if (state.isAudioPlaying) {
      pause();
    } else {
      play();
    }
  }

  // ─── Audio Toggle ─────────────────────────────────────────────

  void toggleAudio([bool? show]) {
    final newValue = show ?? !state.showAudio;
    emit(state.copyWith(showAudio: newValue));

    if (newValue) {
      _loadMidiForSong(state.songs[state.pageIndex]);
    } else {
      _midiEngine.stop();
    }
  }

  // ─── Chord Toggle ─────────────────────────────────────────────

  void toggleChord([bool? show]) {
    emit(state.copyWith(showChord: show ?? !state.showChord));
  }

  // ─── Transpose ────────────────────────────────────────────────

  void setTranspose(int semitones) {
    emit(state.copyWith(transposeStep: semitones));
    _midiEngine.setTranspose(semitones);
  }

  void transposeUp() {
    setTranspose((state.transposeStep + 1).clamp(-12, 12));
  }

  void transposeDown() {
    setTranspose((state.transposeStep - 1).clamp(-12, 12));
  }

  // ─── Tempo ────────────────────────────────────────────────────

  void setTempo(double bpm) {
    emit(state.copyWith(tempoBpm: bpm));
    _midiEngine.setTempo(bpm);
  }

  // ─── Instrument ───────────────────────────────────────────────

  void setMidiInstrument(int program) {
    emit(state.copyWith(midiInstrument: program));
    _midiEngine.setInstrument(program);
  }

  // ─── SoundFont ────────────────────────────────────────────────

  Future<void> setSoundFont(String fileName) async {
    emit(state.copyWith(soundFont: fileName));
    // SoundFont change requires engine reload
    await _midiEngine.initialize();
    if (state.songs.isNotEmpty) {
      await _loadMidiForSong(state.songs[state.pageIndex]);
    }
  }

  // ─── Page Navigation ──────────────────────────────────────────

  Future<void> changePage(int index, int verseIndex) async {
    _midiEngine.stop();
    emit(state.copyWith(
      pageIndex: index,
      verseIndex: verseIndex,
      isAudioPlaying: false,
    ));
    if (state.showAudio) {
      await _loadMidiForSong(state.songs[index]);
    }
  }

  // ─── Chord Data Loading ───────────────────────────────────────

  Future<Map<int, List<ChordData>>?> loadChordData(Song song) async {
    if (song.code != 'KR') return null;

    final chordPath =
        await _assetService.getChordPath(song.code ?? '', song.number ?? '');
    if (chordPath == null) return null;

    try {
      final jsonString = await rootBundle.loadString(chordPath);
      return ChordService.parseChordJson(jsonString);
    } catch (e) {
      log('Error loading chord data: $e');
      return null;
    }
  }

  // ─── Book Code ────────────────────────────────────────────────

  void changeBookcode(String bookCode, {bool isFavorite = false}) {
    List<Song> songs = [];
    for (var book in state.favoriteSongBook) {
      songs.addAll(book.songs);
    }
    emit(
      state.copyWith(
        bookCode: bookCode,
        playOnlyFavorite: isFavorite,
        shuffleIndex: getRandomUniqueIndex(songs.length),
      ),
    );
  }

  // ─── Favorites ────────────────────────────────────────────────

  void modifyFavorite(Song song, {bool playOnlyFav = true}) {
    List<SongBook> modifiedSongBook = [];
    if (state.favoriteSongBook.isEmpty) {
      modifiedSongBook =
          state.songBook.map((e) => e.copyWith(songs: [])).toList();
    } else {
      modifiedSongBook = List.from(state.favoriteSongBook);
    }
    modifiedSongBook = modifiedSongBook.map((e) {
      var temp = e;
      if (temp.code == song.code) {
        List<Song> tempSongs = List.from(e.songs);
        if (tempSongs.any((element) => element.number == song.number)) {
          tempSongs.removeWhere((element) => element.number == song.number);
        } else {
          tempSongs.add(song);
        }
        temp = temp.copyWith(songs: tempSongs);
      }
      return temp;
    }).toList();
    final hasFavoriteSongs = modifiedSongBook.any((sb) => sb.songs.isNotEmpty);
    emit(state.copyWith(
        favoriteSongBook: modifiedSongBook,
        playOnlyFavorite: playOnlyFav && hasFavoriteSongs));
  }

  bool isSongFavorite(Song? song) {
    if (song == null) return false;
    if (state.favoriteSongBook.map((e) => e.code).contains(song.code)) {
      SongBook songBook = state.favoriteSongBook
          .firstWhere((element) => element.code == song.code);
      return songBook.songs.map((e) => e.number).contains(song.number);
    } else {
      return false;
    }
  }

  // ─── History ──────────────────────────────────────────────────

  void deleteHistory(SongHistory history) {
    emit(state.copyWith(
        histories: List<SongHistory>.from(state.histories)..remove(history)));
  }

  void addToHistory(SongHistory item) {
    List<SongHistory> data = List.from(state.histories);
    if (data.length >= 20) {
      data = List<SongHistory>.from(data).sublist(1, 20);
    }
    data.add(item);
    emit(state.copyWith(histories: data));
  }

  // ─── Notes ────────────────────────────────────────────────────

  void changeSortNote(String sortBy) {
    emit(state.copyWith(sortNotesBy: sortBy));
  }

  void saveNote(SongNote data) {
    var notes = List<SongNote>.from(state.notes);
    int index = notes.indexWhere((note) => note.id == data.id);
    if (index != -1) {
      notes[index] = data;
    } else {
      notes.add(data);
    }
    emit(state.copyWith(notes: notes));
  }

  Future<void> deleteNote(SongNote data) async {
    var notes = List<SongNote>.from(state.notes);
    notes.remove(data);
    emit(state.copyWith(notes: notes));
  }

  // ─── Selection ────────────────────────────────────────────────

  Future<void> removeSelection() async {
    emit(state.copyWith(selectedSong: null));
  }

  void selectSong(Song song) {
    emit(state.copyWith(selectedSong: song));
  }

  // ─── Search ───────────────────────────────────────────────────

  void onSearchTermsChanged(String text) {
    emit(state.copyWith(searchTerms: text));
  }

  // ─── Shuffle ──────────────────────────────────────────────────

  Future<void> toggleShuffle() async {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
        msg: 'Shuffle mode ${state.shuffleMode ? 'disabled' : 'enabled'}');
    emit(state.copyWith(shuffleMode: !state.shuffleMode));
  }

  // ─── Font & Text ──────────────────────────────────────────────

  void changeFont(String font) {
    emit(state.copyWith(defaultFont: font));
  }

  void changeTextScale(double value) {
    emit(state.copyWith(defaultTextScale: value));
  }

  void changeTextHeight(double value) {
    emit(state.copyWith(defaultTextHeight: value));
  }

  // ─── Mode ─────────────────────────────────────────────────────

  void changeMode() {
    emit(state.copyWith(isImageMode: !state.isImageMode));
  }

  // ─── HydratedBloc Overrides ───────────────────────────────────

  @override
  SongState? fromJson(Map<String, dynamic> json) {
    return SongState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(SongState state) {
    return state
        .copyWith(isAudioLoading: false, isLoading: false, selectedSong: null)
        .toJson();
  }

  Future<String?> getPdfPath(String bookCode, String number) async {
    return _assetService.getPdfPath(bookCode, number);
  }

  void sync(SongState songState) {
    emit(songState);
  }

  @override
  Future<void> close() {
    _midiStateSub?.cancel();
    _debouncer?.cancel();
    _midiEngine.disposeEngine();
    return super.close();
  }
}

List<int> getRandomUniqueIndex(int length) {
  math.Random random = math.Random();
  List<int> indices = List.generate(length, (index) => index);
  for (int i = length - 1; i > 0; i--) {
    int randomIndex = random.nextInt(i + 1);
    int temp = indices[randomIndex];
    indices[randomIndex] = indices[i];
    indices[i] = temp;
  }
  return indices;
}

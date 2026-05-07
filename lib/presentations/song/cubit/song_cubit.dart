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
    _preloadNearbySongMidi(state.pageIndex);
  }

  Future<String?> _midiPathForSong(Song song) {
    return _assetService.getMidiPath(song.code ?? '', song.number ?? '');
  }

  Future<void> _loadMidiForSong(Song song, {bool autoplay = false}) async {
    if (!state.showAudio) return;

    final midiPath = await _midiPathForSong(song);
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
      tempoBpm: state.tempoBpm,
      instrument: state.midiInstrument,
      autoplay: autoplay,
    );
    emit(state.copyWith(isAudioLoading: false));
  }

  void _preloadNearbySongMidi(int index) {
    if (!state.showAudio) return;
    for (final nearbyIndex in [index - 1, index + 1]) {
      if (nearbyIndex < 0 || nearbyIndex >= state.songs.length) continue;
      _midiPathForSong(state.songs[nearbyIndex]).then((midiPath) {
        if (midiPath == null) return;
        _midiEngine.preload(
          midiPath,
          transpose: state.transposeStep,
          instrument: state.midiInstrument,
        );
      });
    }
  }

  Future<void> play() async {
    if (!state.showAudio) {
      emit(state.copyWith(showAudio: true));
    }
    if (state.songs.isNotEmpty) {
      final song = state.songs[state.pageIndex];
      final midiPath = await _midiPathForSong(song);
      if (midiPath == null) {
        emit(state.copyWith(showAudio: false, isAudioLoading: false));
        return;
      }
      if (!_midiEngine.isCurrentSong(midiPath)) {
        await _loadMidiForSong(song);
      }
    }
    await _midiEngine.play();
    emit(state.copyWith(isAudioPlaying: true));
  }

  Future<void> pause() async {
    await _midiEngine.pause();
    emit(state.copyWith(isAudioPlaying: false));
  }

  Future<void> stop() async {
    await _midiEngine.stop();
    emit(state.copyWith(isAudioPlaying: false));
  }

  Future<void> seek(Duration position) async {
    await _midiEngine.seek(position.inMilliseconds / 1000);
  }

  Future<void> togglePlayPause() async {
    if (state.isAudioPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  // ─── Audio Toggle ─────────────────────────────────────────────

  void toggleAudio([bool? show]) {
    final newValue = show ?? !state.showAudio;
    emit(state.copyWith(showAudio: newValue));

    if (newValue && state.songs.isNotEmpty) {
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

  void setChordAccidentalMode(String mode) {
    final normalized = mode == ChordService.accidentalFlat
        ? ChordService.accidentalFlat
        : ChordService.accidentalSharp;
    emit(state.copyWith(chordAccidentalMode: normalized));
  }

  void togglePreferNaturalChords([bool? value]) {
    final preferNatural = value ?? !state.preferNaturalChords;
    final recommendedTranspose = preferNatural
        ? ChordService.recommendedNaturalTranspose(
            state.originalFamilyChord,
            baseTransposeOffset: state.baseTransposeOffset,
          )
        : 0;
    emit(state.copyWith(
      preferNaturalChords: preferNatural,
      transposeStep: recommendedTranspose,
    ));
    _midiEngine.setTranspose(recommendedTranspose);
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
    _preloadNearbySongMidi(state.pageIndex);
  }

  void setDefaultTempo(double bpm) {
    emit(state.copyWith(defaultTempoBpm: bpm, tempoBpm: bpm));
    _midiEngine.setTempo(bpm);
  }

  // ─── Instrument ───────────────────────────────────────────────

  void setMidiInstrument(int? program) {
    emit(state.copyWith(midiInstrument: program));
    _midiEngine.setInstrument(program ?? -1);
    _preloadNearbySongMidi(state.pageIndex);
  }

  void resetPlaybackSettings() {
    emit(state.copyWith(
      showAudio: false,
      showChord: false,
      transposeStep: 0,
      originalFamilyChord: null,
      originalPdfKey: null,
      baseTransposeOffset: 0,
      tempoBpm: 76,
      defaultTempoBpm: 76,
      midiInstrument: null,
      isAudioPlaying: false,
    ));
    _midiEngine.stop();
    _midiEngine.setTranspose(0);
    _midiEngine.setTempo(76);
    _midiEngine.setInstrument(-1);
  }

  // ─── SoundFont ────────────────────────────────────────────────

  Future<void> setSoundFont(String fileName) async {
    emit(state.copyWith(soundFont: fileName));
    await _midiEngine.changeSoundFont('../data/soundfont/$fileName');
    if (state.songs.isNotEmpty) {
      await _loadMidiForSong(state.songs[state.pageIndex]);
    }
  }

  // ─── Page Navigation ──────────────────────────────────────────

  Future<void> changePage(int index, int verseIndex) async {
    if (index < 0 || index >= state.songs.length) return;
    final wasPlaying = state.isAudioPlaying;
    emit(state.copyWith(
      pageIndex: index,
      verseIndex: verseIndex,
      isAudioPlaying: false,
      originalPdfKey: null,
      originalFamilyChord: null,
      baseTransposeOffset: 0,
    ));
    if (state.showAudio) {
      await _loadMidiForSong(
        state.songs[index],
        autoplay: wasPlaying,
      );
      _preloadNearbySongMidi(index);
    }
  }

  void setPdfTwoPageMode(bool enabled) {
    emit(state.copyWith(
      pdfTwoPageMode: enabled,
      pdfVerticalScrolling: enabled ? false : state.pdfVerticalScrolling,
    ));
  }

  void setPdfVerticalScrolling(bool enabled) {
    emit(state.copyWith(
      pdfVerticalScrolling: enabled,
      pdfTwoPageMode: enabled ? false : state.pdfTwoPageMode,
    ));
  }

  // ─── Chord Data Loading ───────────────────────────────────────

  Future<Map<int, List<ChordData>>?> loadChordData(Song song) async {
    if (song.code != 'KR') return null;

    final chordPath =
        await _assetService.getChordPath(song.code ?? '', song.number ?? '');
    if (chordPath == null) return null;

    try {
      final jsonString = await rootBundle.loadString(chordPath);
      final chords = ChordService.parseChordJson(jsonString);
      final familyChord = ChordService.detectFamilyChord(chords);

      // Invalidate old PDF key so chord display doesn't use stale offset
      // The PDF viewer will call updatePdfKey with the correct key after rendering
      final pdfKey = state.originalPdfKey;
      final baseTransposeOffset = ChordService.calculateBaseTransposeOffset(
        pdfKey: pdfKey,
        familyChord: familyChord,
      );
      final previousTranspose = state.transposeStep;
      final recommendedTranspose = state.preferNaturalChords
          ? ChordService.recommendedNaturalTranspose(
              familyChord,
              baseTransposeOffset: baseTransposeOffset,
            )
          : state.transposeStep;
      emit(state.copyWith(
        originalFamilyChord: familyChord,
        baseTransposeOffset: baseTransposeOffset,
        originalPdfKey: pdfKey, // preserve existing pdf key until updatePdfKey
        transposeStep: recommendedTranspose,
      ));
      if (recommendedTranspose != previousTranspose) {
        _midiEngine.setTranspose(recommendedTranspose);
      }
      return chords;
    } catch (e) {
      log('Error loading chord data: $e');
      return null;
    }
  }

  void updatePdfKey(String? pdfKey) {
    if (pdfKey == state.originalPdfKey) return;
    final baseTransposeOffset = ChordService.calculateBaseTransposeOffset(
      pdfKey: pdfKey,
      familyChord: state.originalFamilyChord,
    );
    if (state.preferNaturalChords && state.originalFamilyChord == null) {
      emit(state.copyWith(
        originalPdfKey: pdfKey,
        baseTransposeOffset: baseTransposeOffset,
      ));
      return;
    }
    final previousTranspose = state.transposeStep;
    final recommendedTranspose = state.preferNaturalChords
        ? ChordService.recommendedNaturalTranspose(
            state.originalFamilyChord,
            baseTransposeOffset: baseTransposeOffset,
          )
        : state.transposeStep;
    emit(state.copyWith(
      originalPdfKey: pdfKey,
      baseTransposeOffset: baseTransposeOffset,
      transposeStep: recommendedTranspose,
    ));
    if (recommendedTranspose != previousTranspose) {
      _midiEngine.setTranspose(recommendedTranspose);
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

  void changeLyricsTextAlign(String align) {
    emit(state.copyWith(lyricsTextAlign: align));
  }

  void changeLyricsVerticalAlign(String align) {
    emit(state.copyWith(lyricsVerticalAlign: align));
  }

  void changeChordFontSizePercent(int value) {
    emit(state.copyWith(chordFontSizePercent: value.clamp(50, 200)));
  }

  void changeChordFillOpacityPercent(int value) {
    emit(state.copyWith(chordFillOpacityPercent: value.clamp(0, 100)));
  }

  void changeChordPaddingPercent(int value) {
    emit(state.copyWith(chordPaddingPercent: value.clamp(0, 400)));
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
        .copyWith(
          isAudioLoading: false,
          isLoading: false,
          selectedSong: null,
          showAudio: false,
          showChord: false,
          transposeStep: 0,
          originalFamilyChord: null,
          originalPdfKey: null,
          baseTransposeOffset: 0,
          tempoBpm: 76,
          defaultTempoBpm: 76,
          midiInstrument: null,
          isAudioPlaying: false,
        )
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

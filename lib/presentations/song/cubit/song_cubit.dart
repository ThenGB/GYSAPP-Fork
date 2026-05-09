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
import 'song_playback_defaults.dart';
import 'song_playlist.dart';
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
  MidiPlaybackState _lastMidiState = const MidiPlaybackState();
  bool _handlingAutoNext = false;

  SongCubit(this.songRepository, this._assetService, this._midiEngine)
    : super(const SongState()) {
    _setupMidiStreams();
    _midiEngine.setCacheMax(const SongState().preloadCacheMax);
    getData().then((_) async {
      await _midiEngine.initialize();
      await _midiEngine.changeSoundFont(state.soundFont);
      _midiEngine.setCacheMax(state.preloadCacheMax);
      _preloadCurrentSongMidi();
    });
  }

  void _setupMidiStreams() {
    _midiStateSub = _midiEngine.stateStream.listen((midiState) {
      final ended = _didMidiEnd(_lastMidiState, midiState);
      _lastMidiState = midiState;
      // Convert MidiPlaybackState to relevant SongState updates
      if (midiState.isPlaying != state.isAudioPlaying) {
        emit(state.copyWith(isAudioPlaying: midiState.isPlaying));
      }
      if (midiState.isLoading != state.isAudioLoading) {
        emit(state.copyWith(isAudioLoading: midiState.isLoading));
      }
      if (ended) {
        unawaited(_handleMidiSongEnded());
      }
    });
  }

  bool _didMidiEnd(MidiPlaybackState previous, MidiPlaybackState current) {
    if (!previous.isPlaying || current.isPlaying || current.duration <= 0) {
      return false;
    }
    return current.position >= current.duration - 0.35;
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
    _resetSongScopedPlaybackDefaults();
    _preloadNearbySongMidi(state.pageIndex);
    final song = state.songs[state.pageIndex];
    await _loadMidiForSong(song, force: true);
  }

  Future<String?> _midiPathForSong(Song song) {
    return _assetService.getMidiPath(song.code ?? '', song.number ?? '');
  }

  Future<void> _loadMidiForSong(
    Song song, {
    bool autoplay = false,
    bool force = false,
  }) async {
    if (!force && !state.showAudio) return;

    final midiPath = await _midiPathForSong(song);
    if (midiPath == null) {
      emit(
        state.copyWith(
          isAudioLoading: false,
          showAudio: state.showAudio ? false : state.showAudio,
        ),
      );
      return;
    }

    emit(state.copyWith(isAudioLoading: true));
    await _midiEngine.loadMidi(
      midiPath,
      transpose: state.transposeStep,
      tempoBpm: state.tempoBpm,
      baseTempoBpm: state.defaultTempoBpm,
      instrument: state.midiInstrument,
      autoplay: autoplay,
    );
    emit(state.copyWith(isAudioLoading: false));
  }

  void _preloadNearbySongMidi(int index) {
    if (!state.preloadEnabled) return;
    final queue = _playbackQueue();
    for (final song in queue.getPreloadSongs(state.preloadCount)) {
      _midiPathForSong(song).then((midiPath) {
        if (midiPath == null) return;
        final preset = _defaultPreloadSettingsFor(song);
        _midiEngine.preload(
          midiPath,
          transpose: preset.transposeStep,
          tempoBpm: preset.tempoBpm,
          baseTempoBpm: preset.defaultTempoBpm,
          instrument: state.midiInstrument,
          soundFont: state.soundFont,
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
    final normalized = semitones.clamp(-12, 12);
    emit(state.copyWith(transposeStep: normalized));
    _midiEngine.setTranspose(normalized);
    _preloadNearbySongMidi(state.pageIndex);
  }

  void setTransposeKey(String key) {
    setTranspose(_currentPlaybackDefaults().transposeStepForKey(key));
  }

  void setChordAccidentalMode(String mode) {
    final normalized = mode == ChordService.accidentalFlat
        ? ChordService.accidentalFlat
        : ChordService.accidentalSharp;
    final baseline = _currentPlaybackDefaults().resolveChordBaseline(
      familyChord: state.originalFamilyChord,
      pdfKey: state.originalPdfKey,
      preferNaturalChords: state.preferNaturalChords,
    );
    emit(
      state.copyWith(
        chordAccidentalMode: normalized,
        transposeStep: baseline.transposeStep,
        baseTransposeOffset: baseline.baseTransposeOffset,
      ),
    );
    _midiEngine.setTranspose(baseline.transposeStep);
  }

  void togglePreferNaturalChords([bool? value]) {
    final preferNatural = value ?? !state.preferNaturalChords;
    final baseline = _currentPlaybackDefaults().resolveChordBaseline(
      familyChord: state.originalFamilyChord,
      pdfKey: state.originalPdfKey,
      preferNaturalChords: preferNatural,
    );
    emit(
      state.copyWith(
        preferNaturalChords: preferNatural,
        transposeStep: baseline.transposeStep,
        baseTransposeOffset: baseline.baseTransposeOffset,
      ),
    );
    _midiEngine.setTranspose(baseline.transposeStep);
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
    _debouncer?.cancel();
    _debouncer = Timer(const Duration(milliseconds: 250), () {
      _midiEngine.setTempo(bpm);
      _preloadNearbySongMidi(state.pageIndex);
    });
  }

  void setDefaultTempo(double bpm) {
    emit(state.copyWith(defaultTempoBpm: bpm, tempoBpm: bpm));
    _midiEngine.setTempoBase(bpm);
    _preloadNearbySongMidi(state.pageIndex);
  }

  // ─── Instrument ───────────────────────────────────────────────

  void setMidiInstrument(int? program) {
    emit(state.copyWith(midiInstrument: program));
    _midiEngine.setInstrument(program ?? -1);
    _preloadNearbySongMidi(state.pageIndex);
  }

  void setPreloadEnabled(bool enabled) {
    emit(state.copyWith(preloadEnabled: enabled));
    if (enabled) {
      _preloadNearbySongMidi(state.pageIndex);
    }
  }

  void setPreloadCount(int count) {
    final clamped = count.clamp(1, 5);
    emit(state.copyWith(preloadCount: clamped));
    _preloadNearbySongMidi(state.pageIndex);
  }

  void setPreloadCacheMax(int max) {
    final clamped = max.clamp(4, 32);
    _midiEngine.setCacheMax(clamped);
    emit(state.copyWith(preloadCacheMax: clamped));
  }

  void resetPlaybackSettings() {
    emit(
      state.copyWith(
        showAudio: false,
        showChord: false,
        transposeStep: 0,
        originalFamilyChord: null,
        originalPdfKey: null,
        baseTransposeOffset: 0,
        tempoBpm: 76,
        defaultTempoBpm: 76,
        midiInstrument: null,
        soundFont: defaultMidiSoundFont,
        isAudioPlaying: false,
      ),
    );
    _midiEngine.stop();
    _midiEngine.setTranspose(0);
    _midiEngine.setTempo(76);
    _midiEngine.setInstrument(-1);
  }

  // ─── SoundFont ────────────────────────────────────────────────

  Future<void> setSoundFont(String fileName) async {
    emit(state.copyWith(soundFont: fileName));
    await _midiEngine.changeSoundFont(fileName);
    if (state.songs.isNotEmpty) {
      await _loadMidiForSong(state.songs[state.pageIndex], force: true);
      _preloadNearbySongMidi(state.pageIndex);
    }
  }

  // ─── Page Navigation ──────────────────────────────────────────

  Future<void> changePage(int index, int verseIndex) async {
    if (index < 0 || index >= state.songs.length) return;
    final wasPlaying = state.isAudioPlaying;
    final reset = _currentPlaybackDefaults().resetForSong();
    emit(
      state.copyWith(
        pageIndex: index,
        verseIndex: verseIndex,
        isAudioPlaying: false,
        transposeStep: reset.transposeStep,
        tempoBpm: reset.tempoBpm,
        defaultTempoBpm: reset.defaultTempoBpm,
        originalPdfKey: reset.originalPdfKey,
        originalFamilyChord: reset.originalFamilyChord,
        baseTransposeOffset: reset.baseTransposeOffset,
      ),
    );
    _midiEngine.setTranspose(reset.transposeStep);
    _midiEngine.setTempoBase(reset.defaultTempoBpm);
    await _loadMidiForSong(
      state.songs[index],
      autoplay: wasPlaying,
      force: true,
    );
    _preloadNearbySongMidi(index);
  }

  void setPdfTwoPageMode(bool enabled) {
    emit(
      state.copyWith(
        pdfTwoPageMode: enabled,
        pdfVerticalScrolling: enabled ? false : state.pdfVerticalScrolling,
      ),
    );
  }

  void setPdfVerticalScrolling(bool enabled) {
    emit(
      state.copyWith(
        pdfVerticalScrolling: enabled,
        pdfTwoPageMode: enabled ? false : state.pdfTwoPageMode,
      ),
    );
  }

  // ─── Chord Data Loading ───────────────────────────────────────

  Future<Map<int, List<ChordData>>?> loadChordData(Song song) async {
    if (song.code != 'KR') return null;

    final chordPath = await _assetService.getChordPath(
      song.code ?? '',
      song.number ?? '',
    );
    if (chordPath == null) return null;

    try {
      final jsonString = await rootBundle.loadString(chordPath);
      final chords = ChordService.parseChordJson(jsonString);
      final familyChord = ChordService.detectFamilyChord(chords);

      // Invalidate old PDF key so chord display doesn't use stale offset
      // The PDF viewer will call updatePdfKey with the correct key after rendering
      final pdfKey = state.originalPdfKey;
      final baseline = _currentPlaybackDefaults().resolveChordBaseline(
        familyChord: familyChord,
        pdfKey: pdfKey,
        preferNaturalChords: state.preferNaturalChords,
      );
      final previousTranspose = state.transposeStep;
      emit(
        state.copyWith(
          originalFamilyChord: baseline.originalFamilyChord,
          baseTransposeOffset: baseline.baseTransposeOffset,
          originalPdfKey: baseline.originalPdfKey,
          transposeStep: baseline.transposeStep,
        ),
      );
      if (baseline.transposeStep != previousTranspose) {
        _midiEngine.setTranspose(baseline.transposeStep);
      }
      return chords;
    } catch (e) {
      log('Error loading chord data: $e');
      return null;
    }
  }

  void updatePdfKey(String? pdfKey) {
    if (pdfKey == state.originalPdfKey) return;
    final baseline = _currentPlaybackDefaults().resolveChordBaseline(
      familyChord: state.originalFamilyChord,
      pdfKey: pdfKey,
      preferNaturalChords: state.preferNaturalChords,
    );
    if (state.preferNaturalChords && state.originalFamilyChord == null) {
      emit(
        state.copyWith(
          originalPdfKey: baseline.originalPdfKey,
          baseTransposeOffset: baseline.baseTransposeOffset,
        ),
      );
      return;
    }
    final previousTranspose = state.transposeStep;
    emit(
      state.copyWith(
        originalPdfKey: baseline.originalPdfKey,
        baseTransposeOffset: baseline.baseTransposeOffset,
        transposeStep: baseline.transposeStep,
      ),
    );
    if (baseline.transposeStep != previousTranspose) {
      _midiEngine.setTranspose(baseline.transposeStep);
    }
  }

  SongPlaybackDefaults _currentPlaybackDefaults() {
    return SongPlaybackDefaults(
      transposeStep: state.transposeStep,
      tempoBpm: state.tempoBpm,
      defaultTempoBpm: state.defaultTempoBpm,
      originalFamilyChord: state.originalFamilyChord,
      originalPdfKey: state.originalPdfKey,
      baseTransposeOffset: state.baseTransposeOffset,
    );
  }

  SongPlaybackDefaults _defaultPreloadSettingsFor(Song song) {
    if (state.pageIndex < state.songs.length &&
        state.songs[state.pageIndex].code == song.code &&
        state.songs[state.pageIndex].number == song.number) {
      return _currentPlaybackDefaults();
    }
    return _currentPlaybackDefaults().resetForSong();
  }

  SongPlaybackQueue _playbackQueue() {
    final currentSong =
        state.pageIndex >= 0 && state.pageIndex < state.songs.length
        ? state.songs[state.pageIndex]
        : null;
    return SongPlaybackQueue.resolve(
      books: state.songBook,
      currentSongs: state.songs,
      currentSong: currentSong,
      playlists: state.playlists,
      activePlaylistId: state.activePlaylistId,
      autoNextMode: state.playlistAutoNextMode,
      shuffleIndex:
          state.playlistAutoNextMode == SongPlaylistAutoNextMode.shufflePlaylist
          ? state.playlistShuffleIndex
          : state.shuffleIndex,
    );
  }

  Future<void> _handleMidiSongEnded() async {
    if (_handlingAutoNext) return;
    final mode = SongPlaylistAutoNextMode.normalize(state.playlistAutoNextMode);
    if (mode == SongPlaylistAutoNextMode.off) return;
    final nextSong = _playbackQueue().nextSong;
    if (nextSong == null) return;

    _handlingAutoNext = true;
    try {
      await _openSong(nextSong, autoplay: true);
    } finally {
      _handlingAutoNext = false;
    }
  }

  Future<void> _openSong(Song song, {bool autoplay = false}) async {
    final bookCode = song.code ?? state.bookCode;
    final book = state.songBook.firstWhere(
      (book) => book.code == bookCode,
      orElse: () => SongBook(code: bookCode, songs: const []),
    );
    final index = book.songs.indexWhere(
      (item) => item.code == song.code && item.number == song.number,
    );
    if (index < 0) return;
    emit(state.copyWith(bookCode: bookCode, playOnlyFavorite: false));
    await changePage(index, 0);
    if (autoplay) {
      await play();
    }
  }

  void _resetSongScopedPlaybackDefaults() {
    final reset = _currentPlaybackDefaults().resetForSong();
    emit(
      state.copyWith(
        transposeStep: reset.transposeStep,
        tempoBpm: reset.tempoBpm,
        defaultTempoBpm: reset.defaultTempoBpm,
        originalFamilyChord: reset.originalFamilyChord,
        originalPdfKey: reset.originalPdfKey,
        baseTransposeOffset: reset.baseTransposeOffset,
      ),
    );
    _midiEngine.setTranspose(reset.transposeStep);
    _midiEngine.setTempoBase(reset.defaultTempoBpm);
  }

  // ─── Book Code ────────────────────────────────────────────────

  // Playlists

  SongPlaylist? get activePlaylist {
    final id = state.activePlaylistId;
    if (id == null) return null;
    for (final playlist in state.playlists) {
      if (playlist.id == id) return playlist;
    }
    return null;
  }

  void createPlaylist([String? name]) {
    final playlist = SongPlaylist(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: (name == null || name.trim().isEmpty) ? 'Playlist' : name.trim(),
      songs: const [],
    );
    emit(
      state.copyWith(
        playlists: [...state.playlists, playlist],
        activePlaylistId: state.activePlaylistId ?? playlist.id,
      ),
    );
  }

  void renamePlaylist(String playlistId, String name) {
    final normalized = name.trim();
    if (normalized.isEmpty) return;
    emit(
      state.copyWith(
        playlists: state.playlists
            .map(
              (playlist) => playlist.id == playlistId
                  ? playlist.copyWith(name: normalized)
                  : playlist,
            )
            .toList(),
      ),
    );
  }

  void deletePlaylist(String playlistId) {
    final playlists = state.playlists
        .where((playlist) => playlist.id != playlistId)
        .toList();
    emit(
      state.copyWith(
        playlists: playlists,
        activePlaylistId: state.activePlaylistId == playlistId
            ? (playlists.isEmpty ? null : playlists.first.id)
            : state.activePlaylistId,
      ),
    );
  }

  void setActivePlaylist(String? playlistId) {
    emit(state.copyWith(activePlaylistId: playlistId));
    _preloadNearbySongMidi(state.pageIndex);
  }

  void setPlaylistAutoNextMode(String mode) {
    final normalized = SongPlaylistAutoNextMode.normalize(mode);
    emit(state.copyWith(playlistAutoNextMode: normalized));
    _refreshPlaylistShuffleIfNeeded();
    _preloadNearbySongMidi(state.pageIndex);
  }

  void addSongToActivePlaylist(Song song) {
    if (state.playlists.isEmpty) {
      createPlaylist('Playlist');
    }
    final playlistId = state.activePlaylistId ?? state.playlists.first.id;
    addSongToPlaylist(playlistId, song);
  }

  void addSongToPlaylist(String playlistId, Song song) {
    emit(
      state.copyWith(
        playlists: state.playlists.map((playlist) {
          if (playlist.id != playlistId) return playlist;
          return playlist.copyWith(
            songs: [...playlist.songs, SongPlaylistItem.fromSong(song)],
          );
        }).toList(),
        activePlaylistId: state.activePlaylistId ?? playlistId,
      ),
    );
    _refreshPlaylistShuffleIfNeeded();
    _preloadNearbySongMidi(state.pageIndex);
  }

  void removeSongFromPlaylist(String playlistId, int songIndex) {
    emit(
      state.copyWith(
        playlists: state.playlists.map((playlist) {
          if (playlist.id != playlistId ||
              songIndex < 0 ||
              songIndex >= playlist.songs.length) {
            return playlist;
          }
          final songs = List<SongPlaylistItem>.from(playlist.songs)
            ..removeAt(songIndex);
          return playlist.copyWith(songs: songs);
        }).toList(),
      ),
    );
    _refreshPlaylistShuffleIfNeeded();
    _preloadNearbySongMidi(state.pageIndex);
  }

  bool isSongInActivePlaylist(Song song) {
    return activePlaylist?.songs.any((item) => item.matches(song)) ?? false;
  }

  void _refreshPlaylistShuffleIfNeeded() {
    if (state.playlistAutoNextMode !=
        SongPlaylistAutoNextMode.shufflePlaylist) {
      return;
    }
    emit(
      state.copyWith(
        playlistShuffleIndex: getRandomUniqueIndex(
          activePlaylist?.songs.length ?? 0,
        ),
      ),
    );
  }

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
      modifiedSongBook = state.songBook
          .map((e) => e.copyWith(songs: []))
          .toList();
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
    emit(
      state.copyWith(
        favoriteSongBook: modifiedSongBook,
        playOnlyFavorite: playOnlyFav && hasFavoriteSongs,
      ),
    );
  }

  bool isSongFavorite(Song? song) {
    if (song == null) return false;
    if (state.favoriteSongBook.map((e) => e.code).contains(song.code)) {
      SongBook songBook = state.favoriteSongBook.firstWhere(
        (element) => element.code == song.code,
      );
      return songBook.songs.map((e) => e.number).contains(song.number);
    } else {
      return false;
    }
  }

  // ─── History ──────────────────────────────────────────────────

  void deleteHistory(SongHistory history) {
    emit(
      state.copyWith(
        histories: List<SongHistory>.from(state.histories)..remove(history),
      ),
    );
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
      msg: 'Shuffle mode ${state.shuffleMode ? 'disabled' : 'enabled'}',
    );
    emit(state.copyWith(shuffleMode: !state.shuffleMode));
    _preloadNearbySongMidi(state.pageIndex);
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

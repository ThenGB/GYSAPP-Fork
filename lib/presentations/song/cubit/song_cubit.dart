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
  bool get isWarmUpEnabled => state.midiPreloadEnabled;

  void toggleWarmUp([bool? value]) {
    final newValue = value ?? !state.midiPreloadEnabled;
    emit(state.copyWith(midiPreloadEnabled: newValue));
    if (newValue) {
      unawaited(_warmUpPlaybackQueue());
    }
  }

  Future<void> _warmUpPlaybackQueue() async {
    try {
      if (!state.midiPreloadEnabled ||
          !state.showAudio ||
          state.songs.isEmpty) {
        log(
          'Warm-up skipped: enabled=${state.midiPreloadEnabled}, showAudio=${state.showAudio}, songs=${state.songs.length}',
          name: 'SongCubit',
        );
        return;
      }
      final count = state.midiPreloadNeighborCount.clamp(0, 5);
      final queue = _playbackQueue();
      final preloadSongs = queue.preloadSongs(count: count);
      log(
        'Warm-up starting: mode=${queue.autoNextMode}, count=$count, preloadSongs=${preloadSongs.length}',
        name: 'SongCubit',
      );
      for (final song in preloadSongs) {
        final midiPath = await _midiPathForSong(song);
        if (midiPath != null) {
          final defaults = await _resolvePreloadDefaultsForSong(song);
          log(
            'Warm-up song: ${song.code} ${song.number} → $midiPath',
            name: 'SongCubit',
          );
          unawaited(
            _midiEngine.warmUp(
              midiPath,
              transpose: defaults.transposeStep,
              tempoBpm: defaults.tempoBpm,
              baseTempoBpm: defaults.defaultTempoBpm,
              instrument: state.midiInstrument,
            ),
          );
        }
      }
      log('Warm-up finished', name: 'SongCubit');
    } catch (e, st) {
      log('Warm-up error: $e', name: 'SongCubit', error: e, stackTrace: st);
    }
  }

  StreamSubscription<MidiPlaybackState>? _midiStateSub;
  Timer? _debouncer;
  MidiPlaybackState _lastMidiState = const MidiPlaybackState();
  bool _handlingAutoNext = false;
  int _midiLoadGeneration = 0;

  SongCubit(this.songRepository, this._assetService, this._midiEngine)
    : super(const SongState()) {
    _setupMidiStreams();
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    // Run data loading and MIDI engine init in parallel so they don't
    // block each other at startup.
    final dataFuture = getData();
    final midiInitFuture = _midiEngine.initialize();
    await Future.wait([dataFuture, midiInitFuture]);

    // Apply persisted engine settings.
    await _midiEngine.changeSoundFont(state.soundFont);
    _midiEngine.setCacheMax(state.midiCacheMaxCount);

    // If audio was enabled in a previous session, pre-warm the current
    // song's MIDI in the background so playback starts instantly.
    if (state.showAudio && state.songs.isNotEmpty) {
      final currentIdx = state.pageIndex.clamp(0, state.songs.length - 1);
      final currentSong = state.songs[currentIdx];
      final midiPath = await _midiPathForSong(currentSong);
      if (midiPath != null) {
        final defaults = await _resolvePreloadDefaultsForSong(currentSong);
        log(
          'Startup warm-up current song: ${currentSong.code} ${currentSong.number} → $midiPath',
          name: 'SongCubit',
        );
        unawaited(
          _midiEngine.warmUp(
            midiPath,
            transpose: defaults.transposeStep,
            tempoBpm: defaults.tempoBpm,
            baseTempoBpm: defaults.defaultTempoBpm,
            instrument: state.midiInstrument,
          ),
        );
      }
      unawaited(_warmUpPlaybackQueue());
    }
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

  Future<String?> _midiPathForSong(Song song) {
    final midiCode = song.midiMappedFrom ?? song.code ?? '';
    final midiNumber = song.midiMappedNumber ?? song.number ?? '';
    return _assetService.getMidiPath(midiCode, midiNumber);
  }

  Future<void> _loadMidiForSong(
    Song song, {
    bool autoplay = false,
    bool force = false,
  }) async {
    if (!force && !state.showAudio) return;

    final loadGeneration = ++_midiLoadGeneration;
    final midiPath = await _midiPathForSong(song);
    if (!_isActiveMidiLoad(loadGeneration)) return;
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
    if (!_isActiveMidiLoad(loadGeneration)) return;
    emit(state.copyWith(isAudioLoading: false));
  }

  bool _isActiveMidiLoad(int loadGeneration) {
    return !isClosed && loadGeneration == _midiLoadGeneration;
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
    unawaited(_warmUpPlaybackQueue());
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
      unawaited(
        _loadMidiForSong(state.songs[state.pageIndex]).then((_) {
          return _warmUpPlaybackQueue();
        }),
      );
    } else {
      _midiLoadGeneration++;
      unawaited(_midiEngine.stop());
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
    });
  }

  void setDefaultTempo(double bpm) {
    emit(state.copyWith(defaultTempoBpm: bpm, tempoBpm: bpm));
    _midiEngine.setTempoBase(bpm);
  }

  // ─── Accidental Mode ─────────────────────────────────────────────

  void toggleAccidentalMode() {
    final newMode = state.chordAccidentalMode == ChordService.accidentalSharp
        ? ChordService.accidentalFlat
        : ChordService.accidentalSharp;
    emit(state.copyWith(chordAccidentalMode: newMode));
  }

  // ─── Instrument ───────────────────────────────────────────────

  void setMidiInstrument(int? program) {
    emit(state.copyWith(midiInstrument: program));
    _midiEngine.setInstrument(program ?? -1);
    unawaited(_warmUpPlaybackQueue());
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
    _midiLoadGeneration++;
    unawaited(_midiEngine.stop());
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
      unawaited(_warmUpPlaybackQueue());
    }
  }

  // ─── Preload Settings ───────────────────────────────────────

  void setMidiPreloadNeighborCount(int count) {
    final clamped = count.clamp(0, 5);
    emit(state.copyWith(midiPreloadNeighborCount: clamped));
    unawaited(_warmUpPlaybackQueue());
  }

  void setMidiCacheMaxCount(int count) {
    final clamped = count.clamp(4, 32);
    emit(state.copyWith(midiCacheMaxCount: clamped));
    _midiEngine.setCacheMax(clamped);
  }

  // ─── Page Navigation ──────────────────────────────────────────

  Future<void> changePage(int index, int verseIndex) async {
    if (index < 0 || index >= state.songs.length) return;
    final wasPlaying = state.isAudioPlaying;
    final song = state.songs[index];
    log(
      'changePage: ${song.code} ${song.number} (index=$index, wasPlaying=$wasPlaying)',
      name: 'SongCubit',
    );
    final reset = await _resolvePreloadDefaultsForSong(song);
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
    await _loadMidiForSong(song, autoplay: wasPlaying, force: true);
    unawaited(_warmUpPlaybackQueue());
  }

  Future<void> goToPreviousSong() async {
    final song = _playbackQueue().manualPreviousSong;
    if (song != null) {
      await _openSong(song, autoplay: state.isAudioPlaying);
    }
  }

  Future<void> goToNextSong() async {
    final song = _playbackQueue().manualNextSong;
    if (song != null) {
      await _openSong(song, autoplay: state.isAudioPlaying);
    }
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

  /// Re-detect family chord from edited chords (e.g. from the PDF viewer's
  /// note-aligned chord editor) and update transpose baseline accordingly.
  /// This mirrors gyschordweb's detectNoteAlignedFamilyChord.
  void detectAndUpdateFamilyChord(Map<int, List<ChordData>> chords) {
    final familyChord = ChordService.detectFamilyChord(chords);
    final baseline = _currentPlaybackDefaults().resolveChordBaseline(
      familyChord: familyChord,
      pdfKey: state.originalPdfKey,
      preferNaturalChords: state.preferNaturalChords,
    );
    final previousTranspose = state.transposeStep;
    emit(
      state.copyWith(
        originalFamilyChord: baseline.originalFamilyChord,
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
    if (mode == SongPlaylistAutoNextMode.one) {
      await _midiEngine.seek(0);
      await _midiEngine.play();
      emit(state.copyWith(isAudioPlaying: true));
      return;
    }
    final nextSong = _playbackQueue().nextSong;
    if (nextSong == null) return;

    _handlingAutoNext = true;
    try {
      await _openSong(nextSong, autoplay: true);
    } finally {
      _handlingAutoNext = false;
    }
  }

  /// Open a specific [song] by switching to its book and jumping to its page.
  /// This is the canonical way to navigate to a song from any context
  Future<void> openSong(Song song, {bool autoplay = false}) =>
      _openSong(song, autoplay: autoplay);

  Future<void> _openSong(Song song, {bool autoplay = false}) async {
    final bookCode = song.code ?? state.bookCode;
    final book = state.songBook.firstWhere(
      (book) => book.code == bookCode,
      orElse: () => SongBook(code: bookCode, songs: const []),
    );
    final index = book.songs.indexWhere(
      (item) => item.code == song.code && item.number == song.number,
    );
    log(
      'openSong: ${song.code} ${song.number} → book=$bookCode, index=$index',
      name: 'SongCubit',
    );
    if (index < 0) return;
    addToHistory(
      SongHistory(index: index, bookCode: bookCode, createdAt: DateTime.now()),
    );
    // Update bookCode AND pageIndex in a single emit to avoid triggering
    // the BlocConsumer listener twice (once for bookCode, once for pageIndex).
    emit(state.copyWith(bookCode: bookCode, pageIndex: index));
    // Still call changePage to load MIDI and other per-song state.
    // Note: changePage emits again, but with the same pageIndex so the
    // listener's listenWhen (pageIndex change) will skip the second fire.
    await changePage(index, 0);
    if (autoplay) {
      await play();
    }
  }

  Future<SongPlaybackDefaults> _resolvePreloadDefaultsForSong(Song song) async {
    final currentSong =
        state.pageIndex >= 0 && state.pageIndex < state.songs.length
        ? state.songs[state.pageIndex]
        : null;
    final songMatchesCurrent =
        currentSong != null &&
        currentSong.code == song.code &&
        currentSong.number == song.number;
    final familyChord = await _detectFamilyChordForSong(song);
    final base = _currentPlaybackDefaults().resetForSong();
    if (!state.preferNaturalChords) {
      return base;
    }
    return base.resolveChordBaseline(
      familyChord: familyChord,
      pdfKey: songMatchesCurrent ? state.originalPdfKey : null,
      preferNaturalChords: true,
    );
  }

  Future<String?> _detectFamilyChordForSong(Song song) async {
    if (!state.preferNaturalChords) return null;
    final chordPath = await _assetService.getChordPath(
      song.code ?? '',
      song.number ?? '',
    );
    if (chordPath == null) return null;
    try {
      final jsonString = await rootBundle.loadString(chordPath);
      final chords = ChordService.parseChordJson(jsonString);
      return ChordService.detectFamilyChord(chords);
    } catch (e) {
      log('Error detecting family chord for preload: $e');
      return null;
    }
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
    final currentMode = SongPlaylistAutoNextMode.normalize(
      state.playlistAutoNextMode,
    );
    final nextMode =
        currentMode == SongPlaylistAutoNextMode.playlist ||
            currentMode == SongPlaylistAutoNextMode.shufflePlaylist
        ? currentMode
        : SongPlaylistAutoNextMode.playlist;
    emit(
      state.copyWith(
        activePlaylistId: playlistId,
        playlistAutoNextMode: playlistId == null ? currentMode : nextMode,
      ),
    );
    _refreshPlaylistShuffleIfNeeded();
    unawaited(_warmUpPlaybackQueue());
  }

  void setPlaylistAutoNextMode(String mode) {
    final normalized = SongPlaylistAutoNextMode.normalize(mode);
    emit(state.copyWith(playlistAutoNextMode: normalized));
    _refreshPlaylistShuffleIfNeeded();
    unawaited(_warmUpPlaybackQueue());
  }

  void cycleLoopMode() {
    final nextMode = SongPlaylistAutoNextMode.cycle(
      state.playlistAutoNextMode,
      hasUsableShufflePlaylist: activePlaylist?.songs.isNotEmpty ?? false,
    );
    setPlaylistAutoNextMode(nextMode);
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
    unawaited(_warmUpPlaybackQueue());
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
    unawaited(_warmUpPlaybackQueue());
  }

  bool isSongInActivePlaylist(Song song) {
    return activePlaylist?.songs.any((item) => item.matches(song)) ?? false;
  }

  void _refreshPlaylistShuffleIfNeeded() {
    final mode = SongPlaylistAutoNextMode.normalize(state.playlistAutoNextMode);
    if (mode == SongPlaylistAutoNextMode.shufflePlaylist) {
      emit(
        state.copyWith(
          playlistShuffleIndex: getRandomUniqueIndex(
            activePlaylist?.songs.length ?? 0,
          ),
        ),
      );
      return;
    }
    if (mode == SongPlaylistAutoNextMode.shuffleAll) {
      emit(
        state.copyWith(shuffleIndex: getRandomUniqueIndex(state.songs.length)),
      );
    }
  }

  void changeBookcode(String bookCode) {
    final songCount = state.songBook
        .firstWhere(
          (book) => book.code == bookCode,
          orElse: () => SongBook(code: bookCode, songs: const []),
        )
        .songs
        .length;
    emit(
      state.copyWith(
        bookCode: bookCode,
        shuffleIndex: getRandomUniqueIndex(songCount),
      ),
    );
    unawaited(_warmUpPlaybackQueue());
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
    return _clearTransientSelection(SongState.fromJson(json));
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
    emit(_clearTransientSelection(songState));
  }

  SongState _clearTransientSelection(SongState songState) {
    return songState.copyWith(selectedSong: null);
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

import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../data/services/chord_service.dart';
import '../../../data/services/local_asset_service.dart';
import '../../../data/services/midi_engine_service.dart';
import '../../../data/services/pdf_note_service.dart';
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
      if (!state.midiPreloadEnabled || state.songs.isEmpty) {
        return;
      }
      final count = state.midiPreloadNeighborCount.clamp(0, 5);
      final queue = _playbackQueue();
      final preloadSongs = queue.preloadSongs(count: count);

      log(
        'Warm-up starting for ${preloadSongs.length} neighbors',
        name: 'SongCubit',
      );

      // Separate MIDI and PDF warmup chains so they don't block each other
      unawaited(_warmUpMidiChain(preloadSongs));
      unawaited(_warmUpPdfChain(preloadSongs));
    } catch (e, st) {
      log('Warm-up error: $e', name: 'SongCubit', error: e, stackTrace: st);
    }
  }

  Future<void> _warmUpMidiChain(List<Song> songs) async {
    if (!state.showAudio) return;
    for (final song in songs) {
      try {
        final midiPath = await _midiPathForSong(song);
        if (midiPath == null) continue;

        final defaults = await _resolvePreloadDefaultsForSong(song);
        await _midiEngine.warmUp(
          midiPath,
          transpose: defaults.transposeStep,
          tempoBpm: defaults.tempoBpm,
          baseTempoBpm: defaults.defaultTempoBpm,
          instrument: state.midiInstrument,
        );
      } catch (e) {
        log('MIDI Warm-up failed for ${song.number}: $e', name: 'SongCubit');
      }
    }
  }

  Future<void> _warmUpPdfChain(List<Song> songs) async {
    final noteService = PdfNoteService();
    for (final song in songs) {
      try {
        final pdfPath = await getPdfPath(song.code ?? '', song.number ?? '');
        if (pdfPath == null) continue;

        // Perform deep warmup: extraction + note detection
        final request = PdfDocumentRequest.parse(pdfPath);
        await noteService.warmup(
          request.assetPath,
          startPage: request.startPage,
          pageCount: _warmupPageCount(request.pageCount),
        );
      } catch (e) {
        log('PDF Warm-up failed for ${song.number}: $e', name: 'SongCubit');
      }
    }
  }

  StreamSubscription<MidiPlaybackState>? _midiStateSub;
  Timer? _debouncer;
  MidiPlaybackState _lastMidiState = const MidiPlaybackState();
  bool _handlingAutoNext = false;
  int _midiLoadGeneration = 0;
  int _pdfLoadGeneration = 0;

  SongCubit(this.songRepository, this._assetService, this._midiEngine)
    : super(const SongState()) {
    _setupMidiStreams();
    _initializeAsync();
  }

  /// Temporary cache for chords parsed during resolution to avoid redundant asset loads.
  Map<int, List<ChordData>>? _resolvedChordsCache;

  Future<void> _initializeAsync() async {
    // PRE-INITIALIZE the local asset service so index and paths are ready
    // This is much faster than waiting for the repository wrapper.
    unawaited(_assetService.initialize());

    // START IMMEDIATELY: If we have cached state, trigger resource loading
    // without waiting for any other async initialization. This provides
    // the "instant" PDF experience.
    if (state.songs.isNotEmpty) {
      final currentIdx = state.pageIndex.clamp(0, state.songs.length - 1);
      final currentSong = state.songs[currentIdx];

      log('Startup immediate load: ${currentSong.number}', name: 'SongCubit');

      // Clear cache before starting
      _resolvedChordsCache = null;

      // Force-resolve paths and trigger pre-warmup immediately
      unawaited(
        _assetService
            .getPdfPath(currentSong.code ?? '', currentSong.number ?? '')
            .then((path) {
              if (path != null) {
                // 1. Update state so UI starts rendering the PDF container
                emit(state.copyWith(currentPdfPath: path, isPdfLoading: false));

                // 2. Trigger note extraction pre-warmup
                unawaited(
                  () async {
                    final metadataSource = _metadataSourceForSong(currentSong);
                    final metadataPdfPath = await _assetService.getPdfPath(
                      metadataSource.bookCode,
                      metadataSource.number,
                    );
                    final request = PdfDocumentRequest.parse(
                      metadataPdfPath ?? path,
                    );
                    return PdfNoteService().warmup(
                      request.assetPath,
                      startPage: request.startPage,
                      pageCount: _warmupPageCount(request.pageCount),
                    );
                  }().then((metadata) {
                    if (metadata == null || isClosed) return;
                    if (metadata.detectedKey != null) {
                      updatePdfKey(metadata.detectedKey);
                    }
                    if (metadata.detectedTempo != null) {
                      updatePdfTempo(metadata.detectedTempo!);
                    }
                  }),
                );
              }
            }),
      );

      // Load Chords and resources in parallel - CRITICAL for first load
      unawaited(_loadChordDataInternal(currentSong));
      unawaited(_loadPdfForSong(currentSong));
    }

    // Run data loading and MIDI engine init in parallel
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

      // Delay neighbor warmup significantly to prioritize the active song's resources
      // and ensure the app UI has fully settled after boot.
      Future.delayed(const Duration(seconds: 3), () {
        if (!isClosed) unawaited(_warmUpPlaybackQueue());
      });
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

  Future<void> getData({bool preloadCurrentSong = true}) async {
    final response = await songRepository.getData();
    response.fold(
      (failure) {
        Fluttertoast.cancel();
        Fluttertoast.showToast(msg: failure.message);
      },
      (res) {
        final hadSongs = state.songs.isNotEmpty;
        final availableCodes = res.map((book) => book.code ?? '').toSet();
        final nextBookCode = availableCodes.contains(state.bookCode)
            ? state.bookCode
            : (res.firstOrNull?.code ?? state.bookCode);
        final resetIndex = nextBookCode == state.bookCode ? state.pageIndex : 0;
        emit(
          state.copyWith(
            songBook: res,
            bookCode: nextBookCode,
            pageIndex: resetIndex,
            verseIndex: nextBookCode == state.bookCode ? state.verseIndex : 0,
          ),
        );
        if (preloadCurrentSong &&
            !hadSongs &&
            state.songs.isNotEmpty &&
            state.currentPdfPath == null) {
          final currentIdx = state.pageIndex.clamp(0, state.songs.length - 1);
          final currentSong = state.songs[currentIdx];
          unawaited(_loadResourcesForSong(currentSong));
          unawaited(_loadChordDataInternal(currentSong));
        }
      },
    );
  }

  Future<void> refreshLibraryAvailability() async {
    await getData();
  }

  // ─── PDF & MIDI Resource Loading ──────────────────────────────

  Future<void> _loadResourcesForSong(
    Song song, {
    bool autoplay = false,
    bool forceMidi = false,
  }) async {
    // Ensure PDF key/tempo metadata is ready before MIDI starts.
    await _loadPdfForSong(song, forceMetadataWarmup: true);
    await _loadMidiForSong(song, autoplay: autoplay, force: forceMidi);
    unawaited(_warmUpPlaybackQueue());
  }

  Future<void> _loadPdfForSong(
    Song song, {
    bool forceMetadataWarmup = false,
  }) async {
    final generation = ++_pdfLoadGeneration;
    final songCode = song.code ?? '';
    final songNumber = song.number ?? '';
    final previousPath = state.currentPdfPath;

    final needsPreparation = await _assetService.needsPdfPreparation(
      songCode,
      songNumber,
    );
    if (!_isActivePdfLoad(generation)) return;
    if (needsPreparation) {
      emit(state.copyWith(isPdfLoading: true));
    }

    String? pdfPath;
    try {
      pdfPath = await getPdfPath(songCode, songNumber);

      if (!_isActivePdfLoad(generation)) return;

      final pathUnchanged = pdfPath == previousPath;
      if (!pathUnchanged || state.currentPdfPath != pdfPath) {
        emit(state.copyWith(currentPdfPath: pdfPath));
      }

      // TRIGGER NOTE EXTRACTION EARLY - This pre-warms the PdfNoteService cache
      // so when the PDF viewer opens, note positions are already cached
      if (pdfPath != null && (forceMetadataWarmup || !pathUnchanged)) {
        final noteService = PdfNoteService();
        final metadataSource = _metadataSourceForSong(song);
        final metadataPdfPath = await getPdfPath(
          metadataSource.bookCode,
          metadataSource.number,
        );
        final request = PdfDocumentRequest.parse(metadataPdfPath ?? pdfPath);
        final warmupPages = _warmupPageCount(request.pageCount);

        // Give note extraction a short head start so real note-aligned chord
        // positions are ready sooner on non-preloaded songs.
        try {
          final metadata = await noteService
              .warmup(
                request.assetPath,
                startPage: request.startPage,
                pageCount: warmupPages,
              )
              .timeout(const Duration(milliseconds: 450));
          if (metadata != null) {
            if (metadata.detectedKey != null) {
              updatePdfKey(metadata.detectedKey);
            }
            if (metadata.detectedTempo != null) {
              updatePdfTempo(metadata.detectedTempo!);
            }
          }
        } on TimeoutException {
          log('Note warm-up timeout for ${song.number}', name: 'SongCubit');
        } catch (e) {
          log('Note warm-up failed for ${song.number}: $e', name: 'SongCubit');
        }
      }
    } finally {
      if (_isActivePdfLoad(generation)) {
        emit(
          state.copyWith(
            isPdfLoading: false,
            currentPdfPath: pdfPath ?? state.currentPdfPath,
          ),
        );
      }
    }
  }

  int _warmupPageCount(int? pageCount) {
    final target = pageCount ?? 2;
    if (target < 1) return 1;
    if (target > 2) return 2;
    return target;
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
    if (!force && !state.showAudio) {
      emit(state.copyWith(isAudioLoading: false));
      return;
    }

    final generation = ++_midiLoadGeneration;
    final midiPath = await _midiPathForSong(song);
    if (!_isActiveMidiLoad(generation)) return;
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
    if (!_isActiveMidiLoad(generation)) return;
    emit(state.copyWith(isAudioLoading: false));
  }

  bool _isActiveMidiLoad(int loadGeneration) {
    return !isClosed && loadGeneration == _midiLoadGeneration;
  }

  bool _isActivePdfLoad(int loadGeneration) {
    return !isClosed && loadGeneration == _pdfLoadGeneration;
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
        await _loadPdfForSong(song, forceMetadataWarmup: true);
        await _loadMidiForSong(song, autoplay: true);
        emit(state.copyWith(isAudioPlaying: true));
        unawaited(_warmUpPlaybackQueue());
        return;
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
      final song = state.songs[state.pageIndex];
      unawaited(
        _loadPdfForSong(song, forceMetadataWarmup: true)
            .then((_) {
              return _loadMidiForSong(song);
            })
            .then((_) {
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
    if (!_isChordEnabledForBook(state.bookCode)) {
      if (state.showChord) {
        emit(state.copyWith(showChord: false));
      }
      return;
    }
    emit(state.copyWith(showChord: show ?? !state.showChord));
  }

  // ─── Transpose ────────────────────────────────────────────────

  void setTranspose(int semitones) {
    final normalized = _normalizeTranspose(semitones);
    emit(state.copyWith(transposeStep: normalized));
    _midiEngine.setTranspose(normalized);
  }

  int _normalizeTranspose(int semitones) {
    if (semitones < -11 || semitones > 11) return 0;
    return semitones;
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
    setTranspose(state.transposeStep + 1);
  }

  void transposeDown() {
    setTranspose(state.transposeStep - 1);
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
      final song = state.songs[state.pageIndex];
      await _loadPdfForSong(song, forceMetadataWarmup: true);
      await _loadMidiForSong(song, force: true);
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
    _debouncer?.cancel();
    _debouncer = null;
    final wasPlaying = state.isAudioPlaying;
    final song = state.songs[index];
    log(
      'changePage: ${song.code} ${song.number} (index=$index, wasPlaying=$wasPlaying)',
      name: 'SongCubit',
    );
    _resolvedChordsCache = null;
    final reset = _currentPlaybackDefaults().resetForSong();

    emit(
      state.copyWith(
        pageIndex: index,
        verseIndex: verseIndex,
        isAudioPlaying: false,
        isPdfLoading: false,
        showChord: _isChordEnabledForBook(song.code ?? state.bookCode)
            ? state.showChord
            : false,
        // Don't clear currentPdfPath yet, let it stay for smooth transition
        // currentPdfPath: null,
        currentChords: {},
        transposeStep: reset.transposeStep,
        tempoBpm: reset.tempoBpm,
        defaultTempoBpm: reset.defaultTempoBpm,
        originalPdfKey: reset.originalPdfKey,
        originalFamilyChord: reset.originalFamilyChord,
        baseTransposeOffset: reset.baseTransposeOffset,
      ),
    );
    // Trigger resources and chords in parallel
    unawaited(
      _loadResourcesForSong(song, autoplay: wasPlaying, forceMidi: true),
    );
    unawaited(_resolveChordBaselineForCurrentSong(song));
    unawaited(_warmUpPlaybackQueue());
  }

  Future<void> _resolveChordBaselineForCurrentSong(Song song) async {
    final reset = await _resolvePreloadDefaultsForSong(song);
    final preloadedChords = _resolvedChordsCache;
    _resolvedChordsCache = null;
    if (isClosed || !_isCurrentSong(song)) return;

    if (preloadedChords != null) {
      emit(
        state.copyWith(
          currentChords: preloadedChords,
          transposeStep: reset.transposeStep,
          tempoBpm: reset.tempoBpm,
          defaultTempoBpm: reset.defaultTempoBpm,
          originalPdfKey: reset.originalPdfKey,
          originalFamilyChord: reset.originalFamilyChord,
          baseTransposeOffset: reset.baseTransposeOffset,
        ),
      );
      return;
    }

    unawaited(_loadChordDataInternal(song));
  }

  bool _isCurrentSong(Song song) {
    if (isClosed) return false;
    if (state.songs.isEmpty) return false;
    final currentIdx = state.pageIndex.clamp(0, state.songs.length - 1);
    final currentSong = state.songs[currentIdx];
    return currentSong.code == song.code && currentSong.number == song.number;
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

  Future<void> _loadChordDataInternal(Song song) async {
    final chordPath = await _assetService.getChordPath(
      song.code ?? '',
      song.number ?? '',
    );

    if (isClosed) return;

    // Check if the current song is still the same as the one we loaded chords for
    final currentIdx = state.pageIndex.clamp(0, state.songs.length - 1);
    final currentSong = state.songs[currentIdx];
    if (currentSong.code != song.code || currentSong.number != song.number) {
      return;
    }

    if (chordPath == null) {
      emit(
        state.copyWith(
          currentChords: {},
          originalFamilyChord: null,
          // DONT clear originalPdfKey here, as it might have been detected from the PDF
          baseTransposeOffset: 0,
        ),
      );
      return;
    }

    try {
      final jsonString = await rootBundle.loadString(chordPath);
      final chords = ChordService.parseChordJson(jsonString);

      if (isClosed) return;
      if (state
              .songs[state.pageIndex.clamp(0, state.songs.length - 1)]
              .number !=
          song.number) {
        return;
      }

      final familyChord = ChordService.detectFamilyChord(chords);
      final baseline = _currentPlaybackDefaults().resolveChordBaseline(
        familyChord: familyChord,
        pdfKey: state.originalPdfKey,
        preferNaturalChords: state.preferNaturalChords,
      );

      final previousTranspose = state.transposeStep;
      emit(
        state.copyWith(
          currentChords: chords,
          originalFamilyChord: baseline.originalFamilyChord,
          baseTransposeOffset: baseline.baseTransposeOffset,
          transposeStep: baseline.transposeStep,
        ),
      );

      if (baseline.transposeStep != previousTranspose) {
        _midiEngine.setTranspose(baseline.transposeStep);
      }
    } catch (e) {
      log('Error loading chord data: $e', name: 'SongCubit');
      emit(state.copyWith(currentChords: {}));
    }
  }

  /// Internal data fetcher (legacy/manual use)
  Future<Map<int, List<ChordData>>?> loadChordData(Song song) async {
    final chordPath = await _assetService.getChordPath(
      song.code ?? '',
      song.number ?? '',
    );
    if (chordPath == null) return null;
    try {
      final jsonString = await rootBundle.loadString(chordPath);
      return ChordService.parseChordJson(jsonString);
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
    final accidentalMode = ChordService.preferredAccidentalModeForKey(
      pdfKey,
      fallback: state.chordAccidentalMode,
    );
    final previousTranspose = state.transposeStep;
    emit(
      state.copyWith(
        originalPdfKey: baseline.originalPdfKey,
        chordAccidentalMode: accidentalMode,
        baseTransposeOffset: baseline.baseTransposeOffset,
        transposeStep: baseline.transposeStep,
      ),
    );
    if (baseline.transposeStep != previousTranspose) {
      _midiEngine.setTranspose(baseline.transposeStep);
    }
  }

  void updatePdfTempo(double tempoBpm) {
    if (tempoBpm <= 0) return;
    if (tempoBpm == state.defaultTempoBpm) return;

    log('Applying detected PDF Tempo: $tempoBpm', name: 'SongCubit');

    emit(state.copyWith(tempoBpm: tempoBpm, defaultTempoBpm: tempoBpm));

    // Debounce the engine update slightly
    final expectedPdfLoadGeneration = _pdfLoadGeneration;
    _debouncer?.cancel();
    _debouncer = Timer(const Duration(milliseconds: 100), () {
      if (!isClosed && expectedPdfLoadGeneration == _pdfLoadGeneration) {
        _midiEngine.setTempoBase(tempoBpm); // Use setTempoBase to sync with PDF
      }
    });
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
        currentChords: chords,
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
    // Still call changePage to load resources.
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

  ({String bookCode, String number}) _metadataSourceForSong(Song song) {
    return (bookCode: song.code ?? state.bookCode, number: song.number ?? '');
  }

  bool _isChordEnabledForBook(String? bookCode) => bookCode != 'HYMNE';

  Future<String?> _detectFamilyChordForSong(Song song) async {
    if (!state.preferNaturalChords) {
      _resolvedChordsCache = null;
      return null;
    }
    final chordPath = await _assetService.getChordPath(
      song.code ?? '',
      song.number ?? '',
    );
    if (chordPath == null) {
      _resolvedChordsCache = null;
      return null;
    }
    try {
      final jsonString = await rootBundle.loadString(chordPath);
      final chords = ChordService.parseChordJson(jsonString);
      // Cache the parsed chords so _loadChordDataInternal doesn't have to re-parse them
      _resolvedChordsCache = chords;
      return ChordService.detectFamilyChord(chords);
    } catch (e) {
      log('Error detecting family chord for preload: $e');
      _resolvedChordsCache = null;
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
        showChord: _isChordEnabledForBook(bookCode) ? state.showChord : false,
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
          isPdfLoading: false,
          currentPdfPath:
              null, // Still clear this as it depends on absolute disk paths
          isLoading: false,
          selectedSong: null,
          isAudioPlaying: false,
        )
        .toJson();
  }

  Future<String?> getPdfPath(String bookCode, String number) async {
    return _assetService.getPdfPath(bookCode, number);
  }

  Future<void> releaseResourcesForMaintenance() async {
    _pdfLoadGeneration++;
    _midiLoadGeneration++;
    _handlingAutoNext = false;
    _resolvedChordsCache = null;
    await stop();
    PdfNoteService().clearCache();
    emit(
      state.copyWith(
        currentPdfPath: null,
        currentChords: const {},
        isAudioLoading: false,
        isPdfLoading: false,
        isAudioPlaying: false,
      ),
    );
  }

  Future<void> prepareForAppReset() async {
    await releaseResourcesForMaintenance();
  }

  Future<void> resetToDefaults() async {
    emit(const SongState());
    await _midiEngine.changeSoundFont(state.soundFont);
    _midiEngine.setCacheMax(state.midiCacheMaxCount);
    await getData(preloadCurrentSong: false);
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

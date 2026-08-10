import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../data/services/chord_service.dart';
import '../../../data/services/chord_sync_service.dart';
import '../../../data/services/local_asset_service.dart';
import '../../../data/services/midi_engine_service.dart';
import '../../../data/services/pdf_note_service.dart';
import '../../../di/injection.dart';
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

  /// Browsing context is intentionally transient. It answers a different
  /// question from autoplay mode: "where did the user open this hymn from?"
  /// null means the normal hymn book/library; otherwise it is the playlist
  /// whose ordered neighbours should be used for preload and manual next/prev.
  String? _navigationPlaylistId;

  bool get isNavigatingPlaylist => _navigationPlaylistId != null;

  void toggleWarmUp([bool? value]) {
    final newValue = value ?? !state.midiPreloadEnabled;
    emit(state.copyWith(midiPreloadEnabled: newValue));
    if (newValue) {
      unawaited(_warmUpPlaybackQueue());
    }
  }

  Future<void> _warmUpPlaybackQueue() async {
    try {
      if (!state.midiPreloadEnabled || state.songs.isEmpty) return;
      final count = state.midiPreloadNeighborCount.clamp(0, 5).toInt();
      final queue = _navigationQueue();
      final preloadSongs = queue.preloadSongs(count: count);
      if (preloadSongs.isEmpty) return;

      log(
        'Adaptive warm-up: ${preloadSongs.length} neighbours '
        '(${_navigationPlaylistId == null ? 'library' : 'playlist'})',
        name: 'SongCubit',
      );

      // MIDI rendering and PDF preparation are independent. Run the chains in
      // parallel so a slow PDF extraction never delays an already-cached MIDI,
      // and vice versa.
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
        log('MIDI warm-up failed for ${song.number}: $e', name: 'SongCubit');
      }
    }
  }

  Future<void> _warmUpPdfChain(List<Song> songs) async {
    final noteService = PdfNoteService();
    // File preparation for neighbours can happen concurrently. Keep the set
    // small (maximum five on either side is already enforced in state) so this
    // does not become unbounded I/O.
    await Future.wait(
      songs.map((song) async {
        try {
          final pdfPath = await getPdfPath(song.code ?? '', song.number ?? '');
          if (pdfPath == null) return;
          final request = PdfDocumentRequest.parse(pdfPath);
          await noteService.warmup(
            request.assetPath,
            startPage: request.startPage,
            pageCount: _warmupPageCount(request.pageCount),
          );
        } catch (e) {
          log('PDF warm-up failed for ${song.number}: $e', name: 'SongCubit');
        }
      }),
    );
  }

  StreamSubscription<MidiPlaybackState>? _midiStateSub;
  Timer? _debouncer;
  MidiPlaybackState _lastMidiState = const MidiPlaybackState();
  bool _handlingAutoNext = false;
  int _midiLoadGeneration = 0;
  int _pdfLoadGeneration = 0;

  SongCubit(this.songRepository, this._assetService, this._midiEngine)
    : super(
        const SongState(
          lyricsTextAlign: 'center',
          lyricsVerticalAlign: 'center',
        ),
      ) {
    _setupMidiStreams();
    _initializeAsync();
  }

  Map<int, List<ChordData>>? _resolvedChordsCache;

  Future<void> _initializeAsync() async {
    unawaited(_assetService.initialize());

    if (state.songs.isNotEmpty) {
      final currentIdx = state.pageIndex.clamp(0, state.songs.length - 1).toInt();
      final currentSong = state.songs[currentIdx];
      log('Startup immediate load: ${currentSong.number}', name: 'SongCubit');
      _resolvedChordsCache = null;

      unawaited(
        _assetService
            .getPdfPath(currentSong.code ?? '', currentSong.number ?? '')
            .then((path) {
              if (path != null && !isClosed) {
                final request = PdfDocumentRequest.parse(path);
                final singlePage = request.pageCount != null && request.pageCount! <= 1;
                emit(
                  state.copyWith(
                    currentPdfPath: path,
                    isPdfLoading: false,
                    pdfTwoPageMode: singlePage ? false : state.pdfTwoPageMode,
                    pdfVerticalScrolling:
                        singlePage ? false : state.pdfVerticalScrolling,
                  ),
                );

                unawaited(
                  () async {
                    final metadataSource = _metadataSourceForSong(currentSong);
                    final metadataPdfPath = await _assetService.getPdfPath(
                      metadataSource.bookCode,
                      metadataSource.number,
                    );
                    final metadataRequest = PdfDocumentRequest.parse(
                      metadataPdfPath ?? path,
                    );
                    return PdfNoteService().warmup(
                      metadataRequest.assetPath,
                      startPage: metadataRequest.startPage,
                      pageCount: _warmupPageCount(metadataRequest.pageCount),
                    );
                  }().then((metadata) {
                    if (metadata == null || isClosed) return;
                    if (metadata.detectedKey != null) updatePdfKey(metadata.detectedKey);
                    if (metadata.detectedTempo != null) {
                      updatePdfTempo(metadata.detectedTempo!);
                    }
                  }),
                );
              }
            }),
      );

      unawaited(_loadChordDataInternal(currentSong));
      unawaited(_loadPdfForSong(currentSong));
    }

    final dataFuture = getData();
    if (state.showAudio) {
      await Future.wait([dataFuture, _midiEngine.initialize()]);
    } else {
      await dataFuture;
    }

    _midiEngine.setSoundFont(state.soundFont);
    _midiEngine.setCacheMax(state.midiCacheMaxCount);

    if (state.showAudio && state.songs.isNotEmpty) {
      final currentIdx = state.pageIndex.clamp(0, state.songs.length - 1).toInt();
      final currentSong = state.songs[currentIdx];
      final midiPath = await _midiPathForSong(currentSong);
      if (midiPath != null) {
        final defaults = await _resolvePreloadDefaultsForSong(currentSong);
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

    // Start neighbour warming shortly after the first real frame rather than
    // waiting three seconds, which left an obvious loading gap when a user
    // immediately swiped to the next hymn.
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!isClosed) unawaited(_warmUpPlaybackQueue());
    });

    unawaited(_syncChordsFromGithub());
  }

  Future<void> _syncChordsFromGithub() async {
    try {
      final service = di<ChordSyncService>();
      final result = await service.sync();
      log('Chord sync finished: $result', name: 'SongCubit');
      if (result.changed && !isClosed && state.songs.isNotEmpty) {
        final currentIdx = state.pageIndex.clamp(0, state.songs.length - 1).toInt();
        final currentSong = state.songs[currentIdx];
        final hasChord = await _assetService.hasChord(
          currentSong.code ?? '',
          currentSong.number ?? '',
        );
        if (hasChord && !isClosed) {
          unawaited(_loadChordDataInternal(currentSong));
          unawaited(_resolveChordBaselineForCurrentSong(currentSong));
        }
      }
    } catch (e, st) {
      log('Chord sync failed: $e', name: 'SongCubit', error: e, stackTrace: st);
    }
  }

  void _setupMidiStreams() {
    _midiStateSub = _midiEngine.stateStream.listen((midiState) {
      final ended = _didMidiEnd(_lastMidiState, midiState);
      _lastMidiState = midiState;
      if (midiState.isPlaying != state.isAudioPlaying) {
        emit(state.copyWith(isAudioPlaying: midiState.isPlaying));
      }
      if (midiState.isLoading != state.isAudioLoading) {
        emit(state.copyWith(isAudioLoading: midiState.isLoading));
      }
      if (ended) unawaited(_handleMidiSongEnded());
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
          final currentIdx = state.pageIndex.clamp(0, state.songs.length - 1).toInt();
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

  Future<void> _loadResourcesForSong(
    Song song, {
    bool autoplay = false,
    bool forceMidi = false,
  }) async {
    await Future.wait([
      _loadPdfForSong(song, forceMetadataWarmup: true),
      _loadMidiForSong(song, autoplay: autoplay, force: forceMidi),
    ]);
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

    String? pdfPath;
    try {
      pdfPath = await getPdfPath(songCode, songNumber);
      if (!_isActivePdfLoad(generation)) return;

      final pathUnchanged = pdfPath == previousPath;
      var singlePage = false;
      if (pdfPath != null) {
        try {
          final request = PdfDocumentRequest.parse(pdfPath);
          singlePage = request.pageCount != null && request.pageCount! <= 1;
        } catch (_) {}
      }

      emit(
        state.copyWith(
          isPdfLoading: needsPreparation,
          currentPdfPath: pdfPath,
          // A one-page hymn cannot meaningfully inherit the previous hymn's
          // spread/vertical mode. Return it to the canonical single-page mode.
          pdfTwoPageMode: singlePage ? false : state.pdfTwoPageMode,
          pdfVerticalScrolling: singlePage ? false : state.pdfVerticalScrolling,
        ),
      );

      if (pdfPath != null && (forceMetadataWarmup || !pathUnchanged)) {
        unawaited(_warmupPdfMetadata(song, pdfPath));
      }
    } finally {
      if (_isActivePdfLoad(generation)) {
        emit(state.copyWith(isPdfLoading: false));
      }
    }
  }

  Future<void> _warmupPdfMetadata(Song song, String pdfPath) async {
    final noteService = PdfNoteService();
    final metadataSource = _metadataSourceForSong(song);
    final metadataPdfPath = await getPdfPath(
      metadataSource.bookCode,
      metadataSource.number,
    );
    final request = PdfDocumentRequest.parse(metadataPdfPath ?? pdfPath);
    final warmupPages = _warmupPageCount(request.pageCount);

    try {
      final metadata = await noteService
          .warmup(
            request.assetPath,
            startPage: request.startPage,
            pageCount: warmupPages,
          )
          .timeout(const Duration(milliseconds: 450));
      if (metadata != null && !isClosed) {
        if (metadata.detectedKey != null) updatePdfKey(metadata.detectedKey);
        if (metadata.detectedTempo != null) updatePdfTempo(metadata.detectedTempo!);
      }
    } on TimeoutException {
      log('Note warm-up timeout for ${song.number}', name: 'SongCubit');
    } catch (e) {
      log('Note warm-up failed for ${song.number}: $e', name: 'SongCubit');
    }
  }

  int _warmupPageCount(int? pageCount) {
    final target = pageCount ?? 2;
    if (target < 1) return 1;
    if (target > 2) return 2;
    return target;
  }

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
    final defaults = await _resolvePreloadDefaultsForSong(song);
    if (!_isActiveMidiLoad(generation)) return;
    await _midiEngine.loadMidi(
      midiPath,
      transpose: defaults.transposeStep,
      tempoBpm: defaults.tempoBpm,
      baseTempoBpm: defaults.defaultTempoBpm,
      instrument: state.midiInstrument,
      autoplay: autoplay,
    );
    if (!_isActiveMidiLoad(generation)) return;
    emit(state.copyWith(isAudioLoading: false));
  }

  bool _isActiveMidiLoad(int loadGeneration) =>
      !isClosed && loadGeneration == _midiLoadGeneration;

  bool _isActivePdfLoad(int loadGeneration) =>
      !isClosed && loadGeneration == _pdfLoadGeneration;

  Future<void> play() async {
    if (!state.showAudio) emit(state.copyWith(showAudio: true));
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

  void toggleAudio([bool? show]) {
    final newValue = show ?? !state.showAudio;
    emit(state.copyWith(showAudio: newValue));

    if (newValue && state.songs.isNotEmpty) {
      final song = state.songs[state.pageIndex];
      unawaited(
        _loadPdfForSong(song, forceMetadataWarmup: true)
            .then((_) => _loadMidiForSong(song))
            .then((_) => _warmUpPlaybackQueue()),
      );
    } else {
      _midiLoadGeneration++;
      unawaited(_midiEngine.stop());
    }
  }

  void toggleChord([bool? show]) {
    if (!_isChordEnabledForBook(state.bookCode)) {
      if (state.showChord) emit(state.copyWith(showChord: false));
      return;
    }
    emit(state.copyWith(showChord: show ?? !state.showChord));
  }

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

  void transposeUp() => setTranspose(state.transposeStep + 1);
  void transposeDown() => setTranspose(state.transposeStep - 1);

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

  void toggleAccidentalMode() {
    final newMode = state.chordAccidentalMode == ChordService.accidentalSharp
        ? ChordService.accidentalFlat
        : ChordService.accidentalSharp;
    emit(state.copyWith(chordAccidentalMode: newMode));
  }

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

  void setMidiPreloadNeighborCount(int count) {
    final clamped = count.clamp(0, 5).toInt();
    emit(state.copyWith(midiPreloadNeighborCount: clamped));
    unawaited(_warmUpPlaybackQueue());
  }

  void setMidiCacheMaxCount(int count) {
    final clamped = count.clamp(4, 32).toInt();
    emit(state.copyWith(midiCacheMaxCount: clamped));
    _midiEngine.setCacheMax(clamped);
  }

  Future<void> changePage(int index, int verseIndex) async {
    if (index < 0 || index >= state.songs.length) return;
    _debouncer?.cancel();
    _debouncer = null;
    final wasPlaying = state.isAudioPlaying;
    final song = state.songs[index];
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
        currentChords: {},
        transposeStep: reset.transposeStep,
        tempoBpm: reset.tempoBpm,
        defaultTempoBpm: reset.defaultTempoBpm,
        originalPdfKey: reset.originalPdfKey,
        originalFamilyChord: reset.originalFamilyChord,
        baseTransposeOffset: reset.baseTransposeOffset,
      ),
    );
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
    if (isClosed || state.songs.isEmpty) return false;
    final currentIdx = state.pageIndex.clamp(0, state.songs.length - 1).toInt();
    final currentSong = state.songs[currentIdx];
    return currentSong.code == song.code && currentSong.number == song.number;
  }

  Future<void> goToPreviousSong() async {
    final song = _navigationQueue().manualPreviousSong;
    if (song != null) await _openSong(song, autoplay: state.isAudioPlaying);
  }

  Future<void> goToNextSong() async {
    final song = _navigationQueue().manualNextSong;
    if (song != null) await _openSong(song, autoplay: state.isAudioPlaying);
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

  void setNormalPdfMode() {
    if (!state.pdfTwoPageMode && !state.pdfVerticalScrolling) return;
    emit(state.copyWith(pdfTwoPageMode: false, pdfVerticalScrolling: false));
  }

  Future<void> _loadChordDataInternal(Song song) async {
    final jsonString = await _assetService.readChordJson(
      song.code ?? '',
      song.number ?? '',
    );
    if (isClosed) return;
    final currentIdx = state.pageIndex.clamp(0, state.songs.length - 1).toInt();
    final currentSong = state.songs[currentIdx];
    if (currentSong.code != song.code || currentSong.number != song.number) return;

    if (jsonString == null) {
      emit(
        state.copyWith(
          currentChords: {},
          originalFamilyChord: null,
          baseTransposeOffset: 0,
        ),
      );
      return;
    }

    try {
      final chords = ChordService.parseChordJson(jsonString);
      if (isClosed) return;
      if (state.songs[
            state.pageIndex.clamp(0, state.songs.length - 1).toInt()
          ].number !=
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

  Future<Map<int, List<ChordData>>?> loadChordData(Song song) async {
    final jsonString = await _assetService.readChordJson(
      song.code ?? '',
      song.number ?? '',
    );
    if (jsonString == null) return null;
    try {
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
    if (tempoBpm <= 0 || tempoBpm == state.defaultTempoBpm) return;
    emit(state.copyWith(tempoBpm: tempoBpm, defaultTempoBpm: tempoBpm));
    final expectedPdfLoadGeneration = _pdfLoadGeneration;
    _debouncer?.cancel();
    _debouncer = Timer(const Duration(milliseconds: 100), () {
      if (!isClosed && expectedPdfLoadGeneration == _pdfLoadGeneration) {
        _midiEngine.setTempoBase(tempoBpm);
      }
    });
  }

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

  SongPlaybackDefaults _currentPlaybackDefaults() => SongPlaybackDefaults(
    transposeStep: state.transposeStep,
    tempoBpm: state.tempoBpm,
    defaultTempoBpm: state.defaultTempoBpm,
    originalFamilyChord: state.originalFamilyChord,
    originalPdfKey: state.originalPdfKey,
    baseTransposeOffset: state.baseTransposeOffset,
  );

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

  SongPlaybackQueue _navigationQueue() {
    final currentSong =
        state.pageIndex >= 0 && state.pageIndex < state.songs.length
        ? state.songs[state.pageIndex]
        : null;
    final playlistId = _navigationPlaylistId;
    return SongPlaybackQueue.resolve(
      books: state.songBook,
      currentSongs: state.songs,
      currentSong: currentSong,
      playlists: state.playlists,
      activePlaylistId: playlistId,
      autoNextMode: playlistId == null
          ? SongPlaylistAutoNextMode.off
          : SongPlaylistAutoNextMode.playlist,
      shuffleIndex: const [],
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

  Future<void> openSong(Song song, {bool autoplay = false}) =>
      _openSong(song, autoplay: autoplay);

  Future<void> openSongFromLibrary(Song song, {bool autoplay = false}) async {
    _navigationPlaylistId = null;
    await _openSong(song, autoplay: autoplay);
    unawaited(_warmUpPlaybackQueue());
  }

  Future<void> openSongFromPlaylist(
    Song song,
    String playlistId, {
    bool autoplay = false,
  }) async {
    _navigationPlaylistId = playlistId;
    if (state.activePlaylistId != playlistId) {
      emit(state.copyWith(activePlaylistId: playlistId));
    }
    await _openSong(song, autoplay: autoplay);
    unawaited(_warmUpPlaybackQueue());
  }

  void useLibraryNavigationContext() {
    _navigationPlaylistId = null;
    unawaited(_warmUpPlaybackQueue());
  }

  Future<void> usePlaylistNavigationContext([String? playlistId]) async {
    final targetId = playlistId ?? state.activePlaylistId;
    if (targetId == null) return;
    _navigationPlaylistId = targetId;
    final playlist = state.playlists.firstWhereOrNull((p) => p.id == targetId);
    if (playlist == null || playlist.songs.isEmpty) return;

    final currentSong = state.songs.isEmpty
        ? null
        : state.songs[
            state.pageIndex.clamp(0, state.songs.length - 1).toInt()
          ];
    final currentInPlaylist = currentSong != null &&
        playlist.songs.any((item) => item.matches(currentSong));
    if (!currentInPlaylist) {
      final first = _resolvePlaylistItem(playlist.songs.first);
      if (first != null) await openSongFromPlaylist(first, targetId);
    } else {
      unawaited(_warmUpPlaybackQueue());
    }
  }

  Song? _resolvePlaylistItem(SongPlaylistItem item) {
    for (final book in state.songBook) {
      for (final song in book.songs) {
        if (item.matches(song)) return song;
      }
    }
    return null;
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
    addToHistory(
      SongHistory(index: index, bookCode: bookCode, createdAt: DateTime.now()),
    );
    emit(state.copyWith(bookCode: bookCode, pageIndex: index));
    await changePage(index, 0);
    if (autoplay) await play();
  }

  Future<SongPlaybackDefaults> _resolvePreloadDefaultsForSong(Song song) async {
    final currentSong =
        state.pageIndex >= 0 && state.pageIndex < state.songs.length
        ? state.songs[state.pageIndex]
        : null;
    final songMatchesCurrent = currentSong != null &&
        currentSong.code == song.code &&
        currentSong.number == song.number;
    final familyChord = await _detectFamilyChordForSong(song);
    final base = _currentPlaybackDefaults().resetForSong();
    if (!state.preferNaturalChords) return base;
    return base.resolveChordBaseline(
      familyChord: familyChord,
      pdfKey: songMatchesCurrent ? state.originalPdfKey : null,
      preferNaturalChords: true,
    );
  }

  ({String bookCode, String number}) _metadataSourceForSong(Song song) =>
      (bookCode: song.code ?? state.bookCode, number: song.number ?? '');

  bool _isChordEnabledForBook(String? bookCode) => bookCode != 'HYMNE';

  Future<String?> _detectFamilyChordForSong(Song song) async {
    if (!state.preferNaturalChords) {
      _resolvedChordsCache = null;
      return null;
    }
    final jsonString = await _assetService.readChordJson(
      song.code ?? '',
      song.number ?? '',
    );
    if (jsonString == null) {
      _resolvedChordsCache = null;
      return null;
    }
    try {
      final chords = ChordService.parseChordJson(jsonString);
      _resolvedChordsCache = chords;
      return ChordService.detectFamilyChord(chords);
    } catch (e) {
      _resolvedChordsCache = null;
      return null;
    }
  }

  void reloadChordsForCurrentSong() {
    if (state.songs.isEmpty) return;
    final idx = state.pageIndex.clamp(0, state.songs.length - 1).toInt();
    final song = state.songs[idx];
    unawaited(_loadChordDataInternal(song));
    unawaited(_resolveChordBaselineForCurrentSong(song));
  }

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
    if (_navigationPlaylistId == playlistId) _navigationPlaylistId = null;
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
    _navigationPlaylistId = playlistId;
    emit(
      state.copyWith(
        activePlaylistId: playlistId,
        playlistAutoNextMode: playlistId == null ? currentMode : nextMode,
      ),
    );
    _refreshPlaylistShuffleIfNeeded();
    if (playlistId != null) {
      unawaited(usePlaylistNavigationContext(playlistId));
    } else {
      unawaited(_warmUpPlaybackQueue());
    }
  }

  void setPlaylistAutoNextMode(String mode) {
    final normalized = SongPlaylistAutoNextMode.normalize(mode);
    emit(state.copyWith(playlistAutoNextMode: normalized));
    if (normalized == SongPlaylistAutoNextMode.playlist ||
        normalized == SongPlaylistAutoNextMode.shufflePlaylist) {
      _navigationPlaylistId = state.activePlaylistId;
    }
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

  void toggleShuffle() {
    final current = SongPlaylistAutoNextMode.normalize(state.playlistAutoNextMode);
    final hasUsablePlaylist = activePlaylist?.songs.isNotEmpty ?? false;
    final isShuffleOn = current == SongPlaylistAutoNextMode.shuffleAll ||
        current == SongPlaylistAutoNextMode.shufflePlaylist;
    final nextMode = isShuffleOn
        ? SongPlaylistAutoNextMode.off
        : (hasUsablePlaylist
              ? SongPlaylistAutoNextMode.shufflePlaylist
              : SongPlaylistAutoNextMode.shuffleAll);
    setPlaylistAutoNextMode(nextMode);
  }

  void addSongToActivePlaylist(Song song) {
    if (state.playlists.isEmpty) createPlaylist('Playlist');
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
              songIndex < 0 || songIndex >= playlist.songs.length) {
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

  bool isSongInActivePlaylist(Song song) =>
      activePlaylist?.songs.any((item) => item.matches(song)) ?? false;

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
      emit(state.copyWith(shuffleIndex: getRandomUniqueIndex(state.songs.length)));
    }
  }

  void changeBookcode(String bookCode) {
    _navigationPlaylistId = null;
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
        pageIndex: 0,
        verseIndex: 0,
        currentPdfPath: null,
        currentChords: {},
        isPdfLoading: false,
        showChord: _isChordEnabledForBook(bookCode) ? state.showChord : false,
        shuffleIndex: getRandomUniqueIndex(songCount),
      ),
    );
    unawaited(_warmUpPlaybackQueue());
  }

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

  void changeSortNote(String sortBy) {
    emit(state.copyWith(sortNotesBy: sortBy));
  }

  void saveNote(SongNote data) {
    var notes = List<SongNote>.from(state.notes);
    final index = notes.indexWhere((note) => note.id == data.id);
    if (index != -1) {
      notes[index] = data;
    } else {
      notes.add(data);
    }
    emit(state.copyWith(notes: notes));
  }

  Future<void> deleteNote(SongNote data) async {
    final notes = List<SongNote>.from(state.notes)..remove(data);
    emit(state.copyWith(notes: notes));
  }

  Future<void> removeSelection() async {
    emit(state.copyWith(selectedSong: null));
  }

  void selectSong(Song song) {
    emit(state.copyWith(selectedSong: song));
  }

  void onSearchTermsChanged(String text) {
    emit(state.copyWith(searchTerms: text));
  }

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
    emit(state.copyWith(chordFontSizePercent: value.clamp(50, 200).toInt()));
  }

  void changeChordFillOpacityPercent(int value) {
    emit(state.copyWith(chordFillOpacityPercent: value.clamp(0, 100).toInt()));
  }

  void changeChordPaddingPercent(int value) {
    emit(state.copyWith(chordPaddingPercent: value.clamp(0, 400).toInt()));
  }

  void changeChordOffsetPercent(int value) {
    emit(state.copyWith(chordOffsetPercent: value.clamp(0, 300).toInt()));
  }

  void changeMode() {
    emit(state.copyWith(isImageMode: !state.isImageMode));
  }

  @override
  SongState? fromJson(Map<String, dynamic> json) {
    var restored = SongState.fromJson(json);
    final layoutVersion = (json['lyrics_layout_version'] as num?)?.toInt() ?? 0;
    if (layoutVersion < 2 &&
        restored.lyricsTextAlign == 'left' &&
        restored.lyricsVerticalAlign == 'top') {
      restored = restored.copyWith(
        lyricsTextAlign: 'center',
        lyricsVerticalAlign: 'center',
      );
    }
    return _clearTransientSelection(restored);
  }

  @override
  Map<String, dynamic>? toJson(SongState state) {
    final json = state
        .copyWith(
          isAudioLoading: false,
          isPdfLoading: false,
          currentPdfPath: null,
          isLoading: false,
          selectedSong: null,
          isAudioPlaying: false,
        )
        .toJson()
      ..remove('songBook');
    json['lyrics_layout_version'] = 2;
    return json;
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
    _navigationPlaylistId = null;
    emit(
      const SongState(
        lyricsTextAlign: 'center',
        lyricsVerticalAlign: 'center',
      ),
    );
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
  final random = math.Random();
  final indices = List.generate(length, (index) => index);
  for (var i = length - 1; i > 0; i--) {
    final randomIndex = random.nextInt(i + 1);
    final temp = indices[randomIndex];
    indices[randomIndex] = indices[i];
    indices[i] = temp;
  }
  return indices;
}
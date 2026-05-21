import 'dart:async';

import 'package:church/data/services/chord_service.dart';
import 'package:church/data/services/local_asset_service.dart';
import 'package:church/data/services/midi_engine_service.dart';
import 'package:church/data/services/pdf_chunk_service.dart';

import 'package:church/data/utilities/variables/failure.dart';
import 'package:church/domain/entity/song/song_entity.dart';
import 'package:church/domain/repository/song_repository.dart';
import 'package:church/presentations/song/cubit/song_cubit.dart';
import 'package:church/presentations/song/cubit/song_playlist.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    HydratedBloc.storage = _MemoryStorage();
  });

  test('restored song state clears transient selected song', () async {
    final cubit = SongCubit(
      _FakeSongRepository(),
      _FakeAssetService(),
      _FakeMidiEngine(),
    );
    await _flushAsync();

    final restored = cubit.fromJson({
      'selectedSong': {'code': 'KR', 'number': '001', 'lyric': 'One'},
    });

    expect(restored?.selectedSong, isNull);
    expect(cubit.isSelectingSong, isFalse);

    await cubit.close();
  });

  test('synced song state clears transient selected song', () async {
    final cubit = SongCubit(
      _FakeSongRepository(),
      _FakeAssetService(),
      _FakeMidiEngine(),
    );
    await _flushAsync();

    cubit.sync(
      const SongState(
        selectedSong: Song(code: 'KR', number: '001', title: 'One'),
      ),
    );

    expect(cubit.state.selectedSong, isNull);
    expect(cubit.isSelectingSong, isFalse);

    await cubit.close();
  });

  test('does not warm up native midi before audio is requested', () async {
    final engine = _FakeMidiEngine();
    final cubit = SongCubit(_FakeSongRepository(), _FakeAssetService(), engine);
    await _flushAsync();

    expect(engine.events, isNot(contains('cache:12')));
    expect(engine.events.where((event) => event.startsWith('load:')), isEmpty);
    expect(engine.events.where((event) => event.startsWith('warm:')), isEmpty);

    await cubit.close();
  });

  test('loads the initial PDF after song data arrives', () async {
    final assetService = _FakeAssetService(
      pdfPath: 'assets/data/pdf/kr/001.pdf',
    );
    final cubit = SongCubit(
      _FakeSongRepository(),
      assetService,
      _FakeMidiEngine(),
    );
    await _flushAsync();
    await _flushAsync();

    expect(cubit.state.currentPdfPath, 'assets/data/pdf/kr/001.pdf');
    expect(cubit.state.isPdfLoading, isFalse);
    expect(assetService.pdfRequests, contains('KR:001'));

    await cubit.close();
  });

  test(
    'page change starts PDF loading before slow chord preload finishes',
    () async {
      final assetService = _FakeAssetService(
        pdfPath: 'assets/data/pdf/kr/002.pdf',
        chordPath:
            'assets/data/chord/kr/001_Pujilah Allah Yang Maha Esa.chord.json',
      );
      assetService.blockChordPathFor = 'KR:002';
      final cubit = SongCubit(
        _FakeSongRepository(),
        assetService,
        _FakeMidiEngine(),
      );
      await _flushAsync();
      await _flushAsync();

      final changeFuture = cubit.changePage(1, 0);
      await _flushAsync();

      expect(assetService.pdfRequests, contains('KR:002'));
      expect(cubit.state.pageIndex, 1);
      expect(cubit.state.currentPdfPath, 'assets/data/pdf/kr/002.pdf');

      assetService.releaseChordPath('KR:002');
      await changeFuture;
      await cubit.close();
    },
  );

  test(
    'page change does not show PDF preparation loading when prep is already done',
    () async {
      final assetService = _FakeAssetService(
        pdfPath: 'assets/data/pdf/kr/002.pdf',
      );
      final cubit = SongCubit(
        _FakeSongRepository(),
        assetService,
        _FakeMidiEngine(),
      );
      await _flushAsync();
      await _flushAsync();

      final loadingStates = <bool>[];
      final subscription = cubit.stream
          .map((state) => state.isPdfLoading)
          .listen(loadingStates.add);

      await cubit.changePage(1, 0);
      await _flushAsync();

      expect(assetService.pdfRequests, contains('KR:002'));
      expect(loadingStates, isNot(contains(true)));

      await subscription.cancel();
      await cubit.close();
    },
  );

  test(
    'maintenance release clears active PDF path and loading flags',
    () async {
      final cubit = SongCubit(
        _FakeSongRepository(),
        _FakeAssetService(),
        _FakeMidiEngine(),
      );
      await _flushAsync();

      cubit.sync(
        const SongState(
          currentPdfPath: 'assets/data/pdf/kr/001.pdf',
          isPdfLoading: true,
          isAudioLoading: true,
          isAudioPlaying: true,
        ),
      );

      await cubit.releaseResourcesForMaintenance();

      expect(cubit.state.currentPdfPath, isNull);
      expect(cubit.state.isPdfLoading, isFalse);
      expect(cubit.state.isAudioLoading, isFalse);
      expect(cubit.state.isAudioPlaying, isFalse);

      await cubit.close();
    },
  );

  test('requests chord data using the active book code', () async {
    final assetService = _FakeAssetService(chordPath: null);
    final cubit = SongCubit(
      _FakeSongRepository(),
      assetService,
      _FakeMidiEngine(),
    );
    await _flushAsync();

    final chords = await cubit.loadChordData(
      const Song(code: 'HYMNE', number: '001', title: 'Pujilah Allah'),
    );

    expect(assetService.chordRequests, contains('HYMNE:001'));
    expect(chords, isNull);

    await cubit.close();
  });

  test(
    'page change loads the new midi without pre-rerendering old source',
    () async {
      final engine = _FakeMidiEngine();
      final cubit = SongCubit(
        _FakeSongRepository(),
        _FakeAssetService(),
        engine,
      );
      await _flushAsync();
      cubit.toggleAudio(true);
      await _flushAsync();
      engine.events.clear();

      await cubit.changePage(1, 0);
      await _flushAsync();

      expect(
        engine.events,
        contains(
          'load:assets/data/midi/kr/002.mid:t0:tempo76.0:base76.0:start0',
        ),
      );
      expect(engine.events, isNot(contains('setTranspose:0')));
      expect(engine.events, isNot(contains('setTempoBase:76.0')));

      await cubit.close();
    },
  );

  test('HYMNE PDF metadata warmup does not request KR fallback path', () async {
    final assetService = _FakeAssetService();
    final cubit = SongCubit(
      _FakeSongRepository(),
      assetService,
      _FakeMidiEngine(),
    );
    await _flushAsync();
    assetService.pdfRequests.clear();

    cubit.sync(
      const SongState(
        bookCode: 'HYMNE',
        songBook: [
          SongBook(
            code: 'HYMNE',
            songs: [Song(code: 'HYMNE', number: '001', title: 'Pujilah Allah')],
          ),
        ],
      ),
    );

    await cubit.changePage(0, 0);
    await _flushAsync();

    expect(assetService.pdfRequests, isNotEmpty);
    expect(assetService.pdfRequests.any((it) => it.startsWith('KR:')), isFalse);
    expect(
      assetService.pdfRequests.any((it) => it.startsWith('HYMNE:')),
      isTrue,
    );

    await cubit.close();
  });

  test(
    'cycleLoopMode follows gyschordweb order without playlist fallback',
    () async {
      final cubit = SongCubit(
        _FakeSongRepository(),
        _FakeAssetService(),
        _FakeMidiEngine(),
      );
      await _flushAsync();

      cubit.cycleLoopMode();
      expect(cubit.state.playlistAutoNextMode, SongPlaylistAutoNextMode.one);
      cubit.cycleLoopMode();
      expect(cubit.state.playlistAutoNextMode, SongPlaylistAutoNextMode.number);
      cubit.cycleLoopMode();
      expect(
        cubit.state.playlistAutoNextMode,
        SongPlaylistAutoNextMode.playlist,
      );
      cubit.cycleLoopMode();
      expect(
        cubit.state.playlistAutoNextMode,
        SongPlaylistAutoNextMode.shuffleAll,
      );
      cubit.cycleLoopMode();
      expect(cubit.state.playlistAutoNextMode, SongPlaylistAutoNextMode.off);

      await cubit.close();
    },
  );

  test(
    'preload warmup follows wrapped playback queue after audio opens',
    () async {
      final engine = _FakeMidiEngine();
      final cubit = SongCubit(
        _FakeSongRepository(),
        _FakeAssetService(),
        engine,
      );
      await _flushAsync();

      cubit.toggleAudio(true);
      await _flushAsync();
      engine.events.clear();

      cubit.setPlaylistAutoNextMode(SongPlaylistAutoNextMode.number);
      await _flushAsync();

      expect(
        engine.events,
        contains('warm:assets/data/midi/kr/002.mid:t0:tempo76.0:base76.0'),
      );
      expect(
        engine.events,
        contains('warm:assets/data/midi/kr/003.mid:t0:tempo76.0:base76.0'),
      );

      await cubit.close();
    },
  );

  test(
    'repeat-one restarts the current midi instead of loading next song',
    () async {
      final engine = _FakeMidiEngine();
      final cubit = SongCubit(
        _FakeSongRepository(),
        _FakeAssetService(),
        engine,
      );
      await _flushAsync();
      cubit.toggleAudio(true);
      await _flushAsync();
      cubit.setPlaylistAutoNextMode(SongPlaylistAutoNextMode.one);
      engine.events.clear();

      engine.emitPlayback(
        const MidiPlaybackState(isPlaying: true, position: 9.9, duration: 10),
      );
      await _flushAsync();
      engine.emitPlayback(
        const MidiPlaybackState(isPlaying: false, position: 10, duration: 10),
      );
      await _flushAsync();

      expect(engine.events, contains('seek:0.0'));
      expect(engine.events, contains('play'));
      expect(
        engine.events.where((event) => event.startsWith('load:')),
        isEmpty,
      );

      await cubit.close();
    },
  );

  test(
    'activating a playlist switches to playlist mode and non-playlist modes hide active playlist',
    () async {
      final cubit = SongCubit(
        _FakeSongRepository(),
        _FakeAssetService(),
        _FakeMidiEngine(),
      );
      await _flushAsync();
      cubit.createPlaylist('Ibadah');
      final playlistId = cubit.state.playlists.single.id;

      cubit.setPlaylistAutoNextMode(SongPlaylistAutoNextMode.number);
      cubit.setActivePlaylist(playlistId);

      expect(cubit.state.activePlaylistId, playlistId);
      expect(
        cubit.state.playlistAutoNextMode,
        SongPlaylistAutoNextMode.playlist,
      );
      expect(cubit.state.isPlaylistLoopModeActive, isTrue);

      cubit.setPlaylistAutoNextMode(SongPlaylistAutoNextMode.number);

      expect(cubit.state.activePlaylistId, playlistId);
      expect(cubit.state.isPlaylistLoopModeActive, isFalse);

      await cubit.close();
    },
  );

  test(
    'updatePdfKey applies natural transpose even before family chord loads',
    () async {
      final engine = _FakeMidiEngine();
      final cubit = SongCubit(
        _FakeSongRepository(),
        _FakeAssetService(),
        engine,
      );
      await _flushAsync();
      engine.events.clear();

      cubit.updatePdfKey('Fis');

      expect(cubit.state.originalFamilyChord, isNull);
      expect(cubit.state.originalPdfKey, 'Fis');
      expect(cubit.state.transposeStep, -1);
      expect(cubit.state.baseTransposeOffset, 0);
      expect(engine.events, contains('setTranspose:-1'));

      await cubit.close();
    },
  );

  test('toggleChord is disabled for HYMNE book', () async {
    final cubit = SongCubit(
      _FakeSongRepository(),
      _FakeAssetService(),
      _FakeMidiEngine(),
    );
    await _flushAsync();

    cubit.sync(const SongState(bookCode: 'HYMNE', showChord: true));
    cubit.toggleChord();

    expect(cubit.state.showChord, isFalse);
    await cubit.close();
  });

  test('updatePdfKey infers accidental style from detected PDF key', () async {
    final cubit = SongCubit(
      _FakeSongRepository(),
      _FakeAssetService(),
      _FakeMidiEngine(),
    );
    await _flushAsync();

    cubit.updatePdfKey('Bes');
    expect(cubit.state.chordAccidentalMode, ChordService.accidentalFlat);

    cubit.updatePdfKey('Fis');
    expect(cubit.state.chordAccidentalMode, ChordService.accidentalSharp);

    await cubit.close();
  });

  test(
    'stale page load completion does not clear newer loading state',
    () async {
      final engine = _BlockingMidiEngine();
      final cubit = SongCubit(
        _FakeSongRepository(),
        _FakeAssetService(),
        engine,
      );
      await _flushAsync();
      cubit.toggleAudio(true);
      await _flushAsync();
      engine.events.clear();

      final secondSongLoad = Completer<void>();
      final thirdSongLoad = Completer<void>();
      engine.blockedLoads['assets/data/midi/kr/002.mid'] = secondSongLoad;
      engine.blockedLoads['assets/data/midi/kr/003.mid'] = thirdSongLoad;

      final firstPageChange = cubit.changePage(1, 0);
      await _flushAsync();
      expect(cubit.state.pageIndex, 1);
      expect(cubit.state.isAudioLoading, isTrue);

      final secondPageChange = cubit.changePage(2, 0);
      await _flushAsync();
      expect(cubit.state.pageIndex, 2);
      expect(cubit.state.isAudioLoading, isTrue);

      secondSongLoad.complete();
      await firstPageChange;
      await _flushAsync();

      expect(cubit.state.pageIndex, 2);
      expect(cubit.state.isAudioLoading, isTrue);

      thirdSongLoad.complete();
      await secondPageChange;
      await _flushAsync();

      expect(cubit.state.isAudioLoading, isFalse);

      await cubit.close();
    },
  );

  test(
    'tempo debounce from previous song is canceled on page change',
    () async {
      final engine = _FakeMidiEngine();
      final cubit = SongCubit(
        _FakeSongRepository(),
        _FakeAssetService(),
        engine,
      );
      await _flushAsync();
      engine.events.clear();

      cubit.updatePdfTempo(120);
      await cubit.changePage(1, 0);
      await Future<void>.delayed(const Duration(milliseconds: 180));

      expect(engine.events, isNot(contains('setTempoBase:120.0')));
      expect(cubit.state.pageIndex, 1);
      expect(cubit.state.defaultTempoBpm, 76);

      await cubit.close();
    },
  );
}

Future<void> _flushAsync() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _MemoryStorage implements Storage {
  final Map<String, dynamic> _values = {};

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<void> close() async {}

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  dynamic read(String key) => _values[key];

  @override
  Future<void> write(String key, dynamic value) async {
    _values[key] = value;
  }
}

class _FakeSongRepository implements SongRepository {
  @override
  Future<Either<Failure, List<SongBook>>> getData() async {
    return right(const [
      SongBook(
        code: 'KR',
        songs: [
          Song(code: 'KR', number: '001', title: 'One'),
          Song(code: 'KR', number: '002', title: 'Two'),
          Song(code: 'KR', number: '003', title: 'Three'),
        ],
      ),
    ]);
  }
}

class _FakeAssetService extends LocalAssetService {
  final String? chordPath;
  final String? pdfPath;
  final List<String> chordRequests = [];
  final List<String> pdfRequests = [];
  final Map<String, Completer<void>> _blockedChordPaths = {};

  _FakeAssetService({this.chordPath, this.pdfPath}) : super(PdfChunkService());

  set blockChordPathFor(String key) {
    _blockedChordPaths[key] = Completer<void>();
  }

  void releaseChordPath(String key) {
    _blockedChordPaths.remove(key)?.complete();
  }

  @override
  Future<String?> getPdfPath(String bookCode, String number) async {
    pdfRequests.add('$bookCode:$number');
    return pdfPath ?? 'assets/data/pdf/${bookCode.toLowerCase()}/$number.pdf';
  }

  @override
  Future<bool> needsPdfPreparation(String bookCode, String number) async {
    return false;
  }

  @override
  Future<String?> getMidiPath(String bookCode, String number) async {
    return 'assets/data/midi/${bookCode.toLowerCase()}/$number.mid';
  }

  @override
  Future<String?> getChordPath(String bookCode, String number) async {
    final key = '$bookCode:$number';
    chordRequests.add(key);
    final blocker = _blockedChordPaths[key];
    if (blocker != null) {
      await blocker.future;
    }
    return chordPath;
  }
}

class _FakeMidiEngine extends MidiEngineService {
  final List<String> events = [];
  final StreamController<MidiPlaybackState> _states =
      StreamController<MidiPlaybackState>.broadcast();

  _FakeMidiEngine()
    : super(LocalAssetService(PdfChunkService()), cacheDir: 'unused');

  @override
  Stream<MidiPlaybackState> get stateStream => _states.stream;

  void emitPlayback(MidiPlaybackState state) {
    _states.add(state);
  }

  @override
  Future<void> initialize() async {
    events.add('initialize');
  }

  @override
  Future<void> changeSoundFont(String soundFontFileName) async {
    events.add('soundfont:$soundFontFileName');
  }

  @override
  void setSoundFont(String soundFontFileName) {
    events.add('selectSoundFont:$soundFontFileName');
  }

  @override
  Future<void> loadMidi(
    String midiPath, {
    int transpose = 0,
    double tempoBpm = 76,
    double? baseTempoBpm,
    int? instrument,
    bool autoplay = false,
    Duration startAt = Duration.zero,
  }) async {
    events.add(
      'load:$midiPath:t$transpose:tempo$tempoBpm:base${baseTempoBpm ?? 76}:start${startAt.inSeconds}',
    );
  }

  @override
  Future<void> warmUp(
    String midiPath, {
    int transpose = 0,
    double tempoBpm = 76,
    double? baseTempoBpm,
    int? instrument,
  }) async {
    events.add(
      'warm:$midiPath:t$transpose:tempo$tempoBpm:base${baseTempoBpm ?? 76}',
    );
  }

  @override
  Future<void> play({Duration startAt = Duration.zero}) async {
    events.add('play');
  }

  @override
  Future<void> pause() async {
    events.add('pause');
  }

  @override
  Future<void> stop() async {
    events.add('stop');
  }

  @override
  Future<void> seek(double seconds) async {
    events.add('seek:$seconds');
  }

  @override
  Future<void> setTempo(double bpm) async {
    events.add('setTempo:$bpm');
  }

  @override
  Future<void> setInstrument(int program) async {
    events.add('setInstrument:$program');
  }

  @override
  Future<void> setTranspose(int semitones) async {
    events.add('setTranspose:$semitones');
  }

  @override
  Future<void> setTempoBase(double bpm) async {
    events.add('setTempoBase:$bpm');
  }

  @override
  Future<void> disposeEngine() async {
    events.add('dispose');
    await _states.close();
  }
}

class _BlockingMidiEngine extends _FakeMidiEngine {
  final Map<String, Completer<void>> blockedLoads = {};

  @override
  Future<void> loadMidi(
    String midiPath, {
    int transpose = 0,
    double tempoBpm = 76,
    double? baseTempoBpm,
    int? instrument,
    bool autoplay = false,
    Duration startAt = Duration.zero,
  }) async {
    await super.loadMidi(
      midiPath,
      transpose: transpose,
      tempoBpm: tempoBpm,
      baseTempoBpm: baseTempoBpm,
      instrument: instrument,
      autoplay: autoplay,
      startAt: startAt,
    );
    final key = '$midiPath:$transpose';
    final completer = blockedLoads.remove(key) ?? blockedLoads.remove(midiPath);
    if (completer != null) {
      await completer.future;
    }
  }
}

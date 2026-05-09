import 'dart:async';

import 'package:church/data/services/local_asset_service.dart';
import 'package:church/data/services/midi_engine_service.dart';
import 'package:church/data/utilities/variables/failure.dart';
import 'package:church/domain/entity/song/song_entity.dart';
import 'package:church/domain/repository/song_repository.dart';
import 'package:church/presentations/song/cubit/song_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  setUp(() {
    HydratedBloc.storage = _MemoryStorage();
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
      engine.events.clear();

      await cubit.changePage(1, 0);

      expect(
        engine.events,
        contains('load:assets/data/midi/kr/002.mid:t0:tempo76.0:base76.0'),
      );
      expect(engine.events, isNot(contains('setTranspose:0')));
      expect(engine.events, isNot(contains('setTempoBase:76.0')));

      await cubit.close();
    },
  );

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
  @override
  Future<String?> getMidiPath(String bookCode, String number) async {
    return 'assets/data/midi/${bookCode.toLowerCase()}/$number.mid';
  }

  @override
  Future<String?> getChordPath(String bookCode, String number) async => null;
}

class _FakeMidiEngine extends MidiEngineService {
  final List<String> events = [];

  _FakeMidiEngine() : super(LocalAssetService(), cacheDir: 'unused');

  @override
  Future<void> initialize() async {
    events.add('initialize');
  }

  @override
  Future<void> changeSoundFont(String soundFontFileName) async {
    events.add('soundfont:$soundFontFileName');
  }

  @override
  void setCacheMax(int max) {
    events.add('cache:$max');
  }

  @override
  Future<void> loadMidi(
    String midiPath, {
    int transpose = 0,
    double tempoBpm = 76,
    double? baseTempoBpm,
    int? instrument,
    bool autoplay = false,
  }) async {
    events.add(
      'load:$midiPath:t$transpose:tempo$tempoBpm:base${baseTempoBpm ?? 76}',
    );
  }

  @override
  Future<void> preload(
    String midiPath, {
    int transpose = 0,
    double? tempoBpm,
    double? baseTempoBpm,
    int? instrument,
    String? soundFont,
  }) async {
    events.add('preload:$midiPath:t$transpose:sf$soundFont');
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
  }) async {
    await super.loadMidi(
      midiPath,
      transpose: transpose,
      tempoBpm: tempoBpm,
      baseTempoBpm: baseTempoBpm,
      instrument: instrument,
      autoplay: autoplay,
    );
    await blockedLoads[midiPath]?.future;
  }
}

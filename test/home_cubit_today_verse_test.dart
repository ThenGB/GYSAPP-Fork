import 'package:church/data/services/ourmanna_service.dart';
import 'package:church/domain/entity/sauh/sauh_entity.dart';
import 'package:church/domain/entity/truevoice/truevoice_entity.dart';
import 'package:church/domain/repository/scrapper_repository.dart';
import 'package:church/presentations/home/bloc/home_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockScrapperRepository extends Mock implements ScrapperRepository {}

class MockOurMannnaService extends Mock implements OurMannnaService {}

class _MemoryStorage implements Storage {
  _MemoryStorage();

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

Future<void> _flushAsync() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    HydratedBloc.storage = _MemoryStorage();
  });

  group('HomeCubit fetchTodayVerse bible version', () {
    late MockScrapperRepository mockRepository;
    late MockOurMannnaService mockOurMannaService;

    setUp(() async {
      mockRepository = MockScrapperRepository();
      mockOurMannaService = MockOurMannnaService();
      when(() => mockRepository.getSauh())
          .thenAnswer((_) async => const Right(<Sauh>[]));
      when(() => mockRepository.getSuaraSejati())
          .thenAnswer((_) async => const Right(<TrueVoice>[]));
    });

    test('uses default bible code when BibleCubit storage is absent', () async {
      when(() => mockOurMannaService.getVerse(bibleCode: any(named: 'bibleCode')))
          .thenAnswer((_) async => OurMannaVerse(
                text:
                    'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life according to the scriptures',
                reference: 'John 3:16',
                bibleCodeName: 'TB',
                originalReference: 'John 3:16',
              ));

      HomeCubit(mockRepository, mockOurMannaService);
      await _flushAsync();

      verify(() => mockOurMannaService.getVerse(bibleCode: 'b_tb')).called(1);
    });

    test('falls back to default when stored code is missing from installed list', () async {
      await HydratedBloc.storage.write(
        'BibleCubit',
        <String, dynamic>{
          'currentBibleCode': 'missing_version',
          'bibleCodes': <String>['b_tb'],
        },
      );

      when(() => mockOurMannaService.getVerse(bibleCode: any(named: 'bibleCode')))
          .thenAnswer((_) async => OurMannaVerse(
                text:
                    'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life according to the scriptures',
                reference: 'John 3:16',
                bibleCodeName: 'TB',
                originalReference: 'John 3:16',
              ));

      HomeCubit(mockRepository, mockOurMannaService);
      await _flushAsync();

      verify(() => mockOurMannaService.getVerse(bibleCode: 'b_tb')).called(1);
    });

    test('keeps stored codes when BibleCubit storage is valid', () async {
      await HydratedBloc.storage.write(
        'BibleCubit',
        <String, dynamic>{
          'currentBibleCode': 'b_tb',
          'bibleCodes': <String>['b_tb', 'installed_version'],
        },
      );

      when(() => mockOurMannaService.getVerse(bibleCode: any(named: 'bibleCode')))
          .thenAnswer((_) async => OurMannaVerse(
                text:
                    'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life according to the scriptures',
                reference: 'John 3:16',
                bibleCodeName: 'TB',
                originalReference: 'John 3:16',
              ));

      final cubit = HomeCubit(mockRepository, mockOurMannaService);
      await _flushAsync();

      expect(cubit.bibleCodes, containsAll(<String>['b_tb', 'installed_version']));
      verify(() => mockOurMannaService.getVerse(bibleCode: 'b_tb')).called(1);
    });
  });
}

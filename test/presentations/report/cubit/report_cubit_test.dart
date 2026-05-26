import 'package:bloc_test/bloc_test.dart';
import 'package:church/presentations/report/cubit/report_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  group('ReportCubit', () {
    late Storage storage;

    setUp(() {
      storage = MockStorage();
      when(() => storage.read(any())).thenReturn(null);
      when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
      when(() => storage.delete(any())).thenAnswer((_) async {});
      when(() => storage.clear()).thenAnswer((_) async {});
      HydratedBloc.storage = storage;
    });

    test('initial state is correct', () {
      final cubit = ReportCubit();
      expect(cubit.state, const ReportState(isLoading: false));
    });

    blocTest<ReportCubit, ReportState>(
      'emits nothing when sendReport is called (as it is currently empty)',
      build: () => ReportCubit(),
      act: (cubit) => cubit.sendReport(),
      expect: () => [],
    );

    test('fromJson returns correct ReportState', () {
      final cubit = ReportCubit();
      final json = {'isLoading': true};
      final state = cubit.fromJson(json);
      expect(state, const ReportState(isLoading: true));
    });

    test('toJson returns correct Map', () {
      final cubit = ReportCubit();
      final state = const ReportState(isLoading: true);
      final json = cubit.toJson(state);
      expect(json, {'isLoading': true});
    });
  });
}

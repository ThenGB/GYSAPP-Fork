import 'dart:async';

import 'package:church/data/services/app_reset_service.dart';
import 'package:church/data/services/asset_distribution/asset_distribution_service.dart';
import 'package:church/data/services/asset_distribution/github_release_asset_client.dart';
import 'package:church/data/services/asset_distribution/models.dart';
import 'package:church/presentations/bible/cubit/bible_cubit.dart';
import 'package:church/presentations/settings/cubit/asset_management_cubit.dart';
import 'package:church/presentations/song/cubit/song_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  const bibleDefinition = AssetDefinition(
    kind: DistributedAssetKind.bible,
    code: 'b_kjv',
    title: 'KJV',
    installFileName: 'b_kjv.db',
    bundledByDefault: false,
    releaseTrack: AssetReleaseTrack.bibles,
  );
  const hymnalDefinition = AssetDefinition(
    kind: DistributedAssetKind.hymnal,
    code: 'MDR',
    title: 'MDR',
    installFileName: 'mdr_master.pdf',
    bundledByDefault: false,
    releaseTrack: AssetReleaseTrack.hymnals,
  );

  late _MockAssetDistributionService service;
  late _MockAppResetService resetService;

  setUpAll(() {
    registerFallbackValue(CancelToken());
    registerFallbackValue(bibleDefinition);
  });

  setUp(() {
    service = _MockAssetDistributionService();
    resetService = _MockAppResetService();
    when(() => service.loadStatuses()).thenAnswer((_) async => const []);
  });

  void stubSuccessfulDownload(AssetDefinition definition) {
    when(
      () => service.downloadAndInstall(
        definition,
        onProgress: any(named: 'onProgress'),
        cancelToken: any(named: 'cancelToken'),
        onDownloadComplete: any(named: 'onDownloadComplete'),
      ),
    ).thenAnswer((invocation) async {
      final progress =
          invocation.namedArguments[#onProgress] as ProgressCallback?;
      final complete =
          invocation.namedArguments[#onDownloadComplete] as void Function()?;
      progress?.call(50, 100);
      complete?.call();
    });
  }

  test('Bible install refreshes the live Bible version library', () async {
    final bibleCubit = _MockBibleCubit();
    when(bibleCubit.refreshAvailableBibles).thenAnswer((_) async {});
    stubSuccessfulDownload(bibleDefinition);

    final cubit = AssetManagementCubit(service, resetService);
    addTearDown(cubit.close);

    await cubit.downloadAsset(bibleDefinition, bibleCubit: bibleCubit);

    verify(bibleCubit.refreshAvailableBibles).called(1);
    expect(cubit.state.progressByCode, isEmpty);
    expect(cubit.state.installingCodes, isEmpty);
  });

  test('Hymnal install refreshes the live song library', () async {
    final songCubit = _MockSongCubit();
    when(songCubit.refreshLibraryAvailability).thenAnswer((_) async {});
    stubSuccessfulDownload(hymnalDefinition);

    final cubit = AssetManagementCubit(service, resetService);
    addTearDown(cubit.close);

    await cubit.downloadAsset(hymnalDefinition, songCubit: songCubit);

    verify(songCubit.refreshLibraryAvailability).called(1);
    expect(cubit.state.progressByCode, isEmpty);
  });

  test('cancelDownload cancels the active network token and clears progress', () async {
    final started = Completer<void>();
    when(
      () => service.downloadAndInstall(
        bibleDefinition,
        onProgress: any(named: 'onProgress'),
        cancelToken: any(named: 'cancelToken'),
        onDownloadComplete: any(named: 'onDownloadComplete'),
      ),
    ).thenAnswer((invocation) async {
      final progress =
          invocation.namedArguments[#onProgress] as ProgressCallback?;
      final token = invocation.namedArguments[#cancelToken] as CancelToken;
      progress?.call(10, 100);
      started.complete();
      while (!token.isCancelled) {
        await Future<void>.delayed(Duration.zero);
      }
      throw const AssetDownloadCancelled('b_kjv');
    });

    final cubit = AssetManagementCubit(service, resetService);
    addTearDown(cubit.close);

    final download = cubit.downloadAsset(bibleDefinition);
    await started.future;
    expect(cubit.state.progressByCode['b_kjv'], closeTo(0.1, 0.001));

    cubit.cancelDownload('b_kjv');
    await download;

    expect(cubit.state.progressByCode.containsKey('b_kjv'), isFalse);
    expect(cubit.state.cancellingCodes.contains('b_kjv'), isFalse);
    expect(cubit.state.message, contains('stopped'));
  });
}

class _MockAssetDistributionService extends Mock
    implements AssetDistributionService {}

class _MockAppResetService extends Mock implements AppResetService {}

class _MockBibleCubit extends Mock implements BibleCubit {}

class _MockSongCubit extends Mock implements SongCubit {}

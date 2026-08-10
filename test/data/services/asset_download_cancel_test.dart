import 'dart:io';
import 'dart:typed_data';

import 'package:church/data/services/asset_distribution/asset_cache_maintenance_service.dart';
import 'package:church/data/services/asset_distribution/asset_distribution_service.dart';
import 'package:church/data/services/asset_distribution/encrypted_asset_package_service.dart';
import 'package:church/data/services/asset_distribution/github_release_asset_client.dart';
import 'package:church/data/services/asset_distribution/installed_asset_registry.dart';
import 'package:church/data/services/asset_distribution/installed_asset_store.dart';
import 'package:church/data/services/asset_distribution/models.dart';
import 'package:church/data/services/local_asset_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late Directory supportDir;

  setUp(() {
    supportDir = Directory.systemTemp.createTempSync('church_cancel_asset_');
    registerFallbackValue(
      const RemoteAssetPackage(
        code: 'b_kjv',
        version: '',
        fileName: '',
        downloadUrl: '',
        installFileName: '',
        sizeBytes: 0,
      ),
    );
  });

  tearDown(() {
    if (supportDir.existsSync()) supportDir.deleteSync(recursive: true);
  });

  test('cancelled network download never installs or registers asset', () async {
    final store = _MemoryInstalledAssetStore();
    final registry = InstalledAssetRegistry(
      supportDirectory: supportDir,
      store: store,
    );
    final client = _MockAssetClient();
    final cancelToken = CancelToken();
    var installPhaseStarted = false;

    when(
      () => client.fetchLatestManifest(AssetReleaseTrack.bibles),
    ).thenAnswer(
      (_) async => RemoteAssetManifest(
        track: AssetReleaseTrack.bibles,
        releaseTag: 'bibles-test',
        publishedAt: DateTime.utc(2026, 8, 10),
        packages: const [
          RemoteAssetPackage(
            code: 'b_kjv',
            version: '1',
            fileName: 'b_kjv.gyspkg',
            downloadUrl: 'https://example.invalid/b_kjv.gyspkg',
            installFileName: 'b_kjv.db',
            sizeBytes: 1024,
            checksumSha256: 'unused-because-cancelled-before-checksum',
          ),
        ],
      ),
    );
    when(
      () => client.downloadPackage(
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
        cancelToken: cancelToken,
      ),
    ).thenAnswer((invocation) async {
      final destination = invocation.positionalArguments[1] as String;
      await File(destination).writeAsBytes(const [1, 2, 3, 4]);
      cancelToken.cancel('test cancellation');
    });

    final service = AssetDistributionService(
      registry,
      client,
      EncryptedAssetPackageService(),
      _MockCacheMaintenance(),
      _MockLocalAssetService(),
      store,
    );

    const definition = AssetDefinition(
      kind: DistributedAssetKind.bible,
      code: 'b_kjv',
      title: 'KJV',
      installFileName: 'b_kjv.db',
      bundledByDefault: false,
      releaseTrack: AssetReleaseTrack.bibles,
    );

    await expectLater(
      service.downloadAndInstall(
        definition,
        cancelToken: cancelToken,
        onDownloadComplete: () => installPhaseStarted = true,
      ),
      throwsA(isA<AssetDownloadCancelled>()),
    );

    expect(installPhaseStarted, isFalse);
    expect(
      File('${registry.bibleInstallDirectory.path}/b_kjv.db').existsSync(),
      isFalse,
    );
    expect(
      await registry.getInstalledRecord(
        DistributedAssetKind.bible,
        'b_kjv',
      ),
      isNull,
    );
  });
}

class _MemoryInstalledAssetStore implements InstalledAssetStore {
  final Map<String, Uint8List> _files = {};

  @override
  Future<List<String>> listFiles(String directory) async {
    final prefix = directory.endsWith('/') ? directory : '$directory/';
    return _files.keys.where((key) => key.startsWith(prefix)).toList();
  }

  @override
  Future<Uint8List?> readFile(String relativePath) async => _files[relativePath];

  @override
  Future<void> writeFile(String relativePath, Uint8List bytes) async {
    _files[relativePath] = bytes;
  }

  @override
  Future<void> deleteFile(String relativePath) async {
    _files.remove(relativePath);
  }

  @override
  Future<bool> exists(String relativePath) async => _files.containsKey(relativePath);

  @override
  Future<void> clear() async => _files.clear();
}

class _MockAssetClient extends Mock implements GitHubReleaseAssetClient {}

class _MockCacheMaintenance extends Mock
    implements AssetCacheMaintenanceService {}

class _MockLocalAssetService extends Mock implements LocalAssetService {}

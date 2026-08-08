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
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Regression coverage for the download→install→registry pipeline used by
/// downloaded (non-TB) bible versions.
///
/// These tests run on the VM, so downloadAndInstall takes the native
/// streaming path: the package is written to the registry's install dir and
/// the registry record is persisted.
void main() {
  late Directory supportDir;

  setUp(() {
    supportDir = Directory.systemTemp.createTempSync('church_install_');
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
    if (supportDir.existsSync()) {
      supportDir.deleteSync(recursive: true);
    }
  });

  Future<RemoteAssetManifest> manifest({String checksum = ''}) async {
    return RemoteAssetManifest(
      track: AssetReleaseTrack.bibles,
      releaseTag: 'bibles-2026.05.21',
      publishedAt: DateTime.utc(2026, 5, 21),
      packages: [
        RemoteAssetPackage(
          code: 'b_kjv',
          version: '2026.05.21',
          fileName: 'b_kjv.gyspkg',
          downloadUrl: 'https://example.invalid/b_kjv.gyspkg',
          installFileName: 'b_kjv.db',
          sizeBytes: 100,
          checksumSha256: checksum,
        ),
      ],
    );
  }

  String checksumOf(Uint8List bytes) =>
      sha256.convert(bytes).toString().toUpperCase();

  test('downloadAndInstall writes decrypted file and registry record',
      () async {
    final store = _MemoryInstalledAssetStore();
    final registry = InstalledAssetRegistry(
      supportDirectory: supportDir,
      store: store,
    );
    final packageService = EncryptedAssetPackageService();
    final payload = Uint8List.fromList(List.generate(64, (i) => i + 1));
    final packageBytes = packageService.buildPackageBytesForTesting(payload);

    final client = _MockAssetClient();
    when(() => client.fetchLatestManifest(AssetReleaseTrack.bibles))
        .thenAnswer((_) async => manifest(checksum: checksumOf(packageBytes)));
    when(
      () => client.downloadPackage(
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((invocation) async {
      final destination = invocation.positionalArguments[1] as String;
      await File(destination).writeAsBytes(packageBytes);
    });

    final service = AssetDistributionService(
      registry,
      client,
      packageService,
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

    await service.downloadAndInstall(definition);

    // Native path: the decrypted payload lands in the install dir.
    final installedFile = File(
      '${registry.bibleInstallDirectory.path}/b_kjv.db',
    );
    expect(installedFile.existsSync(), isTrue);
    expect(await installedFile.readAsBytes(), payload);

    final record = await registry.getInstalledRecord(
      DistributedAssetKind.bible,
      'b_kjv',
    );
    expect(record, isNotNull);
    expect(record!.installedPath, 'b_kjv.db');
    expect(record.version, '2026.05.21');
  });

  test('downloadAndInstall surfaces checksum mismatch before install', () async {
    final store = _MemoryInstalledAssetStore();
    final registry = InstalledAssetRegistry(
      supportDirectory: supportDir,
      store: store,
    );
    final packageService = EncryptedAssetPackageService();
    final payload = Uint8List.fromList(List.generate(32, (i) => i));
    final packageBytes = packageService.buildPackageBytesForTesting(payload);

    final client = _MockAssetClient();
    when(() => client.fetchLatestManifest(AssetReleaseTrack.bibles))
        .thenAnswer((_) async => manifest(checksum: 'DEADBEEF'));
    when(
      () => client.downloadPackage(
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((invocation) async {
      final destination = invocation.positionalArguments[1] as String;
      await File(destination).writeAsBytes(packageBytes);
    });

    final service = AssetDistributionService(
      registry,
      client,
      packageService,
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
      service.downloadAndInstall(definition),
      throwsStateError,
    );

    // Nothing may have been installed on checksum failure.
    expect(
      File('${registry.bibleInstallDirectory.path}/b_kjv.db').existsSync(),
      isFalse,
    );
  });

  test('downloadAndInstall rejects a manifest without a checksum', () async {
    final store = _MemoryInstalledAssetStore();
    final registry = InstalledAssetRegistry(
      supportDirectory: supportDir,
      store: store,
    );
    final packageService = EncryptedAssetPackageService();
    final payload = Uint8List.fromList(List.generate(32, (i) => i));
    final packageBytes = packageService.buildPackageBytesForTesting(payload);

    final client = _MockAssetClient();
    // Empty checksum = manifest omits the integrity field entirely.
    when(() => client.fetchLatestManifest(AssetReleaseTrack.bibles))
        .thenAnswer((_) async => manifest(checksum: ''));
    when(
      () => client.downloadPackage(
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((invocation) async {
      final destination = invocation.positionalArguments[1] as String;
      await File(destination).writeAsBytes(packageBytes);
    });

    final service = AssetDistributionService(
      registry,
      client,
      packageService,
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
      service.downloadAndInstall(definition),
      throwsStateError,
    );

    expect(
      File('${registry.bibleInstallDirectory.path}/b_kjv.db').existsSync(),
      isFalse,
    );
  });

  test('downloadAndInstall rejects a manifest with a path-traversal name',
      () async {
    final store = _MemoryInstalledAssetStore();
    final registry = InstalledAssetRegistry(
      supportDirectory: supportDir,
      store: store,
    );
    final packageService = EncryptedAssetPackageService();
    final payload = Uint8List.fromList(List.generate(32, (i) => i));
    final packageBytes = packageService.buildPackageBytesForTesting(payload);

    final client = _MockAssetClient();
    when(() => client.fetchLatestManifest(AssetReleaseTrack.bibles))
        .thenAnswer((_) async {
      return RemoteAssetManifest(
        track: AssetReleaseTrack.bibles,
        releaseTag: 'bibles-2026.05.21',
        publishedAt: DateTime.utc(2026, 5, 21),
        packages: [
          RemoteAssetPackage(
            code: 'b_kjv',
            version: '2026.05.21',
            fileName: '../../escape.gyspkg',
            downloadUrl: 'https://example.invalid/b_kjv.gyspkg',
            installFileName: 'b_kjv.db',
            sizeBytes: 100,
            checksumSha256: checksumOf(packageBytes),
          ),
        ],
      );
    });
    when(
      () => client.downloadPackage(
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((invocation) async {
      final destination = invocation.positionalArguments[1] as String;
      await File(destination).writeAsBytes(packageBytes);
    });

    final service = AssetDistributionService(
      registry,
      client,
      packageService,
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
      service.downloadAndInstall(definition),
      throwsStateError,
    );

    // The raw-name check throws before any download/decrypt/install runs:
    // the mock downloadPackage must never have been invoked, so no file can
    // have been written anywhere (escape or otherwise).
    verifyNever(
      () => client.downloadPackage(
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    );
  });
}

/// In-memory [InstalledAssetStore] — mirrors the idb_shim web store contract
/// without touching the file system.
class _MemoryInstalledAssetStore implements InstalledAssetStore {
  final Map<String, Uint8List> _files = {};

  @override
  Future<List<String>> listFiles(String directory) async {
    final prefix = directory.endsWith('/') ? directory : '$directory/';
    return _files.keys.where((k) => k.startsWith(prefix)).toList();
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
  Future<bool> exists(String relativePath) async =>
      _files.containsKey(relativePath);
}

class _MockAssetClient extends Mock implements GitHubReleaseAssetClient {}

class _MockCacheMaintenance extends Mock
    implements AssetCacheMaintenanceService {}

class _MockLocalAssetService extends Mock implements LocalAssetService {}

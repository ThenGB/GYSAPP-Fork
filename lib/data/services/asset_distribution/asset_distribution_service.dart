import 'dart:io';

import 'package:crypto/crypto.dart';

import '../../../di/injection.dart';
import '../local_asset_service.dart';
import '../pdf_note_service.dart';
import 'asset_cache_maintenance_service.dart';
import 'encrypted_asset_package_service.dart';
import 'github_release_asset_client.dart';
import 'installed_asset_registry.dart';
import 'models.dart';

class AssetDistributionService {
  AssetDistributionService(
    this._registry,
    this._client,
    this._packageService,
    this._cacheMaintenanceService,
    this._appDirectory,
    this._localAssetService,
  );

  final InstalledAssetRegistry _registry;
  final GitHubReleaseAssetClient _client;
  final EncryptedAssetPackageService _packageService;
  final AssetCacheMaintenanceService _cacheMaintenanceService;
  final AppDirectory _appDirectory;
  final LocalAssetService _localAssetService;
  final Map<AssetReleaseTrack, RemoteAssetManifest?> _manifestCache = {};

  Future<List<ManagedAssetStatus>> loadStatuses() async {
    final installedRecords = {
      for (final record in await _registry.getInstalledRecords()) record.key: record,
    };
    final bibleManifest = await _safeManifest(AssetReleaseTrack.bibles);
    final hymnalManifest = await _safeManifest(AssetReleaseTrack.hymnals);
    final soundfontManifest = await _safeManifest(AssetReleaseTrack.soundfont);

    return supportedDistributedAssets.map((definition) {
      final manifest = switch (definition.releaseTrack) {
        AssetReleaseTrack.bibles => bibleManifest,
        AssetReleaseTrack.hymnals => hymnalManifest,
        AssetReleaseTrack.soundfont => soundfontManifest,
      };
      final remote = manifest?.packages
          .where((package) => package.code == definition.code)
          .firstOrNull;
      return ManagedAssetStatus(
        definition: definition,
        installedRecord: installedRecords['${definition.kind.name}:${definition.code}'],
        remotePackage: remote,
      );
    }).toList();
  }

  Future<void> refreshRemoteState() async {
    _manifestCache.clear();
    await Future.wait([
      _safeManifest(AssetReleaseTrack.bibles),
      _safeManifest(AssetReleaseTrack.hymnals),
      _safeManifest(AssetReleaseTrack.soundfont),
    ]);
  }

  Future<void> downloadAndInstall(
    AssetDefinition definition, {
    ProgressCallback? onProgress,
  }) async {
    final manifest = await _safeManifest(definition.releaseTrack);
    final package = manifest?.packages
        .where((entry) => entry.code == definition.code)
        .firstOrNull;
    if (package == null) {
      throw StateError('No release package available for ${definition.code}.');
    }

    final tempDir = Directory(_appDirectory.assetTempFolder);
    await tempDir.create(recursive: true);
    final packageFile = File('${tempDir.path}/${package.fileName}');
    await _client.downloadPackage(
      package,
      packageFile.path,
      onProgress: onProgress,
    );
    await _verifyChecksum(packageFile, package.checksumSha256);

    final destinationFile = switch (definition.kind) {
      DistributedAssetKind.bible =>
        File('${_registry.bibleInstallDirectory.path}/${package.installFileName}'),
      DistributedAssetKind.hymnal =>
        File('${_registry.hymnalInstallDirectory.path}/${package.installFileName}'),
      DistributedAssetKind.soundfont =>
        File('${_registry.soundfontInstallDirectory.path}/${package.installFileName}'),
    };

    await _packageService.installPackage(
      packageFile: packageFile,
      destinationFile: destinationFile,
    );

    await _registry.saveInstalled(
      InstalledAssetRecord(
        kind: definition.kind,
        code: definition.code,
        version: package.version,
        installedPath: package.installFileName,
        installedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        releaseTag: manifest?.releaseTag,
        checksumSha256: package.checksumSha256,
      ),
    );

    if (definition.kind == DistributedAssetKind.hymnal) {
      final requestPath = await _localAssetService.getPdfPath(definition.code, '001');
      if (requestPath != null) {
        final request = PdfDocumentRequest.parse(requestPath);
        await PdfNoteService().warmup(
          request.assetPath,
          startPage: request.startPage,
          pageCount: 1,
        );
      }
    }

    if (await packageFile.exists()) {
      await packageFile.delete();
    }
  }

  Future<void> deleteInstalled(AssetDefinition definition) async {
    await _registry.removeInstalled(definition.kind, definition.code);
  }

  Future<void> clearFastAccessCache() async {
    PdfNoteService().clearCache();
    await _cacheMaintenanceService.clearFastAccessCache();
  }

  Future<RemoteAssetManifest?> _safeManifest(AssetReleaseTrack track) async {
    if (_manifestCache.containsKey(track)) {
      return _manifestCache[track];
    }
    try {
      final manifest = await _client.fetchLatestManifest(track);
      _manifestCache[track] = manifest;
      return manifest;
    } catch (_) {
      _manifestCache[track] = null;
      return null;
    }
  }

  Future<void> _verifyChecksum(
    File packageFile,
    String? expectedChecksum,
  ) async {
    if (expectedChecksum == null || expectedChecksum.isEmpty) {
      return;
    }
    final digest = sha256.convert(await packageFile.readAsBytes()).toString();
    // Manifest checksums are stored uppercase; compare case-insensitively
    // (an exact != always threw and silently broke downloads).
    if (digest.toLowerCase() != expectedChecksum.toLowerCase()) {
      if (await packageFile.exists()) {
        await packageFile.delete();
      }
      throw StateError('Checksum mismatch for ${packageFile.path}.');
    }
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

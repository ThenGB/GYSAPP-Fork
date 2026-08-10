import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart' hide ProgressCallback;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;

import '../local_asset_service.dart';
import '../pdf_note_service.dart';
import 'asset_cache_maintenance_service.dart';
import 'encrypted_asset_package_service.dart';
import 'github_release_asset_client.dart';
import 'installed_asset_registry.dart';
import 'installed_asset_store.dart';
import 'models.dart';

class AssetDownloadCancelled implements Exception {
  const AssetDownloadCancelled(this.code);
  final String code;
}

class _DigestAccumulator implements Sink<Digest> {
  Digest? _digest;

  @override
  void add(Digest data) {
    _digest = data;
  }

  @override
  void close() {}

  Digest get value {
    final digest = _digest;
    if (digest == null) throw StateError('Digest not produced.');
    return digest;
  }
}

class AssetDistributionService {
  AssetDistributionService(
    this._registry,
    this._client,
    this._packageService,
    this._cacheMaintenanceService,
    this._localAssetService,
    this._store,
  );

  final InstalledAssetRegistry _registry;
  final GitHubReleaseAssetClient _client;
  final EncryptedAssetPackageService _packageService;
  final AssetCacheMaintenanceService _cacheMaintenanceService;
  final LocalAssetService _localAssetService;
  final InstalledAssetStore _store;
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
    CancelToken? cancelToken,
    void Function()? onDownloadComplete,
  }) async {
    var downloadFinished = false;
    try {
      final manifest = await _safeManifest(definition.releaseTrack);
      _throwIfCancelled(cancelToken, definition.code);
      final package = manifest?.packages
          .where((entry) => entry.code == definition.code)
          .firstOrNull;
      if (package == null) {
        throw StateError('No release package available for ${definition.code}.');
      }

      final installName = _safeInstallName(package.installFileName);

      if (kIsWeb) {
        final packageBytes = cancelToken == null
            ? await _client.downloadPackageBytes(
                package,
                onProgress: onProgress,
              )
            : await _client.downloadPackageBytes(
                package,
                onProgress: onProgress,
                cancelToken: cancelToken,
              );
        _throwIfCancelled(cancelToken, definition.code);
        downloadFinished = true;
        onDownloadComplete?.call();

        await _verifyChecksumBytes(packageBytes, package.checksumSha256);
        final installedBytes = await _packageService.installPackageBytes(
          packageBytes,
        );
        await _store.writeFile(
          '${_kindDirectory(definition.kind)}/$installName',
          installedBytes,
        );
      } else {
        final tempDir = await Directory.systemTemp.createTemp('gys_asset_');
        try {
          final fileName = _safeInstallName(package.fileName);
          final packageFile = File(p.join(tempDir.path, fileName));
          if (!p.isWithin(tempDir.path, p.normalize(packageFile.path))) {
            throw StateError('Package file escapes temp dir: $fileName');
          }
          if (cancelToken == null) {
            await _client.downloadPackage(
              package,
              packageFile.path,
              onProgress: onProgress,
            );
          } else {
            await _client.downloadPackage(
              package,
              packageFile.path,
              onProgress: onProgress,
              cancelToken: cancelToken,
            );
          }
          _throwIfCancelled(cancelToken, definition.code);
          downloadFinished = true;
          onDownloadComplete?.call();

          await _verifyChecksumFile(packageFile, package.checksumSha256);

          final destinationFile = switch (definition.kind) {
            DistributedAssetKind.bible => File(
              p.join(_registry.bibleInstallDirectory.path, installName),
            ),
            DistributedAssetKind.hymnal => File(
              p.join(_registry.hymnalInstallDirectory.path, installName),
            ),
            DistributedAssetKind.soundfont => File(
              p.join(_registry.soundfontInstallDirectory.path, installName),
            ),
          };
          await _packageService.installPackage(
            packageFile: packageFile,
            destinationFile: destinationFile,
          );
        } finally {
          if (await tempDir.exists()) await tempDir.delete(recursive: true);
        }
      }

      await _registry.saveInstalled(
        InstalledAssetRecord(
          kind: definition.kind,
          code: definition.code,
          version: package.version,
          installedPath: installName,
          installedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
          releaseTag: manifest?.releaseTag,
          checksumSha256: package.checksumSha256,
        ),
      );

      if (definition.kind == DistributedAssetKind.hymnal && !kIsWeb) {
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
    } catch (error) {
      if (!downloadFinished && cancelToken?.isCancelled == true) {
        throw AssetDownloadCancelled(definition.code);
      }
      rethrow;
    }
  }

  void _throwIfCancelled(CancelToken? token, String code) {
    if (token?.isCancelled == true) throw AssetDownloadCancelled(code);
  }

  static String _kindDirectory(DistributedAssetKind kind) =>
      switch (kind) {
        DistributedAssetKind.bible => 'bible',
        DistributedAssetKind.hymnal => 'hymnal',
        DistributedAssetKind.soundfont => 'soundfont',
      };

  Future<void> deleteInstalled(AssetDefinition definition) async {
    await _registry.removeInstalled(definition.kind, definition.code);
  }

  Future<void> clearFastAccessCache() async {
    if (kIsWeb) return;
    PdfNoteService().clearCache();
    await _cacheMaintenanceService.clearFastAccessCache();
  }

  Future<RemoteAssetManifest?> _safeManifest(AssetReleaseTrack track) async {
    if (_manifestCache.containsKey(track)) return _manifestCache[track];
    try {
      final manifest = await _client.fetchLatestManifest(track);
      _manifestCache[track] = manifest;
      return manifest;
    } catch (_) {
      _manifestCache[track] = null;
      return null;
    }
  }

  static String _safeInstallName(String name) {
    if (name.contains('/') || name.contains('\\') || name.contains('\u0000')) {
      throw StateError('Invalid install file name: $name');
    }
    final basename = p.basename(name);
    final invalidWindows = RegExp(r'[:*?<>|]');
    if (basename.isEmpty ||
        basename == '.' ||
        basename == '..' ||
        invalidWindows.hasMatch(basename)) {
      throw StateError('Invalid install file name: $name');
    }
    return basename;
  }

  Future<void> _verifyChecksumBytes(
    Uint8List bytes,
    String? expectedChecksum,
  ) async {
    if (expectedChecksum == null || expectedChecksum.isEmpty) {
      throw StateError('Missing checksum for downloaded package.');
    }
    final digest = sha256.convert(bytes).toString();
    if (digest.toLowerCase() != expectedChecksum.toLowerCase()) {
      throw StateError('Checksum mismatch for $expectedChecksum.');
    }
  }

  Future<void> _verifyChecksumFile(
    File file,
    String? expectedChecksum,
  ) async {
    if (expectedChecksum == null || expectedChecksum.isEmpty) {
      throw StateError('Missing checksum for downloaded package.');
    }
    final accumulator = _DigestAccumulator();
    final sink = sha256.startChunkedConversion(accumulator);
    await for (final chunk in file.openRead()) {
      sink.add(chunk);
    }
    sink.close();
    final digest = accumulator.value.toString();
    if (digest.toLowerCase() != expectedChecksum.toLowerCase()) {
      throw StateError('Checksum mismatch for $expectedChecksum.');
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'models.dart';

class InstalledAssetRegistry {
  InstalledAssetRegistry({required Directory supportDirectory})
    : _supportDirectory = supportDirectory;

  final Directory _supportDirectory;
  Map<String, InstalledAssetRecord>? _cache;

  Directory get installedAssetsDirectory =>
      Directory('${_supportDirectory.path}/installed_assets');

  Directory get bibleInstallDirectory =>
      Directory('${installedAssetsDirectory.path}/bible');

  Directory get hymnalInstallDirectory =>
      Directory('${installedAssetsDirectory.path}/hymnal');

  File get registryFile => File('${installedAssetsDirectory.path}/registry.json');

  Future<Map<String, InstalledAssetRecord>> _load() async {
    final cached = _cache;
    if (cached != null) return cached;

    if (!await registryFile.exists()) {
      _cache = {};
      return _cache!;
    }

    final json = jsonDecode(await registryFile.readAsString()) as Map<String, dynamic>;
    _cache = json.map(
      (key, value) => MapEntry(
        key,
        InstalledAssetRecord.fromJson((value as Map).cast<String, dynamic>()),
      ),
    );
    return _cache!;
  }

  Future<void> _persist(Map<String, InstalledAssetRecord> data) async {
    await installedAssetsDirectory.create(recursive: true);
    await registryFile.writeAsString(
      jsonEncode({for (final entry in data.entries) entry.key: entry.value.toJson()}),
    );
    _cache = data;
  }

  Future<List<InstalledAssetRecord>> getInstalledRecords({
    DistributedAssetKind? kind,
  }) async {
    final data = await _load();
    final values = data.values.toList();
    if (kind == null) return values;
    return values.where((record) => record.kind == kind).toList();
  }

  Future<InstalledAssetRecord?> getInstalledRecord(
    DistributedAssetKind kind,
    String code,
  ) async {
    final data = await _load();
    return data['${kind.name}:$code'];
  }

  Future<void> saveInstalled(InstalledAssetRecord record) async {
    final data = Map<String, InstalledAssetRecord>.from(await _load());
    data[record.key] = record;
    await _persist(data);
  }

  Future<void> removeInstalled(
    DistributedAssetKind kind,
    String code, {
    bool deleteFile = true,
  }) async {
    final data = Map<String, InstalledAssetRecord>.from(await _load());
    final removed = data.remove('${kind.name}:$code');
    if (removed != null && deleteFile) {
      final path = await _resolveInstalledPath(removed);
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    await _persist(data);
  }

  Future<String?> resolveInstalledBiblePath(String code) async {
    final record = await getInstalledRecord(DistributedAssetKind.bible, code);
    return _resolveInstalledPath(record);
  }

  Future<String?> resolveInstalledHymnalPath(String code) async {
    final record = await getInstalledRecord(DistributedAssetKind.hymnal, code);
    return _resolveInstalledPath(record);
  }

  Future<String?> _resolveInstalledPath(InstalledAssetRecord? record) async {
    if (record == null || record.installedPath.isEmpty) return null;
    final baseDir = switch (record.kind) {
      DistributedAssetKind.bible => bibleInstallDirectory,
      DistributedAssetKind.hymnal => hymnalInstallDirectory,
    };
    final file = File('${baseDir.path}/${record.installedPath}');
    return await file.exists() ? file.path : null;
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;

import 'installed_asset_store.dart';
import 'installed_asset_store_io.dart';
import 'models.dart';

/// Persistent record of which distributed assets are installed locally.
///
/// The registry JSON itself and the installed asset files are read/written
/// through an [InstalledAssetStore] so the same code works on native (real
/// file system) and web (IndexedDB). On web, file-path resolution
/// ([resolveInstalledBiblePath] and friends) has no meaning and returns null.
class InstalledAssetRegistry {
  InstalledAssetRegistry({
    Directory? supportDirectory,
    String? supportPath,
    InstalledAssetStore? store,
  }) : assert(supportDirectory != null || supportPath != null),
       _supportPath = supportPath ?? supportDirectory!.path,
       _store =
           store ??
           FileSystemInstalledAssetStore(
             installedAssetsRoot:
                 '${supportPath ?? supportDirectory!.path}/installed_assets',
           );

  final String _supportPath;
  final InstalledAssetStore _store;
  Map<String, InstalledAssetRecord>? _cache;

  static const _registryPath = 'registry.json';

  /// Relative path (inside the installed-assets root) of a kind directory.
  static String _kindDirectory(DistributedAssetKind kind) => switch (kind) {
    DistributedAssetKind.bible => 'bible',
    DistributedAssetKind.hymnal => 'hymnal',
    DistributedAssetKind.soundfont => 'soundfont',
  };

  static String _assetRelativePath(InstalledAssetRecord record) =>
      '${_kindDirectory(record.kind)}/${record.installedPath}';

  Directory get installedAssetsDirectory =>
      Directory('$_supportPath/installed_assets');

  Directory get bibleInstallDirectory =>
      Directory('${installedAssetsDirectory.path}/bible');

  Directory get hymnalInstallDirectory =>
      Directory('${installedAssetsDirectory.path}/hymnal');

  Directory get soundfontInstallDirectory =>
      Directory('${installedAssetsDirectory.path}/soundfont');

  Future<Map<String, InstalledAssetRecord>> _load() async {
    final cached = _cache;
    if (cached != null) return cached;

    final bytes = await _store.readFile(_registryPath);
    if (bytes == null) {
      _cache = {};
      return _cache!;
    }

    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    _cache = json.map(
      (key, value) => MapEntry(
        key,
        InstalledAssetRecord.fromJson((value as Map).cast<String, dynamic>()),
      ),
    );
    return _cache!;
  }

  Future<void> _persist(Map<String, InstalledAssetRecord> data) async {
    await _store.writeFile(
      _registryPath,
      Uint8List.fromList(
        utf8.encode(
          jsonEncode({
            for (final entry in data.entries) entry.key: entry.value.toJson(),
          }),
        ),
      ),
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
      await _store.deleteFile(_assetRelativePath(removed));
    }
    await _persist(data);
  }

  /// Reads the installed bible database bytes, or null when not installed.
  Future<Uint8List?> readInstalledBibleBytes(String code) async {
    final record = await getInstalledRecord(DistributedAssetKind.bible, code);
    if (record == null || record.installedPath.isEmpty) return null;
    return _store.readFile(_assetRelativePath(record));
  }

  /// Cheap existence check for an installed bible database — uses the
  /// store's exists (no full DB read; important on web IndexedDB).
  Future<bool> existsInstalledBible(String code) async {
    final record = await getInstalledRecord(DistributedAssetKind.bible, code);
    if (record == null || record.installedPath.isEmpty) return false;
    return _store.exists(_assetRelativePath(record));
  }

  /// Writes bible database bytes for [code]. On native this also persists
  /// the corresponding record so folder scans and the registry agree.
  Future<void> writeInstalledBibleBytes(String code, Uint8List bytes) async {
    final installFileName = '$code.db';
    await _store.writeFile(
      '${_kindDirectory(DistributedAssetKind.bible)}/$installFileName',
      bytes,
    );
    await saveInstalled(
      InstalledAssetRecord(
        kind: DistributedAssetKind.bible,
        code: code,
        version: '',
        installedPath: installFileName,
        installedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Lists installed bible codes, e.g. `['b_kjv', 'b_cuv']`.
  Future<List<String>> listInstalledBibleCodes() async {
    final records = await getInstalledRecords(kind: DistributedAssetKind.bible);
    return records.map((record) => record.code).toList()..sort();
  }

  Future<String?> resolveInstalledBiblePath(String code) async {
    final record = await getInstalledRecord(DistributedAssetKind.bible, code);
    return _resolveInstalledPath(record);
  }

  Future<String?> resolveInstalledHymnalPath(String code) async {
    final record = await getInstalledRecord(DistributedAssetKind.hymnal, code);
    return _resolveInstalledPath(record);
  }

  Future<String?> resolveInstalledSoundfontPath(String code) async {
    final record = await getInstalledRecord(
      DistributedAssetKind.soundfont,
      code,
    );
    return _resolveInstalledPath(record);
  }

  /// File-path resolution only exists on native. On web it always returns
  /// null — callers must use [readInstalledBibleBytes] / the store instead.
  Future<String?> _resolveInstalledPath(InstalledAssetRecord? record) async {
    if (kIsWeb || record == null || record.installedPath.isEmpty) return null;
    final baseDir = switch (record.kind) {
      DistributedAssetKind.bible => bibleInstallDirectory,
      DistributedAssetKind.hymnal => hymnalInstallDirectory,
      DistributedAssetKind.soundfont => soundfontInstallDirectory,
    };
    final file = File('${baseDir.path}/${record.installedPath}');
    // Defense-in-depth: resolved paths must stay inside the install dir.
    if (!p.isWithin(baseDir.path, p.normalize(file.path))) {
      return null;
    }
    return await file.exists() ? file.path : null;
  }
}

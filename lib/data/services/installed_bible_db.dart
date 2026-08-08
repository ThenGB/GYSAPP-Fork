import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite_common/sqflite.dart';

import '../../di/injection.dart';
import 'asset_distribution/installed_asset_registry.dart';

/// Opens installed (downloaded, non-bundled) Bible databases on every
/// platform.
///
/// Native platforms open the `.db` file directly from disk. Web has no file
/// system, so the downloaded bytes are first written into the sqlite web
/// factory's store (IndexedDB) under a stable relative path, then opened.
class InstalledBibleDb {
  /// Relative store path used for a bible code on web.
  static String webPath(String code) => 'bible/$code.db';

  static InstalledAssetRegistry _registry() {
    try {
      return di<InstalledAssetRegistry>();
    } catch (_) {
      // Tests that construct the registry manually can inject it.
      final testRegistry = _testRegistry;
      if (testRegistry != null) return testRegistry;
      rethrow;
    }
  }

  /// Test hook: registry used when DI has not been set up.
  static InstalledAssetRegistry? _testRegistry;

  static void debugUseRegistry(InstalledAssetRegistry registry) {
    _testRegistry = registry;
  }

  static Future<Database?> open(
    String code, {
    bool readOnly = true,
  }) async {
    _safeCode(code); // Reject codes that could escape the install dir.
    final registry = _registry();

    if (kIsWeb) {
      final bytes = await registry.readInstalledBibleBytes(code);
      if (bytes == null) return null;
      final path = webPath(code);
      await databaseFactory.writeDatabaseBytes(path, bytes);
      return databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(readOnly: readOnly),
      );
    }

    // Prefer the registry-resolved path; fall back to a folder scan so
    // manually copied .db files (which listInstalledCodes surfaces) still
    // open, matching the pre-refactor behavior.
    final resolved =
        await registry.resolveInstalledBiblePath(code) ??
        await _folderPath(registry, code);
    if (resolved == null) return null;
    return openDatabase(resolved, readOnly: readOnly);
  }

  static Future<bool> exists(String code) async {
    _safeCode(code); // Reject codes that could escape the install dir.
    final registry = _registry();
    if (kIsWeb) {
      return registry.existsInstalledBible(code);
    }
    final resolved =
        await registry.resolveInstalledBiblePath(code) ??
        await _folderPath(registry, code);
    return resolved != null;
  }

  /// Rejects a bible code that isn't a plain basename, so a tampered
  /// registry record or caller can't escape the install dir via `../`.
  static String _safeCode(String code) {
    if (code.isEmpty ||
        code.contains('/') ||
        code.contains('\\') ||
        code.contains('\u0000') ||
        code == '.' ||
        code == '..') {
      throw ArgumentError.value(code, 'code', 'Invalid bible code');
    }
    return code;
  }

  static Future<String?> _folderPath(
    InstalledAssetRegistry registry,
    String code,
  ) async {
    final folder = registry.bibleInstallDirectory;
    if (!await folder.exists()) return null;
    final file = File(p.join(folder.path, '${_safeCode(code)}.db'));
    return await file.exists() ? file.path : null;
  }

  /// Lists installed bible codes (e.g. `['b_kjv', 'b_cuv']`).
  ///
  /// Native also scans the install folder so manually copied `.db` files
  /// remain selectable; web relies on the registry (IndexedDB).
  static Future<List<String>> listInstalledCodes() async {
    final registry = _registry();
    if (kIsWeb) {
      return registry.listInstalledBibleCodes();
    }
    final folder = registry.bibleInstallDirectory;
    if (!await folder.exists()) return const [];
    final codes = <String>{
      for (final file in await folder.list().toList())
        if (file is File &&
            p.basename(file.path).toLowerCase().endsWith('.db'))
          p.basenameWithoutExtension(file.path),
      ...await registry.listInstalledBibleCodes(),
    };
    return codes.toList()..sort();
  }

  /// Writes downloaded bible bytes into the store (web) or the install
  /// folder (native). Used by tests to simulate an installed version.
  static Future<void> writeInstalled(String code, Uint8List bytes) async {
    _safeCode(code); // Consistency with open()/exists() on every platform.
    final registry = _registry();
    if (kIsWeb) {
      await registry.writeInstalledBibleBytes(code, bytes);
      return;
    }
    final file = File(
      p.join(registry.bibleInstallDirectory.path, '$code.db'),
    );
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }
}

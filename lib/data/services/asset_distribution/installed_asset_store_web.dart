import 'dart:typed_data';

import 'package:idb_shim/idb_browser.dart' show IdbFactory, idbFactoryBrowser;
import 'package:idb_shim/idb_client.dart' show Database, idbModeReadOnly, idbModeReadWrite;

import 'installed_asset_store.dart';

/// [InstalledAssetStore] backed by IndexedDB (web).
///
/// Every file is stored as one record keyed by its relative path inside a
/// single object store. `idbFactory` defaults to the browser IndexedDB
/// ([idbFactoryBrowser]); tests inject the in-memory factory
/// ([newIdbFactoryMemory]).
class IndexedDbInstalledAssetStore implements InstalledAssetStore {
  IndexedDbInstalledAssetStore({
    String databaseName = 'gys_installed_assets',
    String storeName = 'files',
    IdbFactory? idbFactory,
  }) : _databaseName = databaseName,
       _storeName = storeName,
       _idbFactory = idbFactory ?? idbFactoryBrowser;

  final String _databaseName;
  final String _storeName;
  final IdbFactory _idbFactory;

  Database? _database;

  Future<Database> _db() async {
    final existing = _database;
    if (existing != null) return existing;
    final db = await _idbFactory.open(
      _databaseName,
      version: 1,
      onUpgradeNeeded: (event) {
        final db = event.database;
        if (!db.objectStoreNames.contains(_storeName)) {
          db.createObjectStore(_storeName);
        }
      },
    );
    _database = db;
    return db;
  }

  @override
  Future<List<String>> listFiles(String directory) async {
    final db = await _db();
    final tx = db.transaction(_storeName, idbModeReadOnly);
    final store = tx.objectStore(_storeName);
    final keys = await store.getAllKeys();
    await tx.completed;
    final prefix = directory.endsWith('/') ? directory : '$directory/';
    return keys
        .whereType<String>()
        .where((key) => key.startsWith(prefix))
        .toList();
  }

  @override
  Future<Uint8List?> readFile(String relativePath) async {
    final db = await _db();
    final tx = db.transaction(_storeName, idbModeReadOnly);
    final store = tx.objectStore(_storeName);
    final value = await store.getObject(relativePath);
    await tx.completed;
    return value as Uint8List?;
  }

  @override
  Future<void> writeFile(String relativePath, Uint8List bytes) async {
    final db = await _db();
    final tx = db.transaction(_storeName, idbModeReadWrite);
    final store = tx.objectStore(_storeName);
    await store.put(bytes, relativePath);
    await tx.completed;
  }

  @override
  Future<void> deleteFile(String relativePath) async {
    final db = await _db();
    final tx = db.transaction(_storeName, idbModeReadWrite);
    final store = tx.objectStore(_storeName);
    await store.delete(relativePath);
    await tx.completed;
  }

  @override
  Future<bool> exists(String relativePath) async {
    final db = await _db();
    final tx = db.transaction(_storeName, idbModeReadOnly);
    final store = tx.objectStore(_storeName);
    final value = await store.getObject(relativePath);
    await tx.completed;
    return value != null;
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'installed_asset_store.dart';

/// [InstalledAssetStore] backed by the real file system.
///
/// Files live under [installedAssetsRoot] (e.g. the app support
/// directory's `installed_assets` folder).
class FileSystemInstalledAssetStore implements InstalledAssetStore {
  FileSystemInstalledAssetStore({required String installedAssetsRoot})
    : _root = installedAssetsRoot;

  final String _root;

  String _resolve(String relativePath) {
    // Defense-in-depth: stored asset paths must stay inside the
    // installed-assets root. p.join collapses ../, so check the joined
    // result stays under [root] to block registry tampering from escaping.
    final resolved = p.normalize(p.join(_root, relativePath));
    if (!p.isWithin(_root, resolved)) {
      throw ArgumentError.value(
        relativePath,
        'relativePath',
        'Path escapes installed-assets root',
      );
    }
    return resolved;
  }

  @override
  Future<List<String>> listFiles(String directory) async {
    final dir = Directory(_resolve(directory));
    if (!await dir.exists()) return const [];
    final names = <String>[];
    await for (final entity in dir.list()) {
      if (entity is File) {
        // Normalize to '/' separators to match the web (IndexedDB) store.
        names.add(
          p.joinAll([
            directory,
            p.basename(entity.path),
          ]).replaceAll('\\', '/'),
        );
      }
    }
    return names;
  }

  @override
  Future<Uint8List?> readFile(String relativePath) async {
    final file = File(_resolve(relativePath));
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  @override
  Future<void> writeFile(String relativePath, Uint8List bytes) async {
    final file = File(_resolve(relativePath));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }

  @override
  Future<void> deleteFile(String relativePath) async {
    final file = File(_resolve(relativePath));
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<bool> exists(String relativePath) async {
    return File(_resolve(relativePath)).exists();
  }
}

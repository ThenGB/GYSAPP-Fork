import 'dart:typed_data';

/// Platform-agnostic storage for installed distributed assets.
///
/// Native platforms (Android/iOS/desktop) back this with the real file
/// system under the app support directory; web backs it with IndexedDB
/// (via idb_shim), because there is no file system in the browser.
///
/// All paths are relative to the installed-assets root, e.g.
/// `registry.json`, `bible/b_kjv.db`.
abstract class InstalledAssetStore {
  /// Lists the relative paths of every file stored under [directory]
  /// (e.g. `bible` -> `bible/b_kjv.db`). Returns [] when nothing is stored.
  Future<List<String>> listFiles(String directory);

  /// Reads a stored file, or null when it does not exist.
  Future<Uint8List?> readFile(String relativePath);

  /// Writes (creating or replacing) a stored file.
  Future<void> writeFile(String relativePath, Uint8List bytes);

  /// Deletes a stored file. No-op when it does not exist.
  Future<void> deleteFile(String relativePath);

  /// Whether a stored file exists.
  Future<bool> exists(String relativePath);

  /// Removes every installed distributed asset.
  Future<void> clear();
}

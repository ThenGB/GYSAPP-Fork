import 'installed_asset_store.dart';
import 'installed_asset_store_io.dart';

export 'installed_asset_store.dart';

/// Native platforms: files on disk under `<root>/installed_assets`.
InstalledAssetStore createInstalledAssetStore(String rootPath) {
  return FileSystemInstalledAssetStore(installedAssetsRoot: rootPath);
}

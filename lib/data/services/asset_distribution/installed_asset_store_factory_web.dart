import 'installed_asset_store.dart';
import 'installed_asset_store_web.dart';

export 'installed_asset_store.dart';

/// Web: IndexedDB backed store; [rootPath] is ignored (no file system).
InstalledAssetStore createInstalledAssetStore(String rootPath) {
  return IndexedDbInstalledAssetStore();
}

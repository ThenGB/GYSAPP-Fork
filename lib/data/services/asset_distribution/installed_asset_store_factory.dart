/// Platform-agnostic storage for installed distributed assets.
library;

import 'installed_asset_store.dart';

export 'installed_asset_store.dart';
export 'installed_asset_store_factory_io.dart'
    if (dart.library.html) 'installed_asset_store_factory_web.dart';

/// Test hook: lets tests inject a store (e.g. the in-memory idb factory)
/// before DI resolution.
class InstalledAssetStoreHolder {
  static InstalledAssetStore? store;
}

import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../di/injection.dart';
import '../utilities/platform_utils.dart';
import 'asset_distribution/installed_asset_store.dart';
import 'auth_token_store.dart';
import 'fast_hydrated_storage.dart';

class AppResetService {
  AppResetService({
    required this.appDirectory,
    Storage? storage,
    AuthTokenStore? authTokenStore,
    InstalledAssetStore? installedAssetStore,
    Future<void> Function()? cancelNotifications,
  }) : _storage = storage ?? HydratedBloc.storage,
       _authTokenStore = authTokenStore,
       _installedAssetStore = installedAssetStore,
       _cancelNotifications =
           cancelNotifications ?? _defaultCancelNotifications;

  final AppDirectory appDirectory;
  final Storage _storage;
  final AuthTokenStore? _authTokenStore;
  final InstalledAssetStore? _installedAssetStore;
  final Future<void> Function() _cancelNotifications;

  Future<void> wipeEverything() async {
    await Future.wait([
      _cancelNotifications(),
      if (_authTokenStore != null) _authTokenStore.clear(),
      if (_installedAssetStore != null) _installedAssetStore.clear(),
    ]);
    await _storage.clear();
    await _storage.close();

    if (!kIsWeb) {
      await Future.wait([
        _resetDirectory(appDirectory.document),
        _resetDirectory(appDirectory.cache),
        _resetDirectory(appDirectory.support),
      ]);
    }

    final newStorage = FastFileStorage();
    await newStorage.init();
    HydratedBloc.storage = newStorage;
  }

  Future<void> _resetDirectory(String path) async {
    final directory = Directory(path);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    await directory.create(recursive: true);
  }

  static Future<void> _defaultCancelNotifications() async {
    if (!isNotificationConfiguredForCurrentPlatform) return;
    await AwesomeNotifications().cancelAll();
  }
}

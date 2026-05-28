import 'dart:developer';
import 'dart:io';

import 'package:chaleno/chaleno.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import '../data/data.dart';

import '../data/utilities/encrypt.dart';
import '../domain/domain.dart';
import '../presentations/presentations.dart';

var di = GetIt.I;
AppConfig get config => di<AppConfig>();

Future<void> setupInjection(AppConfig config) async {
  await _utils(config);
  _repositories();
  _services();
  _blocs();
}

void _blocs() {
  di.registerFactory(() => HomeCubit(di()));
  di.registerFactory(() => InitialCubit());
  di.registerFactory(() => DashboardCubit(di()));
  di.registerFactory(() => BibleCubit());
  di.registerFactory(() => LiteratureKesaksianCubit(di()));
  di.registerFactory(() => LiteratureWartaCubit(di()));
  di.registerFactory(() => LiteratureRenunganCubit(di()));
  di.registerFactory(() => LiteraturePanduanCubit(di()));
  di.registerSingleton(SongCubit(di(), di(), di()));
  di.registerFactory(() => FaithCubit());
  di.registerFactory(() => SettingsCubit());
  di.registerFactory(() => AssetManagementCubit(di(), di()));
  di.registerFactory(() => AuthCubit());
  di.registerFactory(() => BackupCubit(di(), di()));
}

Future<void> _utils(AppConfig appConfig) async {
  // Use hardcoded paths instead of platform channel calls (avoids hang)
  const base = '/data/data/id.sch.kanaan.egys';
  final document = '$base/files';
  final cache = '$base/cache';
  final support = '$base/files';
  di.registerSingleton(AppDirectory(document, cache, support));
  di.registerSingleton(EncryptData(di()));
  di.registerFactory(() => Chaleno());
  di.registerSingleton(appConfig);
  di.registerFactory(() => Dio()..interceptors.add(loggingInterceptor));
  di.registerLazySingletonAsync(() async {
    try {
      var credentials = await AppConfigStore.jsonConfig('mailer_credentials');
      String username = credentials['username'];
      String password = credentials['password'];
      return Mailer(username, password);
    } catch (e) {
      return Mailer('', '');
    }
  });
}

void _services() {
  di.registerLazySingleton(() => LocalBibleAssetService());
  di.registerLazySingleton(() => PdfChunkService());
  di.registerLazySingleton(() => AppResetService(appDirectory: di()));
  di.registerLazySingleton(
    () => InstalledAssetRegistry(
      supportDirectory: Directory(di<AppDirectory>().support),
    ),
  );
  di.registerLazySingleton(() => EncryptedAssetPackageService());
  di.registerLazySingleton(() => GitHubReleaseAssetClient(di()));
  di.registerLazySingleton(
    () => AssetCacheMaintenanceService(appDirectory: di()),
  );
  di.registerLazySingleton(
    () => LocalAssetService(di(), installedAssetRegistry: di()),
  );
  di.registerLazySingleton(
    () => AssetDistributionService(di(), di(), di(), di(), di(), di()),
  );

  di.registerLazySingleton(
    () => MidiEngineService(
      di(),
      cacheDir: '${di<AppDirectory>().songMusicFolder}/render_cache',
    ),
  );
}

void _repositories() {
  di.registerFactory<ScrapperRepository>(() => ScrapperRepositoryImpl(di()));
  di.registerFactory<BibleRepository>(() => BibleRepositoryImpl());
  di.registerFactory<SongRepository>(() => SongRepositoryImpl(di()));
  di.registerFactory<AuthRepository>(() => AuthRepositoryImpl());
  di.registerFactory<AccountRepository>(
    () => AccountRepositoryImpl(di()..options.baseUrl = config.baseUrlApi),
  );
  di.registerFactory<ThemePreferencesRepository>(() => ThemePreferencesRepository());
}

class AppDirectory {
  final String document;
  final String cache;
  final String support;

  AppDirectory(this.document, this.cache, this.support);

  String get bibleFolder => '$support/installed_assets/bible';
  String get hymnalFolder => '$support/installed_assets/hymnal';
  String get assetRegistryPath => '$support/installed_assets/registry.json';
  String get assetTempFolder => '$cache/asset_downloads';
  String get preparedPdfFolder => '$document/master_pdfs';
  String get pdfNoteCacheFolder => '$cache/pdf_note_cache';
  String get songRenderCacheFolder => '$songMusicFolder/render_cache';
  String get songMusicFolder => '$cache/song';
  String get songLyricFolder => '$cache/lyrics';
  String get songDbPath => '$cache/song/song.db';
  String get backupFolder => '$cache/backup';
  String get encryptFolder => '$cache/encrypted';
  String get decryptFolder => '$cache/encrypted';
}

InterceptorsWrapper loggingInterceptor = InterceptorsWrapper(
  onError: (e, handler) {
    if (kDebugMode) {
      log(e.message ?? '', name: 'HTTP ERROR ');
      log(e.response?.data.toString() ?? '', name: 'HTTP ERROR ');
    }
    return handler.reject(e);
  },
  onRequest: (options, handler) {
    if (kDebugMode) {
      log(options.toJson().toString(), name: 'HTTP REQUEST');
    }
    return handler.next(options);
  },
  onResponse: (e, handler) {
    if (kDebugMode) {
      log(e.data.toString(), name: 'HTTP RESPONSE');
    }
    return handler.next(e);
  },
);

extension RequestOptionsExtension on RequestOptions {
  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'baseUrl': baseUrl,
      'path': path,
      'headers': headers,
      'data': data,
    };
  }
}

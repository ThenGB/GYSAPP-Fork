import 'dart:developer';
import 'dart:io';

import 'package:chaleno/chaleno.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'
    show
        getApplicationDocumentsDirectory,
        getApplicationSupportDirectory,
        getTemporaryDirectory;

import '../data/data.dart';
import '../data/utilities/encrypt.dart';
import '../domain/domain.dart';
import '../presentations/presentations.dart';

final di = GetIt.I;
AppConfig get config => di<AppConfig>();

Future<void> setupInjection(AppConfig config) async {
  await _utils(config);
  _repositories();
  _services();
  _blocs();
}

void _blocs() {
  di.registerFactory(() => HomeCubit(di(), di()));
  di.registerFactory(() => InitialCubit());
  di.registerFactory(() => DashboardCubit(di()));

  // Bible and Song are expensive, long-lived feature controllers. Register
  // them lazily so app bootstrap only builds their engines when a widget first
  // requests the feature rather than while setupInjection is still blocking
  // runApp().
  di.registerLazySingleton<BibleCubit>(() => BibleCubit());
  di.registerLazySingleton<SongCubit>(() => SongCubit(di(), di(), di()));

  di.registerFactory(() => LiteratureKesaksianCubit(di()));
  di.registerFactory(() => LiteratureWartaCubit(di()));
  di.registerFactory(() => LiteratureRenunganCubit(di()));
  di.registerFactory(() => LiteraturePanduanCubit(di()));
  di.registerFactory(() => FaithCubit());
  di.registerFactory(() => SettingsCubit());
  di.registerFactory(() => AssetManagementCubit(di(), di()));
  di.registerFactory(() => AuthCubit());
  di.registerFactory(() => BackupCubit(di(), di()));
}

Future<void> _utils(AppConfig appConfig) async {
  late final String document;
  late final String cache;
  late final String support;

  if (kIsWeb) {
    document = 'web/files';
    cache = 'web/cache';
    support = 'web/files';
  } else if (Platform.isAndroid) {
    const base = '/data/data/id.sch.kanaan.egys';
    document = '$base/files';
    cache = '$base/cache';
    support = '$base/files';
  } else {
    // These platform-channel calls are independent. Resolve them concurrently
    // instead of adding their latency serially to cold start.
    final directories = await Future.wait([
      getApplicationDocumentsDirectory(),
      getTemporaryDirectory(),
      getApplicationSupportDirectory(),
    ]);
    document = directories[0].path;
    cache = directories[1].path;
    support = directories[2].path;
  }

  di.registerSingleton(AppDirectory(document, cache, support));
  di.registerSingleton(EncryptData(di()));
  di.registerFactory(() => Chaleno());
  di.registerSingleton(appConfig);
  di.registerFactory(() => Dio()..interceptors.add(loggingInterceptor));
  di.registerLazySingletonAsync(() async {
    try {
      final credentials = await AppConfigStore.jsonConfig('mailer_credentials');
      final username = credentials['username'] as String? ?? '';
      final password = credentials['password'] as String? ?? '';
      return Mailer(username, password);
    } catch (_) {
      return Mailer('', '');
    }
  });
}

void _services() {
  di.registerLazySingleton(() => LocalBibleAssetService());
  di.registerLazySingleton(() => PdfChunkService());
  di.registerLazySingleton(() => AppResetService(appDirectory: di()));
  di.registerLazySingleton(
    () => ChordSyncService(di<AppDirectory>(), http.Client()),
  );
  di.registerLazySingleton(
    () =>
        InstalledAssetStoreHolder.store ??
        createInstalledAssetStore(
          '${di<AppDirectory>().support}/installed_assets',
        ),
  );
  di.registerLazySingleton(
    () => InstalledAssetRegistry(
      supportPath: di<AppDirectory>().support,
      store: di<InstalledAssetStore>(),
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
    () => AssetDistributionService(
      di(),
      di(),
      di(),
      di(),
      di(),
      di<InstalledAssetStore>(),
    ),
  );
  di.registerLazySingleton(
    () => MidiEngineService(
      di(),
      cacheDir: '${di<AppDirectory>().songMusicFolder}/render_cache',
    ),
  );
  di.registerLazySingleton(() => OurMannnaService(di<Dio>(), di(), di()));
}

void _repositories() {
  di.registerFactory<ScrapperRepository>(() => ScrapperRepositoryImpl(di()));
  di.registerFactory<BibleRepository>(() => BibleRepositoryImpl());
  di.registerFactory<SongRepository>(() => SongRepositoryImpl(di()));
  di.registerFactory<AuthRepository>(() => AuthRepositoryImpl());
  di.registerFactory<AccountRepository>(
    () => AccountRepositoryImpl(di()..options.baseUrl = config.baseUrlApi),
  );
  di.registerFactory<ThemePreferencesRepository>(
    () => ThemePreferencesRepository(),
  );
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
  String get chordFolder => '$support/chords';
}

final InterceptorsWrapper loggingInterceptor = InterceptorsWrapper(
  onError: (error, handler) {
    if (kDebugMode) {
      final request = error.requestOptions;
      log(
        '${request.method} ${request.path} -> ${error.response?.statusCode ?? 'network error'}',
        name: 'HTTP ERROR',
      );
    }
    return handler.next(error);
  },
  onRequest: (options, handler) {
    if (kDebugMode) {
      log('${options.method} ${options.path}', name: 'HTTP REQUEST');
    }
    return handler.next(options);
  },
  onResponse: (response, handler) {
    if (kDebugMode) {
      log(
        '${response.requestOptions.method} ${response.requestOptions.path} -> ${response.statusCode}',
        name: 'HTTP RESPONSE',
      );
    }
    return handler.next(response);
  },
);

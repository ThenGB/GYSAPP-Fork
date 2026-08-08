import 'dart:developer';
import 'dart:io';

import 'package:chaleno/chaleno.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, getApplicationSupportDirectory, getTemporaryDirectory;

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
  di.registerFactory(() => HomeCubit(di(), di()));
  di.registerFactory(() => InitialCubit());
  di.registerFactory(() => DashboardCubit(di()));
  // Lazy singleton: the Bible tab (BlocProvider(create: di())) and the
  // version management page (di<BibleCubit>()) must share ONE instance —
  // a factory here silently created two, so downloading/selecting a version
  // in Settings never reached the open Bible pane.  It must be LAZY: the
  // constructor opens the sqlite FFI database, and doing that during
  // setupInjection (before the engine is running) deadlocks on the isolate
  // spawn.  First access happens from the dashboard at first frame, when
  // the FFI isolate can start.
  di.registerLazySingleton<BibleCubit>(() => BibleCubit());
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
  // Native Android keeps its known app-data layout.  Other platforms get
  // real, platform-correct directories from path_provider — the previous
  // hardcoded '/data/data/id.sch.kanaan.egys' made every download (and
  // HydratedBloc state) land in a nonexistent directory on desktop/iOS.
  late final String document;
  late final String cache;
  late final String support;
  if (kIsWeb) {
    // Web has no file system; AppDirectory is only used by native paths.
    document = 'web/files';
    cache = 'web/cache';
    support = 'web/files';
  } else if (Platform.isAndroid) {
    const base = '/data/data/id.sch.kanaan.egys';
    document = '$base/files';
    cache = '$base/cache';
    support = '$base/files';
  } else {
    final documents = await getApplicationDocumentsDirectory();
    final temp = await getTemporaryDirectory();
    final appSupport = await getApplicationSupportDirectory();
    document = documents.path;
    cache = temp.path;
    support = appSupport.path;
  }
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
    () => ChordSyncService(di<AppDirectory>(), http.Client()),
  );
  di.registerLazySingleton(
    () => InstalledAssetStoreHolder.store ?? createInstalledAssetStore(
      '${di<AppDirectory>().support}/installed_assets',
    ),
  );
  di.registerLazySingleton(
    () => InstalledAssetRegistry(
      supportDirectory: Directory(di<AppDirectory>().support),
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
  di.registerLazySingleton(
    () => OurMannnaService(di<Dio>(), di(), di()),
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
  // Synced chord JSON files (from gyschordweb), not bundled anymore.
  String get chordFolder => '$support/chords';
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

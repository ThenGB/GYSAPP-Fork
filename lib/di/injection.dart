import 'dart:developer';

import 'package:chaleno/chaleno.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path_provider/path_provider.dart';

import '../data/data.dart';
import '../data/repository/backupsync_repository_impl.dart';
import '../data/repository/google_repository_impl.dart';

import '../data/utilities/encrypt.dart';
import '../domain/domain.dart';
import '../domain/repository/backupsync_repository.dart';
import '../domain/repository/google_repository.dart';
import '../presentations/presentations.dart';

var di = GetIt.I;
AppConfig get config => di<AppConfig>();

Future<void> setupInjection(AppConfig config) async {
  _blocs();
  await _utils(config);
  _repositories();
  _services();
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
  di.registerFactory(() => SongCubit(di(), di(), di()));
  di.registerFactory(() => FaithCubit());
  di.registerFactory(() => SettingsCubit());
  di.registerFactory(() => AuthCubit(di()));
  di.registerFactory(() => BackupCubit(di(), di(), di(), di()));
}

Future<void> _utils(AppConfig appConfig) async {
  final directories = await Future.wait([
    getApplicationDocumentsDirectory(),
    getTemporaryDirectory(),
    getApplicationSupportDirectory(),
  ]);
  var document = directories[0].path;
  var cache = directories[1].path;
  var support = directories[2].path;
  di.registerSingleton(AppDirectory(document, cache, support));
  di.registerSingleton(EncryptData(di()));
  di.registerFactory(() => Chaleno());
  di.registerSingleton(appConfig);
  di.registerFactory(() => Dio()..interceptors.add(loggingInterceptor));
  di.registerLazySingletonAsync(() async {
    try {
      var credentials = await FirebaseUtils.jsonConfig('mailer_credentials');
      String username = credentials['username'];
      String password = credentials['password'];
      return Mailer(username, password);
    } catch (e) {
      return Mailer('', '');
    }
  });
  di.registerSingleton(
    GoogleSignIn(scopes: [drive.DriveApi.driveAppdataScope]),
  );
}

void _services() {
  di.registerLazySingleton(() => LocalBibleAssetService());
  di.registerLazySingleton(() => LocalAssetService());
  
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
  di.registerFactory<BackupSyncRepository>(
    () => BackupSyncRepositoryImpl(di()),
  );
  di.registerFactory<GoogleRepository>(() => GoogleRepositoryImpl(di()));
}

class AppDirectory {
  final String document;
  final String cache;
  final String support;

  AppDirectory(this.document, this.cache, this.support);

  String get bibleFolder => '$cache/bible';
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

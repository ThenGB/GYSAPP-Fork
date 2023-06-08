import 'dart:developer';

import 'package:chaleno/chaleno.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import '../data/repository/account_repository_impl.dart';
import '../data/repository/auth_repository_impl.dart';
import '../data/repository/bible_repository_impl.dart';
import '../data/repository/scrapper_repository_impl.dart';
import '../data/repository/song_repository_impl.dart';
import '../domain/entity/appconfig/appconfig.dart';
import '../domain/repository/account_repository.dart';
import '../domain/repository/auth_repository.dart';
import '../domain/repository/bible_repository.dart';
import '../domain/repository/scrapper_repository.dart';
import '../domain/repository/song_repository.dart';
import '../presentations/auth/cubit/auth_cubit.dart';
import '../presentations/bible/cubit/bible_cubit.dart';
import '../presentations/dashboard/cubit/dashboard_cubit.dart';
import '../presentations/home/bloc/home_cubit.dart';
import '../presentations/initial/bloc/initial_cubit.dart';
import '../presentations/literature/cubit/kesaksian/literature_kesaksian_cubit.dart';
import '../presentations/literature/cubit/panduan/literature_panduan_cubit.dart';
import '../presentations/literature/cubit/renungan/literature_renungan_cubit.dart';
import '../presentations/literature/cubit/warta/literature_warta_cubit.dart';
import '../presentations/settings/cubit/settings_cubit.dart';
import '../presentations/song/cubit/song_cubit.dart';

var di = GetIt.I;
AppConfig get config => di<AppConfig>();

setupInjection(AppConfig config) {
  _blocs();
  _utils(config);
  _repositories();
}

_blocs() {
  di.registerFactory(() => HomeCubit(di()));
  di.registerFactory(() => InitialCubit());
  di.registerFactory(() => DashboardCubit(di()));
  di.registerFactory(() => BibleCubit());
  di.registerFactory(() => LiteratureKesaksianCubit(di()));
  di.registerFactory(() => LiteratureWartaCubit(di()));
  di.registerFactory(() => LiteratureRenunganCubit(di()));
  di.registerFactory(() => LiteraturePanduanCubit(di()));
  di.registerFactory(() => SongCubit(di()));
  di.registerFactory(() => SettingsCubit());
  di.registerFactory(() => AuthCubit(di()));
}

_utils(AppConfig appConfig) async {
  var document = (await getApplicationDocumentsDirectory()).path;
  var cache = (await getTemporaryDirectory()).path;
  var support = (await getApplicationSupportDirectory()).path;
  di.registerSingleton(AppDirectory(document, cache, support));
  di.registerFactory(() => Chaleno());
  di.registerSingleton(appConfig);
  di.registerFactory(() => Dio()..interceptors.add(loggingInterceptor));
}

_repositories() {
  di.registerFactory<ScrapperRepository>(() => ScrapperRepositoryImpl(di()));
  di.registerFactory<BibleRepository>(() => BibleRepositoryImpl());
  di.registerFactory<SongRepository>(() => SongRepositoryImpl());
  di.registerFactory<AuthRepository>(() => AuthRepositoryImpl());
  di.registerFactory<AccountRepository>(
      () => AccountRepositoryImpl(di()..options.baseUrl = config.baseUrlApi));
}

class AppDirectory {
  final String document;
  final String cache;
  final String support;

  AppDirectory(this.document, this.cache, this.support);

  String get bibleFolder => '$cache/bible';
  String get songMusicFolder => '$cache/song';
  String get songDbPath => '$cache/song/song.db';
}

InterceptorsWrapper loggingInterceptor = InterceptorsWrapper(
  onError: (e, handler) {
    log(e.message ?? '', name: 'HTTP ERROR ');
    log(e.response?.data.toString() ?? '', name: 'HTTP ERROR ');
    return handler.reject(e);
  },
  onRequest: (options, handler) {
    log(options.toJson().toString(), name: 'HTTP REQUEST');
    return handler.next(options);
  },
  onResponse: (e, handler) {
    log(e.data.toString(), name: 'HTTP RESPONSE');
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
      // Add any other properties you want to include
    };
  }
}

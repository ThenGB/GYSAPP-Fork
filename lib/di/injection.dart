import 'package:chaleno/chaleno.dart';
import 'package:church/data/repository/bible_repository_impl.dart';
import 'package:church/data/repository/scrapper_repository_impl.dart';
import 'package:church/domain/repository/bible_repository/bible_repository.dart';
import 'package:church/domain/repository/scrapper_repository.dart';
import 'package:church/presentations/bible/cubit/bible_cubit.dart';
import 'package:church/presentations/dashboard/cubit/dashboard_cubit.dart';
import 'package:church/presentations/home/bloc/home_cubit.dart';
import 'package:church/presentations/initial/bloc/initial_cubit.dart';
import 'package:church/presentations/literature/cubit/kesaksian/literature_kesaksian_cubit.dart';
import 'package:church/presentations/literature/cubit/panduan/literature_panduan_cubit.dart';
import 'package:church/presentations/literature/cubit/renungan/literature_renungan_cubit.dart';
import 'package:church/presentations/literature/cubit/warta/literature_warta_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

var di = GetIt.I;

setupInjection() {
  _blocs();
  _utils();
  _repositories();
}

_blocs() {
  di.registerFactory(() => HomeCubit(di()));
  di.registerFactory(() => InitialCubit());
  di.registerFactory(() => DashboardCubit());
  di.registerFactory(() => BibleCubit());
  di.registerFactory(() => LiteratureKesaksianCubit(di()));
  di.registerFactory(() => LiteratureWartaCubit(di()));
  di.registerFactory(() => LiteratureRenunganCubit(di()));
  di.registerFactory(() => LiteraturePanduanCubit(di()));
}

_utils() async {
  var document = (await getApplicationDocumentsDirectory()).path;
  var cache = (await getTemporaryDirectory()).path;
  var support = (await getApplicationSupportDirectory()).path;
  di.registerSingleton(AppDirectory(document, cache, support));
  di.registerFactory(() => Chaleno());
}

_repositories() {
  di.registerFactory<ScrapperRepository>(() => ScrapperRepositoryImpl(di()));
  di.registerFactory<BibleRepository>(() => BibleRepositoryImpl());
}

class AppDirectory {
  final String document;
  final String cache;
  final String support;

  AppDirectory(this.document, this.cache, this.support);

  String get bibleFolder => '$cache/bible';
  String get songFolder => '$cache/song';
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/utilities/firebase_utils.dart';
import '../../../domain/entity/banner/banner.dart';
import '../../../domain/entity/menulink/menulink_entity.dart';
import '../../../domain/repository/scrapper_repository.dart';
import 'home_state.dart';

export 'home_state.dart';

class HomeCubit extends HydratedCubit<HomeState> {
  final ScrapperRepository repository;
  CollectionReference bannersCollection =
      FirebaseFirestore.instance.collection('banners');
  late BehaviorSubject<List<ImageBanner>> rxBanner =
      BehaviorSubject<List<ImageBanner>>.seeded([]);

  ValueStream<List<ImageBanner>> get bannerObservable => rxBanner.stream;
  HomeCubit(this.repository) : super(const HomeState()) {
    scrappSauhBagiJiwa();
    scrappTrueVoice();
    getMenu();
    bannersCollection.snapshots().listen((event) {
      final banners = event.docs
          .map((e) => ImageBanner.fromJson(e.data() as Map<String, dynamic>))
          .toList();
      rxBanner.add(banners);
    });
  }

  getMenu() {
    var appMenuJson = FirebaseUtils.listMapConfig('app_menu');
    final List<Menulink> menuLinks =
        appMenuJson.map<Menulink>((e) => Menulink.fromJson(e)).toList();

    emit(state.copyWith(menuLinks: menuLinks));
  }

  scrappSauhBagiJiwa() async {
    var result = await repository.getSauh();
    result.fold(
      (failure) {},
      (res) {
        emit(state.copyWith(sauhs: res));
      },
    );
  }

  scrappTrueVoice() async {
    var result = await repository.getSuaraSejati();
    result.fold(
      (failure) {},
      (res) {
        emit(state.copyWith(trueVoices: res));
      },
    );
  }

  @override
  HomeState? fromJson(Map<String, dynamic> json) {
    return HomeState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(HomeState state) {
    return state.toJson();
  }
}

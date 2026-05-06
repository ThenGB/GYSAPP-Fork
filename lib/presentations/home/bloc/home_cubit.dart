import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    log(FirebaseAuth.instance.currentUser.toString());
    scrappSauhBagiJiwa();
    scrappTrueVoice();
    getMenu();
    bannersCollection.snapshots().listen((event) {
      final banners = event.docs.map((e) {
        final map = (e.data() as Map<String, dynamic>).map(
          (key, value) => MapEntry(key,
              value is Timestamp ? value.toDate().toIso8601String() : value),
        );
        return ImageBanner.fromJson(map);
      }).toList();
      rxBanner.add(banners);
    });
    getPrimaryMenuStatus();
  }

  void refresh() {
    scrappSauhBagiJiwa();
    scrappTrueVoice();
    getMenu();
    getPrimaryMenuStatus();
  }

  Future<void> getMenu() async {
    var appMenuJson = await FirebaseUtils.listMapConfig('app_menu');
    final List<Menulink> menuLinks =
        appMenuJson.map<Menulink>((e) => Menulink.fromJson(e)).toList();

    emit(state.copyWith(menuLinks: menuLinks));
  }

  Future<void> getPrimaryMenuStatus() async {
    var appMenuJson = await FirebaseUtils.jsonConfig('primary_menu');
    final bool isSuaraSejatiEnabled = appMenuJson['suara_sejati'];
    final bool isSauhEnabled = appMenuJson['sauh_bagi_jiwa'];
    emit(state.copyWith(
      isSuaraSejatiEnabled: isSuaraSejatiEnabled,
      isSauhEnabled: isSauhEnabled,
    ));
  }

  Future<void> scrappSauhBagiJiwa() async {
    var result = await repository.getSauh();
    result.fold(
      (failure) {},
      (res) {
        emit(state.copyWith(sauhs: res));
      },
    );
  }

  Future<void> scrappTrueVoice() async {
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

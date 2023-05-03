import 'dart:convert';

import 'package:church/domain/entity/menulink/menulink_entity.dart';
import 'package:church/domain/repository/scrapper_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/entity/banner/banner.dart';
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
    // emit(
    //   state.copyWith(
    //     menuLinks: [
    //       const Menulink(
    //         label: 'Rhema',
    //         icon: Assets.assetsIconsRhema,
    //         url: '#',
    //       ),
    //       const Menulink(
    //         label: 'Literatur',
    //         icon: Assets.assetsIconsLiteratur,
    //         url: '#',
    //       ),
    //       const Menulink(
    //         label: 'Podcast',
    //         icon: Assets.assetsIconsPodcast,
    //         url: '#',
    //       ),
    //       const Menulink(
    //         label: 'Khotbah',
    //         icon: Assets.assetsIconsKhotbah,
    //         url: '#',
    //       ),
    //       const Menulink(
    //         label: 'Facebook',
    //         icon: Assets.assetsIconsFacebook,
    //         url: '#',
    //       ),
    //       const Menulink(
    //         label: 'Instagram',
    //         icon: Assets.assetsIconsInstagram,
    //         url: '#',
    //       ),
    //       const Menulink(
    //         label: 'Youtube',
    //         icon: Assets.assetsIconsYoutube,
    //         url: '#',
    //       ),
    //       const Menulink(
    //         label: 'Spotify',
    //         icon: Assets.assetsIconsSpotify,
    //         url: '#',
    //       ),
    //     ],
    //   ),
    // );
  }

  getMenu() {
    var appMenuJsonString = FirebaseRemoteConfig.instance.getString('app_menu');
    var appMenuJson = jsonDecode(appMenuJsonString);
    final List<Menulink> menuLinks = appMenuJson
        .map<Menulink>((e) => Menulink.fromJson(e as Map<String, dynamic>))
        .toList();

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

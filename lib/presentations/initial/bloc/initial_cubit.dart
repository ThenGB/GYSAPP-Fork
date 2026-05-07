import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../app.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/firebase_utils.dart';
import '../../../data/utilities/platform_utils.dart';
import '../../../data/utilities/variables/failure.dart';
import '../../../di/injection.dart';
import 'initial_state.dart';

export 'initial_state.dart';

class InitialCubit extends HydratedCubit<InitialState> {
  InitialCubit() : super(const InitialState());

  Future<void> getRemoteConfig() async {
    if (!isFirebaseConfiguredForCurrentPlatform) {
      FirebaseUtils.useFallbackConfig();
      return;
    }
    try {
      FirebaseRemoteConfig.instance.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: Duration(
              seconds: kReleaseMode ? state.configFetchTimeoutSeconds : 5),
          minimumFetchInterval: Duration(
              seconds: kReleaseMode ? state.configFetchIntervalSeconds : 1),
        ),
      );
      var isConnectedToInternet =
          (await internetChecker.isHostReachable(defaultAddress)).isSuccess;
      if (isConnectedToInternet) {
        /// default as per 17 January 2025
        await FirebaseRemoteConfig.instance.setDefaults({
          'enable_memberarea': 'true',
          'notifikasi_bible':
              '{"title":{"en":"Its time to read the Bible..","id":"Waktunya membaca..","zh":"讀經時了.."},"body":{"en":"Have you read the Bible today?","id":"Sudahkah membaca Alkitab hari ini?","zh":"今日讀經了嗎?"},"imageUrl":"https://tjc.org/wp-content/uploads/2016/05/tjclogo_english_680x88.png"}',
          'primary_menu': '{"sauh_bagi_jiwa":true,"suara_sejati":true}',
          'footer_copied_text':
              '{\n  "en": "Download GYS App on\\n\\nPlaystore \\nhttps://play.store.com\\n\\nAppStore \\nhttps://app.store.com",\n    "id": "Download GYS App on\\n\\nPlaystore \\nhttps://play.store.com\\n\\nAppStore \\nhttps://app.store.com",\n      "zh": "Download GYS App on\\n\\nPlaystore \\nhttps://play.store.com\\n\\nAppStore \\nhttps://app.store.com"\n}',
          'testpath': 'asdasdasdasdasdasdasd',
          'app_menu':
              '[{"label":"eRhema","icon":"https://play-lh.googleusercontent.com/nxpU2jVSvYA4JnGWPHzw-l5j23DIgIqumkdR_aiOndyhjNB2fEkS9Tp296G-p6VX8E8","url":"https://Bible.tjc.org","enabled":true},{"label":"PelitaKecil","icon":"assets/icons/rhema.png","url":"https://pelitakecil.com/","enabled":true},{"label":"Literatur","icon":"assets/icons/literatur.png","url":"/literature","enabled":true},{"label":"Podcast","icon":"assets/icons/podcast.png","url":"https://www.youtube.com/channel/UCnKhYlQA5iJJvobPF4IYJFQ","enabled":true},{"label":"Khotbah","icon":"assets/icons/khotbah.png","url":"khotbah","enabled":true},{"label":"Facebook","icon":"assets/icons/facebook.png","url":"https://www.facebook.com/gerejayesussejati/","enabled":true},{"label":"Instagram","icon":"assets/icons/instagram.png","url":"https://www.instagram.com/gerejayesussejati/","enabled":true},{"label":"Youtube","icon":"assets/icons/youtube.png","url":"https://www.youtube.com/channel/UCAHSLvPBcg2M-_N1VQfhxrg","enabled":true},{"label":"Spotify","icon":"assets/icons/spotify.png","url":"https://open.spotify.com/show/4edDo52t3IlkgiWhBnk1GK","enabled":true}]',
          'biblepath': '/Project/Hatiku/v2/alkitab',
          'config_literature':
              '{"kesaksian":"#posts-table-1 \u003e tbody \u003e tr \u003e td \u003e a","wartasejati":"#posts-table-2 \u003e tbody \u003e tr \u003e td \u003e a","panduanalkitab":"article","renungan":"div.module.module-accordion.tb_1uum169 \u003e ul \u003e li \u003e div \u003e div \u003e div \u003e table \u003e tbody \u003e tr \u003e td \u003e a","pelitakecil":"#posts-table-3 \u003e tbody \u003e tr \u003e td \u003e a","notifikasi_sabat":{"title":"Notifikasi Sabat","body":"Ingat dan Kuduskanlah Hari Sabat ... ","image":"https://tjc.org/wp-content/uploads/2016/05/tjclogo_english_680x88.png"}}',
          'mailer_recipients':
              '[{"address":"harley@itmandiri.com","name":"Pak Harley"}]',
          'ftp_server':
              '{"host":"194.233.65.230","port":"821","username":"itm","password":"56983466"}',
          'bible_name':
              '{"Perjanjian lama":{"b_kjv":"Old Testament","b_tb":"Perjanjian Lama","b_cuv":"舊約聖經"},"Perjanjian baru":{"b_kjv":"New Testament","b_tb":"Perjanjian Baru","b_cuv":"新約聖經"}}',
          'literature_panduan_alkitab':
              '[{"title":"Panduan Kitab Roma","img":"https://tjc.org/id/wp-content/uploads/sites/43/2020/04/cover-PA-Roma.jpg","link":"https://tjc.org/id/wp-content/uploads/sites/43/2020/04/Roma.pdf"},{"title":"Panduan Kitab Markus","img":"https://tjc.org/id/wp-content/uploads/sites/43/2021/05/cover-PA-Markus.jpg","link":"https://tjc.org/id/wp-content/uploads/sites/43/2021/05/Markus.pdf"},{"title":"Panduan Kitab 2 Korintus","img":"https://tjc.org/id/wp-content/uploads/sites/43/2022/08/cover-2-Korintus.jpg","link":"http://tjc.org/id/wp-content/uploads/sites/43/2022/08/Kitab-2-Korintus.pdf"},{"title":"Panduan Kitab Matius","img":"https://tjc.org/id/wp-content/uploads/sites/43/2019/08/cover-PA-Matius.jpg","link":"https://tjc.org/id/wp-content/uploads/sites/43/2019/08/Matius.pdf"},{"title":"Panduan Kitab Kejadian","img":"https://tjc.org/id/wp-content/uploads/sites/43/2024/04/cover-kejadian-website.jpg","link":"https://tjc.org/id/wp-content/uploads/sites/43/2024/04/Kejadian.pdf"},{"title":"Panduan Kitab Lukas","img":"https://tjc.org/id/wp-content/uploads/sites/43/2019/08/cover-PA-Lukas.jpg","link":"https://tjc.org/id/wp-content/uploads/sites/43/2019/08/PA-Lukas.pdf"},{"title":"Panduan Kitab Yohanes","img":"https://tjc.org/id/wp-content/uploads/sites/43/2019/08/cover-PA-Yohanes.jpg","link":"https://tjc.org/id/wp-content/uploads/sites/43/2019/08/PA-yohanes.pdf"},{"title":"Panduan Kitab Kisah Rasul","img":"https://tjc.org/id/wp-content/uploads/sites/43/2019/08/cover-PA-Kisah-Para-Rasul.jpg","link":"https://tjc.org/id/wp-content/uploads/sites/43/2019/08/Panduan-Pemahaman-Alkitab-Kisah-Para-Rasul.pdf"},{"title":"Panduan Kitab 1 Korintus","img":"https://tjc.org/id/wp-content/uploads/sites/43/2020/01/cover-PA-1-korintus.jpg","link":"https://tjc.org/id/wp-content/uploads/sites/43/2020/06/PA-1-Korintus.pdf"},{"title":"Panduan Kitab Galatia, Efesus, Filipi, Kolose","img":"https://tjc.org/id/wp-content/uploads/sites/43/2019/08/cover-PA-Galatia-Efesus-Filipi-Kolose.jpg","link":"https://tjc.org/id/wp-content/uploads/sites/43/2021/05/Panduan-Pemahaman-Alkitab-Galatia-Efesus-Filipi-Kolose-revisi.pdf"},{"title":"Panduan Kitab Tesalonika, Timotius, Titus","img":"https://tjc.org/id/wp-content/uploads/sites/43/2019/08/cover-PA-Tesalonika-Timotius-Titus.jpg","link":"https://tjc.org/id/wp-content/uploads/sites/43/2019/08/Panduan-Pemahaman-Alkitab-Tesalonika-Timotius-Titus.pdf"},{"title":"Panduan Kitab Filemon, Ibrani","img":"https://tjc.org/id/wp-content/uploads/sites/43/2019/08/cover-PA-Filemon-Ibrani.jpg","link":"https://tjc.org/id/wp-content/uploads/sites/43/2019/08/Filemon-dan-Ibrani.pdf"},{"title":"Panduan Kitab Yakobus, 1 dan 2 Petrus","img":"https://tjc.org/id/wp-content/uploads/sites/43/2024/04/cover-bsg-yakobus-1.jpg","link":"https://tjc.org/id/wp-content/uploads/sites/43/2019/08/Panduan-Pemahaman-Alkitab-Yakobus-1-2-Petrus.pdf"},{"title":"Panduan Kitab 1,2 dan 3 Yohanes, Yudas, Wahyu","img":"https://tjc.org/id/wp-content/uploads/sites/43/2019/08/123-yohanes-print-01-cover.jpg","link":"https://tjc.org/id/wp-content/uploads/sites/43/2019/08/PA-123-Yohanes-Yudas-Wahyu.pdf"}]',
          'bible_codename':
              '{"KJV":"King James Version","CUV":"Chinese Union Version","TB":"Terjemahan Baru"}',
          'notifikasi_sabat':
              '{"title":"Notifikasi Sabat","body":"Ingat dan Kuduskanlah Hari Sabat  ...  ","imageUrl":"https://tjc.org/wp-content/uploads/2016/05/tjclogo_english_680x88.png"}',
          'mailer_credentials':
              '{"username":"hatiku.app@gmail.com","password":"rjnsfeygekniyfil"}',
          'firebase_remote_config':
              '{"fetch_timeout":10,"fetch_interval":3600}',
          'sauhconfig':
              "var swiperSlides \u003d document.querySelectorAll(\u0027.tf_swiper-slide\u0027);\n        var slideData \u003d [];\n\n        swiperSlides.forEach(function(slide) {\n            var titleElement \u003d slide.querySelector(\u0027.slide-content.tb_text_wrap h3\u0027);\n            var linkElement \u003d titleElement ? titleElement.querySelector(\u0027a\u0027) : null; // Search for an \u0027a\u0027 tag within the \u0027h3\u0027\n            var imageElement \u003d slide.querySelector(\u0027img\u0027);\n            var slideInfo \u003d {};\n\n            if (titleElement) {\n                slideInfo.title \u003d titleElement.textContent.trim();\n            }\n\n            // If the link element exists, add its href to slideInfo\n            if (linkElement) {\n                slideInfo.linkUrl \u003d linkElement.href;\n            }\n\n            if (imageElement) {\n                slideInfo.imageUrl \u003d imageElement.dataset.tfSrc;\n            }\n\n            if (Object.keys(slideInfo).length \u003e 0) {\n                slideData.push(slideInfo);\n            }\n        });\n\n        var slideDataJson \u003d slideData;\n        slideDataJson;"
        });
        var value = await FirebaseRemoteConfig.instance.fetchAndActivate();
        log((value).toString(), name: '[Firebase remote config]');
      }
    } catch (e) {
      log(Failure.fromError(e).message, name: 'getRemoteConfig', error: e);
    }
    FirebaseUtils.complete(FirebaseRemoteConfig.instance);
  }

  Future<void> initState() async {
    emit(
      state.copyWith(
        message: 'Initiating...',
      ),
    );
    await di.allReady();
    log('Initiating application state');
    var result =
        (await internetChecker.isHostReachable(defaultAddress)).isSuccess;
    if (!result && state.isFreshInstall) {
      emit(
        state.copyWith(
          isFailed: true,
          message:
              'First time installation failed. Please connect to the internet and try again.',
          isLoading: false,
          isLoaded: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isFailed: false,
          message: 'Syncing...',
          isFreshInstall: false,
          isLoading: false,
          isLoaded: true,
        ),
      );
    }
    await getRemoteConfig();
    var firebaseRemoteConfig =
        await FirebaseUtils.jsonConfig('firebase_remote_config');
    emit(
      state.copyWith(
        configFetchTimeoutSeconds: firebaseRemoteConfig['fetch_timeout'] ??
            state.configFetchTimeoutSeconds,
        configFetchIntervalSeconds: firebaseRemoteConfig['fetch_interval'] ??
            state.configFetchIntervalSeconds,
      ),
    );

    if (isFirebaseConfiguredForCurrentPlatform) {
      try {
        await FirebaseAuth.instance
            .signInAnonymously()
            .timeout(Duration(seconds: 5));
      } catch (e) {
        log('Cant log in anonymously ${e.toString()}', name: 'Firebase Auth');
      }
    }
  }

  void toggleTheme(ThemeMode themeMode, BuildContext Function() context) {
    emit(state.copyWith(themeMode: themeMode.toThemeString));
    Future.delayed(
      kThemeChangeDuration,
      () {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          SystemChrome.setSystemUIOverlayStyle(
              context().theme.appBarTheme.systemOverlayStyle!);
        });
      },
    );
  }

  void changeTextScale(double newScale) {
    emit(state.copyWith(defaultTextScale: newScale));
  }

  void changeFontStyle(String newValue) {
    emit(state.copyWith(defaultFont: newValue));
  }

  @override
  InitialState? fromJson(Map<String, dynamic> json) {
    try {
      return InitialState.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(InitialState state) {
    try {
      return state.toJson();
    } catch (e) {
      return null;
    }
  }
}


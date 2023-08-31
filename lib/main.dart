import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() async {
  runZonedGuarded(
    () async {
      await initApplication();
      runApp(
        EasyLocalization(
          startLocale: const Locale('id', 'ID'),
          supportedLocales: const [
            Locale('id', 'ID'),
            Locale('en', 'US'),
            Locale('zh', 'ZH'),
          ],
          path: 'assets/translations',
          assetLoader: SmartNetworkAssetLoader(
            localeUrl: (String localeName) {
              var url = 'https://e.gys.or.id/assets/translations/';
              log('GETTING Locale from network $url');
              return url;
            },
            assetsPath: 'assets/translations',
            localCacheDuration: Duration(seconds: 1),
          ),
          useOnlyLangCode: true,
          child: const App(),
        ),
      );
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

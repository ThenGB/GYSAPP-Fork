import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() async {
  await initApplication();
  runApp(
    EasyLocalization(
      startLocale: const Locale('en', 'US'),
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
        Locale('zh', 'ZH'),
      ],
      path: 'assets/translations',
      useOnlyLangCode: true,
      saveLocale: true,
      child: const App(),
    ),
  );
}

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_preview_screenshot/device_preview_screenshot.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' as paths;

import 'app.dart';
import 'data/utilities/platform_utils.dart';

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
              log('GETTING Locale from network $url$localeName.json');
              return url;
            },
            assetsPath: 'assets/translations',
            localCacheDuration: Duration(seconds: 1),
          ),
          useOnlyLangCode: true,
          child: DevicePreview(
            enabled: false,
            tools: [
              ...DevicePreview.defaultTools,
              DevicePreviewScreenshot(
                onScreenshot: (context, screenshot) async {
                  var result = base64.encode(screenshot.bytes);
                  await Clipboard.setData(
                    ClipboardData(text: result),
                  );
                  log('Screenshot ${screenshot.device.identifier}');
                },
              ),
            ],
            builder: (context) => const App(),
          ),
        ),
      );
    },
    (error, stack) {
      if (isFirebaseCrashlyticsConfiguredForCurrentPlatform &&
          Firebase.apps.isNotEmpty) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return;
      }
      log(
        'Uncaught zoned error',
        error: error,
        stackTrace: stack,
      );
    },
  );
}

/// ```dart
/// SmartNetworkAssetLoader(
///           assetsPath: 'assets/translations',
///           localCacheDuration: Duration(days: 1),
///           localeUrl: (String localeName) => Constants.appLangUrl,
///           timeout: Duration(seconds: 30),
///         )
/// ```
class SmartNetworkAssetLoader extends AssetLoader {
  final Function localeUrl;

  final Duration timeout;

  final String assetsPath;

  final Duration localCacheDuration;

  SmartNetworkAssetLoader(
      {required this.localeUrl,
      this.timeout = const Duration(seconds: 30),
      required this.assetsPath,
      this.localCacheDuration = const Duration(days: 1)});

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    var string = '';

    // try loading local previously-saved localization file
    if (await localTranslationExists(locale.toString())) {
      string = await loadFromLocalFile(locale.toString());
    }

    // no local or failed, check if internet and download the file
    if (string == '' && await isInternetConnectionAvailable()) {
      string = await loadFromNetwork(locale.toString());
    }

    // local cache duration was reached or no internet access but prefer local file to assets
    if (string == '' &&
        await localTranslationExists(locale.toString(),
            ignoreCacheDuration: true)) {
      string = await loadFromLocalFile(locale.toString());
    }

    // still nothing? Load from assets
    if (string == '') {
      string = await rootBundle.loadString('$assetsPath/$locale.json');
    }

    // then returns the json file
    return json.decode(string);
  }

  Future<bool> localeExists(String localePath) => Future.value(true);

  Future<bool> isInternetConnectionAvailable() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    } else {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } on SocketException catch (_) {
        return false;
      }
    }

    return false;
  }

  Future<String> loadFromNetwork(String localeName) async {
    String url = localeUrl(localeName);

    url = '$url$localeName.json';

    try {
      final response =
          await Future.any([http.get(Uri.parse(url)), Future.delayed(timeout)]);

      if (response != null && response.statusCode == 200) {
        var content = utf8.decode(response.bodyBytes);

        // check valid json before saving it
        if (json.decode(content) != null) {
          await saveTranslation(localeName, content);
          return content;
        }
      }
    } catch (e) {
      log(e.toString());
    }

    return '';
  }

  Future<bool> localTranslationExists(String localeName,
      {bool ignoreCacheDuration = false}) async {
    var translationFile = await getFileForLocale(localeName);

    if (!await translationFile.exists()) {
      return false;
    }

    // don't check file's age
    if (!ignoreCacheDuration) {
      var difference =
          DateTime.now().difference(await translationFile.lastModified());

      if (difference > (localCacheDuration)) {
        return false;
      }
    }

    return true;
  }

  Future<String> loadFromLocalFile(String localeName) async {
    return await (await getFileForLocale(localeName)).readAsString();
  }

  Future<void> saveTranslation(String localeName, String content) async {
    var file = File(await getFilenameForLocale(localeName));
    await file.create(recursive: true);
    await file.writeAsString(content);
    log('saved');
  }

  Future<String> get _localPath async {
    final directory = await paths.getTemporaryDirectory();

    return directory.path;
  }

  Future<String> getFilenameForLocale(String localeName) async {
    return '${await _localPath}/translations/$localeName.json';
  }

  Future<File> getFileForLocale(String localeName) async {
    return File(await getFilenameForLocale(localeName));
  }
}


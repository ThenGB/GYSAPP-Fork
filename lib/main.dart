import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' as paths;

import 'app.dart';

void main() async {
  runZonedGuarded(
    () async {
      // Initialize MarionetteBinding for screenshot support in debug mode
      if (kDebugMode) {
        MarionetteBinding.ensureInitialized();
      } else {
        WidgetsFlutterBinding.ensureInitialized();
      }

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
            localCacheDuration: const Duration(days: 1),
            timeout: const Duration(seconds: 2),
          ),
          useOnlyLangCode: true,
          child: const App(),
        ),
      );
    },
    (error, stack) {
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
    final localeName = locale.languageCode;
    var string = '';

    if (await localTranslationExists(localeName)) {
      string = await loadFromLocalFile(localeName);
    }

    if (string == '') {
      string = await rootBundle.loadString('$assetsPath/$localeName.json');
    }

    unawaited(_refreshFromNetwork(localeName));

    return json.decode(string) as Map<String, dynamic>;
  }

  Future<void> _refreshFromNetwork(String localeName) async {
    try {
      if (await isInternetConnectionAvailable()) {
        await loadFromNetwork(localeName);
      }
    } catch (e) {
      log(e.toString());
    }
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
      final response = await http.get(Uri.parse(url)).timeout(timeout);

      if (response.statusCode == 200) {
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

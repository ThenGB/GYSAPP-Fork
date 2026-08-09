import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:path_provider/path_provider.dart' as paths;

import 'app.dart';

void main() async {
  runZonedGuarded(
    () async {
      if (kDebugMode && !kIsWeb) {
        // Marionette: lets AI agents inspect and drive the app at runtime
        // (VM-service based). Debug builds only. Web does not support it
        // (same guard as initApplication in app.dart).
        MarionetteBinding.ensureInitialized();
      }
      // Only ensure initialization - actual binding done in app.dart via initApplication()
      WidgetsFlutterBinding.ensureInitialized();

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

    // Web has no local filesystem (dart:io File throws, and path_provider
    // has no web implementation registered unless the app explicitly
    // depends on path_provider_web) — skip the file cache and rely on the
    // bundled assets + network refresh is skipped as well (the JSON ships
    // with the app bundle).
    if (!kIsWeb && await localTranslationExists(localeName)) {
      string = await loadFromLocalFile(localeName);
    }

    // Stale-cache guard: after an app update the bundled translations can
    // contain keys the cached file (fetched days ago) does not have.  The
    // cached file is merged over the bundle, but the bundle's keys are the
    // source of truth for the CURRENT app version — any key missing from the
    // cache is filled in from the bundle so new UI labels never render as
    // raw keys (e.g. "bible_book") after an update.
    if (string != '') {
      try {
        final bundledStr = await rootBundle.loadString(
          '$assetsPath/$localeName.json',
        );
        final cachedMap = (json.decode(string) as Map).cast<String, dynamic>();
        final bundledMap =
            (json.decode(bundledStr) as Map).cast<String, dynamic>();
        var merged = false;
        for (final entry in bundledMap.entries) {
          if (!cachedMap.containsKey(entry.key)) {
            cachedMap[entry.key] = entry.value;
            merged = true;
          }
        }
        if (merged) {
          string = json.encode(cachedMap);
        }
      } catch (_) {
        // Keep the cached file if the bundle can't be read.
      }
    }

    if (string == '') {
      string = await rootBundle.loadString('$assetsPath/$localeName.json');
    }

    if (!kIsWeb) {
      unawaited(_refreshFromNetwork(localeName));
    }

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

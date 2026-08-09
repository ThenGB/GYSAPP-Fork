import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' as paths;

import 'app.dart';

void main() {
  runZonedGuarded(
    () async {
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
              const url = 'https://e.gys.or.id/assets/translations/';
              if (kDebugMode) {
                log('GETTING Locale from network $url$localeName.json');
              }
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
      log('Uncaught zoned error', error: error, stackTrace: stack);
    },
  );
}

/// Loads bundled translations immediately, then refreshes the on-disk cache
/// in the background on native platforms. Network refresh is deliberately
/// fire-and-forget so localization never delays the first usable frame.
class SmartNetworkAssetLoader extends AssetLoader {
  final String Function(String localeName) localeUrl;
  final Duration timeout;
  final String assetsPath;
  final Duration localCacheDuration;

  SmartNetworkAssetLoader({
    required this.localeUrl,
    this.timeout = const Duration(seconds: 30),
    required this.assetsPath,
    this.localCacheDuration = const Duration(days: 1),
  });

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final localeName = locale.languageCode;
    var string = '';

    // Web has no native filesystem. Native platforms can reuse a fresh cache
    // while always falling back to the translation JSON shipped with the app.
    if (!kIsWeb && await localTranslationExists(localeName)) {
      string = await loadFromLocalFile(localeName);
    }

    // Merge newly shipped keys into an older cached translation. This keeps
    // a network cache from hiding labels introduced by an app update.
    if (string.isNotEmpty) {
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
        if (merged) string = json.encode(cachedMap);
      } catch (_) {
        // Keep the cached file if the bundle cannot be read.
      }
    }

    if (string.isEmpty) {
      string = await rootBundle.loadString('$assetsPath/$localeName.json');
    }

    if (!kIsWeb) {
      unawaited(_refreshFromNetwork(localeName));
    }

    return (json.decode(string) as Map).cast<String, dynamic>();
  }

  Future<void> _refreshFromNetwork(String localeName) async {
    try {
      // Avoid connectivity/DNS preflight checks. The real HTTP request already
      // has a strict timeout and is a more reliable reachability signal.
      await loadFromNetwork(localeName);
    } catch (e) {
      if (kDebugMode) log('Translation refresh failed: $e');
    }
  }

  Future<String> loadFromNetwork(String localeName) async {
    final url = '${localeUrl(localeName)}$localeName.json';
    try {
      final response = await http.get(Uri.parse(url)).timeout(timeout);
      if (response.statusCode != 200) return '';

      final content = utf8.decode(response.bodyBytes);
      final decoded = json.decode(content);
      if (decoded is! Map) return '';

      await saveTranslation(localeName, content);
      return content;
    } catch (e) {
      if (kDebugMode) log('Translation download failed: $e');
      return '';
    }
  }

  Future<bool> localTranslationExists(
    String localeName, {
    bool ignoreCacheDuration = false,
  }) async {
    final translationFile = await getFileForLocale(localeName);
    if (!await translationFile.exists()) return false;

    if (!ignoreCacheDuration) {
      final difference = DateTime.now().difference(
        await translationFile.lastModified(),
      );
      if (difference > localCacheDuration) return false;
    }
    return true;
  }

  Future<String> loadFromLocalFile(String localeName) async {
    return (await getFileForLocale(localeName)).readAsString();
  }

  Future<void> saveTranslation(String localeName, String content) async {
    final file = File(await getFilenameForLocale(localeName));
    await file.create(recursive: true);
    await file.writeAsString(content, flush: false);
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

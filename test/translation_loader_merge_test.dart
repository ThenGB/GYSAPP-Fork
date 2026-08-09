import 'dart:convert';
import 'dart:io';

import 'package:church/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String temporaryPath;
  _FakePathProviderPlatform(this.temporaryPath);

  @override
  Future<String?> getTemporaryPath() async => temporaryPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'translation loader merges bundle keys over a stale cached file',
    () async {
      final tmp = await Directory.systemTemp.createTemp('church_trans_');
      addTearDown(() async {
        if (await tmp.exists()) await tmp.delete(recursive: true);
      });
      PathProviderPlatform.instance = _FakePathProviderPlatform(tmp.path);

      // Simulate a cache fetched BEFORE the app update: it is missing the
      // new keys the bundle ships with.
      final cacheDir = Directory('${tmp.path}/translations');
      await cacheDir.create(recursive: true);
      final cacheFile = File('${cacheDir.path}/id.json');
      await cacheFile.writeAsString(
        jsonEncode({
          'old_key': 'nilai lama',
          'bible_playback_title': 'Pemutaran Alkitab (lama)',
        }),
      );

      final loader = SmartNetworkAssetLoader(
        localeUrl: (_) => 'https://example.invalid/assets/translations/',
        assetsPath: 'assets/translations',
        timeout: const Duration(seconds: 1),
        localCacheDuration: const Duration(days: 1),
      );

      final map = await loader.load('id', const Locale('id', 'ID'));

      // Existing cached values are kept…
      expect(map['old_key'], 'nilai lama');
      expect(map['bible_playback_title'], 'Pemutaran Alkitab (lama)');
      // …while keys missing from the cache are filled from the bundle, so
      // headings like "bible_book" never render as raw keys after an update.
      expect(map['bible_range_title'], 'Rentang pemutaran');
      expect(map['bible_book'], 'Kitab');
      expect(map['bible_range_chapter_end'], 'Sampai akhir pasal');
      expect(map.containsKey('bible_range_summary'), isTrue);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

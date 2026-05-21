import 'dart:io';

import 'package:church/data/services/asset_distribution/asset_cache_maintenance_service.dart';
import 'package:church/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory rootDir;
  late AppDirectory appDirectory;

  setUp(() async {
    rootDir = await Directory.systemTemp.createTemp(
      'church_asset_cache_maintenance_',
    );
    appDirectory = AppDirectory(
      '${rootDir.path}/documents',
      '${rootDir.path}/cache',
      '${rootDir.path}/support',
    );
  });

  tearDown(() async {
    if (await rootDir.exists()) {
      await rootDir.delete(recursive: true);
    }
  });

  test('clears fast-access cache while preserving installed bible and hymnal files', () async {
    final service = AssetCacheMaintenanceService(appDirectory: appDirectory);

    final installedBible = File('${appDirectory.bibleFolder}/b_kjv.db')
      ..createSync(recursive: true);
    await installedBible.writeAsBytes(const [1, 2, 3]);

    final installedHymnal = File('${appDirectory.hymnalFolder}/hymne_master.pdf')
      ..createSync(recursive: true);
    await installedHymnal.writeAsBytes(const [4, 5, 6]);

    final preparedMaster = File('${appDirectory.preparedPdfFolder}/kr_master.pdf')
      ..createSync(recursive: true);
    await preparedMaster.writeAsBytes(const [7, 8, 9]);

    final noteCache = File('${appDirectory.pdfNoteCacheFolder}/note.json')
      ..createSync(recursive: true);
    await noteCache.writeAsString('{}');

    final midiCache = File('${appDirectory.songRenderCacheFolder}/render.wav')
      ..createSync(recursive: true);
    await midiCache.writeAsBytes(const [9, 9, 9]);

    await service.clearFastAccessCache();

    expect(await installedBible.exists(), isTrue);
    expect(await installedHymnal.exists(), isTrue);
    expect(await preparedMaster.exists(), isFalse);
    expect(await noteCache.exists(), isFalse);
    expect(await midiCache.exists(), isFalse);
  });
}

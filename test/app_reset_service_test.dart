import 'dart:io';

import 'package:church/data/services/app_reset_service.dart';
import 'package:church/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  late Directory rootDir;
  late AppDirectory appDirectory;
  late _MemoryStorage storage;
  late bool notificationsCancelled;

  setUp(() async {
    rootDir = await Directory.systemTemp.createTemp('church_app_reset_test_');
    appDirectory = AppDirectory(
      '${rootDir.path}/documents',
      '${rootDir.path}/cache',
      '${rootDir.path}/support',
    );
    storage = _MemoryStorage();
    notificationsCancelled = false;
  });

  tearDown(() async {
    if (await rootDir.exists()) {
      await rootDir.delete(recursive: true);
    }
  });

  test(
    'wipes app directories, clears hydrated storage, and cancels notifications',
    () async {
      final service = AppResetService(
        appDirectory: appDirectory,
        storage: storage,
        cancelNotifications: () async {
          notificationsCancelled = true;
        },
      );

      final preparedMaster = File(
        '${appDirectory.preparedPdfFolder}/kr_master.pdf',
      )..createSync(recursive: true);
      await preparedMaster.writeAsBytes(const [1, 2, 3]);

      final installedBible = File('${appDirectory.bibleFolder}/b_kjv.db')
        ..createSync(recursive: true);
      await installedBible.writeAsBytes(const [4, 5, 6]);

      final installedHymnal = File(
        '${appDirectory.hymnalFolder}/hymne_master.pdf',
      )..createSync(recursive: true);
      await installedHymnal.writeAsBytes(const [7, 8, 9]);

      final midiCache = File('${appDirectory.songRenderCacheFolder}/render.wav')
        ..createSync(recursive: true);
      await midiCache.writeAsBytes(const [9, 9, 9]);

      final backupFile = File('${appDirectory.backupFolder}/latest.gysbk')
        ..createSync(recursive: true);
      await backupFile.writeAsString('backup');

      await service.wipeEverything();

      expect(storage.clearCalls, 1);
      expect(storage.closeCalls, 1);
      expect(notificationsCancelled, isTrue);
      expect(await preparedMaster.exists(), isFalse);
      expect(await installedBible.exists(), isFalse);
      expect(await installedHymnal.exists(), isFalse);
      expect(await midiCache.exists(), isFalse);
      expect(await backupFile.exists(), isFalse);
      expect(await Directory(appDirectory.document).exists(), isTrue);
      expect(await Directory(appDirectory.cache).exists(), isTrue);
      expect(await Directory(appDirectory.support).exists(), isTrue);
    },
  );
}

class _MemoryStorage implements Storage {
  int clearCalls = 0;
  int closeCalls = 0;

  @override
  Future<void> clear() async {
    clearCalls++;
  }

  @override
  Future<void> close() async {
    closeCalls++;
  }

  @override
  Future<void> delete(String key) async {}

  @override
  dynamic read(String key) => null;

  @override
  Future<void> write(String key, dynamic value) async {}
}

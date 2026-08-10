import 'dart:io';

import 'package:church/data/services/fast_hydrated_storage_native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hydrated write is durable before its Future is awaited', () async {
    final directory = Directory.systemTemp.createTempSync(
      'gys-fast-storage-test-',
    );
    addTearDown(() async {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    });

    final storage = FastFileStorage(cacheDir: directory);
    await storage.init();

    final pendingWrite = storage.write('preferences', <String, dynamic>{
      'theme': 'dark',
      'accent': 'red',
    });

    // Simulate a new process/storage instance immediately, before awaiting the
    // Future returned by Storage.write. The synchronous flushed write should
    // already be visible on disk.
    final restored = FastFileStorage(cacheDir: directory);
    await restored.init();

    expect(restored.read('preferences'), <String, dynamic>{
      'theme': 'dark',
      'accent': 'red',
    });

    await pendingWrite;
    await storage.close();
    await restored.close();
  });

  test('identical consecutive writes skip the disk flush', () async {
    final directory = Directory.systemTemp.createTempSync(
      'gys-fast-storage-test-',
    );
    addTearDown(() async {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    });

    final storage = FastFileStorage(cacheDir: directory);
    await storage.init();

    await storage.write('tts', <String, dynamic>{'word': 'A'});
    final stateFile = File('${directory.path}/__bloc_tts.json');
    // dart:io reports second-resolution mtimes on Windows, so every
    // observation crosses a second boundary to stay deterministic.
    await _waitForNextSecond();
    final firstMtime = stateFile.lastModifiedSync();

    // High-frequency transient emits with an identical snapshot must not
    // touch the disk again: the file mtime must survive the burst unchanged.
    // The burst runs in a *different* second than [firstMtime] so any flush
    // inside it would bump the mtime past the baseline.
    await _waitForNextSecond();
    for (var i = 0; i < 20; i++) {
      await storage.write('tts', <String, dynamic>{'word': 'A'});
    }
    expect(stateFile.lastModifiedSync(), firstMtime);
    expect(stateFile.readAsStringSync(), contains('"word":"A"'));

    // A changed snapshot does persist.
    await _waitForNextSecond();
    await storage.write('tts', <String, dynamic>{'word': 'B'});
    expect(stateFile.lastModifiedSync().isAfter(firstMtime), isTrue);
    expect(storage.read('tts'), <String, dynamic>{'word': 'B'});

    await storage.close();
  });
}

Future<void> _waitForNextSecond() async {
  final start = DateTime.now();
  while (DateTime.now().second == start.second) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    if (DateTime.now().difference(start).inSeconds >= 2) break;
  }
}

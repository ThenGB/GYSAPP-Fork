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
}

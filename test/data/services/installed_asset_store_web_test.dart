import 'dart:typed_data';

import 'package:church/data/services/asset_distribution/installed_asset_store_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_client_memory.dart';

/// Regression coverage for the web install pipeline: downloaded bible bytes
/// and the registry JSON are persisted in IndexedDB (here the in-memory
/// factory), listed, read back and deleted — the exact operations the
/// download/load flow performs on web.
void main() {
  late IdbFactory factory;
  late IndexedDbInstalledAssetStore store;

  setUp(() {
    factory = newIdbFactoryMemory();
    store = IndexedDbInstalledAssetStore(
      databaseName: 'test_gys_installed_assets',
      idbFactory: factory,
    );
  });

  test('write, list and read files', () async {
    await store.writeFile('bible/b_kjv.db', Uint8List.fromList([1, 2, 3]));
    await store.writeFile('bible/b_cuv.db', Uint8List.fromList([4, 5, 6]));
    await store.writeFile('registry.json', Uint8List.fromList([9]));

    final bibleFiles = await store.listFiles('bible');
    expect(bibleFiles, containsAll(['bible/b_kjv.db', 'bible/b_cuv.db']));
    expect(bibleFiles.any((f) => f.startsWith('bible/')), isTrue);
    expect(await store.exists('bible/b_kjv.db'), isTrue);
    expect(await store.readFile('bible/b_kjv.db'), [1, 2, 3]);
    expect(await store.exists('bible/missing.db'), isFalse);
  });

  test('delete removes the file', () async {
    await store.writeFile('bible/b_kjv.db', Uint8List.fromList([1, 2, 3]));
    await store.deleteFile('bible/b_kjv.db');
    expect(await store.exists('bible/b_kjv.db'), isFalse);
    expect(await store.readFile('bible/b_kjv.db'), isNull);
  });

  test('persists across store instances sharing the same database', () async {
    await store.writeFile('bible/b_kjv.db', Uint8List.fromList([7, 8, 9]));
    final reopened = IndexedDbInstalledAssetStore(
      databaseName: 'test_gys_installed_assets',
      idbFactory: factory,
    );
    expect(await reopened.readFile('bible/b_kjv.db'), [7, 8, 9]);
  });
}

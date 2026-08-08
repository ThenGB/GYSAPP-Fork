import 'dart:io';
import 'dart:typed_data';

import 'package:church/data/services/asset_distribution/installed_asset_store_io.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression coverage for the native file-backed installed-asset store:
/// writes land under the root, listing/reading round-trips, and paths that
/// would escape the root are rejected (defense-in-depth against registry
/// tampering).
void main() {
  late Directory root;
  late FileSystemInstalledAssetStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('church_store_io_');
    store = FileSystemInstalledAssetStore(
      installedAssetsRoot: root.path,
    );
  });

  tearDown(() async {
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  });

  test('writes, lists and reads files under the root', () async {
    await store.writeFile('bible/b_kjv.db', Uint8List.fromList([1, 2, 3]));
    await store.writeFile('registry.json', Uint8List.fromList([9]));

    expect(await store.exists('bible/b_kjv.db'), isTrue);
    expect(await store.readFile('bible/b_kjv.db'), [1, 2, 3]);
    expect(await store.listFiles('bible'), ['bible/b_kjv.db']);
    // File physically landed inside the root.
    expect(
      await File('${root.path}/bible/b_kjv.db').exists(),
      isTrue,
    );
  });

  test('rejects paths that escape the installed-assets root', () async {
    expect(
      () => store.writeFile('../escape.db', Uint8List.fromList([1])),
      throwsArgumentError,
    );
    expect(
      () => store.writeFile('bible/../../escape.db', Uint8List.fromList([1])),
      throwsArgumentError,
    );
    // Nothing was written outside the root.
    expect(
      await File('${root.parent.path}/escape.db').exists(),
      isFalse,
    );
  });
}

import 'dart:io';
import 'dart:typed_data';

import 'package:church/data/repository/bible_repository_impl.dart';
import 'package:church/data/services/asset_distribution/installed_asset_registry.dart';
import 'package:church/data/services/asset_distribution/models.dart';
import 'package:church/data/services/installed_bible_db.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Regression test for "downloaded (non-TB) bible versions load empty".
///
/// Desktop sqflite has no method channel, so opening a downloaded .db used to
/// throw MissingPluginException and the pane rendered empty. This test
/// exercises the full desktop path with the real KJV database: install bytes
/// into the registry store, resolve the file, open with the FFI factory and
/// read Genesis 1:1 through the repository.
void main() {
  late Directory supportDir;
  late Directory bibleFolder;

  setUpAll(() {
    // Same initialisation app.dart performs on desktop.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    supportDir = await Directory.systemTemp.createTemp(
      'church_bible_sql_',
    );
    bibleFolder = Directory('${supportDir.path}/installed_assets/bible');
    await bibleFolder.create(recursive: true);
  });

  tearDown(() async {
    if (await supportDir.exists()) {
      await supportDir.delete(recursive: true);
    }
  });

  test('installed b_kjv.db opens and returns Genesis 1:1', () async {
    // Locate the real bundled sample DB shipped in the repo.
    final sourceDb = File('Original Alkitab DB/b_kjv.db');
    expect(sourceDb.existsSync(), isTrue,
        reason: 'b_kjv.db sample must exist for this regression test');

    final registry = InstalledAssetRegistry(supportDirectory: supportDir);
    InstalledBibleDb.debugUseRegistry(registry);
    final installedPath = '${bibleFolder.path}/b_kjv.db';
    await File(installedPath).writeAsBytes(await sourceDb.readAsBytes());

    await registry.saveInstalled(
      const InstalledAssetRecord(
        kind: DistributedAssetKind.bible,
        code: 'b_kjv',
        version: 'test',
        installedPath: 'b_kjv.db',
        installedAtEpochMs: 1,
      ),
    );

    // The cubit's selectBibleCodeByName path (non-bundled branch).
    final db = await InstalledBibleDb.open('b_kjv', readOnly: true);
    expect(db, isNotNull, reason: 'sqlite must open the downloaded bible');
    final openedDb = db as Database;

    final repository = BibleRepositoryImpl();
    final verses = await repository.getVerses(
      openedDb,
      bookId: 1,
      chapterId: 1,
    );
    await openedDb.close();

    expect(verses, isNotEmpty);
    expect(verses.first.verseId, 1);
    expect(verses.first.verse, isNotNull);
    expect(verses.first.verse!.trim(), isNotEmpty);
  });

  test('installed codes are listed by the registry after download', () async {
    final registry = InstalledAssetRegistry(supportDirectory: supportDir);
    await registry.writeInstalledBibleBytes(
      'b_cuv',
      Uint8List.fromList(const [1, 2, 3]),
    );

    final codes = await registry.listInstalledBibleCodes();
    expect(codes, contains('b_cuv'));
    expect(await registry.readInstalledBibleBytes('b_cuv'), [1, 2, 3]);
    expect(await registry.existsInstalledBible('b_cuv'), isTrue);
    expect(await registry.existsInstalledBible('b_missing'), isFalse);
  });

  test('open returns null for a code that is not installed', () async {
    // The cubit's split/main switch treats a null open as failure and keeps
    // the previous handle — verify the null trigger works on desktop.
    final registry = InstalledAssetRegistry(supportDirectory: supportDir);
    InstalledBibleDb.debugUseRegistry(registry);

    final db = await InstalledBibleDb.open('b_missing', readOnly: true);
    expect(db, isNull);

    expect(await InstalledBibleDb.exists('b_missing'), isFalse);
  });

  test('rejects bible codes that would escape the install folder', () async {
    final registry = InstalledAssetRegistry(supportDirectory: supportDir);
    InstalledBibleDb.debugUseRegistry(registry);

    // Tampered registry/caller codes must not resolve outside the install
    // dir (defense-in-depth, mirroring the store/registry isWithin guards).
    expect(
      () => InstalledBibleDb.open('../escape', readOnly: true),
      throwsArgumentError,
    );
    expect(
      () => InstalledBibleDb.writeInstalled(
        '..',
        Uint8List.fromList(const [1]),
      ),
      throwsArgumentError,
    );
    expect(
      File('${supportDir.parent.path}/escape.db').existsSync(),
      isFalse,
    );
  });
}

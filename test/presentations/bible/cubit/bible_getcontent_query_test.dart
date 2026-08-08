import 'dart:io';

import 'package:church/data/repository/bible_repository_impl.dart';
import 'package:church/data/services/asset_distribution/installed_asset_registry.dart';
import 'package:church/data/services/asset_distribution/models.dart';
import 'package:church/data/services/installed_bible_db.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Runs the exact 5-query content load that BibleCubit.getContent performs
/// against the real downloaded KJV database, to reproduce an empty Bible
/// pane for non-TB versions.
void main() {
  late Directory supportDir;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    supportDir = await Directory.systemTemp.createTemp('church_bible_sql_');
  });

  tearDown(() async {
    if (await supportDir.exists()) {
      await supportDir.delete(recursive: true);
    }
  });

  test('getContent 5-query load on b_kjv.db returns Genesis 1', () async {
    final sourceDb = File('Original Alkitab DB/b_kjv.db');
    expect(sourceDb.existsSync(), isTrue);

    final registry = InstalledAssetRegistry(supportDirectory: supportDir);
    InstalledBibleDb.debugUseRegistry(registry);
    final bibleFolder = Directory('${supportDir.path}/installed_assets/bible');
    await bibleFolder.create(recursive: true);
    await File('${bibleFolder.path}/b_kjv.db')
        .writeAsBytes(await sourceDb.readAsBytes());
    await registry.saveInstalled(
      const InstalledAssetRecord(
        kind: DistributedAssetKind.bible,
        code: 'b_kjv',
        version: 'test',
        installedPath: 'b_kjv.db',
        installedAtEpochMs: 1,
      ),
    );

    final db = await InstalledBibleDb.open('b_kjv', readOnly: true);
    expect(db, isNotNull, reason: 'b_kjv.db must open');
    final openedDb = db as Database;
    final repository = BibleRepositoryImpl();

    // Mirrors bible_cubit.dart getContent Future.wait for the DB branch.
    final results = await Future.wait([
      repository.getVerses(openedDb, bookId: 1, chapterId: 1),
      repository.getBooks(openedDb),
      repository.getPericope(openedDb, bookId: 1, chapterId: 1),
      repository.getPericopeParalel(openedDb, bc: 1001001),
      repository.getRef(openedDb, bc: 1001001),
    ]);

    final verses = results[0] as List;
    final books = results[1] as List;

    expect(verses, isNotEmpty, reason: 'Genesis 1 must exist in KJV');
    expect((verses.first as dynamic).verseId, 1);
    expect(books, isNotEmpty, reason: 'book list must load');
    expect(books.length, greaterThanOrEqualTo(39));

    await openedDb.close();
  });
}

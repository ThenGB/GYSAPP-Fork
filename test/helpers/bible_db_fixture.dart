import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Creates a compact Bible SQLite database with the same table/column contract
/// consumed by [BibleRepositoryImpl]. Tests use this instead of relying on a
/// developer-only database file that is not present in clean CI checkouts.
Future<void> createBibleDbFixture(String path) async {
  final db = await databaseFactoryFfi.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE bible (
            id INTEGER PRIMARY KEY,
            b INTEGER NOT NULL,
            c INTEGER NOT NULL,
            v INTEGER NOT NULL,
            t TEXT,
            r INTEGER,
            c1 TEXT,
            v1 TEXT,
            color TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE book (
            id INTEGER PRIMARY KEY,
            bs TEXT,
            bl TEXT,
            c INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE pericope (
            id INTEGER PRIMARY KEY,
            b INTEGER,
            c INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE pericope_paralel (
            id INTEGER PRIMARY KEY
          )
        ''');
        await db.execute('''
          CREATE TABLE ref (
            id INTEGER PRIMARY KEY,
            sv INTEGER
          )
        ''');
      },
    ),
  );

  final batch = db.batch();
  for (var id = 1; id <= 66; id++) {
    batch.insert('book', {
      'id': id,
      'bs': id == 1 ? 'Gen' : 'B$id',
      'bl': id == 1 ? 'Genesis' : 'Book $id',
      'c': id == 1 ? 50 : 1,
    });
  }
  batch.insert('bible', {
    'id': 1001001,
    'b': 1,
    'c': 1,
    'v': 1,
    't': 'In the beginning God created the heaven and the earth.',
  });
  batch.insert('bible', {
    'id': 1001002,
    'b': 1,
    'c': 1,
    'v': 2,
    't': 'And the earth was without form, and void.',
  });
  await batch.commit(noResult: true);
  await db.close();
}

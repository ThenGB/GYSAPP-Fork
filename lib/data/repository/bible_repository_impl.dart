import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../domain/entity/bible_book/bible_book.dart';
import '../../domain/entity/bible_ref/bible_ref.dart';
import '../../domain/entity/pericope/pericope.dart';
import '../../domain/entity/pericope_paralel/pericope_paralel.dart';
import '../../domain/entity/verse/verse.dart';
import '../../domain/repository/bible_repository.dart';

class BibleRepositoryImpl implements BibleRepository {
  @override
  Future<List<Verse>> getVerses(Database db,
      {required int bookId, required int chapterId}) async {
    String query = 'SELECT * FROM bible';
    List<Verse> bibles = [];
    try {
      query += ' WHERE b = $bookId AND c = $chapterId ORDER BY id asc';
      var result = await db.rawQuery(query);
      bibles = result.map((e) => Verse.fromJson(e)).toList();
    } catch (e) {
      log('Error: $e', name: 'BibleRepositoryImpl - getBible');
    }
    return bibles;
  }

  @override
  Future<List<BibleBook>> getBooks(Database db, {int? bookId}) async {
    String query = 'SELECT * FROM book';
    List<BibleBook> books = [];
    try {
      if (bookId != null) {
        query += ' WHERE id = $bookId';
      }
      var result = await db.rawQuery(query);
      for (var element in result) {
        books.add(BibleBook.fromJson(element));
      }
    } catch (e) {
      log('Error: $e', name: 'BibleRepositoryImpl - getBooks');
    }
    return books;
  }

  @override
  Future<List<Pericope>> getPericope(Database db,
      {required int bookId, required int chapterId}) async {
    List<Pericope> pericopes = [];
    String query = 'SELECT * FROM pericope';
    try {
      query += ' WHERE b = $bookId AND c = $chapterId';
      var result = await db.rawQuery(query);
      pericopes = result.map((e) => Pericope.fromJson(e)).toList();
    } catch (e) {
      log('Error: $e', name: 'BibleRepositoryImpl - getPericope');
    }
    return pericopes;
  }

  @override
  Future<List<PericopeParalel>> getPericopeParalel(Database db,
      {required int bc}) async {
    List<PericopeParalel> pericopesParalels = [];
    String query = 'SELECT * FROM pericope_paralel';
    try {
      query += ' WHERE (CAST(id as varchar(10)) LIKE \'$bc%\')';
      var result = await db.rawQuery(query);
      pericopesParalels =
          result.map((e) => PericopeParalel.fromJson(e)).toList();
    } catch (e) {
      log('Error: $e', name: 'BibleRepositoryImpl - getPericopeParalel');
    }
    return pericopesParalels;
  }

  @override
  Future<List<BibleRef>> getRef(Database db, {required int bc}) async {
    List<BibleRef> bibleRef = [];
    String query = 'SELECT * FROM ref';
    try {
      query += ' WHERE (CAST(id as varchar(10)) LIKE \'$bc%\') order by id, sv';
      var result = await db.rawQuery(query);
      bibleRef = result.map((e) => BibleRef.fromJson(e)).toList();
    } catch (e) {
      log('Error: $e', name: 'BibleRepositoryImpl - getPericopeParalel');
    }
    return bibleRef;
  }

  @override
  Future<List<Verse>> getVersesByIdRange(Database db,
      {required int fromId, required int? toId}) async {
    String query = 'SELECT * FROM bible where ';
    if (toId == 0) {
      toId = null;
    }
    toId ??= fromId;
    List<Verse> bibles = [];
    try {
      for (var id = fromId; id <= toId; id++) {
        query += 'id = $id ';
        if (id < toId) {
          query += 'or ';
        }
      }
      var result = await db.rawQuery(query);
      bibles = result.map((e) => Verse.fromJson(e)).toList();
    } catch (e) {
      log('Error: $e', name: 'BibleRepositoryImpl - getBible');
    }
    return bibles;
  }

  @override
  Future<List<Verse>> search(Database db, String searchText) async {
    final List<Verse> listData = [];
    try {
      const String query = '''
      SELECT * FROM bible
      WHERE t LIKE ? OR t LIKE ? OR t LIKE ?
    ''';

      final List<String> searchTextList = searchText.split(' ');

      final List<String> whereArgs = searchTextList
          .map((text) => '%$text%')
          .toList(); // Generate wildcard search strings

      final List<Map<String, dynamic>> maps =
          await db.rawQuery(query, whereArgs);

      for (var map in maps) {
        listData.add(Verse.fromJson(map));
      }

      return listData;
    } catch (e) {
      print('@searchBibleByString: $e');
      return listData;
    }
  }
}

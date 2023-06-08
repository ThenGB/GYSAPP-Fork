import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../domain/entity/bible_book/bible_book.dart';
import '../../domain/entity/pericope/pericope.dart';
import '../../domain/entity/pericope_paralel/pericope_paralel.dart';
import '../../domain/entity/verse/verse.dart';
import '../../domain/repository/bible_repository.dart';

class BibleRepositoryImpl implements BibleRepository {
  @override
  Future<List<Verse>> getBible(Database db,
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
  Future getRef(Database db, {required int bc}) {
    // TODO: implement getRef
    throw UnimplementedError();
  }
}

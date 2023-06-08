import 'package:sqflite/sqflite.dart';

import '../entity/bible_book/bible_book.dart';
import '../entity/pericope/pericope.dart';
import '../entity/verse/verse.dart';

abstract class BibleRepository {
  Future<List<BibleBook>> getBooks(Database db, {int? bookId});
  Future<List<Verse>> getBible(Database db,
      {required int bookId, required int chapterId});
  Future<List<Pericope>> getPericope(Database db,
      {required int bookId, required int chapterId});
  Future getPericopeParalel(Database db, {required int bc});
  Future getRef(Database db, {required int bc});
}

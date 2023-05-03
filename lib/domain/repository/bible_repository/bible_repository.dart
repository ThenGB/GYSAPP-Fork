import 'package:church/domain/entity/bible/bible.dart';
import 'package:church/domain/entity/bible_book/bible_book.dart';
import 'package:church/domain/entity/pericope/pericope.dart';
import 'package:sqflite/sqflite.dart';

abstract class BibleRepository {
  Future<List<BibleBook>> getBooks(Database db, {int? bookId});
  Future<List<Bible>> getBible(Database db,
      {required int bookId, required int chapterId});
  Future<List<Pericope>> getPericope(Database db,
      {required int bookId, required int chapterId});
  Future getPericopeParalel(Database db, {required int bc});
  Future getRef(Database db, {required int bc});
}

import 'package:sqflite/sqflite.dart';

import '../entity/bible_book/bible_book.dart';
import '../entity/bible_ref/bible_ref.dart';
import '../entity/pericope/pericope.dart';
import '../entity/pericope_paralel/pericope_paralel.dart';
import '../entity/verse/verse.dart';

abstract class BibleRepository {
  Future<List<BibleBook>> getBooks(Database db, {int? bookId});
  Future<List<Verse>> getVerses(Database db,
      {required int bookId, required int chapterId});
  Future<List<Pericope>> getPericope(Database db,
      {required int bookId, required int chapterId});
  Future<List<PericopeParalel>> getPericopeParalel(Database db,
      {required int bc});
  Future<List<BibleRef>> getRef(Database db, {required int bc});
  Future<List<Verse>> getVersesByIdRange(Database db,
      {required int fromId, required int? toId});

  Future<List<Verse>> search(
      Database db, String searchText, List<BibleBook> selectedBooks);
}

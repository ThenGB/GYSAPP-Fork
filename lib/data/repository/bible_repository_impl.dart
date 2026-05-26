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
  Future<List<Verse>> getVerses(
    Database db, {
    required int bookId,
    required int chapterId,
  }) async {
    String query = 'SELECT * FROM bible';
    List<Verse> bibles = [];
    try {
      query += ' WHERE b = ? AND c = ? ORDER BY id asc';
      var result = await db.rawQuery(query, [bookId, chapterId]);
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
      final List<Object?> args = [];
      if (bookId != null) {
        query += ' WHERE id = ?';
        args.add(bookId);
      }
      var result = await db.rawQuery(query, args);
      for (var element in result) {
        books.add(BibleBook.fromJson(element));
      }
    } catch (e) {
      log('Error: $e', name: 'BibleRepositoryImpl - getBooks');
    }
    return books;
  }

  @override
  Future<List<Pericope>> getPericope(
    Database db, {
    required int bookId,
    required int chapterId,
  }) async {
    List<Pericope> pericopes = [];
    String query = 'SELECT * FROM pericope';
    try {
      query += ' WHERE b = ? AND c = ?';
      var result = await db.rawQuery(query, [bookId, chapterId]);
      pericopes = result.map((e) => Pericope.fromJson(e)).toList();
    } catch (e) {
      log('Error: $e', name: 'BibleRepositoryImpl - getPericope');
    }
    return pericopes;
  }

  @override
  Future<List<PericopeParalel>> getPericopeParalel(
    Database db, {
    required int bc,
  }) async {
    List<PericopeParalel> pericopesParalels = [];
    String query = 'SELECT * FROM pericope_paralel';
    try {
      query += ' WHERE (CAST(id as varchar(10)) LIKE ?)';
      var result = await db.rawQuery(query, ['$bc%']);
      pericopesParalels = result
          .map((e) => PericopeParalel.fromJson(e))
          .toList();
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
      query += ' WHERE (CAST(id as varchar(10)) LIKE ?) order by id, sv';
      var result = await db.rawQuery(query, ['$bc%']);
      bibleRef = result.map((e) => BibleRef.fromJson(e)).toList();
    } catch (e) {
      log('Error: $e', name: 'BibleRepositoryImpl - getPericopeParalel');
    }
    return bibleRef;
  }

  @override
  Future<List<Verse>> getVersesByIdRange(
    Database db, {
    required int fromId,
    required int? toId,
  }) async {
    String query = 'SELECT * FROM bible where ';
    if (toId == 0) {
      toId = null;
    }
    toId ??= fromId;
    List<Verse> bibles = [];
    try {
      query += 'id >= ? AND id <= ?';
      var result = await db.rawQuery(query, [fromId, toId]);
      bibles = result.map((e) => Verse.fromJson(e)).toList();
    } catch (e) {
      log('Error: $e', name: 'BibleRepositoryImpl - getBible');
    }
    return bibles;
  }

  @override
  Future<List<Verse>> search(
    Database db,
    String searchText,
    List<BibleBook> selectedBooks,
  ) async {
    if (selectedBooks.isEmpty) {
      return []; // Return an empty list if selectedBooks is empty
    }

    final List<Verse> listData = [];
    try {
      final List<String> inOrderPhrases = [];
      final List<String> randomOrderWords = [];

      // Regular expression to match phrases enclosed in double quotes (")
      final RegExp phraseRegex = RegExp(r'"([^"]+)"');

      // Extract phrases and words from searchText
      final Iterable<Match> matches = phraseRegex.allMatches(searchText);

      // Process the matches to separate phrases and words
      for (var match in matches) {
        final String matchText = match.group(1)!;
        inOrderPhrases.add(matchText);
        searchText = searchText.replaceFirst(
          '"$matchText"',
          '',
        ); // Remove the processed phrase from searchText
      }

      randomOrderWords.addAll(searchText.split(' '));
      randomOrderWords.removeWhere((element) => element.isEmpty);

      final List<Object?> queryArgs = [];
      String inOrderQuery = '';
      if (inOrderPhrases.isNotEmpty) {
        inOrderQuery = ' AND t LIKE ?';
        queryArgs.add('%${inOrderPhrases.join(' ')}%');
      }

      final String randomOrderQuery = randomOrderWords.isEmpty
          ? ''
          : ' AND ${List.generate(randomOrderWords.length, (index) => 't LIKE ?').join(' AND ')}';
      queryArgs.addAll(randomOrderWords.map((text) => '%$text%'));

      final List<int> selectedBookIds = selectedBooks
          .map((book) => book.id)
          .toList();
      queryArgs.addAll(selectedBookIds);
      final String selectedBooksQuery =
          ' AND b IN (${List.generate(selectedBookIds.length, (index) => '?').join(', ')})';

      final String query =
          'SELECT * FROM bible WHERE 1=1 $inOrderQuery $randomOrderQuery$selectedBooksQuery';

      final List<Map<String, dynamic>> maps = await db.rawQuery(query, queryArgs);

      for (var map in maps) {
        listData.add(Verse.fromJson(map));
      }

      return listData;
    } catch (e) {
      log('@searchBibleByString: $e');
      return listData;
    }
  }
}

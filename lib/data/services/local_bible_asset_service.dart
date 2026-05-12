import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entity/bible_book/bible_book.dart';
import '../../domain/entity/bible_ref/bible_ref.dart';
import '../../domain/entity/pericope/pericope.dart';
import '../../domain/entity/pericope_paralel/pericope_paralel.dart';
import '../../domain/entity/verse/verse.dart';

class LocalBibleAssetService {
  final Map<String, List<BibleBook>> _booksCache = {};
  final Map<String, List<Verse>> _chapterCache = {};
  final Map<String, List<Pericope>> _pericopeCache = {};
  final Map<String, Map<String, List<BibleRef>>> _refsCache = {};
  final Map<String, Map<String, List<PericopeParalel>>> _paralelsCache = {};

  bool isBundledCode(String code) => _normalizeCode(code) == 'b_tb';

  Future<List<String>> getBundledBibleCodes() async {
    return const ['b_tb'];
  }

  Future<List<BibleBook>> getBooks(String code, {int? bookId}) async {
    final normalizedCode = _normalizeCode(code);
    final cached = _booksCache[normalizedCode];
    final books = cached ?? await _loadBooks(normalizedCode);
    if (bookId == null) return books;
    return books.where((book) => book.id == bookId).toList();
  }

  Future<List<Verse>> getVerses(
    String code, {
    required int bookId,
    required int chapterId,
  }) async {
    final key = '${_normalizeCode(code)}:$bookId:$chapterId';
    final cached = _chapterCache[key];
    if (cached != null) return cached;

    final data = await _loadJsonList(
      'assets/data/bible/${_normalizeCode(code)}/chapters/${bookId}_$chapterId.json',
    );
    final verses = data.map((item) => Verse.fromJson(item)).toList();
    _chapterCache[key] = verses;
    return verses;
  }

  Future<List<Pericope>> getPericopes(
    String code, {
    required int bookId,
    required int chapterId,
  }) async {
    final key = '${_normalizeCode(code)}:$bookId:$chapterId';
    final cached = _pericopeCache[key];
    if (cached != null) return cached;

    final data = await _loadJsonList(
      'assets/data/bible/${_normalizeCode(code)}/pericopes/${bookId}_$chapterId.json',
    );
    final pericopes = data.map((item) => Pericope.fromJson(item)).toList();
    _pericopeCache[key] = pericopes;
    return pericopes;
  }

  Future<List<PericopeParalel>> getPericopeParalels(
    String code, {
    required int bc,
  }) async {
    final grouped = await _loadParalels(_normalizeCode(code));
    return grouped[bc.toString()] ?? [];
  }

  Future<List<BibleRef>> getRefs(String code, {required int bc}) async {
    final grouped = await _loadRefs(_normalizeCode(code));
    return grouped[bc.toString()] ?? [];
  }

  Future<List<Verse>> getVersesByIdRange(
    String code, {
    required int fromId,
    required int? toId,
  }) async {
    if (toId == 0) toId = null;
    toId ??= fromId;

    // Group verse IDs by book and chapter for batch fetching
    final Map<String, List<int>> chaptersToFetch = {};
    for (var id = fromId; id <= toId; id++) {
      final bookId = id ~/ 1000000;
      final chapterId = (id % 1000000) ~/ 1000;
      final key = '$bookId-$chapterId';
      chaptersToFetch.putIfAbsent(key, () => []).add(id);
    }

    // Fetch all chapters in parallel
    final futures = chaptersToFetch.entries.map((entry) async {
      final parts = entry.key.split('-');
      final bookId = int.parse(parts[0]);
      final chapterId = int.parse(parts[1]);
      final chapter = await getVerses(code, bookId: bookId, chapterId: chapterId);
      return MapEntry(entry.key, chapter);
    });

    final chapterResults = await Future.wait(futures.toList());
    final chapterMap = Map.fromEntries(chapterResults);

    // Extract specific verses from each chapter
    final verses = <Verse>[];
    for (final entry in chaptersToFetch.entries) {
      final chapter = chapterMap[entry.key] ?? [];
      for (final id in entry.value) {
        final verse = chapter.where((item) => item.id == id).firstOrNull;
        if (verse != null) verses.add(verse);
      }
    }
    return verses;
  }

  Future<List<Verse>> search(
    String code,
    String searchText,
    List<BibleBook> selectedBooks,
  ) async {
    if (searchText.isEmpty || selectedBooks.isEmpty) return [];

    final selectedBookIds = selectedBooks.map((book) => book.id).toSet();
    final phraseRegex = RegExp(r'"([^"]+)"');
    final phrases = phraseRegex
        .allMatches(searchText)
        .map((match) => match.group(1)!.toLowerCase())
        .toList();
    var remainingText = searchText;
    for (final phrase in phrases) {
      remainingText = remainingText.replaceFirst('"$phrase"', '');
    }
    final words = remainingText
        .toLowerCase()
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .toList();

    // Collect all chapter pairs to fetch in parallel
    final books = await getBooks(code);
    final filteredBooks = books.where((book) => selectedBookIds.contains(book.id)).toList();

    // Create list of all (bookId, chapterId) pairs
    final chapterPairs = <MapEntry<int, int>>[];
    for (final book in filteredBooks) {
      for (var chapter = 1; chapter <= (book.chapterCount ?? 0); chapter++) {
        chapterPairs.add(MapEntry(book.id, chapter));
      }
    }

    // Fetch all chapters in parallel
    final chapterResults = await Future.wait(
      chapterPairs.map((pair) => getVerses(code, bookId: pair.key, chapterId: pair.value)),
    );

    // Search through all fetched verses
    final results = <Verse>[];
    for (final verses in chapterResults) {
      for (final verse in verses) {
        final text = (verse.verse ?? '').toLowerCase();
        final matchesPhrases = phrases.every(text.contains);
        final matchesWords = words.every(text.contains);
        if (matchesPhrases && matchesWords) results.add(verse);
      }
    }
    return results;
  }

  Future<String?> getBibleTitle(
    String code,
    List<int> verseIds, {
    bool isLong = false,
    bool withVerse = true,
  }) async {
    if (verseIds.isEmpty) return '-';

    verseIds.sort();
    final firstId = verseIds.first;
    final bookId = firstId ~/ 1000000;
    final books = await getBooks(code, bookId: bookId);
    if (books.isEmpty) return '-';

    final book = books.first;
    final bookName = isLong
        ? (book.longName ?? book.shortName ?? '-')
        : (book.shortName ?? book.longName ?? '-');
    final chapter = ((firstId % 1000000) ~/ 1000).toString();

    if (!withVerse) return '$bookName $chapter';

    final verseNumbers = _groupVerseNumbers(verseIds);
    final parsedVerse = verseNumbers
        .map((group) =>
            '${group.first}${group.last == group.first ? '' : '-${group.last}'}')
        .join(', ');
    return '$bookName $chapter:$parsedVerse';
  }

  Future<List<BibleBook>> _loadBooks(String code) async {
    final data = await _loadJsonList('assets/data/bible/$code/books.json');
    final books = data.map((item) => BibleBook.fromJson(item)).toList();
    _booksCache[code] = books;
    return books;
  }

  Future<Map<String, List<BibleRef>>> _loadRefs(String code) async {
    final cached = _refsCache[code];
    if (cached != null) return cached;

    final data = await _loadJsonMap('assets/data/bible/$code/refs_by_bc.json');
    final refs = data.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map((item) => BibleRef.fromJson(item))
            .toList(),
      ),
    );
    _refsCache[code] = refs;
    return refs;
  }

  Future<Map<String, List<PericopeParalel>>> _loadParalels(String code) async {
    final cached = _paralelsCache[code];
    if (cached != null) return cached;

    final data = await _loadJsonMap(
      'assets/data/bible/$code/pericope_paralels_by_bc.json',
    );
    final paralels = data.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map((item) => PericopeParalel.fromJson(item))
            .toList(),
      ),
    );
    _paralelsCache[code] = paralels;
    return paralels;
  }

  Future<List<Map<String, dynamic>>> _loadJsonList(String path) async {
    final text = await rootBundle.loadString(path);
    return (jsonDecode(text) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> _loadJsonMap(String path) async {
    final text = await rootBundle.loadString(path);
    return (jsonDecode(text) as Map<String, dynamic>);
  }

  List<List<int>> _groupVerseNumbers(List<int> verseIds) {
    int? previous;
    var current = <int>[];
    final groups = <List<int>>[];

    for (final verseId in verseIds) {
      final verseNumber = verseId % 1000;
      if (previous == null || previous + 1 == verseNumber) {
        current.add(verseNumber);
      } else {
        groups.add(List.from(current));
        current = [verseNumber];
      }
      previous = verseNumber;
    }

    if (current.isNotEmpty) groups.add(current);
    return groups;
  }

  String _normalizeCode(String code) {
    return code.toLowerCase().replaceAll('.db', '');
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

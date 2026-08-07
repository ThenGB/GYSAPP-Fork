import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../di/injection.dart';
import '../../domain/repository/bible_repository.dart';
import '../../presentations/home/bloc/home_state.dart';
import 'local_bible_asset_service.dart';

class OurMannnaService {
  static const String _cacheKeyPrefix = 'ourmanna_verse_';
  static const String _cacheDateKeyPrefix = 'ourmanna_verse_date_';

  final Dio _dio;
  final LocalBibleAssetService _localBibleAssetService;
  final BibleRepository _bibleRepository;
  final AppDirectory _appDirectory;

  OurMannnaService(
    this._dio,
    this._localBibleAssetService,
    this._bibleRepository,
    this._appDirectory,
  );

  static final Map<String, int> _bookNameToId = _buildBookMap();

  static Map<String, int> _buildBookMap() {
    final map = <String, int>{};
    void add(int id, List<String> names) {
      for (final name in names) {
        map[name.toLowerCase()] = id;
      }
    }

    add(1, ['genesis', 'gen', 'gn']);
    add(2, ['exodus', 'exo', 'ex', 'exod']);
    add(3, ['leviticus', 'lev', 'lv']);
    add(4, ['numbers', 'num', 'nm', 'nu']);
    add(5, ['deuteronomy', 'deut', 'dt', 'deu']);
    add(6, ['joshua', 'josh', 'jos']);
    add(7, ['judges', 'judg', 'jdg', 'jg']);
    add(8, ['ruth', 'ru']);
    add(9, ['1 samuel', '1 sam', '1sa', '1 s', 'i samuel', 'i sam']);
    add(10, ['2 samuel', '2 sam', '2sa', '2 s', 'ii samuel', 'ii sam']);
    add(11, ['1 kings', '1 kgs', '1ki', '1 k', 'i kings', 'i kgs']);
    add(12, ['2 kings', '2 kgs', '2ki', '2 k', 'ii kings', 'ii kgs']);
    add(13, ['1 chronicles', '1 chr', '1ch', '1 c', 'i chronicles', 'i chr']);
    add(14, ['2 chronicles', '2 chr', '2ch', '2 c', 'ii chronicles', 'ii chr']);
    add(15, ['ezra', 'ezr']);
    add(16, ['nehemiah', 'neh', 'ne']);
    add(17, ['esther', 'est', 'es']);
    add(18, ['job', 'jb']);
    add(19, ['psalm', 'ps', 'psa', 'psalms', 'pss']);
    add(20, ['proverbs', 'prov', 'pr', 'prv']);
    add(21, ['ecclesiastes', 'eccl', 'ec', 'qoheleth']);
    add(22, ['song of solomon', 'song', 'so', 'sos', 'song of songs', 'canticles', 'cant']);
    add(23, ['isaiah', 'isa', 'is']);
    add(24, ['jeremiah', 'jer', 'je']);
    add(25, ['lamentations', 'lam', 'la']);
    add(26, ['ezekiel', 'ezek', 'ez', 'eze']);
    add(27, ['daniel', 'dan', 'da', 'dn']);
    add(28, ['hosea', 'hos', 'ho']);
    add(29, ['joel', 'jl']);
    add(30, ['amos', 'am']);
    add(31, ['obadiah', 'obad', 'ob']);
    add(32, ['jonah', 'jon']);
    add(33, ['micah', 'mic']);
    add(34, ['nahum', 'nah', 'na']);
    add(35, ['habakkuk', 'hab']);
    add(36, ['zephaniah', 'zeph', 'zep']);
    add(37, ['haggai', 'hag', 'hg']);
    add(38, ['zechariah', 'zech', 'zec']);
    add(39, ['malachi', 'mal']);
    add(40, ['matthew', 'matt', 'mt']);
    add(41, ['mark', 'mk', 'mrk']);
    add(42, ['luke', 'lk', 'luk']);
    add(43, ['john', 'jn', 'joh']);
    add(44, ['acts', 'ac']);
    add(45, ['romans', 'rom', 'ro', 'rm']);
    add(46, ['1 corinthians', '1 cor', '1co', '1 c', 'i corinthians', 'i cor']);
    add(47, ['2 corinthians', '2 cor', '2co', '2 c', 'ii corinthians', 'ii cor']);
    add(48, ['galatians', 'gal', 'ga']);
    add(49, ['ephesians', 'eph']);
    add(50, ['philippians', 'phil', 'php', 'pp']);
    add(51, ['colossians', 'col']);
    add(52, ['1 thessalonians', '1 thess', '1th', '1 t', 'i thessalonians', 'i thess']);
    add(53, ['2 thessalonians', '2 thess', '2th', '2 t', 'ii thessalonians', 'ii thess']);
    add(54, ['1 timothy', '1 tim', '1ti', '1 t', 'i timothy', 'i tim']);
    add(55, ['2 timothy', '2 tim', '2ti', '2 t', 'ii timothy', 'ii tim']);
    add(56, ['titus', 'tit', 'ti']);
    add(57, ['philemon', 'phlm', 'phm']);
    add(58, ['hebrews', 'heb']);
    add(59, ['james', 'jas', 'jm']);
    add(60, ['1 peter', '1 pet', '1pe', '1 p', 'i peter', 'i pet']);
    add(61, ['2 peter', '2 pet', '2pe', '2 p', 'ii peter', 'ii pet']);
    add(62, ['1 john', '1 jn', '1jo', '1 j', 'i john', 'i jn']);
    add(63, ['2 john', '2 jn', '2jo', '2 j', 'ii john', 'ii jn']);
    add(64, ['3 john', '3 jn', '3jo', '3 j', 'iii john', 'iii jn']);
    add(65, ['jude', 'jud']);
    add(66, ['revelation', 'rev', 're', 'rv', 'apocalypse']);

    return map;
  }

  (int, int, int)? _parseReference(String reference) {
    try {
      final lastSpace = reference.lastIndexOf(' ');
      if (lastSpace == -1) return null;

      final bookName = reference.substring(0, lastSpace).trim();
      final chapterVerse = reference.substring(lastSpace + 1).trim();
      final cvParts = chapterVerse.split(':');
      if (cvParts.length != 2) return null;

      final chapterId = int.tryParse(cvParts[0]);
      final verseMatch = RegExp(r'(\d+)').firstMatch(cvParts[1]);
      final verseId = verseMatch != null ? int.tryParse(verseMatch.group(1)!) : null;
      if (chapterId == null || verseId == null) return null;

      final bookId = _bookNameToId[bookName.toLowerCase()];
      if (bookId == null) return null;

      return (bookId, chapterId, verseId);
    } catch (e) {
      return null;
    }
  }

  String _cacheKey(String bibleCode) => '$_cacheKeyPrefix$bibleCode';
  String _cacheDateKey(String bibleCode) => '$_cacheDateKeyPrefix$bibleCode';

  Future<OurMannaVerse?> getVerse({String? bibleCode}) async {
    log('TodayVerse: getVerse called with bibleCode=$bibleCode', name: 'OurMannnaService');
    final effectiveCode = (bibleCode != null && bibleCode.isNotEmpty) ? bibleCode : 'b_tb';

    // 1. Check per-bibleCode cache
    final cached = await _getCachedVerse(effectiveCode);
    if (cached != null) {
      log('TodayVerse: cached verse for $effectiveCode: ref=${cached.reference}', name: 'OurMannnaService');
      return cached;
    }

    // 2. No cache for this bibleCode — fetch from API
    log('TodayVerse: no cache for $effectiveCode, fetching from API', name: 'OurMannnaService');
    OurMannaVerse? apiVerse;
    try {
      final response = await _dio.get(
        'https://beta.ourmanna.com/api/v1/get',
      );
      if (response.statusCode == 200) {
        final responseText = response.data.toString();
        apiVerse = _parseVerseResponse(responseText);
      }
    } catch (e) {
      // ignore
    }

    if (apiVerse == null || apiVerse.text.isEmpty) return null;

    log('TodayVerse: API verse: ref=${apiVerse.reference}', name: 'OurMannnaService');

    // 3. Localize against the requested bible
    final localized = await _localizeVerse(apiVerse.reference, effectiveCode);
    if (localized != null) {
      await _cacheVerse(localized, effectiveCode);
      return localized;
    }

    // 4. Localization failed — return English API text (no cache),
    // sanitized in case the endpoint ever echoes markup.
    return OurMannaVerse(
      text: _stripBibleTags(apiVerse.text),
      reference: apiVerse.reference,
      bibleCodeName: apiVerse.bibleCodeName,
      originalReference: apiVerse.originalReference,
    );
  }

  Future<OurMannaVerse?> _localizeVerse(
    String reference,
    String bibleCode,
  ) async {
    try {
      final parsed = _parseReference(reference);
      log('TodayVerse: _localizeVerse ref=$reference, bibleCode=$bibleCode, parsed=$parsed', name: 'OurMannnaService');

      int? bookId;
      int? chapterId;
      int? verseId;

      if (parsed != null) {
        (bookId, chapterId, verseId) = parsed;
      } else {
        final fallback = await _findBookFromLocal(reference, bibleCode);
        if (fallback != null) {
          (bookId, chapterId, verseId) = fallback;
          log('TodayVerse: fuzzy match found bookId=$bookId', name: 'OurMannnaService');
        } else {
          log('TodayVerse: could not parse reference: $reference', name: 'OurMannnaService');
          return null;
        }
      }

      final isBundled = _localBibleAssetService.isBundledCode(bibleCode);
      log('TodayVerse: bookId=$bookId, chapterId=$chapterId, verseId=$verseId, isBundled=$isBundled', name: 'OurMannnaService');

      String? verseText;
      String? localBookName;

      if (isBundled) {
        final verses = await _localBibleAssetService.getVerses(
          bibleCode,
          bookId: bookId,
          chapterId: chapterId,
        );
        log('TodayVerse: got ${verses.length} verses from bundled', name: 'OurMannnaService');
        final match = verses.where((v) => v.verseId == verseId).toList();
        if (match.isNotEmpty) {
          verseText = match.first.verse;
          log('TodayVerse: found verse text: ${verseText?.substring(0, 30)}...', name: 'OurMannnaService');
        }

        final allBooks = await _localBibleAssetService.getBooks(bibleCode);
        log('TodayVerse: allBooks count=${allBooks.length}', name: 'OurMannnaService');
        final found = allBooks.where((b) => b.id == bookId).toList();
        if (found.isNotEmpty) {
          localBookName = found.first.longName ?? found.first.shortName;
          log('TodayVerse: localBookName=$localBookName (long=${found.first.longName}, short=${found.first.shortName}, id=${found.first.id})', name: 'OurMannnaService');
        } else {
          log('TodayVerse: bookId=$bookId not found in allBooks!', name: 'OurMannnaService');
        }
      } else {
        final dbPath = p.join(_appDirectory.bibleFolder, '$bibleCode.db');
        log('TodayVerse: checking dbPath=$dbPath', name: 'OurMannnaService');
        final dbFile = _fileExists(dbPath);
        if (!dbFile) {
          log('TodayVerse: db file not found', name: 'OurMannnaService');
          return null;
        }

        Database? db;
        try {
          db = await openDatabase(dbPath, readOnly: true);
          final verses = await _bibleRepository.getVerses(db, bookId: bookId, chapterId: chapterId);
          log('TodayVerse: got ${verses.length} verses from sqlite', name: 'OurMannnaService');
          final match = verses.where((v) => v.verseId == verseId).toList();
          if (match.isNotEmpty) {
            verseText = match.first.verse;
            log('TodayVerse: found verse text: ${verseText?.substring(0, 30)}...', name: 'OurMannnaService');
          }

          final allBooks = await _bibleRepository.getBooks(db);
          final found = allBooks.where((b) => b.id == bookId).toList();
          if (found.isNotEmpty) {
            localBookName = found.first.longName ?? found.first.shortName;
            log('TodayVerse: localBookName=$localBookName (long=${found.first.longName}, short=${found.first.shortName})', name: 'OurMannnaService');
          }
        } finally {
          await db?.close();
        }
      }

      if (verseText != null && verseText.isNotEmpty) {
        verseText = _stripBibleTags(verseText);
        final localRef = localBookName != null
            ? '$localBookName $chapterId:$verseId'
            : reference;
        final codeName = bibleCode.split('_').last.toUpperCase();
        return OurMannaVerse(text: verseText, reference: localRef, bibleCodeName: codeName, originalReference: reference);
      }
      log('TodayVerse: verseText is null or empty, falling back', name: 'OurMannnaService');
    } catch (e, st) {
      log('Failed to localize verse: $e\n$st', name: 'OurMannnaService');
    }
    return null;
  }

  Future<(int, int, int)?> _findBookFromLocal(String reference, String bibleCode) async {
    try {
      final lastSpace = reference.lastIndexOf(' ');
      if (lastSpace == -1) return null;

      final bookPart = reference.substring(0, lastSpace).trim().toLowerCase();
      final chapterVerse = reference.substring(lastSpace + 1).trim();
      final cvParts = chapterVerse.split(':');
      if (cvParts.length != 2) return null;

      final chapterId = int.tryParse(cvParts[0]);
      final verseMatch = RegExp(r'(\d+)').firstMatch(cvParts[1]);
      final verseId = verseMatch != null ? int.tryParse(verseMatch.group(1)!) : null;
      if (chapterId == null || verseId == null) return null;

      final isBundled = _localBibleAssetService.isBundledCode(bibleCode);

      if (isBundled) {
        final allBooks = await _localBibleAssetService.getBooks(bibleCode);
        for (final book in allBooks) {
          final bs = (book.shortName ?? '').toLowerCase();
          final bl = (book.longName ?? '').toLowerCase();
          if (bookPart == bs || bookPart == bl) {
            return (book.id, chapterId, verseId);
          }
        }
      } else {
        final dbPath = p.join(_appDirectory.bibleFolder, '$bibleCode.db');
        if (!_fileExists(dbPath)) return null;
        Database? db;
        try {
          db = await openDatabase(dbPath, readOnly: true);
          final allBooks = await _bibleRepository.getBooks(db);
          for (final book in allBooks) {
            final bs = (book.shortName ?? '').toLowerCase();
            final bl = (book.longName ?? '').toLowerCase();
            if (bookPart == bs || bookPart == bl) {
              return (book.id, chapterId, verseId);
            }
          }
        } finally {
          await db?.close();
        }
      }
    } catch (e) {
      log('TodayVerse: _findBookFromLocal error: $e', name: 'OurMannnaService');
    }
    return null;
  }

  bool _fileExists(String path) {
    try {
      return FileSystemEntity.typeSync(path) ==
          FileSystemEntityType.file;
    } catch (_) {
      return false;
    }
  }

  String _stripBibleTags(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]+>'), '')
        // HTML entities the API occasionally returns (&amp; &lt; &quot; …)
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  OurMannaVerse? _parseVerseResponse(String response) {
    try {
      final parts = response.split(' - ');
      if (parts.length < 2) return null;

      final text = parts[0].trim();
      final refWithVersion = parts.sublist(1).join(' - ').trim();

      String reference = refWithVersion;
      final versionMatch =
          RegExp(r'\s*\([^)]+\)\s*$').firstMatch(refWithVersion);
      if (versionMatch != null) {
        reference = refWithVersion.substring(0, versionMatch.start).trim();
      }

      if (text.isEmpty || reference.isEmpty) return null;

      return OurMannaVerse(text: text, reference: reference);
    } catch (e) {
      return null;
    }
  }

  String _todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<OurMannaVerse?> _getCachedVerse(String bibleCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _cacheKey(bibleCode);
      final dateKey = _cacheDateKey(bibleCode);
      final cachedDate = prefs.getString(dateKey);
      final todayStr = _todayDateString();

      // Invalidate cache if the date has changed (new day = new verse from OurManna)
      if (cachedDate != todayStr) {
        if (cachedDate != null) {
          await prefs.remove(key);
          await prefs.remove(dateKey);
        }
        return null;
      }

      final cachedJson = prefs.getString(key);
      if (cachedJson == null) return null;

      final data = jsonDecode(cachedJson);
      final verse = OurMannaVerse.fromJson(data);
      if (verse.originalReference == null) {
        await prefs.remove(key);
        await prefs.remove(dateKey);
        return null;
      }
      // Sanitize on read: older app versions cached the raw bundled text
      // which still contained <pb/>/<t> XML markers — those would otherwise
      // render as literal symbols in the Today Verse card forever.
      return OurMannaVerse(
        text: _stripBibleTags(verse.text),
        reference: verse.reference,
        bibleCodeName: verse.bibleCodeName,
        originalReference: verse.originalReference,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheVerse(OurMannaVerse verse, String bibleCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey(bibleCode), jsonEncode(verse.toJson()));
      await prefs.setString(_cacheDateKey(bibleCode), _todayDateString());
    } catch (e) {
      // Ignore cache errors
    }
  }
}
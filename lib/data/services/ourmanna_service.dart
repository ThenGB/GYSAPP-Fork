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
  static const String _cacheKey = 'ourmanna_verse';
  static const String _cacheTimestampKey = 'ourmanna_verse_timestamp';
  static const Duration _cacheDuration = Duration(hours: 24);

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
      final verseId = int.tryParse(cvParts[1]);
      if (chapterId == null || verseId == null) return null;

      final bookId = _bookNameToId[bookName.toLowerCase()];
      if (bookId == null) return null;

      return (bookId, chapterId, verseId);
    } catch (e) {
      return null;
    }
  }

  Future<OurMannaVerse?> getVerse({String? bibleCode}) async {
    log('TodayVerse: getVerse called with bibleCode=$bibleCode', name: 'OurMannnaService');
    final cached = await _getCachedVerse();
    if (cached != null) {
      log('TodayVerse: cached verse found: ref=${cached.reference}', name: 'OurMannnaService');
      if (bibleCode != null && bibleCode.isNotEmpty) {
        final refToLocalize = cached.originalReference ?? cached.reference;
        final localized = await _localizeVerse(refToLocalize, bibleCode);
        if (localized != null) {
          log('TodayVerse: localized cached verse: ${localized.text.substring(0, 30)}...', name: 'OurMannnaService');
          await _cacheVerse(localized);
          return localized;
        }
        log('TodayVerse: localization of cached verse failed, returning cached', name: 'OurMannnaService');
      }
      return _ensureCleanVerse(cached);
    }

    log('TodayVerse: no cache, fetching from API', name: 'OurMannnaService');
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
    if (bibleCode != null && bibleCode.isNotEmpty) {
      final localized = await _localizeVerse(apiVerse.reference, bibleCode);
      if (localized != null) {
        await _cacheVerse(localized);
        return localized;
      }
    }

    await _cacheVerse(apiVerse);
    return apiVerse;
  }

  OurMannaVerse _ensureCleanVerse(OurMannaVerse verse) {
    final cleaned = _stripBibleTags(verse.text);
    if (cleaned == verse.text) return verse;
    return OurMannaVerse(
      text: cleaned,
      reference: verse.reference,
      bibleCodeName: verse.bibleCodeName,
      originalReference: verse.originalReference,
    );
  }

  Future<OurMannaVerse?> _localizeVerse(
    String reference,
    String bibleCode,
  ) async {
    try {
      final parsed = _parseReference(reference);
      log('TodayVerse: _localizeVerse ref=$reference, bibleCode=$bibleCode, parsed=$parsed', name: 'OurMannnaService');
      if (parsed == null) return null;

      final (bookId, chapterId, verseId) = parsed;
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

        final books = await _localBibleAssetService.getBooks(
          bibleCode,
          bookId: bookId,
        );
        if (books.isNotEmpty) {
          localBookName = books.first.longName ?? books.first.shortName;
          log('TodayVerse: localBookName=$localBookName', name: 'OurMannnaService');
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
          final verses = await _bibleRepository.getVerses(
            db,
            bookId: bookId,
            chapterId: chapterId,
          );
          log('TodayVerse: got ${verses.length} verses from sqlite', name: 'OurMannnaService');
          final match = verses.where((v) => v.verseId == verseId).toList();
          if (match.isNotEmpty) {
            verseText = match.first.verse;
            log('TodayVerse: found verse text: ${verseText?.substring(0, 30)}...', name: 'OurMannnaService');
          }

          final books = await _bibleRepository.getBooks(db, bookId: bookId);
          if (books.isNotEmpty) {
            localBookName = books.first.longName ?? books.first.shortName;
            log('TodayVerse: localBookName=$localBookName', name: 'OurMannnaService');
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

  Future<OurMannaVerse?> _getCachedVerse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);
      if (timestamp == null) return null;

      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cachedTime) > _cacheDuration) {
        return null;
      }

      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson == null) return null;

      final data = jsonDecode(cachedJson);
      return OurMannaVerse.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheVerse(OurMannaVerse verse) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(verse.toJson()));
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Ignore cache errors
    }
  }
}
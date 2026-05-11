import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';

import '../../../domain/entity/song/song_entity.dart';

class LocalAssetService {
  final Map<String, List<Map<String, dynamic>>> _indexCache = {};
  final Map<String, Map<String, Map<String, dynamic>>> _songLookupCache = {};
  Map<String, dynamic>? _assetManifest;
  final Map<String, Map<String, dynamic>> _pdfManifestCache = {};
  Map<String, String>? _normalizedAssetPathMap;
  Map<String, Map<String, String>>? _pdfPathByBookAndNumber;

  Future<void> initialize() async {}

  Future<List<Map<String, dynamic>>> _loadBookIndex(String code) async {
    if (_indexCache.containsKey(code)) {
      _cacheSongLookup(code, _indexCache[code]!);
      return _indexCache[code]!;
    }

    final fileName =
        'assets/data/index/${code.toLowerCase().replaceAll('-', '_')}_index.json';
    try {
      final jsonString = await rootBundle.loadString(fileName);
      final List<dynamic> data = jsonDecode(jsonString);
      final songs = data.cast<Map<String, dynamic>>();
      _indexCache[code] = songs;
      _cacheSongLookup(code, songs);
      return songs;
    } catch (e) {
      log('Failed to load index for $code: $e');
      return [];
    }
  }

  void _cacheSongLookup(String code, List<Map<String, dynamic>> songs) {
    _songLookupCache[code] ??= {
      for (final song in songs)
        if (song['number'] is String) song['number'] as String: song,
    };
  }

  Future<List<SongBook>> loadSongBooks() async {
    const codes = ['KR', 'HYMNE', 'MDR', 'ASM-I', 'ASM-M', 'ASM-P'];
    return Future.wait(codes.map(loadSongBook));
  }

  Future<SongBook> loadSongBook(String code) async {
    final songsData = await _loadBookIndex(code);
    final songs = songsData
        .map(
          (data) => Song(
            code: code,
            number: data['number'] as String?,
            number2: data['number2'] as String?,
            title: data['title'] as String?,
            soundfilePath: data['midiFile'] as String?,
            pageLength: data['pages'] as int?,
            pageStart: data['page'] as int?,
            verses: (data['verses'] as List<dynamic>?)?.cast<String>() ?? [],
          ),
        )
        .toList();

    return SongBook(code: code, songs: songs);
  }

  Future<String?> getMidiPath(String bookCode, String number) async {
    final song = await _findSong(bookCode, number);
    if (song.isEmpty) return null;
    return _resolveAssetPath(song['midiFile'] as String?);
  }

  Future<String?> getChordPath(String bookCode, String number) async {
    if (bookCode == 'HYMNE') return getChordPath('KR', number);
    if (bookCode != 'KR') return null;
    final song = await _findSong(bookCode, number);
    if (song.isEmpty) return null;
    if (song['hasChord'] != true) return null;
    return _resolveAssetPath(song['chordFile'] as String?);
  }

  Future<String?> getPdfPath(String bookCode, String number) async {
    final song = await _findSong(bookCode, number);
    if (song.isEmpty) return null;
    final masterPath = await _resolveMasterPdfPath(bookCode, number);
    if (masterPath != null) return masterPath;

    final indexedPath = await _resolveAssetPath(song['pdfFile'] as String?);
    if (indexedPath != null) return indexedPath;
    final numberedPath = await _resolvePdfByNumber(bookCode, number);
    if (numberedPath != null) return numberedPath;

    return null;
  }

  Future<Map<String, dynamic>> _findSong(String bookCode, String number) async {
    await _loadBookIndex(bookCode);
    return _songLookupCache[bookCode]?[number] ?? {};
  }

  Future<String?> _resolvePdfByNumber(String bookCode, String number) async {
    final pdfIndex = await _loadPdfPathIndex();
    final bookIndex = pdfIndex[bookCode];
    final resolved = bookIndex?[number] ?? bookIndex?[number.padLeft(3, '0')];
    if (resolved != null) return resolved;

    log('PDF path not found for $bookCode $number', name: 'LocalAssetService');
    return null;
  }

  Future<String?> _resolveMasterPdfPath(String bookCode, String number) async {
    final manifest = await _loadPdfManifest(bookCode);
    final songs = manifest['songs'];
    if (songs is! Map<String, dynamic>) return null;

    final entry = songs[number] ?? songs[number.padLeft(3, '0')];
    if (entry is! Map<String, dynamic>) return null;

    final path = entry['path'] as String? ?? manifest['masterPath'] as String?;
    final startPage = entry['startPage'];
    final pageCount = entry['pageCount'];
    if (path == null || startPage is! int || pageCount is! int) return null;

    return '$path#page=$startPage&pages=$pageCount';
  }

  Future<Map<String, dynamic>> _loadPdfManifest(String bookCode) async {
    if (_pdfManifestCache.containsKey(bookCode)) {
      return _pdfManifestCache[bookCode]!;
    }

    final folder = _pdfFolderForBookCode(bookCode);
    if (folder == null) {
      _pdfManifestCache[bookCode] = {};
      return _pdfManifestCache[bookCode]!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/index/${folder}_pdf_manifest.json',
      );
      _pdfManifestCache[bookCode] =
          jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      _pdfManifestCache[bookCode] = {};
    }
    return _pdfManifestCache[bookCode]!;
  }

  String? _pdfFolderForBookCode(String bookCode) {
    return switch (bookCode) {
      'MDR' => 'mdr',
      'HYMNE' => 'hymne',
      'ASM-I' => 'asm_i',
      'ASM-M' => 'asm_m',
      'ASM-P' => 'asm_p',
      _ => null,
    };
  }

  Future<Map<String, Map<String, String>>> _loadPdfPathIndex() async {
    if (_pdfPathByBookAndNumber != null) return _pdfPathByBookAndNumber!;

    final manifest = await _loadAssetManifest();
    final index = <String, Map<String, String>>{};
    const folderToCode = {
      'kr': 'KR',
      'hymne': 'HYMNE',
      'mdr': 'MDR',
      'asm_i': 'ASM-I',
      'asm_m': 'ASM-M',
      'asm_p': 'ASM-P',
    };
    final numberPattern = RegExp(r'^([0-9]+[A-Za-z]?)');

    for (final key in manifest.keys) {
      final normalized = key.replaceAll('\\', '/');
      if (!normalized.toLowerCase().endsWith('.pdf')) continue;
      final parts = normalized.split('/');
      if (parts.length < 5 || parts[0] != 'assets' || parts[2] != 'pdf') {
        continue;
      }
      final code = folderToCode[parts[3].toLowerCase()];
      if (code == null) continue;
      final match = numberPattern.firstMatch(parts.last);
      if (match == null) continue;
      index.putIfAbsent(code, () => {})[match.group(1)!] = key;
    }

    _pdfPathByBookAndNumber = index;
    return index;
  }

  Future<bool> hasChord(String bookCode, String number) async {
    if (bookCode != 'KR') return false;
    final path = await getChordPath(bookCode, number);
    if (path == null) return false;
    try {
      await rootBundle.loadString(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasMidi(String bookCode, String number) async {
    final path = await getMidiPath(bookCode, number);
    return path != null;
  }

  Future<String?> _resolveAssetPath(String? path) async {
    if (path == null || path.trim().isEmpty) return null;

    final manifest = await _loadAssetManifest();
    final candidate = _withDataPrefix(path);
    if (manifest.containsKey(candidate)) {
      return candidate;
    }

    final normalizedMap = await _loadNormalizedAssetPathMap();
    final resolved = normalizedMap[_normalizeAssetKey(candidate)];
    if (resolved != null) {
      return resolved;
    }

    // Fallback: extract the song number (e.g. "100") from the path and
    // search the manifest for a file in the same folder starting with it.
    // This handles cases where the index filename doesn't match the actual file
    // (e.g. wrong title in filename, or number-only file like "416.MID").
    final numberMatch = RegExp(r'/(\d+)[^/]*$').firstMatch(candidate);
    if (numberMatch != null) {
      final number = numberMatch.group(1)!;
      final folder = candidate.substring(0, numberMatch.start + 1);
      final folderPrefix = folder.toLowerCase();
      final numPattern = RegExp(
        '^$number'
        r'[._\-]',
        caseSensitive: false,
      );
      for (final key in manifest.keys) {
        final normalizedKey = key.replaceAll('\\', '/').toLowerCase();
        if (normalizedKey.startsWith(folderPrefix)) {
          final fileName = normalizedKey.split('/').last;
          if (numPattern.hasMatch(fileName) ||
              fileName == '$number.mid' ||
              fileName == '$number.MID') {
            return key;
          }
        }
      }
    }

    log('Asset path not found: $path', name: 'LocalAssetService');
    return null;
  }

  String _withDataPrefix(String path) {
    final normalized = path.replaceAll('\\', '/');
    if (normalized.startsWith('assets/')) return normalized;
    return 'assets/data/$normalized';
  }

  Future<Map<String, dynamic>> _loadAssetManifest() async {
    if (_assetManifest != null) return _assetManifest!;

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _assetManifest = {
        for (final asset in manifest.listAssets()) asset: const <String>[],
      };
    } catch (e) {
      log('Failed to load asset manifest: $e', name: 'LocalAssetService');
      _assetManifest = {};
    }
    return _assetManifest!;
  }

  Future<Map<String, String>> _loadNormalizedAssetPathMap() async {
    if (_normalizedAssetPathMap != null) return _normalizedAssetPathMap!;

    final manifest = await _loadAssetManifest();
    _normalizedAssetPathMap = {
      for (final key in manifest.keys) _normalizeAssetKey(key): key,
    };
    return _normalizedAssetPathMap!;
  }

  String _normalizeAssetKey(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  /// Get all available soundfont files
  Future<List<String>> getAvailableSoundFonts() async {
    final manifest = await _loadAssetManifest();
    return manifest.keys
        .where((k) => k.startsWith('assets/data/soundfont/') && k.toLowerCase().endsWith('.sf2'))
        .map((k) => k.split('/').last)
        .toList()..sort();
  }
}

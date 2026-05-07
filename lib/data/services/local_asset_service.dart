import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../../domain/entity/song/song_entity.dart';

class LocalAssetService {
  final Map<String, List<Map<String, dynamic>>> _indexCache = {};
  final Map<String, dynamic> _masterIndex = {};
  Map<String, dynamic>? _assetManifest;
  Map<String, String>? _normalizedAssetPathMap;

  Future<void> initialize() async {
    await _loadMasterIndex();
  }

  Future<void> _loadMasterIndex() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/index/master_index.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      _masterIndex.addAll(data);
    } catch (e) {
      log('Failed to load master index: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _loadBookIndex(String code) async {
    if (_indexCache.containsKey(code)) {
      return _indexCache[code]!;
    }

    final fileName =
        'assets/data/index/${code.toLowerCase().replaceAll('-', '_')}_index.json';
    try {
      final jsonString = await rootBundle.loadString(fileName);
      final List<dynamic> data = jsonDecode(jsonString);
      final songs = data.cast<Map<String, dynamic>>();
      _indexCache[code] = songs;
      return songs;
    } catch (e) {
      log('Failed to load index for $code: $e');
      return [];
    }
  }

  Future<List<SongBook>> loadSongBooks() async {
    final books = <SongBook>[];
    for (final code in ['KR', 'HYMNE', 'MDR', 'ASM-I', 'ASM-M', 'ASM-P']) {
      final songs = await loadSongBook(code);
      books.add(songs);
    }
    return books;
  }

  Future<SongBook> loadSongBook(String code) async {
    final songsData = await _loadBookIndex(code);
    final songs = await Future.wait(
      songsData.map(
        (data) async => Song(
          code: code,
          number: data['number'] as String?,
          number2: data['number2'] as String?,
          title: data['title'] as String?,
          soundfilePath: await _resolveAssetPath(data['midiFile'] as String?),
          pageLength: data['pages'] as int?,
          pageStart: data['page'] as int?,
          verses: (data['verses'] as List<dynamic>?)?.cast<String>() ?? [],
        ),
      ),
    );

    return SongBook(code: code, songs: songs);
  }

  Future<String?> getMidiPath(String bookCode, String number) async {
    final songs = await _loadBookIndex(bookCode);
    final song = songs.firstWhere(
      (s) => s['number'] == number,
      orElse: () => {},
    );
    if (song.isEmpty) return null;
    return _resolveAssetPath(song['midiFile'] as String?);
  }

  Future<String?> getChordPath(String bookCode, String number) async {
    if (bookCode != 'KR') return null;
    final songs = await _loadBookIndex(bookCode);
    final song = songs.firstWhere(
      (s) => s['number'] == number,
      orElse: () => {},
    );
    if (song.isEmpty) return null;
    if (song['hasChord'] != true) return null;
    return _resolveAssetPath(song['chordFile'] as String?);
  }

  Future<String?> getPdfPath(String bookCode, String number) async {
    final songs = await _loadBookIndex(bookCode);
    final song = songs.firstWhere(
      (s) => s['number'] == number,
      orElse: () => {},
    );
    if (song.isEmpty) return null;
    return _resolveAssetPath(song['pdfFile'] as String?);
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
    if (resolved == null) {
      log('Asset path not found: $path', name: 'LocalAssetService');
    }
    return resolved;
  }

  String _withDataPrefix(String path) {
    final normalized = path.replaceAll('\\', '/');
    if (normalized.startsWith('assets/')) return normalized;
    return 'assets/data/$normalized';
  }

  Future<Map<String, dynamic>> _loadAssetManifest() async {
    if (_assetManifest != null) return _assetManifest!;

    try {
      final jsonString = await rootBundle.loadString('AssetManifest.json');
      _assetManifest = jsonDecode(jsonString) as Map<String, dynamic>;
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

  /// Copy SoundFont from assets to app documents directory for WebView access.
  Future<String> getSoundFontPath(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final targetFile = File('${dir.path}/soundfont/$fileName');

    if (await targetFile.exists()) {
      return targetFile.path;
    }

    await targetFile.parent.create(recursive: true);

    final assetPath = 'assets/data/soundfont/$fileName';
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    await targetFile.writeAsBytes(bytes, flush: true);

    return targetFile.path;
  }

  /// Get all available soundfont files
  Future<List<String>> getAvailableSoundFonts() async {
    return ['GeneralUser-GS.sf2', 'TimGM6mb.sf2'];
  }
}

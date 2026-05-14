import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../domain/entity/song/song_entity.dart';
import 'pdf_chunk_service.dart';

class LocalAssetService {
  final PdfChunkService _chunkService;

  LocalAssetService(this._chunkService);

  final Map<String, List<Map<String, dynamic>>> _indexCache = {};
  final Map<String, Map<String, Map<String, dynamic>>> _songLookupCache = {};
  Map<String, dynamic>? _assetManifest;
  final Map<String, Map<String, dynamic>> _pdfManifestCache = {};
  Map<String, String>? _normalizedAssetPathMap;
  Map<String, Map<String, String>>? _pdfPathByBookAndNumber;

  /// Maps asset paths (e.g. `assets/data/pdf/mdr/mdr_master.pdf`) to temp file
  /// paths extracted on disk so pdfrx can open them with `PdfViewer.file`.
  final Map<String, String> _masterPdfTempPaths = {};
  final Map<String, Future<String?>> _inflightExtractions = {};

  Future<void> initialize() async {}

  /// Force extraction of a master PDF asset to a temp file for instant access later.
  Future<void> preparePdfFile(String assetPath) async {
    await _extractMasterPdfToTemp(assetPath);
  }

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

    // No PDF for this song — not an error, many songs legitimately have
    // no sheet-music PDF (e.g. MDR songs 003, 103, etc.).
    return null;
  }

  Future<String?> _resolveMasterPdfPath(String bookCode, String number) async {
    final manifest = await _loadPdfManifest(bookCode);
    if (manifest.isEmpty) {
      log('Manifest empty for $bookCode', name: 'LocalAssetService');
      return null;
    }

    final songs = manifest['songs'];
    if (songs is! Map<String, dynamic>) {
      log('Manifest songs missing for $bookCode', name: 'LocalAssetService');
      return null;
    }

    final entry = songs[number] ?? songs[number.padLeft(3, '0')];
    if (entry is! Map<String, dynamic>) {
      log(
        'Song $number not found in $bookCode manifest',
        name: 'LocalAssetService',
      );
      return null;
    }

    // Check for optimized chunks first
    final chunkFile = manifest['chunkFile'] as String?;
    final chunkIndex = entry['chunkIndex'];
    final relStart = entry['chunkRelativeStart'];
    if (chunkFile != null && chunkIndex is int && relStart is int) {
      try {
        final chunkPath = await _chunkService.getChunkFile(
          chunkFilePath: chunkFile,
          chunkIndex: chunkIndex,
          cacheKey: bookCode,
        );
        if (chunkPath != null) {
          final pageCount = entry['pageCount'] as int? ?? 1;
          final masterPath = manifest['masterPath'] as String? ?? chunkFile;
          final version = await _fileVersion(chunkPath);
          return '$chunkPath#${_pdfRangeFragment(page: relStart, pages: pageCount, master: masterPath, version: version)}';
        }
      } catch (e) {
        log(
          'Failed to load chunk for $bookCode $number: $e',
          name: 'LocalAssetService',
        );
      }
    }

    final path = entry['path'] as String? ?? manifest['masterPath'] as String?;
    final startPage = entry['startPage'];
    final pageCount = entry['pageCount'];
    if (path == null || startPage is! int || pageCount is! int) {
      log('Incomplete entry for $bookCode $number', name: 'LocalAssetService');
      return null;
    }

    // Extract large master PDFs to temp files so pdfrx opens them via
    // PdfViewer.file() instead of PdfViewer.asset().  This avoids flaky
    // asset-loading on Windows desktop with multi-ten-megabyte files.
    if (path.startsWith('assets/')) {
      final tempPath = await _extractMasterPdfToTemp(path);
      if (tempPath != null) {
        final version = await _fileVersion(tempPath);
        return '$tempPath#${_pdfRangeFragment(page: startPage, pages: pageCount, version: version)}';
      }
    }

    return '$path#${_pdfRangeFragment(page: startPage, pages: pageCount)}';
  }

  Future<String?> _fileVersion(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      return (await file.lastModified()).millisecondsSinceEpoch.toString();
    } catch (_) {
      return null;
    }
  }

  String _pdfRangeFragment({
    required int page,
    int? pages,
    String? master,
    String? version,
  }) {
    final parts = <String>['page=$page'];
    if (pages != null) parts.add('pages=$pages');
    if (master != null) parts.add('master=$master');
    if (version != null) parts.add('v=$version');
    return parts.join('&');
  }

  Future<Map<String, dynamic>> _loadPdfManifest(String bookCode) async {
    // Only return cached value if it is a real manifest (not an empty error
    // placeholder) so that transient load failures are retried next time.
    if (_pdfManifestCache.containsKey(bookCode) &&
        _pdfManifestCache[bookCode]!.isNotEmpty) {
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
      final manifest = jsonDecode(jsonString) as Map<String, dynamic>;
      _pdfManifestCache[bookCode] = manifest;
      return manifest;
    } catch (e, st) {
      log(
        'Failed to load PDF manifest for $bookCode: $e\n$st',
        name: 'LocalAssetService',
      );
      return {};
    }
  }

  /// Copy a master PDF asset to a temp file once per session so pdfrx can
  /// open it with PdfViewer.file() which is more reliable than .asset() for
  /// large files on Windows desktop.
  Future<String?> _extractMasterPdfToTemp(String assetPath) async {
    if (_masterPdfTempPaths.containsKey(assetPath)) {
      final cached = _masterPdfTempPaths[assetPath]!;
      final cachedFile = File(cached);
      if (await _isCompletePdf(cachedFile)) return cached;
      await cachedFile.delete().catchError((_) => cachedFile);
      _masterPdfTempPaths.remove(assetPath);
    }

    final inflight = _inflightExtractions[assetPath];
    if (inflight != null) return inflight;

    final future = _extractMasterPdfToTempInternal(assetPath);
    _inflightExtractions[assetPath] = future;
    try {
      return await future;
    } finally {
      if (identical(_inflightExtractions[assetPath], future)) {
        _inflightExtractions.remove(assetPath);
      }
    }
  }

  Future<String?> _extractMasterPdfToTempInternal(String assetPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = p.basename(assetPath);
      final pdfDir = Directory(p.join(appDir.path, 'master_pdfs'));
      final targetFile = File(p.join(pdfDir.path, fileName));

      // If file exists and is complete, reuse it permanently.
      if (await targetFile.exists()) {
        if (await _isCompletePdf(targetFile)) {
          _masterPdfTempPaths[assetPath] = targetFile.path;
          return targetFile.path;
        }
        await targetFile.delete().catchError((_) => targetFile);
      }

      await pdfDir.create(recursive: true);

      final byteData = await rootBundle.load(assetPath);
      final tempFile = File(
        '${targetFile.path}.${DateTime.now().microsecondsSinceEpoch}.$pid.tmp',
      );

      if (byteData.lengthInBytes > 1024 * 1024 * 1) {
        // > 1MB
        await compute(
          (args) {
            final file = File(args['path'] as String);
            final bytes = args['bytes'] as Uint8List;
            file.writeAsBytesSync(bytes, flush: true);
          },
          {
            'path': tempFile.path,
            'bytes': byteData.buffer.asUint8List(
              byteData.offsetInBytes,
              byteData.lengthInBytes,
            ),
          },
        );
      } else {
        await tempFile.writeAsBytes(
          byteData.buffer.asUint8List(
            byteData.offsetInBytes,
            byteData.lengthInBytes,
          ),
          flush: true,
        );
      }
      if (!await _isCompletePdf(tempFile)) {
        await tempFile.delete().catchError((_) => tempFile);
        return null;
      }

      if (await targetFile.exists()) {
        if (await _isCompletePdf(targetFile)) {
          await tempFile.delete().catchError((_) => tempFile);
          _masterPdfTempPaths[assetPath] = targetFile.path;
          return targetFile.path;
        }
        await targetFile.delete().catchError((_) => targetFile);
      }

      try {
        await tempFile.rename(targetFile.path);
      } on FileSystemException {
        if (await _isCompletePdf(targetFile)) {
          await tempFile.delete().catchError((_) => tempFile);
          _masterPdfTempPaths[assetPath] = targetFile.path;
          return targetFile.path;
        }
        await tempFile.delete().catchError((_) => tempFile);
        return null;
      }

      _masterPdfTempPaths[assetPath] = targetFile.path;
      log(
        'Extracted master PDF permanently to ${targetFile.path}',
        name: 'LocalAssetService',
      );
      return targetFile.path;
    } catch (e) {
      log(
        'Failed to extract master PDF $assetPath: $e',
        name: 'LocalAssetService',
      );
      return null;
    }
  }

  static Future<bool> _isCompletePdf(File file) async {
    try {
      if (!await file.exists()) return false;
      final length = await file.length();
      if (length < 8) return false;

      final raf = await file.open();
      try {
        final header = await raf.read(5);
        if (!_matchesBytes(header, const [0x25, 0x50, 0x44, 0x46, 0x2D])) {
          return false;
        }

        final tailLength = length < 2048 ? length : 2048;
        await raf.setPosition(length - tailLength);
        final tail = await raf.read(tailLength);
        return _containsBytes(tail, const [0x25, 0x25, 0x45, 0x4F, 0x46]);
      } finally {
        await raf.close();
      }
    } catch (_) {
      return false;
    }
  }

  static bool _matchesBytes(List<int> bytes, List<int> pattern) {
    if (bytes.length < pattern.length) return false;
    for (var i = 0; i < pattern.length; i++) {
      if (bytes[i] != pattern[i]) return false;
    }
    return true;
  }

  static bool _containsBytes(List<int> bytes, List<int> pattern) {
    if (bytes.length < pattern.length) return false;
    for (var i = 0; i <= bytes.length - pattern.length; i++) {
      var found = true;
      for (var j = 0; j < pattern.length; j++) {
        if (bytes[i + j] != pattern[j]) {
          found = false;
          break;
        }
      }
      if (found) return true;
    }
    return false;
  }

  String? _pdfFolderForBookCode(String bookCode) {
    return switch (bookCode) {
      'KR' => 'kr',
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

    // Asset not found — the song may simply have no PDF file.
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
        .where(
          (k) =>
              k.startsWith('assets/data/soundfont/') &&
              k.toLowerCase().endsWith('.sf2'),
        )
        .map((k) => k.split('/').last)
        .toList()
      ..sort();
  }
}

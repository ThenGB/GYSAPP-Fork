import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../domain/entity/song/song_entity.dart';
import '../../di/injection.dart';
import 'asset_distribution/installed_asset_registry.dart';
import 'asset_distribution/models.dart';
import 'chord_sync_service.dart';
import 'pdf_chunk_service.dart';

/// Top-level helper so [compute] can run the big song-index decode on a
/// background isolate.
List<dynamic> _decodeIndexJson(String source) =>
    jsonDecode(source) as List<dynamic>;

class LocalAssetService {
  // Retained as a constructor dependency for backward compatibility with
  // existing tests and injection wiring while chunk bundles are phased out.
  // ignore: unused_field
  final PdfChunkService _chunkService;
  final InstalledAssetRegistry? _installedAssetRegistry;

  LocalAssetService(this._chunkService, {InstalledAssetRegistry? installedAssetRegistry})
    : _installedAssetRegistry = installedAssetRegistry;

  final Map<String, List<Map<String, dynamic>>> _indexCache = {};
  final Map<String, Map<String, Map<String, dynamic>>> _songLookupCache = {};
  Map<String, dynamic>? _assetManifest;
  final Map<String, Map<String, dynamic>> _pdfManifestCache = {};
  Map<String, String>? _normalizedAssetPathMap;

  /// Maps asset paths (e.g. `assets/data/pdf/mdr/mdr_master.pdf`) to temp file
  /// paths extracted on disk so pdfrx can open them with `PdfViewer.file`.
  final Map<String, String> _masterPdfTempPaths = {};
  final Map<String, Future<String?>> _inflightExtractions = {};

  Future<void> initialize() async {}

  /// Force extraction of a master PDF asset to a temp file for instant access later.
  Future<void> preparePdfFile(String assetPath) async {
    await _extractMasterPdfToTemp(assetPath);
  }

  Future<bool> needsPdfPreparation(String bookCode, String number) async {
    final bundledMasterPath = await _resolveMasterPdfAssetPath(bookCode, number);
    if (bundledMasterPath == null) return false;
    return !(await _isMasterPdfPrepared(bundledMasterPath));
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
      // ~2MB of index JSON across all books — decode on a background isolate
      // so startup / first Hymnal open doesn't jank the UI thread.
      final List<dynamic> data = await compute(_decodeIndexJson, jsonString);
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
    final registry = _installedAssetRegistry;
    final codes = registry == null
        ? const ['KR', 'HYMNE', 'MDR', 'ASM-I', 'ASM-M', 'ASM-P']
        : await _loadAvailableBookCodesFromRegistry(registry);
    return Future.wait(codes.map(loadSongBook));
  }

  Future<List<String>> _loadAvailableBookCodesFromRegistry(
    InstalledAssetRegistry registry,
  ) async {
    final installed = await registry.getInstalledRecords(
      kind: DistributedAssetKind.hymnal,
    );
    final codes = <String>{'KR'};
    for (final record in installed) {
      codes.add(record.code);
    }
    return codes.toList()..sort();
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
    final song = await _findSong(bookCode, number);
    if (song.isEmpty) return null;

    // Native chord file only. Do not cross-map chords across books because
    // numbering/title mappings can differ per book.
    if (song['hasChord'] == true) {
      final chordFile = song['chordFile'] as String?;
      // 1. Chord synced from gyschordweb wins over everything.
      final synced = await di<ChordSyncService>()
          .resolveInstalledChordPath(chordFile);
      if (synced != null) return synced;
      // 2. Bundled fallback (kept only until the first sync replaces it).
      final nativePath = await _resolveAssetPath(chordFile);
      if (nativePath != null) return nativePath;
    }

    return null;
  }

  /// Reads the chord JSON text for a song, transparently handling both
  /// synced file paths (app support dir) and bundled assets.
  Future<String?> readChordJson(String bookCode, String number) async {
    final path = await getChordPath(bookCode, number);
    if (path == null) return null;
    try {
      if (path.startsWith('assets/') || path.startsWith('data/')) {
        return rootBundle.loadString(path);
      }
      final file = File(path);
      if (await file.exists()) return file.readAsString();
    } catch (_) {}
    return null;
  }

  Future<String?> getPdfPath(String bookCode, String number) async {
    return _resolveMasterPdfPath(bookCode, number);
  }

  Future<Map<String, dynamic>> _findSong(String bookCode, String number) async {
    await _loadBookIndex(bookCode);
    return _songLookupCache[bookCode]?[number] ?? {};
  }

  Future<String?> _resolveMasterPdfPath(String bookCode, String number) async {
    final entry = await _loadPdfManifestSongEntry(bookCode, number);
    if (entry == null) return null;

    final startPage = entry.startPage;
    final pageCount = entry.pageCount;
    final installedMasterPath = await _installedAssetRegistry
        ?.resolveInstalledHymnalPath(bookCode);
    final bundledMasterPath = installedMasterPath ?? entry.masterAssetPath;

    if (bundledMasterPath == null) {
      log(
        'Master PDF missing for $bookCode $number',
        name: 'LocalAssetService',
      );
      return null;
    }

    final localMasterPath =
        installedMasterPath ??
        await _extractMasterPdfToTemp(bundledMasterPath) ??
        bundledMasterPath;
    final version = localMasterPath == bundledMasterPath
        ? null
        : await _fileVersion(localMasterPath);

    return '$localMasterPath#${_pdfRangeFragment(page: startPage, pages: pageCount, version: version)}';
  }

  Future<_PdfManifestSongEntry?> _loadPdfManifestSongEntry(
    String bookCode,
    String number,
  ) async {
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

    final startPage =
        entry['startPage'] as int? ??
        entry['page'] as int? ??
        entry['chunkRelativeStart'] as int?;
    if (startPage == null) {
      log(
        'Song $number in $bookCode manifest is missing a start page',
        name: 'LocalAssetService',
      );
      return null;
    }

    final pageCount =
        entry['pageCount'] as int? ?? entry['pages'] as int? ?? 1;
    final manifestMasterPath = manifest['masterPath'] as String?;
    final entryMasterPath = entry['path'] as String?;
    final bundledMasterPath = await _resolveAssetPath(
      manifestMasterPath ?? entryMasterPath,
    );

    return _PdfManifestSongEntry(
      startPage: startPage,
      pageCount: pageCount,
      masterAssetPath: bundledMasterPath,
    );
  }

  Future<String?> _resolveMasterPdfAssetPath(String bookCode, String number) async {
    final entry = await _loadPdfManifestSongEntry(bookCode, number);
    return entry?.masterAssetPath;
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
      final targetFile = await _masterPdfTargetFile(assetPath);
      final pdfDir = targetFile.parent;

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

  Future<bool> _isMasterPdfPrepared(String assetPath) async {
    final cached = _masterPdfTempPaths[assetPath];
    if (cached != null) {
      final cachedFile = File(cached);
      if (await _isCompletePdf(cachedFile)) return true;
      _masterPdfTempPaths.remove(assetPath);
    }

    final targetFile = await _masterPdfTargetFile(assetPath);
    return _isCompletePdf(targetFile);
  }

  Future<File> _masterPdfTargetFile(String assetPath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(assetPath);
    final pdfDir = Directory(p.join(appDir.path, 'master_pdfs'));
    return File(p.join(pdfDir.path, fileName));
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

  Future<bool> hasChord(String bookCode, String number) async {
    return await readChordJson(bookCode, number) != null;
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
      final assetMap = {
        for (final asset in manifest.listAssets()) asset: const <String>[],
      };
      if (assetMap.isNotEmpty) {
        _assetManifest = assetMap;
        return _assetManifest!;
      }
    } catch (e) {
      log('Failed to load asset manifest: $e', name: 'LocalAssetService');
    }
    _assetManifest = await _loadAssetManifestFromSourceTree();
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
    return Uri.decodeFull(
      value,
    ).toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  /// Get all available soundfont files
  Future<List<String>> getAvailableSoundFonts() async {
    final manifest = await _loadAssetManifest();
    final fonts = <String>{
      ...manifest.keys
          .where(
            (k) =>
                k.startsWith('assets/data/soundfont/') &&
                k.toLowerCase().endsWith('.sf2'),
          )
          .map((k) => Uri.decodeFull(k.split('/').last)),
    };
    // Downloaded soundfonts live in the install directory — include them
    // so a freshly downloaded font appears as selectable immediately
    // (previously only bundled manifest entries were listed).
    final registry = _installedAssetRegistry;
    if (registry != null) {
      final dir = registry.soundfontInstallDirectory;
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          final name = entity.uri.pathSegments.last;
          if (name.toLowerCase().endsWith('.sf2')) {
            fonts.add(name);
          }
        }
      }
    }
    return fonts.toList()..sort();
  }

  Future<Map<String, dynamic>> _loadAssetManifestFromSourceTree() async {
    final assetsDir = Directory('assets');
    if (!await assetsDir.exists()) {
      return {};
    }

    final manifest = <String, dynamic>{};
    await for (final entity in assetsDir.list(recursive: true)) {
      if (entity is! File) continue;
      manifest[entity.path.replaceAll('\\', '/')] = const <String>[];
    }
    return manifest;
  }
}

class _PdfManifestSongEntry {
  const _PdfManifestSongEntry({
    required this.startPage,
    required this.pageCount,
    required this.masterAssetPath,
  });

  final int startPage;
  final int pageCount;
  final String? masterAssetPath;
}

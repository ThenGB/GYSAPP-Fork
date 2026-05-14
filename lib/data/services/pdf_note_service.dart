import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'pdf_note_extractor.dart';

/// Parsed PDF path with optional `#page=N&pages=M` fragment.
///
/// Example: `assets/data/pdf/kr/001.pdf#page=3&pages=2`
class PdfDocumentRequest {
  const PdfDocumentRequest({
    required this.assetPath,
    required this.sourceId,
    required this.startPage,
    required this.pageCount,
    required this.isFile,
    this.masterPath,
  });

  final String assetPath;
  final String sourceId;
  final String? masterPath;
  final int startPage;
  final int? pageCount;

  /// Whether this path points to a file on disk (as opposed to a bundled asset).
  final bool isFile;

  static final _driveLetterPattern = RegExp(r'^[A-Za-z]:/');

  static PdfDocumentRequest parse(String value) {
    final normalized = value.replaceAll('\\', '/');
    final fragmentIndex = normalized.indexOf('#');

    String assetPath;
    String? fragment;
    if (fragmentIndex < 0) {
      assetPath = normalized;
      fragment = null;
    } else {
      assetPath = normalized.substring(0, fragmentIndex);
      fragment = normalized.substring(fragmentIndex + 1);
    }

    // File paths start with '/' (Unix/macOS) or a drive letter like 'C:/' (Windows).
    // Asset paths never start with either.
    final isFile =
        assetPath.startsWith('/') || _driveLetterPattern.hasMatch(assetPath);

    if (fragment == null) {
      return PdfDocumentRequest(
        assetPath: assetPath,
        sourceId: normalized,
        startPage: 1,
        pageCount: null,
        isFile: isFile,
      );
    }

    // Supports query-style fragment: page=N&pages=M&master=path
    final params = Uri.splitQueryString(fragment);
    final startPage = int.tryParse(params['page'] ?? '') ?? 1;
    final pageCount = int.tryParse(params['pages'] ?? '');
    final masterPath = params['master'];

    return PdfDocumentRequest(
      assetPath: assetPath,
      sourceId: normalized,
      startPage: startPage,
      pageCount: pageCount,
      isFile: isFile,
      masterPath: masterPath,
    );
  }
}

/// Global service for caching and pre-extracting note positions from PDF sheet music.
///
/// This improves performance by allowing background warmup and avoiding redundant
/// extraction when switching between songs or reopening the viewer.
class PdfNoteService {
  static final PdfNoteService _instance = PdfNoteService._internal();
  factory PdfNoteService() => _instance;
  PdfNoteService._internal();

  /// Cache of note positions per PDF asset path and page.
  /// Key: "path#page"
  final Map<String, Map<int, NotePosition>> _posCache = {};

  /// Cache of detailed note info (for edit mode).
  final Map<String, List<NoteInfo>> _infoCache = {};

  /// Cache of full extraction results.
  final Map<String, PdfExtractionResult> _resultCache = {};

  /// Cache of opened documents to speed up text extraction.
  final Map<String, PdfDocument> _docCache = {};

  /// Directory for disk-based extraction cache.
  Directory? _cacheDir;

  Future<void> _ensureCacheDir() async {
    if (_cacheDir != null) return;
    final temp = await getTemporaryDirectory();
    _cacheDir = Directory(p.join(temp.path, 'pdf_note_cache'));
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
  }

  String _getDiskCachePath(String assetPath, int pageNumber) {
    final fileName = '${assetPath.hashCode}_$pageNumber.json';
    return p.join(_cacheDir!.path, fileName);
  }

  /// Pre-extract notes for a PDF document. Used by the warmup engine.
  Future<void> warmup(
    String pdfPath, {
    int startPage = 1,
    int? pageCount,
  }) async {
    try {
      final cleanPath = pdfPath.split('#').first;
      final doc = await _getOrOpenDocument(cleanPath);

      try {
        final actualStart = startPage;
        final actualEnd = pageCount != null
            ? actualStart + pageCount
            : doc.pages.length + 1;

        for (int i = actualStart; i < actualEnd && i <= doc.pages.length; i++) {
          final page = doc.pages[i - 1];
          await loadNotePositions(page, cleanPath);
        }
      } finally {
        // Don't dispose here, let _docCache manage it or periodic cleanup
      }
    } catch (e) {
      log('PdfNoteService: Warmup failed for $pdfPath: $e');
    }
  }

  Future<PdfDocument> _getOrOpenDocument(String path) async {
    if (_docCache.containsKey(path)) return _docCache[path]!;

    final isFile = path.startsWith('/') || path.contains(':/');
    final doc = isFile
        ? await PdfDocument.openFile(path)
        : await PdfDocument.openAsset(path);

    // Simple cache management: only keep 3 docs open
    if (_docCache.length >= 3) {
      final firstKey = _docCache.keys.first;
      final oldDoc = _docCache.remove(firstKey);
      await oldDoc?.dispose();
    }

    return _docCache[path] = doc;
  }

  /// Load both positions and detailed info in a single extraction.
  /// This is more efficient than calling loadNotePositions and loadNoteInfos separately.
  Future<
    ({
      Map<int, NotePosition> positions,
      List<NoteInfo> infos,
      String? detectedKey,
      double? detectedTempo,
    })
  >
  loadNotePositionsAndInfos(PdfPage page, String assetPath) async {
    final key = '$assetPath#${page.pageNumber}';
    if (_resultCache.containsKey(key)) {
      final result = _resultCache[key]!;
      return (
        positions: {
          for (final info in result.notes)
            info.idx: (xPct: info.xPct, yPct: info.yPct),
        },
        infos: result.notes,
        detectedKey: result.detectedKey,
        detectedTempo: result.detectedTempo,
      );
    }

    await _ensureCacheDir();
    final diskPath = _getDiskCachePath(assetPath, page.pageNumber);
    final diskFile = File(diskPath);

    if (await diskFile.exists()) {
      try {
        final jsonStr = await diskFile.readAsString();
        final result = PdfExtractionResult.fromJson(jsonDecode(jsonStr));
        _resultCache[key] = result;
        return (
          positions: {
            for (final info in result.notes)
              info.idx: (xPct: info.xPct, yPct: info.yPct),
          },
          infos: result.notes,
          detectedKey: result.detectedKey,
          detectedTempo: result.detectedTempo,
        );
      } catch (e) {
        log('PdfNoteService: Failed to read disk cache for $key: $e');
      }
    }

    try {
      final rawText = await page.loadText();
      if (rawText == null) {
        return (
          positions: <int, NotePosition>{},
          infos: <NoteInfo>[],
          detectedKey: null,
          detectedTempo: null,
        );
      }

      final result = await extractPdfContentAsync(
        rawText,
        page.width,
        page.height,
      );
      _resultCache[key] = result;

      // Save to disk cache for instant subsequent loads
      unawaited(
        diskFile.writeAsString(jsonEncode(result.toJson())).catchError((e) {
          log('PdfNoteService: Failed to save disk cache for $key: $e');
          return diskFile;
        }),
      );

      return (
        positions: {
          for (final info in result.notes)
            info.idx: (xPct: info.xPct, yPct: info.yPct),
        },
        infos: result.notes,
        detectedKey: result.detectedKey,
        detectedTempo: result.detectedTempo,
      );
    } catch (e) {
      log('PdfNoteService: Failed to extract content for $key: $e');
      return (
        positions: <int, NotePosition>{},
        infos: <NoteInfo>[],
        detectedKey: null,
        detectedTempo: null,
      );
    }
  }

  Future<PdfExtractionResult> loadNotePositions(
    PdfPage page,
    String assetPath,
  ) async {
    final key = '$assetPath#${page.pageNumber}';
    if (_resultCache.containsKey(key)) return _resultCache[key]!;

    await _ensureCacheDir();
    final diskPath = _getDiskCachePath(assetPath, page.pageNumber);
    final diskFile = File(diskPath);

    if (await diskFile.exists()) {
      try {
        final jsonStr = await diskFile.readAsString();
        final result = PdfExtractionResult.fromJson(jsonDecode(jsonStr));
        _resultCache[key] = result;
        return result;
      } catch (e) {
        log('PdfNoteService: Failed to read disk cache for $key: $e');
      }
    }

    try {
      final rawText = await page.loadText();
      if (rawText == null) return PdfExtractionResult(notes: []);

      final result = await extractPdfContentAsync(
        rawText,
        page.width,
        page.height,
      );
      _resultCache[key] = result;

      // Save to disk cache for instant subsequent loads
      unawaited(
        diskFile.writeAsString(jsonEncode(result.toJson())).catchError((e) {
          log('PdfNoteService: Failed to save disk cache for $key: $e');
          return diskFile;
        }),
      );

      return result;
    } catch (e) {
      log('PdfNoteService: Failed to extract content for $key: $e');
      return PdfExtractionResult(notes: []);
    }
  }

  Future<List<NoteInfo>> loadNoteInfos(PdfPage page, String assetPath) async {
    final key = '$assetPath#${page.pageNumber}';
    if (_infoCache.containsKey(key)) return _infoCache[key]!;

    try {
      final rawText = await page.loadText();
      if (rawText == null) return _infoCache[key] = [];

      final result = await extractPdfContentAsync(
        rawText,
        page.width,
        page.height,
      );
      final infos = result.notes;
      return _infoCache[key] = infos;
    } catch (e) {
      log('PdfNoteService: Failed to extract infos for $key: $e');
      return _infoCache[key] = [];
    }
  }

  void clearCache() {
    _posCache.clear();
    _infoCache.clear();
    _resultCache.clear();
    for (final doc in _docCache.values) {
      doc.dispose();
    }
    _docCache.clear();
  }
}

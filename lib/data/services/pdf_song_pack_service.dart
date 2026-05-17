import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PdfSongPackService {
  static const int _headerSize = 32;
  static const int _indexEntrySize = 40;
  static const int _maxPackBinaryCacheEntries = 2;

  static final _driveLetterPattern = RegExp(r'^[A-Za-z]:[/\\]');

  static final Map<String, Uint8List> _packBinaryCache = {};
  static final Map<String, Future<Uint8List>> _inflightPackLoads = {};
  static final Map<String, Future<String?>> _inflightSongExtractions = {};

  Future<String?> getSongFile({
    required String packFilePath,
    required int songIndex,
    required String cacheKey,
  }) async {
    final extractionKey = '$packFilePath#$songIndex#$cacheKey';
    final inflight = _inflightSongExtractions[extractionKey];
    if (inflight != null) return inflight;

    final extractionFuture = _getSongFileInternal(
      packFilePath: packFilePath,
      songIndex: songIndex,
      cacheKey: cacheKey,
    );
    _inflightSongExtractions[extractionKey] = extractionFuture;
    try {
      return await extractionFuture;
    } finally {
      if (identical(_inflightSongExtractions[extractionKey], extractionFuture)) {
        _inflightSongExtractions.remove(extractionKey);
      }
    }
  }

  Future<String?> _getSongFileInternal({
    required String packFilePath,
    required int songIndex,
    required String cacheKey,
  }) async {
    try {
      final tempDir = await getApplicationSupportDirectory();
      final targetPath = p.join(
        tempDir.path,
        'pdf_song_packs',
        '${cacheKey}_$songIndex.pdf',
      );
      final targetFile = File(targetPath);

      if (await targetFile.exists()) {
        if (await _isCompletePdf(targetFile)) return targetPath;
        await targetFile.delete().catchError((_) => targetFile);
      }

      await targetFile.parent.create(recursive: true);

      final bytes = await _loadPackBinary(packFilePath);
      if (bytes.length < _headerSize) return null;

      final magic = String.fromCharCodes(bytes.sublist(0, 4));
      if (magic != 'SPK2') return null;

      final entryCount = ByteData.sublistView(bytes, 8, 12).getUint32(
        0,
        Endian.little,
      );
      if (songIndex < 0 || songIndex >= entryCount) return null;

      final indexOffset = _headerSize + (songIndex * _indexEntrySize);
      final entryData = ByteData.sublistView(
        bytes,
        indexOffset,
        indexOffset + _indexEntrySize,
      );

      final compressedSize = entryData.getUint32(12, Endian.little);
      final dataOffset = entryData.getUint32(20, Endian.little);
      if (compressedSize <= 0 ||
          dataOffset <= 0 ||
          dataOffset + compressedSize > bytes.length) {
        return null;
      }

      final compressedData = bytes.sublist(
        dataOffset,
        dataOffset + compressedSize,
      );
      final decompressedData = GZipDecoder().decodeBytes(compressedData);

      final tempFile = File(
        '$targetPath.${DateTime.now().microsecondsSinceEpoch}.$pid.tmp',
      );
      await tempFile.writeAsBytes(decompressedData, flush: true);
      if (!await _isCompletePdf(tempFile)) {
        await tempFile.delete().catchError((_) => tempFile);
        return null;
      }

      if (await targetFile.exists()) {
        if (await _isCompletePdf(targetFile)) {
          await tempFile.delete().catchError((_) => tempFile);
          return targetPath;
        }
        await targetFile.delete().catchError((_) => targetFile);
      }

      try {
        await tempFile.rename(targetPath);
      } on FileSystemException {
        if (await targetFile.exists() && await _isCompletePdf(targetFile)) {
          await tempFile.delete().catchError((_) => tempFile);
          return targetPath;
        }
        await tempFile.delete().catchError((_) => tempFile);
        return null;
      }

      return targetPath;
    } catch (e) {
      log('PdfSongPackService error: $e', name: 'PdfSongPackService');
      return null;
    }
  }

  Future<Uint8List> _loadPackBinary(String packFilePath) async {
    final cached = _packBinaryCache[packFilePath];
    if (cached != null) return cached;

    final inflight = _inflightPackLoads[packFilePath];
    if (inflight != null) return inflight;

    final future = () async {
      final normalized = packFilePath.replaceAll('\\', '/');
      final isFile =
          normalized.startsWith('/') || _driveLetterPattern.hasMatch(normalized);

      final Uint8List bytes;
      if (isFile) {
        bytes = await File(packFilePath).readAsBytes();
      } else {
        final byteData = await rootBundle.load(packFilePath);
        bytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );
      }

      if (_packBinaryCache.length >= _maxPackBinaryCacheEntries) {
        _packBinaryCache.remove(_packBinaryCache.keys.first);
      }
      _packBinaryCache[packFilePath] = bytes;
      return bytes;
    }();

    _inflightPackLoads[packFilePath] = future;
    try {
      return await future;
    } finally {
      if (identical(_inflightPackLoads[packFilePath], future)) {
        _inflightPackLoads.remove(packFilePath);
      }
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
        if (!_matches(header, const [0x25, 0x50, 0x44, 0x46, 0x2D])) {
          return false;
        }

        final tailLength = length < 2048 ? length : 2048;
        await raf.setPosition(length - tailLength);
        final tail = await raf.read(tailLength);
        return _contains(tail, const [0x25, 0x25, 0x45, 0x4F, 0x46]);
      } finally {
        await raf.close();
      }
    } catch (_) {
      return false;
    }
  }

  static bool _matches(List<int> bytes, List<int> pattern) {
    if (bytes.length < pattern.length) return false;
    for (var i = 0; i < pattern.length; i++) {
      if (bytes[i] != pattern[i]) return false;
    }
    return true;
  }

  static bool _contains(List<int> bytes, List<int> pattern) {
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
}

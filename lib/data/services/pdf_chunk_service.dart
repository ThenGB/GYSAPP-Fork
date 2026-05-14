import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PdfChunkService {
  static const int headerSize = 32;
  static const int indexEntrySize = 40;

  /// Extract a specific chunk from a master chunk binary file and return the path to the decompressed PDF.
  Future<String?> getChunkFile({
    required String chunkFilePath,
    required int chunkIndex,
    required String cacheKey,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(
        tempDir.path,
        'pdf_chunks',
        '${cacheKey}_$chunkIndex.pdf',
      );
      final targetFile = File(targetPath);

      if (await targetFile.exists()) {
        if (await _isCompletePdf(targetFile)) {
          return targetPath;
        }
        await targetFile.delete().catchError((_) => targetFile);
      }

      await targetFile.parent.create(recursive: true);

      // Read the master chunk file from assets
      final byteData = await rootBundle.load(chunkFilePath);
      final bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );

      if (bytes.length < headerSize) return null;

      // Verify magic
      final magic = String.fromCharCodes(bytes.sublist(0, 4));
      if (magic != 'CHNK') return null;

      final chunkCount = ByteData.sublistView(
        bytes,
        8,
        12,
      ).getUint32(0, Endian.little);
      if (chunkIndex >= chunkCount) return null;

      // Read index entry
      final indexOffset = headerSize + (chunkIndex * indexEntrySize);
      final entryData = ByteData.sublistView(
        bytes,
        indexOffset,
        indexOffset + indexEntrySize,
      );

      // Removed unused: startPage, endPage, uncompressedSize
      final compressedSize = entryData.getUint32(12, Endian.little);
      final dataOffset = entryData.getUint32(20, Endian.little);

      // Extract and decompress
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
      log('PdfChunkService Error: $e');
      return null;
    }
  }

  static Future<bool> _isCompletePdf(File file) async {
    try {
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

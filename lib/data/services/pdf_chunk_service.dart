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
      final targetPath = p.join(tempDir.path, 'pdf_chunks', '${cacheKey}_$chunkIndex.pdf');
      final targetFile = File(targetPath);

      if (await targetFile.exists()) {
        return targetPath;
      }

      await targetFile.parent.create(recursive: true);

      // Read the master chunk file from assets
      final byteData = await rootBundle.load(chunkFilePath);
      final bytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

      if (bytes.length < headerSize) return null;

      // Verify magic
      final magic = String.fromCharCodes(bytes.sublist(0, 4));
      if (magic != 'CHNK') return null;

      final chunkCount = ByteData.sublistView(bytes, 8, 12).getUint32(0, Endian.little);
      if (chunkIndex >= chunkCount) return null;

      // Read index entry
      final indexOffset = headerSize + (chunkIndex * indexEntrySize);
      final entryData = ByteData.sublistView(bytes, indexOffset, indexOffset + indexEntrySize);
      
      // Removed unused: startPage, endPage, uncompressedSize
      final compressedSize = entryData.getUint32(12, Endian.little);
      final dataOffset = entryData.getUint32(20, Endian.little);

      // Extract and decompress
      final compressedData = bytes.sublist(dataOffset, dataOffset + compressedSize);
      final decompressedData = GZipDecoder().decodeBytes(compressedData);

      await targetFile.writeAsBytes(decompressedData);
      return targetPath;
    } catch (e) {
      log('PdfChunkService Error: $e');
      return null;
    }
  }
}

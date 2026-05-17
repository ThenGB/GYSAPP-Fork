import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:church/data/services/pdf_song_pack_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('church_pdf_song_pack_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          return switch (call.method) {
            'getTemporaryDirectory' => tempDir.path,
            'getApplicationSupportDirectory' => tempDir.path,
            'getApplicationDocumentsDirectory' => tempDir.path,
            _ => null,
          };
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('extracts a valid per-song PDF from SPK2 pack file', () async {
    final packPath = p.join(tempDir.path, 'kr_song_pack.bin');
    final pdfBytes = Uint8List.fromList(
      utf8.encode('%PDF-1.4\n1 0 obj\n<<>>\nendobj\n%%EOF\n'),
    );
    final compressed = GZipEncoder().encode(pdfBytes);

    final header = BytesBuilder()
      ..add(utf8.encode('SPK2'))
      ..add(_u32(1)) // version
      ..add(_u32(1)) // entry count
      ..add(_u32(32)) // index offset
      ..add(Uint8List(16)); // reserved

    final dataOffset = 32 + 40;
    final index = BytesBuilder()
      ..add(_u32(0)) // index
      ..add(_u32(1)) // start page
      ..add(_u32(1)) // end page
      ..add(_u32(compressed.length))
      ..add(_u32(pdfBytes.length))
      ..add(_u32(dataOffset))
      ..add(Uint8List(16)); // reserved

    final bytes = BytesBuilder()
      ..add(header.toBytes())
      ..add(index.toBytes())
      ..add(compressed);
    await File(packPath).writeAsBytes(bytes.toBytes(), flush: true);

    final extractedPath = await PdfSongPackService().getSongFile(
      packFilePath: packPath,
      songIndex: 0,
      cacheKey: 'KR_PACK',
    );

    expect(extractedPath, isNotNull);
    final extracted = File(extractedPath!);
    expect(await extracted.exists(), true);
    final head = await extracted.openRead(0, 5).first;
    expect(String.fromCharCodes(head), '%PDF-');
  });
}

Uint8List _u32(int value) {
  final data = ByteData(4)..setUint32(0, value, Endian.little);
  return data.buffer.asUint8List();
}

import 'dart:io';

import 'package:church/data/services/pdf_chunk_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('church_pdf_chunk_test_');
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

  test('repairs a corrupt cached chunk before returning it', () async {
    final cachedChunk = File(p.join(tempDir.path, 'pdf_chunks', 'KR_0.pdf'));
    await cachedChunk.parent.create(recursive: true);
    await cachedChunk.writeAsString('partial failed write');

    final chunkPath = await PdfChunkService().getChunkFile(
      chunkFilePath: 'assets/data/pdf/kr/kr_chunks.bin',
      chunkIndex: 0,
      cacheKey: 'KR',
    );

    expect(chunkPath, cachedChunk.path);
    final bytes = await cachedChunk.openRead(0, 5).first;
    expect(String.fromCharCodes(bytes), '%PDF-');
    expect(await cachedChunk.length(), greaterThan(1000));
  });

  test('stores extracted chunks in persistent app support cache', () async {
    final chunkPath = await PdfChunkService().getChunkFile(
      chunkFilePath: 'assets/data/pdf/kr/kr_chunks.bin',
      chunkIndex: 0,
      cacheKey: 'KR',
    );

    expect(chunkPath, p.join(tempDir.path, 'pdf_chunks', 'KR_0.pdf'));
  });
}

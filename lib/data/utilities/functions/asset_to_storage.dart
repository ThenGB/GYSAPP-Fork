import 'dart:io';

import 'package:flutter/services.dart';

Future<void> assetToStorage(
    {required String assetFilePath, required String localFilePath}) async {
  var file = File(localFilePath);
  if (!file.existsSync()) {
    ByteData fileData = await rootBundle.load(assetFilePath);
    final buffer = fileData.buffer;
    file.createSync(recursive: true);
    await file.writeAsBytes(
        buffer.asUint8List(fileData.offsetInBytes, fileData.lengthInBytes));
  }
}


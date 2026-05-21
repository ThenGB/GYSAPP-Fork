import 'dart:io';
import 'dart:typed_data';

import 'package:church/data/services/asset_distribution/encrypted_asset_package_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'church_encrypted_asset_package_',
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('installs encrypted package payload into destination file', () async {
    final service = EncryptedAssetPackageService();
    final packageFile = File('${tempDir.path}/b_kjv.gyspkg');
    final destinationFile = File('${tempDir.path}/installed/b_kjv.db');
    final expectedBytes = Uint8List.fromList(List.generate(32, (i) => i));

    await packageFile.writeAsBytes(
      service.buildPackageBytesForTesting(expectedBytes),
    );

    await service.installPackage(
      packageFile: packageFile,
      destinationFile: destinationFile,
    );

    expect(await destinationFile.exists(), isTrue);
    expect(await destinationFile.readAsBytes(), expectedBytes);
  });
}

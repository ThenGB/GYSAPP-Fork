import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android 12 splash branding resources are committed', () {
    final res = Directory('android/app/src/main/res');
    expect(res.existsSync(), isTrue);

    final brandingFiles = res
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('android12branding.png'))
        .toList();

    // flutter_native_splash creates density-specific light and dark branding
    // assets. If these new PNGs are ignored, values-v31 still references the
    // drawable and Android release linking fails late in the build.
    expect(brandingFiles.length, greaterThanOrEqualTo(5));
    expect(
      brandingFiles.any((file) => file.path.contains('drawable-night-')),
      isTrue,
    );
    expect(
      brandingFiles.any(
        (file) =>
            file.path.contains('drawable-') &&
            !file.path.contains('drawable-night-'),
      ),
      isTrue,
    );
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PDF range viewer disables pdfrx progressive loading', () {
    final source = File(
      'lib/presentations/song/widgets/song_pdf_viewer.dart',
    ).readAsStringSync();

    expect(
      'useProgressiveLoading: false'.allMatches(source).length,
      greaterThanOrEqualTo(2),
    );
  });

  test('PDF layout cache depends on the page set supplied by pdfrx', () {
    final source = File(
      'lib/presentations/song/widgets/song_pdf_viewer.dart',
    ).readAsStringSync();

    expect(source, contains('pageSignature'));
    expect(source, contains(r'#pages$pageSignature'));
  });
}

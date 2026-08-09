import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dashboard hydration never persists credentials or account PII', () {
    final source = File(
      'lib/presentations/dashboard/cubit/dashboard_cubit.dart',
    ).readAsStringSync();

    for (final key in ['idToken', 'account', 'ftpPassword', 'ftpUsername']) {
      expect(source, contains("..remove('$key')"), reason: key);
    }
    expect(source, contains('authTokenStore.write'));
    expect(source, contains('authTokenStore.read'));
    expect(source, contains('authTokenStore.clear'));
  });

  test('web authentication token storage is session scoped', () {
    final source = File(
      'lib/data/services/auth_token_store.dart',
    ).readAsStringSync();
    expect(source, contains('WebOptions(useSessionStorage: true)'));
  });

  test('Android production manifest disallows clear-text traffic', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('android:usesCleartextTraffic="false"'));
    expect(manifest, isNot(contains('android:usesCleartextTraffic="true"')));
  });

  test('translation bundles do not contain common UTF-8 mojibake markers', () {
    const markers = ['â€¦', 'â€”', 'â†', 'ðŸ', 'Ã', 'Â'];
    for (final file in Directory('assets/translations')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))) {
      final source = file.readAsStringSync();
      for (final marker in markers) {
        expect(source, isNot(contains(marker)), reason: '${file.path}: $marker');
      }
    }
  });
}

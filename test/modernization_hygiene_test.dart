import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Marionette runtime is fully removed from app and lockfile', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final lock = File('pubspec.lock').readAsStringSync();
    final libFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    expect(pubspec.toLowerCase(), isNot(contains('marionette')));
    expect(lock.toLowerCase(), isNot(contains('marionette')));
    for (final file in libFiles) {
      expect(
        file.readAsStringSync().toLowerCase(),
        isNot(contains('marionette')),
        reason: file.path,
      );
    }
  });

  test('translation loader avoids redundant connectivity preflight', () {
    final source = File(
      'lib/data/utilities/smart_network_asset_loader.dart',
    ).readAsStringSync();
    expect(source, isNot(contains('InternetConnectionChecker')));
  });

  test('song selector exposes both list and grid browse modes', () {
    final source = File(
      'lib/presentations/song/view/song_list_view.dart',
    ).readAsStringSync();
    expect(source, contains('SongSelectorViewMode.list'));
    expect(source, contains('SongSelectorViewMode.grid'));
  });

  test('home dashboard narrows rebuilds around changing state', () {
    final source = File(
      'lib/presentations/home/view/home_view.dart',
    ).readAsStringSync();

    expect(source, contains('class HomeHeader extends StatelessWidget'));
    expect(source, contains('previous.sauhs != current.sauhs'));
    expect(source, contains('previous.todayVerse != current.todayVerse'));
    expect(source, contains('previous.account != current.account'));
  });

  test('authentication diagnostics stay debug-only and avoid secret dumps', () {
    final login = File(
      'lib/presentations/auth/view/login_view.dart',
    ).readAsStringSync();
    final accountRepository = File(
      'lib/data/repository/account_repository_impl.dart',
    ).readAsStringSync();
    final dashboardCubit = File(
      'lib/presentations/dashboard/cubit/dashboard_cubit.dart',
    ).readAsStringSync();
    final injection = File('lib/di/injection.dart').readAsStringSync();

    expect(login, contains('void _authDebug(String message)'));
    expect(login, contains('kDebugMode'));
    expect(accountRepository, contains('if (kDebugMode) debugPrint'));
    expect(dashboardCubit, contains('if (kDebugMode) debugPrint'));

    // Credentials may legitimately exist as request fields, but no diagnostic
    // path may print token/cookie/header/body payload values.
    for (final forbidden in [
      'substring(0, token.length',
      'Profile API body preview',
      'Session cookies:',
      'idToken:',
      'response.body}',
      r'headers: ${',
      r'data: ${',
    ]) {
      expect(login, isNot(contains(forbidden)), reason: forbidden);
      expect(injection, isNot(contains(forbidden)), reason: forbidden);
    }
  });

  test('light and dark themes keep the same primary type scale', () {
    final light = File(
      'lib/components/themes/default_theme.dart',
    ).readAsStringSync();
    final dark = File('lib/components/themes/dark_theme.dart').readAsStringSync();

    for (final size in ['fs(38)', 'fs(32)', 'fs(27)', 'fs(23)', 'fs(17)']) {
      expect(light, contains(size));
      expect(dark, contains(size));
    }
    expect(
      dark,
      contains('shape: RoundedRectangleBorder(borderRadius: r(16))'),
    );
  });
}

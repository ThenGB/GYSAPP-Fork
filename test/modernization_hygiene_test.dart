import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Marionette runtime is fully removed from app and lockfile', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final lockfile = File('pubspec.lock').readAsStringSync();
    final mainSource = File('lib/main.dart').readAsStringSync();
    final appSource = File('lib/app.dart').readAsStringSync();

    expect(pubspec, isNot(contains('marionette_flutter')));
    expect(lockfile, isNot(contains('marionette_flutter')));
    expect(mainSource.toLowerCase(), isNot(contains('marionette')));
    expect(appSource.toLowerCase(), isNot(contains('marionette')));
  });

  test('translation loader avoids redundant connectivity preflight', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(pubspec, isNot(contains('connectivity_plus')));
    expect(mainSource, isNot(contains('Connectivity().checkConnectivity')));
    expect(mainSource, isNot(contains('InternetAddress.lookup')));
    expect(mainSource, contains('http.get'));
    expect(mainSource, contains('.timeout(timeout)'));
  });

  test('song selector exposes both list and grid browse modes', () {
    final source = File(
      'lib/presentations/song/view/song_list_view.dart',
    ).readAsStringSync();

    expect(source, contains('enum _SongBrowseLayout { list, grid }'));
    expect(source, contains("ValueKey('song-grid')"));
    expect(source, contains("ValueKey('song-list')"));
    expect(source, contains('GridView.builder'));
    expect(source, contains('ListView.separated'));
    expect(source, contains('SegmentedButton<_SongBrowseLayout>'));
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

  test('authentication diagnostics are debug-only and redacted', () {
    final login = File(
      'lib/presentations/auth/view/login_view.dart',
    ).readAsStringSync();
    final accountRepository = File(
      'lib/data/repository/account_repository_impl.dart',
    ).readAsStringSync();
    final dashboardCubit = File(
      'lib/presentations/dashboard/cubit/dashboard_cubit.dart',
    ).readAsStringSync();

    expect(login, contains('void _authDebug(String message)'));
    expect(login, contains('if (!kDebugMode) return;'));
    expect(login, contains('Sensitive authentication diagnostic redacted'));
    expect(accountRepository, contains('if (kDebugMode) debugPrint'));
    expect(dashboardCubit, contains('if (kDebugMode) debugPrint'));
    expect(dashboardCubit, isNot(contains('substring(0, token.length')));
  });

  test('light and dark themes keep the same primary type scale', () {
    final light = File('lib/components/themes/default_theme.dart')
        .readAsStringSync();
    final dark = File('lib/components/themes/dark_theme.dart')
        .readAsStringSync();

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

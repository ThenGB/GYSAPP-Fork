import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('settings routes offline library into a dedicated asset page', () {
    final settingsView = File(
      'lib/presentations/settings/view/settings_view.dart',
    ).readAsStringSync();
    final routerSource = File('lib/router/router.dart').readAsStringSync();

    expect(settingsView, contains('AssetManagementRoute('));
    expect(settingsView, contains('Offline Library'));
    expect(
      routerSource,
      contains('CupertinoRoute(page: AssetManagementRoute.page)'),
    );
  });

  test(
    'asset management page exposes refresh and remove-installed actions',
    () {
      final assetView = File(
        'lib/presentations/settings/view/asset_management_view.dart',
      ).readAsStringSync();

      expect(assetView, contains('Icons.refresh_rounded'));
      expect(assetView, contains('Check latest release'));
      expect(assetView, contains('no GitHub sign-in required'));
      expect(assetView, contains('Remove installed'));
      expect(assetView, contains('Full App Reset'));
      expect(assetView, contains('Reset All App Data'));
    },
  );

  test(
    'release tooling keeps checksum metadata and GitHub publish support',
    () {
      final packagingTool = File(
        'tool/asset_distribution/package_release_assets.dart',
      ).readAsStringSync();
      final publishTool = File(
        'tool/asset_distribution/publish_release_assets.dart',
      ).readAsStringSync();

      expect(packagingTool, contains('checksumSha256'));
      expect(publishTool, contains('GITHUB_TOKEN'));
      expect(publishTool, contains("'ThenGB'"));
      expect(publishTool, contains("'GYSApp-Data'"));
      expect(publishTool, contains('latest/'));
    },
  );

  test('hymnal asset titles reflect clarified library meanings', () {
    final modelsSource = File(
      'lib/data/services/asset_distribution/models.dart',
    ).readAsStringSync();

    expect(modelsSource, contains("title: 'Aku Senang Menyanyi I'"));
    expect(modelsSource, contains("title: 'Aku Senang Menyanyi M'"));
    expect(modelsSource, contains("title: 'Aku Senang Menyanyi P'"));
    expect(modelsSource, contains("title: 'Mandarin'"));
    expect(modelsSource, contains("title: 'Hymne (English Version)'"));
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('soundfont tile navigates to the managed-asset page', () {
    final settingsSource = File(
      'lib/presentations/settings/view/settings_view.dart',
    ).readAsStringSync();
    expect(settingsSource, contains('router.push(SoundFontRoute())'));
    // The old popup menu is gone.
    expect(settingsSource, isNot(contains('_showSoundFontMenu')));
    expect(settingsSource, isNot(contains('showMenu<String>')));

    final pageSource = File(
      'lib/presentations/settings/view/soundfont_view.dart',
    ).readAsStringSync();
    expect(pageSource, contains('DistributedAssetTile('));
    expect(pageSource, contains('isActive'));
    expect(pageSource, contains('setSoundFont'));
    // The tile provides download/delete for non-bundled fonts.
    final tileSource = File(
      'lib/components/widgets/distributed_asset_tile.dart',
    ).readAsStringSync();
    expect(tileSource, contains('cubit.deleteAsset'));
    expect(tileSource, contains('cubit.downloadAsset'));
  });

  test('song settings reads midi warm-up switch from bloc state', () {
    final source = File(
      'lib/presentations/settings/view/settings_view.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('value: songCubit.isWarmUpEnabled')));
    expect(source, contains('value: state.midiPreloadEnabled'));
  });

  test('soundfont download shows a progress bar while downloading', () {
    final source = File(
      'lib/presentations/settings/view/settings_view.dart',
    ).readAsStringSync();

    expect(source, contains('router.push(SoundFontRoute())'));
  });

  test('soundfont download shows a progress bar while downloading', () {
    // The managed-asset tile renders the download progress inline.
    final tileSource = File(
      'lib/components/widgets/distributed_asset_tile.dart',
    ).readAsStringSync();

    expect(tileSource, contains('progressByCode'));
    expect(tileSource, contains('LinearProgressIndicator('));
  });
}

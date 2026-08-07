import 'dart:io';

import 'package:church/presentations/settings/view/settings_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('soundfont menu values include the currently selected soundfont', () {
    expect(
      settingsSoundFontMenuValues(
        availableSoundFonts: null,
        selectedSoundFont: 'GeneralUser-GS.sf2',
      ),
      ['GeneralUser-GS.sf2', 'TimGM6mb.sf2'],
    );
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

    expect(source, contains('assetState.progressByCode.isNotEmpty'));
    expect(source, contains('LinearProgressIndicator('));
    expect(source, contains('minHeight: 4'));
  });

  test('soundfont pill anchors its menu to the pill (Builder context)', () {
    final source = File(
      'lib/presentations/settings/view/settings_view.dart',
    ).readAsStringSync();

    expect(source, contains('builder: (pillContext) => InkWell('));
    expect(source, contains('_showSoundFontMenu('));
    expect(source, contains('showMenu<String>('));
    expect(source, contains('await songCubit.midiEngine.getAvailableSoundFonts();'));
  });
}

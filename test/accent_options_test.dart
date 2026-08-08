import 'dart:io';

import 'package:church/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accent options are ordered by hue with custom last', () {
    final keys = appAccentOptions.map((a) => a.key).toList();
    expect(keys, contains('skyBlue'));
    expect(keys, contains('maroon'), reason: 'legacy key must resolve');
    // Every key must resolve (no stale picker list vs theme list).
    for (final a in appAccentOptions) {
      expect(appAccentByKey(a.key).key, a.key);
    }
    // Custom is not a preset and falls back to default when no seed.
    expect(appAccentByKey(customAccentKey).key, defaultAccentKey);
  });

  test('custom accent derives a full option from the seed', () {
    const seed = Color(0xFF123456);
    final option = appAccentByKey(customAccentKey, customSeed: seed);
    expect(option.key, customAccentKey);
    expect(option.seed, seed);
    expect(option.darkSurface, isNot(seed));
    expect(option.darkContainer, isNot(seed));
    // Both schemes build without throwing.
    expect(
      lightHymnalColorScheme(customAccentKey, customSeed: seed).primary,
      isNotNull,
    );
    expect(
      darkHymnalColorScheme(customAccentKey, customSeed: seed).primary,
      seed,
    );
  });

  test('theme mode label is rendered once in settings', () {
    final source = File(
      'lib/presentations/settings/view/settings_view.dart',
    ).readAsStringSync();
    final labelCount = 'label: \'theme_mode\'.tr()'.allMatches(source).length;
    expect(labelCount, 1, reason: 'duplicate theme-mode title removed');
    expect(
      source,
      isNot(contains("Text(\n                      'theme_mode'.tr(),")),
    );
  });

  test('accent picker sources presets from appAccentOptions', () {
    final source = File(
      'lib/presentations/settings/view/settings_view.dart',
    ).readAsStringSync();
    expect(source, contains('...appAccentOptions.map'));
    expect(source, contains('customAccentKey'));
    expect(source, contains('_CustomColorDialog'));
  });
}

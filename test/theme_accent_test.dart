import 'package:church/components/themes/app_accent.dart';
import 'package:church/components/themes/default_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default accent is maroon and multiple accent choices exist', () {
    expect(defaultAccentKey, 'maroon');
    expect(appAccentOptions.length, greaterThanOrEqualTo(12));
    expect(appAccentByKey(defaultAccentKey).seed, const Color(0xFF570013));
  });

  test('theme uses selected accent for primary and background tint', () {
    final maroonTheme = defaultTheme('Roboto', accentKey: 'maroon');
    final blueTheme = defaultTheme('Roboto', accentKey: 'darkBlue');

    expect(maroonTheme.colorScheme.primary, const Color(0xFF570013));
    expect(blueTheme.colorScheme.primary, const Color(0xFF002D73));
    expect(
      maroonTheme.colorScheme.surface,
      isNot(blueTheme.colorScheme.surface),
    );
    expect(
      maroonTheme.colorScheme.surfaceContainerLow,
      isNot(blueTheme.colorScheme.surfaceContainerLow),
    );
  });

  test('theme follows stitch typography pairing', () {
    final theme = defaultTheme('Roboto');

    expect(theme.textTheme.headlineLarge?.fontFamily, 'EB Garamond');
    expect(theme.textTheme.headlineMedium?.fontFamily, 'EB Garamond');
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Manrope');
    expect(theme.textTheme.labelSmall?.fontFamily, 'Manrope');
  });
}

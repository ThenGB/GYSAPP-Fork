import 'package:church/components/themes/app_accent.dart';
import 'package:church/components/themes/default_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default accent is skyBlue and multiple accent choices exist', () {
    expect(defaultAccentKey, 'skyBlue');
    expect(appAccentOptions.length, greaterThanOrEqualTo(12));
    expect(appAccentByKey(defaultAccentKey).seed, const Color(0xFF3B82F6));
  });

  test('theme uses selected accent for primary and background tint', () {
    final skyBlueTheme = defaultTheme('Roboto', accentKey: 'skyBlue');
    final mintGreenTheme = defaultTheme('Roboto', accentKey: 'mintGreen');

    // Verify themes use different accent colors
    expect(
      skyBlueTheme.colorScheme.primary.toARGB32(),
      isNot(mintGreenTheme.colorScheme.primary.toARGB32()),
    );
    // Verify surface container colors are different (indicating accent changes affect theme)
    expect(
      skyBlueTheme.colorScheme.surfaceContainerHighest.toARGB32(),
      isNot(mintGreenTheme.colorScheme.surfaceContainerHighest.toARGB32()),
    );
    expect(
      skyBlueTheme.colorScheme.primaryContainer.toARGB32(),
      isNot(mintGreenTheme.colorScheme.primaryContainer.toARGB32()),
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

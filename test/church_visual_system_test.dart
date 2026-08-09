import 'package:church/components/themes/app_accent.dart';
import 'package:church/components/themes/church_theme.dart';
import 'package:church/components/themes/default_theme.dart';
import 'package:church/data/models/theme_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GYS church visual system', () {
    test('keeps GYS blue as the default brand accent', () {
      expect(defaultAccentKey, 'skyBlue');
      final accent = appAccentByKey(defaultAccentKey);
      expect(accent.label, 'GYS Blue');
      expect(accent.seed, const Color(0xFF3B82F6));
    });

    test('surface tone changes the app surface without changing accent', () {
      ThemeData themeFor(SurfaceTone tone) {
        final preferences = ThemePreferences(surfaceTone: tone);
        return applyChurchVisualSystem(
          defaultTheme('Roboto', accentKey: defaultAccentKey),
          preferences: preferences,
        );
      }

      final light = themeFor(SurfaceTone.light);
      final soft = themeFor(SurfaceTone.medium);
      final deep = themeFor(SurfaceTone.dark);

      expect(light.colorScheme.primary, soft.colorScheme.primary);
      expect(soft.colorScheme.primary, deep.colorScheme.primary);
      expect(
        light.scaffoldBackgroundColor.toARGB32(),
        isNot(soft.scaffoldBackgroundColor.toARGB32()),
      );
      expect(
        soft.scaffoldBackgroundColor.toARGB32(),
        isNot(deep.scaffoldBackgroundColor.toARGB32()),
      );
    });

    test('uses restrained chrome and editorial church typography', () {
      final theme = applyChurchVisualSystem(
        defaultTheme('Roboto'),
        preferences: const ThemePreferences(),
      );

      expect(theme.useMaterial3, isTrue);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.appBarTheme.scrolledUnderElevation, 0);
      expect(theme.textTheme.headlineLarge?.fontFamily, 'EB Garamond');
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Manrope');
      expect(theme.progressIndicatorTheme.linearMinHeight, 4);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:church/data/models/theme_preferences.dart';

void main() {
  group('ThemePreferences', () {
    test('has correct default values', () {
      const prefs = ThemePreferences();
      expect(prefs.accentKey, 'skyBlue');
      expect(prefs.surfaceTone, SurfaceTone.light);
      expect(prefs.cornerRadius, CornerRadiusStyle.soft);
      expect(prefs.density, DisplayDensity.standard);
      expect(prefs.typographyScale, TypographyScale.normal);
      expect(prefs.compactMode, false);
    });

    test('can copy with new values', () {
      const prefs = ThemePreferences();
      final updated = prefs.copyWith(
        accentKey: 'mintGreen',
        density: DisplayDensity.compact,
      );
      expect(updated.accentKey, 'mintGreen');
      expect(updated.density, DisplayDensity.compact);
      // Original values preserved
      expect(updated.surfaceTone, SurfaceTone.light);
    });
  });
}
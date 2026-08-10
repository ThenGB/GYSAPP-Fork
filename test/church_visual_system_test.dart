import 'package:church/components/themes/app_accent.dart';
import 'package:church/components/themes/app_theme_extras.dart';
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

    ThemeData themeFor(ThemePreferences preferences) {
      return applyChurchVisualSystem(
        defaultTheme(
          'Roboto',
          accentKey: defaultAccentKey,
          density: preferences.density,
          cornerRadius: preferences.cornerRadius,
          typographyScale: preferences.typographyScale,
        ),
        preferences: preferences,
      );
    }

    test('surface tone changes scaffold and component surface families', () {
      final light = themeFor(
        const ThemePreferences(surfaceTone: SurfaceTone.light),
      );
      final medium = themeFor(
        const ThemePreferences(surfaceTone: SurfaceTone.medium),
      );
      final dark = themeFor(
        const ThemePreferences(surfaceTone: SurfaceTone.dark),
      );

      expect(light.colorScheme.primary, medium.colorScheme.primary);
      expect(medium.colorScheme.primary, dark.colorScheme.primary);
      expect(
        light.scaffoldBackgroundColor.toARGB32(),
        isNot(medium.scaffoldBackgroundColor.toARGB32()),
      );
      expect(
        medium.scaffoldBackgroundColor.toARGB32(),
        isNot(dark.scaffoldBackgroundColor.toARGB32()),
      );
      expect(
        light.colorScheme.surfaceContainerLow.toARGB32(),
        isNot(medium.colorScheme.surfaceContainerLow.toARGB32()),
      );
      expect(
        medium.colorScheme.surfaceContainerHigh.toARGB32(),
        isNot(dark.colorScheme.surfaceContainerHigh.toARGB32()),
      );
    });

    test('density changes global geometry and selector control size', () {
      final compact = themeFor(
        const ThemePreferences(density: DisplayDensity.compact),
      );
      final comfortable = themeFor(
        const ThemePreferences(density: DisplayDensity.comfortable),
      );

      final compactExtras = compact.extension<AppThemeExtras>()!;
      final comfortableExtras = comfortable.extension<AppThemeExtras>()!;
      expect(compactExtras.densityFactor, lessThan(0.9));
      expect(comfortableExtras.densityFactor, greaterThan(1.1));
      expect(compact.visualDensity.vertical, lessThan(0));
      expect(comfortable.visualDensity.vertical, greaterThan(0));

      final compactMinimum = compact.segmentedButtonTheme.style?.minimumSize
          ?.resolve(<WidgetState>{});
      final comfortableMinimum = comfortable
          .segmentedButtonTheme
          .style
          ?.minimumSize
          ?.resolve(<WidgetState>{});
      expect(compactMinimum, isNotNull);
      expect(comfortableMinimum, isNotNull);
      expect(
        comfortableMinimum!.height,
        greaterThan(compactMinimum!.height),
      );
    });

    test('typography scale visibly changes common UI text styles', () {
      final compact = themeFor(
        const ThemePreferences(typographyScale: TypographyScale.compact),
      );
      final comfortable = themeFor(
        const ThemePreferences(
          typographyScale: TypographyScale.comfortable,
        ),
      );

      expect(
        comfortable.textTheme.titleMedium!.fontSize!,
        greaterThan(compact.textTheme.titleMedium!.fontSize!),
      );
      expect(
        comfortable.textTheme.bodyMedium!.fontSize!,
        greaterThan(compact.textTheme.bodyMedium!.fontSize!),
      );
      expect(
        comfortable.textTheme.labelLarge!.fontSize!,
        greaterThan(compact.textTheme.labelLarge!.fontSize!),
      );
    });

    test('corner radius affects cards and appearance selectors', () {
      final soft = themeFor(
        const ThemePreferences(cornerRadius: CornerRadiusStyle.soft),
      );
      final sharp = themeFor(
        const ThemePreferences(cornerRadius: CornerRadiusStyle.sharp),
      );

      final softCard = soft.cardTheme.shape! as RoundedRectangleBorder;
      final sharpCard = sharp.cardTheme.shape! as RoundedRectangleBorder;
      final softRadius = (softCard.borderRadius as BorderRadius).topLeft.x;
      final sharpRadius = (sharpCard.borderRadius as BorderRadius).topLeft.x;
      expect(softRadius, greaterThan(sharpRadius));

      final softSegmentShape = soft.segmentedButtonTheme.style?.shape
          ?.resolve(<WidgetState>{}) as RoundedRectangleBorder?;
      final sharpSegmentShape = sharp.segmentedButtonTheme.style?.shape
          ?.resolve(<WidgetState>{}) as RoundedRectangleBorder?;
      expect(softSegmentShape, isNotNull);
      expect(sharpSegmentShape, isNotNull);
      expect(
        (softSegmentShape!.borderRadius as BorderRadius).topLeft.x,
        greaterThan(
          (sharpSegmentShape!.borderRadius as BorderRadius).topLeft.x,
        ),
      );
    });

    test('uses restrained chrome and editorial church typography', () {
      final theme = themeFor(const ThemePreferences());

      expect(theme.useMaterial3, isTrue);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.appBarTheme.scrolledUnderElevation, 0);
      expect(theme.textTheme.headlineLarge?.fontFamily, 'EB Garamond');
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Manrope');
      expect(theme.progressIndicatorTheme.linearMinHeight, 4);
    });
  });
}

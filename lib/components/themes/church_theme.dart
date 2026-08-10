import 'package:flutter/material.dart';

import '../../data/models/theme_preferences.dart';
import 'app_theme_extras.dart';

/// Applies the app's church-focused visual language on top of the base light
/// or dark theme. Appearance preferences are intentionally applied at the
/// ThemeData level so custom views, selectors and stock Material controls all
/// react to the same surface, density, radius and typography choices.
ThemeData applyChurchVisualSystem(
  ThemeData base, {
  required ThemePreferences preferences,
}) {
  final baseColors = base.colorScheme;
  final baseExtras =
      base.extension<AppThemeExtras>() ??
      const AppThemeExtras(
        radiusScale: 1,
        typographyScale: 1,
        densityFactor: 1,
      );

  // The old ranges (0.92↔1.08 for density and 0.90↔1.10 for type) were
  // technically different but visually too subtle. Keep the middle value
  // unchanged while giving the two ends a clear, still-accessible identity.
  final radiusScale = switch (preferences.cornerRadius) {
    CornerRadiusStyle.soft => 1.15,
    CornerRadiusStyle.medium => 0.62,
    CornerRadiusStyle.sharp => 0.16,
  };
  final typographyScale = switch (preferences.typographyScale) {
    TypographyScale.compact => 0.86,
    TypographyScale.normal => 1.0,
    TypographyScale.comfortable => 1.16,
  };
  final densityFactor = switch (preferences.density) {
    DisplayDensity.compact => 0.84,
    DisplayDensity.standard => 1.0,
    DisplayDensity.comfortable => 1.18,
  };
  final visualDensity = switch (preferences.density) {
    DisplayDensity.compact => const VisualDensity(horizontal: -2, vertical: -2),
    DisplayDensity.standard => VisualDensity.standard,
    // Flutter's built-in VisualDensity.comfortable is actually denser than
    // standard. Positive values are used here because this app's
    // "comfortable" option means more breathing room.
    DisplayDensity.comfortable => const VisualDensity(horizontal: 1, vertical: 1),
  };

  final extras = AppThemeExtras(
    radiusScale: radiusScale,
    typographyScale: typographyScale,
    densityFactor: densityFactor,
  );

  BorderRadius radius(double value) => BorderRadius.circular(
    (value * extras.radiusScale).clamp(2.0, 36.0).toDouble(),
  );
  double radiusValue(double value) =>
      (value * extras.radiusScale).clamp(2.0, 36.0).toDouble();

  final colors = _surfaceColorScheme(
    baseColors,
    base.brightness,
    preferences.surfaceTone,
  );
  final sanctuarySurface = colors.surface;
  final quietSurface = colors.surfaceContainerLow;
  final elevatedQuietSurface = colors.surfaceContainerHigh;
  final borderColor = colors.outlineVariant.withValues(
    alpha: base.brightness == Brightness.dark ? 0.48 : 0.62,
  );
  final primaryBorder = colors.primary.withValues(
    alpha: base.brightness == Brightness.dark ? 0.46 : 0.34,
  );

  // Base themes already scale the most-used editorial styles. Convert that
  // existing scale to the stronger global scale here, then explicitly scale
  // the Material styles that the base theme leaves at their stock size.
  final typeRatio = typographyScale / baseExtras.typographyScale;
  final scaledTextTheme = base.textTheme
      .apply(fontSizeFactor: typeRatio)
      .copyWith(
        displayLarge: base.textTheme.displayLarge?.copyWith(
          fontSize: (base.textTheme.displayLarge?.fontSize ?? 57) * typographyScale,
        ),
        displayMedium: base.textTheme.displayMedium?.copyWith(
          fontSize: (base.textTheme.displayMedium?.fontSize ?? 45) * typographyScale,
        ),
        displaySmall: base.textTheme.displaySmall?.copyWith(
          fontSize: (base.textTheme.displaySmall?.fontSize ?? 36) * typographyScale,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          fontSize: (base.textTheme.titleSmall?.fontSize ?? 14) * typographyScale,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          fontSize: (base.textTheme.bodySmall?.fontSize ?? 12) * typographyScale,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontSize: (base.textTheme.labelLarge?.fontSize ?? 14) * typographyScale,
        ),
        labelMedium: base.textTheme.labelMedium?.copyWith(
          fontSize: (base.textTheme.labelMedium?.fontSize ?? 12) * typographyScale,
        ),
      );
  final primaryTextTheme = base.primaryTextTheme.apply(
    fontSizeFactor: typographyScale,
  );
  final appBarTitleStyle = base.appBarTheme.titleTextStyle?.copyWith(
    fontSize:
        (base.appBarTheme.titleTextStyle?.fontSize ?? 20) * typeRatio,
  );

  final controlShape = RoundedRectangleBorder(borderRadius: radius(14));
  final inputShape = OutlineInputBorder(
    borderRadius: radius(15),
    borderSide: BorderSide(color: borderColor),
  );

  return base.copyWith(
    colorScheme: colors,
    textTheme: scaledTextTheme,
    primaryTextTheme: primaryTextTheme,
    visualDensity: visualDensity,
    extensions: [
      ...base.extensions.values.where((extension) => extension is! AppThemeExtras),
      extras,
    ],
    scaffoldBackgroundColor: sanctuarySurface,
    canvasColor: sanctuarySurface,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      toolbarHeight: 64 * densityFactor,
      titleSpacing: 8 * densityFactor,
      backgroundColor: sanctuarySurface.withValues(alpha: 0.98),
      foregroundColor: colors.onSurface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: colors.onSurface),
      actionsIconTheme: IconThemeData(color: colors.onSurface),
      systemOverlayStyle: base.appBarTheme.systemOverlayStyle,
      titleTextStyle: appBarTitleStyle,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: sanctuarySurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      endShape: const RoundedRectangleBorder(),
      scrimColor: Colors.black.withValues(alpha: 0.28),
    ),
    cardTheme: CardThemeData(
      color: quietSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius(18),
        side: BorderSide(color: borderColor, width: 0.8),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: borderColor.withValues(alpha: 0.65),
      thickness: 0.8,
      space: 1 * densityFactor,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colors.primary,
      textColor: colors.onSurface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16 * densityFactor,
        vertical: 3 * densityFactor,
      ),
      shape: RoundedRectangleBorder(borderRadius: radius(14)),
      minVerticalPadding: 4 * densityFactor,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        disabledBackgroundColor: colors.onSurface.withValues(alpha: 0.08),
        disabledForegroundColor: colors.onSurface.withValues(alpha: 0.36),
        minimumSize: Size(44 * densityFactor, 44 * densityFactor),
        padding: EdgeInsets.symmetric(
          horizontal: 18 * densityFactor,
          vertical: 11 * densityFactor,
        ),
        shape: controlShape,
        textStyle: scaledTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        foregroundColor: colors.primary,
        side: BorderSide(color: primaryBorder),
        minimumSize: Size(44 * densityFactor, 44 * densityFactor),
        padding: EdgeInsets.symmetric(
          horizontal: 17 * densityFactor,
          vertical: 10 * densityFactor,
        ),
        shape: controlShape,
        textStyle: scaledTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        minimumSize: Size(40 * densityFactor, 40 * densityFactor),
        padding: EdgeInsets.symmetric(
          horizontal: 12 * densityFactor,
          vertical: 9 * densityFactor,
        ),
        shape: RoundedRectangleBorder(borderRadius: radius(12)),
        textStyle: scaledTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: colors.onSurfaceVariant,
        highlightColor: colors.primary.withValues(alpha: 0.10),
        hoverColor: colors.primary.withValues(alpha: 0.07),
        focusColor: colors.primary.withValues(alpha: 0.10),
        minimumSize: Size(40 * densityFactor, 40 * densityFactor),
        padding: EdgeInsets.all(8 * densityFactor),
        shape: RoundedRectangleBorder(borderRadius: radius(13)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: quietSurface,
      selectedColor: colors.primaryContainer.withValues(alpha: 0.78),
      disabledColor: colors.onSurface.withValues(alpha: 0.05),
      side: BorderSide(color: borderColor.withValues(alpha: 0.75)),
      shape: RoundedRectangleBorder(borderRadius: radius(999)),
      padding: EdgeInsets.symmetric(
        horizontal: 4 * densityFactor,
        vertical: 2 * densityFactor,
      ),
      labelPadding: EdgeInsets.symmetric(horizontal: 6 * densityFactor),
      labelStyle: scaledTextTheme.labelMedium,
      checkmarkColor: colors.onPrimaryContainer,
      iconTheme: IconThemeData(
        color: colors.primary,
        size: 18 * typographyScale,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        foregroundColor: colors.onSurfaceVariant,
        backgroundColor: colors.surfaceContainerLow,
        selectedForegroundColor: colors.onPrimaryContainer,
        selectedBackgroundColor: colors.primaryContainer,
        overlayColor: colors.primary.withValues(alpha: 0.10),
        textStyle: scaledTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12 * densityFactor,
          vertical: 10 * densityFactor,
        ),
        minimumSize: Size(40 * densityFactor, 44 * densityFactor),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: radius(14)),
        visualDensity: visualDensity,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: elevatedQuietSurface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 15 * densityFactor,
        vertical: 13 * densityFactor,
      ),
      border: inputShape,
      enabledBorder: inputShape,
      disabledBorder: inputShape.copyWith(
        borderSide: BorderSide(color: borderColor.withValues(alpha: 0.45)),
      ),
      focusedBorder: inputShape.copyWith(
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      errorBorder: inputShape.copyWith(
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: inputShape.copyWith(
        borderSide: BorderSide(color: colors.error, width: 1.5),
      ),
      prefixIconColor: colors.primary,
      suffixIconColor: colors.onSurfaceVariant,
      hintStyle: scaledTextTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant.withValues(alpha: 0.68),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.onSurface.withValues(alpha: 0.24);
        }
        if (states.contains(WidgetState.selected)) return colors.onPrimary;
        return colors.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.onSurface.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.selected)) return colors.primary;
        return colors.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colors.primary;
        return borderColor;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: radius(5)),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colors.primary;
        return Colors.transparent;
      }),
      checkColor: WidgetStatePropertyAll(colors.onPrimary),
      side: BorderSide(color: borderColor, width: 1.2),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colors.primary;
        return colors.onSurfaceVariant;
      }),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 66 * densityFactor,
      backgroundColor: sanctuarySurface.withValues(alpha: 0.98),
      surfaceTintColor: Colors.transparent,
      indicatorColor: colors.primaryContainer.withValues(alpha: 0.72),
      indicatorShape: RoundedRectangleBorder(borderRadius: radius(16)),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: (selected ? 23 : 21) * typographyScale,
          color: selected ? colors.primary : colors.onSurfaceVariant,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return scaledTextTheme.labelSmall?.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected ? colors.primary : colors.onSurfaceVariant,
        );
      }),
    ),
    bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
      backgroundColor: quietSurface.withValues(alpha: 0.98),
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.onSurfaceVariant,
      selectedLabelStyle: scaledTextTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: scaledTextTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: sanctuarySurface,
      modalBackgroundColor: sanctuarySurface,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Colors.black.withValues(alpha: 0.28),
      showDragHandle: true,
      dragHandleColor: colors.outlineVariant,
      dragHandleSize: Size(36 * densityFactor, 4 * densityFactor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(radiusValue(24)),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: sanctuarySurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: radius(22),
        side: BorderSide(color: borderColor),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: colors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: radius(16),
        side: BorderSide(color: borderColor.withValues(alpha: 0.75)),
      ),
      textStyle: scaledTextTheme.bodyMedium,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colors.primary,
      linearTrackColor: colors.surfaceContainerHighest,
      circularTrackColor: colors.surfaceContainerHighest,
      linearMinHeight: 4 * densityFactor,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 1,
      highlightElevation: 0,
      backgroundColor: colors.primaryContainer,
      foregroundColor: colors.onPrimaryContainer,
      shape: RoundedRectangleBorder(borderRadius: radius(18)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colors.inverseSurface,
      contentTextStyle: scaledTextTheme.bodyMedium?.copyWith(
        color: colors.onInverseSurface,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: radius(14)),
    ),
  );
}

ColorScheme _surfaceColorScheme(
  ColorScheme colors,
  Brightness brightness,
  SurfaceTone tone,
) {
  Color tune(Color source) => _surfaceForTone(
    source,
    colors.primary,
    brightness,
    tone,
  );

  return colors.copyWith(
    surface: tune(colors.surface),
    surfaceDim: tune(colors.surfaceDim),
    surfaceBright: tune(colors.surfaceBright),
    surfaceContainerLowest: tune(colors.surfaceContainerLowest),
    surfaceContainerLow: tune(colors.surfaceContainerLow),
    surfaceContainer: tune(colors.surfaceContainer),
    surfaceContainerHigh: tune(colors.surfaceContainerHigh),
    surfaceContainerHighest: tune(colors.surfaceContainerHighest),
  );
}

Color _surfaceForTone(
  Color base,
  Color accent,
  Brightness brightness,
  SurfaceTone tone,
) {
  if (brightness == Brightness.dark) {
    return switch (tone) {
      SurfaceTone.light => Color.alphaBlend(
        Colors.white.withValues(alpha: 0.055),
        base,
      ),
      SurfaceTone.medium => base,
      SurfaceTone.dark => Color.alphaBlend(
        Colors.black.withValues(alpha: 0.13),
        base,
      ),
    };
  }

  return switch (tone) {
    SurfaceTone.light => base,
    SurfaceTone.medium => Color.alphaBlend(
      accent.withValues(alpha: 0.055),
      base,
    ),
    SurfaceTone.dark => Color.alphaBlend(
      Colors.black.withValues(alpha: 0.08),
      base,
    ),
  };
}

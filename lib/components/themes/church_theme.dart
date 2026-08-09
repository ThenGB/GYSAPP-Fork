import 'package:flutter/material.dart';

import '../../data/models/theme_preferences.dart';
import 'app_theme_extras.dart';

/// Applies the app's church-focused visual language on top of the base light
/// or dark theme. The base theme still owns typography, accent generation and
/// platform behavior; this layer keeps surfaces, navigation and interaction
/// chrome calm and consistent across every feature.
ThemeData applyChurchVisualSystem(
  ThemeData base, {
  required ThemePreferences preferences,
}) {
  final colors = base.colorScheme;
  final extras =
      base.extension<AppThemeExtras>() ??
      const AppThemeExtras(
        radiusScale: 1,
        typographyScale: 1,
        densityFactor: 1,
      );

  BorderRadius radius(double value) =>
      BorderRadius.circular((value * extras.radiusScale).clamp(4.0, 32.0));

  final sanctuarySurface = _surfaceForTone(
    colors.surface,
    colors.primary,
    base.brightness,
    preferences.surfaceTone,
  );
  final quietSurface = Color.alphaBlend(
    colors.primary.withValues(
      alpha: base.brightness == Brightness.dark ? 0.045 : 0.028,
    ),
    sanctuarySurface,
  );
  final elevatedQuietSurface = Color.alphaBlend(
    colors.primary.withValues(
      alpha: base.brightness == Brightness.dark ? 0.065 : 0.045,
    ),
    colors.surfaceContainerLow,
  );
  final borderColor = colors.outlineVariant.withValues(
    alpha: base.brightness == Brightness.dark ? 0.42 : 0.58,
  );
  final primaryBorder = colors.primary.withValues(
    alpha: base.brightness == Brightness.dark ? 0.42 : 0.30,
  );

  final controlShape = RoundedRectangleBorder(borderRadius: radius(14));
  final inputShape = OutlineInputBorder(
    borderRadius: radius(15),
    borderSide: BorderSide(color: borderColor),
  );

  return base.copyWith(
    scaffoldBackgroundColor: sanctuarySurface,
    canvasColor: sanctuarySurface,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      toolbarHeight: 64,
      titleSpacing: 8,
      backgroundColor: sanctuarySurface.withValues(alpha: 0.98),
      foregroundColor: colors.onSurface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: colors.onSurface),
      actionsIconTheme: IconThemeData(color: colors.onSurface),
      systemOverlayStyle: base.appBarTheme.systemOverlayStyle,
      titleTextStyle: base.appBarTheme.titleTextStyle,
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
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colors.primary,
      textColor: colors.onSurface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16 * extras.densityFactor,
        vertical: 3 * extras.densityFactor,
      ),
      shape: RoundedRectangleBorder(borderRadius: radius(14)),
      minVerticalPadding: 4,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        disabledBackgroundColor: colors.onSurface.withValues(alpha: 0.08),
        disabledForegroundColor: colors.onSurface.withValues(alpha: 0.36),
        minimumSize: Size(44, 44 * extras.densityFactor),
        padding: EdgeInsets.symmetric(
          horizontal: 18 * extras.densityFactor,
          vertical: 11 * extras.densityFactor,
        ),
        shape: controlShape,
        textStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        foregroundColor: colors.primary,
        side: BorderSide(color: primaryBorder),
        minimumSize: Size(44, 44 * extras.densityFactor),
        padding: EdgeInsets.symmetric(
          horizontal: 17 * extras.densityFactor,
          vertical: 10 * extras.densityFactor,
        ),
        shape: controlShape,
        textStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        minimumSize: Size(40, 40 * extras.densityFactor),
        padding: EdgeInsets.symmetric(
          horizontal: 12 * extras.densityFactor,
          vertical: 9 * extras.densityFactor,
        ),
        shape: RoundedRectangleBorder(borderRadius: radius(12)),
        textStyle: base.textTheme.labelLarge?.copyWith(
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
        shape: RoundedRectangleBorder(borderRadius: radius(13)),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: quietSurface,
      selectedColor: colors.primaryContainer.withValues(alpha: 0.78),
      disabledColor: colors.onSurface.withValues(alpha: 0.05),
      side: BorderSide(color: borderColor.withValues(alpha: 0.75)),
      shape: RoundedRectangleBorder(borderRadius: radius(999)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      checkmarkColor: colors.onPrimaryContainer,
      iconTheme: IconThemeData(color: colors.primary, size: 18),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: elevatedQuietSurface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 15 * extras.densityFactor,
        vertical: 13 * extras.densityFactor,
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
      hintStyle: base.textTheme.bodyMedium?.copyWith(
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
      height: 66 * extras.densityFactor,
      backgroundColor: sanctuarySurface.withValues(alpha: 0.98),
      surfaceTintColor: Colors.transparent,
      indicatorColor: colors.primaryContainer.withValues(alpha: 0.72),
      indicatorShape: RoundedRectangleBorder(borderRadius: radius(16)),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: selected ? 23 : 21,
          color: selected ? colors.primary : colors.onSurfaceVariant,
        );
      }),
      labelTextStyle: base.navigationBarTheme.labelTextStyle,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: sanctuarySurface,
      modalBackgroundColor: sanctuarySurface,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Colors.black.withValues(alpha: 0.28),
      showDragHandle: true,
      dragHandleColor: colors.outlineVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24 * extras.radiusScale),
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
      color: sanctuarySurface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: radius(16),
        side: BorderSide(color: borderColor.withValues(alpha: 0.75)),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colors.primary,
      linearTrackColor: colors.surfaceContainerHighest,
      circularTrackColor: colors.surfaceContainerHighest,
      linearMinHeight: 4,
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
      contentTextStyle: base.snackBarTheme.contentTextStyle,
      shape: RoundedRectangleBorder(borderRadius: radius(14)),
    ),
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
        Colors.white.withValues(alpha: 0.025),
        base,
      ),
      SurfaceTone.medium => base,
      SurfaceTone.dark => Color.alphaBlend(
        Colors.black.withValues(alpha: 0.09),
        base,
      ),
    };
  }

  return switch (tone) {
    SurfaceTone.light => base,
    SurfaceTone.medium => Color.alphaBlend(
      accent.withValues(alpha: 0.026),
      base,
    ),
    SurfaceTone.dark => Color.alphaBlend(
      Colors.black.withValues(alpha: 0.035),
      base,
    ),
  };
}

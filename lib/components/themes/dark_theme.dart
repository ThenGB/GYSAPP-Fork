import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_accent.dart';

const _hymnalHeadingFont = 'EB Garamond';
const _hymnalUiFont = 'Manrope';

ThemeData darkTheme(String defaultFont, {String accentKey = defaultAccentKey}) {
  var colorScheme = darkHymnalColorScheme(accentKey);
  return ThemeData(
    fontFamily: defaultFont,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      toolbarHeight: 64,
      titleSpacing: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.primary,
      iconTheme: IconThemeData(color: colorScheme.primary),
      actionsIconTheme: IconThemeData(color: colorScheme.primary),
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      shadowColor: colorScheme.primary.withValues(alpha: 0.12),
      shape: Border(
        bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      titleTextStyle: TextStyle(
        fontFamily: _hymnalHeadingFont,
        fontWeight: FontWeight.w600,
        fontSize: 22,
        height: 1.27,
        color: colorScheme.primary,
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: _hymnalUiFont,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.7)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => colorScheme.primaryContainer,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => colorScheme.onPrimaryContainer,
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        textStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontFamily: _hymnalUiFont,
            fontWeight: FontWeight.bold,
          );
        }),
      ),
    ),
    buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(colorScheme.primary),
        textStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontFamily: _hymnalUiFont,
            fontWeight: FontWeight.bold,
          );
        }),
      ),
    ),
    textTheme: Typography.whiteHelsinki
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.primary,
          decorationColor: colorScheme.onSurface,
          fontFamily: _hymnalUiFont,
        )
        .copyWith(
          headlineLarge: TextStyle(
            fontFamily: _hymnalHeadingFont,
            fontWeight: FontWeight.w600,
            fontSize: 34,
            height: 1.24,
            color: colorScheme.primary,
          ),
          headlineMedium: TextStyle(
            fontFamily: _hymnalHeadingFont,
            fontWeight: FontWeight.w500,
            fontSize: 28,
            height: 1.28,
            color: colorScheme.primary,
          ),
          headlineSmall: TextStyle(
            fontFamily: _hymnalHeadingFont,
            fontWeight: FontWeight.w500,
            fontSize: 22,
            height: 1.28,
            color: colorScheme.primary,
          ),
          titleLarge: TextStyle(
            fontFamily: _hymnalHeadingFont,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            height: 1.28,
            color: colorScheme.primary,
          ),
          titleMedium: TextStyle(
            fontFamily: _hymnalUiFont,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            height: 1.5,
            color: colorScheme.onSurface,
          ),
          bodyLarge: TextStyle(
            fontFamily: _hymnalUiFont,
            fontWeight: FontWeight.w400,
            fontSize: 18,
            height: 1.55,
            color: colorScheme.onSurface,
          ),
          bodyMedium: TextStyle(
            fontFamily: _hymnalUiFont,
            fontWeight: FontWeight.w400,
            fontSize: 16,
            height: 1.5,
            color: colorScheme.onSurface,
          ),
          labelSmall: TextStyle(
            fontFamily: _hymnalUiFont,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            height: 1.34,
            letterSpacing: 1.2,
            color: colorScheme.onSurface.withValues(alpha: 0.72),
          ),
        ),
    primaryTextTheme: Typography.whiteHelsinki.apply(
      bodyColor: colorScheme.primary,
      displayColor: colorScheme.primary,
      decorationColor: colorScheme.primary,
      fontFamily: defaultFont,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      fillColor: colorScheme.surfaceContainerLow,
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 14),
      labelStyle: TextStyle(
        fontFamily: _hymnalHeadingFont,
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: colorScheme.primary,
      ),
      floatingLabelStyle: TextStyle(
        fontFamily: _hymnalHeadingFont,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: colorScheme.primary,
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colorScheme.primary,
      textColor: colorScheme.onSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh.withValues(alpha: 0.94),
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontFamily: _hymnalUiFont,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: _hymnalUiFont,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant.withValues(alpha: 0.55),
      thickness: 1,
      space: 0,
    ),
    iconTheme: IconThemeData(color: colorScheme.primary),
    useMaterial3: true,
    sliderTheme: SliderThemeData(
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.24),
      thumbColor: colorScheme.primary,
      trackHeight: 4,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    colorScheme: colorScheme,
    dividerColor: colorScheme.outlineVariant,
    brightness: Brightness.dark,
    visualDensity: VisualDensity.standard,
  );
}

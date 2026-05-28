import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_accent.dart';

const _hymnalHeadingFont = 'EB Garamond';
const _hymnalUiFont = 'Manrope';

ThemeData darkTheme(String defaultFont, {String accentKey = defaultAccentKey}) {
  final colorScheme = darkHymnalColorScheme(accentKey);

  return ThemeData(
    useMaterial3: true,
    fontFamily: defaultFont,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    visualDensity: VisualDensity.standard,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _HymnalPageTransitionsBuilder(),
        TargetPlatform.iOS: _HymnalPageTransitionsBuilder(),
        TargetPlatform.macOS: _HymnalPageTransitionsBuilder(),
        TargetPlatform.windows: _HymnalPageTransitionsBuilder(),
        TargetPlatform.linux: _HymnalPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      toolbarHeight: 56,
      titleSpacing: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: _hymnalHeadingFont,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
    ),
    textTheme: Typography.whiteHelsinki
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
          decorationColor: colorScheme.onSurface,
          fontFamily: _hymnalUiFont,
        )
        .copyWith(
          headlineLarge: TextStyle(
            fontFamily: _hymnalHeadingFont,
            fontWeight: FontWeight.w700,
            fontSize: 32,
            height: 1.12,
            color: colorScheme.onSurface,
          ),
          headlineMedium: TextStyle(
            fontFamily: _hymnalHeadingFont,
            fontWeight: FontWeight.w700,
            fontSize: 28,
            height: 1.16,
            color: colorScheme.onSurface,
          ),
          headlineSmall: TextStyle(
            fontFamily: _hymnalHeadingFont,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            height: 1.2,
            color: colorScheme.onSurface,
          ),
          titleLarge: TextStyle(
            fontFamily: _hymnalHeadingFont,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.22,
            color: colorScheme.onSurface,
          ),
          titleMedium: TextStyle(
            fontFamily: _hymnalUiFont,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            height: 1.34,
            color: colorScheme.onSurface,
          ),
          bodyLarge: TextStyle(
            fontFamily: _hymnalUiFont,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            height: 1.5,
            color: colorScheme.onSurface,
          ),
          bodyMedium: TextStyle(
            fontFamily: _hymnalUiFont,
            fontWeight: FontWeight.w500,
            fontSize: 14,
            height: 1.5,
            color: colorScheme.onSurface,
          ),
          labelSmall: TextStyle(
            fontFamily: _hymnalUiFont,
            fontWeight: FontWeight.w700,
            fontSize: 11,
            height: 1.3,
            letterSpacing: 1.0,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
    primaryTextTheme: Typography.whiteHelsinki.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
      decorationColor: colorScheme.onSurface,
      fontFamily: defaultFont,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: _hymnalUiFont,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outlineVariant),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onSurface,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: const TextStyle(
          fontFamily: _hymnalUiFont,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      labelStyle: TextStyle(
        fontFamily: _hymnalUiFont,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurfaceVariant,
      ),
      floatingLabelStyle: TextStyle(
        fontFamily: _hymnalUiFont,
        fontWeight: FontWeight.w700,
        color: colorScheme.primary,
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colorScheme.primary,
      textColor: colorScheme.onSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      minVerticalPadding: 4,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all(const Size.square(42)),
        minimumSize: WidgetStateProperty.all(const Size.square(42)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.28);
          }
          return colorScheme.onSurface;
        }),
        overlayColor: WidgetStateProperty.all(
          colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      indicatorColor: colorScheme.primary.withValues(alpha: 0.2),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: selected ? 22 : 20,
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: _hymnalUiFont,
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        );
      }),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainerLow.withValues(alpha: 0.95),
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontFamily: _hymnalUiFont,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: _hymnalUiFont,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: colorScheme.surface,
      modalBarrierColor: Colors.black.withValues(alpha: 0.2),
      showDragHandle: true,
      dragHandleColor: colorScheme.outlineVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: TextStyle(
        fontFamily: _hymnalUiFont,
        color: colorScheme.onInverseSurface,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      selectedColor: colorScheme.primaryContainer.withValues(alpha: 0.4),
      side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: TextStyle(
        fontFamily: _hymnalUiFont,
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: colorScheme.onSurface,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.4),
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      labelStyle: const TextStyle(
        fontFamily: _hymnalUiFont,
        fontWeight: FontWeight.w800,
      ),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: colorScheme.primary, width: 2.2),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant.withValues(alpha: 0.45),
      thickness: 1,
      space: 0,
    ),
    iconTheme: IconThemeData(color: colorScheme.primary),
    sliderTheme: SliderThemeData(
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.24),
      thumbColor: colorScheme.primary,
      trackHeight: 5,
    ),
  );
}

class _HymnalPageTransitionsBuilder extends PageTransitionsBuilder {
  const _HymnalPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.02, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData darkTheme(String defaultFont) {
  var colorScheme = ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 4, 25, 59),
  );
  return ThemeData(
    fontFamily: defaultFont,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStateProperty.resolveWith(
          (states) {
            return TextStyle(
              fontFamily: defaultFont,
              fontWeight: FontWeight.bold,
            );
          },
        ),
      ),
    ),
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStateProperty.resolveWith(
          (states) {
            return TextStyle(
              fontFamily: defaultFont,
              fontWeight: FontWeight.bold,
            );
          },
        ),
      ),
    ),
    textTheme: Typography.whiteHelsinki.apply(
      fontFamily: defaultFont,
    ),
    primaryTextTheme: Typography.whiteHelsinki.apply(
        bodyColor: const Color(0xffffffff),
        displayColor: const Color(0xffffffff),
        decorationColor: const Color(0xffffffff),
        fontFamily: defaultFont),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.blueGrey.shade900.withAlpha(010),
    colorScheme: colorScheme,
    dividerColor: Colors.blueGrey.shade900,
    brightness: Brightness.dark,
    visualDensity: VisualDensity.compact,
  );
}


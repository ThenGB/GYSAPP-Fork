import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData defaultTheme(String defaultFont) {
  var colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xff002D73),
  );
  return ThemeData(
    fontFamily: defaultFont,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.grey.shade800,
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
    textTheme: Typography.blackHelsinki.apply(
      bodyColor: Color(0xff333333),
      displayColor: Color(0xff666666),
      decorationColor: Color(0xff333333),
      fontFamily: defaultFont,
    ),
    primaryTextTheme: Typography.blackHelsinki.apply(
      bodyColor: const Color(0xff002D73),
      displayColor: const Color(0xff002D73),
      decorationColor: const Color(0xff002D73),
      fontFamily: defaultFont,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.grey.shade100,
    colorScheme: colorScheme,
    dividerColor: Colors.grey.shade100,
    brightness: Brightness.light,
    visualDensity: VisualDensity.compact,
  );
}


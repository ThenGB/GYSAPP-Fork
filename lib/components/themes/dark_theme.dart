import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkTheme() {
  return ThemeData.dark(useMaterial3: true).copyWith(
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.white,
      ),
    ),
    textTheme: GoogleFonts.robotoTextTheme().apply(
      bodyColor: const Color(0xffffffff),
      displayColor: const Color(0xffffffff),
      decorationColor: const Color(0xffffffff),
    ),
    primaryTextTheme: GoogleFonts.robotoTextTheme().apply(
      bodyColor: const Color(0xffffffff),
      displayColor: const Color(0xffffffff),
      decorationColor: const Color(0xffffffff),
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.blueGrey.shade900.withAlpha(24),
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: const Color.fromARGB(255, 4, 25, 59),
    ),
    dividerColor: Colors.blueGrey.shade900,
    brightness: Brightness.dark,
    visualDensity: VisualDensity.compact,
  );
}

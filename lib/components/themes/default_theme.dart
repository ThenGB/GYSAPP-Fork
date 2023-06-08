import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData defaultTheme() {
  var colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xff002D73),
  );
  return ThemeData(
    fontFamily: GoogleFonts.roboto().fontFamily,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.grey.shade800,
      ),
    ),
    textTheme: GoogleFonts.robotoTextTheme(),
    primaryTextTheme: GoogleFonts.robotoTextTheme().apply(
      bodyColor: const Color(0xff002D73),
      displayColor: const Color(0xff002D73),
      decorationColor: const Color(0xff002D73),
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.grey.shade100,
    colorScheme: colorScheme,
    dividerColor: Colors.grey.shade100,
    brightness: Brightness.light,
    visualDensity: VisualDensity.compact,
  );
}

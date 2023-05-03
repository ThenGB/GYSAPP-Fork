import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData defaultTheme() {
  return ThemeData(
    textTheme: GoogleFonts.robotoTextTheme(),
    primaryTextTheme: GoogleFonts.robotoTextTheme().apply(
      bodyColor: const Color(0xff002D73),
      displayColor: const Color(0xff002D73),
      decorationColor: const Color(0xff002D73),
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.grey.shade100,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff002D73),
    ),
    dividerColor: Colors.grey.shade100,
    brightness: Brightness.light,
    visualDensity: VisualDensity.compact,
  );
}

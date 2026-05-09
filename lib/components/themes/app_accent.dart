import 'package:flutter/material.dart';

const defaultAccentKey = 'maroon';

Color _tint(Color base, Color accent, double alpha) {
  return Color.alphaBlend(accent.withValues(alpha: alpha), base);
}

class AppAccentOption {
  final String key;
  final String label;
  final Color seed;
  final Color container;
  final Color fixed;

  const AppAccentOption({
    required this.key,
    required this.label,
    required this.seed,
    required this.container,
    required this.fixed,
  });
}

const appAccentOptions = [
  AppAccentOption(
    key: defaultAccentKey,
    label: 'Maroon',
    seed: Color(0xFF570013),
    container: Color(0xFF800020),
    fixed: Color(0xFFFFDADA),
  ),
  AppAccentOption(
    key: 'darkBlue',
    label: 'Biru Tua',
    seed: Color(0xFF002D73),
    container: Color(0xFF0B3D91),
    fixed: Color(0xFFDCE8FF),
  ),
  AppAccentOption(
    key: 'emerald',
    label: 'Emerald',
    seed: Color(0xFF0F5D50),
    container: Color(0xFF167565),
    fixed: Color(0xFFD8F4ED),
  ),
  AppAccentOption(
    key: 'indigo',
    label: 'Indigo',
    seed: Color(0xFF3730A3),
    container: Color(0xFF4F46E5),
    fixed: Color(0xFFE3E1FF),
  ),
  AppAccentOption(
    key: 'purple',
    label: 'Ungu',
    seed: Color(0xFF6D28D9),
    container: Color(0xFF7E3AF2),
    fixed: Color(0xFFF0E6FF),
  ),
  AppAccentOption(
    key: 'rose',
    label: 'Rose',
    seed: Color(0xFFBE123C),
    container: Color(0xFFE11D48),
    fixed: Color(0xFFFFE1E8),
  ),
  AppAccentOption(
    key: 'charcoal',
    label: 'Charcoal',
    seed: Color(0xFF272821),
    container: Color(0xFF3D3E36),
    fixed: Color(0xFFE4E3D7),
  ),
  AppAccentOption(
    key: 'crimson',
    label: 'Crimson',
    seed: Color(0xFF9F1239),
    container: Color(0xFFBE123C),
    fixed: Color(0xFFFFD9E2),
  ),
  AppAccentOption(
    key: 'teal',
    label: 'Teal',
    seed: Color(0xFF0F766E),
    container: Color(0xFF0D9488),
    fixed: Color(0xFFD1FAF5),
  ),
  AppAccentOption(
    key: 'forest',
    label: 'Forest',
    seed: Color(0xFF166534),
    container: Color(0xFF15803D),
    fixed: Color(0xFFDCFCE7),
  ),
  AppAccentOption(
    key: 'copper',
    label: 'Copper',
    seed: Color(0xFF9A3412),
    container: Color(0xFFC2410C),
    fixed: Color(0xFFFFEDD5),
  ),
  AppAccentOption(
    key: 'slate',
    label: 'Slate',
    seed: Color(0xFF334155),
    container: Color(0xFF475569),
    fixed: Color(0xFFE2E8F0),
  ),
  AppAccentOption(
    key: 'plum',
    label: 'Plum',
    seed: Color(0xFF6B21A8),
    container: Color(0xFF7E22CE),
    fixed: Color(0xFFF3E8FF),
  ),
];

AppAccentOption appAccentByKey(String? key) {
  return appAccentOptions.firstWhere(
    (accent) => accent.key == key,
    orElse: () => appAccentOptions.first,
  );
}

ColorScheme lightHymnalColorScheme(String? accentKey) {
  final accent = appAccentByKey(accentKey);
  if (accent.key == defaultAccentKey) {
    return const ColorScheme.light(
      brightness: Brightness.light,
      primary: Color(0xFF570013),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF800020),
      onPrimaryContainer: Color(0xFFFFDADA),
      secondary: Color(0xFF735C00),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFED65B),
      onSecondaryContainer: Color(0xFF745C00),
      tertiary: Color(0xFF272821),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFF3D3E36),
      onTertiaryContainer: Color(0xFFA9A99E),
      surface: Color(0xFFFFF8F7),
      onSurface: Color(0xFF251819),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFFFF0F0),
      surfaceContainer: Color(0xFFFFE9E8),
      surfaceContainerHigh: Color(0xFFFBE2E2),
      surfaceContainerHighest: Color(0xFFF5DDDD),
      outline: Color(0xFF8C7071),
      outlineVariant: Color(0xFFE0BFBF),
      primaryFixed: Color(0xFFFFDADA),
      onPrimaryFixed: Color(0xFF40000B),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
    );
  }
  final neutralBase = const Color(0xFFFAFAFC);
  final surface = _tint(neutralBase, accent.fixed, 0.08);
  final surfaceLowest = _tint(Colors.white, accent.fixed, 0.04);
  final surfaceLow = _tint(neutralBase, accent.fixed, 0.06);
  final surfaceContainer = _tint(const Color(0xFFF4F6FA), accent.fixed, 0.08);
  final surfaceHigh = _tint(const Color(0xFFEEF2F8), accent.fixed, 0.1);
  final surfaceHighest = _tint(const Color(0xFFE8EDF6), accent.fixed, 0.12);
  return ColorScheme.light(
    brightness: Brightness.light,
    primary: accent.seed,
    onPrimary: Colors.white,
    primaryContainer: accent.container,
    onPrimaryContainer: Colors.white,
    secondary: accent.container,
    onSecondary: Colors.white,
    secondaryContainer: accent.fixed,
    onSecondaryContainer: accent.seed,
    tertiary: _tint(const Color(0xFF60708A), accent.seed, 0.08),
    onTertiary: Colors.white,
    surface: surface,
    onSurface: const Color(0xFF1F2430),
    surfaceContainerLowest: surfaceLowest,
    surfaceContainerLow: surfaceLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceHigh,
    surfaceContainerHighest: surfaceHighest,
    primaryFixed: accent.fixed,
    onPrimaryFixed: accent.seed,
    outline: _tint(const Color(0xFF64748B), accent.seed, 0.22),
    outlineVariant: _tint(const Color(0xFFC7D0DF), accent.seed, 0.2),
    error: const Color(0xFFBA1A1A),
    onError: Colors.white,
  );
}

ColorScheme darkHymnalColorScheme(String? accentKey) {
  final accent = appAccentByKey(accentKey);
  if (accent.key == defaultAccentKey) {
    return const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: Color(0xFFFFB3B5),
      onPrimary: Color(0xFF570013),
      primaryContainer: Color(0xFF8E0F28),
      onPrimaryContainer: Color(0xFFFFDADA),
      secondary: Color(0xFFE9C349),
      onSecondary: Color(0xFF2F2200),
      secondaryContainer: Color(0xFF574500),
      onSecondaryContainer: Color(0xFFFFE088),
      tertiary: Color(0xFFC7C7BC),
      onTertiary: Color(0xFF272821),
      tertiaryContainer: Color(0xFF46473F),
      onTertiaryContainer: Color(0xFFE4E3D7),
      surface: Color(0xFF1F1617),
      onSurface: Color(0xFFFFEDEC),
      surfaceContainerLowest: Color(0xFF170F10),
      surfaceContainerLow: Color(0xFF241A1B),
      surfaceContainer: Color(0xFF2D2122),
      surfaceContainerHigh: Color(0xFF352728),
      surfaceContainerHighest: Color(0xFF3E2E2F),
      outline: Color(0xFF9E8081),
      outlineVariant: Color(0xFF5F4849),
      primaryFixed: Color(0xFFFFDADA),
      onPrimaryFixed: Color(0xFF40000B),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
    );
  }
  final neutralBase = const Color(0xFF101522);
  final surface = _tint(neutralBase, accent.seed, 0.12);
  final surfaceLowest = _tint(const Color(0xFF0C101A), accent.seed, 0.08);
  final surfaceLow = _tint(const Color(0xFF151B29), accent.seed, 0.1);
  final surfaceContainer = _tint(const Color(0xFF1A2233), accent.seed, 0.12);
  final surfaceHigh = _tint(const Color(0xFF202A3E), accent.seed, 0.14);
  final surfaceHighest = _tint(const Color(0xFF27324A), accent.seed, 0.16);
  return ColorScheme.dark(
    brightness: Brightness.dark,
    primary: accent.fixed,
    onPrimary: accent.seed,
    primaryContainer: accent.seed,
    onPrimaryContainer: Colors.white,
    secondary: accent.fixed,
    onSecondary: accent.seed,
    secondaryContainer: accent.container,
    onSecondaryContainer: accent.fixed,
    tertiary: _tint(const Color(0xFFB9C2D3), accent.fixed, 0.08),
    onTertiary: const Color(0xFF101522),
    surface: surface,
    onSurface: const Color(0xFFF4F7FF),
    surfaceContainerLowest: surfaceLowest,
    surfaceContainerLow: surfaceLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceHigh,
    surfaceContainerHighest: surfaceHighest,
    primaryFixed: accent.fixed,
    onPrimaryFixed: accent.seed,
    outline: _tint(const Color(0xFF8EA0BE), accent.fixed, 0.18),
    outlineVariant: _tint(const Color(0xFF495B7A), accent.fixed, 0.2),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
  );
}

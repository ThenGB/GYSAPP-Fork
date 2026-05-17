import 'package:flutter/material.dart';

const defaultAccentKey = 'darkBlue';
const maroonAccentKey = 'maroon';

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
    key: maroonAccentKey,
    label: 'Maroon',
    seed: Color(0xFF7B2E1E),
    container: Color(0xFF99513B),
    fixed: Color(0xFFF7E2D7),
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
  if (accent.key == maroonAccentKey) {
    return const ColorScheme.light(
      brightness: Brightness.light,
      primary: Color(0xFF7A2D3A),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFF7DFE5),
      onPrimaryContainer: Color(0xFF2A0F16),
      secondary: Color(0xFF3B536A),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFDCE8F4),
      onSecondaryContainer: Color(0xFF12273B),
      tertiary: Color(0xFF7A5B2C),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFF2E4CB),
      onTertiaryContainer: Color(0xFF2E2008),
      surface: Color(0xFFF4F5F8),
      onSurface: Color(0xFF1D2028),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF2F4F9),
      surfaceContainer: Color(0xFFEBEEF5),
      surfaceContainerHigh: Color(0xFFE3E8F0),
      surfaceContainerHighest: Color(0xFFDDE3EC),
      outline: Color(0xFF717988),
      outlineVariant: Color(0xFFC4CBD8),
      primaryFixed: Color(0xFFF7DFE5),
      onPrimaryFixed: Color(0xFF2A0F16),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
    );
  }
  final neutralBase = const Color(0xFFF3F5FA);
  final surface = _tint(neutralBase, accent.fixed, 0.08);
  final surfaceLowest = _tint(Colors.white, accent.fixed, 0.03);
  final surfaceLow = _tint(neutralBase, accent.fixed, 0.06);
  final surfaceContainer = _tint(const Color(0xFFEAF0F8), accent.fixed, 0.1);
  final surfaceHigh = _tint(const Color(0xFFE3EBF6), accent.fixed, 0.12);
  final surfaceHighest = _tint(const Color(0xFFDCE6F3), accent.fixed, 0.14);
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
    tertiary: _tint(const Color(0xFF5A6C86), accent.seed, 0.1),
    onTertiary: Colors.white,
    surface: surface,
    onSurface: const Color(0xFF1E2331),
    surfaceContainerLowest: surfaceLowest,
    surfaceContainerLow: surfaceLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceHigh,
    surfaceContainerHighest: surfaceHighest,
    primaryFixed: accent.fixed,
    onPrimaryFixed: accent.seed,
    outline: _tint(const Color(0xFF687A95), accent.seed, 0.24),
    outlineVariant: _tint(const Color(0xFFC2CCDE), accent.seed, 0.2),
    error: const Color(0xFFBA1A1A),
    onError: Colors.white,
  );
}

ColorScheme darkHymnalColorScheme(String? accentKey) {
  final accent = appAccentByKey(accentKey);
  if (accent.key == maroonAccentKey) {
    return const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: Color(0xFFF2C5D0),
      onPrimary: Color(0xFF3C121C),
      primaryContainer: Color(0xFF7A2D3A),
      onPrimaryContainer: Color(0xFFFFD9E1),
      secondary: Color(0xFFC3D7EA),
      onSecondary: Color(0xFF1C3248),
      secondaryContainer: Color(0xFF3B536A),
      onSecondaryContainer: Color(0xFFDCE8F4),
      tertiary: Color(0xFFE8D0A7),
      onTertiary: Color(0xFF3C2A0D),
      tertiaryContainer: Color(0xFF7A5B2C),
      onTertiaryContainer: Color(0xFFF2E4CB),
      surface: Color(0xFF12141B),
      onSurface: Color(0xFFF0F3FA),
      surfaceContainerLowest: Color(0xFF0D1017),
      surfaceContainerLow: Color(0xFF171C27),
      surfaceContainer: Color(0xFF1E2431),
      surfaceContainerHigh: Color(0xFF252C3C),
      surfaceContainerHighest: Color(0xFF2D3648),
      outline: Color(0xFF9BA7BA),
      outlineVariant: Color(0xFF3E4B63),
      primaryFixed: Color(0xFFF7DFE5),
      onPrimaryFixed: Color(0xFF2A0F16),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
    );
  }
  final neutralBase = const Color(0xFF111521);
  final surface = _tint(neutralBase, accent.seed, 0.12);
  final surfaceLowest = _tint(const Color(0xFF090D16), accent.seed, 0.08);
  final surfaceLow = _tint(const Color(0xFF131B2A), accent.seed, 0.1);
  final surfaceContainer = _tint(const Color(0xFF192233), accent.seed, 0.12);
  final surfaceHigh = _tint(const Color(0xFF202B3F), accent.seed, 0.14);
  final surfaceHighest = _tint(const Color(0xFF28344A), accent.seed, 0.16);
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
    tertiary: _tint(const Color(0xFFC0CADB), accent.fixed, 0.08),
    onTertiary: const Color(0xFF0E1522),
    surface: surface,
    onSurface: const Color(0xFFF2F5FD),
    surfaceContainerLowest: surfaceLowest,
    surfaceContainerLow: surfaceLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceHigh,
    surfaceContainerHighest: surfaceHighest,
    primaryFixed: accent.fixed,
    onPrimaryFixed: accent.seed,
    outline: _tint(const Color(0xFF91A6C7), accent.fixed, 0.18),
    outlineVariant: _tint(const Color(0xFF4A5E82), accent.fixed, 0.2),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
  );
}

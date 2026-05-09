import 'package:flutter/material.dart';

const defaultAccentKey = 'maroon';
const _cream = Color(0xFFFFF8F7);

Color _mix(Color base, Color tint, double alpha) {
  return Color.alphaBlend(tint.withValues(alpha: alpha), base);
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
  final surface = _mix(_cream, accent.fixed, 0.22);
  final surfaceLowest = _mix(Colors.white, accent.fixed, 0.1);
  final surfaceLow = _mix(const Color(0xFFFFF0F0), accent.fixed, 0.16);
  final surfaceContainer = _mix(const Color(0xFFFFE9E8), accent.fixed, 0.2);
  final surfaceHigh = _mix(const Color(0xFFFBE2E2), accent.fixed, 0.22);
  final surfaceHighest = _mix(const Color(0xFFF5DDDD), accent.fixed, 0.24);
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
    tertiary: const Color(0xFF3D3E36),
    onTertiary: Colors.white,
    surface: surface,
    onSurface: const Color(0xFF251819),
    surfaceContainerLowest: surfaceLowest,
    surfaceContainerLow: surfaceLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceHigh,
    surfaceContainerHighest: surfaceHighest,
    primaryFixed: accent.fixed,
    onPrimaryFixed: accent.seed,
    outline: const Color(0xFF8C7071),
    outlineVariant: const Color(0xFFE0BFBF),
    error: const Color(0xFFBA1A1A),
    onError: Colors.white,
  );
}

ColorScheme darkHymnalColorScheme(String? accentKey) {
  final accent = appAccentByKey(accentKey);
  final surface = _mix(const Color(0xFF1C1414), accent.seed, 0.24);
  final surfaceLowest = _mix(const Color(0xFF130D0D), accent.seed, 0.14);
  final surfaceLow = _mix(const Color(0xFF251819), accent.seed, 0.2);
  final surfaceContainer = _mix(const Color(0xFF302222), accent.seed, 0.24);
  final surfaceHigh = _mix(const Color(0xFF3B2D2D), accent.seed, 0.28);
  final surfaceHighest = _mix(const Color(0xFF463637), accent.seed, 0.3);
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
    tertiary: const Color(0xFFC7C7BC),
    onTertiary: const Color(0xFF1B1C15),
    surface: surface,
    onSurface: const Color(0xFFFFEDEC),
    surfaceContainerLowest: surfaceLowest,
    surfaceContainerLow: surfaceLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceHigh,
    surfaceContainerHighest: surfaceHighest,
    primaryFixed: accent.fixed,
    onPrimaryFixed: accent.seed,
    outline: const Color(0xFFCFAEAE),
    outlineVariant: const Color(0xFF584141),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
  );
}

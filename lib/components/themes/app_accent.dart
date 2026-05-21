import 'package:flutter/material.dart';

const defaultAccentKey = 'skyBlue';
const maroonAccentKey = 'maroon';



class AppAccentOption {
  final String key;
  final String label;
  final Color seed;
  final Color container;
  final Color fixed;
  final Color surface;

  const AppAccentOption({
    required this.key,
    required this.label,
    required this.seed,
    required this.container,
    required this.fixed,
    this.surface = Colors.transparent,
  });
}

const appAccentOptions = [
  AppAccentOption(
    key: 'skyBlue',
    label: 'Sky Blue',
    seed: Color(0xFF3B82F6),
    container: Color(0xFFDBEAFE),
    fixed: Color(0xFFF8FAFC),
  ),
  AppAccentOption(
    key: 'mintGreen',
    label: 'Mint Green',
    seed: Color(0xFF10B981),
    container: Color(0xFFD1FAF5),
    fixed: Color(0xFFF0FDF4),
  ),
  AppAccentOption(
    key: 'softLavender',
    label: 'Lavender',
    seed: Color(0xFF8B5CF6),
    container: Color(0xFFF3E8FF),
    fixed: Color(0xFFFAF5FF),
  ),
  AppAccentOption(
    key: 'warmPeach',
    label: 'Peach',
    seed: Color(0xFFF97316),
    container: Color(0xFFFFEDD5),
    fixed: Color(0xFFFFFBF5),
  ),
  AppAccentOption(
    key: 'dustyRose',
    label: 'Rose',
    seed: Color(0xFFF43F5E),
    container: Color(0xFFFFE4E6),
    fixed: Color(0xFFFFF1F2),
  ),
  AppAccentOption(
    key: 'softTeal',
    label: 'Teal',
    seed: Color(0xFF14B8A6),
    container: Color(0xFFCCFBF1),
    fixed: Color(0xFFF0FDFA),
  ),
  AppAccentOption(
    key: 'softIndigo',
    label: 'Indigo',
    seed: Color(0xFF6366F1),
    container: Color(0xFFE0E7FF),
    fixed: Color(0xFFEEF2FF),
  ),
  AppAccentOption(
    key: 'softAmber',
    label: 'Amber',
    seed: Color(0xFFF59E0B),
    container: Color(0xFFFEF3C7),
    fixed: Color(0xFFFFFBEB),
  ),
  AppAccentOption(
    key: 'softCyan',
    label: 'Cyan',
    seed: Color(0xFF06B6D4),
    container: Color(0xFFCFFAFE),
    fixed: Color(0xFFECFEFF),
  ),
  AppAccentOption(
    key: 'softViolet',
    label: 'Violet',
    seed: Color(0xFF7C3AED),
    container: Color(0xFFEDE9FE),
    fixed: Color(0xFFF5F3FF),
  ),
  AppAccentOption(
    key: 'softPink',
    label: 'Pink',
    seed: Color(0xFFEC4899),
    container: Color(0xFFFCE7F3),
    fixed: Color(0xFFFDF2F8),
  ),
  AppAccentOption(
    key: 'softGray',
    label: 'Gray',
    seed: Color(0xFF6B7280),
    container: Color(0xFFF3F4F6),
    fixed: Color(0xFFFAFAFA),
  ),
  // Keep legacy maroon option for backward compatibility
  AppAccentOption(
    key: maroonAccentKey,
    label: 'Maroon',
    seed: Color(0xFF7B2E1E),
    container: Color(0xFF99513B),
    fixed: Color(0xFFF7E2D7),
  ),
];

AppAccentOption appAccentByKey(String? key) {
  return appAccentOptions.firstWhere(
    (accent) => accent.key == key,
    orElse: () => appAccentOptions.first,
  );
}

ColorScheme lightHymnalColorScheme(String? accentKey) {
  final accent = appAccentByKey(accentKey ?? defaultAccentKey);
  return ColorScheme.fromSeed(
    seedColor: accent.seed,
    brightness: Brightness.light,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    surface: accent.surface,
  );
}

ColorScheme darkHymnalColorScheme(String? accentKey) {
  final accent = appAccentByKey(accentKey ?? defaultAccentKey);
  return ColorScheme.fromSeed(
    seedColor: accent.seed.withValues(alpha: 0.8),
    brightness: Brightness.dark,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    surface: const Color(0xFF0F172A),
  );
}


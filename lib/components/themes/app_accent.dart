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
  // Dark mode specific colors
  final Color darkSurface;
  final Color darkContainer;
  final Color darkOnSurface;
  final Color darkOnSurfaceVariant;

  const AppAccentOption({
    required this.key,
    required this.label,
    required this.seed,
    required this.container,
    required this.fixed,
    this.surface = Colors.transparent,
    // Default dark mode colors (can be overridden per accent)
    this.darkSurface = const Color(0xFF1E1E2E),
    this.darkContainer = const Color(0xFF2A2A3E),
    this.darkOnSurface = const Color(0xFFE8E8F0),
    this.darkOnSurfaceVariant = const Color(0xFFA0A0B0),
  });
}

const appAccentOptions = [
  AppAccentOption(
    key: 'skyBlue',
    label: 'Sky Blue',
    seed: Color(0xFF3B82F6),
    container: Color(0xFFDBEAFE),
    fixed: Color(0xFFF8FAFC),
    surface: Color(0xFFF8FAFC),
    darkSurface: Color(0xFF0F1729),
    darkContainer: Color(0xFF1E3A5F),
    darkOnSurface: Color(0xFFE2E8F0),
    darkOnSurfaceVariant: Color(0xFF94A3B8),
  ),
  AppAccentOption(
    key: 'mintGreen',
    label: 'Mint Green',
    seed: Color(0xFF10B981),
    container: Color(0xFFD1FAF5),
    fixed: Color(0xFFF0FDF4),
    surface: Color(0xFFF0FDF4),
    darkSurface: Color(0xFF0F1F1A),
    darkContainer: Color(0xFF1A3D2E),
    darkOnSurface: Color(0xFFE2F5E9),
    darkOnSurfaceVariant: Color(0xFF6EE7B7),
  ),
  AppAccentOption(
    key: 'softLavender',
    label: 'Lavender',
    seed: Color(0xFF8B5CF6),
    container: Color(0xFFF3E8FF),
    fixed: Color(0xFFFAF5FF),
    surface: Color(0xFFFAF5FF),
    darkSurface: Color(0xFF1A0F2E),
    darkContainer: Color(0xFF2D1B5F),
    darkOnSurface: Color(0xFFE8E0FF),
    darkOnSurfaceVariant: Color(0xFFC4B5FD),
  ),
  AppAccentOption(
    key: 'warmPeach',
    label: 'Peach',
    seed: Color(0xFFF97316),
    container: Color(0xFFFFEDD5),
    fixed: Color(0xFFFFFBF5),
    surface: Color(0xFFFFFBF5),
    darkSurface: Color(0xFF1F1409),
    darkContainer: Color(0xFF3D2A1A),
    darkOnSurface: Color(0xFFFFF0E2),
    darkOnSurfaceVariant: Color(0xFFFED7AA),
  ),
  AppAccentOption(
    key: 'dustyRose',
    label: 'Rose',
    seed: Color(0xFFF43F5E),
    container: Color(0xFFFFE4E6),
    fixed: Color(0xFFFFF1F2),
    surface: Color(0xFFFFF1F2),
    darkSurface: Color(0xFF1F0F12),
    darkContainer: Color(0xFF3D1A22),
    darkOnSurface: Color(0xFFFFE4E6),
    darkOnSurfaceVariant: Color(0xFFFECDD3),
  ),
  AppAccentOption(
    key: 'softTeal',
    label: 'Teal',
    seed: Color(0xFF14B8A6),
    container: Color(0xFFCCFBF1),
    fixed: Color(0xFFF0FDFA),
    surface: Color(0xFFF0FDFA),
    darkSurface: Color(0xFF0F1F1D),
    darkContainer: Color(0xFF1A3D38),
    darkOnSurface: Color(0xFFE0F5F0),
    darkOnSurfaceVariant: Color(0xFF5EEAD4),
  ),
  AppAccentOption(
    key: 'softIndigo',
    label: 'Indigo',
    seed: Color(0xFF6366F1),
    container: Color(0xFFE0E7FF),
    fixed: Color(0xFFEEF2FF),
    surface: Color(0xFFEEF2FF),
    darkSurface: Color(0xFF0F0F2E),
    darkContainer: Color(0xFF1F2255),
    darkOnSurface: Color(0xFFE0E7FF),
    darkOnSurfaceVariant: Color(0xFFA5B4FC),
  ),
  AppAccentOption(
    key: 'softAmber',
    label: 'Amber',
    seed: Color(0xFFF59E0B),
    container: Color(0xFFFEF3C7),
    fixed: Color(0xFFFFFBEB),
    surface: Color(0xFFFFFBEB),
    darkSurface: Color(0xFF1F1A0A),
    darkContainer: Color(0xFF3D3020),
    darkOnSurface: Color(0xFFFFF8E0),
    darkOnSurfaceVariant: Color(0xFFFCD34D),
  ),
  AppAccentOption(
    key: 'softCyan',
    label: 'Cyan',
    seed: Color(0xFF06B6D4),
    container: Color(0xFFCFFAFE),
    fixed: Color(0xFFECFEFF),
    surface: Color(0xFFECFEFF),
    darkSurface: Color(0xFF0F1F22),
    darkContainer: Color(0xFF1A3D4A),
    darkOnSurface: Color(0xFFE0F5FF),
    darkOnSurfaceVariant: Color(0xFF67E8F9),
  ),
  AppAccentOption(
    key: 'softViolet',
    label: 'Violet',
    seed: Color(0xFF7C3AED),
    container: Color(0xFFEDE9FE),
    fixed: Color(0xFFF5F3FF),
    surface: Color(0xFFF5F3FF),
    darkSurface: Color(0xFF180F28),
    darkContainer: Color(0xFF2A1D4D),
    darkOnSurface: Color(0xFFF0E8FF),
    darkOnSurfaceVariant: Color(0xFFA78BFA),
  ),
  AppAccentOption(
    key: 'softPink',
    label: 'Pink',
    seed: Color(0xFFEC4899),
    container: Color(0xFFFCE7F3),
    fixed: Color(0xFFFDF2F8),
    surface: Color(0xFFFDF2F8),
    darkSurface: Color(0xFF1F0F18),
    darkContainer: Color(0xFF3D1A2D),
    darkOnSurface: Color(0xFFFFF0F5),
    darkOnSurfaceVariant: Color(0xFFF9A8D4),
  ),
  AppAccentOption(
    key: 'softGray',
    label: 'Gray',
    seed: Color(0xFF6B7280),
    container: Color(0xFFF3F4F6),
    fixed: Color(0xFFFAFAFA),
    surface: Color(0xFFFAFAFA),
    darkSurface: Color(0xFF1F1F22),
    darkContainer: Color(0xFF2A2A30),
    darkOnSurface: Color(0xFFE8E8EA),
    darkOnSurfaceVariant: Color(0xFF9CA3AF),
  ),
  // Keep legacy maroon option for backward compatibility
  AppAccentOption(
    key: maroonAccentKey,
    label: 'Maroon',
    seed: Color(0xFF7B2E1E),
    container: Color(0xFF99513B),
    fixed: Color(0xFFF7E2D7),
    darkSurface: Color(0xFF1F0F0F),
    darkContainer: Color(0xFF3D2020),
    darkOnSurface: Color(0xFFF5E0D8),
    darkOnSurfaceVariant: Color(0xFFDEB8A8),
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
  return ColorScheme(
    brightness: Brightness.dark,
    // Use accent seed for primary colors
    primary: accent.seed,
    onPrimary: Colors.white,
    primaryContainer: accent.darkContainer,
    onPrimaryContainer: accent.darkOnSurface,
    secondary: accent.seed.withValues(alpha: 0.8),
    onSecondary: Colors.white,
    secondaryContainer: accent.darkContainer.withValues(alpha: 0.7),
    onSecondaryContainer: accent.darkOnSurface,
    tertiary: accent.seed.withValues(alpha: 0.6),
    onTertiary: Colors.white,
    tertiaryContainer: accent.darkContainer.withValues(alpha: 0.5),
    onTertiaryContainer: accent.darkOnSurface,
    error: const Color(0xFFCF6679),
    onError: Colors.black,
    surface: accent.darkSurface,
    onSurface: accent.darkOnSurface,
    surfaceContainerHighest: accent.darkContainer,
    onSurfaceVariant: accent.darkOnSurfaceVariant,
    outline: accent.darkOnSurfaceVariant.withValues(alpha: 0.5),
    outlineVariant: accent.darkOnSurfaceVariant.withValues(alpha: 0.3),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: accent.darkOnSurface,
    onInverseSurface: accent.darkSurface,
    inversePrimary: accent.seed,
    surfaceContainerLow: accent.darkSurface.withValues(alpha: 0.95),
    surfaceContainerLowest: Colors.black,
    surfaceContainer: accent.darkSurface.withValues(alpha: 0.9),
    surfaceContainerHigh: accent.darkContainer.withValues(alpha: 0.5),
  );
}


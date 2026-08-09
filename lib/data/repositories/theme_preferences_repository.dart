import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/theme_preferences.dart';

/// Durable store for user-facing appearance preferences.
///
/// Theme settings previously used a Hive box without initializing Hive on app
/// startup. That made writes silently unavailable on some launches and the
/// background preference reload could then replace the user's live selection
/// with defaults. SharedPreferences is already initialized by its platform
/// plugin, is cross-platform, and is sufficient for this small JSON payload.
class ThemePreferencesRepository {
  static const String _key = 'theme_preferences_v2';
  static const String _themeModeKey = 'theme_mode_v2';

  SharedPreferences? _preferences;
  ThemePreferences _cachedPreferences = const ThemePreferences();
  String _cachedThemeMode = 'light';

  Future<void> init() async {
    if (_preferences != null) return;
    final preferences = await SharedPreferences.getInstance();
    _preferences = preferences;

    final encoded = preferences.getString(_key);
    if (encoded != null && encoded.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(encoded);
        if (decoded is Map) {
          _cachedPreferences = ThemePreferences.fromJson(
            Map<String, dynamic>.from(decoded),
          );
        }
      } catch (_) {
        // Keep defaults when a previous value is malformed. Do not make a bad
        // preference payload capable of blocking application startup.
      }
    }
    _cachedThemeMode = preferences.getString(_themeModeKey) ?? 'light';
  }

  ThemePreferences get preferences => _cachedPreferences;

  String get themeMode => _cachedThemeMode;

  Future<void> savePreferences(ThemePreferences prefs) async {
    await init();
    _cachedPreferences = prefs;
    await _preferences!.setString(_key, jsonEncode(prefs.toJson()));
  }

  Future<void> saveThemeMode(String mode) async {
    await init();
    _cachedThemeMode = mode;
    await _preferences!.setString(_themeModeKey, mode);
  }

  Future<void> updateAccentKey(String key) async {
    await savePreferences(_cachedPreferences.copyWith(accentKey: key));
  }

  Future<void> updateDensity(DisplayDensity density) async {
    await savePreferences(_cachedPreferences.copyWith(density: density));
  }

  Future<void> updateTypographyScale(TypographyScale scale) async {
    await savePreferences(_cachedPreferences.copyWith(typographyScale: scale));
  }

  Future<void> updateCornerRadius(CornerRadiusStyle style) async {
    await savePreferences(_cachedPreferences.copyWith(cornerRadius: style));
  }

  Future<void> updateSurfaceTone(SurfaceTone tone) async {
    await savePreferences(_cachedPreferences.copyWith(surfaceTone: tone));
  }

  Future<void> updateCompactMode(bool compact) async {
    await savePreferences(_cachedPreferences.copyWith(compactMode: compact));
  }

  Future<void> reset() async {
    await init();
    _cachedPreferences = const ThemePreferences();
    _cachedThemeMode = 'light';
    await Future.wait([
      _preferences!.remove(_key),
      _preferences!.remove(_themeModeKey),
    ]);
  }
}

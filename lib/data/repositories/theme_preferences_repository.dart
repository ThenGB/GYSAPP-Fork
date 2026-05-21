import 'package:hive_flutter/hive_flutter.dart';
import '../models/theme_preferences.dart';

class ThemePreferencesRepository {
  static const String _boxName = 'theme_preferences';
  static const String _key = 'preferences';

  Box? _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
  }

  ThemePreferences get preferences {
    if (_box == null) {
      return const ThemePreferences();
    }
    final data = _box!.get(_key);
    if (data == null) return const ThemePreferences();
    return ThemePreferences.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> savePreferences(ThemePreferences prefs) async {
    if (_box == null) return;
    await _box!.put(_key, prefs.toJson());
  }

  Future<void> updateAccentKey(String key) async {
    final current = preferences;
    await savePreferences(current.copyWith(accentKey: key));
  }

  Future<void> updateDensity(DisplayDensity density) async {
    final current = preferences;
    await savePreferences(current.copyWith(density: density));
  }

  Future<void> updateTypographyScale(TypographyScale scale) async {
    final current = preferences;
    await savePreferences(current.copyWith(typographyScale: scale));
  }

  Future<void> updateCornerRadius(CornerRadiusStyle style) async {
    final current = preferences;
    await savePreferences(current.copyWith(cornerRadius: style));
  }

  Future<void> updateSurfaceTone(SurfaceTone tone) async {
    final current = preferences;
    await savePreferences(current.copyWith(surfaceTone: tone));
  }

  Future<void> updateCompactMode(bool compact) async {
    final current = preferences;
    await savePreferences(current.copyWith(compactMode: compact));
  }

  Future<void> reset() async {
    await savePreferences(const ThemePreferences());
  }
}
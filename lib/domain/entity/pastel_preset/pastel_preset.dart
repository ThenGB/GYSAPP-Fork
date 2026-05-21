import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pastel_preset.freezed.dart';
part 'pastel_preset.g.dart';

Color _colorToJson(Color color) {
  return color;
}

Color _colorFromJson(dynamic json) {
  if (json is Color) return json;
  if (json is int) return Color(json);
  if (json is String) {
    final hexColor = json.startsWith('#') ? json.substring(1) : json;
    final colorInt = int.tryParse(hexColor, radix: 16) ?? 0xFF000000;
    return Color(0xFF000000 + colorInt);
  }
  return const Color(0xFF93C5FD); // default sky blue
}

@freezed
abstract class PastelPreset with _$PastelPreset {
  const PastelPreset._();
  const factory PastelPreset({
    required String key,
    required String label,
    @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) required Color primary,
    @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) required Color container,
    @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) required Color surface,
    @Default(false) bool isDark,
  }) = _PastelPreset;

  factory PastelPreset.fromJson(Map<String, dynamic> json) =>
      _$PastelPresetFromJson(json);
}

const pastelPresets = [
  PastelPreset(
    key: 'skyBlue',
    label: 'Sky Blue',
    primary: Color(0xFF93C5FD),
    container: Color(0xFFDBEAFE),
    surface: Color(0xFFF8FAFC),
  ),
  PastelPreset(
    key: 'mintGreen',
    label: 'Mint Green',
    primary: Color(0xFF6EE7B7),
    container: Color(0xFFD1FAF5),
    surface: Color(0xFFF0FDF4),
  ),
  PastelPreset(
    key: 'softLavender',
    label: 'Soft Lavender',
    primary: Color(0xFFC4B5FD),
    container: Color(0xFFF3E8FF),
    surface: Color(0xFFFAF5FF),
  ),
  PastelPreset(
    key: 'warmPeach',
    label: 'Warm Peach',
    primary: Color(0xFFFED7AA),
    container: Color(0xFFFFEDD5),
    surface: Color(0xFFFFFBF5),
  ),
  PastelPreset(
    key: 'dustyRose',
    label: 'Dusty Rose',
    primary: Color(0xFFFECDD3),
    container: Color(0xFFFFE4E6),
    surface: Color(0xFFFFF1F2),
  ),
  PastelPreset(
    key: 'softTeal',
    label: 'Soft Teal',
    primary: Color(0xFF5EEAD4),
    container: Color(0xFFCCFBF1),
    surface: Color(0xFFF0FDFA),
  ),
  PastelPreset(
    key: 'softIndigo',
    label: 'Soft Indigo',
    primary: Color(0xFFA5B4FC),
    container: Color(0xFFE0E7FF),
    surface: Color(0xFFEEF2FF),
  ),
  PastelPreset(
    key: 'softAmber',
    label: 'Soft Amber',
    primary: Color(0xFFFCD34D),
    container: Color(0xFFFEF3C7),
    surface: Color(0xFFFFFBEB),
  ),
  PastelPreset(
    key: 'softCyan',
    label: 'Soft Cyan',
    primary: Color(0xFF67E8F9),
    container: Color(0xFFCFFAFE),
    surface: Color(0xFFECFEFF),
  ),
  PastelPreset(
    key: 'softViolet',
    label: 'Soft Violet',
    primary: Color(0xFFA78BFA),
    container: Color(0xFFEDE9FE),
    surface: Color(0xFFF5F3FF),
  ),
  PastelPreset(
    key: 'softPink',
    label: 'Soft Pink',
    primary: Color(0xFFF9A8D4),
    container: Color(0xFFFCE7F3),
    surface: Color(0xFFFDF2F8),
  ),
  PastelPreset(
    key: 'softGray',
    label: 'Soft Gray',
    primary: Color(0xFF9CA3AF),
    container: Color(0xFFF3F4F6),
    surface: Color(0xFFFAFAFA),
  ),
];
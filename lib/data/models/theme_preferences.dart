import 'package:flutter/material.dart' show Color;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_preferences.freezed.dart';
part 'theme_preferences.g.dart';

enum SurfaceTone { light, medium, dark }

enum CornerRadiusStyle { soft, medium, sharp }

enum DisplayDensity { compact, standard, comfortable }

enum TypographyScale { compact, normal, comfortable }

@freezed
abstract class ThemePreferences with _$ThemePreferences {
  const ThemePreferences._();

  const factory ThemePreferences({
    @Default('skyBlue') String accentKey,

    /// ARGB value of the user-picked custom accent colour; 0 = unset.
    @Default(0) int customAccentSeed,
    @Default(SurfaceTone.light) SurfaceTone surfaceTone,
    @Default(CornerRadiusStyle.soft) CornerRadiusStyle cornerRadius,
    @Default(DisplayDensity.standard) DisplayDensity density,
    @Default(TypographyScale.normal) TypographyScale typographyScale,
    @Default(false) bool compactMode,
  }) = _ThemePreferences;

  factory ThemePreferences.fromJson(Map<String, dynamic> json) =>
      _$ThemePreferencesFromJson(json);

  Color? get customAccentColor =>
      customAccentSeed == 0 ? null : Color(customAccentSeed);
}

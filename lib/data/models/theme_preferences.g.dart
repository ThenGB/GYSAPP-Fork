// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ThemePreferences _$ThemePreferencesFromJson(
  Map<String, dynamic> json,
) => _ThemePreferences(
  accentKey: json['accentKey'] as String? ?? 'skyBlue',
  customAccentSeed: (json['customAccentSeed'] as num?)?.toInt() ?? 0,
  surfaceTone:
      $enumDecodeNullable(_$SurfaceToneEnumMap, json['surfaceTone']) ??
      SurfaceTone.light,
  cornerRadius:
      $enumDecodeNullable(_$CornerRadiusStyleEnumMap, json['cornerRadius']) ??
      CornerRadiusStyle.soft,
  density:
      $enumDecodeNullable(_$DisplayDensityEnumMap, json['density']) ??
      DisplayDensity.standard,
  typographyScale:
      $enumDecodeNullable(_$TypographyScaleEnumMap, json['typographyScale']) ??
      TypographyScale.normal,
  compactMode: json['compactMode'] as bool? ?? false,
);

Map<String, dynamic> _$ThemePreferencesToJson(_ThemePreferences instance) =>
    <String, dynamic>{
      'accentKey': instance.accentKey,
      'customAccentSeed': instance.customAccentSeed,
      'surfaceTone': _$SurfaceToneEnumMap[instance.surfaceTone]!,
      'cornerRadius': _$CornerRadiusStyleEnumMap[instance.cornerRadius]!,
      'density': _$DisplayDensityEnumMap[instance.density]!,
      'typographyScale': _$TypographyScaleEnumMap[instance.typographyScale]!,
      'compactMode': instance.compactMode,
    };

const _$SurfaceToneEnumMap = {
  SurfaceTone.light: 'light',
  SurfaceTone.medium: 'medium',
  SurfaceTone.dark: 'dark',
};

const _$CornerRadiusStyleEnumMap = {
  CornerRadiusStyle.soft: 'soft',
  CornerRadiusStyle.medium: 'medium',
  CornerRadiusStyle.sharp: 'sharp',
};

const _$DisplayDensityEnumMap = {
  DisplayDensity.compact: 'compact',
  DisplayDensity.standard: 'standard',
  DisplayDensity.comfortable: 'comfortable',
};

const _$TypographyScaleEnumMap = {
  TypographyScale.compact: 'compact',
  TypographyScale.normal: 'normal',
  TypographyScale.comfortable: 'comfortable',
};

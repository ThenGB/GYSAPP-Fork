// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pastel_preset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PastelPreset _$PastelPresetFromJson(Map<String, dynamic> json) =>
    _PastelPreset(
      key: json['key'] as String,
      label: json['label'] as String,
      primary: _colorFromJson(json['primary']),
      container: _colorFromJson(json['container']),
      surface: _colorFromJson(json['surface']),
      isDark: json['isDark'] as bool? ?? false,
    );

Map<String, dynamic> _$PastelPresetToJson(_PastelPreset instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'primary': _colorToJson(instance.primary),
      'container': _colorToJson(instance.container),
      'surface': _colorToJson(instance.surface),
      'isDark': instance.isDark,
    };

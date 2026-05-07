// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menulink_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Menulink _$MenulinkFromJson(Map<String, dynamic> json) => _Menulink(
      label: json['label'] as String,
      icon: json['icon'] as String,
      url: json['url'] as String,
      enabled: json['enabled'] as bool,
    );

Map<String, dynamic> _$MenulinkToJson(_Menulink instance) => <String, dynamic>{
      'label': instance.label,
      'icon': instance.icon,
      'url': instance.url,
      'enabled': instance.enabled,
    };

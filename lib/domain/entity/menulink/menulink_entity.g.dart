// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menulink_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MenulinkImpl _$$MenulinkImplFromJson(Map<String, dynamic> json) =>
    _$MenulinkImpl(
      label: json['label'] as String,
      icon: json['icon'] as String,
      url: json['url'] as String,
      enabled: json['enabled'] as bool,
    );

Map<String, dynamic> _$$MenulinkImplToJson(_$MenulinkImpl instance) =>
    <String, dynamic>{
      'label': instance.label,
      'icon': instance.icon,
      'url': instance.url,
      'enabled': instance.enabled,
    };

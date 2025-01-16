// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImageBannerImpl _$$ImageBannerImplFromJson(Map<String, dynamic> json) =>
    _$ImageBannerImpl(
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      linkUrl: json['linkUrl'] as String?,
      order: (json['order'] as num?)?.toInt(),
      title: json['title'] as String?,
      expiredDate: json['expiredDate'] == null
          ? null
          : DateTime.parse(json['expiredDate'] as String),
    );

Map<String, dynamic> _$$ImageBannerImplToJson(_$ImageBannerImpl instance) =>
    <String, dynamic>{
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'linkUrl': instance.linkUrl,
      'order': instance.order,
      'title': instance.title,
      'expiredDate': instance.expiredDate?.toIso8601String(),
    };

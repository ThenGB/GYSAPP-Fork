// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImageBanner _$ImageBannerFromJson(Map<String, dynamic> json) => _ImageBanner(
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      linkUrl: json['linkUrl'] as String?,
      order: (json['order'] as num?)?.toInt(),
      title: json['title'] as String?,
      expiredDate: json['expiredDate'] == null
          ? null
          : DateTime.parse(json['expiredDate'] as String),
    );

Map<String, dynamic> _$ImageBannerToJson(_ImageBanner instance) =>
    <String, dynamic>{
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'linkUrl': instance.linkUrl,
      'order': instance.order,
      'title': instance.title,
      'expiredDate': instance.expiredDate?.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kesaksian_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Kesaksian _$KesaksianFromJson(Map<String, dynamic> json) => _Kesaksian(
      title: json['title'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$KesaksianToJson(_Kesaksian instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'url': instance.url,
      'imageUrl': instance.imageUrl,
    };

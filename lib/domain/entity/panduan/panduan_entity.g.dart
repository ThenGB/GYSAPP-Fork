// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panduan_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Panduan _$PanduanFromJson(Map<String, dynamic> json) => _Panduan(
      title: json['title'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$PanduanToJson(_Panduan instance) => <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'url': instance.url,
      'imageUrl': instance.imageUrl,
    };

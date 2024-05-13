// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kesaksian_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KesaksianImpl _$$KesaksianImplFromJson(Map<String, dynamic> json) =>
    _$KesaksianImpl(
      title: json['title'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$$KesaksianImplToJson(_$KesaksianImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'url': instance.url,
      'imageUrl': instance.imageUrl,
    };

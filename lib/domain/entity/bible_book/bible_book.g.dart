// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BibleBookImpl _$$BibleBookImplFromJson(Map<String, dynamic> json) =>
    _$BibleBookImpl(
      id: (json['id'] as num).toInt(),
      shortName: json['bs'] as String?,
      longName: json['bl'] as String?,
      chapterCount: (json['c'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$BibleBookImplToJson(_$BibleBookImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bs': instance.shortName,
      'bl': instance.longName,
      'c': instance.chapterCount,
    };

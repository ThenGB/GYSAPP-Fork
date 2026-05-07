// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BibleBook _$BibleBookFromJson(Map<String, dynamic> json) => _BibleBook(
      id: (json['id'] as num).toInt(),
      shortName: json['bs'] as String?,
      longName: json['bl'] as String?,
      chapterCount: (json['c'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BibleBookToJson(_BibleBook instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bs': instance.shortName,
      'bl': instance.longName,
      'c': instance.chapterCount,
    };

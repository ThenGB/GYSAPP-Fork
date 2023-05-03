// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_BibleBook _$$_BibleBookFromJson(Map<String, dynamic> json) => _$_BibleBook(
      id: json['id'] as int,
      shortName: json['bs'] as String?,
      longName: json['bl'] as String?,
      chapterCount: json['c'] as int?,
    );

Map<String, dynamic> _$$_BibleBookToJson(_$_BibleBook instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bs': instance.shortName,
      'bl': instance.longName,
      'c': instance.chapterCount,
    };

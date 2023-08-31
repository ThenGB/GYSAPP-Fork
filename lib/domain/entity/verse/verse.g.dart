// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Verse _$$_VerseFromJson(Map<String, dynamic> json) => _$_Verse(
      id: dynamicToInt(json['id']),
      bookId: dynamicToInt(json['b']),
      chapterId: dynamicToInt(json['c']),
      verseId: dynamicToInt(json['v']),
      verse: json['t'] as String?,
      revisionId: json['r'] as int?,
      c1: dynamicToString(json['c1']),
      v1: dynamicToString(json['v1']),
      color: _colorFromJson(json['color']),
    );

Map<String, dynamic> _$$_VerseToJson(_$_Verse instance) => <String, dynamic>{
      'id': intToDynamic(instance.id),
      'b': intToDynamic(instance.bookId),
      'c': intToDynamic(instance.chapterId),
      'v': intToDynamic(instance.verseId),
      't': instance.verse,
      'r': instance.revisionId,
      'c1': stringToDynamic(instance.c1),
      'v1': stringToDynamic(instance.v1),
      'color': _colorToJson(instance.color),
    };

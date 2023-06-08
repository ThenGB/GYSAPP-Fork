// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Verse _$$_VerseFromJson(Map<String, dynamic> json) => _$_Verse(
      id: json['id'] as int,
      bookId: json['b'] as int,
      chapterId: json['c'] as int,
      verseId: json['v'] as int,
      verse: json['t'] as String?,
      revisionId: json['r'] as int?,
      c1: json['c1'] as String?,
      v1: json['v1'] as String?,
      color: _colorFromJson(json['color']),
    );

Map<String, dynamic> _$$_VerseToJson(_$_Verse instance) => <String, dynamic>{
      'id': instance.id,
      'b': instance.bookId,
      'c': instance.chapterId,
      'v': instance.verseId,
      't': instance.verse,
      'r': instance.revisionId,
      'c1': instance.c1,
      'v1': instance.v1,
      'color': _colorToJson(instance.color),
    };

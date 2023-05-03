// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pericope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Pericope _$$_PericopeFromJson(Map<String, dynamic> json) => _$_Pericope(
      id: json['id'] as int,
      s: json['s'] as int?,
      bookId: json['b'] as int?,
      chapterId: json['c'] as int?,
      verseId: json['v'] as int?,
      title: json['t'] as String?,
    );

Map<String, dynamic> _$$_PericopeToJson(_$_Pericope instance) =>
    <String, dynamic>{
      'id': instance.id,
      's': instance.s,
      'b': instance.bookId,
      'c': instance.chapterId,
      'v': instance.verseId,
      't': instance.title,
    };

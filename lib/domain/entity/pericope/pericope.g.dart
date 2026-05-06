// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pericope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Pericope _$PericopeFromJson(Map<String, dynamic> json) => _Pericope(
      id: (json['id'] as num).toInt(),
      s: (json['s'] as num?)?.toInt(),
      bookId: (json['b'] as num?)?.toInt(),
      chapterId: (json['c'] as num?)?.toInt(),
      verseId: (json['v'] as num?)?.toInt(),
      title: json['t'] as String?,
    );

Map<String, dynamic> _$PericopeToJson(_Pericope instance) => <String, dynamic>{
      'id': instance.id,
      's': instance.s,
      'b': instance.bookId,
      'c': instance.chapterId,
      'v': instance.verseId,
      't': instance.title,
    };

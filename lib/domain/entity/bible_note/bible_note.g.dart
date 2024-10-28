// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BibleNoteImpl _$$BibleNoteImplFromJson(Map<String, dynamic> json) =>
    _$BibleNoteImpl(
      id: (json['id'] as num).toInt(),
      verses: (json['verses'] as List<dynamic>)
          .map((e) => Verse.fromJson(e as Map<String, dynamic>))
          .toList(),
      text: json['text'] as String?,
      createdDate: DateTime.parse(json['createdDate'] as String),
      updatedDate: DateTime.parse(json['updatedDate'] as String),
    );

Map<String, dynamic> _$$BibleNoteImplToJson(_$BibleNoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'verses': instance.verses,
      'text': instance.text,
      'createdDate': instance.createdDate.toIso8601String(),
      'updatedDate': instance.updatedDate.toIso8601String(),
    };

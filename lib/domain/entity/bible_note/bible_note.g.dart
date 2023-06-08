// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_BibleNote _$$_BibleNoteFromJson(Map<String, dynamic> json) => _$_BibleNote(
      verses: (json['verses'] as List<dynamic>)
          .map((e) => Verse.fromJson(e as Map<String, dynamic>))
          .toList(),
      text: json['text'] as String?,
      createdDate: DateTime.parse(json['createdDate'] as String),
      updatedDate: DateTime.parse(json['updatedDate'] as String),
    );

Map<String, dynamic> _$$_BibleNoteToJson(_$_BibleNote instance) =>
    <String, dynamic>{
      'verses': instance.verses,
      'text': instance.text,
      'createdDate': instance.createdDate.toIso8601String(),
      'updatedDate': instance.updatedDate.toIso8601String(),
    };

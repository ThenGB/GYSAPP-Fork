// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faith_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_FaithNote _$$_FaithNoteFromJson(Map<String, dynamic> json) => _$_FaithNote(
      verses: (json['verses'] as List<dynamic>).map((e) => e as int).toList(),
      text: json['text'] as String?,
      createdDate: DateTime.parse(json['createdDate'] as String),
      updatedDate: DateTime.parse(json['updatedDate'] as String),
    );

Map<String, dynamic> _$$_FaithNoteToJson(_$_FaithNote instance) =>
    <String, dynamic>{
      'verses': instance.verses,
      'text': instance.text,
      'createdDate': instance.createdDate.toIso8601String(),
      'updatedDate': instance.updatedDate.toIso8601String(),
    };

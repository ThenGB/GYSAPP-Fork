// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faith_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FaithNoteImpl _$$FaithNoteImplFromJson(Map<String, dynamic> json) =>
    _$FaithNoteImpl(
      id: (json['id'] as num).toInt(),
      verses: (json['verses'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      text: json['text'] as String?,
      createdDate: DateTime.parse(json['createdDate'] as String),
      updatedDate: DateTime.parse(json['updatedDate'] as String),
    );

Map<String, dynamic> _$$FaithNoteImplToJson(_$FaithNoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'verses': instance.verses,
      'text': instance.text,
      'createdDate': instance.createdDate.toIso8601String(),
      'updatedDate': instance.updatedDate.toIso8601String(),
    };

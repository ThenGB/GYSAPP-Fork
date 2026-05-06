// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SongNote _$SongNoteFromJson(Map<String, dynamic> json) => _SongNote(
      id: (json['id'] as num).toInt(),
      song: Song.fromJson(json['song'] as Map<String, dynamic>),
      text: json['text'] as String?,
      createdDate: DateTime.parse(json['createdDate'] as String),
      updatedDate: DateTime.parse(json['updatedDate'] as String),
    );

Map<String, dynamic> _$SongNoteToJson(_SongNote instance) => <String, dynamic>{
      'id': instance.id,
      'song': instance.song,
      'text': instance.text,
      'createdDate': instance.createdDate.toIso8601String(),
      'updatedDate': instance.updatedDate.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SongNote _$$_SongNoteFromJson(Map<String, dynamic> json) => _$_SongNote(
      id: json['id'] as int,
      song: Song.fromJson(json['song'] as Map<String, dynamic>),
      text: json['text'] as String?,
      createdDate: DateTime.parse(json['createdDate'] as String),
      updatedDate: DateTime.parse(json['updatedDate'] as String),
    );

Map<String, dynamic> _$$_SongNoteToJson(_$_SongNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'song': instance.song,
      'text': instance.text,
      'createdDate': instance.createdDate.toIso8601String(),
      'updatedDate': instance.updatedDate.toIso8601String(),
    };

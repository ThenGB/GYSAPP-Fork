// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SongHistory _$$_SongHistoryFromJson(Map<String, dynamic> json) =>
    _$_SongHistory(
      index: json['index'] as int,
      bookCode: json['bookCode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$_SongHistoryToJson(_$_SongHistory instance) =>
    <String, dynamic>{
      'index': instance.index,
      'bookCode': instance.bookCode,
      'createdAt': instance.createdAt.toIso8601String(),
    };

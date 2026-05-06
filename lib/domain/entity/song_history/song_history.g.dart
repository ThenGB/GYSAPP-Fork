// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SongHistory _$SongHistoryFromJson(Map<String, dynamic> json) => _SongHistory(
      index: (json['index'] as num).toInt(),
      bookCode: json['bookCode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SongHistoryToJson(_SongHistory instance) =>
    <String, dynamic>{
      'index': instance.index,
      'bookCode': instance.bookCode,
      'createdAt': instance.createdAt.toIso8601String(),
    };

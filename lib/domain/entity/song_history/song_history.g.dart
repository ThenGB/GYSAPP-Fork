// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SongHistoryImpl _$$SongHistoryImplFromJson(Map<String, dynamic> json) =>
    _$SongHistoryImpl(
      index: (json['index'] as num).toInt(),
      bookCode: json['bookCode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SongHistoryImplToJson(_$SongHistoryImpl instance) =>
    <String, dynamic>{
      'index': instance.index,
      'bookCode': instance.bookCode,
      'createdAt': instance.createdAt.toIso8601String(),
    };

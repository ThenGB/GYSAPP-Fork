// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SongBookImpl _$$SongBookImplFromJson(Map<String, dynamic> json) =>
    _$SongBookImpl(
      code: json['code'] as String?,
      songs: (json['songs'] as List<dynamic>?)
              ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$SongBookImplToJson(_$SongBookImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'songs': instance.songs,
    };

_$SongImpl _$$SongImplFromJson(Map<String, dynamic> json) => _$SongImpl(
      code: json['code'] as String?,
      number: json['number'] as String?,
      number2: json['number2'] as String?,
      title: json['lyric'] as String?,
      soundfilePath: json['song'] as String?,
      pageLength: (json['pages'] as num?)?.toInt(),
      pageStart: (json['page'] as num?)?.toInt(),
      verses: (json['verses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$SongImplToJson(_$SongImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'number': instance.number,
      'number2': instance.number2,
      'lyric': instance.title,
      'song': instance.soundfilePath,
      'pages': instance.pageLength,
      'page': instance.pageStart,
      'verses': instance.verses,
    };

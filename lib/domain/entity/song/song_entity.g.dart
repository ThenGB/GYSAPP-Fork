// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SongBook _$$_SongBookFromJson(Map<String, dynamic> json) => _$_SongBook(
      code: json['code'] as String?,
      songs: (json['songs'] as List<dynamic>?)
              ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_SongBookToJson(_$_SongBook instance) =>
    <String, dynamic>{
      'code': instance.code,
      'songs': instance.songs,
    };

_$_Song _$$_SongFromJson(Map<String, dynamic> json) => _$_Song(
      code: json['code'] as String?,
      number: json['number'] as String?,
      number2: json['number2'] as String?,
      title: json['lyric'] as String?,
      soundfilePath: json['song'] as String?,
      pageLength: json['pages'] as int?,
      pageStart: json['page'] as int?,
      verses: (json['verses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_SongToJson(_$_Song instance) => <String, dynamic>{
      'code': instance.code,
      'number': instance.number,
      'number2': instance.number2,
      'lyric': instance.title,
      'song': instance.soundfilePath,
      'pages': instance.pageLength,
      'page': instance.pageStart,
      'verses': instance.verses,
    };

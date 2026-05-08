// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SongBook _$SongBookFromJson(Map<String, dynamic> json) => _SongBook(
  code: json['code'] as String?,
  songs:
      (json['songs'] as List<dynamic>?)
          ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$SongBookToJson(_SongBook instance) => <String, dynamic>{
  'code': instance.code,
  'songs': instance.songs,
};

_Song _$SongFromJson(Map<String, dynamic> json) => _Song(
  code: json['code'] as String?,
  number: json['number'] as String?,
  number2: json['number2'] as String?,
  title: json['lyric'] as String?,
  soundfilePath: json['song'] as String?,
  pageLength: (json['pages'] as num?)?.toInt(),
  pageStart: (json['page'] as num?)?.toInt(),
  verses:
      (json['verses'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$SongToJson(_Song instance) => <String, dynamic>{
  'code': instance.code,
  'number': instance.number,
  'number2': instance.number2,
  'lyric': instance.title,
  'song': instance.soundfilePath,
  'pages': instance.pageLength,
  'page': instance.pageStart,
  'verses': instance.verses,
};

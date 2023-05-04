// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SongState _$$_SongStateFromJson(Map<String, dynamic> json) => _$_SongState(
      isLoading: json['isLoading'] as bool? ?? false,
      songBook: (json['songBook'] as List<dynamic>?)
              ?.map((e) => SongBook.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      favoriteSongBook: (json['favoriteSongBook'] as List<dynamic>?)
              ?.map((e) => SongBook.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      bookCode: json['bookCode'] as String? ?? 'KR',
      pageIndex: json['pageIndex'] as int? ?? 0,
      verseIndex: json['verseIndex'] as int? ?? 0,
      isImageMode: json['isImageMode'] ?? false,
      textScaleFactor: (json['textScaleFactor'] as num?)?.toDouble() ?? 1,
      showSizer: json['showSizer'] as bool? ?? false,
    );

Map<String, dynamic> _$$_SongStateToJson(_$_SongState instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'songBook': instance.songBook,
      'favoriteSongBook': instance.favoriteSongBook,
      'bookCode': instance.bookCode,
      'pageIndex': instance.pageIndex,
      'verseIndex': instance.verseIndex,
      'isImageMode': instance.isImageMode,
      'textScaleFactor': instance.textScaleFactor,
      'showSizer': instance.showSizer,
    };

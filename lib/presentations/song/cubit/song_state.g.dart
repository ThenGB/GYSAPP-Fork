// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SongState _$$_SongStateFromJson(Map<String, dynamic> json) => _$_SongState(
      isLoading: json['isLoading'] as bool? ?? false,
      isAudioLoading: json['isAudioLoading'] as bool? ?? false,
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
      defaultAudioFormat: json['defaultAudioFormat'] as String? ?? 'mid',
      selectedSong: json['selectedSong'] == null
          ? null
          : Song.fromJson(json['selectedSong'] as Map<String, dynamic>),
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => SongNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      sortNotesBy: json['sortNotesBy'] as String? ?? 'Newest',
      histories: (json['histories'] as List<dynamic>?)
              ?.map((e) => SongHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      playOnlyFavorite: json['playOnlyFavorite'] as bool? ?? false,
      shuffleMode: json['shuffleMode'] as bool? ?? false,
      shuffleIndex: (json['shuffleIndex'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      showAudio: json['showAudio'] as bool? ?? false,
      searchTerms: json['searchTerms'] as String? ?? '',
    );

Map<String, dynamic> _$$_SongStateToJson(_$_SongState instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'isAudioLoading': instance.isAudioLoading,
      'songBook': instance.songBook,
      'favoriteSongBook': instance.favoriteSongBook,
      'bookCode': instance.bookCode,
      'pageIndex': instance.pageIndex,
      'verseIndex': instance.verseIndex,
      'isImageMode': instance.isImageMode,
      'textScaleFactor': instance.textScaleFactor,
      'showSizer': instance.showSizer,
      'defaultAudioFormat': instance.defaultAudioFormat,
      'selectedSong': instance.selectedSong,
      'notes': instance.notes,
      'sortNotesBy': instance.sortNotesBy,
      'histories': instance.histories,
      'playOnlyFavorite': instance.playOnlyFavorite,
      'shuffleMode': instance.shuffleMode,
      'shuffleIndex': instance.shuffleIndex,
      'showAudio': instance.showAudio,
      'searchTerms': instance.searchTerms,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SongState _$SongStateFromJson(Map<String, dynamic> json) => _SongState(
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
      pageIndex: (json['pageIndex'] as num?)?.toInt() ?? 0,
      verseIndex: (json['verseIndex'] as num?)?.toInt() ?? 0,
      isImageMode: json['isImageMode'] ?? false,
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
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      showAudio: json['showAudio'] as bool? ?? false,
      showChord: json['showChord'] as bool? ?? false,
      searchTerms: json['searchTerms'] as String? ?? '',
      defaultFont: json['defaultFont'] as String? ?? 'Roboto',
      defaultTextScale: (json['defaultTextScale'] as num?)?.toDouble() ?? 1.2,
      defaultTextHeight: (json['defaultTextHeight'] as num?)?.toDouble() ?? 1.5,
      lastSync: (json['lastSync'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, DateTime.parse(e as String)),
          ) ??
          const {},
      remoteLyricsUpdateAt:
          (json['remoteLyricsUpdateAt'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, DateTime.parse(e as String)),
              ) ??
              const {},
      transposeStep: (json['transposeStep'] as num?)?.toInt() ?? 0,
      chordAccidentalMode: json['chordAccidentalMode'] as String? ?? 'sharp',
      preferNaturalChords: json['preferNaturalChords'] as bool? ?? false,
      originalFamilyChord: json['originalFamilyChord'] as String?,
      originalPdfKey: json['originalPdfKey'] as String?,
      baseTransposeOffset: (json['baseTransposeOffset'] as num?)?.toInt() ?? 0,
      tempoBpm: (json['tempoBpm'] as num?)?.toDouble() ?? 76.0,
      defaultTempoBpm: (json['defaultTempoBpm'] as num?)?.toDouble() ?? 76.0,
      midiInstrument: (json['midiInstrument'] as num?)?.toInt(),
      soundFont: json['soundFont'] as String? ?? 'GeneralUser-GS.sf2',
      isAudioPlaying: json['isAudioPlaying'] as bool? ?? false,
      pdfTwoPageMode: json['pdfTwoPageMode'] as bool? ?? false,
      pdfVerticalScrolling: json['pdfVerticalScrolling'] as bool? ?? false,
      lyricsTextAlign: json['lyricsTextAlign'] as String? ?? 'left',
      lyricsVerticalAlign: json['lyricsVerticalAlign'] as String? ?? 'top',
      chordFontSizePercent:
          (json['chordFontSizePercent'] as num?)?.toInt() ?? 100,
      chordFillOpacityPercent:
          (json['chordFillOpacityPercent'] as num?)?.toInt() ?? 94,
      chordPaddingPercent:
          (json['chordPaddingPercent'] as num?)?.toInt() ?? 100,
    );

Map<String, dynamic> _$SongStateToJson(_SongState instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'isAudioLoading': instance.isAudioLoading,
      'songBook': instance.songBook,
      'favoriteSongBook': instance.favoriteSongBook,
      'bookCode': instance.bookCode,
      'pageIndex': instance.pageIndex,
      'verseIndex': instance.verseIndex,
      'isImageMode': instance.isImageMode,
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
      'showChord': instance.showChord,
      'searchTerms': instance.searchTerms,
      'defaultFont': instance.defaultFont,
      'defaultTextScale': instance.defaultTextScale,
      'defaultTextHeight': instance.defaultTextHeight,
      'lastSync':
          instance.lastSync.map((k, e) => MapEntry(k, e.toIso8601String())),
      'remoteLyricsUpdateAt': instance.remoteLyricsUpdateAt
          .map((k, e) => MapEntry(k, e.toIso8601String())),
      'transposeStep': instance.transposeStep,
      'chordAccidentalMode': instance.chordAccidentalMode,
      'preferNaturalChords': instance.preferNaturalChords,
      'originalFamilyChord': instance.originalFamilyChord,
      'originalPdfKey': instance.originalPdfKey,
      'baseTransposeOffset': instance.baseTransposeOffset,
      'tempoBpm': instance.tempoBpm,
      'defaultTempoBpm': instance.defaultTempoBpm,
      'midiInstrument': instance.midiInstrument,
      'soundFont': instance.soundFont,
      'isAudioPlaying': instance.isAudioPlaying,
      'pdfTwoPageMode': instance.pdfTwoPageMode,
      'pdfVerticalScrolling': instance.pdfVerticalScrolling,
      'lyricsTextAlign': instance.lyricsTextAlign,
      'lyricsVerticalAlign': instance.lyricsVerticalAlign,
      'chordFontSizePercent': instance.chordFontSizePercent,
      'chordFillOpacityPercent': instance.chordFillOpacityPercent,
      'chordPaddingPercent': instance.chordPaddingPercent,
    };

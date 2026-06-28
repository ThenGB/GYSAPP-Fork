// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BibleState _$BibleStateFromJson(Map<String, dynamic> json) => _BibleState(
  currentBibleCode: json['currentBibleCode'] as String? ?? 'b_tb',
  splitBibleCode: json['splitBibleCode'] as String? ?? 'b_tb',
  bibleCodes:
      (json['bibleCodes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  currentBible: json['currentBible'] == null
      ? null
      : Verse.fromJson(json['currentBible'] as Map<String, dynamic>),
  prevBible: json['prevBible'] == null
      ? null
      : Verse.fromJson(json['prevBible'] as Map<String, dynamic>),
  currentBibleSplit: json['currentBibleSplit'] == null
      ? null
      : Verse.fromJson(json['currentBibleSplit'] as Map<String, dynamic>),
  prevBibleSplit: json['prevBibleSplit'] == null
      ? null
      : Verse.fromJson(json['prevBibleSplit'] as Map<String, dynamic>),
  books:
      (json['books'] as List<dynamic>?)
          ?.map((e) => BibleBook.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  booksSplit:
      (json['booksSplit'] as List<dynamic>?)
          ?.map((e) => BibleBook.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  verses:
      (json['verses'] as List<dynamic>?)
          ?.map((e) => Verse.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  versesSplit:
      (json['versesSplit'] as List<dynamic>?)
          ?.map((e) => Verse.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  bookmarks:
      (json['bookmarks'] as List<dynamic>?)
          ?.map((e) => BibleBookmark.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  references:
      (json['references'] as List<dynamic>?)
          ?.map((e) => BibleRef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  referencesSplit:
      (json['referencesSplit'] as List<dynamic>?)
          ?.map((e) => BibleRef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  histories:
      (json['histories'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          DateTime.parse(k),
          Verse.fromJson(e as Map<String, dynamic>),
        ),
      ) ??
      const {},
  pericopes:
      (json['pericopes'] as List<dynamic>?)
          ?.map((e) => Pericope.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  pericopesSplit:
      (json['pericopesSplit'] as List<dynamic>?)
          ?.map((e) => Pericope.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  notes:
      (json['notes'] as List<dynamic>?)
          ?.map((e) => BibleNote.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  pericopesParalels:
      (json['pericopesParalels'] as List<dynamic>?)
          ?.map((e) => PericopeParalel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  pericopesParalelsSplit:
      (json['pericopesParalelsSplit'] as List<dynamic>?)
          ?.map((e) => PericopeParalel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  currentBook: json['currentBook'] == null
      ? null
      : BibleBook.fromJson(json['currentBook'] as Map<String, dynamic>),
  currentBookSplit: json['currentBookSplit'] == null
      ? null
      : BibleBook.fromJson(json['currentBookSplit'] as Map<String, dynamic>),
  selectedVerse:
      (json['selectedVerse'] as List<dynamic>?)
          ?.map((e) => Verse.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  hightlightedVerse:
      (json['hightlightedVerse'] as List<dynamic>?)
          ?.map((e) => Verse.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  todayReading: json['todayReading'] == null
      ? null
      : Verse.fromJson(json['todayReading'] as Map<String, dynamic>),
  lastOpenBible: json['lastOpenBible'] == null
      ? null
      : DateTime.parse(json['lastOpenBible'] as String),
  defaultFont: json['defaultFont'] as String? ?? 'EB Garamond',
  defaultTextScale: (json['defaultTextScale'] as num?)?.toDouble() ?? 1.2,
  defaultTextHeight: (json['defaultTextHeight'] as num?)?.toDouble() ?? 1.5,
  followGlobalFontSettings: json['followGlobalFontSettings'] as bool? ?? true,
  sortNotesBy: json['sortNotesBy'] as String? ?? 'Newest',
  enableAudio: json['enableAudio'] as bool? ?? false,
  isSpeaking: json['isSpeaking'] as bool? ?? false,
  isSplitContentLoading: json['isSplitContentLoading'] as bool? ?? false,
  currentWord: json['currentWord'] as String? ?? '',
  currentStartWord: (json['currentStartWord'] as num?)?.toInt() ?? 0,
  currentEndWord: (json['currentEndWord'] as num?)?.toInt() ?? 0,
  selectedFilterBooks:
      (json['selectedFilterBooks'] as List<dynamic>?)
          ?.map((e) => BibleBook.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  voices:
      (json['voices'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as Map<String, dynamic>),
      ) ??
      const {},
  speedRate: (json['speedRate'] as num?)?.toDouble() ?? .35,
  pitchRate: (json['pitchRate'] as num?)?.toDouble() ?? .90,
);

Map<String, dynamic> _$BibleStateToJson(_BibleState instance) =>
    <String, dynamic>{
      'currentBibleCode': instance.currentBibleCode,
      'splitBibleCode': instance.splitBibleCode,
      'bibleCodes': instance.bibleCodes,
      'currentBible': instance.currentBible,
      'prevBible': instance.prevBible,
      'currentBibleSplit': instance.currentBibleSplit,
      'prevBibleSplit': instance.prevBibleSplit,
      'books': instance.books,
      'booksSplit': instance.booksSplit,
      'verses': instance.verses,
      'versesSplit': instance.versesSplit,
      'bookmarks': instance.bookmarks,
      'references': instance.references,
      'referencesSplit': instance.referencesSplit,
      'histories': instance.histories.map(
        (k, e) => MapEntry(k.toIso8601String(), e),
      ),
      'pericopes': instance.pericopes,
      'pericopesSplit': instance.pericopesSplit,
      'notes': instance.notes,
      'pericopesParalels': instance.pericopesParalels,
      'pericopesParalelsSplit': instance.pericopesParalelsSplit,
      'currentBook': instance.currentBook,
      'currentBookSplit': instance.currentBookSplit,
      'selectedVerse': instance.selectedVerse,
      'hightlightedVerse': instance.hightlightedVerse,
      'todayReading': instance.todayReading,
      'lastOpenBible': instance.lastOpenBible?.toIso8601String(),
      'defaultFont': instance.defaultFont,
      'defaultTextScale': instance.defaultTextScale,
      'defaultTextHeight': instance.defaultTextHeight,
      'followGlobalFontSettings': instance.followGlobalFontSettings,
      'sortNotesBy': instance.sortNotesBy,
      'enableAudio': instance.enableAudio,
      'isSpeaking': instance.isSpeaking,
      'isSplitContentLoading': instance.isSplitContentLoading,
      'currentWord': instance.currentWord,
      'currentStartWord': instance.currentStartWord,
      'currentEndWord': instance.currentEndWord,
      'selectedFilterBooks': instance.selectedFilterBooks,
      'voices': instance.voices,
      'speedRate': instance.speedRate,
      'pitchRate': instance.pitchRate,
    };

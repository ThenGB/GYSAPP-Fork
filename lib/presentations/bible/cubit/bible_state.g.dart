// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_BibleState _$$_BibleStateFromJson(Map<String, dynamic> json) =>
    _$_BibleState(
      currentBibleCode: json['currentBibleCode'] as String? ?? 'b_tb',
      splitBibleCode: json['splitBibleCode'] as String? ?? 'b_tb',
      bibleCodes: (json['bibleCodes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      currentBible: json['currentBible'] == null
          ? null
          : Verse.fromJson(json['currentBible'] as Map<String, dynamic>),
      prevBible: json['prevBible'] == null
          ? null
          : Verse.fromJson(json['prevBible'] as Map<String, dynamic>),
      books: (json['books'] as List<dynamic>?)
              ?.map((e) => BibleBook.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      verses: (json['verses'] as List<dynamic>?)
              ?.map((e) => Verse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      bookmarks: (json['bookmarks'] as List<dynamic>?)
              ?.map((e) => Verse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      references: (json['references'] as List<dynamic>?)
              ?.map((e) => BibleRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      splitVerses: (json['splitVerses'] as List<dynamic>?)
              ?.map((e) => Verse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      histories: (json['histories'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                DateTime.parse(k), Verse.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      pericopes: (json['pericopes'] as List<dynamic>?)
              ?.map((e) => Pericope.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      splitPericopes: (json['splitPericopes'] as List<dynamic>?)
              ?.map((e) => Pericope.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => BibleNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pericopesParalels: (json['pericopesParalels'] as List<dynamic>?)
              ?.map((e) => PericopeParalel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      splitPericopesParalels: (json['splitPericopesParalels'] as List<dynamic>?)
              ?.map((e) => PericopeParalel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentBook: json['currentBook'] == null
          ? null
          : BibleBook.fromJson(json['currentBook'] as Map<String, dynamic>),
      splitBook: json['splitBook'] == null
          ? null
          : BibleBook.fromJson(json['splitBook'] as Map<String, dynamic>),
      selectedVerse: (json['selectedVerse'] as List<dynamic>?)
              ?.map((e) => Verse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      hightlightedVerse: (json['hightlightedVerse'] as List<dynamic>?)
              ?.map((e) => Verse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      todayReading: json['todayReading'] == null
          ? null
          : Verse.fromJson(json['todayReading'] as Map<String, dynamic>),
      lastOpenBible: json['lastOpenBible'] == null
          ? null
          : DateTime.parse(json['lastOpenBible'] as String),
      defaultFont: json['defaultFont'] as String? ?? 'Roboto',
      defaultTextScale: (json['defaultTextScale'] as num?)?.toDouble() ?? 1,
      defaultTextHeight: (json['defaultTextHeight'] as num?)?.toDouble() ?? 1.5,
      sortNotesBy: json['sortNotesBy'] as String? ?? 'Newest',
    );

Map<String, dynamic> _$$_BibleStateToJson(_$_BibleState instance) =>
    <String, dynamic>{
      'currentBibleCode': instance.currentBibleCode,
      'splitBibleCode': instance.splitBibleCode,
      'bibleCodes': instance.bibleCodes,
      'currentBible': instance.currentBible,
      'prevBible': instance.prevBible,
      'books': instance.books,
      'verses': instance.verses,
      'bookmarks': instance.bookmarks,
      'references': instance.references,
      'splitVerses': instance.splitVerses,
      'histories':
          instance.histories.map((k, e) => MapEntry(k.toIso8601String(), e)),
      'pericopes': instance.pericopes,
      'splitPericopes': instance.splitPericopes,
      'notes': instance.notes,
      'pericopesParalels': instance.pericopesParalels,
      'splitPericopesParalels': instance.splitPericopesParalels,
      'currentBook': instance.currentBook,
      'splitBook': instance.splitBook,
      'selectedVerse': instance.selectedVerse,
      'hightlightedVerse': instance.hightlightedVerse,
      'todayReading': instance.todayReading,
      'lastOpenBible': instance.lastOpenBible?.toIso8601String(),
      'defaultFont': instance.defaultFont,
      'defaultTextScale': instance.defaultTextScale,
      'defaultTextHeight': instance.defaultTextHeight,
      'sortNotesBy': instance.sortNotesBy,
    };

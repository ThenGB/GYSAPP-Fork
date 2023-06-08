// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_BibleState _$$_BibleStateFromJson(Map<String, dynamic> json) =>
    _$_BibleState(
      currentBibleCode: json['currentBibleCode'] as String? ?? 'b_tb',
      bibleCodes: (json['bibleCodes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      currentBible: json['currentBible'] == null
          ? null
          : Verse.fromJson(json['currentBible'] as Map<String, dynamic>),
      books: (json['books'] as List<dynamic>?)
              ?.map((e) => BibleBook.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      verses: (json['verses'] as List<dynamic>?)
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
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => BibleNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pericopesParalels: (json['pericopesParalels'] as List<dynamic>?)
              ?.map((e) => PericopeParalel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentBook: json['currentBook'] == null
          ? null
          : BibleBook.fromJson(json['currentBook'] as Map<String, dynamic>),
      bookTitle: json['bookTitle'] as String?,
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
    );

Map<String, dynamic> _$$_BibleStateToJson(_$_BibleState instance) =>
    <String, dynamic>{
      'currentBibleCode': instance.currentBibleCode,
      'bibleCodes': instance.bibleCodes,
      'currentBible': instance.currentBible,
      'books': instance.books,
      'verses': instance.verses,
      'histories':
          instance.histories.map((k, e) => MapEntry(k.toIso8601String(), e)),
      'pericopes': instance.pericopes,
      'notes': instance.notes,
      'pericopesParalels': instance.pericopesParalels,
      'currentBook': instance.currentBook,
      'bookTitle': instance.bookTitle,
      'selectedVerse': instance.selectedVerse,
      'hightlightedVerse': instance.hightlightedVerse,
      'todayReading': instance.todayReading,
      'lastOpenBible': instance.lastOpenBible?.toIso8601String(),
      'defaultFont': instance.defaultFont,
      'defaultTextScale': instance.defaultTextScale,
      'defaultTextHeight': instance.defaultTextHeight,
    };

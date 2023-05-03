// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_BibleState _$$_BibleStateFromJson(Map<String, dynamic> json) =>
    _$_BibleState(
      currentBibleCode: json['currentBibleCode'] as String?,
      bibleCodes: (json['bibleCodes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      currentBible: json['currentBible'] == null
          ? null
          : Bible.fromJson(json['currentBible'] as Map<String, dynamic>),
      books: (json['books'] as List<dynamic>?)
              ?.map((e) => BibleBook.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      bibles: (json['bibles'] as List<dynamic>?)
              ?.map((e) => Bible.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pericopes: (json['pericopes'] as List<dynamic>?)
              ?.map((e) => Pericope.fromJson(e as Map<String, dynamic>))
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
              ?.map((e) => Bible.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      hightlightedVerse: (json['hightlightedVerse'] as List<dynamic>?)
              ?.map((e) => Bible.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_BibleStateToJson(_$_BibleState instance) =>
    <String, dynamic>{
      'currentBibleCode': instance.currentBibleCode,
      'bibleCodes': instance.bibleCodes,
      'currentBible': instance.currentBible,
      'books': instance.books,
      'bibles': instance.bibles,
      'pericopes': instance.pericopes,
      'pericopesParalels': instance.pericopesParalels,
      'currentBook': instance.currentBook,
      'bookTitle': instance.bookTitle,
      'selectedVerse': instance.selectedVerse,
      'hightlightedVerse': instance.hightlightedVerse,
    };

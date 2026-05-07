// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_bookmark.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BibleBookmark _$BibleBookmarkFromJson(Map<String, dynamic> json) =>
    _BibleBookmark(
      createdAt: DateTime.parse(json['created_at'] as String),
      isBookmarkAll: json['is_bookmark_all'] as bool,
      verse: Verse.fromJson(json['verse'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BibleBookmarkToJson(_BibleBookmark instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt.toIso8601String(),
      'is_bookmark_all': instance.isBookmarkAll,
      'verse': instance.verse,
    };

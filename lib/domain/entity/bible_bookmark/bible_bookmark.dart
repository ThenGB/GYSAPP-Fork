import 'package:freezed_annotation/freezed_annotation.dart';

import '../entities.dart';

part 'bible_bookmark.freezed.dart';
part 'bible_bookmark.g.dart';

@freezed
abstract class BibleBookmark with _$BibleBookmark {
  const BibleBookmark._();
  const factory BibleBookmark({
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'is_bookmark_all') required bool isBookmarkAll,
    @JsonKey(name: 'verse') required Verse verse,
  }) = _BibleBookmark;

  factory BibleBookmark.fromJson(Map<String, dynamic> json) =>
      _$BibleBookmarkFromJson(json);
}


import 'package:freezed_annotation/freezed_annotation.dart';

part 'bible_book.freezed.dart';
part 'bible_book.g.dart';

@freezed
class BibleBook with _$BibleBook {
  const BibleBook._();
  const factory BibleBook({
    required int id,
    @JsonKey(name: 'bs') String? shortName,
    @JsonKey(name: 'bl') String? longName,
    @JsonKey(name: 'c') int? chapterCount,
  }) = _BibleBook;

  factory BibleBook.fromJson(Map<String, dynamic> json) =>
      _$BibleBookFromJson(json);
}

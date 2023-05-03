import 'package:freezed_annotation/freezed_annotation.dart';

part 'pericope.freezed.dart';
part 'pericope.g.dart';

@freezed
class Pericope with _$Pericope {
  const Pericope._();
  const factory Pericope({
    required int id,
    @JsonKey(name: 's') int? s,
    @JsonKey(name: 'b') int? bookId,
    @JsonKey(name: 'c') int? chapterId,
    @JsonKey(name: 'v') int? verseId,
    @JsonKey(name: 't') String? title,
  }) = _Pericope;

  factory Pericope.fromJson(Map<String, dynamic> json) =>
      _$PericopeFromJson(json);
}

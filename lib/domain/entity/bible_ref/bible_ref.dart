import 'package:freezed_annotation/freezed_annotation.dart';

part 'bible_ref.freezed.dart';
part 'bible_ref.g.dart';

@freezed
class BibleRef with _$BibleRef {
  const BibleRef._();
  const factory BibleRef({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'sv') int? sv,
    @JsonKey(name: 'ev') int? ev,
  }) = _BibleRef;

  factory BibleRef.fromJson(Map<String, dynamic> json) =>
      _$BibleRefFromJson(json);
}

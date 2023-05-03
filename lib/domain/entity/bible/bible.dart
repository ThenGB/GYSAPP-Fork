import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bible.freezed.dart';
part 'bible.g.dart';

@freezed
class Bible with _$Bible {
  const Bible._();
  const factory Bible({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'b') required int bookId,
    @JsonKey(name: 'c') required int chapterId,
    @JsonKey(name: 'v') required int verseId,
    @JsonKey(name: 't') String? verse,
    @JsonKey(name: 'r') int? revisionId,
    @JsonKey(name: 'c1') String? c1,
    @JsonKey(name: 'v1') String? v1,
    @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
        Color? color,
  }) = _Bible;

  factory Bible.fromJson(Map<String, dynamic> json) => _$BibleFromJson(json);

  bool isSame(Bible other) {
    return bookId == other.bookId &&
        chapterId == other.chapterId &&
        verseId == other.verseId &&
        id == other.id;
  }
}

String? _colorToJson(Color? color) {
  if (color == Colors.transparent || color == null) {
    return null;
  }
  return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
}

Color? _colorFromJson(dynamic json) {
  if (json == null) {
    return Colors.transparent;
  }
  final hexColor = json.startsWith('#') ? json.substring(1) : json;
  final colorInt = int.parse(hexColor, radix: 16);
  return Color(0xFF000000 + colorInt);
}

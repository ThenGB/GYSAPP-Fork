import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'verse.freezed.dart';
part 'verse.g.dart';

@freezed
class Verse with _$Verse {
  const Verse._();
  const factory Verse({
    @JsonKey(name: 'id')
        required int id,
    @JsonKey(name: 'b')
        required int bookId,
    @JsonKey(name: 'c')
        required int chapterId,
    @JsonKey(name: 'v')
        required int verseId,
    @JsonKey(name: 't')
        String? verse,
    @JsonKey(name: 'r')
        int? revisionId,
    @JsonKey(name: 'c1', fromJson: dynamicToString, toJson: stringToDynamic)
        String? c1,
    @JsonKey(name: 'v1')
        String? v1,
    @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
        Color? color,
  }) = _Verse;

  factory Verse.fromJson(Map<String, dynamic> json) => _$VerseFromJson(json);

  bool isSame(Verse other) {
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

dynamicToString(dynamic value) {
  return value?.toString();
}

stringToDynamic(String? value) {
  return value;
}

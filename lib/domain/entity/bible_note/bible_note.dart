import 'package:freezed_annotation/freezed_annotation.dart';

import '../verse/verse.dart';

part 'bible_note.freezed.dart';
part 'bible_note.g.dart';

@freezed
class BibleNote with _$BibleNote {
  const BibleNote._();
  const factory BibleNote({
    required List<Verse> verses,
    String? text,
    required DateTime createdDate,
    required DateTime updatedDate,
  }) = _BibleNote;

  factory BibleNote.empty(List<Verse> verses) {
    return BibleNote(
      verses: verses,
      createdDate: DateTime.now(),
      updatedDate: DateTime.now(),
    );
  }

  factory BibleNote.fromJson(Map<String, dynamic> json) =>
      _$BibleNoteFromJson(json);
}

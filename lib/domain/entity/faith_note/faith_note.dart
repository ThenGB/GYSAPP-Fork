import 'package:freezed_annotation/freezed_annotation.dart';

part 'faith_note.freezed.dart';
part 'faith_note.g.dart';

@freezed
abstract class FaithNote with _$FaithNote {
  const FaithNote._();
  const factory FaithNote({
    required int id,
    required List<int> verses,
    String? text,
    required DateTime createdDate,
    required DateTime updatedDate,
  }) = _FaithNote;

  factory FaithNote.empty(List<int> verses) {
    return FaithNote(
      id: DateTime.now().microsecondsSinceEpoch,
      verses: verses,
      createdDate: DateTime.now(),
      updatedDate: DateTime.now(),
    );
  }

  factory FaithNote.fromJson(Map<String, dynamic> json) =>
      _$FaithNoteFromJson(json);
}


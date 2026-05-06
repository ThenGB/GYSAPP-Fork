import 'package:freezed_annotation/freezed_annotation.dart';

import '../song/song_entity.dart';

part 'song_note.freezed.dart';
part 'song_note.g.dart';

@freezed
abstract class SongNote with _$SongNote {
  const SongNote._();
  const factory SongNote({
    required int id,
    required Song song,
    String? text,
    required DateTime createdDate,
    required DateTime updatedDate,
  }) = _SongNote;

  factory SongNote.empty(Song song) {
    return SongNote(
      id: DateTime.now().microsecondsSinceEpoch,
      song: song,
      createdDate: DateTime.now(),
      updatedDate: DateTime.now(),
    );
  }

  factory SongNote.fromJson(Map<String, dynamic> json) =>
      _$SongNoteFromJson(json);
}


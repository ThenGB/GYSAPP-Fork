import 'package:freezed_annotation/freezed_annotation.dart';

part 'song_history.freezed.dart';
part 'song_history.g.dart';

@freezed
class SongHistory with _$SongHistory {
  const SongHistory._();
  const factory SongHistory({
    required int index,
    required String bookCode,
    required DateTime createdAt,
  }) = _SongHistory;

  factory SongHistory.fromJson(Map<String, dynamic> json) =>
      _$SongHistoryFromJson(json);
}

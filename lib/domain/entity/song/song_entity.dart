import 'package:freezed_annotation/freezed_annotation.dart';

part 'song_entity.freezed.dart';
part 'song_entity.g.dart';

@freezed
abstract class SongBook with _$SongBook {
  const SongBook._();
  const factory SongBook({
    @JsonKey(name: 'code') String? code,
    @Default([]) @JsonKey(name: 'songs') List<Song> songs,
  }) = _SongBook;

  factory SongBook.fromJson(Map<String, dynamic> json) =>
      _$SongBookFromJson(json);
}

@freezed
abstract class Song with _$Song {
  const Song._();
  const factory Song({
    @JsonKey(name: 'code') String? code,
    @JsonKey(name: 'number') String? number,
    @JsonKey(name: 'number2') String? number2,
    @JsonKey(name: 'lyric') String? title,
    @JsonKey(name: 'song') String? soundfilePath,
    @JsonKey(name: 'pages') int? pageLength,
    @JsonKey(name: 'page') int? pageStart,
    @Default([]) @JsonKey(name: 'verses') List<String> verses,
  }) = _Song;

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
}


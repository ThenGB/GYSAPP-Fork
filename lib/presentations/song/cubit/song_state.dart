import 'dart:io';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pdf_render/pdf_render.dart';

import '../../../data/utilities/extensions/list_extension.dart';
import '../../../di/injection.dart';
import '../../../domain/entity/song/song_entity.dart';
import '../../../domain/entity/song_history/song_history.dart';
import '../../../domain/entity/song_note/song_note.dart';

part 'song_state.freezed.dart';
part 'song_state.g.dart';

@freezed
class SongState with _$SongState {
  const SongState._();
  const factory SongState({
    @Default(false) bool isLoading,
    @Default(false) bool isAudioLoading,
    @Default([]) List<SongBook> songBook,
    @Default([]) List<SongBook> favoriteSongBook,
    @Default('KR') String bookCode,
    @Default(0) int pageIndex,
    @Default(0) int verseIndex,
    @Default(false) isImageMode,
    @Default(1) double textScaleFactor,
    @Default(false) bool showSizer,
    @Default('mid') String defaultAudioFormat,
    Song? selectedSong,
    @Default([]) List<SongNote> notes,
    @Default('Newest') String sortNotesBy,
    @Default([]) List<SongHistory> histories,
    @Default(false) bool playOnlyFavorite,
    @Default(false) bool shuffleMode,
    @Default([]) List<int> shuffleIndex,
    @Default(false) bool showAudio,
    @Default('') String searchTerms,
  }) = _SongState;

  SongBook? get currentSong {
    return songBook.firstWhereOrNull((element) => element.code == bookCode);
  }

  List<Song> get songs {
    // return (currentSong?.songs ?? []);

    if (!playOnlyFavorite) {
      return (currentSong?.songs ?? []);
    }
    List<Song> songs = [];
    for (var book in favoriteSongBook) {
      songs.addAll(book.songs);
    }
    if (shuffleMode) {
      songs = songs.rearrangeList(shuffleIndex);
    }
    return songs;
  }

  Future<List<Uint8List>> getImageLyricPath(
      BuildContext context, int pageStart, int pageLength) async {
    final result = <Uint8List>[];
    var data = await rootBundle.load('assets/data/$bookCode.pdf');
    var file = File('${di<AppDirectory>().cache}/$bookCode.pdf');
    if (!file.existsSync()) {
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await file.writeAsBytes(bytes, flush: true);
    }
    var doc = await PdfDocument.openFile(file.path);
    for (var i = 0; i < pageLength; i++) {
      var page = await doc.getPage(pageStart + i);
      var image = await page.render(
        backgroundFill: true,
        height: (page.height * 2).toInt(),
        width: (page.width * 2).toInt(),
      );
      var img = await image.createImageDetached();
      var imgBytes = await img.toByteData(format: ImageByteFormat.png);
      var libImage = imgBytes!.buffer
          .asUint8List(imgBytes.offsetInBytes, imgBytes.lengthInBytes);
      result.add(libImage);
    }
    return result;
  }

  Future<List<SongNote>> filteredNote(String filter) async {
    Map<String, SongNote> mapped = {};
    Map<String, SongNote> filtered = {};

    /// generate the title of the note first
    for (var note in notes) {
      var title = note.song.title ?? '';
      mapped[title] = note;
    }

    /// return all immediately if the filter is empty to show all
    if (filter.isEmpty) {
      return mapped.entries.sorted(sortNotes).map((e) => e.value).toList();
    }

    /// filter function
    for (var item in mapped.entries) {
      if (item.value.text?.toLowerCase().contains(filter) == true ||
          item.key.toLowerCase().contains(filter)) {
        filtered[item.key] = item.value;
      }
    }

    return filtered.entries.sorted(sortNotes).map((e) => e.value).toList();
  }

  int sortNotes(MapEntry<String, SongNote> a, MapEntry<String, SongNote> b) {
    return () {
      switch (sortNotesBy) {
        case 'Newest':
          return b.value.createdDate.compareTo(a.value.createdDate);
        case 'Oldest':
          return a.value.createdDate.compareTo(b.value.createdDate);
        case 'A-Z':
          return a.key.compareTo(b.key);
        case 'Z-A':
          return b.key.compareTo(a.key);
        default:
          return 0;
      }
    }();
  }

  factory SongState.fromJson(Map<String, dynamic> json) =>
      _$SongStateFromJson(json);
}

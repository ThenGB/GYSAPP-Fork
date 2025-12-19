import 'dart:io';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:pdf_render/pdf_render.dart';
// import 'package:pdfx/pdfx.dart';
import '../../../data/utilities/extensions/extensions.dart';
import '../../../di/injection.dart';
import '../../../domain/entity/song/song_entity.dart';
import '../../../domain/entity/song_history/song_history.dart';
import '../../../domain/entity/song_note/song_note.dart';
import '../../../router/router.dart';

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
    @Default('Roboto') String defaultFont,
    @Default(1.2) double defaultTextScale,
    @Default(1.5) double defaultTextHeight,
    @Default({}) Map<String, DateTime> lastSync,
    @Default({}) Map<String, DateTime> remoteLyricsUpdateAt,
  }) = _SongState;

  SongBook? get currentSong {
    return songBook.firstWhereOrNull((element) => element.code == bookCode);
  }

  TextTheme getTextThemeByFontName(String font) {
    switch (font) {
      case 'Roboto':
        return GoogleFonts.robotoTextTheme();
      case 'Roboto Serif':
        return GoogleFonts.robotoSerifTextTheme();
      case 'Open Sans':
        return GoogleFonts.openSansTextTheme();
      case 'Gentium Basic':
        return GoogleFonts.gentiumBookPlusTextTheme();
      case 'Arial':
        return GoogleFonts.ptSansTextTheme();
      default:
        return GoogleFonts.robotoTextTheme();
    }
  }

  bool get fontBold {
    return bookCode.contains('MDR');
  }

  TextTheme get defaultTextTheme {
    var result = GoogleFonts.robotoTextTheme();
    switch (defaultFont) {
      case 'Roboto':
        result = GoogleFonts.robotoTextTheme();
        break;
      case 'Roboto Serif':
        result = GoogleFonts.robotoSerifTextTheme();
        break;
      case 'Open Sans':
        result = GoogleFonts.openSansTextTheme();
        break;
      case 'Gentium Basic':
        result = GoogleFonts.gentiumBookPlusTextTheme();
        break;
      case 'Arial':
        result = GoogleFonts.ptSansTextTheme();
        break;
      default:
        result = GoogleFonts.robotoTextTheme();
        break;
    }
    return result.apply(
        bodyColor: router.navigatorKey.currentContext?.textColor);
  }

  List<String> get availableFonts {
    return ['Roboto', 'Roboto Serif', 'Open Sans', 'Gentium Basic', 'Arial'];
  }

  List<Song> get songs {
    // If not playing only favorites, return current song book
    if (!playOnlyFavorite) {
      return (currentSong?.songs ?? []);
    }

    // If playing only favorites but no favorite books exist, fallback to current song
    if (favoriteSongBook.isEmpty) {
      return (currentSong?.songs ?? []);
    }

    // Collect songs from all favorite books
    List<Song> songs = [];
    for (var book in favoriteSongBook) {
      songs.addAll(book.songs);
    }

    // If no songs found in favorite books, fallback to current song
    if (songs.isEmpty) {
      return (currentSong?.songs ?? []);
    }

    // Apply shuffle if enabled
    if (shuffleMode) {
      songs = songs.rearrangeList(shuffleIndex);
    }

    return songs;
  }
  /*
  // Fungsi getImageLyricPath
  Future<List<Uint8List>> getImageLyricPath(
      BuildContext context, int pageStart, int pageLength) async {
    final result = <Uint8List>[];
    try {
      var file = File('${di<AppDirectory>().songLyricFolder}/$bookCode.pdf');
      if (!file.existsSync()) {
        var data = await rootBundle.load('assets/data/$bookCode.pdf');
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await file.writeAsBytes(bytes, flush: true);
      }

      final document = await PdfDocument.openFile(file.path);
      for (var i = 0; i < pageLength; i++) {
        final page = await document.getPage(pageStart + i);
        final pageImage = await page.render(
          width: (page.width * 2).toDouble(),
          height: (page.height * 2).toDouble(),
          format: PdfPageImageFormat.png,
          backgroundColor: '#FFFFFFFF', // tetap putih
        );
        result.add(pageImage!.bytes);
        await page.close();
      }
      await document.close();

      print('###PDF: $bookCode [LEN=${result.length}] ==> ${file.path}');
    } catch (e) {
      print(e.toString());
    }
    return result;
  }
  */
  Future<List<SongNote>> filteredNote(String filter) async {
    Map<String, SongNote> mapped = {};
    Map<String, SongNote> filtered = {};

    /// generate the title of the note first
    for (var note in notes) {
      var title = note.song.title ?? '';
      mapped['$title|${note.id}'] = note;
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
      title(String v) => v.split('|').first;
      switch (sortNotesBy) {
        case 'Newest':
          return b.value.createdDate.compareTo(a.value.createdDate);
        case 'Oldest':
          return a.value.createdDate.compareTo(b.value.createdDate);
        case 'A-Z':
          return title(a.key).compareTo(title(b.key));
        case 'Z-A':
          return title(b.key).compareTo(title(a.key));
        default:
          return 0;
      }
    }();
  }

  factory SongState.fromJson(Map<String, dynamic> json) =>
      _$SongStateFromJson(json);
}

extension SongStateSafeAccess on SongState {
  /// Safely get a song by index, returns null if index is out of bounds
  Song? getSongAt(int index) {
    if (index < 0 || index >= songs.length) {
      return null;
    }
    return songs[index];
  }

  /// Safely get song title by index, returns empty string if index is out of bounds
  String getSongTitleAt(int index) {
    final song = getSongAt(index);
    return song?.title ?? '';
  }

  /// Safely get song number by index, returns null if index is out of bounds
  String? getSongNumberAt(int index) {
    final song = getSongAt(index);
    return song?.number;
  }

  /// Safely get song code by index, returns empty string if index is out of bounds
  String getSongCodeAt(int index) {
    final song = getSongAt(index);
    return song?.code ?? '';
  }

  /// Safely get verse at specific song index and verse index
  String? getVerseAt(int songIndex, int verseIndex) {
    final song = getSongAt(songIndex);
    if (song == null || verseIndex < 0 || verseIndex >= song.verses.length) {
      return null;
    }
    return song.verses[verseIndex];
  }

  /// Safely get verse count for a song at index
  int getVerseCountAt(int index) {
    final song = getSongAt(index);
    return song?.verses.length ?? 0;
  }

  /// Safely get page length for a song at index
  int getPageLengthAt(int index) {
    final song = getSongAt(index);
    return song?.pageLength ?? 0;
  }

  /// Check if index is valid for songs list
  bool isValidSongIndex(int index) {
    return index >= 0 && index < songs.length;
  }
}

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/utilities/extensions/context_ext.dart';
import '../../../domain/entity/bible_book/bible_book.dart';
import '../../../domain/entity/bible_bookmark/bible_bookmark.dart';
import '../../../domain/entity/bible_note/bible_note.dart';
import '../../../domain/entity/bible_ref/bible_ref.dart';
import '../../../domain/entity/pericope/pericope.dart';
import '../../../domain/entity/pericope_paralel/pericope_paralel.dart';
import '../../../domain/entity/verse/verse.dart';
import '../../../router/router.dart';

part 'bible_state.freezed.dart';
part 'bible_state.g.dart';

@freezed
class BibleState with _$BibleState {
  const BibleState._();
  const factory BibleState({
    @Default('b_tb') String currentBibleCode,
    @Default('b_tb') String splitBibleCode,
    @Default([]) List<String> bibleCodes,
    Verse? currentBible,
    Verse? prevBible,
    Verse? currentBibleSplit,
    Verse? prevBibleSplit,
    @Default([]) List<BibleBook> books,
    @Default([]) List<BibleBook> booksSplit,
    @Default([]) List<Verse> verses,
    @Default([]) List<BibleBookmark> bookmarks,
    @Default([]) List<BibleRef> references,
    @Default([]) List<BibleRef> referencesSplit,
    @Default([]) List<Verse> versesSplit,
    @Default({}) Map<DateTime, Verse> histories,
    @Default([]) List<Pericope> pericopes,
    @Default([]) List<Pericope> pericopesSplit,
    @Default([]) List<BibleNote> notes,
    @Default([]) List<PericopeParalel> pericopesParalels,
    @Default([]) List<PericopeParalel> pericopesParalelsSplit,
    BibleBook? currentBook,
    BibleBook? currentBookSplit,
    @Default([]) List<Verse> selectedVerse,
    @Default([]) List<Verse> hightlightedVerse,
    Verse? todayReading,
    DateTime? lastOpenBible,
    @Default('Roboto') String defaultFont,
    @Default(1.2) double defaultTextScale,
    @Default(1.5) double defaultTextHeight,
    @Default('Newest') String sortNotesBy,
    @Default(false) bool enableAudio,
    @Default(false) bool isSpeaking,
    @Default('') String currentWord,
    @Default(0) int currentStartWord,
    @Default(0) int currentEndWord,
    @Default([]) List<BibleBook> selectedFilterBooks,
    @Default({}) Map<String, Map> voices,
    @Default(.35) double speedRate,
    @Default(.90) double pitchRate,
  }) = _BibleState;

  factory BibleState.fromJson(Map<String, dynamic> json) =>
      _$BibleStateFromJson(json);

  bool? get isSelectedPerjanjianLama {
    if (isSelectedCurrentBook) return false;
    var perjanjian = selectedFilterBooks
        .where((element) => element.id <= 39)
        .toSet()
        .toList();
    return perjanjian.length == 39
        ? true
        : perjanjian.isEmpty
            ? false
            : null;
  }

  String get currentBibleLanguage {
    switch (currentBibleCode) {
      case 'b_tb':
        return 'id-ID';
      case 'b_kjv':
        return 'en-US';
      case 'b_cuv':
        return 'zh-CN';
      default:
        return 'en-US';
    }
  }

  bool? get isSelectedPerjanjianBaru {
    if (isSelectedCurrentBook) return false;
    var perjanjian = selectedFilterBooks
        .where((element) => element.id > 39)
        .toSet()
        .toList();
    return perjanjian.length == 27
        ? true
        : perjanjian.isEmpty
            ? false
            : null;
  }

  bool get isSelectedCurrentBook {
    return selectedFilterBooks.length == 1 &&
        selectedFilterBooks.single == currentBook;
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
        result = GoogleFonts.gentiumBookBasicTextTheme();
        break;
      case 'Arial':
        result = GoogleFonts.ptSansTextTheme();
        break;
      default:
        result = GoogleFonts.robotoTextTheme();
        break;
    }
    return result.apply(
        bodyColor:
            router.navigatorKey.currentContext?.textTheme.bodyMedium?.color);
  }

  Future<List<BibleNote>> filteredNote(
      String filter, Future<String> Function(List<Verse> item) getTitle) async {
    Map<String, BibleNote> mapped = {};
    Map<String, BibleNote> filtered = {};

    /// generate the title of the note first
    for (var note in notes) {
      var title = await getTitle(note.verses);
      mapped['$title|${note.id}'] = note;
    }

    /// return all immediately if the filter is empty to show all
    if (filter.isEmpty) {
      return mapped.entries.sorted(sortNotes).map((e) => e.value).toList();
    }

    /// filter function
    for (var item in mapped.entries) {
      if (item.value.text?.toLowerCase().contains(filter.toLowerCase()) ==
              true ||
          item.key.toLowerCase().contains(filter.toLowerCase())) {
        filtered[item.key] = item.value;
      }
    }

    return filtered.entries.sorted(sortNotes).map((e) => e.value).toList();
  }

  int sortNotes(MapEntry<String, BibleNote> a, MapEntry<String, BibleNote> b) {
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

  TextTheme getTextThemeByFontName(String font, TextTheme textTheme) {
    switch (font) {
      case 'Roboto':
        return GoogleFonts.robotoTextTheme(textTheme);
      case 'Roboto Serif':
        return GoogleFonts.robotoSerifTextTheme(textTheme);
      case 'Open Sans':
        return GoogleFonts.openSansTextTheme(textTheme);
      case 'Gentium Basic':
        return GoogleFonts.gentiumBookBasicTextTheme(textTheme);
      case 'Arial':
        return GoogleFonts.ptSansTextTheme(textTheme);
      default:
        return GoogleFonts.robotoTextTheme(textTheme);
    }
  }

  List<String> get availableFonts {
    return ['Roboto', 'Roboto Serif', 'Open Sans', 'Gentium Basic', 'Arial'];
  }

  String get currentBibleCodeName {
    String code = currentBibleCode.split('_').last.toUpperCase();
    switch (code) {
      case 'TB':
        return 'Terjemahan Baru';
      case 'CUV':
        return 'Chinese Union Version';
      case 'KJV':
        return 'King James Version';

      default:
        return 'Unknown'.tr();
    }
  }
}

String getBibleCodeName(String? code) {
  code = code?.split('_').last.toUpperCase() ?? '';
  if (code.contains('.')) {
    code = code.split('.').first;
  }
  switch (code) {
    case 'TB':
      return 'Terjemahan Baru';
    case 'CUV':
      return 'Chinese Union Version';
    case 'KJV':
      return 'King James Version';

    default:
      return 'Unknown'.tr();
  }
}

extension GetByPericope on List<Pericope> {
  List<Pericope> getById(int id) {
    return where((element) => element.id == id).toList();
  }
}

extension GetByBibleRef on List<BibleRef> {
  List<BibleRef> getById(int id) {
    return where((element) => element.id == id).toList();
  }
}

extension GetByPericopeParalel on List<PericopeParalel> {
  List<PericopeParalel> getById(int id) {
    return where((element) => element.id == id).toList();
  }
}

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/data.dart';
import '../../../domain/entity/faith_note/faith_note.dart';
import '../../../router/router.dart';

part 'faith_state.freezed.dart';
part 'faith_state.g.dart';

@freezed
class FaithState with _$FaithState {
  const FaithState._();
  const factory FaithState({
    @Default([]) List<int> selectedFaith,
    @Default([]) List<FaithNote> notes,
    @Default({}) Set<int> pdfLoadingList,
    @Default('Newest') String sortNotesBy,
    @Default('id') String language,
    @Default('Roboto') String defaultFont,
    @Default(1.2) double defaultTextScale,
    @Default(1.5) double defaultTextHeight,
  }) = _FaithState;

  List<String> get availableFonts {
    return ['Roboto', 'Roboto Serif', 'Open Sans', 'Gentium Basic', 'Arial'];
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

  Locale get locale {
    switch (language) {
      case 'en':
        return const Locale('en'); // English
      case 'id':
        return const Locale('id');
      case 'zh':
        return const Locale('zh');
      default:
        return const Locale('id');
    }
  }

  Future<List<FaithNote>> filteredNote(String filter) async {
    Map<String, FaithNote> mapped = {};
    Map<String, FaithNote> filtered = {};

    /// generate the title of the note first
    for (var note in notes) {
      var title = (note.verses.map((e) => e + 1)).toList().joinToString();
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

  TextTheme getTextThemeByFontName(String font) {
    switch (font) {
      case 'Roboto':
        return GoogleFonts.robotoTextTheme();
      case 'Roboto Serif':
        return GoogleFonts.robotoSerifTextTheme();
      case 'Open Sans':
        return GoogleFonts.openSansTextTheme();
      case 'Gentium Basic':
        return GoogleFonts.gentiumBookBasicTextTheme();
      case 'Arial':
        return GoogleFonts.ptSansTextTheme();
      default:
        return GoogleFonts.robotoTextTheme();
    }
  }

  int sortNotes(MapEntry<String, FaithNote> a, MapEntry<String, FaithNote> b) {
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

  factory FaithState.fromJson(Map<String, dynamic> json) =>
      _$FaithStateFromJson(json);
}

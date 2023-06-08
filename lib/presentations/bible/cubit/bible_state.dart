import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/utilities/extensions/context_ext.dart';
import '../../../domain/entity/bible_book/bible_book.dart';
import '../../../domain/entity/bible_note/bible_note.dart';
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
    @Default('b_tb') String? currentBibleCode,
    @Default([]) List<String> bibleCodes,
    Verse? currentBible,
    @Default([]) List<BibleBook> books,
    @Default([]) List<Verse> verses,
    @Default({}) Map<DateTime, Verse> histories,
    @Default([]) List<Pericope> pericopes,
    @Default([]) List<BibleNote> notes,
    @Default([]) List<PericopeParalel> pericopesParalels,
    BibleBook? currentBook,
    String? bookTitle,
    @Default([]) List<Verse> selectedVerse,
    @Default([]) List<Verse> hightlightedVerse,
    Verse? todayReading,
    DateTime? lastOpenBible,
    @Default('Roboto') String defaultFont,
    @Default(1) double defaultTextScale,
    @Default(1.5) double defaultTextHeight,
  }) = _BibleState;

  factory BibleState.fromJson(Map<String, dynamic> json) =>
      _$BibleStateFromJson(json);

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

  List<String> get availableFonts {
    return ['Roboto', 'Roboto Serif', 'Open Sans', 'Gentium Basic', 'Arial'];
  }

  String get currentBibleCodeName {
    String code = currentBibleCode?.split('_').last.toUpperCase() ?? '';
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
}

extension GetByPericope on List<Pericope> {
  Pericope? getById(int id) {
    return firstWhereOrNull((element) => element.id == id);
  }
}

extension GetByPericopeParalel on List<PericopeParalel> {
  PericopeParalel? getById(int id) {
    return firstWhereOrNull((element) => element.id == id);
  }
}

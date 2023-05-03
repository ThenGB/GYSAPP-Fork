import 'package:church/domain/entity/bible/bible.dart';
import 'package:church/domain/entity/bible_book/bible_book.dart';
import 'package:church/domain/entity/pericope_paralel/pericope_paralel.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/pericope/pericope.dart';

part 'bible_state.freezed.dart';
part 'bible_state.g.dart';

@freezed
class BibleState with _$BibleState {
  const BibleState._();
  const factory BibleState({
    String? currentBibleCode,
    @Default([]) List<String> bibleCodes,
    Bible? currentBible,
    @Default([]) List<BibleBook> books,
    @Default([]) List<Bible> bibles,
    @Default([]) List<Pericope> pericopes,
    @Default([]) List<PericopeParalel> pericopesParalels,
    BibleBook? currentBook,
    String? bookTitle,
    @Default([]) List<Bible> selectedVerse,
    @Default([]) List<Bible> hightlightedVerse,
  }) = _BibleState;

  factory BibleState.fromJson(Map<String, dynamic> json) =>
      _$BibleStateFromJson(json);
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

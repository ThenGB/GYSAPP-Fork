import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/utilities/extensions/int_ext.dart';
import '../../../domain/entity/faith_note/faith_note.dart';

part 'faith_state.freezed.dart';
part 'faith_state.g.dart';

@freezed
class FaithState with _$FaithState {
  const FaithState._();
  const factory FaithState({
    @Default([]) List<int> selectedFaith,
    @Default([]) List<FaithNote> notes,
    @Default('Newest') String sortNotesBy,
  }) = _FaithState;

  Future<List<FaithNote>> filteredNote(String filter) async {
    Map<String, FaithNote> mapped = {};
    Map<String, FaithNote> filtered = {};

    /// generate the title of the note first
    for (var note in notes) {
      var title = (note.verses.map((e) => e + 1)).toList().joinToString();
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

  int sortNotes(MapEntry<String, FaithNote> a, MapEntry<String, FaithNote> b) {
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

  factory FaithState.fromJson(Map<String, dynamic> json) =>
      _$FaithStateFromJson(json);
}

import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../domain/entity/faith_note/faith_note.dart';
import 'faith_state.dart';

class FaithCubit extends HydratedCubit<FaithState> {
  FaithCubit() : super(FaithState());

  @override
  FaithState? fromJson(Map<String, dynamic> json) {
    return FaithState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(FaithState state) {
    return state.copyWith(selectedFaith: []).toJson();
  }

  removeSelection() {
    emit(state.copyWith(selectedFaith: []));
  }

  saveNote(FaithNote data) {
    var notes = List<FaithNote>.from(state.notes);
    notes.add(data);

    emit(state.copyWith(notes: notes));
  }

  changeSortNote(String sortBy) {
    emit(state.copyWith(sortNotesBy: sortBy));
  }

  deleteNote(FaithNote data) {
    var notes = List<FaithNote>.from(state.notes);
    notes.remove(data);

    emit(state.copyWith(notes: notes));
  }

  selectVerse(int index) {
    List<int> temp = List.from(state.selectedFaith);
    if (temp.contains(index)) {
      temp.remove(index);
    } else {
      temp.add(index);
    }
    temp = temp.toSet().toList();
    emit(state.copyWith(selectedFaith: temp));
  }
}

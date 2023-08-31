import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../domain/entity/faith_note/faith_note.dart';
import 'faith_state.dart';

export 'faith_state.dart';

class FaithCubit extends HydratedCubit<FaithState> {
  FaithCubit() : super(FaithState());

  bool get isSelectingFaith => state.selectedFaith.isNotEmpty;

  @override
  FaithState? fromJson(Map<String, dynamic> json) {
    return FaithState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(FaithState state) {
    return state.copyWith(selectedFaith: []).toJson();
  }

  changeFont(String font) {
    emit(state.copyWith(defaultFont: font));
  }

  sync(FaithState faithState) {
    emit(faithState);
  }

  changeTextScale(double value) {
    emit(state.copyWith(defaultTextScale: value));
  }

  changeTextHeight(double value) {
    emit(state.copyWith(defaultTextHeight: value));
  }

  setLanguage(Locale locale) {
    emit(state.copyWith(language: locale.languageCode));
  }

  removeSelection() {
    emit(state.copyWith(selectedFaith: []));
  }

  saveNote(FaithNote data) {
    var notes = List<FaithNote>.from(state.notes);
    int index = notes.indexWhere((note) => note.id == data.id);

    if (index != -1) {
      notes[index] = data; // Replace the note with the same id
    } else {
      notes.add(data); // Add the note if it doesn't exist in the list
    }

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

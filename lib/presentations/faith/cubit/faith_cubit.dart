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

  void changeFont(String font) {
    emit(state.copyWith(defaultFont: font));
  }

  void sync(FaithState faithState) {
    emit(faithState);
  }

  void changeTextScale(double value) {
    emit(state.copyWith(defaultTextScale: value));
  }

  void changeTextHeight(double value) {
    emit(state.copyWith(defaultTextHeight: value));
  }

  void setLanguage(Locale locale) {
    emit(state.copyWith(language: locale.languageCode));
  }

  void removeSelection() {
    emit(state.copyWith(selectedFaith: []));
  }

  void saveNote(FaithNote data) {
    final notes = List<FaithNote>.from(state.notes);
    final index = notes.indexWhere((note) => note.id == data.id);

    if (index != -1) {
      notes[index] = data;
    } else {
      notes.add(data);
    }

    emit(state.copyWith(notes: notes));
  }

  void changeSortNote(String sortBy) {
    emit(state.copyWith(sortNotesBy: sortBy));
  }

  void deleteNote(FaithNote data) {
    final notes = List<FaithNote>.from(state.notes)..remove(data);
    emit(state.copyWith(notes: notes));
  }

  void selectVerse(int index) {
    var temp = List<int>.from(state.selectedFaith);
    if (temp.contains(index)) {
      temp.remove(index);
    } else {
      temp.add(index);
    }
    temp = temp.toSet().toList();
    emit(state.copyWith(selectedFaith: temp));
  }
}

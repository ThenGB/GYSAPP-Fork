import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../../components/components.dart';
import '../../../data/utilities/enums.dart';
import '../../../domain/entity/song_note/song_note.dart';
import '../../../router/router.dart';
import '../cubit/song_cubit.dart';

@RoutePage()
class SongNotesListView extends StatelessWidget {
  final SongCubit cubit;
  const SongNotesListView({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return NoteListScaffold<SongCubit, SongState, SongNote>(
      cubit: cubit,
      countOf: (state) => state.notes.length,
      sortNotesByOf: (state) => state.sortNotesBy,
      onSortSelected: cubit.changeSortNote,
      filteredOf: (state, query) => state.filteredNote(query),
      titleOf: (note) async => note.song.title ?? '',
      bodyOf: (note) {
        if (note.text == null) return '';
        return quill.Document.fromJson(
          jsonDecode(note.text!),
        ).toPlainText().trim().replaceAll('\n', ' .. ');
      },
      dateOf: (note) => note.createdDate,
      onTapNote: (note) {
        router.push(
          SongNoteRoute(
            initialData: note,
            cubit: cubit,
            mode: NoteMode.viewOnly,
            onSave: (data) {
              cubit.saveNote(data);
              router.maybePop();
            },
          ),
        );
      },
    );
  }
}

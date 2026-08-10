import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../../components/components.dart';
import '../../../data/utilities/enums.dart';
import '../../../domain/entity/bible_note/bible_note.dart';
import '../../../router/router.dart';
import '../../presentations.dart';
import '../cubit/bible_cubit.dart';

@RoutePage()
class BibleNoteListView extends StatelessWidget {
  final BibleCubit cubit;
  final String? initialSearch;
  const BibleNoteListView({
    super.key,
    required this.cubit,
    this.initialSearch,
  });

  @override
  Widget build(BuildContext context) {
    return NoteListScaffold<BibleCubit, BibleState, BibleNote>(
      cubit: cubit,
      initialSearch: initialSearch,
      countOf: (state) => state.notes.length,
      sortNotesByOf: (state) => state.sortNotesBy,
      onSortSelected: cubit.changeSortNote,
      filteredOf: (state, query) => state.filteredNote(
        query,
        (item) => cubit.getBibleTitle(item, withVerse: true),
      ),
      titleOf: (note) => cubit.getBibleTitle(note.verses, withVerse: true),
      bodyOf: (note) => quill.Document.fromJson(
        jsonDecode(note.text!),
      ).toPlainText().trim().replaceAll('\n', ' .. '),
      dateOf: (note) => note.createdDate,
      onTapNote: (note) {
        router.push(
          BibleNoteRoute(
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

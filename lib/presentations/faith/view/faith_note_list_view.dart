import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../../components/components.dart';
import '../../../data/utilities/enums.dart';
import '../../../data/utilities/extensions/int_ext.dart';
import '../../../domain/entity/faith_note/faith_note.dart';
import '../../../router/router.dart';
import '../cubit/faith_cubit.dart';

@RoutePage()
class FaithNoteListView extends StatelessWidget {
  final FaithCubit cubit;
  const FaithNoteListView({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return NoteListScaffold<FaithCubit, FaithState, FaithNote>(
      cubit: cubit,
      countOf: (state) => state.notes.length,
      sortNotesByOf: (state) => state.sortNotesBy,
      onSortSelected: cubit.changeSortNote,
      filteredOf: (state, query) => state.filteredNote(query),
      titleOf: (note) async =>
          (note.verses.map((e) => e + 1)).toList().joinToString(),
      bodyOf: (note) => quillPlainText(note.text),
      dateOf: (note) => note.createdDate,
      onTapNote: (note) {
        router.push(
          FaithNoteRoute(
            initialData: note,
            cubit: cubit,
            mode: NoteMode.viewOnly,
            onSave: (data) {
              cubit.saveNote(data);
              router.maybePop();
              router.push(FaithNoteListRoute(cubit: cubit));
            },
          ),
        );
      },
    );
  }
}

/// Kept top-level so the wrapper stays a thin adapter: quill delta JSON →
/// readable one-line preview.
String quillPlainText(String? text) {
  if (text == null) return '';
  try {
    return quill.Document.fromJson(
      jsonDecode(text),
    ).toPlainText().trim().replaceAll('\n', ' .. ');
  } catch (_) {
    return '';
  }
}

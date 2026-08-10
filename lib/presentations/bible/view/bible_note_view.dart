import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../components/components.dart';
import '../../../data/utilities/enums.dart';
import '../../../domain/entity/bible_note/bible_note.dart';
import '../cubit/bible_cubit.dart';

@RoutePage()
class BibleNoteView extends StatelessWidget {
  final BibleNote initialData;
  final BibleCubit cubit;
  final NoteMode mode;
  final Function(BibleNote data) onSave;

  const BibleNoteView({
    super.key,
    required this.initialData,
    required this.cubit,
    required this.mode,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return NoteEditorScaffold<BibleCubit, BibleState, BibleNote>(
      cubit: cubit,
      data: initialData,
      initialMode: mode,
      textOf: (data) => data.text,
      withText: (data, text) => data.copyWith(text: text),
      titleBuilder: (context, data) => FutureBuilder<String>(
        future: cubit.getBibleTitle(data.verses, withVerse: true),
        builder: (context, snapshot) => Text(
          snapshot.data ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onSave: (data) => onSave(data),
      onDelete: (data) => cubit.deleteNote(initialData),
    );
  }
}

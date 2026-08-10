import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../components/components.dart';
import '../../../data/utilities/enums.dart';
import '../../../data/utilities/extensions/int_ext.dart';
import '../../../domain/entity/faith_note/faith_note.dart';
import '../cubit/faith_cubit.dart';

@RoutePage()
class FaithNoteView extends StatelessWidget {
  final FaithNote initialData;
  final FaithCubit cubit;
  final NoteMode mode;
  final Function(FaithNote data) onSave;

  const FaithNoteView({
    super.key,
    required this.initialData,
    required this.cubit,
    required this.mode,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return NoteEditorScaffold<FaithCubit, FaithState, FaithNote>(
      cubit: cubit,
      data: initialData,
      initialMode: mode,
      textOf: (data) => data.text,
      withText: (data, text) => data.copyWith(text: text),
      titleBuilder: (context, data) => Text(
        (data.verses.map((e) => e + 1)).toList().joinToString(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onSave: (data) => onSave(data),
      onDelete: (data) => cubit.deleteNote(initialData),
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../components/components.dart';
import '../../../data/utilities/enums.dart';
import '../../../domain/entity/song_note/song_note.dart';
import '../cubit/song_cubit.dart';

@RoutePage()
class SongNoteView extends StatelessWidget {
  final SongNote initialData;
  final SongCubit cubit;
  final NoteMode mode;
  final Function(SongNote data) onSave;

  const SongNoteView({
    super.key,
    required this.initialData,
    required this.cubit,
    required this.mode,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return NoteEditorScaffold<SongCubit, SongState, SongNote>(
      cubit: cubit,
      data: initialData,
      initialMode: mode,
      textOf: (data) => data.text,
      withText: (data, text) => data.copyWith(text: text),
      titleBuilder: (context, data) => Text(
        data.song.title ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onSave: (data) => onSave(data),
      onDelete: (data) => cubit.deleteNote(initialData),
    );
  }
}

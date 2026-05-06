import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../../data/utilities/enums.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../domain/entity/song_note/song_note.dart';
import '../../../router/router.dart';
import '../cubit/song_cubit.dart';

@RoutePage()
class SongNoteView extends StatefulWidget {
  final SongNote initialData;
  final SongCubit cubit;
  final NoteMode mode;
  final Function(SongNote data) onSave;

  const SongNoteView(
      {super.key,
      required this.initialData,
      required this.cubit,
      required this.mode,
      required this.onSave});

  @override
  State<SongNoteView> createState() => _SongNoteViewState();
}

class _SongNoteViewState extends State<SongNoteView> {
  bool get isNewNote => data.text == null;
  late quill.QuillController controller = quill.QuillController(
    document: data.text == null
        ? quill.Document()
        : quill.Document.fromJson(
            jsonDecode(data.text!),
          ),
    selection: TextSelection.collapsed(offset: 0),
  );
  late SongNote data = widget.initialData;
  bool forceClose = false;
  Future<void> onSave() async {
    forceClose = true;
    data =
        data.copyWith(text: jsonEncode(controller.document.toDelta().toJson()));
    widget.onSave(data);
  }

  late FocusNode focusNode = FocusNode();
  late ScrollController scrollController = ScrollController();
  late NoteMode mode = widget.mode;

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.readOnly = mode == NoteMode.viewOnly;
    return BlocProvider<SongCubit>.value(
      value: widget.cubit,
      child: BlocBuilder<SongCubit, SongState>(
        // ignore: deprecated_member_use
        builder: (context, state) => WillPopScope(
          onWillPop: () async {
            if (forceClose) return true;
            if (!isNewNote && mode == NoteMode.write) {
              var oldController = controller;
              oldController.dispose();
              controller = quill.QuillController(
                document: quill.Document.fromJson(
                  jsonDecode(data.text!),
                ),
                selection: TextSelection.collapsed(offset: 0),
              );
              mode = NoteMode.viewOnly;
              setState(() {});
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: context.colorScheme.surface,
            appBar: AppBar(
              title: Text(data.song.title ?? ''),
              actions: [
                if (mode == NoteMode.write) ...[
                  // IconButton(
                  //   onPressed: () {
                  //     mode = NoteMode.viewOnly;
                  //     setState(() {});
                  //   },
                  //   icon: Icon(Icons.visibility_outlined),
                  // ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: context.colorScheme.primaryContainer,
                      foregroundColor: context.colorScheme.onPrimaryContainer,
                    ),
                    onPressed: onSave,
                    icon: Icon(Icons.save),
                    label: Text('Save'),
                  )
                ] else ...[
                  IconButton(
                    onPressed: () async {
                      var isConfirmed = await context.showConfirmation(
                          'Are you sure want to delete?'.tr());
                      if (isConfirmed) {
                        router.maybePop();
                        widget.cubit.deleteNote(widget.initialData);
                      }
                    },
                    icon: Icon(Icons.delete),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: context.colorScheme.primaryContainer,
                      foregroundColor: context.colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () {
                      setState(() {
                        mode = NoteMode.write;
                      });
                      // router.maybePop();
                      // router.push(
                      //   SongNoteRoute(
                      //     initialData: widget.initialData,
                      //     cubit: widget.cubit,
                      //     mode: NoteMode.write,
                      //     onSave: widget.onSave,
                      //   ),
                      // );
                    },
                    icon: Icon(Icons.edit),
                    label: Text('Edit'),
                  )
                ],
                SizedBox(
                  width: 16,
                ),
              ],
            ),
            body: Container(
              padding: EdgeInsets.all(16),
              child: quill.QuillEditor(
                controller: controller,
                configurations: quill.QuillEditorConfigurations(
                  showCursor: mode == NoteMode.write,
                  padding: EdgeInsets.zero,
                  expands: true,
                  scrollable: true,
                  autoFocus: mode == NoteMode.write,
                ),
                focusNode: focusNode,
                scrollController: scrollController,
              ),
            ),
            bottomNavigationBar: mode == NoteMode.viewOnly
                ? null
                : Container(
                    margin: context.mediaQuery.viewInsets +
                        context.mediaQuery.viewPadding,
                    child: quill.QuillToolbar.simple(
                      controller: controller,
                      configurations:
                          const quill.QuillSimpleToolbarConfigurations(),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}


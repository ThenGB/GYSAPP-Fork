import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../../data/utilities/enums.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../domain/entity/bible_note/bible_note.dart';
import '../../../router/router.dart';
import '../../presentations.dart';

@RoutePage()
class BibleNoteView extends StatefulWidget {
  final BibleNote initialData;
  final BibleCubit cubit;
  final NoteMode mode;
  final Function(BibleNote data) onSave;

  const BibleNoteView(
      {super.key,
      required this.initialData,
      required this.cubit,
      required this.mode,
      required this.onSave});

  @override
  State<BibleNoteView> createState() => _BibleNoteViewState();
}

class _BibleNoteViewState extends State<BibleNoteView> {
  bool get isNewNote => data.text == null;
  late quill.QuillController controller = quill.QuillController(
    document: data.text == null
        ? quill.Document()
        : quill.Document.fromJson(
            jsonDecode(data.text!),
          ),
    selection: TextSelection.collapsed(offset: 0),
  );
  late BibleNote data = widget.initialData;
  bool forceClose = false;
  onSave() async {
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
    return BlocProvider<BibleCubit>.value(
      value: widget.cubit,
      child: BlocBuilder<BibleCubit, BibleState>(
        builder: (context, state) => WillPopScope(
          onWillPop: () async {
            if (forceClose) return true;
            if (!isNewNote && mode == NoteMode.write) {
              mode = NoteMode.viewOnly;
              var oldController = controller;
              oldController.dispose();
              controller = quill.QuillController(
                document: quill.Document.fromJson(
                  jsonDecode(data.text!),
                ),
                selection: TextSelection.collapsed(offset: 0),
              );

              setState(() {});
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: context.colorScheme.background,
            appBar: AppBar(
              title: FutureBuilder(
                future:
                    widget.cubit.getBibleTitle(data.verses, withVerse: true),
                builder: (context, snapshot) => Text(snapshot.data ?? ''),
              ),
              actions: [
                if (mode == NoteMode.write) ...[
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
                        router.pop();
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
                      // router.pop();
                      // router.push(
                      //   BibleNoteRoute(
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
                configurations: quill.QuillEditorConfigurations(
                  showCursor: mode == NoteMode.write,
                  padding: EdgeInsets.zero,
                  expands: true,
                  scrollable: true,
                  autoFocus: true,
                  controller: controller,
                  readOnly: mode == NoteMode.viewOnly,
                ),
                focusNode: focusNode,
                scrollController: scrollController,
              ),
            ),
            bottomNavigationBar: mode == NoteMode.viewOnly
                ? null
                : Container(
                    margin: context.mediaQuery.viewPadding +
                        context.mediaQuery.viewInsets,
                    child: quill.QuillToolbar.simple(
                      configurations: quill.QuillSimpleToolbarConfigurations(
                        controller: controller,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

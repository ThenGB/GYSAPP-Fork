import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../../data/utilities/enums.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/extensions/int_ext.dart';
import '../../../domain/entity/faith_note/faith_note.dart';
import '../../../router/router.dart';
import '../cubit/faith_cubit.dart';
import '../cubit/faith_state.dart';

@RoutePage()
class FaithNoteView extends StatefulWidget {
  final FaithNote initialData;
  final FaithCubit cubit;
  final NoteMode mode;
  final Function(FaithNote data) onSave;

  const FaithNoteView(
      {super.key,
      required this.initialData,
      required this.cubit,
      required this.mode,
      required this.onSave});

  @override
  State<FaithNoteView> createState() => FaithNoteViewState();
}

class FaithNoteViewState extends State<FaithNoteView> {
  late quill.QuillController controller = quill.QuillController(
    document: data.text == null
        ? quill.Document()
        : quill.Document.fromJson(
            jsonDecode(data.text!),
          ),
    selection: TextSelection.collapsed(offset: 0),
  );
  late FaithNote data = widget.initialData;

  onSave() async {
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
    return BlocProvider<FaithCubit>.value(
      value: widget.cubit,
      child: BlocBuilder<FaithCubit, FaithState>(
        builder: (context, state) => Scaffold(
          backgroundColor: context.colorScheme.background,
          appBar: AppBar(
            title:
                Text((data.verses.map((e) => e + 1)).toList().joinToString()),
            actions: [
              if (mode == NoteMode.write) ...[
                IconButton(
                  onPressed: () {
                    mode = NoteMode.viewOnly;
                    setState(() {});
                  },
                  icon: Icon(Icons.visibility_outlined),
                ),
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
                    var isConfirmed = await context
                        .showConfirmation('Are you sure want to delete?'.tr());
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
                    //   FaithNoteRoute(
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
              locale: context.locale,
              showCursor: mode == NoteMode.write,
              padding: EdgeInsets.zero,
              expands: true,
              focusNode: focusNode,
              scrollController: scrollController,
              scrollable: true,
              autoFocus: true,
              controller: controller,
              readOnly: mode == NoteMode.viewOnly,
            ),
          ),
          bottomNavigationBar: mode == NoteMode.viewOnly
              ? null
              : Container(
                  margin: context.mediaQuery.viewInsets,
                  child: quill.QuillToolbar.basic(
                    locale: context.locale,
                    controller: controller,
                  ),
                ),
        ),
      ),
    );
  }
}

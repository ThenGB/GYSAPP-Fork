import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../../router/router.dart';
import '../../presentations.dart';

@RoutePage()
class FaithNoteView extends StatefulWidget {
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
  State<FaithNoteView> createState() => FaithNoteViewState();
}

class FaithNoteViewState extends State<FaithNoteView> {
  bool get isNewNote => data.text == null;
  late quill.QuillController controller = quill.QuillController(
    document: data.text == null
        ? quill.Document()
        : quill.Document.fromJson(jsonDecode(data.text!)),
    selection: TextSelection.collapsed(offset: 0),
  );
  late FaithNote data = widget.initialData;

  Future<void> onSave() async {
    forceClose = true;
    data = data.copyWith(
      text: jsonEncode(controller.document.toDelta().toJson()),
    );
    widget.onSave(data);
  }

  bool forceClose = false;

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
    return BlocProvider<FaithCubit>.value(
      value: widget.cubit,
      child: BlocBuilder<FaithCubit, FaithState>(
        // ignore: deprecated_member_use
        builder: (context, state) => WillPopScope(
          onWillPop: () async {
            if (forceClose) return true;
            if (!isNewNote && mode == NoteMode.write) {
              var oldController = controller;
              oldController.dispose();
              controller = quill.QuillController(
                document: quill.Document.fromJson(jsonDecode(data.text!)),
                selection: TextSelection.collapsed(offset: 0),
              );
              mode = NoteMode.viewOnly;
              setState(() {});
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: context.colorScheme.surfaceContainerLowest,
            appBar: AppBar(
              backgroundColor: context.colorScheme.surfaceContainerLowest,
              shape: Border(
                bottom: BorderSide(
                  color: context.colorScheme.outlineVariant.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
              title: Text(
                (data.verses.map((e) => e + 1)).toList().joinToString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                if (mode == NoteMode.write) ...[
                  // IconButton(
                  //   onPressed: () {
                  //     mode = NoteMode.viewOnly;
                  //     setState(() {});
                  //   },
                  //   icon: Icon(Icons.visibility_outlined),
                  // ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: onSave,
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Save'),
                  ),
                ] else ...[
                  IconButton(
                    onPressed: () async {
                      var isConfirmed = await context.showConfirmation(
                        'Are you sure want to delete?'.tr(),
                      );
                      if (isConfirmed) {
                        router.maybePop();
                        widget.cubit.deleteNote(widget.initialData);
                      }
                    },
                    icon: Icon(Icons.delete),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        mode = NoteMode.write;
                      });
                      // router.maybePop();
                      // router.push(
                      //   FaithNoteRoute(
                      //     initialData: widget.initialData,
                      //     cubit: widget.cubit,
                      //     mode: NoteMode.write,
                      //     onSave: widget.onSave,
                      //   ),
                      // );
                    },
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit'),
                  ),
                ],
                SizedBox(width: 16),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.colorScheme.surfaceContainerLowest,
                      context.colorScheme.surfaceContainerLow,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.colorScheme.outlineVariant.withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: quill.QuillEditor(
                    focusNode: focusNode,
                    scrollController: scrollController,
                    controller: controller,
                    config: quill.QuillEditorConfig(
                      showCursor: mode == NoteMode.write,
                      padding: EdgeInsets.zero,
                      expands: true,
                      scrollable: true,
                      autoFocus: mode == NoteMode.write,
                    ),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: mode == NoteMode.viewOnly
                ? null
                : Builder(
                    builder: (inner) {
                      final insets = MediaQuery.viewInsetsOf(inner);
                      return Container(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: context.colorScheme.outlineVariant.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ),
                    ),
                    margin:
                        insets +
                        context.mediaQuery.viewPadding,
                    child: quill.QuillSimpleToolbar(
                      controller: controller,
                      config: const quill.QuillSimpleToolbarConfig(),
                    ),
                  );
                },
              ),
          ),
        ),
      ),
    );
  }
}

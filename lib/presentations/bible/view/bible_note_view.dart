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

  const BibleNoteView({
    super.key,
    required this.initialData,
    required this.cubit,
    required this.mode,
    required this.onSave,
  });

  @override
  State<BibleNoteView> createState() => _BibleNoteViewState();
}

class _BibleNoteViewState extends State<BibleNoteView> {
  bool get isNewNote => data.text == null;
  late quill.QuillController controller = quill.QuillController(
    document: data.text == null
        ? quill.Document()
        : quill.Document.fromJson(jsonDecode(data.text!)),
    selection: TextSelection.collapsed(offset: 0),
  );
  late BibleNote data = widget.initialData;
  bool forceClose = false;
  Future<void> onSave() async {
    forceClose = true;
    data = data.copyWith(
      text: jsonEncode(controller.document.toDelta().toJson()),
    );
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
    return BlocProvider<BibleCubit>.value(
      value: widget.cubit,
      child: BlocBuilder<BibleCubit, BibleState>(
        // ignore: deprecated_member_use
        builder: (context, state) => WillPopScope(
          onWillPop: () async {
            if (forceClose) return true;
            if (!isNewNote && mode == NoteMode.write) {
              mode = NoteMode.viewOnly;
              var oldController = controller;
              oldController.dispose();
              controller = quill.QuillController(
                document: quill.Document.fromJson(jsonDecode(data.text!)),
                selection: TextSelection.collapsed(offset: 0),
              );

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
              title: FutureBuilder(
                future: widget.cubit.getBibleTitle(
                  data.verses,
                  withVerse: true,
                ),
                builder: (context, snapshot) => Text(
                  snapshot.data ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              actions: [
                if (mode == NoteMode.write) ...[
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
                      //   BibleNoteRoute(
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
                    controller: controller,
                    config: quill.QuillEditorConfig(
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
              ),
            ),
            bottomNavigationBar: mode == NoteMode.viewOnly
                ? null
                // Builder isolates viewInsets read so only the toolbar
                // subtree rebuilds on keyboard, not the entire page.
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
                    margin: context.mediaQuery.viewPadding + insets,
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

import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../data/utilities/enums.dart';
import '../../data/utilities/extensions/context_ext.dart';
import '../themes/app_theme_extras.dart';

/// Shared quill note editor used by the Bible, Faith, and Hymnal note
/// systems. The three legacy editors were identical apart from the title
/// resolution and the note type; this widget keeps that shared behavior in
/// one place while the storage models stay untouched.
class NoteEditorScaffold<C extends StateStreamable<S>, S, T>
    extends StatefulWidget {
  const NoteEditorScaffold({
    super.key,
    required this.cubit,
    required this.data,
    required this.initialMode,
    required this.textOf,
    required this.withText,
    required this.titleBuilder,
    required this.onSave,
    required this.onDelete,
  });

  final C cubit;
  final T data;
  final NoteMode initialMode;

  /// Returns the stored quill JSON (null = new note).
  final String? Function(T data) textOf;

  /// Returns a copy of the note with a new text payload.
  final T Function(T data, String text) withText;

  /// Page title (e.g. the bible reference / faith verse / song title).
  final Widget Function(BuildContext context, T data) titleBuilder;

  final void Function(T data) onSave;
  final void Function(T data) onDelete;

  @override
  State<NoteEditorScaffold<C, S, T>> createState() =>
      _NoteEditorScaffoldState<C, S, T>();
}

class _NoteEditorScaffoldState<C extends StateStreamable<S>, S, T>
    extends State<NoteEditorScaffold<C, S, T>> {
  bool get isNewNote => widget.textOf(data) == null;

  late T data = widget.data;
  late NoteMode mode = widget.initialMode;
  bool forceClose = false;

  late quill.QuillController controller = quill.QuillController(
    document: widget.textOf(data) == null
        ? quill.Document()
        : quill.Document.fromJson(jsonDecode(widget.textOf(data)!)),
    selection: const TextSelection.collapsed(offset: 0),
  );

  late FocusNode focusNode = FocusNode();
  late ScrollController scrollController = ScrollController();

  Future<void> onSave() async {
    forceClose = true;
    data = widget.withText(
      data,
      jsonEncode(controller.document.toDelta().toJson()),
    );
    widget.onSave(data);
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.readOnly = mode == NoteMode.viewOnly;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (forceClose) return true;
        if (!isNewNote && mode == NoteMode.write) {
          mode = NoteMode.viewOnly;
          final oldController = controller;
          oldController.dispose();
          controller = quill.QuillController(
            document: quill.Document.fromJson(
              jsonDecode(widget.textOf(data)!),
            ),
            selection: const TextSelection.collapsed(offset: 0),
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
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          title: widget.titleBuilder(context, data),
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
                label: Text('Save'.tr()),
              ),
            ] else ...[
              IconButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final isConfirmed = await context.showConfirmation(
                    'Are you sure want to delete?'.tr(),
                  );
                  if (!mounted) return;
                  if (isConfirmed) {
                    widget.onDelete(data);
                    navigator.maybePop();
                  }
                },
                icon: const Icon(Icons.delete),
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
                },
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text('Edit'.tr()),
              ),
            ],
            const SizedBox(width: 16),
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
              borderRadius: context.appRadius(8),
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
            // Builder isolates viewInsets so only the toolbar subtree
            // rebuilds on keyboard, not the entire page.
            : Builder(
                builder: (inner) {
                  final insets = MediaQuery.viewInsetsOf(inner);
                  return Container(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: context.colorScheme.outlineVariant
                              .withValues(alpha: 0.55),
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
    );
  }
}

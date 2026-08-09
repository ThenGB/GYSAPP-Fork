// ignore_for_file: use_build_context_synchronously

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../../router/router.dart';
import '../bible.dart';

class SelectedVerseMenu extends StatelessWidget {
  const SelectedVerseMenu({
    super.key,
    required this.verses,
    required this.viewPadding,
  });

  final double viewPadding;
  final List<Verse> verses;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Material(
            elevation: 8,
            shadowColor: colors.shadow.withValues(alpha: 0.22),
            color: colors.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
              borderRadius: context.appRadius(20),
              side: BorderSide(
                color: colors.primary.withValues(alpha: 0.16),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.fromLTRB(14, 10, 10, 10 + viewPadding * 0.1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: context.appRadius(11),
                        ),
                        child: Text(
                          '${verses.length}',
                          style: context.textTheme.labelLarge?.copyWith(
                            color: colors.onPrimaryContainer,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FutureBuilder<String>(
                          future: context.read<BibleCubit>().getBibleTitle(
                            verses,
                            withVerse: true,
                          ),
                          builder: (context, snapshot) => Text(
                            snapshot.data ?? '—',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close'.tr(),
                        visualDensity: VisualDensity.compact,
                        onPressed: context.read<BibleCubit>().removeSelection,
                        icon: const Icon(Icons.close_rounded, size: 19),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _SelectionAction(
                          icon: Icons.note_add_outlined,
                          label: 'Note'.tr(),
                          onPressed: () => _openNote(context),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: _SelectionAction(
                          icon: Icons.share_outlined,
                          label: 'Share'.tr(),
                          onPressed: () => _share(context),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: _SelectionAction(
                          icon: Icons.copy_outlined,
                          label: 'Copy'.tr(),
                          onPressed: () => _copy(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final color in const [
                          Color(0xffFD7F7F),
                          Color(0xffFF9783),
                          Color(0xffFFCE55),
                          Color(0xffBCEB8A),
                          Color(0xffC8FFF1),
                          Color(0xffAED3FF),
                          Color(0xffFFC9E7),
                          Color(0xffE7E7E7),
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 7),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                context.read<BibleCubit>().hightLightBible(
                                  verses
                                      .map((verse) => verse.copyWith(color: color))
                                      .toList(),
                                );
                                context.read<BibleCubit>().removeSelection();
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                  border: Border.all(
                                    color: colors.outline.withValues(alpha: 0.18),
                                  ),
                                ),
                                child: _isHighlightActive(context, color)
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 17,
                                        color: Colors.black87,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isHighlightActive(BuildContext context, Color color) {
    final state = context.watch<BibleCubit>().state;
    final selectedIds = state.selectedVerse.map((verse) => verse.id).toSet();
    return state.hightlightedVerse
        .where((verse) => selectedIds.contains(verse.id))
        .map((verse) => verse.color)
        .any((candidate) => candidate == color);
  }

  void _openNote(BuildContext context) {
    final cubit = context.read<BibleCubit>();
    router.push(
      BibleNoteRoute(
        initialData: BibleNote.empty(cubit.state.selectedVerse),
        cubit: cubit,
        mode: NoteMode.write,
        onSave: (data) {
          cubit.saveNote(data);
          router.maybePop();
          router.push(BibleNoteListRoute(cubit: cubit));
        },
      ),
    );
  }

  Future<String> _selectedText(BuildContext context) async {
    final sorted = verses.sorted((a, b) => a.verseId.compareTo(b.verseId));
    final title = await context.read<BibleCubit>().getBibleTitle(
      verses,
      withVerse: true,
    );
    final json = await AppConfigStore.jsonConfig('footer_copied_text');
    final footer = json[context.locale.languageCode]?.toString() ?? '';
    final buffer = StringBuffer(title);
    for (final bible in sorted) {
      buffer.write('\n${bible.verseId}. ${bible.verse ?? ''}');
    }
    if (footer.trim().isNotEmpty) buffer.write('\n\n$footer');
    return buffer.toString();
  }

  Future<void> _share(BuildContext context) async {
    final text = await _selectedText(context);
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (_) {
      // Sharing is optional on unsupported platforms.
    }
  }

  Future<void> _copy(BuildContext context) async {
    final text = await _selectedText(context);
    await Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.cancel();
    Fluttertoast.showToast(msg: 'Copied!'.tr());
  }
}

class _SelectionAction extends StatelessWidget {
  const _SelectionAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(icon, size: 16),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, maxLines: 1),
      ),
    );
  }
}

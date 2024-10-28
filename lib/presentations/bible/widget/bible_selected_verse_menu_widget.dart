// ignore_for_file: use_build_context_synchronously

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../../router/router.dart';
import '../bible.dart';

class SelectedVerseMenu extends StatelessWidget {
  final double viewPadding;
  final List<Verse> verses;
  const SelectedVerseMenu({
    super.key,
    required this.verses,
    required this.viewPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(blurRadius: 160, color: Colors.black.withOpacity(.2)),
        ],
        color: context.colorScheme.background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // DragHandler(),
          Row(
            children: [
              Expanded(
                child: FutureBuilder(
                    future: context
                        .read<BibleCubit>()
                        .getBibleTitle(verses, withVerse: true),
                    builder: (context, snapshot) => Text(
                          snapshot.data ?? '---',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )),
              ),
              IconButton(
                icon: Icon(Icons.close),
                visualDensity: VisualDensity.compact,
                onPressed: context.read<BibleCubit>().removeSelection,
              ),
            ],
          ),
          SizedBox(
            height: 12,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // if (verses.length == 1)
                //   TextButton(
                //       style: TextButton.styleFrom(
                //         backgroundColor: context.colorScheme.primaryContainer,
                //         foregroundColor: context.colorScheme.onPrimaryContainer,
                //       ),
                //       onPressed: () {
                //         context.read<BibleCubit>().modifyBookmark(verses.first);
                //       },
                //       child: Text(
                //           '${(context.read<BibleCubit>().state.bookmarks.contains(verses.first) ? 'Remove' : 'Add')} bookmark'
                //               .tr())),
                // SizedBox(
                //   width: 8,
                // ),
                TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: context.colorScheme.primaryContainer,
                      foregroundColor: context.colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () {
                      router.push(BibleNoteRoute(
                        initialData: BibleNote.empty(
                            context.read<BibleCubit>().state.selectedVerse),
                        cubit: context.read<BibleCubit>(),
                        mode: NoteMode.write,
                        onSave: (data) {
                          context.read<BibleCubit>().saveNote(data);
                          router.maybePop();
                          router
                              .push(BibleNoteListRoute(cubit: context.read()));
                        },
                      ));
                    },
                    child: Text('Note'.tr())),
                SizedBox(
                  width: 8,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: context.colorScheme.primaryContainer,
                    foregroundColor: context.colorScheme.onPrimaryContainer,
                  ),
                  onPressed: () async {
                    String text = '';
                    var bibles =
                        verses.sorted((a, b) => a.verseId.compareTo(b.verseId));
                    var title = await context
                        .read<BibleCubit>()
                        .getBibleTitle(verses, withVerse: true);
                    var json =
                        await FirebaseUtils.jsonConfig('footer_copied_text');
                    var footer = json[context.locale.languageCode];
                    text = title;
                    if (bibles.length > 1) {
                      text += ' : ${bibles.first.verseId}';
                      text += ' - ';
                      text += '${bibles.last.verseId}';
                    }
                    for (var bible in bibles) {
                      var verse = bible.verse ?? '';
                      var number = bible.verseId;
                      text += '\n$number. $verse';
                    }
                    text += '\n\n$footer';
                    Share.share(text);
                  },
                  child: Text(
                    'Share'.tr(),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: context.colorScheme.primaryContainer,
                      foregroundColor: context.colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () async {
                      String text = '';
                      var bibles = verses
                          .sorted((a, b) => a.verseId.compareTo(b.verseId));
                      var title = await context
                          .read<BibleCubit>()
                          .getBibleTitle(verses, withVerse: true);
                      var json =
                          await FirebaseUtils.jsonConfig('footer_copied_text');
                      var footer = json[context.locale.languageCode];
                      text = title;
                      for (var bible in bibles) {
                        var verse = bible.verse ?? '';
                        var number = bible.verseId;
                        text += '\n$number. $verse';
                      }
                      text += '\n\n$footer';
                      await Clipboard.setData(ClipboardData(text: text));
                      Fluttertoast.cancel();
                      Fluttertoast.showToast(msg: 'Copied!'.tr());
                    },
                    child: Text('Copy'.tr())),
              ],
            ),
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 8,
              children: [
                ...[
                  Color(0xffFD7F7F),
                  Color(0xffFF9783),
                  Color(0xffFFCE55),
                  Color(0xffBCEB8A),
                  Color(0xffC8FFF1),
                  Color(0xffAED3FF),
                  Color(0xffFFC9E7),
                  Color(0xffE7E7E7),
                ].map(
                  (v) => InkWell(
                    onTap: () {
                      context.read<BibleCubit>().hightLightBible(
                            verses.map((e) => e.copyWith(color: v)).toList(),
                          );
                      context.read<BibleCubit>().removeSelection();
                    },
                    child: CircleAvatar(
                      backgroundColor: v,
                      child: context
                              .watch<BibleCubit>()
                              .state
                              .hightlightedVerse
                              .where((element) => context
                                  .read<BibleCubit>()
                                  .state
                                  .selectedVerse
                                  .map((e) => e.id)
                                  .contains(element.id))
                              .map((e) => e.color)
                              .any((element) => element == v)
                          ? Icon(Icons.check)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8 + 16 + viewPadding),
        ],
      ),
    );
  }
}

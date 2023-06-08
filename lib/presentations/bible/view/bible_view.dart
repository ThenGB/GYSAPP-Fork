// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../../components/widgets/drag_handler.dart';
import '../../../components/widgets/section.dart';
import '../../../data/utilities/enums.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/extensions/datetime_ext.dart';
import '../../../data/utilities/firebase_utils.dart';
import '../../../data/utilities/variables/assets.dart';
import '../../../domain/entity/bible_note/bible_note.dart';
import '../../../domain/entity/verse/verse.dart';
import '../../../router/router.dart';
import '../../settings/view/settings_view.dart';
import '../cubit/bible_cubit.dart';
import '../widget/bible_select_widget.dart';
import '../widget/bible_setting_widget.dart';

@RoutePage()
class BibleView extends StatefulWidget {
  const BibleView({super.key});

  @override
  State<BibleView> createState() => _BibleViewState();
}

class _BibleViewState extends State<BibleView> {
  late ScrollController scrollController = ScrollController();
  onTapSelectBible(BuildContext context) async {
    log('onTapSelectBible');
    context.read<BibleCubit>().getBibles();
    var bibleCodes = context
        .read<BibleCubit>()
        .state
        .bibleCodes
        .map((e) => e.split('.').first.toUpperCase())
        .toList();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BibleSelectWidget(
        bibleCodes: bibleCodes,
        onTap: (index) async {
          await context.read<BibleCubit>().selectBibleCode(index);
          router.pop();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  late List<GlobalKey<VerseWidgetState>> verseKeys = List.generate(
      context.read<BibleCubit>().state.verses.length,
      (index) => GlobalKey<VerseWidgetState>());

  scrollToVerse(int verseIndex, bool playAnimation) async {
    Future.delayed(kThemeAnimationDuration, () async {
      log(verseIndex.toString(), name: 'Scroll to');
      RenderBox? verseBox = verseKeys[verseIndex]
          .currentContext
          ?.findRenderObject() as RenderBox?;
      // double verseHeight = verseBox?.size.height ?? 0;
      if (verseBox == null) return;
      // Scroll to the position of the vverse
      await Scrollable.ensureVisible(
        verseKeys[verseIndex].currentContext!,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
      if (playAnimation) {
        verseKeys[verseIndex].currentState?.playAnimation();
      }
      // scrollController.animateTo(
      //   verseBox.localToGlobal(Offset.zero).dy,
      //   duration: Duration(milliseconds: 500),
      //   curve: Curves.easeInOut,
      // );
    });
  }

  openSettings() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      builder: (c) => BlocProvider<BibleCubit>.value(
        value: context.read(),
        child: BlocBuilder<BibleCubit, BibleState>(
          builder: (context, state) => BibleSettingWidget(
            selectedFont: state.defaultFont,
            availableFonts: state.availableFonts,
            textHeight: state.defaultTextHeight,
            textScale: state.defaultTextScale,
            onTextHeightChanged: (value) {
              context.read<BibleCubit>().changeTextHeight(value);
            },
            onTextScaleChanged: (value) {
              context.read<BibleCubit>().changeTextScale(value);
            },
            onFontSelected: (font) {
              context.read<BibleCubit>().changeFont(font);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BibleCubit, BibleState>(
      listenWhen: (previous, current) {
        return previous.verses.length != current.verses.length;
      },
      listener: (context, state) {
        verseKeys = List.generate(state.verses.length, (index) => GlobalKey());
      },
      child: BlocBuilder<BibleCubit, BibleState>(
        builder: (context, state) => Scaffold(
          bottomSheet: AnimatedSize(
            duration: kThemeAnimationDuration,
            child: state.selectedVerse.isEmpty
                ? SizedBox(
                    width: double.infinity,
                  )
                : SelectedVerseMenu(),
          ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Container(
              constraints: BoxConstraints(
                maxWidth: context.mediaQuery.size.width / 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            strokeAlign: BorderSide.strokeAlignCenter,
                            width: 1,
                            color: context.theme.disabledColor,
                          ),
                          backgroundColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(100),
                            ),
                          )),
                      onPressed: () {
                        router.push(BibleListRoute(
                          books: state.books,
                          getBibles: (bookId, chapterId) async {
                            if (bookId == null || chapterId == null) {
                              return [];
                            }
                            return await context
                                .read<BibleCubit>()
                                .getVersesByBook(bookId, chapterId);
                          },
                          onSelected: (verse) async {
                            await context.read<BibleCubit>().getContent(verse);
                            router.pop();
                            await context
                                .read<BibleCubit>()
                                .saveToHistory(verse);

                            scrollToVerse(verse.verseId - 1, true);
                          },
                        ));
                      },
                      child: FutureBuilder(
                        future: context
                            .read<BibleCubit>()
                            .getBibleTitle([state.currentBible]),
                        builder: (context, snapshot) => Column(
                          children: [
                            Text(
                              snapshot.data ?? '',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PopupMenuButton<int>(
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        context.read<BibleCubit>().selectBibleCode(value);
                      },
                      itemBuilder: (context) =>
                          state.bibleCodes.asMap().entries.map((e) {
                        var code = e.value.split('.').first;
                        var index = e.key;
                        return PopupMenuItem(
                          value: index,
                          child: Text(
                            state.getBibleCodeName(code),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(),
                          ),
                        );
                      }).toList(),
                      child: IgnorePointer(
                        ignoring: true,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              side: BorderSide(
                                strokeAlign: BorderSide.strokeAlignCenter,
                                width: 1,
                                color: context.theme.disabledColor,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(100),
                                ),
                              )),
                          onPressed: () {},
                          child: Text(
                            state.currentBibleCode
                                    ?.split('_')
                                    .last
                                    .toUpperCase() ??
                                '',
                            style: TextStyle(
                              color: null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // AnimatedCrossFade(
              //   alignment: Alignment.center,
              //   duration: kThemeAnimationDuration,
              //   crossFadeState: state.selectedVerse.length != 1
              //       ? CrossFadeState.showFirst
              //       : CrossFadeState.showSecond,
              //   firstChild: const SizedBox(
              //     width: 10,
              //     height: 48,
              //   ),
              //   secondChild: IconButton(
              //     icon: const Icon(Icons.short_text),
              //     onPressed: () async {
              //       await showDialog(
              //         context: context,
              //         builder: (c) {
              //           return BibleReadDialog(
              //             cubit: context.read(),
              //           );
              //         },
              //       );
              //     },
              //   ),
              // ),
              // AnimatedCrossFade(
              //   alignment: Alignment.center,
              //   duration: kThemeAnimationDuration,
              //   crossFadeState: state.selectedVerse.isEmpty
              //       ? CrossFadeState.showFirst
              //       : CrossFadeState.showSecond,
              //   firstChild: const SizedBox(
              //     width: 10,
              //     height: 48,
              //   ),
              //   secondChild: IconButton(
              //     icon: const Icon(Icons.more_horiz_rounded),
              //     onPressed: () async {
              //       showModalBottomSheet(
              //         context: context,
              //         backgroundColor: Colors.transparent,
              //         elevation: 0,
              //         isScrollControlled: true,
              //         builder: (c) => BlocProvider.value(
              //             value: context.read<BibleCubit>(),
              //             child: BibleMenu(
              //               onNote: () async {
              //                 if (state.selectedVerse.length < 2) {
              //                   Fluttertoast.cancel();
              //                   Fluttertoast.showToast(
              //                     msg: 'Select at least 2 verses'.tr(),
              //                   );
              //                   return;
              //                 }
              //                 var bibles = state.selectedVerse.sorted(
              //                     (a, b) => a.verseId.compareTo(b.verseId));
              //                 router.push(
              //                   BibleNoteRoute(
              //                     cubit: context.read(),
              //                     mode: BibleNoteMode.write,
              //                     onSave: (data) {
              //                       context.read<BibleCubit>().saveNote(data);
              //                       router.pop();
              //                       router.push(BibleNoteListRoute(
              //                           cubit: context.read()));
              //                     },
              //                     initialData: state.notes
              //                             .indexWhere((element) =>
              //                                 element.from == bibles.first &&
              //                                 element.to == bibles.last)
              //                             .isNegative
              //                         ? BibleNote.empty(
              //                             bibles.first, bibles.last)
              //                         : state.notes.firstWhere((element) =>
              //                             element.from == bibles.first &&
              //                             element.to == bibles.last),
              //                   ),
              //                 );
              //               },
              //               onCopy: () async {
              //                 String text = '';
              //                 var bibles = state.selectedVerse.sorted(
              //                     (a, b) => a.verseId.compareTo(b.verseId));
              //                 var title = await context
              //                     .read<BibleCubit>()
              //                     .getBibleTitle(bibles.first);
              //                 var json = FirebaseUtils.jsonConfig(
              //                     'footer_copied_text');
              //                 var footer = json[context.locale.languageCode];
              //                 text = title;
              //                 if (bibles.length > 1) {
              //                   text += ' : ${bibles.first.verseId}';
              //                   text += ' - ';
              //                   text += '${bibles.last.verseId}';
              //                 }
              //                 for (var bible in bibles) {
              //                   var verse = bible.verse ?? '';
              //                   var number = bible.verseId;
              //                   text += '\n$number. $verse';
              //                 }
              //                 text += '\n\n$footer';
              //                 await Clipboard.setData(
              //                     ClipboardData(text: text));
              //                 Fluttertoast.cancel();
              //                 Fluttertoast.showToast(msg: 'Copied!'.tr());
              //               },
              //               onDeleted: () {
              //                 context.read<BibleCubit>().hightLightBible(state
              //                     .selectedVerse
              //                     .map((e) =>
              //                         e.copyWith(color: Colors.transparent))
              //                     .toList());
              //               },
              //               onHightlighted: (color) {
              //                 context.read<BibleCubit>().hightLightBible(state
              //                     .selectedVerse
              //                     .map((e) => e.copyWith(color: color))
              //                     .toList());
              //               },
              //             )),
              //       );
              //     },
              //   ),
              // ),

              /// history button
              AnimatedCrossFade(
                alignment: Alignment.center,
                duration: kThemeAnimationDuration,
                crossFadeState: CrossFadeState.showSecond,
                firstChild: const SizedBox(
                  width: 0,
                  height: 48,
                ),
                secondChild: IconButton(
                  icon: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      Assets.assetsIconsHistory,
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (c) {
                        return BlocProvider<BibleCubit>.value(
                          value: context.read(),
                          child: BlocBuilder<BibleCubit, BibleState>(
                            builder: (context, state) => Dialog(
                              clipBehavior: Clip.antiAlias,
                              child: Scrollbar(
                                child: SingleChildScrollView(
                                  child: state.histories.isEmpty
                                      ? ListTile(
                                          title: Text(
                                            'Empty'.tr(),
                                          ),
                                        )
                                      : Column(
                                          children: state.histories.entries
                                              .toList()
                                              .reversed
                                              .map((e) => FutureBuilder(
                                                    future: context
                                                        .read<BibleCubit>()
                                                        .getBibleTitle(
                                                            [e.value],
                                                            withVerse: true),
                                                    builder:
                                                        (context, snapshot) =>
                                                            ListTile(
                                                      trailing: Text(
                                                          e.key.toHumanDate()),
                                                      onTap: () async {
                                                        router.pop();
                                                        context
                                                            .read<BibleCubit>()
                                                            .getContent(e.value)
                                                            .then((value) {
                                                          scrollToVerse(
                                                              context
                                                                      .read<
                                                                          BibleCubit>()
                                                                      .state
                                                                      .currentBible
                                                                      ?.verseId ??
                                                                  0,
                                                              true);
                                                        });
                                                      },
                                                      title: Text(
                                                          snapshot.data ?? ''),
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              /// bookmark button
              AnimatedCrossFade(
                alignment: Alignment.center,
                duration: kThemeAnimationDuration,
                crossFadeState: CrossFadeState.showSecond,
                firstChild: const SizedBox(
                  width: 0,
                  height: 48,
                ),
                secondChild: IconButton(
                  icon: const Icon(Icons.bookmark_border_rounded),
                  onPressed: () async {
                    Fluttertoast.showToast(
                      msg: 'Fitur masih dalam pengembangan',
                    );
                  },
                ),
              ),

              /// more menu
              AnimatedCrossFade(
                  alignment: Alignment.center,
                  duration: kThemeAnimationDuration,
                  crossFadeState: CrossFadeState.showSecond,
                  firstChild: const SizedBox(
                    width: 0,
                    height: 48,
                  ),
                  secondChild: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 0) {
                        openSettings();
                        return;
                      } else if (value == 1) {
                        Fluttertoast.showToast(
                            msg: 'Fitur masih dalam pengembangan');
                      } else if (value == 2) {
                        router.push(
                          BibleNoteListRoute(
                            cubit: context.read(),
                          ),
                        );
                      } else if (value == 3) {
                        Fluttertoast.showToast(
                            msg: 'Fitur masih dalam pengembangan');
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Fitur masih dalam pengembangan');
                      }
                    },
                    itemBuilder: (context) => [
                      'Setting',
                      'See all bookmarks',
                      'See all notes',
                      'Search',
                      'Split Mode'
                    ]
                        .asMap()
                        .entries
                        .map((e) => PopupMenuItem(
                            value: e.key, child: Text(e.value.tr())))
                        .toList(),
                  )),
            ],
          ),
          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterFloat,
          floatingActionButton: state.selectedVerse.isNotEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      FloatingActionButton(
                        heroTag: 'previous',
                        mini: true,
                        shape: CircleBorder(),
                        onPressed: () {
                          context
                              .read<BibleCubit>()
                              .previousChapter()
                              .then((value) {
                            var index =
                                context.read<BibleCubit>().state.verses.length -
                                    1;
                            scrollToVerse(index, false);
                          });
                        },
                        child: Icon(Icons.keyboard_arrow_left),
                      ),
                      Spacer(),
                      FloatingActionButton(
                        mini: true,
                        shape: CircleBorder(),
                        heroTag: 'next',
                        onPressed: () {
                          context.read<BibleCubit>().nextChapter();
                          scrollToVerse(0, false);
                        },
                        child: Icon(Icons.keyboard_arrow_right),
                      ),
                    ],
                  ),
                ),
          body: Theme(
            data: Theme.of(context).copyWith(textTheme: state.defaultTextTheme),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Container(
                color: context.colorScheme.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...state.verses.asMap().entries.map((e) {
                      log('${state.verses.length}', name: 'Verse length');
                      var index = e.key;
                      bool hasPericope =
                          state.pericopes.getById(state.verses[index].id) !=
                              null;
                      bool hasPericopeParalel = state.pericopesParalels
                              .getById(state.verses[index].id) !=
                          null;

                      return VerseWidget(
                          state: state,
                          key: verseKeys[index],
                          index: index,
                          hasPericope: hasPericope,
                          hasPericopeParalel: hasPericopeParalel);
                    }).toList(),
                    SizedBox(
                      height: 60,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SelectedVerseMenu extends StatelessWidget {
  const SelectedVerseMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(blurRadius: 160, color: Colors.black.withOpacity(.2)),
        ],
        color: context.colorScheme.background,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DragHandler(),
          TextButton(
              onPressed: () {
                router.push(BibleNoteRoute(
                  initialData: BibleNote.empty(
                      context.read<BibleCubit>().state.selectedVerse),
                  cubit: context.read<BibleCubit>(),
                  mode: BibleNoteMode.write,
                  onSave: (data) {
                    context.read<BibleCubit>().saveNote(data);
                    router.pop();
                    router.push(BibleNoteListRoute(cubit: context.read()));
                  },
                ));
              },
              child: Text('stst')),
        ],
      ),
    );
  }
}

class VerseWidget extends StatefulWidget {
  const VerseWidget({
    super.key,
    required this.index,
    required this.hasPericope,
    required this.hasPericopeParalel,
    required this.state,
  });

  final int index;
  final bool hasPericope;
  final bool hasPericopeParalel;
  final BibleState state;

  @override
  State<VerseWidget> createState() => VerseWidgetState();
}

class VerseWidgetState extends State<VerseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController =
      AnimationController(vsync: this, duration: kThemeAnimationDuration);
  late Animation<Color?> animation =
      ColorTween(begin: Colors.amber.withOpacity(0), end: Colors.amber)
          .animate(animationController);
  void playAnimation() async {
    for (var i = 0; i < 3; i++) {
      await animationController.play();
      await animationController.playReverse();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) => SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            if (widget.hasPericope || widget.hasPericopeParalel)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text.rich(
                  style: context
                      .read<BibleCubit>()
                      .state
                      .defaultTextTheme
                      .bodyMedium,
                  textScaleFactor:
                      context.read<BibleCubit>().state.defaultTextScale,
                  TextSpan(children: [
                    if (widget.hasPericope) ...[
                      TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              height: context
                                  .read<BibleCubit>()
                                  .state
                                  .defaultTextHeight),
                          text: widget.state.pericopes
                              .getById(widget.state.verses[widget.index].id)!
                              .title!)
                    ],
                    if (widget.hasPericopeParalel)
                      TextSpan(
                          text: widget.state.pericopesParalels
                              .getById(widget.state.verses[widget.index].id)!
                              .t!),
                  ]),
                ),
              ),
            Container(
              color: widget.state.selectedVerse
                      .contains(widget.state.verses[widget.index])
                  ? Colors.blueGrey.withOpacity(.15)
                  : animation.value,
              padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical:
                      context.read<BibleCubit>().state.defaultTextHeight * 2),
              child: Text.rich(
                  style: context
                      .read<BibleCubit>()
                      .state
                      .defaultTextTheme
                      .bodyMedium,
                  textScaleFactor:
                      context.read<BibleCubit>().state.defaultTextScale,
                  TextSpan(children: [
                    WidgetSpan(
                      child: Transform.translate(
                        offset: const Offset(0, 2),
                        child: Text(
                          '${widget.state.verses[widget.index].verseId} ',
                          //superscript is usually smaller in size
                          textScaleFactor: 0.7,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: ' ',
                      style: TextStyle(
                        height:
                            context.read<BibleCubit>().state.defaultTextHeight,
                        color: null,
                        backgroundColor: widget.state.hightlightedVerse
                            .firstWhereOrNull((element) => element
                                .isSame(widget.state.verses[widget.index]))
                            ?.color,
                      ),
                      children: widget.state.verses[widget.index].verse
                          ?.split(' ')
                          .map(
                            (e) => TextSpan(
                              text: '$e ',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  log('Onselect');
                                  context.read<BibleCubit>().selectBible(
                                      widget.state.verses[widget.index]);
                                },
                              style: TextStyle(),
                            ),
                          )
                          .toList(),
                    ),
                  ])),
            ),
          ],
        ),
      ),
    );
  }
}

TextSpan buildHighlightedText(String text, List<String> terms) {
  List<TextSpan> textSpans = [];

  for (String term in terms) {
    int startIndex = text.toLowerCase().indexOf(term.toLowerCase());
    if (startIndex != -1) {
      textSpans.add(TextSpan(
        text: text.substring(0, startIndex),
      ));
      textSpans.add(TextSpan(
        text: text.substring(startIndex, startIndex + term.length),
        style: const TextStyle(
          backgroundColor: Colors.yellow, // Set background color
          fontWeight: FontWeight.bold,
        ),
      ));
      text = text.substring(startIndex + term.length);
    }
  }

  textSpans.add(TextSpan(text: text));

  return TextSpan(
    style: const TextStyle(fontSize: 16, color: Colors.black),
    children: textSpans,
  );
}

class BibleMenu extends StatefulWidget {
  final Function(Color color) onHightlighted;
  final Function() onDeleted;
  final Function() onCopy;
  final Function() onNote;

  const BibleMenu({
    super.key,
    required this.onHightlighted,
    required this.onDeleted,
    required this.onCopy,
    required this.onNote,
  });

  @override
  State<BibleMenu> createState() => _BibleMenuState();
}

class _BibleMenuState extends State<BibleMenu> {
  double childHeight = 0.00001;
  final GlobalKey widgetKey = GlobalKey();
  final GlobalKey handlerKey = GlobalKey();
  @override
  void initState() {
    measureWidgetSize(
      context: context,
      widgetKeys: [widgetKey, handlerKey],
      setState: (h) {
        childHeight = h;
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DraggableScrollableSheet(
        initialChildSize: childHeight.clamp(0.00001, 1),
        maxChildSize: childHeight.clamp(0.00001, 1),
        minChildSize: (childHeight - .1).clamp(0.00001, 1),
        expand: false,
        snap: true,
        snapSizes: [childHeight],
        builder: (context, scrollController) {
          return Material(
            color: context.colorScheme.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DragHandler(
                    key: handlerKey,
                  ),
                  Section(
                      label: 'More Options'.tr(),
                      key: widgetKey,
                      child: (gap) => SingleChildScrollView(
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text('Copy'),
                                  onTap: () {
                                    router.pop();
                                    widget.onCopy();
                                  },
                                ),
                                ListTile(
                                  onTap: () {
                                    router.pop();
                                    widget.onNote();
                                  },
                                  title: Text('Note'),
                                ),
                                ListTile(
                                  title: Text('Highlight'.tr()),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await Future.delayed(
                                        kThemeAnimationDuration);

                                    var result = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          const ColorPickDialog(),
                                    );
                                    Color? color;
                                    if (result[0] == 'apply') {
                                      color = result[1];
                                    } else {
                                      widget.onDeleted();
                                      return;
                                    }
                                    if (color != null) {
                                      widget.onHightlighted(color);
                                    }
                                  },
                                ),
                              ],
                            ),
                          )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ColorPickDialog extends StatefulWidget {
  const ColorPickDialog({
    super.key,
  });

  @override
  State<ColorPickDialog> createState() => _ColorPickDialogState();
}

class _ColorPickDialogState extends State<ColorPickDialog> {
  Color? selectedColor;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 300,
        width: 200,
        child: Column(
          children: [
            Text(
              'Highlight'.tr(),
              style: context.textTheme.titleMedium,
            ),
            SizedBox(
              height: 8,
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                double maxWidth = (constraints.maxWidth / 4).clamp(0, 60);
                return Wrap(
                  runSpacing: 16,
                  children: [
                    Colors.amber.shade200,
                    Colors.blue.shade200,
                    Colors.brown.shade200,
                    Colors.cyan.shade200,
                    Colors.red.shade200,
                    Colors.green.shade200,
                    Colors.orange.shade200,
                    Colors.purple.shade200,
                    Colors.teal.shade200,
                    Colors.indigo.shade200,
                    Colors.pink.shade200,
                    Colors.lime.shade200,
                  ]
                      .map((e) => SizedBox(
                            width: maxWidth,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedColor = e;
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: e,
                                child: selectedColor == e
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(
              height: 16,
            ),
            // ElevatedButton(onPressed: () {}, child: const Text('More color')),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colorScheme.error,
                      foregroundColor: context.colorScheme.onError,
                    ),
                    onPressed: () {
                      Navigator.pop(context, ['delete']);
                    },
                    child: const Text('Delete')),
                const SizedBox(
                  width: 8,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colorScheme.primary,
                      foregroundColor: context.colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      if (selectedColor == null) {
                        Fluttertoast.cancel();
                        Fluttertoast.showToast(
                          msg: 'Please select color'.tr(),
                          gravity: ToastGravity.CENTER,
                        );
                        return;
                      }
                      Navigator.pop(context, ['apply', selectedColor]);
                    },
                    child: const Text('Apply')),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class BibleReadDialog extends StatefulWidget {
  final BibleCubit cubit;

  const BibleReadDialog({super.key, required this.cubit});

  @override
  State<BibleReadDialog> createState() => _BibleReadDialogState();
}

class _BibleReadDialogState extends State<BibleReadDialog>
    with TickerProviderStateMixin {
  late Verse bible = widget.cubit.state.selectedVerse.first;
  late AnimationController clipboardAnimationController =
      AnimationController(vsync: this, duration: kThemeAnimationDuration);
  late Animation<int> clipboardAnimation =
      IntTween(begin: 0, end: copiedText.length)
          .animate(clipboardAnimationController);
  String get copiedText => 'Copied!'.tr();
  Control currentControl = Control.play;

  playCopyAnimation() async {
    currentControl = Control.loop;
    var title = await widget.cubit.getBibleTitle([bible], withVerse: true);
    var verse = bible.verse ?? '';
    var number = bible.verseId;
    var json = FirebaseUtils.jsonConfig('footer_copied_text');
    var footer = json[context.locale.languageCode];
    var text = '$title\n$number. $verse\n\n$footer';
    await Clipboard.setData(ClipboardData(text: text));
    clipboardAnimationController.value = 0;
    if (mounted) {
      await clipboardAnimationController.animateTo(1,
          curve: Curves.easeOut, duration: Duration(milliseconds: 200));
    }
    if (mounted) {
      await Future.delayed(Duration(seconds: 2));
    }
    if (mounted) {
      await clipboardAnimationController.animateBack(0,
          curve: Curves.easeOut, duration: Duration(milliseconds: 100));
    }
  }

  @override
  void dispose() {
    clipboardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Dialog(
            clipBehavior: Clip.antiAlias,
            insetPadding: EdgeInsets.fromLTRB(16, 16, 16, context.height / 2),
            child: Scaffold(
              appBar: AppBar(
                titleSpacing: 8,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: context.colorScheme.primaryContainer,
                        foregroundColor: context.colorScheme.onPrimaryContainer,
                      ),
                      onPressed: () {
                        var index = widget.cubit.state.verses.indexOf(bible);
                        log(index.toString());
                        var prevBible = widget.cubit.state.verses
                            .firstWhereIndexedOrNull(
                                (i, element) => i == index - 1);
                        if (prevBible != null) {
                          setState(() {
                            bible = prevBible;
                          });
                        } else {
                          Fluttertoast.cancel();
                          Fluttertoast.showToast(
                              msg: 'You reached the first'.tr());
                        }
                      },
                      icon: Icon(Icons.keyboard_arrow_left),
                    ),
                    Expanded(
                      child: FutureBuilder(
                        future: widget.cubit
                            .getBibleTitle([bible], withVerse: true),
                        builder: (context, snapshot) => Column(
                          children: [
                            Text(
                              snapshot.data ?? '',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              widget.cubit.state.currentBibleCode
                                      ?.split('_')
                                      .last
                                      .toUpperCase() ??
                                  '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: context.colorScheme.primaryContainer,
                        foregroundColor: context.colorScheme.onPrimaryContainer,
                      ),
                      onPressed: () async {
                        var index = widget.cubit.state.verses.indexOf(bible);
                        log(index.toString());
                        var prevBible = widget.cubit.state.verses
                            .firstWhereIndexedOrNull(
                                (i, element) => i == index + 1);
                        if (prevBible != null) {
                          setState(() {
                            bible = prevBible;
                          });
                        } else {
                          Fluttertoast.cancel();
                          Fluttertoast.showToast(
                              msg: 'You reached the last'.tr());
                        }
                      },
                      icon: Icon(Icons.keyboard_arrow_right),
                    ),
                  ],
                ),
              ),
              body: Container(
                height: double.infinity,
                width: double.infinity,
                color: context.colorScheme.background,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: CustomAnimationBuilder(
                          control: Control.playFromStart,
                          tween:
                              IntTween(begin: 0, end: bible.verse?.length ?? 0),
                          duration: Duration(seconds: 1),
                          builder: (context, value, child) =>
                              Text((bible.verse ?? '').substring(0, value)),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            playCopyAnimation();
                          },
                          icon: Icon(CupertinoIcons.doc_on_clipboard),
                        ),
                        AnimatedBuilder(
                          animation: clipboardAnimationController,
                          builder: (context, child) => Text(
                            copiedText.substring(0, clipboardAnimation.value),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: context.height / 1.5,
            child: PlayAnimationBuilder(
              duration: kThemeAnimationDuration,
              delay: Duration(milliseconds: 200),
              tween: Tween<double>(begin: 0, end: 1),
              curve: Curves.easeOut,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 100 - (100 * value)),
                  child: child,
                ),
              ),
              child: Center(
                child: IconButton(
                  padding: EdgeInsets.all(24),
                  style: IconButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: context.colorScheme.errorContainer,
                    foregroundColor: context.colorScheme.onErrorContainer,
                  ),
                  onPressed: () {
                    router.pop();
                  },
                  icon: Icon(Icons.close),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'dart:async';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../../components/widgets/drag_handler.dart';
import '../../../components/widgets/section.dart';
import '../../../data/utilities/enums.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/extensions/datetime_ext.dart';
import '../../../data/utilities/firebase_utils.dart';
import '../../../data/utilities/variables/assets.dart';
import '../../../domain/entity/bcvbc/bcvbc.dart';
import '../../../domain/entity/bible_note/bible_note.dart';
import '../../../domain/entity/bible_ref/bible_ref.dart';
import '../../../domain/entity/pericope/pericope.dart';
import '../../../domain/entity/pericope_paralel/pericope_paralel.dart';
import '../../../domain/entity/verse/verse.dart';
import '../../../router/router.dart';
import '../../settings/view/settings_view.dart';
import '../cubit/bible_cubit.dart';
import '../widget/bible_setting_widget.dart';

@RoutePage()
class BibleView extends StatefulWidget {
  const BibleView({super.key});

  @override
  State<BibleView> createState() => _BibleViewState();
}

class _BibleViewState extends State<BibleView> {
  late ScrollController scrollController = ScrollController()
    ..addListener(() {
      if (isFirstScrolling) {
        if (scrollController2.hasClients) {
          scrollController2.jumpTo(scrollController.offset);
        }
      }
    });
  bool isFirstScrolling = true;
  late ScrollController scrollController2 = ScrollController()
    ..addListener(() {
      if (!isFirstScrolling) {
        scrollController.jumpTo(scrollController2.offset);
      }
    });
  late bool _splitModeEnable = false;

  bool get splitModeEnable => _splitModeEnable;

  set splitModeEnable(bool value) {
    _splitModeEnable = value;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
      var state = context.read<BibleCubit>().state;
      var codes = state.bibleCodes;
      var index =
          codes.indexOf(state.splitBibleCode ?? state.currentBibleCode ?? '');

      context
          .read<BibleCubit>()
          .selectBibleCode(index.isNegative ? 0 : index, true);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    scrollController2.dispose();
    super.dispose();
  }

  scrollToVerse(int verseIndex, bool playAnimation) async {
    Future.delayed(Duration(milliseconds: 700), () async {
      var verseKeys = context.read<BibleCubit>().verseKeys;
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

  GlobalKey selectedVerseMenuKey = GlobalKey();

  Future<double> get selectedVerseMenuHeight async => await Future.delayed(
        Duration(milliseconds: 500),
        () {
          return selectedVerseMenuKey.currentContext?.size?.height ?? 0;
        },
      );

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool lookupTitle = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibleCubit, BibleState>(
      builder: (context, state) => Scaffold(
        key: scaffoldKey,
        backgroundColor: context.colorScheme.background,
        bottomSheet: Container(
          key: selectedVerseMenuKey,
          color: context.colorScheme.background,
          child: AnimatedSize(
            curve: Curves.easeOut,
            alignment: Alignment.bottomCenter,
            duration: kThemeAnimationDuration,
            child: state.selectedVerse.isEmpty
                ? SizedBox(
                    width: double.infinity,
                  )
                : PlayAnimationBuilder(
                    curve: Curves.easeOut,
                    delay: kThemeAnimationDuration,
                    duration: kThemeAnimationDuration,
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: SelectedVerseMenu(
                        verses: state.selectedVerse,
                      ),
                    ),
                  ),
          ),
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Container(
            clipBehavior: Clip.antiAlias,
            constraints: BoxConstraints(
              maxWidth: context.mediaQuery.size.width / 1.8,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  strokeAlign: BorderSide.strokeAlignInside,
                  color: context.theme.disabledColor,
                  width: 1,
                )),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: BorderSide(
                          strokeAlign: BorderSide.strokeAlignCenter,
                          width: 1,
                          color: Colors.transparent,
                        ),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(100),
                            right: lookupTitle
                                ? Radius.circular(100)
                                : Radius.zero,
                          ),
                        ),
                      ),
                      onLongPress: () {
                        setState(() {
                          lookupTitle = true;
                        });
                        Timer(
                          Duration(seconds: 2),
                          () {
                            if (mounted) {
                              setState(() {
                                lookupTitle = false;
                              });
                            }
                          },
                        );
                      },
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
                        builder: (context, snapshot) => Text(
                          snapshot.data ?? '',
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                  ),
                  if (!lookupTitle) VerticalDivider(width: 1),
                  Expanded(
                    flex: lookupTitle ? 0 : 1,
                    child: lookupTitle
                        ? SizedBox.shrink()
                        : PopupMenuButton<int>(
                            clipBehavior: Clip.antiAlias,
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
                                  getBibleCodeName(code),
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
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.zero,
                                    side: BorderSide(
                                      strokeAlign: BorderSide.strokeAlignCenter,
                                      width: 1,
                                      color: Colors.transparent,
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
            //                     mode: NoteMode.write,
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
                visualDensity: VisualDensity.compact,
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.only(left: 16),
                                  title: Text(
                                    'Histories'.tr(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: CloseButton(),
                                ),
                                Divider(height: 1),
                                Scrollbar(
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
                                                        trailing: Text(e.key
                                                            .toHumanDate()),
                                                        onTap: () async {
                                                          router.pop();

                                                          context
                                                              .read<
                                                                  BibleCubit>()
                                                              .getContent(
                                                                  e.value)
                                                              .then((value) {
                                                            scrollToVerse(
                                                                (context
                                                                            .read<BibleCubit>()
                                                                            .state
                                                                            .currentBible
                                                                            ?.verseId ??
                                                                        1) -
                                                                    1,
                                                                true);
                                                            Future.delayed(
                                                              Duration(
                                                                  seconds: 1),
                                                              () {
                                                                // var ctx = scaffoldKey
                                                                //     .currentContext;
                                                                // ctx
                                                                //     ?.read<
                                                                //         BibleCubit>()
                                                                //     .selectBible(
                                                                //         e.value);
                                                              },
                                                            );
                                                          });
                                                        },
                                                        title: Text(
                                                          snapshot.data ?? '',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                  ),
                                ),
                              ],
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
                color: context.colorScheme.primary,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.bookmark_border_rounded),
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (c) {
                      return BibleBookmarkDialog(
                        cubit: context.read(),
                        onModified: (modified) {
                          context.read<BibleCubit>().replaceBookmarks(modified);
                          return true;
                        },
                        onTap: (item) {
                          router.pop();

                          context
                              .read<BibleCubit>()
                              .getContent(item)
                              .then((value) {
                            scrollToVerse(
                                (context
                                            .read<BibleCubit>()
                                            .state
                                            .currentBible
                                            ?.verseId ??
                                        1) -
                                    1,
                                true);
                            Future.delayed(
                              Duration(seconds: 1),
                              () {
                                // var ctx = scaffoldKey
                                //     .currentContext;
                                // ctx
                                //     ?.read<
                                //         BibleCubit>()
                                //     .selectBible(
                                //         e.value);
                              },
                            );
                          });
                        },
                      );
                    },
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
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: context.theme.disabledColor,
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 0) {
                      openSettings();
                      return;
                    } else if (value == 1) {
                      router.push(
                        BibleNoteListRoute(
                          cubit: context.read(),
                        ),
                      );
                    } else if (value == 2) {
                      router.push(BibleSearchRoute(
                          onTap: (item) {
                            router.pop();
                            context.read<BibleCubit>().getContent(item);
                          },
                          cubit: context.read()));
                    }

                    /// split mode
                    else if (value == 3) {
                      splitModeEnable = !splitModeEnable;
                      Fluttertoast.cancel();
                      Fluttertoast.showToast(
                          msg:
                              'Split mode ${splitModeEnable ? 'enabled' : 'disabled'}!'
                                  .tr());
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Fitur masih dalam pengembangan');
                    }
                  },
                  itemBuilder: (context) => [
                    'Setting',
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
            ? Container(
                width: double.infinity,
              )
            : PlayAnimationBuilder(
                duration: kThemeAnimationDuration,
                tween: Tween<double>(begin: 0, end: 1),
                delay: kThemeAnimationDuration,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Padding(
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
                              scrollToVerse(0, false);
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
                ),
              ),
        body: Column(
          key: ValueKey(state.currentBible),
          children: [
            Expanded(
              child: Theme(
                data: Theme.of(context)
                    .copyWith(textTheme: state.defaultTextTheme),
                child: MultiSplitViewTheme(
                  data: MultiSplitViewThemeData(dividerThickness: 64),
                  child: MultiSplitView(
                    antiAliasingWorkaround: true,
                    resizable: true,
                    axis: Axis.vertical,
                    dividerBuilder: (axis, index, resizable, dragging,
                            highlighted, themeData) =>
                        Container(
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: context.colorScheme.background,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 4,
                              spreadRadius: -8,
                              offset: Offset(0, -4),
                            ),
                          ]),
                      child: Row(
                        children: [
                          GestureDetector(
                            onVerticalDragUpdate: (details) {},
                            child: CloseButton(
                              onPressed: () {
                                splitModeEnable = false;
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onVerticalDragUpdate: (details) {},
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FutureBuilder(
                                        future: context
                                            .read<BibleCubit>()
                                            .getBibleTitle([state.currentBible],
                                                splitMode: true),
                                        builder: (context, snapshot) =>
                                            Text(snapshot.data ?? ''),
                                      ),
                                      VerticalDivider(),
                                      PopupMenuButton<int>(
                                        padding: EdgeInsets.zero,
                                        onSelected: (value) {
                                          context
                                              .read<BibleCubit>()
                                              .selectBibleCode(value, true);
                                        },
                                        itemBuilder: (context) =>
                                            (state.bibleCodes)
                                                .asMap()
                                                .entries
                                                .map((e) {
                                          var code = e.value.split('.').first;
                                          var index = e.key;
                                          return PopupMenuItem(
                                            value: index,
                                            child: Text(
                                              getBibleCodeName(code),
                                              maxLines: 1,
                                              softWrap: false,
                                              overflow: TextOverflow.fade,
                                              style: TextStyle(),
                                            ),
                                          );
                                        }).toList(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              state.splitBibleCode
                                                      ?.split('_')
                                                      .last
                                                      .toUpperCase() ??
                                                  '',
                                              style: TextStyle(
                                                color: null,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(Icons.keyboard_arrow_down),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            enableFeedback: false,
                            splashColor: Colors.transparent,
                            onPressed: () {},
                            icon: Icon(Icons.drag_handle_rounded),
                          )
                        ],
                      ),
                    ),
                    children: [
                      Listener(
                        onPointerDown: (event) {
                          isFirstScrolling = true;
                        },
                        child: BibleViewer(
                            scrollFunction: (index) {
                              scrollToVerse(index, true);
                            },
                            scrollController: scrollController,
                            verseKeys: context.read<BibleCubit>().verseKeys,
                            cubit: context.read(),
                            isSplit: false,
                            selectedVerseMenuHeight: selectedVerseMenuHeight),
                      ),
                      if (splitModeEnable)
                        Listener(
                          onPointerDown: (event) {
                            isFirstScrolling = false;
                          },
                          child: BibleViewer(
                              scrollFunction: (index) {
                                scrollToVerse(index, true);
                              },
                              isSplit: true,
                              scrollController: scrollController2,
                              verseKeys: context.read<BibleCubit>().verseKeys2,
                              cubit: context.read(),
                              selectedVerseMenuHeight: selectedVerseMenuHeight),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: state.selectedVerse.isNotEmpty ? 80 : null,
            )
          ],
        ),
      ),
    );
  }
}

class BibleViewer extends StatelessWidget {
  const BibleViewer({
    super.key,
    required this.scrollController,
    required this.verseKeys,
    required this.selectedVerseMenuHeight,
    required this.cubit,
    required this.isSplit,
    required this.scrollFunction,
  });

  final ScrollController scrollController;
  final List<GlobalKey<VerseWidgetState>> verseKeys;
  final Future<double> selectedVerseMenuHeight;
  final BibleCubit cubit;
  final bool isSplit;
  final Function(int index) scrollFunction;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibleCubit, BibleState>(
      bloc: cubit,
      builder: (context, state) {
        var verses = isSplit ? state.splitVerses : state.verses;
        var pericopes = isSplit ? state.splitPericopes : state.pericopes;
        var pericopeParalels =
            isSplit ? state.splitPericopesParalels : state.pericopesParalels;
        return SingleChildScrollView(
          controller: scrollController,
          child: Container(
            color: context.colorScheme.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...verses.asMap().entries.map((e) {
                  var index = e.key;

                  return VerseWidget(
                    verse: e.value,
                    scrollFunction: scrollFunction,
                    onTapNote: (note) {
                      router.push(BibleNoteRoute(
                        initialData: note,
                        cubit: cubit,
                        mode: NoteMode.viewOnly,
                        onSave: (data) {
                          cubit.saveNote(data);
                          router.pop();
                          // router.push(BibleNoteListRoute(cubit: context.read()));
                        },
                      ));
                    },
                    note: state.notes.firstWhereOrNull((element) =>
                        element.verses.firstWhereOrNull(
                            (element) => element.id == e.value.id) !=
                        null),
                    references: state.references.getById(verses[index].id),
                    hightlightedVerse: state.hightlightedVerse,
                    selectedVerse: state.selectedVerse,
                    key: index > (verseKeys.length - 1)
                        ? GlobalKey()
                        : verseKeys[index],
                    index: index,
                    hasBookmark: state.bookmarks.contains(verses[index]),
                    pericope: pericopes.getById(verses[index].id),
                    pericopeParalels:
                        pericopeParalels.getById(verses[index].id),
                  );
                }).toList(),
                FutureBuilder(
                  future: selectedVerseMenuHeight,
                  builder: (context, snapshot) {
                    double height = ((state.selectedVerse.isNotEmpty
                                ? (snapshot.data ?? 0)
                                : 0) -
                            80.0)
                        .clamp(0, 1000);
                    return SizedBox(
                      height: height == 0 ? 60 : height,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SelectedVerseMenu extends StatelessWidget {
  final List<Verse> verses;
  const SelectedVerseMenu({
    super.key,
    required this.verses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          DragHandler(),
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
          Row(
            children: [
              if (verses.length == 1)
                TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: context.colorScheme.primaryContainer,
                      foregroundColor: context.colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () {
                      context.read<BibleCubit>().modifyBookmark(verses.first);
                    },
                    child: Text(
                        '${(context.read<BibleCubit>().state.bookmarks.contains(verses.first) ? 'Remove' : 'Add')} bookmark'
                            .tr())),
              SizedBox(
                width: 8,
              ),
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
                        router.pop();
                        router.push(BibleNoteListRoute(cubit: context.read()));
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
                    await Clipboard.setData(ClipboardData(text: text));
                    Fluttertoast.cancel();
                    Fluttertoast.showToast(msg: 'Copied!'.tr());
                  },
                  child: Text('Copy'.tr())),
            ],
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
                          verses.map((e) => e.copyWith(color: v)).toList());
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
          SizedBox(height: 8 + 16),
        ],
      ),
    );
  }
}

class VerseWidget extends StatefulWidget {
  const VerseWidget({
    super.key,
    required this.index,
    required this.verse,
    this.pericope,
    required this.pericopeParalels,
    required this.selectedVerse,
    required this.hightlightedVerse,
    required this.note,
    required this.onTapNote,
    required this.references,
    required this.hasBookmark,
    required this.scrollFunction,
  });

  final int index;
  final BibleNote? note;
  final Pericope? pericope;
  final bool hasBookmark;
  final List<PericopeParalel> pericopeParalels;
  final List<Verse> selectedVerse;
  final List<BibleRef> references;
  final List<Verse> hightlightedVerse;
  final Function(BibleNote note) onTapNote;
  final Function(int index) scrollFunction;
  final Verse verse;
  bool get hasNote => note != null;

  bool get hasPericope => pericope != null;
  bool get hasPericopeParalel => pericopeParalels.isNotEmpty;
  bool get hasReferences => references.isNotEmpty;

  @override
  State<VerseWidget> createState() => VerseWidgetState();
}

class VerseWidgetState extends State<VerseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController =
      AnimationController(vsync: this, duration: kThemeAnimationDuration);
  late Animation<Color?> animation = ColorTween(
          begin: Colors.blueGrey.withOpacity(0),
          end: Colors.blueGrey.withOpacity(.15))
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text.rich(
                  textAlign: TextAlign.center,
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
                          text: widget.pericope!.title!)
                    ],
                    if (widget.hasPericopeParalel)
                      ...List.generate(
                          widget.pericopeParalels.length,
                          (index) => TextSpan(children: [
                                TextSpan(text: '\n'),
                                WidgetSpan(
                                    child: InkWell(
                                  onTap: () {
                                    var item = widget.pericopeParalels[index];
                                    var bcv = Bcvbc.fromBibleId(item.id1!);
                                    Fluttertoast.cancel();
                                    Fluttertoast.showToast(msg: 'Opening'.tr());
                                    context.read<BibleCubit>().getContent(
                                          Verse(
                                            id: item.id1!,
                                            bookId: int.tryParse(bcv.b!) ?? 1,
                                            chapterId:
                                                int.tryParse(bcv.c!) ?? 1,
                                            verseId: int.tryParse(bcv.v!) ?? 1,
                                          ),
                                        );
                                    widget.scrollFunction(
                                        (int.tryParse(bcv.v!) ?? 1) - 1);
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.open_in_new, size: 14),
                                      Text(
                                          style: GoogleFonts.arima(
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          '${widget.pericopeParalels[index].t}'),
                                    ],
                                  ),
                                ))
                              ])),
                  ]),
                ),
              ),
            Container(
              width: double.infinity,
              color: widget.selectedVerse.contains(widget.verse)
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
                textAlign: TextAlign.justify,
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.hasNote) {
                            widget.onTapNote(widget.note!);
                          }
                        },
                        child: Container(
                          alignment: !widget.hasNote ? null : Alignment.center,
                          decoration: widget.hasNote
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: context.colorScheme.primaryContainer,
                                )
                              : null,
                          width: !widget.hasNote
                              ? null
                              : 18 +
                                  ((widget.verse.verseId.toString().length -
                                              1) *
                                          4)
                                      .toDouble(),
                          height: !widget.hasNote ? null : 16,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.hasBookmark)
                                Icon(
                                  Icons.bookmark,
                                  color: context.colorScheme.primary,
                                  size: 14,
                                ),
                              Text(
                                '${widget.verse.verseId}. ',
                                softWrap: false,

                                maxLines: 1,
                                overflow: TextOverflow.visible,
                                //superscript is usually smaller in size
                                textScaleFactor: 0.7,
                                style: TextStyle(
                                  color: context.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TextSpan(
                      text: ' ',
                      style: TextStyle(
                        height:
                            context.read<BibleCubit>().state.defaultTextHeight,
                        color: null,
                        backgroundColor: widget.hightlightedVerse
                            .firstWhereOrNull(
                                (element) => element.isSame(widget.verse))
                            ?.color,
                      ),
                      children: widget.verse.verse
                          ?.split(' ')
                          .map(
                            (e) => TextSpan(
                              text: '$e ',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  log('Onselect');

                                  context
                                      .read<BibleCubit>()
                                      .selectBible(widget.verse);
                                  if (widget.selectedVerse.isEmpty) {
                                    await Future.delayed(
                                        Duration(milliseconds: 600));
                                  }
                                  if (context
                                      .read<BibleCubit>()
                                      .state
                                      .selectedVerse
                                      .contains(widget.verse)) {
                                    Scrollable.ensureVisible(
                                      context,
                                      alignmentPolicy:
                                          ScrollPositionAlignmentPolicy
                                              .explicit,
                                      alignment: .3,
                                      curve: Curves.easeOut,
                                      duration: Duration(milliseconds: 500),
                                    );
                                  }
                                },
                              style: TextStyle(),
                            ),
                          )
                          .toList(),
                    ),
                    if (widget.hasReferences)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                return BibleRefDialog(
                                    cubit: context.read(),
                                    selectedVerse: widget.verse,
                                    references: widget.references,
                                    scrollFunction: (index) {
                                      widget.scrollFunction(index);
                                    });
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              // color: context.colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '*',
                              textScaleFactor: context
                                  .read<BibleCubit>()
                                  .state
                                  .defaultTextScale,

                              /// REF*
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold
                                  // color: context.colorScheme.onPrimary,
                                  ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BibleRefDialog extends StatefulWidget {
  const BibleRefDialog({
    super.key,
    required this.references,
    required this.cubit,
    required this.selectedVerse,
    required this.scrollFunction,
  });

  final List<BibleRef> references;
  final Verse selectedVerse;
  final BibleCubit cubit;
  final Function(int index) scrollFunction;

  @override
  State<BibleRefDialog> createState() => _BibleRefDialogState();
}

class _BibleRefDialogState extends State<BibleRefDialog> {
  late BibleRef currentRef = widget.references.first;

  late List<Verse> currentVerses = [];

  @override
  void initState() {
    getCurrentVerse();
    super.initState();
  }

  getCurrentVerse() {
    Future.microtask(() async {
      currentVerses =
          await widget.cubit.getVersesByIdRange(currentRef.sv, currentRef.ev);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: SimpleDialog(
        backgroundColor: context.colorScheme.background,
        surfaceTintColor: Colors.transparent,
        alignment: Alignment.topCenter,
        contentPadding: EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
          ),
          FutureBuilder(
            future: widget.cubit
                .getBibleTitle([widget.selectedVerse], withVerse: true),
            builder: (context, snapshot) => Text(
              snapshot.data ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 8),
          IntrinsicHeight(
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.references
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FutureBuilder(
                                future: convertIDtoNameAlkitab(
                                    e.sv, e.ev != 0 ? e.ev : null,
                                    bibleDb: widget.cubit.bibleDb!),
                                builder: (context, snapshot) {
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: currentRef == e
                                          ? context.colorScheme.primary
                                          : context
                                              .colorScheme.primaryContainer,
                                      foregroundColor: currentRef == e
                                          ? context.colorScheme.onPrimary
                                          : context
                                              .colorScheme.onPrimaryContainer,
                                      visualDensity: VisualDensity.compact,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      Scrollable.ensureVisible(context,
                                          duration: kThemeAnimationDuration,
                                          curve: Curves.easeOut,
                                          alignment: .2);
                                      currentRef = e;
                                      setState(() {});
                                      getCurrentVerse();
                                    },
                                    child: Text(snapshot.data ?? ''),
                                  );
                                },
                              ),
                            ))
                        .toList(),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 20),
                    width: 20,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      context.colorScheme.background.withOpacity(0),
                      context.colorScheme.background,
                    ])),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            constraints: BoxConstraints(maxHeight: context.height / 2),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...currentVerses
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                              onTap: () {
                                router.pop();
                                widget.cubit.getContent(e);
                                widget.scrollFunction(e.verseId - 1);
                              },
                              child: Text(
                                  '${e.chapterId}:${e.verseId}  ${(e.verse ?? '')}')),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TextSpan buildHighlightedText(
    String text, List<String> terms, BuildContext context) {
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
    style: TextStyle(fontSize: 14, color: context.textTheme.bodyMedium?.color),
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
    var json = await FirebaseUtils.jsonConfig('footer_copied_text');
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

class BibleBookmarkDialog extends StatefulWidget {
  const BibleBookmarkDialog(
      {super.key,
      required this.cubit,
      required this.onTap,
      required this.onModified});
  final BibleCubit cubit;
  final Function(Verse item) onTap;

  final FutureOr<bool> Function(List<Verse> modified) onModified;

  @override
  State<BibleBookmarkDialog> createState() => _BibleBookmarkDialogState();
}

class _BibleBookmarkDialogState extends State<BibleBookmarkDialog> {
  late List<Verse> bookmarks = List.from(widget.cubit.state.bookmarks);

  late List<Verse> modifiedBookmarks = List.from(bookmarks);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (bookmarks.length == modifiedBookmarks.length) {
          return true;
        }
        return widget.onModified(bookmarks
          ..retainWhere((element) => modifiedBookmarks.contains(element)));
      },
      child: BlocProvider<BibleCubit>.value(
        value: widget.cubit,
        child: BlocBuilder<BibleCubit, BibleState>(
          builder: (context, state) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.only(left: 16),
                  title: Text(
                    'Bookmarks'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: CloseButton(),
                ),
                Divider(height: 1),
                Scrollbar(
                  child: SingleChildScrollView(
                    child: bookmarks.isEmpty
                        ? ListTile(
                            title: Text(
                              'Empty'.tr(),
                            ),
                          )
                        : Column(
                            children: bookmarks.reversed
                                .map((e) => FutureBuilder(
                                      future: context
                                          .read<BibleCubit>()
                                          .getBibleTitle([e], withVerse: true),
                                      builder: (context, snapshot) => ListTile(
                                        contentPadding:
                                            EdgeInsets.only(left: 16),
                                        trailing: IconButton(
                                          onPressed: () {
                                            if (modifiedBookmarks.contains(e)) {
                                              modifiedBookmarks.remove(e);
                                            } else {
                                              modifiedBookmarks.add(e);
                                            }
                                            setState(() {});
                                          },
                                          icon: Icon(modifiedBookmarks
                                                  .contains(e)
                                              ? Icons.bookmark
                                              : Icons.bookmark_outline_rounded),
                                        ),
                                        onTap: () async {
                                          widget.onTap(e);
                                        },
                                        title: Text(snapshot.data ?? ''),
                                      ),
                                    ))
                                .toList(),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

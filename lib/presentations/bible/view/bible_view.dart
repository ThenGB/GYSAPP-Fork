// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:visibility_detector/visibility_detector.dart';

import '../../../components/widgets/swipe_detector_widget.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/functions/debouncer.dart';
import '../../../data/utilities/variables/assets.dart';
import '../../../router/router.dart';
import '../../dashboard/cubit/dashboard_cubit.dart';
import '../bible.dart';

@RoutePage()
class BibleView extends StatefulWidget {
  const BibleView({super.key});

  @override
  State<BibleView> createState() => _BibleViewState();
}

class _BibleViewState extends State<BibleView> {
  Debouncer debouncer = Debouncer(Duration(milliseconds: 100));

  late ScrollController scrollController = ScrollController();
  late ScrollController scrollController2 = ScrollController();
  bool isFirstScrolling = true;
  late bool _splitModeEnable = false;

  bool get splitModeEnable => _splitModeEnable;

  late MultiSplitViewController splitController =
      MultiSplitViewController(areas: [
    Area(min: .3, data: 'atas'),
    if (splitModeEnable) Area(min: .3, data: 'bawah'),
  ]);

  set splitModeEnable(bool value) {
    _splitModeEnable = value;

    splitController.areas = List.generate(
      splitModeEnable ? 2 : 1,
      (index) => Area(min: .3, flex: .5, data: index == 0 ? 'atas' : 'bawah'),
    );

    log(splitController.areas.map((e) => e.size).toString(), name: 'Areas');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
      var state = context.read<BibleCubit>().state;
      var codes = state.bibleCodes;
      var index = codes.indexOf(state.splitBibleCode);

      context
          .read<BibleCubit>()
          .selectBibleCode(index.isNegative ? 0 : index, true);
    });
  }

  @override
  void initState() {
    VisibilityDetectorController.instance.updateInterval =
        Duration(microseconds: 1);
    super.initState();
  }

  @override
  void dispose() {
    splitController.dispose();
    scrollController.dispose();
    scrollController2.dispose();
    debouncer.dispose();
    super.dispose();
  }

  double lastOffset = 0;

  Future<void> scrollToVerse(int verseIndex, bool playAnimation,
      [bool forSecondView = false]) async {
    Future.delayed((kThemeAnimationDuration + Duration(milliseconds: 300)),
        () async {
      var verseKeys = forSecondView
          ? context.read<BibleCubit>().verseKeys2
          : context.read<BibleCubit>().verseKeys;

      log(verseIndex.toString(), name: 'Scroll to');
      RenderBox? verseBox = verseKeys[verseIndex]
          .currentContext
          ?.findRenderObject() as RenderBox?;
      // double verseHeight = verseBox?.size.height ?? 0;
      if (verseBox == null) return;

      // Scroll to the position of the vverse
      await Scrollable.ensureVisible(
        verseKeys[verseIndex].currentState!.context,
        duration: Duration(milliseconds: 800),
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        alignment: 0,
        curve: Curves.easeOut,
      );

      if (playAnimation) {
        verseKeys[verseIndex].currentState?.playAnimation();
      }
    });
  }

  Future<void> openSettings() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      builder: (c) => BlocProvider<BibleCubit>.value(
        value: context.read(),
        child: BlocBuilder<BibleCubit, BibleState>(
          builder: (context, state) => FontSettingWidget(
            selectedFont: state.defaultFont,
            availableFonts: state.availableFonts,
            textHeight: state.defaultTextHeight,
            textScale: state.defaultTextScale,
            getTextStyle: (font) => state
                .getTextThemeByFontName(font, context.textTheme)
                .bodyMedium!,
            onTextHeightChanged: (value) {
              context.read<BibleCubit>().changeTextHeight(value);
            },
            onTextScaleChanged: (value) {
              _currentScale = value;
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

  final PageStorageBucket _bucket = PageStorageBucket();

  Map<int, double> topVisibleIndexes = {};
  Map<int, double> bottomVisibleIndexes = {};

  GlobalKey splitViewKey = GlobalKey();
  double maxHeightBawah = 0;
  void handleScrollBottom(int index, Size size, double visiblePercentage) {
    // Store the visiblePercentage in the bottomVisibleIndexes map using the index as the key
    bottomVisibleIndexes[index] = visiblePercentage;

    // Remove entries with a value of 0 from the bottomVisibleIndexes map
    bottomVisibleIndexes.removeWhere((key, value) => value == 0);

    // Sort the keys of the bottomVisibleIndexes map in ascending order
    var keys = bottomVisibleIndexes.keys.toList()..sort();

    // Rebuild the bottomVisibleIndexes map with the sorted keys
    bottomVisibleIndexes =
        Map.fromEntries(keys.map((e) => MapEntry(e, bottomVisibleIndexes[e]!)));

    // Check if it's the first scrolling event
    if (!isFirstScrolling && lockScroll) {
      // Schedule a microtask to execute after the current event loop
      // Get the index of the widget above the first visible widget
      var indexAbove = bottomVisibleIndexes.keys.first - 1;
      var objectContext =
          context.read<BibleCubit>().verseKeys[indexAbove].currentContext!;

      // Get the size of the widget above the first visible widget
      var boxAbove = (objectContext.findRenderObject() as RenderBox).size;

      // Calculate the amount of the widget that is visible
      var percentageVisible = bottomVisibleIndexes.values.first;
      var visibleBox = boxAbove.height * (1 - percentageVisible);

      // Scroll to the widget above the first visible widget
      if (scrollController.hasClients) {
        var anu = visibleBox / (maxHeightAtas - boxAbove.height);
        Scrollable.ensureVisible(objectContext, alignment: -anu);
        // scrollController.jumpTo(scrollController.offset + visibleBox);
      }
    }
  }

  late ScrollableState scrollable2;
  late ScrollableState scrollable;
  late BuildContext contextBible;
  late BuildContext contextBible2;

  bool lockScroll = true;
  double maxHeightAtas = 0;
  void handleScrollTop(int index, Size size, double visiblePercentage) {
    // Store the visiblePercentage in the topVisibleIndexes map using the index as the key
    topVisibleIndexes[index] = visiblePercentage;

    // Remove entries with a value of 0 from the topVisibleIndexes map
    topVisibleIndexes.removeWhere((key, value) => value == 0);

    // Sort the keys of the topVisibleIndexes map in ascending order
    var keys = topVisibleIndexes.keys.toList()..sort();

    // Rebuild the topVisibleIndexes map with the sorted keys
    topVisibleIndexes =
        Map.fromEntries(keys.map((e) => MapEntry(e, topVisibleIndexes[e]!)));

    // Check if splitMode is enabled and it's the first scrolling event
    if (splitModeEnable && isFirstScrolling && lockScroll) {
      // Schedule a microtask to execute after the current event loop
      // Get the index of the widget above the first visible widget
      var indexAbove = topVisibleIndexes.keys.first - 1;
      var objectContext =
          context.read<BibleCubit>().verseKeys2[indexAbove].currentContext!;

      // Get the size of the widget above the first visible widget
      var boxBelow = (objectContext.findRenderObject() as RenderBox).size;

      // Calculate the amount of the widget that is visible
      var percentageAbove = topVisibleIndexes.values.first;
      var visibleBox = boxBelow.height * (1 - percentageAbove);

      // Scroll to the widget above the first visible widget using scrollController2
      if (scrollController2.hasClients) {
        var anu = visibleBox / (maxHeightBawah - boxBelow.height);
        Scrollable.ensureVisible(objectContext,
            alignment:
                -anu); // scrollController2.jumpTo(scrollController2.offset + visibleBox);
      }
    }
  }

  late double _currentScale = context.read<BibleCubit>().state.defaultTextScale;
  late double _baseScale = context.read<BibleCubit>().state.defaultTextScale;
  double get scale => _currentScale.clamp(.8, 2);

  void onTapTitle(BibleState state, bool forSecondView) {
    if (context.read<DashboardCubit>().state.isSyncing) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: 'Syncing'.tr());
      return;
    }
    router.push(BibleListRoute(
      bibleCode: forSecondView ? state.splitBibleCode : state.currentBibleCode,
      textScale: state.defaultTextScale,
      books: forSecondView ? state.booksSplit : state.books,
      getBibles: (bookId, chapterId) async {
        if (bookId == null || chapterId == null) {
          return [];
        }
        return await context
            .read<BibleCubit>()
            .getVersesByBook(bookId, chapterId);
      },
      onSelected: (verse) async {
        await context.read<BibleCubit>().getContent(
              verse,
              mode: lockScroll
                  ? VerseMode.both
                  : forSecondView
                      ? VerseMode.bottomOnly
                      : VerseMode.topOnly,
            );
        router.maybePop();
        context.read<BibleCubit>().saveToHistory(verse);

        scrollToVerse(verse.verseId - 1, true, forSecondView);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BibleCubit, BibleState>(
      listener: (context, state) {
        scrollToVerse((state.currentBible?.verseId ?? 1) - 1, false);
      },
      listenWhen: (previous, current) =>
          previous.currentBible != current.currentBible && current.isSpeaking,
      child: BlocBuilder<BibleCubit, BibleState>(
        builder: (context, state) => Scaffold(
          key: scaffoldKey,
          backgroundColor: context.colorScheme.surface,
          bottomSheet: Container(
            key: selectedVerseMenuKey,
            color: context.colorScheme.surface,
            child: AnimatedSize(
              curve: Curves.easeOut,
              alignment: Alignment.bottomCenter,
              duration: kThemeAnimationDuration,
              child: state.selectedVerse.isEmpty
                  ? SizedBox(
                      width: double.infinity,
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PlayAnimationBuilder(
                          curve: Curves.easeOut,
                          delay: kThemeAnimationDuration,
                          duration: kThemeAnimationDuration,
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (c, value, child) => Opacity(
                            opacity: value,
                            child: SelectedVerseMenu(
                              viewPadding:
                                  context.mediaQuery.viewPadding.vertical,
                              verses: state.selectedVerse,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    strokeAlign: BorderSide.strokeAlignInside,
                    color: context.theme.disabledColor,
                    width: 1,
                  )),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          // padding: EdgeInsets.only(left: 12, right: 12),
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
                          onTapTitle(state, false);
                        },
                        child: FutureBuilder(
                          future: context
                              .read<BibleCubit>()
                              .getBibleTitle([state.currentBible]),
                          builder: (context, snapshot) =>
                              DefaultTextStyle.merge(
                            textAlign: TextAlign.center,
                            child: LetterWrapText(
                              text: snapshot.data ?? '',
                              textStyle: TextStyle(
                                height: 1,
                                color: context.colorScheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!lookupTitle) VerticalDivider(width: 1),
                    Expanded(
                      flex: lookupTitle ? 0 : 1,
                      child: lookupTitle
                          ? SizedBox.shrink()
                          : BlocBuilder<DashboardCubit, DashboardState>(
                              builder: (context, _) => FutureBuilder(
                                future: context.read<BibleCubit>().getBibles(),
                                builder: (context, snapshot) =>
                                    PopupMenuButton<int>(
                                  offset: Offset(0, 48),
                                  clipBehavior: Clip.antiAlias,
                                  padding: EdgeInsets.zero,
                                  onSelected: (value) {
                                    context
                                        .read<BibleCubit>()
                                        .selectBibleCode(value);
                                  },
                                  itemBuilder: (context) =>
                                      state.bibleCodes.asMap().entries.map((e) {
                                    var code = e.value.split('.').first;
                                    var index = e.key;
                                    return PopupMenuItem(
                                      value: index,
                                      child: FutureBuilder(
                                        future: getBibleCodeName(code),
                                        builder: (context, snapshot) => Text(
                                          snapshot.data ?? '',
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(),
                                        ),
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
                                            strokeAlign:
                                                BorderSide.strokeAlignCenter,
                                            width: 1,
                                            color: Colors.transparent,
                                          ),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.horizontal(
                                              right: Radius.circular(100),
                                            ),
                                          )),
                                      onPressed: () {},
                                      child: Text(
                                        state.currentBibleCode
                                            .split('_')
                                            .last
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: null,
                                        ),
                                      ),
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
                      context.theme.disabledColor,
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
                            builder: (context, state) => MediaQuery(
                              data: context.mediaQuery.copyWith(
                                textScaler:
                                    TextScaler.linear(state.defaultTextScale),
                              ),
                              child: Dialog(
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
                                    Flexible(
                                      child: Scrollbar(
                                        child: SingleChildScrollView(
                                          child: state.histories.isEmpty
                                              ? ListTile(
                                                  title: Text(
                                                    'Empty'.tr(),
                                                  ),
                                                )
                                              : Column(children: [
                                                  ...List.generate(
                                                      state.histories.length,
                                                      (index) {
                                                    var e = state
                                                        .histories.entries
                                                        .toList()[index];
                                                    return FutureBuilder(
                                                      future: context
                                                          .read<BibleCubit>()
                                                          .getBibleTitle(
                                                              [e.value],
                                                              withVerse: true),
                                                      builder:
                                                          (context, snapshot) =>
                                                              ListTile(
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        16),
                                                        minVerticalPadding: 0,
                                                        dense: true,
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                        trailing: Text(
                                                          timeago.format(
                                                            e.key,
                                                            locale: context
                                                                .locale
                                                                .languageCode,
                                                          ),
                                                        ),
                                                        onTap: () async {
                                                          context
                                                              .read<
                                                                  BibleCubit>()
                                                              .getContent(
                                                                  e.value)
                                                              .then((value) {
                                                            var verse = (context
                                                                        .read<
                                                                            BibleCubit>()
                                                                        .state
                                                                        .currentBible
                                                                        ?.verseId ??
                                                                    1) -
                                                                1;
                                                            router.maybePop();
                                                            scrollToVerse(
                                                                verse, true);
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
                                                    );
                                                  }),
                                                  SizedBox(height: 8),
                                                ]),
                                        ),
                                      ),
                                    ),
                                  ],
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
                  color: state.bookmarks.firstWhereOrNull((element) =>
                              element.verse.id.toString().substring(0, 5) ==
                                  state.currentBible?.id
                                      .toString()
                                      .substring(0, 5) &&
                              element.isBookmarkAll) ==
                          null
                      ? context.theme.disabledColor
                      : context.colorScheme.primary,
                  visualDensity: VisualDensity.compact,
                  icon: state.bookmarks.firstWhereOrNull((element) =>
                              element.verse.id.toString().substring(0, 5) ==
                                  state.currentBible?.id
                                      .toString()
                                      .substring(0, 5) &&
                              element.isBookmarkAll) ==
                          null
                      ? const Icon(Icons.bookmark_border_rounded)
                      : Icon(Icons.bookmark),
                  onPressed: () async {
                    context.read<BibleCubit>().modifyBookmark();
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
                  secondChild: BlocBuilder<DashboardCubit, DashboardState>(
                    builder: (context, dashboardState) => dashboardState
                            .isSyncing
                        ? Tooltip(
                            message: 'Syncing'.tr(),
                            child: SizedBox.square(
                              dimension: 32,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation(
                                      context.theme.disabledColor),
                                ),
                              ),
                            ),
                          )
                        : PopupMenuButton(
                            enabled: !dashboardState.isSyncing,
                            offset: Offset(0, 48),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                Icons.more_vert_rounded,
                                color: context.theme.disabledColor,
                              ),
                            ),
                            onSelected: (value) async {
                              if (state.selectedVerse.isNotEmpty) {
                                context.read<BibleCubit>().removeSelection();
                                await Future.delayed(kThemeAnimationDuration +
                                    Duration(milliseconds: 500));
                              }
                              if (value == 'font') {
                                openSettings();
                                return;
                              } else if (value == 'notes') {
                                router.push(
                                  BibleNoteListRoute(
                                    cubit: context.read(),
                                  ),
                                );
                              } else if (value == 'search') {
                                router.push(BibleSearchRoute(
                                    onTap: (item) {
                                      context
                                          .read<BibleCubit>()
                                          .saveToHistory(item);
                                      router.maybePop();
                                      context
                                          .read<BibleCubit>()
                                          .getContent(item)
                                          .then((_) {
                                        scrollToVerse(item.verseId - 1, true);
                                      });
                                    },
                                    cubit: context.read()));
                              }

                              /// split mode
                              else if (value == 'split') {
                                splitModeEnable = !splitModeEnable;
                                Fluttertoast.cancel();
                                Fluttertoast.showToast(
                                    msg:
                                        'Split mode ${splitModeEnable ? 'enabled' : 'disabled'}!'
                                            .tr());
                              }

                              /// Audio
                              else if (value == 'audio') {
                                context.read<BibleCubit>().toggleAudio();
                              } else if (value == 'bookmarks') {
                                showDialog(
                                  context: context,
                                  builder: (c) {
                                    return BibleBookmarkDialog(
                                      cubit: context.read(),
                                      onModified: (modified) {
                                        context
                                            .read<BibleCubit>()
                                            .replaceBookmarks(modified);
                                        return true;
                                      },
                                      onTap: (item) {
                                        router.maybePop();

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
                              } else {
                                Fluttertoast.showToast(
                                    msg: 'Fitur masih dalam pengembangan');
                              }
                            },
                            itemBuilder: (context) => [
                              ['Font Settings', 'font'],
                              ['See all notes', 'notes'],
                              ['See all bookmarks', 'bookmarks'],
                              ['Search', 'search'],
                              ['Split Mode', 'split'],
                              ['Audio', 'audio']
                            ]
                                .asMap()
                                .entries
                                .map((e) => PopupMenuItem(
                                    value: e.value[1],
                                    child: Row(
                                      children: [
                                        Text(e.value[0].tr()),
                                        if (e.value[0] == 'Audio') ...[
                                          Spacer(),
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Checkbox(
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              value: state.enableAudio,
                                              onChanged: (v) {
                                                context
                                                    .read<BibleCubit>()
                                                    .toggleAudio();
                                                router.maybePop();
                                              },
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                          ),
                                        ]
                                      ],
                                    )))
                                .toList(),
                          ),
                  )),
            ],
          ),
          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterFloat,
          floatingActionButton: Stack(
            // alignment: Alignment.bottomCenter,

            children: [
              state.selectedVerse.isNotEmpty
                  ? SizedBox(
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
                                      .previousChapter(lockScroll
                                          ? VerseMode.both
                                          : VerseMode.topOnly)
                                      .then((value) {
                                    scrollToVerse(0, false);
                                  });
                                },
                                child: Icon(Icons.keyboard_arrow_left),
                              ),
                              // Spacer(),
                              // if (state.enableAudio)
                              //   FloatingActionButton(
                              //     mini: true,
                              //     shape: CircleBorder(),
                              //     heroTag: 'play',
                              //     onPressed: () {},
                              //     child: Icon(Icons.play_arrow_rounded),
                              //   ),
                              Spacer(),
                              FloatingActionButton(
                                mini: true,
                                shape: CircleBorder(),
                                heroTag: 'next',
                                onPressed: () {
                                  context.read<BibleCubit>().nextChapter(
                                      null,
                                      false,
                                      lockScroll
                                          ? VerseMode.both
                                          : VerseMode.topOnly);
                                  scrollToVerse(0, false);
                                },
                                child: Icon(Icons.keyboard_arrow_right),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              if (state.enableAudio)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(
                        mini: true,
                        shape: CircleBorder(),
                        heroTag: 'play',
                        onPressed: () {
                          // context.read<BibleCubit>().initTts();
                          // return;
                          if (state.isSpeaking) {
                            context.read<BibleCubit>().stopSpeaking();
                          } else {
                            context.read<BibleCubit>().speakTheBible();
                          }
                        },
                        child: Icon(
                          state.isSpeaking
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: PageStorage(
            bucket: _bucket,
            child: SwipeDetectorWidget(
              onSwipeLeft: () {
                context.read<BibleCubit>().nextChapter(null, false,
                    lockScroll ? VerseMode.both : VerseMode.topOnly);
              },
              onSwipeRight: () {
                context.read<BibleCubit>().previousChapter(
                    lockScroll ? VerseMode.both : VerseMode.topOnly);
              },
              child: Column(
                children: [
                  Expanded(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(textTheme: state.defaultTextTheme),
                      child: MultiSplitViewTheme(
                        data: MultiSplitViewThemeData(dividerThickness: 64),
                        child: MultiSplitView(
                          controller: splitController,
                          antiAliasingWorkaround: true,
                          resizable: true,
                          axis: Axis.vertical,
                          onDividerDragUpdate: (index) {
                            if (splitModeEnable) {
                              var areaAtas = splitController.getArea(0);
                              if ((areaAtas.size ?? 0) > 0.7) {
                                splitController.areas = [
                                  Area(min: .3, flex: .7, data: 'atas'),
                                  Area(min: .3, flex: .3, data: 'bawah'),
                                ];
                              }
                            }
                          },
                          dividerBuilder: (axis, index, resizable, dragging,
                                  highlighted, themeData) =>
                              Container(
                            margin: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                                color: context.colorScheme.surface,
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
                                                  .getBibleTitle(
                                                      [state.currentBibleSplit],
                                                      splitMode: true),
                                              builder: (context, snapshot) =>
                                                  GestureDetector(
                                                      onTap: () {
                                                        onTapTitle(state, true);
                                                      },
                                                      child: Text(
                                                          snapshot.data ?? '')),
                                            ),
                                            VerticalDivider(),
                                            BlocBuilder<DashboardCubit,
                                                DashboardState>(
                                              builder:
                                                  (context, dashboardState) =>
                                                      PopupMenuButton<int>(
                                                offset: Offset(0, 48),
                                                padding: EdgeInsets.zero,
                                                onSelected: (value) {
                                                  context
                                                      .read<BibleCubit>()
                                                      .selectBibleCode(
                                                          value, true);
                                                },
                                                itemBuilder: (context) =>
                                                    (state.bibleCodes)
                                                        .asMap()
                                                        .entries
                                                        .map((e) {
                                                  var code =
                                                      e.value.split('.').first;
                                                  var index = e.key;
                                                  return PopupMenuItem(
                                                    value: index,
                                                    child: FutureBuilder(
                                                      future: getBibleCodeName(
                                                          code),
                                                      builder:
                                                          (context, snapshot) =>
                                                              Text(
                                                        snapshot.data ?? '',
                                                        maxLines: 1,
                                                        softWrap: false,
                                                        overflow:
                                                            TextOverflow.fade,
                                                        style: TextStyle(),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      state.splitBibleCode
                                                          .split('_')
                                                          .last
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        color: null,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(Icons
                                                        .keyboard_arrow_down),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      lockScroll = !lockScroll;
                                    });
                                    if (lockScroll) {
                                      context.read<BibleCubit>().getContent(
                                            state.currentBible,
                                            mode: VerseMode.bottomOnly,
                                          );
                                    }
                                  },
                                  icon: Icon(
                                    lockScroll ? Icons.lock : Icons.lock_open,
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
                          builder: (context, area) {
                            switch (area.data) {
                              case 'atas':
                                return Listener(
                                  onPointerDown: (event) {
                                    isFirstScrolling = true;
                                  },
                                  child: LayoutBuilder(
                                    builder: (context, constraints) =>
                                        BibleViewer(
                                            textScale: scale,
                                            onScaleStart:
                                                (ScaleStartDetails details) {
                                              _baseScale = _currentScale;
                                            },
                                            onScaleUpdate:
                                                (ScaleUpdateDetails details) {
                                              setState(() {
                                                _currentScale =
                                                    (_baseScale * details.scale)
                                                        .clamp(.8, 2);
                                              });
                                            },
                                            onScaleEnd: (details) {
                                              context
                                                  .read<BibleCubit>()
                                                  .changeTextScale(
                                                      _currentScale);
                                            },
                                            listener: (s, context) {
                                              scrollable = s;
                                              contextBible = context;
                                            },
                                            onVerseVisibility: (index, size,
                                                visiblePercentage) {
                                              maxHeightAtas =
                                                  constraints.maxHeight;
                                              handleScrollTop(index, size,
                                                  visiblePercentage);
                                            },
                                            scrollFunction: (index) {
                                              scrollToVerse(index, true);
                                            },
                                            scrollController: scrollController,
                                            verseKeys: context
                                                .read<BibleCubit>()
                                                .verseKeys,
                                            cubit: context.read(),
                                            isSplit: false,
                                            selectedVerseMenuHeight:
                                                selectedVerseMenuHeight),
                                  ),
                                );
                              case 'bawah':
                                return Listener(
                                  onPointerDown: (event) {
                                    isFirstScrolling = false;
                                  },
                                  child: LayoutBuilder(
                                    builder: (context, constraints) =>
                                        BibleViewer(
                                            textScale: scale,
                                            onScaleStart:
                                                (ScaleStartDetails details) {
                                              _baseScale = _currentScale;
                                            },
                                            onScaleUpdate:
                                                (ScaleUpdateDetails details) {
                                              setState(() {
                                                _currentScale =
                                                    (_baseScale * details.scale)
                                                        .clamp(.8, 2);
                                              });
                                            },
                                            onScaleEnd: (details) {
                                              context
                                                  .read<BibleCubit>()
                                                  .changeTextScale(
                                                      _currentScale);
                                            },
                                            key: splitViewKey,
                                            onVerseVisibility: (index, size,
                                                visiblePercentage) {
                                              maxHeightBawah =
                                                  constraints.maxHeight;
                                              handleScrollBottom(index, size,
                                                  visiblePercentage);
                                            },
                                            listener: (s, context) {
                                              scrollable2 = s;
                                              contextBible2 = context;
                                            },
                                            scrollFunction: (index) {
                                              scrollToVerse(index, true);
                                            },
                                            isSplit: true,
                                            scrollController: scrollController2,
                                            verseKeys: context
                                                .read<BibleCubit>()
                                                .verseKeys2,
                                            cubit: context.read(),
                                            selectedVerseMenuHeight:
                                                selectedVerseMenuHeight),
                                  ),
                                );

                              default:
                                return Container();
                            }
                          },
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
          ),
        ),
      ),
    );
  }
}

class LetterWrapText extends StatelessWidget {
  final String text;
  final TextStyle textStyle;

  const LetterWrapText(
      {super.key, required this.text, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    // Split the text into individual letters.
    final letters = text.split('');

    // Create a list of TextSpans for each letter.
    final letterSpans = letters.map((letter) {
      return Text(
        letter,
        style: textStyle.merge(TextStyle(
          letterSpacing: -.8,
        )),
      );
    }).toList();

    return Wrap(
      alignment: WrapAlignment.center,
      children: letterSpans,
    );
  }
}

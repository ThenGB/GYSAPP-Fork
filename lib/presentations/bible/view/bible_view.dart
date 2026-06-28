// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../components/widgets/swipe_detector_widget.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../domain/entity/bible_book/bible_book.dart';
import '../../../domain/entity/verse/verse.dart';
import '../../../data/utilities/toast_utils.dart';
import '../../../router/router.dart';
import '../../dashboard/cubit/dashboard_cubit.dart';
import '../../dashboard/view/dashboard_view.dart';
import '../../initial/bloc/initial_cubit.dart';
import '../bible.dart';

const double _bibleSplitStatusCompactWidth = 500;

enum _BibleSplitPane { top, bottom }

@RoutePage()
class BibleView extends StatefulWidget {
  const BibleView({super.key});

  @override
  State<BibleView> createState() => _BibleViewState();
}

class _BibleViewState extends State<BibleView> {
  late ScrollController scrollController = ScrollController();
  late ScrollController scrollController2 = ScrollController();
  _BibleSplitPane _activeSplitPane = _BibleSplitPane.top;
  bool _isSyncingSplitScroll = false;
  late bool _splitModeEnable = false;

  bool get splitModeEnable => _splitModeEnable;

  late MultiSplitViewController splitController = MultiSplitViewController(
    areas: [
      Area(min: .3, data: 'atas'),
      if (splitModeEnable) Area(min: .3, data: 'bawah'),
    ],
  );

  set splitModeEnable(bool value) {
    _splitModeEnable = value;

    splitController.areas = List.generate(
      splitModeEnable ? 2 : 1,
      (index) => Area(min: .3, flex: .5, data: index == 0 ? 'atas' : 'bawah'),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
      if (!value) {
        return;
      }

      var state = context.read<BibleCubit>().state;
      var codes = state.bibleCodes;
      if (codes.isEmpty) {
        return;
      }
      var index = codes.indexOf(state.splitBibleCode);

      context.read<BibleCubit>().selectBibleCode(
        index.isNegative ? 0 : index,
        true,
      );
    });
  }

  @override
  void initState() {
    VisibilityDetectorController.instance.updateInterval = Duration(
      microseconds: 1,
    );
    super.initState();
  }

  @override
  void dispose() {
    splitController.dispose();
    scrollController.dispose();
    scrollController2.dispose();
    super.dispose();
  }

  double lastOffset = 0;

  Future<void> scrollToVerse(
    int verseIndex,
    bool playAnimation, [
    bool forSecondView = false,
  ]) async {
    Future.delayed(
      (kThemeAnimationDuration + Duration(milliseconds: 300)),
      () async {
        var verseKeys = forSecondView
            ? context.read<BibleCubit>().verseKeys2
            : context.read<BibleCubit>().verseKeys;

        RenderBox? verseBox =
            verseKeys[verseIndex].currentContext?.findRenderObject()
                as RenderBox?;
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
      },
    );
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
          buildWhen: (prev, curr) =>
              prev.defaultFont != curr.defaultFont ||
              prev.defaultTextScale != curr.defaultTextScale ||
              prev.defaultTextHeight != curr.defaultTextHeight ||
              prev.followGlobalFontSettings !=
                  curr.followGlobalFontSettings,
          builder: (context, state) => BlocBuilder<InitialCubit, InitialState>(
            bloc: context.read<InitialCubit>(),
            buildWhen: (prev, curr) =>
                prev.defaultFont != curr.defaultFont ||
                prev.defaultTextScale != curr.defaultTextScale ||
                prev.defaultTextHeight != curr.defaultTextHeight,
            builder: (context, globalState) => _BibleFontSettingsSheet(
              bibleState: state,
              globalState: globalState,
              onFollowGlobalChanged: (value) {
                context.read<BibleCubit>().toggleFollowGlobalFontSettings(value);
                if (value) {
                  context.read<BibleCubit>().syncFromGlobalFontSettings(
                    globalState.defaultFont,
                    globalState.defaultTextScale,
                    globalState.defaultTextHeight,
                  );
                }
              },
              onFontSelected: (font) {
                context.read<BibleCubit>().changeFont(font);
              },
              onTextScaleChanged: (value) {
                context.read<BibleCubit>().changeTextScale(value);
              },
              onTextHeightChanged: (value) {
                context.read<BibleCubit>().changeTextHeight(value);
              },
            ),
          ),
        ),
      ),
    );
  }

  GlobalKey selectedVerseMenuKey = GlobalKey();

  Future<double> get selectedVerseMenuHeight async =>
      await Future.delayed(Duration(milliseconds: 500), () {
        return selectedVerseMenuKey.currentContext?.size?.height ?? 0;
      });

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final PageStorageBucket _bucket = PageStorageBucket();

  Map<int, double> topVisibleIndexes = {};
  Map<int, double> bottomVisibleIndexes = {};

  GlobalKey splitViewKey = GlobalKey();
  double maxHeightBawah = 0;

  _BibleSplitPane? _pendingSyncPane;
  int? _pendingSyncIndex;
  double? _pendingVisibleFraction;
  double? _pendingVerseHeight;

  void _updateVisibility(
    Map<int, double> visMap,
    int index,
    double fraction,
  ) {
    if (fraction > 0) {
      visMap[index] = fraction;
    } else {
      visMap.remove(index);
    }
  }

  int? _firstVisibleIndex(Map<int, double> visMap) {
    if (visMap.isEmpty) return null;
    return visMap.keys.reduce((a, b) => a < b ? a : b);
  }

  void handleScrollBottom(int index, Size size, double visiblePercentage) {
    if (_activeSplitPane != _BibleSplitPane.bottom) return;
    if (!splitModeEnable || !lockScroll) return;
    if (context.read<BibleCubit>().state.isSplitContentLoading) return;

    _updateVisibility(bottomVisibleIndexes, index, visiblePercentage);

    final firstIdx = _firstVisibleIndex(bottomVisibleIndexes);
    if (firstIdx == null) return;
    final firstFrac = bottomVisibleIndexes[firstIdx]!;

    if (_isSyncingSplitScroll) {
      _pendingSyncPane = _BibleSplitPane.bottom;
      _pendingSyncIndex = firstIdx;
      _pendingVisibleFraction = firstFrac;
      _pendingVerseHeight = size.height;
      return;
    }

    _syncSplitPaneScroll(
      sourcePane: _BibleSplitPane.bottom,
      sourceIndex: firstIdx,
      visibleFraction: firstFrac,
      verseHeight: size.height,
    );
  }

  late ScrollableState scrollable2;
  late ScrollableState scrollable;
  late BuildContext contextBible;
  late BuildContext contextBible2;

  bool lockScroll = true;
  Axis? _splitAxis;
  Axis get splitAxis =>
      _splitAxis ??
      (context.mediaQuery.size.width >= 700 ? Axis.horizontal : Axis.vertical);

  void handleScrollTop(int index, Size size, double visiblePercentage) {
    if (_activeSplitPane != _BibleSplitPane.top) return;
    if (!splitModeEnable || !lockScroll) return;
    if (context.read<BibleCubit>().state.isSplitContentLoading) return;

    _updateVisibility(topVisibleIndexes, index, visiblePercentage);

    final firstIdx = _firstVisibleIndex(topVisibleIndexes);
    if (firstIdx == null) return;
    final firstFrac = topVisibleIndexes[firstIdx]!;

    if (_isSyncingSplitScroll) {
      _pendingSyncPane = _BibleSplitPane.top;
      _pendingSyncIndex = firstIdx;
      _pendingVisibleFraction = firstFrac;
      _pendingVerseHeight = size.height;
      return;
    }

    _syncSplitPaneScroll(
      sourcePane: _BibleSplitPane.top,
      sourceIndex: firstIdx,
      visibleFraction: firstFrac,
      verseHeight: size.height,
    );
  }

  void _setActiveSplitPane(_BibleSplitPane pane) {
    if (_isSyncingSplitScroll) return;
    _activeSplitPane = pane;
  }

  Future<void> _syncSplitPaneScroll({
    required _BibleSplitPane sourcePane,
    required int sourceIndex,
    required double visibleFraction,
    required double verseHeight,
  }) async {
    if (!lockScroll || !splitModeEnable || _isSyncingSplitScroll) {
      return;
    }
    if (context.read<BibleCubit>().state.isSplitContentLoading) {
      return;
    }

    final sourceController = sourcePane == _BibleSplitPane.top
        ? scrollController
        : scrollController2;
    final targetController = sourcePane == _BibleSplitPane.top
        ? scrollController2
        : scrollController;

    if (!sourceController.hasClients || !targetController.hasClients) return;

    final targetVerseKeys = sourcePane == _BibleSplitPane.top
        ? context.read<BibleCubit>().verseKeys2
        : context.read<BibleCubit>().verseKeys;

    if (sourceIndex >= targetVerseKeys.length) return;

    final targetKey = targetVerseKeys[sourceIndex];
    if (targetKey.currentContext == null) return;

    final targetRenderBox =
        targetKey.currentContext!.findRenderObject() as RenderBox?;
    final targetViewport = targetController
        .position.context.storageContext
        .findRenderObject() as RenderBox?;
    if (targetRenderBox == null || targetViewport == null) return;

    final targetGlobal = targetRenderBox.localToGlobal(Offset.zero);
    final viewportGlobal = targetViewport.localToGlobal(Offset.zero);
    final targetVerseOffset =
        targetGlobal.dy - viewportGlobal.dy + targetController.position.pixels;
    final targetVerseHeight = targetRenderBox.size.height;

    final targetScroll =
        targetVerseOffset + targetVerseHeight * (1.0 - visibleFraction);
    final clamped =
        targetScroll.clamp(0.0, targetController.position.maxScrollExtent);

    _isSyncingSplitScroll = true;
    _pendingSyncIndex = null;
    _pendingSyncPane = null;
    _pendingVisibleFraction = null;
    _pendingVerseHeight = null;

    targetController.jumpTo(clamped);

    _isSyncingSplitScroll = false;

    if (_pendingSyncIndex != null && _pendingSyncPane != null) {
      final nextIndex = _pendingSyncIndex!;
      final nextPane = _pendingSyncPane!;
      final nextFrac = _pendingVisibleFraction!;
      final nextHeight = _pendingVerseHeight!;
      _pendingSyncIndex = null;
      _pendingSyncPane = null;
      _pendingVisibleFraction = null;
      _pendingVerseHeight = null;
      _syncSplitPaneScroll(
        sourcePane: nextPane,
        sourceIndex: nextIndex,
        visibleFraction: nextFrac,
        verseHeight: nextHeight,
      );
    }
  }

  late double _currentScale = context.read<BibleCubit>().state.defaultTextScale;
  late double _baseScale = context.read<BibleCubit>().state.defaultTextScale;
  double get scale => _currentScale.clamp(.8, 2);

  void onTapTitle(BibleState state, bool forSecondView) {
    if (context.read<DashboardCubit>().state.isSyncing) {
      safeToastCancel();
      safeShowToast(msg: 'Syncing'.tr());
      return;
    }
    final books = forSecondView ? state.booksSplit : state.books;
    final bibleCode = forSecondView
        ? state.splitBibleCode
        : state.currentBibleCode;
    final textScale = state.defaultTextScale;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colorScheme.surfaceContainerLowest,
      builder: (_) => _VersePickerSheet(
        books: books,
        bibleCode: bibleCode,
        textScale: textScale,
        getBibles: (bookId, chapterId) async {
          if (bookId == null || chapterId == null) return [];
          return await context.read<BibleCubit>().getVersesByBook(
            bookId,
            chapterId,
          );
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
          Navigator.of(context).pop();
          context.read<BibleCubit>().saveToHistory(verse);
          scrollToVerse(verse.verseId - 1, true, forSecondView);
        },
      ),
    );
  }

  Future<void> _openHistoriesDialog() async {
    await showDialog(
      context: context,
      builder: (c) {
        return BlocProvider<BibleCubit>.value(
          value: context.read(),
          child: BlocBuilder<BibleCubit, BibleState>(
            buildWhen: (prev, curr) =>
                prev.histories != curr.histories,
            builder: (context, state) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        'Histories'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const CloseButton(),
                    ),
                    const Divider(height: 1),
                    Flexible(
                      child: state.histories.isEmpty
                          ? ListTile(title: Text('Empty'.tr()))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: state.histories.length,
                              itemBuilder: (context, index) {
                                final history = state.histories.entries
                                    .toList()
                                    .reversed
                                    .toList()[index];
                                return FutureBuilder(
                                  future: context
                                      .read<BibleCubit>()
                                      .getBibleTitle([
                                        history.value,
                                      ], withVerse: true),
                                  builder: (context, snapshot) => ListTile(
                                    title: Text(
                                      snapshot.data ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () {
                                      context.read<BibleCubit>().getContent(
                                        history.value,
                                      );
                                      router.maybePop();
                                      scrollToVerse(
                                        (history.value.verseId - 1).clamp(
                                          0,
                                          9999,
                                        ),
                                        true,
                                      );
                                    },
                                  ),
                                );
                              },
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
  }

  Future<void> _openBibleCodePicker({bool split = false}) async {
    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return BlocBuilder<BibleCubit, BibleState>(
          buildWhen: (prev, curr) =>
              prev.bibleCodes != curr.bibleCodes ||
              prev.currentBibleCode != curr.currentBibleCode ||
              prev.splitBibleCode != curr.splitBibleCode,
          builder: (context, state) => ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(
                  'Bible'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: const CloseButton(),
              ),
              const Divider(height: 1),
              ...state.bibleCodes.asMap().entries.map((e) {
                final index = e.key;
                final code = e.value.split('.').first;
                final selectedCode = split
                    ? state.splitBibleCode
                    : state.currentBibleCode;
                final isSelected = selectedCode == e.value;
                return FutureBuilder(
                  future: getBibleCodeName(code),
                  builder: (context, snapshot) => ListTile(
                    title: Text(snapshot.data ?? e.value),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: context.colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      context.read<BibleCubit>().selectBibleCode(index, split);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCombinedSplitHeader(BibleState state) {
    final colors = context.colorScheme;

    Widget buildPicker(bool secondPane) {
      final codeLabel =
          (secondPane ? state.splitBibleCode : state.currentBibleCode)
              .split('_')
              .last
              .toUpperCase();
      return PopupMenuButton<int>(
        offset: const Offset(0, 48),
        onSelected: (value) {
          context.read<BibleCubit>().selectBibleCode(value, secondPane);
        },
        itemBuilder: (context) => state.bibleCodes.asMap().entries.map((e) {
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
              ),
            ),
          );
        }).toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: colors.surfaceContainer,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                codeLabel,
                style: context.textTheme.labelLarge?.copyWith(
                  color: colors.onSurface,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: colors.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder<List<String>>(
            future: Future.wait([
              context.read<BibleCubit>().getBibleTitle(
                    [state.currentBible],
                  ),
              context.read<BibleCubit>().getBibleTitle(
                    [state.currentBibleSplit],
                    splitMode: true,
                  ),
            ]),
            builder: (context, snapshot) {
              final titles = snapshot.data ?? ['', ''];
              final t1 = titles.isNotEmpty ? titles[0] : '';
              final t2 = titles.length > 1 ? titles[1] : '';
              final combined = (t1.isNotEmpty && t2.isNotEmpty && t1 != t2)
                  ? '$t1 / $t2'
                  : (t1.isNotEmpty ? t1 : t2);
              return Text(
                combined,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.headlineMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 25,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildPicker(false),
              const SizedBox(width: 10),
              buildPicker(true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSplitStatusBar(BibleState state) {
    final colors = context.colorScheme;
    final axisToggle = InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => setState(() {
        _splitAxis = splitAxis == Axis.vertical
            ? Axis.horizontal
            : Axis.vertical;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              splitAxis == Axis.horizontal
                  ? Icons.horizontal_split_rounded
                  : Icons.vertical_split_rounded,
              size: 14,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              splitAxis == Axis.horizontal ? 'Horiz' : 'Vert',
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
    final lockToggle = InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => setState(() {
        lockScroll = !lockScroll;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: lockScroll
              ? colors.primaryContainer
              : colors.surfaceContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          lockScroll ? 'Locked'.tr() : 'Unlocked'.tr(),
          style: context.textTheme.labelSmall?.copyWith(
            color: lockScroll
                ? colors.onPrimaryContainer
                : colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          margin: const EdgeInsets.fromLTRB(18, 12, 18, 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surfaceContainerLowest,
                colors.surfaceContainerLow,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  constraints.maxWidth < _bibleSplitStatusCompactWidth;
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.splitscreen_rounded,
                          size: 16,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Split Reading'.tr(),
                            style: context.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [axisToggle, lockToggle],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Icon(
                    Icons.splitscreen_rounded,
                    size: 16,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Split Reading'.tr(),
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  axisToggle,
                  const SizedBox(width: 6),
                  lockToggle,
                ],
              );
            },
          ),
        ),
      ),
    );
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
                  ? SizedBox(width: double.infinity)
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
            centerTitle: true,
            backgroundColor: context.colorScheme.surface.withValues(
              alpha: 0.88,
            ),
            toolbarHeight: 74,
            leading: IconButton(
              tooltip: 'Menu',
              onPressed: openDashboardDrawer,
              icon: const Icon(Icons.menu_outlined),
            ),
            title: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                final isSplit = splitModeEnable;
                onTapTitle(state, isSplit);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: context.colorScheme.outlineVariant
                        .withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: BlocBuilder<BibleCubit, BibleState>(
                        buildWhen: (prev, curr) =>
                            prev.currentBible != curr.currentBible,
                        builder: (context, bibleState) {
                          final verses = splitModeEnable
                              ? [bibleState.currentBible]
                              : [bibleState.currentBible];
                          return FutureBuilder(
                            future: context.read<BibleCubit>().getBibleTitle(
                                  verses,
                                  splitMode: false,
                                ),
                            builder: (context, snapshot) => Text(
                              snapshot.data ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Search'.tr(),
                onPressed: () {
                  router.push(
                    BibleSearchRoute(
                      onTap: (item) {
                        context.read<BibleCubit>().saveToHistory(item);
                        router.maybePop();
                        context.read<BibleCubit>().getContent(item).then((_) {
                          scrollToVerse(item.verseId - 1, true);
                        });
                      },
                      cubit: context.read(),
                    ),
                  );
                },
                icon: const Icon(Icons.search_rounded),
              ),

              /// more menu
              AnimatedCrossFade(
                alignment: Alignment.center,
                duration: kThemeAnimationDuration,
                crossFadeState: CrossFadeState.showSecond,
                firstChild: const SizedBox(width: 0, height: 48),
                secondChild: BlocBuilder<DashboardCubit, DashboardState>(
                  builder: (context, dashboardState) => dashboardState.isSyncing
                      ? Tooltip(
                          message: 'Syncing'.tr(),
                          child: SizedBox.square(
                            dimension: 32,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation(
                                  context.colorScheme.onSurfaceVariant,
                                ),
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
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          onSelected: (value) async {
                            if (state.selectedVerse.isNotEmpty) {
                              context.read<BibleCubit>().removeSelection();
                              await Future.delayed(
                                kThemeAnimationDuration +
                                    Duration(milliseconds: 500),
                              );
                            }
                            if (value == 'font') {
                              openSettings();
                              return;
                            } else if (value == 'version') {
                              _openBibleCodePicker(split: false);
                              return;
                            } else if (value == 'histories') {
                              _openHistoriesDialog();
                              return;
                            } else if (value == 'notes') {
                              router.push(
                                BibleNoteListRoute(cubit: context.read()),
                              );
                            } else if (value == 'search') {
                              router.push(
                                BibleSearchRoute(
                                  onTap: (item) {
                                    context.read<BibleCubit>().saveToHistory(
                                      item,
                                    );
                                    router.maybePop();
                                    context
                                        .read<BibleCubit>()
                                        .getContent(item)
                                        .then((_) {
                                          scrollToVerse(item.verseId - 1, true);
                                        });
                                  },
                                  cubit: context.read(),
                                ),
                              );
                            }
                            /// split mode
                            else if (value == 'split') {
                              splitModeEnable = !splitModeEnable;
                              safeToastCancel();
                              safeShowToast(
                                msg:
                                    'Split mode ${splitModeEnable ? 'enabled' : 'disabled'}!'
                                        .tr(),
                              );
                            }
                            /// Audio
                            else if (value == 'audio') {
                              context.read<BibleCubit>().toggleAudio();
                            } else if (value == 'lock') {
                              setState(() {
                                lockScroll = !lockScroll;
                              });
                              if (lockScroll) {
                                context.read<BibleCubit>().getContent(
                                  state.currentBible,
                                  mode: VerseMode.bottomOnly,
                                );
                              }
                            } else if (value == 'bookmarkNow') {
                              context.read<BibleCubit>().modifyBookmark();
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
                                              true,
                                            );
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
                              safeShowToast(
                                msg: 'Fitur masih dalam pengembangan',
                              );
                            }
                          },
                          itemBuilder: (context) =>
                              [
                                    ['Version', 'version'],
                                    ['Histories', 'histories'],
                                    ['Font Settings', 'font'],
                                    ['See all notes', 'notes'],
                                    ['Bookmark current chapter', 'bookmarkNow'],
                                    ['See all bookmarks', 'bookmarks'],
                                    ['Lock split scroll', 'lock'],
                                    ['Search', 'search'],
                                    ['Split Mode', 'split'],
                                    ['Audio', 'audio'],
                                  ]
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => PopupMenuItem(
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
                                          ],
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                ),
              ),
            ],
          ),
          floatingActionButton: null,
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.2,
                  ),
                  context.colorScheme.surfaceContainerLow.withValues(
                    alpha: 0.35,
                  ),
                  context.colorScheme.surface,
                ],
              ),
            ),
            child: PageStorage(
              bucket: _bucket,
              child: SwipeDetectorWidget(
                onSwipeLeft: () {
                  context.read<BibleCubit>().nextChapter(
                    null,
                    false,
                    lockScroll ? VerseMode.both : VerseMode.topOnly,
                  );
                },
                onSwipeRight: () {
                  context.read<BibleCubit>().previousChapter(
                    lockScroll ? VerseMode.both : VerseMode.topOnly,
                  );
                },
                child: Column(
                  children: [
                    if (splitModeEnable) _buildSplitStatusBar(state),
                    if (splitModeEnable) _buildCombinedSplitHeader(state),
                    Expanded(
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(textTheme: state.defaultTextTheme),
                        child: MultiSplitViewTheme(
                          data: MultiSplitViewThemeData(
                            dividerThickness: splitAxis == Axis.horizontal
                                ? 14
                                : 20,
                          ),
                          child: MultiSplitView(
                            controller: splitController,
                            antiAliasingWorkaround: true,
                            resizable: true,
                            axis: splitAxis,
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
                            dividerBuilder:
                                (
                                  axis,
                                  index,
                                  resizable,
                                  dragging,
                                  highlighted,
                                  themeData,
                                ) => Container(
                                  color: (highlighted || dragging)
                                      ? context.colorScheme.secondaryContainer
                                            .withValues(alpha: 0.18)
                                      : context.colorScheme.surface,
                                  alignment: Alignment.center,
                                  child: axis == Axis.horizontal
                                      ? Container(
                                          width: 24,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: context
                                                .colorScheme
                                                .surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            border: Border.all(
                                              color: context
                                                  .colorScheme
                                                  .outlineVariant
                                                  .withValues(alpha: 0.55),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.drag_indicator_rounded,
                                            color: context
                                                .colorScheme
                                                .onSurfaceVariant,
                                            size: 16,
                                          ),
                                        )
                                      : Container(
                                          width: 84,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: context
                                                .colorScheme
                                                .surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            border: Border.all(
                                              color: context
                                                  .colorScheme
                                                  .outlineVariant
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Container(
                                            width: 56,
                                            height: 3,
                                            decoration: BoxDecoration(
                                              color: context.colorScheme.outline
                                                  .withValues(alpha: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                          ),
                                        ),
                                ),
                            builder: (context, area) {
                              switch (area.data) {
                                case 'atas':
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: splitAxis == Axis.horizontal
                                            ? BorderSide(
                                                color: context
                                                    .colorScheme
                                                    .outlineVariant
                                                    .withValues(alpha: 0.25),
                                              )
                                            : BorderSide.none,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Listener(
                                            onPointerDown: (_) =>
                                                _setActiveSplitPane(
                                                  _BibleSplitPane.top,
                                                ),
                                            onPointerSignal: (signal) {
                                              if (signal
                                                  is PointerScrollEvent) {
                                                _setActiveSplitPane(
                                                  _BibleSplitPane.top,
                                                );
                                              }
                                            },
                                            child: NotificationListener<ScrollNotification>(
                                              onNotification: (notification) {
                                                if (notification
                                                        is ScrollStartNotification &&
                                                    notification.dragDetails !=
                                                        null) {
                                                  _setActiveSplitPane(
                                                    _BibleSplitPane.top,
                                                  );
                                                }
                                                return false;
                                              },
                                              child: LayoutBuilder(
                                                builder:
                                                    (
                                                      context,
                                                      constraints,
                                                    ) => BibleViewer(
                                                      lockScroll: lockScroll,
                                                      textScale: scale,
                                                      onScaleStart:
                                                          (
                                                            ScaleStartDetails
                                                            details,
                                                          ) {
                                                            _baseScale =
                                                                _currentScale;
                                                          },
                                                      onScaleUpdate:
                                                          (
                                                            ScaleUpdateDetails
                                                            details,
                                                          ) {
                                                            setState(() {
                                                              _currentScale =
                                                                  (_baseScale *
                                                                          details
                                                                              .scale)
                                                                      .clamp(
                                                                        .8,
                                                                        2,
                                                                      );
                                                            });
                                                          },
                                                      onScaleEnd: (details) {
                                                        context
                                                            .read<BibleCubit>()
                                                            .changeTextScale(
                                                              _currentScale,
                                                            );
                                                      },
                                                      listener: (s, context) {
                                                        scrollable = s;
                                                        contextBible = context;
                                                      },
                                                      onVerseVisibility:
                                                          (
                                                            index,
                                                            size,
                                                            visiblePercentage,
                                                          ) {
                                                            handleScrollTop(
                                                              index,
                                                              size,
                                                              visiblePercentage,
                                                            );
                                                          },
                                                      scrollFunction: (index) {
                                                        scrollToVerse(
                                                          index,
                                                          true,
                                                          false,
                                                        );
                                                      },
                                                      scrollController:
                                                          scrollController,
                                                      verseKeys: context
                                                          .read<BibleCubit>()
                                                          .verseKeys,
                                                      cubit: context.read(),
                                                      isSplit: false,
                                                      selectedVerseMenuHeight:
                                                          selectedVerseMenuHeight,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                case 'bawah':
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: splitAxis == Axis.vertical
                                            ? BorderSide(
                                                color: context
                                                    .colorScheme
                                                    .outlineVariant
                                                    .withValues(alpha: 0.25),
                                              )
                                            : BorderSide.none,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Listener(
                                            onPointerDown: (_) =>
                                                _setActiveSplitPane(
                                                  _BibleSplitPane.bottom,
                                                ),
                                            onPointerSignal: (signal) {
                                              if (signal
                                                  is PointerScrollEvent) {
                                                _setActiveSplitPane(
                                                  _BibleSplitPane.bottom,
                                                );
                                              }
                                            },
                                            child: NotificationListener<ScrollNotification>(
                                              onNotification: (notification) {
                                                if (notification
                                                        is ScrollStartNotification &&
                                                    notification.dragDetails !=
                                                        null) {
                                                  _setActiveSplitPane(
                                                    _BibleSplitPane.bottom,
                                                  );
                                                }
                                                return false;
                                              },
                                              child: LayoutBuilder(
                                                builder:
                                                    (
                                                      context,
                                                      constraints,
                                                    ) => BibleViewer(
                                                      lockScroll: lockScroll,
                                                      textScale: scale,
                                                      onScaleStart:
                                                          (
                                                            ScaleStartDetails
                                                            details,
                                                          ) {
                                                            _baseScale =
                                                                _currentScale;
                                                          },
                                                      onScaleUpdate:
                                                          (
                                                            ScaleUpdateDetails
                                                            details,
                                                          ) {
                                                            setState(() {
                                                              _currentScale =
                                                                  (_baseScale *
                                                                          details
                                                                              .scale)
                                                                      .clamp(
                                                                        .8,
                                                                        2,
                                                                      );
                                                            });
                                                          },
                                                      onScaleEnd: (details) {
                                                        context
                                                            .read<BibleCubit>()
                                                            .changeTextScale(
                                                              _currentScale,
                                                            );
                                                      },
                                                      key: splitViewKey,
                                                      onVerseVisibility:
                                                          (
                                                            index,
                                                            size,
                                                            visiblePercentage,
                                                          ) {
                                                            handleScrollBottom(
                                                              index,
                                                              size,
                                                              visiblePercentage,
                                                            );
                                                          },
                                                      listener: (s, context) {
                                                        scrollable2 = s;
                                                        contextBible2 = context;
                                                      },
                                                      scrollFunction: (index) {
                                                        scrollToVerse(
                                                          index,
                                                          true,
                                                          true,
                                                        );
                                                      },
                                                      isSplit: true,
                                                      scrollController:
                                                          scrollController2,
                                                      verseKeys: context
                                                          .read<BibleCubit>()
                                                          .verseKeys2,
                                                      cubit: context.read(),
                                                      selectedVerseMenuHeight:
                                                          selectedVerseMenuHeight,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
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

class LetterWrapText extends StatelessWidget {
  final String text;
  final TextStyle textStyle;

  const LetterWrapText({
    super.key,
    required this.text,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Split the text into individual letters.
    final letters = text.split('');

    // Create a list of TextSpans for each letter.
    final letterSpans = letters.map((letter) {
      return Text(
        letter,
        style: textStyle.merge(TextStyle(letterSpacing: -.8)),
      );
    }).toList();

    return Wrap(alignment: WrapAlignment.center, children: letterSpans);
  }
}

class _VersePickerSheet extends StatefulWidget {
  final List<BibleBook> books;
  final String bibleCode;
  final double textScale;
  final Future<List<Verse>> Function(int? bookId, int? chapterId) getBibles;
  final Function(Verse verse) onSelected;

  const _VersePickerSheet({
    required this.books,
    required this.bibleCode,
    required this.textScale,
    required this.getBibles,
    required this.onSelected,
  });

  @override
  State<_VersePickerSheet> createState() => _VersePickerSheetState();
}

class _VersePickerSheetState extends State<_VersePickerSheet> {
  int _step = 0;
  BibleBook? _selectedBook;
  int? _selectedChapter;

  void _pickBook(BibleBook book) {
    setState(() {
      _selectedBook = book;
      _step = 1;
    });
  }

  void _pickChapter(int chapter) {
    setState(() {
      _selectedChapter = chapter;
      _step = 2;
    });
  }

  void _back() {
    if (_step > 0) {
      setState(() {
        if (_step == 2) {
          _selectedChapter = null;
        } else if (_step == 1) {
          _selectedBook = null;
        }
        _step--;
      });
    }
  }

  String get _title {
    switch (_step) {
      case 0:
        return 'Pilih Kitab';
      case 1:
        return '${_selectedBook?.longName ?? ''} — Pilih Pasal';
      case 2:
        return '${_selectedBook?.longName ?? ''} ${_selectedChapter ?? ''} — Pilih Ayat';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
              child: Row(
                children: [
                  if (_step > 0)
                    IconButton(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back_rounded),
                    )
                  else
                    const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: IndexedStack(
                index: _step,
                children: [
                  _buildBookList(scrollController, colors),
                  _buildChapterGrid(scrollController, colors),
                  _buildVerseGrid(scrollController, colors),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookList(ScrollController scrollController, ColorScheme colors) {
    final oldTestament = widget.books.sublist(0, 39.clamp(0, widget.books.length));
    final newTestament = widget.books.length > 39
        ? widget.books.sublist(39)
        : <BibleBook>[];

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 4),
          child: Text(
            'Perjanjian Lama',
            style: context.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: oldTestament.map((book) => _bookChip(book, colors)).toList(),
        ),
        if (newTestament.isNotEmpty) ...[
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Text(
              'Perjanjian Baru',
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: newTestament.map((book) => _bookChip(book, colors)).toList(),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _bookChip(BibleBook book, ColorScheme colors) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _pickBook(book),
      child: Container(
        width: 56,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: colors.surfaceContainerLow,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          book.shortName ?? '',
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChapterGrid(ScrollController scrollController, ColorScheme colors) {
    final count = _selectedBook?.chapterCount ?? 0;
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.2,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        final chapterNum = index + 1;
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _pickChapter(chapterNum),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: colors.surfaceContainerLow,
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              '$chapterNum',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerseGrid(ScrollController scrollController, ColorScheme colors) {
    return FutureBuilder<List<Verse>>(
      future: widget.getBibles(_selectedBook?.id, _selectedChapter),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final verses = snapshot.data!;
        return GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.2,
          ),
          itemCount: verses.length,
          itemBuilder: (context, index) {
            final verse = verses[index];
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => widget.onSelected(verse),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colors.surfaceContainerLow,
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${verse.verseId}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BibleFontSettingsSheet extends StatefulWidget {
  final BibleState bibleState;
  final InitialState globalState;
  final ValueChanged<bool> onFollowGlobalChanged;
  final ValueChanged<String> onFontSelected;
  final ValueChanged<double> onTextScaleChanged;
  final ValueChanged<double> onTextHeightChanged;

  const _BibleFontSettingsSheet({
    required this.bibleState,
    required this.globalState,
    required this.onFollowGlobalChanged,
    required this.onFontSelected,
    required this.onTextScaleChanged,
    required this.onTextHeightChanged,
  });

  @override
  State<_BibleFontSettingsSheet> createState() => _BibleFontSettingsSheetState();
}

class _BibleFontSettingsSheetState extends State<_BibleFontSettingsSheet> {
  bool _isSelectingFont = false;

  String get _effectiveFont => widget.bibleState.followGlobalFontSettings
      ? widget.globalState.defaultFont
      : widget.bibleState.defaultFont;
  double get _effectiveScale => widget.bibleState.followGlobalFontSettings
      ? widget.globalState.defaultTextScale
      : widget.bibleState.defaultTextScale;
  double get _effectiveHeight => widget.bibleState.followGlobalFontSettings
      ? widget.globalState.defaultTextHeight
      : widget.bibleState.defaultTextHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.7,
      minChildSize: 0.3,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                blurRadius: 160,
                color: Colors.black.withValues(alpha: .2),
              ),
            ],
            color: colors.surface,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_isSelectingFont) ...[
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: EdgeInsets.zero,
                      leading: BackButton(
                        onPressed: () {
                          setState(() {
                            _isSelectingFont = false;
                          });
                        },
                      ),
                    ),
                    Divider(),
                    ...widget.bibleState.availableFonts.map(
                      (e) => ListTile(
                        title: Text(
                          e,
                          style: TextStyle(
                            fontFamily: e,
                            color: e == _effectiveFont
                                ? colors.primary
                                : colors.onSurfaceVariant,
                            fontWeight: e == _effectiveFont
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        onTap: widget.bibleState.followGlobalFontSettings
                            ? null
                            : () {
                                widget.onFontSelected(e);
                                setState(() {
                                  _isSelectingFont = false;
                                });
                              },
                        enabled: !widget.bibleState.followGlobalFontSettings,
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          SwitchListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                width: 1,
                                color: colors.outlineVariant,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            title: Text(
                              'Ikuti pengaturan utama',
                              style: context.textTheme.bodyMedium,
                            ),
                            subtitle: Text(
                              'Gunakan font, ukuran, dan jarak dari pengaturan aplikasi',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            value: widget.bibleState.followGlobalFontSettings,
                            onChanged: widget.onFollowGlobalChanged,
                          ),
                          const SizedBox(height: 16),
                          Opacity(
                            opacity: widget.bibleState.followGlobalFontSettings ? 0.5 : 1.0,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        colors.primary,
                                        BlendMode.srcIn,
                                      ),
                                      child: Image.asset(
                                        'assets/icons/font_size_min.png',
                                        width: 24,
                                      ),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        value: _effectiveScale,
                                        min: 0.8,
                                        max: 2.0,
                                        onChanged: widget.bibleState.followGlobalFontSettings
                                            ? null
                                            : (value) {
                                                widget.onTextScaleChanged(value);
                                              },
                                      ),
                                    ),
                                    ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        colors.primary,
                                        BlendMode.srcIn,
                                      ),
                                      child: Image.asset(
                                        'assets/icons/font_size_plus.png',
                                        width: 24,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        colors.primary,
                                        BlendMode.srcIn,
                                      ),
                                      child: Image.asset(
                                        'assets/icons/font_gap_min.png',
                                        width: 24,
                                      ),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        value: _effectiveHeight,
                                        min: 1.0,
                                        max: 2.5,
                                        onChanged: widget.bibleState.followGlobalFontSettings
                                            ? null
                                            : (value) {
                                                widget.onTextHeightChanged(value);
                                              },
                                      ),
                                    ),
                                    ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        colors.primary,
                                        BlendMode.srcIn,
                                      ),
                                      child: Image.asset(
                                        'assets/icons/font_gap_plus.png',
                                        width: 24,
                                      ),
                                    ),
                                  ],
                                ),
                                ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      width: 1,
                                      color: colors.outlineVariant,
                                    ),
                                  ),
                                  titleTextStyle: context.textTheme.bodyMedium
                                      ?.copyWith(fontSize: 10),
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: EdgeInsets.only(left: 16),
                                  title: Text(
                                    'Font',
                                    style: context.textTheme.bodySmall,
                                  ),
                                  subtitle: Text(
                                    _effectiveFont,
                                    style: context.textTheme.bodyMedium?.copyWith(
                                      fontFamily: _effectiveFont,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.keyboard_arrow_right,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  onTap: widget.bibleState.followGlobalFontSettings
                                      ? null
                                      : () {
                                          setState(() {
                                            _isSelectingFont = true;
                                          });
                                        },
                                  enabled: !widget.bibleState.followGlobalFontSettings,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(
                    height: 16 + context.mediaQuery.viewPadding.vertical,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

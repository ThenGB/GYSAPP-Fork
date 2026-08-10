import '../../../components/components.dart';
// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../components/widgets/swipe_detector_widget.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/toast_utils.dart';
import '../../../domain/entity/bible_book/bible_book.dart';
import '../../../domain/entity/verse/verse.dart';
import '../../../router/router.dart';
import '../../dashboard/cubit/dashboard_cubit.dart';
import '../../dashboard/view/dashboard_view.dart';
import '../widgets/bible_audio_sidebar.dart';
import '../../initial/bloc/initial_cubit.dart';
import '../bible.dart';

enum _BibleSplitPane { top, bottom }

const double kBibleSplitMinRatio = 0.26;
const double kBibleSplitMaxRatio = 0.74;

double normalizeBibleSplitRatio(double? value) {
  if (value == null || !value.isFinite) return 0.5;
  return value.clamp(kBibleSplitMinRatio, kBibleSplitMaxRatio).toDouble();
}

int bibleQuickBookIndexForPosition({
  required Offset globalPosition,
  required Rect panelRect,
  required int bookCount,
  required int columnCount,
}) {
  if (bookCount <= 0 || columnCount <= 0 || panelRect.isEmpty) return -1;
  final columns = columnCount.clamp(1, bookCount).toInt();
  final rows = (bookCount + columns - 1) ~/ columns;
  final x = globalPosition.dx
      .clamp(panelRect.left, panelRect.right - 0.001)
      .toDouble();
  final y = globalPosition.dy
      .clamp(panelRect.top, panelRect.bottom - 0.001)
      .toDouble();
  final column = ((x - panelRect.left) / (panelRect.width / columns)).floor();
  final row = ((y - panelRect.top) / (panelRect.height / rows)).floor();
  return (row * columns + column).clamp(0, bookCount - 1).toInt();
}

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
  double _splitRatio = 0.5;
  OverlayEntry? _quickBookOverlay;
  ValueNotifier<int>? _quickBookIndex;
  bool _quickBookUsesSecondPane = false;

  bool get splitModeEnable => _splitModeEnable;

  late MultiSplitViewController splitController = MultiSplitViewController(
    areas: [
      Area(min: kBibleSplitMinRatio, data: 'atas'),
      if (splitModeEnable) Area(min: kBibleSplitMinRatio, data: 'bawah'),
    ],
  );

  set splitModeEnable(bool value) {
    _splitModeEnable = value;

    splitController.areas = List.generate(
      splitModeEnable ? 2 : 1,
      (index) => Area(
        min: kBibleSplitMinRatio,
        flex: splitModeEnable
            ? (index == 0 ? _splitRatio : 1 - _splitRatio)
            : 1,
        data: index == 0 ? 'atas' : 'bawah',
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
      if (!value) {
        _activeSplitPane = _BibleSplitPane.top;
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
    VisibilityDetectorController.instance.updateInterval = const Duration(
      milliseconds: 50,
    );
    super.initState();
  }

  @override
  void dispose() {
    _dismissQuickBookScrubber();
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
        if (verseIndex < 0 || verseIndex >= verseKeys.length) return;

        RenderBox? verseBox =
            verseKeys[verseIndex].currentContext?.findRenderObject()
                as RenderBox?;
        if (verseBox == null) return;

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
              prev.followGlobalFontSettings != curr.followGlobalFontSettings,
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
                context.read<BibleCubit>().toggleFollowGlobalFontSettings(
                  value,
                );
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
  _BibleSplitPane? _lastSyncedPane;
  int? _lastSyncedIndex;
  double? _lastSyncedFraction;
  double _bookHeaderDragDx = 0;

  void _updateVisibility(Map<int, double> visMap, int index, double fraction) {
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
      return;
    }

    _syncSplitPaneScroll(
      sourcePane: _BibleSplitPane.bottom,
      sourceIndex: firstIdx,
      visibleFraction: firstFrac,
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
      return;
    }

    _syncSplitPaneScroll(
      sourcePane: _BibleSplitPane.top,
      sourceIndex: firstIdx,
      visibleFraction: firstFrac,
    );
  }

  void _setActiveSplitPane(_BibleSplitPane pane) {
    if (_isSyncingSplitScroll) return;
    if (_activeSplitPane != pane && mounted) {
      setState(() => _activeSplitPane = pane);
    } else {
      _activeSplitPane = pane;
    }
  }

  Future<void> _syncSplitPaneScroll({
    required _BibleSplitPane sourcePane,
    required int sourceIndex,
    required double visibleFraction,
  }) async {
    if (!lockScroll || !splitModeEnable || _isSyncingSplitScroll) return;
    final cubit = context.read<BibleCubit>();
    final bibleState = cubit.state;
    if (bibleState.isSplitContentLoading) return;

    final sourceController = sourcePane == _BibleSplitPane.top
        ? scrollController
        : scrollController2;
    final targetController = sourcePane == _BibleSplitPane.top
        ? scrollController2
        : scrollController;
    if (!sourceController.hasClients || !targetController.hasClients) return;

    final sourceVerses = sourcePane == _BibleSplitPane.top
        ? bibleState.verses
        : bibleState.versesSplit;
    final targetVerses = sourcePane == _BibleSplitPane.top
        ? bibleState.versesSplit
        : bibleState.verses;
    if (sourceIndex < 0 || sourceIndex >= sourceVerses.length) return;
    final sourceVerse = sourceVerses[sourceIndex];
    final targetIndex = targetVerses.indexWhere(
      (verse) => verse.verseId == sourceVerse.verseId,
    );
    if (targetIndex < 0) return;

    if (_lastSyncedPane == sourcePane &&
        _lastSyncedIndex == sourceIndex &&
        _lastSyncedFraction != null &&
        (_lastSyncedFraction! - visibleFraction).abs() < 0.025) {
      return;
    }

    final targetVerseKeys = sourcePane == _BibleSplitPane.top
        ? cubit.verseKeys2
        : cubit.verseKeys;
    if (targetIndex >= targetVerseKeys.length) return;
    final targetKey = targetVerseKeys[targetIndex];
    if (targetKey.currentContext == null) return;

    final targetRenderBox =
        targetKey.currentContext!.findRenderObject() as RenderBox?;
    final targetViewport =
        targetController.position.context.storageContext.findRenderObject()
            as RenderBox?;
    if (targetRenderBox == null || targetViewport == null) return;

    final targetGlobal = targetRenderBox.localToGlobal(Offset.zero);
    final viewportGlobal = targetViewport.localToGlobal(Offset.zero);
    final targetVerseOffset =
        targetGlobal.dy - viewportGlobal.dy + targetController.position.pixels;
    final targetScroll =
        targetVerseOffset + targetRenderBox.size.height * (1.0 - visibleFraction);
    final clamped = targetScroll
        .clamp(0.0, targetController.position.maxScrollExtent)
        .toDouble();

    if ((targetController.position.pixels - clamped).abs() < 1.0) return;

    _isSyncingSplitScroll = true;
    _pendingSyncIndex = null;
    _pendingSyncPane = null;
    _pendingVisibleFraction = null;
    try {
      await targetController.animateTo(
        clamped,
        duration: const Duration(milliseconds: 48),
        curve: Curves.linearToEaseOut,
      );
      _lastSyncedPane = sourcePane;
      _lastSyncedIndex = sourceIndex;
      _lastSyncedFraction = visibleFraction;
    } catch (_) {
      // Pane may disappear while an animation is in flight.
    } finally {
      _isSyncingSplitScroll = false;
    }

    if (_pendingSyncIndex != null && _pendingSyncPane != null) {
      final nextIndex = _pendingSyncIndex!;
      final nextPane = _pendingSyncPane!;
      final nextFrac = _pendingVisibleFraction ?? 1.0;
      _pendingSyncIndex = null;
      _pendingSyncPane = null;
      _pendingVisibleFraction = null;
      await _syncSplitPaneScroll(
        sourcePane: nextPane,
        sourceIndex: nextIndex,
        visibleFraction: nextFrac,
      );
    }
  }

  late double _currentScale = context.read<BibleCubit>().state.defaultTextScale;
  late double _baseScale = context.read<BibleCubit>().state.defaultTextScale;
  double get scale => _currentScale.clamp(.8, 2).toDouble();

  bool get _headerUsesSecondPane =>
      splitModeEnable && !lockScroll && _activeSplitPane == _BibleSplitPane.bottom;

  void _onBookHeaderDragStart(DragStartDetails details) {
    _bookHeaderDragDx = 0;
  }

  void _onBookHeaderDragUpdate(DragUpdateDetails details) {
    _bookHeaderDragDx += details.delta.dx;
  }

  Future<void> _onBookHeaderDragEnd(
    BibleState state,
    DragEndDetails details,
  ) async {
    if (context.read<DashboardCubit>().state.isSyncing) return;

    final secondPane = _headerUsesSecondPane;
    final books = secondPane ? state.booksSplit : state.books;
    final current = secondPane ? state.currentBibleSplit : state.currentBible;
    if (books.isEmpty || current == null) return;

    final currentIndex = books.indexWhere((book) => book.id == current.bookId);
    if (currentIndex < 0) return;

    final velocity = details.primaryVelocity ?? 0.0;
    final projected = _bookHeaderDragDx + velocity * 0.10;
    _bookHeaderDragDx = 0;
    if (projected.abs() < 28) return;

    final steps = (projected.abs() / 52).round().clamp(1, 12).toInt();
    final direction = projected < 0 ? 1 : -1;
    final targetIndex = (currentIndex + direction * steps)
        .clamp(0, books.length - 1)
        .toInt();
    if (targetIndex == currentIndex) return;

    await _openBookAtIndex(state, targetIndex, secondPane: secondPane);
  }

  Future<void> _openBookAtIndex(
    BibleState state,
    int targetIndex, {
    required bool secondPane,
  }) async {
    final books = secondPane ? state.booksSplit : state.books;
    if (targetIndex < 0 || targetIndex >= books.length) return;

    final targetBook = books[targetIndex];
    final target = Verse(
      id: targetBook.id * 1000000 + 1001,
      bookId: targetBook.id,
      chapterId: 1,
      verseId: 1,
    );
    final mode = splitModeEnable && lockScroll
        ? VerseMode.both
        : secondPane
        ? VerseMode.bottomOnly
        : VerseMode.topOnly;

    final cubit = context.read<BibleCubit>();
    await cubit.getContent(target, mode: mode);
    if (!mounted) return;
    cubit.saveToHistory(target);
    topVisibleIndexes.clear();
    bottomVisibleIndexes.clear();
    _lastSyncedPane = null;
    _lastSyncedIndex = null;
    _lastSyncedFraction = null;

    if (mode != VerseMode.bottomOnly && scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
    if (mode != VerseMode.topOnly && scrollController2.hasClients) {
      scrollController2.jumpTo(0);
    }
  }

  Rect _quickBookPanelRect() {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final navHeight = MediaQuery.orientationOf(context) == Orientation.landscape
        ? kDashboardLandscapeBottomNavHeight
        : kDashboardPortraitBottomNavHeight;
    return Rect.fromLTRB(
      12,
      padding.top + 64,
      size.width - 12,
      size.height - padding.bottom - navHeight - 12,
    );
  }

  Rect _quickBookGridRect(Rect panelRect) => Rect.fromLTRB(
    panelRect.left,
    panelRect.top + 52,
    panelRect.right,
    panelRect.bottom,
  );

  int _quickBookColumnCount(Rect panelRect) => panelRect.width >= 600 ? 4 : 3;

  void _showQuickBookScrubber(
    BibleState state,
    LongPressStartDetails _,
  ) {
    if (context.read<DashboardCubit>().state.isSyncing) return;
    final secondPane = _headerUsesSecondPane;
    final books = secondPane ? state.booksSplit : state.books;
    final current = secondPane ? state.currentBibleSplit : state.currentBible;
    if (books.isEmpty || current == null) return;

    _dismissQuickBookScrubber();
    final currentIndex = books.indexWhere((book) => book.id == current.bookId);
    final selected = ValueNotifier<int>(currentIndex < 0 ? 0 : currentIndex);
    final panelRect = _quickBookPanelRect();
    final columns = _quickBookColumnCount(panelRect);
    _quickBookUsesSecondPane = secondPane;
    _quickBookIndex = selected;
    _quickBookOverlay = OverlayEntry(
      builder: (overlayContext) => _BibleQuickBookScrubber(
        books: books,
        selectedIndex: selected,
        panelRect: panelRect,
        columnCount: columns,
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_quickBookOverlay!);
    HapticFeedback.mediumImpact();
  }

  void _updateQuickBookScrubber(LongPressMoveUpdateDetails details) {
    final selected = _quickBookIndex;
    final overlay = _quickBookOverlay;
    if (selected == null || overlay == null) return;
    final state = context.read<BibleCubit>().state;
    final books = _quickBookUsesSecondPane ? state.booksSplit : state.books;
    final panelRect = _quickBookPanelRect();
    final nextIndex = bibleQuickBookIndexForPosition(
      globalPosition: details.globalPosition,
      panelRect: _quickBookGridRect(panelRect),
      bookCount: books.length,
      columnCount: _quickBookColumnCount(panelRect),
    );
    if (nextIndex >= 0 && nextIndex != selected.value) {
      selected.value = nextIndex;
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _finishQuickBookScrubber(LongPressEndDetails _) async {
    final targetIndex = _quickBookIndex?.value;
    final secondPane = _quickBookUsesSecondPane;
    _dismissQuickBookScrubber();
    if (targetIndex == null) return;
    await _openBookAtIndex(
      context.read<BibleCubit>().state,
      targetIndex,
      secondPane: secondPane,
    );
  }

  void _dismissQuickBookScrubber() {
    _quickBookOverlay?.remove();
    _quickBookOverlay = null;
    _quickBookIndex?.dispose();
    _quickBookIndex = null;
  }

  Future<void> _toggleSplitLock(BibleState state) async {
    setState(() => lockScroll = !lockScroll);
    if (lockScroll) {
      await context.read<BibleCubit>().getContent(
        state.currentBible,
        mode: VerseMode.bottomOnly,
      );
    }
  }

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
      enableDrag: true,
      isDismissible: true,
      showDragHandle: true,
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
            buildWhen: (prev, curr) => prev.histories != curr.histories,
            builder: (context, state) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: context.appRadius(12),
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
                          : Builder(
                              builder: (context) {
                                final historyEntries = state.histories.entries
                                    .toList()
                                    .reversed
                                    .toList();
                                final titleFutures =
                                    <DateTime, Future<String?>>{
                                      for (final entry in historyEntries)
                                        entry.key: context
                                            .read<BibleCubit>()
                                            .getBibleTitle([
                                              entry.value,
                                            ], withVerse: true),
                                    };
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: historyEntries.length,
                                  itemBuilder: (context, index) {
                                    final history = historyEntries[index];
                                    return FutureBuilder(
                                      future: titleFutures[history.key],
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
                                            (history.value.verseId - 1)
                                                .clamp(0, 9999)
                                                .toInt(),
                                            true,
                                          );
                                        },
                                      ),
                                    );
                                  },
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
    final cubit = context.read<BibleCubit>();
    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => BlocProvider<BibleCubit>.value(
        value: cubit,
        child: BlocBuilder<BibleCubit, BibleState>(
          buildWhen: (prev, curr) =>
              prev.bibleCodes != curr.bibleCodes ||
              prev.currentBibleCode != curr.currentBibleCode ||
              prev.splitBibleCode != curr.splitBibleCode,
          builder: (context, state) => ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Text(
                  'Bible'.tr(),
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
        ),
      ),
    );
  }

  Widget _buildBibleCodePicker(BibleState state, bool secondPane) {
    final codeLabel =
        (secondPane ? state.splitBibleCode : state.currentBibleCode)
            .split('_')
            .last
            .toUpperCase();
    final isActive = !splitModeEnable
        ? !secondPane
        : secondPane
        ? _activeSplitPane == _BibleSplitPane.bottom
        : _activeSplitPane == _BibleSplitPane.top;
    return PopupMenuButton<int>(
      offset: const Offset(0, 48),
      borderRadius: BorderRadius.all(Radius.circular(16)),
      onSelected: (value) {
        _setActiveSplitPane(
          secondPane ? _BibleSplitPane.bottom : _BibleSplitPane.top,
        );
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: context.appRadius(16),
          color: isActive
              ? context.colorScheme.primaryContainer.withValues(alpha: 0.55)
              : context.colorScheme.surfaceContainerHigh.withValues(alpha: 0.7),
          border: Border.all(
            color: isActive
                ? context.colorScheme.primary.withValues(alpha: 0.35)
                : context.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? context.colorScheme.primary
                    : context.colorScheme.outlineVariant,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              codeLabel,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildSplitPaneHeader(BibleState state, bool secondPane) {
    final colors = context.colorScheme;
    final codeLabel =
        (secondPane ? state.splitBibleCode : state.currentBibleCode)
            .split('_')
            .last
            .toUpperCase();
    final active = secondPane
        ? _activeSplitPane == _BibleSplitPane.bottom
        : _activeSplitPane == _BibleSplitPane.top;
    final current = secondPane ? state.currentBibleSplit : state.currentBible;
    final books = secondPane ? state.booksSplit : state.books;
    final bookIndex = current == null
        ? -1
        : books.indexWhere((book) => book.id == current.bookId);
    final bookLabel = bookIndex < 0
        ? 'Alkitab'
        : books[bookIndex].longName ?? books[bookIndex].shortName ?? 'Alkitab';
    final chapterLabel = current?.chapterId == null
        ? bookLabel
        : '$bookLabel ${current!.chapterId}';
    return InkWell(
      onTap: () => _setActiveSplitPane(
        secondPane ? _BibleSplitPane.bottom : _BibleSplitPane.top,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.only(left: 12, right: 4, top: 3, bottom: 3),
        color: active
            ? colors.primaryContainer.withValues(alpha: 0.22)
            : colors.surfaceContainerLow.withValues(alpha: 0.6),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? colors.primary
                    : secondPane
                    ? colors.tertiary
                    : colors.outline,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                chapterLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: active ? colors.onSurface : colors.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _setActiveSplitPane(
                  secondPane
                      ? _BibleSplitPane.bottom
                      : _BibleSplitPane.top,
                );
                _openBibleCodePicker(split: secondPane);
              },
              style: TextButton.styleFrom(
                minimumSize: const Size(38, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(
                codeLabel,
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ),
            if (active)
              PopupMenuButton<String>(
                tooltip: 'Opsi panel Alkitab',
                padding: EdgeInsets.zero,
                iconSize: 18,
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: (value) {
                  if (value == 'axis') {
                    setState(() {
                      _splitAxis = splitAxis == Axis.vertical
                          ? Axis.horizontal
                          : Axis.vertical;
                    });
                  } else if (value == 'lock') {
                    _toggleSplitLock(state);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'axis',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        splitAxis == Axis.horizontal
                            ? Icons.horizontal_split_rounded
                            : Icons.vertical_split_rounded,
                      ),
                      title: const Text('Ubah arah panel'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'lock',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        lockScroll
                            ? Icons.lock_rounded
                            : Icons.lock_open_rounded,
                      ),
                      title: Text(
                        lockScroll ? 'Lepaskan sinkronisasi' : 'Sinkronkan panel',
                      ),
                    ),
                  ),
                ],
              ),
          ],
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
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            shadowColor: Colors.transparent,
            toolbarHeight: 60,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colorScheme.surface,
                    context.colorScheme.surface.withValues(alpha: 0.94),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: context.colorScheme.outlineVariant.withValues(
                      alpha: 0.35,
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              tooltip: 'Menu',
              onPressed: openDashboardDrawer,
              icon: const Icon(Icons.menu_outlined),
            ),
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message:
                        'Ketuk untuk memilih • geser untuk pindah • tahan untuk semua kitab',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: _onBookHeaderDragStart,
                      onHorizontalDragUpdate: _onBookHeaderDragUpdate,
                      onHorizontalDragEnd: (details) =>
                          _onBookHeaderDragEnd(state, details),
                      onLongPressStart: (details) =>
                          _showQuickBookScrubber(state, details),
                      onLongPressMoveUpdate: _updateQuickBookScrubber,
                      onLongPressEnd: _finishQuickBookScrubber,
                      onLongPressCancel: _dismissQuickBookScrubber,
                      child: InkWell(
                        borderRadius: context.appRadius(16),
                        onTap: () => onTapTitle(state, _headerUsesSecondPane),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: context.appRadius(16),
                            color: context.colorScheme.surfaceContainerHigh
                                .withValues(alpha: 0.7),
                            border: Border.all(
                              color: context.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: context.colorScheme.shadow.withValues(
                                  alpha: 0.05,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_stories_rounded,
                                size: 18,
                                color: context.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              BlocBuilder<BibleCubit, BibleState>(
                                buildWhen: (prev, curr) =>
                                    prev.currentBible != curr.currentBible ||
                                    prev.currentBibleSplit !=
                                        curr.currentBibleSplit,
                                builder: (context, bibleState) {
                                  final secondPane = _headerUsesSecondPane;
                                  final verses = [
                                    secondPane
                                        ? bibleState.currentBibleSplit
                                        : bibleState.currentBible,
                                  ];
                                  return FutureBuilder(
                                    future: context
                                        .read<BibleCubit>()
                                        .getBibleTitle(
                                          verses,
                                          splitMode: secondPane,
                                        ),
                                    builder: (context, snapshot) => Text(
                                      snapshot.data ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.swap_horiz_rounded,
                                color: context.colorScheme.onSurfaceVariant,
                                size: 19,
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: context.colorScheme.onSurfaceVariant,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!splitModeEnable)
                    BlocBuilder<BibleCubit, BibleState>(
                    buildWhen: (prev, curr) =>
                        prev.currentBibleCode != curr.currentBibleCode ||
                        prev.splitBibleCode != curr.splitBibleCode ||
                        prev.bibleCodes != curr.bibleCodes,
                    builder: (context, bibleState) {
                      if (bibleState.bibleCodes.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _buildBibleCodePicker(bibleState, false);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Split Mode'.tr(),
                onPressed: () {
                  splitModeEnable = !splitModeEnable;
                  safeToastCancel();
                  safeShowToast(
                    msg:
                        'Split mode ${splitModeEnable ? 'enabled' : 'disabled'}!'
                            .tr(),
                  );
                },
                icon: Icon(
                  splitModeEnable
                      ? Icons.splitscreen_rounded
                      : Icons.splitscreen_outlined,
                  color: splitModeEnable ? context.colorScheme.primary : null,
                ),
              ),
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
                          borderRadius: BorderRadius.circular(999),
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
                            } else if (value == 'split') {
                              splitModeEnable = !splitModeEnable;
                              safeToastCancel();
                              safeShowToast(
                                msg:
                                    'Split mode ${splitModeEnable ? 'enabled' : 'disabled'}!'
                                        .tr(),
                              );
                            } else if (value == 'audio') {
                              final cubit = context.read<BibleCubit>();
                              cubit.setAudioPanelOpen(!cubit.state.enableAudio);
                            } else if (value == 'lock') {
                              _toggleSplitLock(state);
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
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              enabled: false,
                              padding: EdgeInsets.zero,
                              child: _BibleMenuGrid(
                                isAudioOn: state.enableAudio,
                                onAction: (value) =>
                                    Navigator.of(context).pop(value),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          floatingActionButton: null,
          body: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
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
                          Expanded(
                            child: Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(textTheme: state.defaultTextTheme),
                              child: MultiSplitViewTheme(
                                data: MultiSplitViewThemeData(
                                  dividerThickness: 10,
                                ),
                                child: MultiSplitView(
                                  controller: splitController,
                                  antiAliasingWorkaround: true,
                                  resizable: true,
                                  axis: splitAxis,
                                  onDividerDragUpdate: (index) {
                                    if (splitModeEnable) {
                                      final areaAtas = splitController.getArea(0);
                                      _splitRatio = normalizeBibleSplitRatio(
                                        areaAtas.size,
                                      );
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
                                            ? context
                                                  .colorScheme
                                                  .secondaryContainer
                                                  .withValues(alpha: 0.18)
                                            : context.colorScheme.surface,
                                        alignment: Alignment.center,
                                        child: axis == Axis.horizontal
                                            ? Container(
                                                width: 8,
                                                height: 56,
                                                decoration: BoxDecoration(
                                                  color: context
                                                      .colorScheme
                                                      .surfaceContainerLow,
                                                  borderRadius: context
                                                      .appRadius(999),
                                                  border: Border.all(
                                                    color: context
                                                        .colorScheme
                                                        .outlineVariant
                                                        .withValues(
                                                          alpha: 0.55,
                                                        ),
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.drag_indicator_rounded,
                                                  color: context
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                  size: 14,
                                                ),
                                              )
                                            : Container(
                                                width: 64,
                                                height: 7,
                                                decoration: BoxDecoration(
                                                  color: context
                                                      .colorScheme
                                                      .surfaceContainerLow,
                                                  borderRadius: context
                                                      .appRadius(999),
                                                  border: Border.all(
                                                    color: context
                                                        .colorScheme
                                                        .outlineVariant
                                                        .withValues(alpha: 0.5),
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                                  child: Container(
                                                  width: 42,
                                                  height: 2,
                                                  decoration: BoxDecoration(
                                                    color: context
                                                        .colorScheme
                                                        .outline
                                                        .withValues(alpha: 0.5),
                                                    borderRadius: context
                                                        .appRadius(999),
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
                                              right:
                                                  splitAxis == Axis.horizontal
                                                  ? BorderSide(
                                                      color: context
                                                          .colorScheme
                                                          .outlineVariant
                                                          .withValues(
                                                            alpha: 0.25,
                                                          ),
                                                    )
                                                  : BorderSide.none,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              if (splitModeEnable)
                                                _buildSplitPaneHeader(
                                                  state,
                                                  false,
                                                ),
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
                                                          notification
                                                                  .dragDetails !=
                                                              null) {
                                                        _setActiveSplitPane(
                                                          _BibleSplitPane.top,
                                                        );
                                                      }
                                                      return false;
                                                    },
                                                    child: LayoutBuilder(
                                                      builder: (context, constraints) => BibleViewer(
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
                                                                            details.scale)
                                                                        .clamp(
                                                                          .8,
                                                                          2,
                                                                        )
                                                                        .toDouble();
                                                              });
                                                            },
                                                        onScaleEnd: (details) {
                                                          context
                                                              .read<
                                                                BibleCubit
                                                              >()
                                                              .changeTextScale(
                                                                _currentScale,
                                                              );
                                                        },
                                                        listener: (s, context) {
                                                          scrollable = s;
                                                          contextBible =
                                                              context;
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
                                                        scrollFunction:
                                                            (index) {
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
                                                          .withValues(
                                                            alpha: 0.25,
                                                          ),
                                                    )
                                                  : BorderSide.none,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              if (splitModeEnable)
                                                _buildSplitPaneHeader(
                                                  state,
                                                  true,
                                                ),
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
                                                          notification
                                                                  .dragDetails !=
                                                              null) {
                                                        _setActiveSplitPane(
                                                          _BibleSplitPane
                                                              .bottom,
                                                        );
                                                      }
                                                      return false;
                                                    },
                                                    child: LayoutBuilder(
                                                      builder: (context, constraints) => BibleViewer(
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
                                                                            details.scale)
                                                                        .clamp(
                                                                          .8,
                                                                          2,
                                                                        )
                                                                        .toDouble();
                                                              });
                                                            },
                                                        onScaleEnd: (details) {
                                                          context
                                                              .read<
                                                                BibleCubit
                                                              >()
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
                                                          contextBible2 =
                                                              context;
                                                        },
                                                        scrollFunction:
                                                            (index) {
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
              const SizedBox.expand(),
              BlocBuilder<BibleCubit, BibleState>(
                buildWhen: (prev, curr) => prev.enableAudio != curr.enableAudio,
                builder: (context, state) => state.enableAudio
                    ? const Positioned.fill(child: BibleAudioSidebar())
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BibleQuickBookScrubber extends StatelessWidget {
  const _BibleQuickBookScrubber({
    required this.books,
    required this.selectedIndex,
    required this.panelRect,
    required this.columnCount,
  });

  final List<BibleBook> books;
  final ValueListenable<int> selectedIndex;
  final Rect panelRect;
  final int columnCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final columns = columnCount.clamp(1, books.length).toInt();
    final rows = (books.length + columns - 1) ~/ columns;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fromRect(
            rect: panelRect,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.96 + value * 0.04,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              ),
              child: Material(
                elevation: 14,
                shadowColor: colors.shadow.withValues(alpha: 0.28),
                color: colors.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: context.appRadius(18),
                  side: BorderSide(
                    color: colors.primary.withValues(alpha: 0.20),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ValueListenableBuilder<int>(
                valueListenable: selectedIndex,
                builder: (context, selected, _) => Column(
                  children: [
                    SizedBox(
                      height: 51,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            Icon(
                              Icons.swipe_rounded,
                              size: 19,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    books[selected].longName ??
                                        books[selected].shortName ??
                                        '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    'Geser sambil menahan • lepaskan untuk membuka',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: colors.outlineVariant.withValues(alpha: 0.46),
                    ),
                    Expanded(
                      child: Column(
                        children: List.generate(rows, (row) {
                          return Expanded(
                            child: Row(
                              children: List.generate(columns, (column) {
                                final index = row * columns + column;
                                if (index >= books.length) {
                                  return const Expanded(child: SizedBox());
                                }
                                final book = books[index];
                                final active = index == selected;
                                return Expanded(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 90),
                                    margin: const EdgeInsets.all(1.5),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? colors.primaryContainer
                                          : Colors.transparent,
                                      borderRadius: context.appRadius(7),
                                    ),
                                    child: Text(
                                      book.longName ?? book.shortName ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: context.textTheme.labelSmall?.copyWith(
                                        color: active
                                            ? colors.onPrimaryContainer
                                            : colors.onSurfaceVariant,
                                        fontSize: context.appFontSize(
                                          active ? 11 : 10,
                                        ),
                                        fontWeight: active
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),
          ),
        ],
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
    final letters = text.split('');
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
      initialChildSize: 0.82,
      minChildSize: 0.46,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 16, 8),
              child: Row(
                children: [
                  if (_step > 0)
                    IconButton(
                      tooltip: 'Kembali',
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back_rounded),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 20,
                        color: colors.primary,
                      ),
                    ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
    final splitAt = 39.clamp(0, widget.books.length).toInt();
    final oldTestament = widget.books.sublist(0, splitAt);
    final newTestament = widget.books.length > 39
        ? widget.books.sublist(39)
        : <BibleBook>[];

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Perjanjian Lama',
            style: context.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        _buildBookGrid(oldTestament, colors),
        if (newTestament.isNotEmpty) ...[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Perjanjian Baru',
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          _buildBookGrid(newTestament, colors),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBookGrid(List<BibleBook> books, ColorScheme colors) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 116,
        mainAxisExtent: 44,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) => _bookChip(books[index], colors),
    );
  }

  Widget _bookChip(BibleBook book, ColorScheme colors) {
    return InkWell(
      borderRadius: context.appRadius(10),
      onTap: () => _pickBook(book),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: context.appRadius(10),
          color: colors.surfaceContainerLow,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.34),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            book.shortName ?? '',
            maxLines: 1,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChapterGrid(
    ScrollController scrollController,
    ColorScheme colors,
  ) {
    final count = _selectedBook?.chapterCount ?? 0;
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 72,
        mainAxisExtent: 48,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        final chapterNum = index + 1;
        return _numberCell(
          colors: colors,
          label: '$chapterNum',
          onTap: () => _pickChapter(chapterNum),
        );
      },
    );
  }

  Widget _buildVerseGrid(
    ScrollController scrollController,
    ColorScheme colors,
  ) {
    return FutureBuilder<List<Verse>>(
      future: widget.getBibles(_selectedBook?.id, _selectedChapter),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final verses = snapshot.data!;
        return GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 72,
            mainAxisExtent: 48,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: verses.length,
          itemBuilder: (context, index) {
            final verse = verses[index];
            return _numberCell(
              colors: colors,
              label: '${verse.verseId}',
              onTap: () => widget.onSelected(verse),
            );
          },
        );
      },
    );
  }

  Widget _numberCell({
    required ColorScheme colors,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: context.appRadius(10),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: context.appRadius(10),
          color: colors.surfaceContainerLow,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.34),
          ),
        ),
        child: Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
  State<_BibleFontSettingsSheet> createState() =>
      _BibleFontSettingsSheetState();
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
                      borderRadius: context.appRadius(999),
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
                              borderRadius: context.appRadius(12),
                              side: BorderSide(
                                width: 1,
                                color: colors.outlineVariant,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
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
                            opacity: widget.bibleState.followGlobalFontSettings
                                ? 0.5
                                : 1.0,
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
                                        onChanged:
                                            widget
                                                .bibleState
                                                .followGlobalFontSettings
                                            ? null
                                            : (value) {
                                                widget.onTextScaleChanged(
                                                  value,
                                                );
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
                                        onChanged:
                                            widget
                                                .bibleState
                                                .followGlobalFontSettings
                                            ? null
                                            : (value) {
                                                widget.onTextHeightChanged(
                                                  value,
                                                );
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
                                    borderRadius: context.appRadius(12),
                                    side: BorderSide(
                                      width: 1,
                                      color: colors.outlineVariant,
                                    ),
                                  ),
                                  titleTextStyle: context.textTheme.bodyMedium
                                      ?.copyWith(
                                        fontSize: context.appFontSize(10),
                                      ),
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: EdgeInsets.only(left: 16),
                                  title: Text(
                                    'Font',
                                    style: context.textTheme.bodySmall,
                                  ),
                                  subtitle: Text(
                                    _effectiveFont,
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(fontFamily: _effectiveFont),
                                  ),
                                  trailing: Icon(
                                    Icons.keyboard_arrow_right,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  onTap:
                                      widget.bibleState.followGlobalFontSettings
                                      ? null
                                      : () {
                                          setState(() {
                                            _isSelectingFont = true;
                                          });
                                        },
                                  enabled: !widget
                                      .bibleState
                                      .followGlobalFontSettings,
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

class _BibleMenuGrid extends StatelessWidget {
  final bool isAudioOn;
  final ValueChanged<String> onAction;

  const _BibleMenuGrid({required this.isAudioOn, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final availableWidth = MediaQuery.sizeOf(context).width - 40;
    final width = availableWidth.clamp(280.0, 360.0).toDouble();
    final items = <({String action, IconData icon, String label, bool active})>[
      (
        action: 'version',
        icon: Icons.menu_book_outlined,
        label: 'Version',
        active: false,
      ),
      (
        action: 'histories',
        icon: Icons.history_rounded,
        label: 'Histories',
        active: false,
      ),
      (
        action: 'font',
        icon: Icons.text_fields_rounded,
        label: 'Font Settings',
        active: false,
      ),
      (
        action: 'notes',
        icon: Icons.sticky_note_2_outlined,
        label: 'See all notes',
        active: false,
      ),
      (
        action: 'bookmarkNow',
        icon: Icons.bookmark_add_outlined,
        label: 'Bookmark current chapter',
        active: false,
      ),
      (
        action: 'bookmarks',
        icon: Icons.bookmarks_outlined,
        label: 'Bookmarks',
        active: false,
      ),
      (
        action: 'search',
        icon: Icons.search_rounded,
        label: 'Search',
        active: false,
      ),
      (
        action: 'audio',
        icon: isAudioOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
        label: 'Audio',
        active: isAudioOn,
      ),
    ];

    return SizedBox(
      width: width,
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 0.96,
        children: [
          for (final item in items)
            Semantics(
              button: true,
              selected: item.active,
              label: item.label.tr(),
              child: InkWell(
                borderRadius: context.appRadius(14),
                onTap: () => onAction(item.action),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: context.appRadius(14),
                    color: item.active
                        ? colors.primaryContainer.withValues(alpha: 0.72)
                        : colors.surfaceContainerLow,
                    border: Border.all(
                      color: item.active
                          ? colors.primary.withValues(alpha: 0.34)
                          : colors.outlineVariant.withValues(alpha: 0.34),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: item.active
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.label.tr(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelSmall?.copyWith(
                          height: 1.12,
                          color: item.active
                              ? colors.onPrimaryContainer
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

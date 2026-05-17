// ignore_for_file: use_build_context_synchronously

import 'dart:async';

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
import '../../../data/utilities/functions/debouncer.dart';
import '../../../data/utilities/toast_utils.dart';
import '../../../router/router.dart';
import '../../dashboard/cubit/dashboard_cubit.dart';
import '../../dashboard/view/dashboard_view.dart';
import '../bible.dart';

const double _bibleSplitPaneHeaderCompactWidth = 440;
const double _bibleSplitStatusCompactWidth = 500;

enum _BibleSplitPane { top, bottom }

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
  _BibleSplitPane _activeSplitPane = _BibleSplitPane.top;
  bool _isSyncingSplitScroll = false;
  Timer? _splitSyncReleaseTimer;
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
    _splitSyncReleaseTimer?.cancel();
    debouncer.dispose();
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
  void handleScrollBottom(int index, Size size, double visiblePercentage) {
    // Store the visiblePercentage in the bottomVisibleIndexes map using the index as the key
    bottomVisibleIndexes[index] = visiblePercentage;

    // Remove entries with a value of 0 from the bottomVisibleIndexes map
    bottomVisibleIndexes.removeWhere((key, value) => value == 0);

    // Sort the keys of the bottomVisibleIndexes map in ascending order
    var keys = bottomVisibleIndexes.keys.toList()..sort();

    // Rebuild the bottomVisibleIndexes map with the sorted keys
    bottomVisibleIndexes = Map.fromEntries(
      keys.map((e) => MapEntry(e, bottomVisibleIndexes[e]!)),
    );

    if (_activeSplitPane == _BibleSplitPane.bottom) {
      _syncSplitPaneScroll(
        sourcePane: _BibleSplitPane.bottom,
        firstVisibleIndexes: bottomVisibleIndexes,
      );
    }
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
    // Store the visiblePercentage in the topVisibleIndexes map using the index as the key
    topVisibleIndexes[index] = visiblePercentage;

    // Remove entries with a value of 0 from the topVisibleIndexes map
    topVisibleIndexes.removeWhere((key, value) => value == 0);

    // Sort the keys of the topVisibleIndexes map in ascending order
    var keys = topVisibleIndexes.keys.toList()..sort();

    // Rebuild the topVisibleIndexes map with the sorted keys
    topVisibleIndexes = Map.fromEntries(
      keys.map((e) => MapEntry(e, topVisibleIndexes[e]!)),
    );

    if (_activeSplitPane == _BibleSplitPane.top) {
      _syncSplitPaneScroll(
        sourcePane: _BibleSplitPane.top,
        firstVisibleIndexes: topVisibleIndexes,
      );
    }
  }

  void _setActiveSplitPane(_BibleSplitPane pane) {
    if (_isSyncingSplitScroll) return;
    _activeSplitPane = pane;
  }

  void _syncSplitPaneScroll({
    required _BibleSplitPane sourcePane,
    required Map<int, double> firstVisibleIndexes,
  }) {
    if (!lockScroll ||
        !splitModeEnable ||
        _isSyncingSplitScroll ||
        firstVisibleIndexes.isEmpty) {
      return;
    }

    final cubit = context.read<BibleCubit>();
    final state = cubit.state;
    final sourceVerses = sourcePane == _BibleSplitPane.top
        ? state.verses
        : state.versesSplit;
    final targetVerses = sourcePane == _BibleSplitPane.top
        ? state.versesSplit
        : state.verses;
    final sourceKeys = sourcePane == _BibleSplitPane.top
        ? cubit.verseKeys
        : cubit.verseKeys2;
    final targetKeys = sourcePane == _BibleSplitPane.top
        ? cubit.verseKeys2
        : cubit.verseKeys;
    final sourceController = sourcePane == _BibleSplitPane.top
        ? scrollController
        : scrollController2;
    final targetController = sourcePane == _BibleSplitPane.top
        ? scrollController2
        : scrollController;

    final firstVisibleIndex = firstVisibleIndexes.keys.firstWhere(
      (index) => index < sourceVerses.length && index < sourceKeys.length,
      orElse: () => -1,
    );
    if (firstVisibleIndex.isNegative ||
        sourceVerses.isEmpty ||
        targetVerses.isEmpty ||
        !sourceController.hasClients ||
        !targetController.hasClients) {
      return;
    }

    final sourceVerse = sourceVerses[firstVisibleIndex];
    var targetVerseIndex = targetVerses.indexWhere(
      (verse) =>
          verse.bookId == sourceVerse.bookId &&
          verse.chapterId == sourceVerse.chapterId &&
          verse.verseId == sourceVerse.verseId,
    );
    if (targetVerseIndex.isNegative &&
        firstVisibleIndex < targetVerses.length) {
      targetVerseIndex = firstVisibleIndex;
    }
    if (targetVerseIndex.isNegative || targetVerseIndex >= targetKeys.length) {
      return;
    }

    final sourceContext = sourceKeys[firstVisibleIndex].currentContext;
    final targetContext = targetKeys[targetVerseIndex].currentContext;
    if (sourceContext == null || targetContext == null) return;

    final alignment = _calculateSplitVerseAlignment(
      sourceContext: sourceContext,
      targetContext: targetContext,
      targetController: targetController,
    );

    _isSyncingSplitScroll = true;
    Scrollable.ensureVisible(
      targetContext,
      alignment: alignment,
      duration: Duration.zero,
    ).whenComplete(() {
      _splitSyncReleaseTimer?.cancel();
      _splitSyncReleaseTimer = Timer(const Duration(milliseconds: 80), () {
        _isSyncingSplitScroll = false;
      });
    });
  }

  double _calculateSplitVerseAlignment({
    required BuildContext sourceContext,
    required BuildContext targetContext,
    required ScrollController targetController,
  }) {
    final sourceBox = sourceContext.findRenderObject() as RenderBox?;
    final targetBox = targetContext.findRenderObject() as RenderBox?;
    final sourceScrollable = Scrollable.maybeOf(sourceContext);
    final sourceViewportBox =
        sourceScrollable?.context.findRenderObject() as RenderBox?;

    if (sourceBox == null ||
        targetBox == null ||
        sourceViewportBox == null ||
        !sourceBox.hasSize ||
        !targetBox.hasSize ||
        !sourceViewportBox.hasSize ||
        !targetController.hasClients) {
      return 0;
    }

    final sourceTop = sourceBox
        .localToGlobal(Offset.zero, ancestor: sourceViewportBox)
        .dy;
    final sourceHeight = sourceBox.size.height;
    final hiddenSourceHeight = (-sourceTop).clamp(0.0, sourceHeight);
    final hiddenSourceRatio = sourceHeight <= 0
        ? 0.0
        : hiddenSourceHeight / sourceHeight;

    final targetHeight = targetBox.size.height;
    final targetHiddenHeight = targetHeight * hiddenSourceRatio;
    final viewportHeight = targetController.position.viewportDimension;
    var denominator = viewportHeight - targetHeight;
    if (denominator.abs() < 0.1) {
      denominator = denominator.isNegative ? -0.1 : 0.1;
    }

    return -targetHiddenHeight / denominator;
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
    router.push(
      BibleListRoute(
        bibleCode: forSecondView
            ? state.splitBibleCode
            : state.currentBibleCode,
        textScale: state.defaultTextScale,
        books: forSecondView ? state.booksSplit : state.books,
        getBibles: (bookId, chapterId) async {
          if (bookId == null || chapterId == null) {
            return [];
          }
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
          router.maybePop();
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

  String? _chapterSubtitle(BibleState state) {
    if (state.verses.isEmpty) return null;
    final raw =
        state.verses.first.verse
            ?.replaceAll(RegExp(r'<[^>]*>'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim() ??
        '';
    if (raw.isEmpty) return null;

    final marks = ['.', ';', '!', '?'];
    var end = -1;
    for (final mark in marks) {
      final index = raw.indexOf(mark);
      if (index > 0 && (end == -1 || index < end)) {
        end = index;
      }
    }
    if (end <= 0 || end > 64) return null;
    final candidate = raw.substring(0, end + 1).trim();
    if (candidate.length < 8) return null;

    final lower = candidate.toLowerCase();
    final looksLikeTitle =
        lower.contains('mazmur') ||
        lower.contains('psalm') ||
        lower.contains('daud') ||
        lower.contains('nyanyian');
    return looksLikeTitle ? candidate : null;
  }

  Widget _buildSplitPaneHeader(BibleState state, {required bool secondPane}) {
    final colors = context.colorScheme;
    final codeLabel =
        (secondPane ? state.splitBibleCode : state.currentBibleCode)
            .split('_')
            .last
            .toUpperCase();
    final versionPicker = PopupMenuButton<int>(
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
          color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
          border: Border.all(color: colors.outline.withValues(alpha: 0.56)),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (secondPane
                    ? colors.surfaceContainerLow
                    : colors.surfaceContainerLowest)
                .withValues(alpha: 0.95),
            colors.surfaceContainerHighest.withValues(alpha: 0.88),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.34),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < _bibleSplitPaneHeaderCompactWidth;
          final title = FutureBuilder(
            future: context.read<BibleCubit>().getBibleTitle([
              secondPane ? state.currentBibleSplit : state.currentBible,
            ], splitMode: secondPane),
            builder: (context, snapshot) => Text(
              snapshot.data ?? '',
              maxLines: compact ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.headlineMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 21 : 25,
              ),
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerRight, child: versionPicker),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: title),
              const SizedBox(width: 12),
              versionPicker,
            ],
          );
        },
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.outlineVariant),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: lockScroll
              ? colors.secondaryContainer
              : colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Text(
          lockScroll ? 'Locked'.tr() : 'Unlocked'.tr(),
          style: context.textTheme.labelSmall?.copyWith(
            color: lockScroll
                ? colors.onSecondaryContainer
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
              icon: const Icon(Icons.menu_book_rounded),
            ),
            title: const Text('Scripture Reader'),
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
                    if (!splitModeEnable)
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                            child: Column(
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: () {
                                    onTapTitle(state, false);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          context
                                              .colorScheme
                                              .surfaceContainerHighest
                                              .withValues(alpha: 0.9),
                                          context
                                              .colorScheme
                                              .surfaceContainerLow
                                              .withValues(alpha: 0.84),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: context
                                            .colorScheme
                                            .outlineVariant
                                            .withValues(alpha: 0.54),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: FutureBuilder(
                                            future: context
                                                .read<BibleCubit>()
                                                .getBibleTitle([
                                                  state.currentBible,
                                                ]),
                                            builder: (context, snapshot) =>
                                                Text(
                                                  snapshot.data ?? '',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: context
                                                      .textTheme
                                                      .headlineMedium
                                                      ?.copyWith(
                                                        color: context
                                                            .colorScheme
                                                            .onSurface,
                                                      ),
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: context
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_chapterSubtitle(state) != null) ...[
                                  const SizedBox(height: 14),
                                  Text(
                                    _chapterSubtitle(state)!,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: context
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Divider(
                                  height: 1,
                                  color: context.colorScheme.outlineVariant
                                      .withValues(alpha: 0.30),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(textTheme: state.defaultTextTheme),
                        child: MultiSplitViewTheme(
                          data: MultiSplitViewThemeData(
                            dividerThickness: splitAxis == Axis.horizontal
                                ? 18
                                : 40,
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
                                          width: 28,
                                          height: 112,
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
                                            size: 18,
                                          ),
                                        )
                                      : Container(
                                          width: 84,
                                          height: 14,
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
                                            width: 16,
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
                                        if (splitModeEnable)
                                          _buildSplitPaneHeader(
                                            state,
                                            secondPane: false,
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
                                        if (splitModeEnable)
                                          _buildSplitPaneHeader(
                                            state,
                                            secondPane: true,
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

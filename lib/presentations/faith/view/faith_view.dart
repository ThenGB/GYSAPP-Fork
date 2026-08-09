import '../../../components/components.dart';
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../../router/router.dart';
import '../../presentations.dart';

const double _faithMaxContentWidth = 1040;

@RoutePage()
class FaithView extends StatefulWidget {
  const FaithView({super.key});

  @override
  State<FaithView> createState() => _FaithViewState();
}

class _FaithViewState extends State<FaithView> {
  late final PageController pageController = PageController(keepPage: true)
    ..addListener(pageListener);
  List data = [];
  bool isInitialized = false;
  @override
  void initState() {
    Future.microtask(() async {
      var jsonString = await rootBundle.loadString(Assets.assetsDataFaith);
      var json = jsonDecode(jsonString)['faith'];
      data = json;
      isInitialized = true;
      setState(() {});
    });
    super.initState();
  }

  List get currentData {
    var language = context.read<FaithCubit>().state.locale.languageCode;
    var temp = data.firstWhereOrNull(
      (element) => element['language'] == language.toUpperCase(),
    );
    if (temp == null) return [];
    return temp['content'];
  }

  String get currentTitle {
    var language = context.read<FaithCubit>().state.locale.languageCode;
    var temp = data.firstWhereOrNull(
      (element) => element['language'] == language.toUpperCase(),
    );
    if (temp == null) return '';
    return temp['title'];
  }

  void pageListener() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      currentPage = pageController.page?.toInt() ?? 0;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  int currentPage = 0;

  final GlobalKey selectedFaithMenuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return BlocBuilder<FaithCubit, FaithState>(
      builder: (context, state) => Scaffold(
        backgroundColor: context.colorScheme.surface,

        appBar: AppBar(
          backgroundColor: context.colorScheme.surface.withValues(alpha: 0.88),
          title: Text('faith_section_title'.tr()),
          automaticallyImplyLeading: false,
          toolbarHeight: 74,
          leading: IconButton(
            tooltip: 'Menu',
            onPressed: openDashboardDrawer,
            icon: const Icon(Icons.menu_outlined),
          ),
          actions: [
            Material(
              color: Colors.transparent,
              shape: StadiumBorder(
                side: BorderSide(
                  color: context
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.4),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              // Builder gives the InkWell its own context so the menu
              // anchors to THIS pill (using the page context made the
              // menu pop up at the wrong position — far left).
              child: Builder(
                builder: (pillContext) => InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () =>
                      _showLanguageMenu(pillContext, state),
                  child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.translate_rounded,
                        size: 18,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _localeLabel(state.locale),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              offset: Offset(0, 48),
              onSelected: (value) {
                if (value == 'See all notes') {
                  router.push(FaithNoteListRoute(cubit: context.read()));
                }
              },
              itemBuilder: (context) {
                return ['See all notes']
                    .map((e) => PopupMenuItem(value: e, child: Text(e.tr())))
                    .toList();
              },
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.more_vert_rounded,
                      size: 22,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        body: !isInitialized
            ? const Center(child: CircularProgressIndicator())
            : DecoratedBox(
                decoration: BoxDecoration(color: context.colorScheme.surface),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: currentData.length,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final faithIndex = index;
                          var item = currentData[faithIndex];
                          final initialCubit = context.read<InitialCubit>();
                          return Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: _faithMaxContentWidth,
                              ),
                              child: DefaultTextStyle.merge(
                                style: TextStyle(
                                  fontWeight:
                                      context
                                          .read<FaithCubit>()
                                          .state
                                          .locale
                                          .languageCode
                                          .contains('zh')
                                      ? FontWeight.w700
                                      : null,
                                ),
                                child: FaithWidget(
                                  fontHeight: initialCubit.state.defaultTextHeight,
                                  index: faithIndex,
                                  item: item,
                                  scale: initialCubit.state.defaultTextScale,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    AnimatedSize(
                      curve: Curves.easeOut,
                      alignment: Alignment.bottomCenter,
                      duration: kThemeAnimationDuration,
                      child: state.selectedFaith.isEmpty
                          ? const SizedBox.shrink()
                          : PlayAnimationBuilder(
                              curve: Curves.easeOut,
                              delay: kThemeAnimationDuration,
                              duration: kThemeAnimationDuration,
                              tween: Tween<double>(begin: 0, end: 1),
                              builder: (c, value, child) => Opacity(
                                opacity: value,
                                child: SelectedFaithMenu(
                                  key: selectedFaithMenuKey,
                                  title: currentTitle,
                                  indexes: state.selectedFaith,
                                  currentData: currentData,
                                  viewPadding:
                                      context.mediaQuery.viewPadding.vertical,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class FaithWidget extends StatelessWidget {
  const FaithWidget({
    super.key,
    required this.item,
    required this.scale,
    required this.index,
    required this.fontHeight,
  });

  final Map<String, dynamic> item;
  final double scale;
  final double fontHeight;
  final int index;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaithCubit, FaithState>(
      builder: (context, state) => GestureDetector(
        onTap: () async {
          context.read<FaithCubit>().selectVerse(index);
          if (state.selectedFaith.isEmpty) {
            await Future.delayed(Duration(milliseconds: 600));
          }
          if (context.read<FaithCubit>().state.selectedFaith.contains(index)) {
            Scrollable.ensureVisible(
              context,
              alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
              alignment: .3,
              curve: Curves.easeOut,
              duration: Duration(milliseconds: 500),
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 430;
            final cardPadding = compact ? 18.0 : 24.0;
            final numberGap = compact ? 12.0 : 16.0;
            final initialCubit = context.read<InitialCubit>();
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: state.selectedFaith.contains(index)
                    ? context.colorScheme.primaryContainer
                    : context.colorScheme.surfaceContainer,
                borderRadius: context.appRadius(compact ? 18 : 22),
              ),
              child: Stack(
                children: [
                  // Roman ornament — auto-fits the whole card (FittedBox
                  // scales it down), so it can never be cropped.
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 4),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style:
                            (context.textTheme.headlineLarge ?? const TextStyle())
                                .copyWith(
                                  fontSize: 96,
                                  fontWeight: FontWeight.w900,
                                  color: context.colorScheme.primary.withValues(
                                    alpha: state.selectedFaith.contains(index)
                                        ? 0.20
                                        : 0.10,
                                  ),
                                  height: 1,
                                ),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomRight,
                          child: Text(_romanNumeral(index + 1)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      cardPadding,
                      cardPadding,
                      cardPadding,
                      cardPadding,
                    ),
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item['number']}',
                        style: TextStyle(
                          fontSize: context.appFontSize(14) * 1.5,
                          fontWeight: FontWeight.w800,
                          color: context.colorScheme.primary,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(width: numberGap),
                      Expanded(
                        child: Text.rich(
                          TextSpan(text: item['text'].toString()),
                          textScaler: TextScaler.linear(scale),
                          style: TextStyle(
                            fontFamily: initialCubit.state.defaultFont,
                            // CJK glyphs use a fallback font whose metrics
                            // differ — forcing fontHeight clipped the glyphs
                            // (cropped rows). Use natural line height there.
                            height: context
                                    .read<FaithCubit>()
                                    .state
                                    .locale
                                    .languageCode
                                    .contains('zh')
                                ? null
                                : fontHeight,
                            // Regular weight: w500 rendered noticeably
                            // heavy with EB Garamond / Manrope.
                            fontWeight: FontWeight.w400,
                            fontSize: context.appFontSize(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> _showLanguageMenu(BuildContext context, FaithState state) async {
  final box = context.findRenderObject() as RenderBox;
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final locale = await showMenu<Locale>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(
          box.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    ),
    initialValue: state.locale,
    items: [
      for (final locale in context.supportedLocales)
        PopupMenuItem(
          value: locale,
          child: Row(
            children: [
              Icon(
                Icons.language_rounded,
                size: 18,
                color: context.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Text(
                _localeLabel(locale),
                style: locale == state.locale
                    ? TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.colorScheme.primary,
                      )
                    : null,
              ),
            ],
          ),
        ),
    ],
  );
  if (locale != null && context.mounted) {
    context.read<FaithCubit>().setLanguage(locale);
  }
}

String _localeLabel(Locale locale) {
  return switch (locale.languageCode) {
    'id' => 'Indonesia',
    'en' => 'English',
    'zh' => '中文',
    _ => locale.languageCode,
  };
}

String _romanNumeral(int value) {
  const numerals = {
    10: 'X',
    9: 'IX',
    8: 'VIII',
    7: 'VII',
    6: 'VI',
    5: 'V',
    4: 'IV',
    3: 'III',
    2: 'II',
    1: 'I',
  };
  return numerals[value] ?? value.toString();
}

class SelectedFaithMenu extends StatelessWidget {
  final List<int> indexes;
  final String title;
  final List<dynamic> currentData;
  final double viewPadding;
  const SelectedFaithMenu({
    super.key,
    required this.indexes,
    required this.currentData,
    required this.title,
    required this.viewPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Container(
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            color: context.colorScheme.surfaceContainerHighest,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text:
                            '${(indexes.map((e) => e + 1)).toList().joinToString()}  ',
                        children: const [],
                      ),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                    onPressed: context.read<FaithCubit>().removeSelection,
                  ),
                ],
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (indexes.length == 1)
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: context.colorScheme.primaryContainer,
                        foregroundColor: context.colorScheme.onPrimaryContainer,
                      ),
                      onPressed: () {
                        router.push(
                          FaithNoteRoute(
                            initialData: FaithNote.empty(
                              context.read<FaithCubit>().state.selectedFaith,
                            ),
                            cubit: context.read<FaithCubit>(),
                            mode: NoteMode.write,
                            onSave: (data) {
                              context.read<FaithCubit>().saveNote(data);
                              router.maybePop();
                              router.push(
                                FaithNoteListRoute(cubit: context.read()),
                              );
                            },
                          ),
                        );
                      },
                      child: Text('Note'.tr()),
                    ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: context.colorScheme.primaryContainer,
                      foregroundColor: context.colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () async {
                      String text = '';
                      var verses = indexes.sorted((a, b) => a.compareTo(b));
                      var json = await AppConfigStore.jsonConfig(
                        'footer_copied_text',
                      );
                      var footer = json[context.locale.languageCode];
                      text = title;
                      for (var index in verses) {
                        var verse = currentData[index]['text'];
                        var number = index + 1;
                        text += '\n$number. $verse';
                      }
                      text += '\n\n$footer';
                      try {
                        await SharePlus.instance.share(ShareParams(text: text));
                      } catch (_) {
                        // Share is unavailable on some platforms — ignore.
                      }
                    },
                    child: Text('Share'.tr()),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: context.colorScheme.outlineVariant,
                      foregroundColor: context.colorScheme.onSecondaryContainer,
                    ),
                    onPressed: () async {
                      String text = '';
                      var verses = indexes.sorted((a, b) => a.compareTo(b));
                      var json = await AppConfigStore.jsonConfig(
                        'footer_copied_text',
                      );
                      var footer = json[context.locale.languageCode];
                      text = title;
                      for (var index in verses) {
                        var verse = currentData[index]['text'];
                        var number = index + 1;
                        text += '\n$number. $verse';
                      }
                      text += '\n\n$footer';
                      await Clipboard.setData(ClipboardData(text: text));
                      Fluttertoast.cancel();
                      Fluttertoast.showToast(msg: 'Copied!'.tr());
                    },
                    child: Text('Copy'.tr()),
                  ),
                ],
              ),
              // The faith page is a full-screen route whose bottom edge
              // sits under the floating dock, so the selection menu needs
              // explicit nav-bar clearance (72 = 64px dock + margin).
              SizedBox(height: 8 + 16 + viewPadding + 72),
            ],
          ),
        ),
      ),
    );
  }
}

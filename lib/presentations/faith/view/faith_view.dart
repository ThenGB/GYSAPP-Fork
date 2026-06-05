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
          title: const Text('Dasar Kepercayaan'),
          automaticallyImplyLeading: false,
          toolbarHeight: 74,
          leading: IconButton(
            tooltip: 'Menu',
            onPressed: openDashboardDrawer,
            icon: const Icon(Icons.menu_outlined),
          ),
          actions: [
            IconButton(
              tooltip: 'Search'.tr(),
              onPressed: () {
                router.push(FaithNoteListRoute(cubit: context.read()));
              },
              icon: const Icon(Icons.search_rounded),
            ),
            PopupMenuButton(
              offset: Offset(0, 48),
              onSelected: (value) {
                if (value == 'Language') {
                  final currentIndex = context.supportedLocales.indexWhere(
                    (locale) =>
                        locale.languageCode == state.locale.languageCode,
                  );
                  final nextIndex =
                      ((currentIndex + 1) % context.supportedLocales.length)
                          .clamp(0, context.supportedLocales.length - 1);
                  context.read<FaithCubit>().setLanguage(
                    context.supportedLocales[nextIndex],
                  );
                } else if (value == 'See all notes') {
                  router.push(FaithNoteListRoute(cubit: context.read()));
                }
              },
              itemBuilder: (context) {
                return ['Language', 'See all notes']
                    .map((e) => PopupMenuItem(value: e, child: Text(e.tr())))
                    .toList();
              },
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.more_vert_rounded,
                  color: context.colorScheme.onSurfaceVariant,
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
            final markerSize = compact ? 104.0 : 140.0;
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
                borderRadius: BorderRadius.circular(compact ? 18 : 22),
              ),
              padding: EdgeInsets.fromLTRB(
                cardPadding,
                cardPadding,
                cardPadding,
                cardPadding,
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    right: -16,
                    bottom: compact ? -14 : -24,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style:
                          (context.textTheme.headlineLarge ?? const TextStyle())
                              .copyWith(
                                fontSize: markerSize,
                                fontWeight: FontWeight.w900,
                                color: context.colorScheme.primary.withValues(
                                  alpha: state.selectedFaith.contains(index)
                                      ? 0.20
                                      : 0.10,
                                ),
                                height: 1,
                              ),
                      child: Text(_romanNumeral(index + 1)),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item['number']}',
                        style: context.textTheme.headlineLarge?.copyWith(
                          color: context.colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: numberGap),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(text: item['text'].toString()),
                              textScaler: TextScaler.linear(scale),
                              style: TextStyle(
                                fontFamily: initialCubit.state.defaultFont,
                                height: fontHeight,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                      SharePlus.instance.share(ShareParams(text: text));
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
              SizedBox(height: 8 + 16 + viewPadding),
            ],
          ),
        ),
      ),
    );
  }
}

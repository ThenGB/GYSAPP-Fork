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
  late double _currentScale = context.read<FaithCubit>().state.defaultTextScale;
  late double _baseScale = context.read<FaithCubit>().state.defaultTextScale;
  double get scale => _currentScale.clamp(.8, 2);

  bool onScaling = false;
  Set<int> touches = {};

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
          title: const Text('Beliefs'),
          automaticallyImplyLeading: false,
          toolbarHeight: 74,
          leading: IconButton(
            tooltip: 'Menu',
            onPressed: openDashboardDrawer,
            icon: const Icon(Icons.auto_stories_rounded),
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
                } else if (value == 'Font Settings') {
                  openDefaultBottomSheet(
                    context,
                    builder: (c) => BlocProvider<FaithCubit>.value(
                      value: context.read(),
                      child: BlocBuilder<FaithCubit, FaithState>(
                        builder: (context, state) => FontSettingWidget(
                          selectedFont: state.defaultFont,
                          getTextStyle: (font) =>
                              state.getTextThemeByFontName(font).bodyMedium!,
                          availableFonts: state.availableFonts,
                          textHeight: state.defaultTextHeight,
                          textScale: state.defaultTextScale,
                          onTextHeightChanged: (value) {
                            context.read<FaithCubit>().changeTextHeight(value);
                          },
                          onTextScaleChanged: (value) {
                            _currentScale = value;
                            context.read<FaithCubit>().changeTextScale(value);
                          },
                          onFontSelected: (font) {
                            context.read<FaithCubit>().changeFont(font);
                          },
                        ),
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (context) {
                return ['Language', 'Font Settings', 'See all notes']
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
            // const SizedBox(
            //   width: 16,
            // ),
          ],
        ),

        // bottomNavigationBar: Container(
        //   padding: const EdgeInsets.all(16),
        //   color: context.colorScheme.background,
        //   child: Row(
        //     children: [
        //       IconButton(
        //         onPressed: () {
        //           pageController.previousPage(
        //               duration: kThemeAnimationDuration, curve: Curves.easeOut);
        //         },
        //         icon: const CircleAvatar(child: Icon(Icons.chevron_left_rounded)),
        //       ),
        //       const Spacer(),
        //       Text('${currentPage + 1} / ${currentData.length}'),
        //       const Spacer(),
        //       IconButton(
        //         onPressed: () {
        //           pageController.nextPage(
        //               duration: kThemeAnimationDuration, curve: Curves.easeOut);
        //         },
        //         icon:
        //             const CircleAvatar(child: Icon(Icons.chevron_right_rounded)),
        //       ),
        //     ],
        //   ),
        // ),
        body: !isInitialized
            ? const Center(child: CircularProgressIndicator())
            : DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.22,
                      ),
                      context.colorScheme.surfaceContainerLow.withValues(
                        alpha: 0.38,
                      ),
                      context.colorScheme.surface,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Listener(
                        onPointerUp: (event) {
                          touches.remove(event.pointer);
                          if (touches.length <= 1) {
                            if (onScaling) {
                              setState(() {
                                onScaling = false;
                              });
                            }
                          }
                        },
                        onPointerDown: (event) {
                          touches.add(event.pointer);
                          if (touches.length > 1) {
                            if (!onScaling) {
                              setState(() {
                                onScaling = true;
                              });
                            }
                          }
                        },
                        onPointerCancel: (event) {
                          touches.remove(event.pointer);
                          if (touches.length <= 1) {
                            if (onScaling) {
                              setState(() {
                                onScaling = false;
                              });
                            }
                          }
                        },
                        child: GestureDetector(
                          onScaleStart: (ScaleStartDetails details) {
                            _baseScale = _currentScale;
                          },
                          onScaleUpdate: (ScaleUpdateDetails details) {
                            setState(() {
                              _currentScale = (_baseScale * details.scale)
                                  .clamp(.8, 2);
                            });
                          },
                          onScaleEnd: (details) {
                            context.read<FaithCubit>().changeTextScale(
                              _currentScale,
                            );
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: IgnorePointer(
                              ignoring: onScaling,
                              child: ListView.builder(
                                itemCount: currentData.length + 1,
                                physics: onScaling
                                    ? NeverScrollableScrollPhysics()
                                    : AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return Align(
                                      alignment: Alignment.topCenter,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: _faithMaxContentWidth,
                                        ),
                                        child: _FaithHeader(
                                          title: currentTitle,
                                        ),
                                      ),
                                    );
                                  }
                                  final faithIndex = index - 1;
                                  var item = currentData[faithIndex];
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
                                          fontHeight: state.defaultTextHeight,
                                          index: faithIndex,
                                          item: item,
                                          scale: scale,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
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
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: const EdgeInsets.fromLTRB(14, 7, 14, 7),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: state.selectedFaith.contains(index)
                      ? [
                          context.colorScheme.primaryContainer.withValues(
                            alpha: 0.56,
                          ),
                          context.colorScheme.surfaceContainerHigh.withValues(
                            alpha: 0.8,
                          ),
                        ]
                      : [
                          context.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.76),
                          context.colorScheme.surfaceContainerLow.withValues(
                            alpha: 0.78,
                          ),
                        ],
                ),
                borderRadius: BorderRadius.circular(compact ? 14 : 18),
                border: Border.all(
                  color: state.selectedFaith.contains(index)
                      ? context.colorScheme.primary
                      : context.colorScheme.outlineVariant.withValues(
                          alpha: 0.30,
                        ),
                ),
                boxShadow: state.selectedFaith.contains(index)
                    ? [
                        BoxShadow(
                          color: context.colorScheme.primary.withValues(
                            alpha: 0.16,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
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
                              style: state.defaultTextTheme.bodyMedium
                                  ?.copyWith(
                                    height: fontHeight,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
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

class _FaithHeader extends StatelessWidget {
  final String title;

  const _FaithHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colorScheme.primaryContainer.withValues(alpha: 0.4),
              context.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.86,
              ),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.colorScheme.primary.withValues(alpha: 0.24),
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Sepuluh pilar iman yang menjadi pondasi kerohanian Gereja Yesus Sejati.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: context.colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                blurRadius: 160,
                color: Colors.black.withValues(alpha: .2),
              ),
            ],
            color: context.colorScheme.surface,
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
                        backgroundColor: context.colorScheme.outlineVariant,
                        foregroundColor:
                            context.colorScheme.onSecondaryContainer,
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

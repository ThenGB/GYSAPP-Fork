// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

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

@RoutePage()
class FaithView extends StatefulWidget {
  const FaithView({super.key});

  @override
  State<FaithView> createState() => _FaithViewState();
}

class _FaithViewState extends State<FaithView> {
  late final PageController pageController = PageController(
    keepPage: true,
  )..addListener(pageListener);
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
        (element) => element['language'] == language.toUpperCase());
    if (temp == null) return [];
    return temp['content'];
  }

  String get currentTitle {
    var language = context.read<FaithCubit>().state.locale.languageCode;
    var temp = data.firstWhereOrNull(
        (element) => element['language'] == language.toUpperCase());
    if (temp == null) return '';
    return temp['title'];
  }

  pageListener() {
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

  GlobalKey selectedFaithMenuKey = GlobalKey();

  Future<double> get selectedFaithMenuHeight async => await Future.delayed(
        Duration(milliseconds: 500),
        () {
          return selectedFaithMenuKey.currentContext?.size?.height ?? 0;
        },
      );

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return BlocBuilder<FaithCubit, FaithState>(
      builder: (context, state) => Scaffold(
        backgroundColor: context.colorScheme.background,
        bottomSheet: Container(
          key: selectedFaithMenuKey,
          color: context.colorScheme.background,
          child: AnimatedSize(
            curve: Curves.easeOut,
            alignment: Alignment.bottomCenter,
            duration: kThemeAnimationDuration,
            child: state.selectedFaith.isEmpty
                ? SizedBox(
                    width: double.infinity,
                  )
                : PlayAnimationBuilder(
                    curve: Curves.easeOut,
                    delay: kThemeAnimationDuration,
                    duration: kThemeAnimationDuration,
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (c, value, child) => Opacity(
                      opacity: value,
                      child: SelectedFaithMenu(
                        title: currentTitle,
                        indexes: state.selectedFaith,
                        currentData: currentData,
                        viewPadding: context.mediaQuery.viewPadding.vertical,
                      ),
                    ),
                  ),
          ),
        ),

        appBar: AppBar(
          title: Text(currentTitle),
          automaticallyImplyLeading: false,
          actions: [
            PopupMenuButton(
              offset: Offset(0, 48),
              onSelected: (value) {
                context.read<FaithCubit>().setLanguage(value);
              },
              itemBuilder: (context) => context.supportedLocales
                  .map(
                    (e) => PopupMenuItem(
                      value: e,
                      child: Text(
                        e.languageCode.toUpperCase(),
                      ),
                    ),
                  )
                  .toList(),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Text(
                  state.locale.languageCode.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            PopupMenuButton(
              offset: Offset(0, 48),
              onSelected: (value) {
                if (value == 'See all notes') {
                  router.push(
                    FaithNoteListRoute(
                      cubit: context.read(),
                    ),
                  );
                } else if (value == 'Font Settings') {
                  openDefaultBottomSheet(context,
                      builder: (c) => BlocProvider<FaithCubit>.value(
                            value: context.read(),
                            child: BlocBuilder<FaithCubit, FaithState>(
                              builder: (context, state) => FontSettingWidget(
                                selectedFont: state.defaultFont,
                                getTextStyle: (font) => state
                                    .getTextThemeByFontName(font)
                                    .bodyMedium!,
                                availableFonts: state.availableFonts,
                                textHeight: state.defaultTextHeight,
                                textScale: state.defaultTextScale,
                                onTextHeightChanged: (value) {
                                  context
                                      .read<FaithCubit>()
                                      .changeTextHeight(value);
                                },
                                onTextScaleChanged: (value) {
                                  _currentScale = value;
                                  context
                                      .read<FaithCubit>()
                                      .changeTextScale(value);
                                },
                                onFontSelected: (font) {
                                  context.read<FaithCubit>().changeFont(font);
                                },
                              ),
                            ),
                          ));
                }
              },
              itemBuilder: (context) {
                return [
                  'Font Settings',
                  'See all notes',
                ]
                    .map(
                      (e) => PopupMenuItem(value: e, child: Text(e.tr())),
                    )
                    .toList();
              },
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.more_vert_rounded,
                  color: context.theme.disabledColor,
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
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    child: Listener(
                      onPointerUp: (event) {
                        log(event.pointer.toString());
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
                        log(event.pointer.toString());
                        touches.add(event.pointer);
                        if (touches.length > 1) {
                          if (!onScaling) {
                            setState(() {
                              onScaling = true;
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
                            _currentScale =
                                (_baseScale * details.scale).clamp(.8, 2);
                          });
                        },
                        onScaleEnd: (details) {
                          context
                              .read<FaithCubit>()
                              .changeTextScale(_currentScale);
                        },
                        child: Container(
                          color: context.colorScheme.background,
                          child: IgnorePointer(
                            ignoring: onScaling,
                            child: ListView.builder(
                              itemCount: currentData.length + 1,
                              physics: onScaling
                                  ? NeverScrollableScrollPhysics()
                                  : AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                if (index == currentData.length) {
                                  return FutureBuilder(
                                    future: selectedFaithMenuHeight,
                                    builder: (context, snapshot) {
                                      return SizedBox(
                                        height:
                                            (((state.selectedFaith.isNotEmpty
                                                        ? (snapshot.data ?? 0)
                                                        : 0)) -
                                                    80.0)
                                                .clamp(0.0, 1000.0),
                                      );
                                    },
                                  );
                                }
                                var item = currentData[index];
                                return FaithWidget(
                                  fontHeight: state.defaultTextHeight,
                                  index: index,
                                  item: item,
                                  scale: scale,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: state.selectedFaith.isNotEmpty ? 80 : null,
                  )
                ],
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
      builder: (context, state) => InkWell(
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
        child: Container(
          decoration: BoxDecoration(
            color: state.selectedFaith.contains(index)
                ? Colors.blueGrey.withOpacity(.15)
                : null,
          ),
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${item['number']}. ${item['text']}",
            textScaleFactor: scale,
            style: state.defaultTextTheme.bodyMedium?.copyWith(
              height: fontHeight,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
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
          Row(
            children: [
              Expanded(
                  child: Text(
                (indexes.map((e) => e + 1)).toList().joinToString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )),
              IconButton(
                icon: Icon(Icons.close),
                visualDensity: VisualDensity.compact,
                onPressed: context.read<FaithCubit>().removeSelection,
              ),
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Row(
            children: [
              if (indexes.length == 1) ...[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: context.colorScheme.primaryContainer,
                    foregroundColor: context.colorScheme.onPrimaryContainer,
                  ),
                  onPressed: () {
                    router.push(
                      FaithNoteRoute(
                        initialData: FaithNote.empty(
                            context.read<FaithCubit>().state.selectedFaith),
                        cubit: context.read<FaithCubit>(),
                        mode: NoteMode.write,
                        onSave: (data) {
                          context.read<FaithCubit>().saveNote(data);
                          router.pop();
                          router
                              .push(FaithNoteListRoute(cubit: context.read()));
                        },
                      ),
                    );
                  },
                  child: Text(
                    'Note'.tr(),
                  ),
                ),
                SizedBox(
                  width: 8,
                )
              ],
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: context.colorScheme.primaryContainer,
                  foregroundColor: context.colorScheme.onPrimaryContainer,
                ),
                onPressed: () async {
                  String text = '';
                  var verses = indexes.sorted((a, b) => a.compareTo(b));
                  var json =
                      await FirebaseUtils.jsonConfig('footer_copied_text');
                  var footer = json[context.locale.languageCode];
                  text = title;
                  for (var index in verses) {
                    var verse = currentData[index]['text'];
                    var number = index + 1;
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
                    var verses = indexes.sorted((a, b) => a.compareTo(b));
                    var json =
                        await FirebaseUtils.jsonConfig('footer_copied_text');
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
                  child: Text('Copy'.tr())),
            ],
          ),
          SizedBox(height: 8 + 16 + viewPadding),
        ],
      ),
    );
  }
}

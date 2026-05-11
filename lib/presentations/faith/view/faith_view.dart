// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_filex/open_filex.dart' as open_filex;
import 'package:path/path.dart' as path;
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
          title: const Text('Kidung Rohani'),
          automaticallyImplyLeading: false,
          shape: Border(
            bottom: BorderSide(color: context.colorScheme.outlineVariant),
          ),
          leading: IconButton(
            tooltip: 'Menu',
            onPressed: openDashboardDrawer,
            icon: const Icon(Icons.menu_rounded),
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
            : Column(
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
                            _currentScale = (_baseScale * details.scale).clamp(
                              .8,
                              2,
                            );
                          });
                        },
                        onScaleEnd: (details) {
                          context.read<FaithCubit>().changeTextScale(
                            _currentScale,
                          );
                        },
                        child: Container(
                          color: context.colorScheme.surface,
                          child: IgnorePointer(
                            ignoring: onScaling,
                            child: ListView.builder(
                              itemCount: currentData.length + 1,
                              physics: onScaling
                                  ? NeverScrollableScrollPhysics()
                                  : AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return _FaithHeader(title: currentTitle);
                                }
                                final faithIndex = index - 1;
                                var item = currentData[faithIndex];
                                return DefaultTextStyle.merge(
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: state.selectedFaith.contains(index)
                ? context.colorScheme.surfaceContainerHigh
                : context.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: state.selectedFaith.contains(index)
                  ? context.colorScheme.primary
                  : context.colorScheme.outlineVariant.withValues(alpha: 0.30),
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
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                right: -16,
                bottom: -24,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: (context.textTheme.headlineLarge ?? const TextStyle())
                      .copyWith(
                        fontSize: 140,
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(text: item['text'].toString()),
                          textScaler: TextScaler.linear(scale),
                          style: state.defaultTextTheme.bodyMedium?.copyWith(
                            height: fontHeight,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'LIHAT PENJELASAN LENGKAP',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.secondary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: context.colorScheme.secondary,
                            ),
                          ],
                        ),
                        FutureBuilder<String?>(
                          future: context.read<FaithCubit>().getPdfName(
                            index + 1,
                          ),
                          builder: (context, snapshot) {
                            final pdfName = snapshot.data;
                            if (pdfName == null) return SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _FaithPdfPill(
                                index: index + 1,
                                pdfName: pdfName,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: context.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sepuluh pilar iman yang menjadi pondasi kerohanian Gereja Yesus Sejati.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              height: 1.55,
            ),
          ),
        ],
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

class _FaithPdfPill extends StatelessWidget {
  const _FaithPdfPill({required this.index, required this.pdfName});

  final int index;
  final String pdfName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaithCubit, FaithState>(
      buildWhen: (previous, current) =>
          previous.pdfLoadingList != current.pdfLoadingList,
      builder: (context, state) => GestureDetector(
        onTap: () {
          if (!state.pdfLoadingList.contains(index)) {
            context.read<FaithCubit>().putPdfState(index, isLoading: true);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: context.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: context.colorScheme.secondary),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                path.basenameWithoutExtension(pdfName.split('-').last),
                style: TextStyle(
                  height: 1,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onSecondaryContainer,
                ),
              ),
              if (state.pdfLoadingList.contains(index))
                StreamBuilder<FileResponse>(
                  stream: context.read<FaithCubit>().getPdf(index),
                  builder: (context, snapshot) {
                    if (snapshot.data is FileInfo) {
                      context.read<FaithCubit>().putPdfState(
                        index,
                        isLoading: false,
                      );
                      open_filex.OpenFilex.open(
                        (snapshot.data as FileInfo).file.path,
                      );
                    }
                    return snapshot.data is DownloadProgress
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: SizedBox(
                              width: 10,
                              height: 10,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    context.colorScheme.onSecondaryContainer,
                                  ),
                                  value: (snapshot.data as DownloadProgress)
                                      .progress,
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink();
                  },
                ),
            ],
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: context.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(blurRadius: 160, color: Colors.black.withValues(alpha: .2)),
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
          Row(
            children: [
              if (indexes.length == 1) ...[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: context.colorScheme.outlineVariant,
                    foregroundColor: context.colorScheme.onSecondaryContainer,
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
                SizedBox(width: 8),
              ],
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: context.colorScheme.outlineVariant,
                  foregroundColor: context.colorScheme.onSecondaryContainer,
                ),
                onPressed: () async {
                  String text = '';
                  var verses = indexes.sorted((a, b) => a.compareTo(b));
                  var json = await FirebaseUtils.jsonConfig(
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
              SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: context.colorScheme.outlineVariant,
                  foregroundColor: context.colorScheme.onSecondaryContainer,
                ),
                onPressed: () async {
                  String text = '';
                  var verses = indexes.sorted((a, b) => a.compareTo(b));
                  var json = await FirebaseUtils.jsonConfig(
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
    );
  }
}

class CustomLoadingWidget extends StatefulWidget {
  final String text;
  final double progressValue;
  final bool isLoading;
  final bool isLoaded;
  final GestureTapCallback onOpen;

  const CustomLoadingWidget({
    super.key,
    required this.text,
    required this.progressValue,
    required this.isLoading,
    required this.isLoaded,
    required this.onOpen,
  });

  @override
  _CustomLoadingWidgetState createState() => _CustomLoadingWidgetState();
}

class _CustomLoadingWidgetState extends State<CustomLoadingWidget> {
  final GlobalKey _textKey = GlobalKey();
  Size _textSize = Size.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateTextSize());
  }

  void _calculateTextSize() {
    final RenderBox renderBox =
        _textKey.currentContext?.findRenderObject() as RenderBox;
    setState(() {
      _textSize = renderBox.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.isLoading) _buildProgressContainer(),
        _buildTextContainer(),
      ],
    );
  }

  Widget _buildProgressContainer() {
    double textWidth =
        _textSize.width; // Assuming _textSize is the size of the container
    double gradientStop =
        widget.progressValue; // Proportion of the container's width

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
      height: _textSize.height,
      width: textWidth,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          LinearProgressIndicator(value: widget.progressValue),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: const [Colors.white, Colors.black],
                      stops: [
                        gradientStop,
                        gradientStop + 0.01,
                      ], // Small delta to create a visible transition
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Loading ${(widget.progressValue * 100).toStringAsFixed(0)}%',
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: TextStyle(fontSize: 6, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContainer() {
    return Opacity(
      opacity: widget.isLoading ? 0.0 : 1.0,
      child: GestureDetector(
        onTap: widget.isLoaded ? widget.onOpen : null,
        child: Badge(
          isLabelVisible: widget.isLoaded,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          backgroundColor: context.colorScheme.secondary,
          label: Text(
            'Open'.tr(),
            style: TextStyle(
              fontSize: 8,
              height: 1,
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onSecondary,
            ),
          ),
          child: Container(
            key: _textKey,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.isLoaded
                  ? context.colorScheme.secondaryContainer
                  : context.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: context.colorScheme.outlineVariant),
            ),
            child: Text(
              widget.text + (widget.isLoaded ? '  ' : ''),
              style: TextStyle(
                fontSize: 10,
                color: widget.isLoaded
                    ? context.colorScheme.onSecondaryContainer
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

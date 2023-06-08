import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/variables/assets.dart';

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
    var language = context.locale.languageCode;
    var temp = data.firstWhereOrNull(
        (element) => element['language'] == language.toUpperCase());
    if (temp == null) return [];
    return temp['content'];
  }

  String get currentTitle {
    var language = context.locale.languageCode;
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
  double _currentScale = 1;
  double _baseScale = 1;
  double get scale => _currentScale.clamp(.5, 4);

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(currentTitle),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              context.setLocale(value);
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
                context.locale.languageCode.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
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
          : GestureDetector(
              onScaleStart: (ScaleStartDetails details) {
                _baseScale = _currentScale;
              },
              onScaleUpdate: (ScaleUpdateDetails details) {
                setState(() {
                  _currentScale = _baseScale * details.scale;
                });
              },
              child: Container(
                color: context.colorScheme.background,
                child: ListView.builder(
                  itemCount: currentData.length,
                  // controller: pageController,
                  itemBuilder: (context, index) {
                    var item = currentData[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${item['number']}. ${item['text']}",
                        textScaleFactor: scale,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

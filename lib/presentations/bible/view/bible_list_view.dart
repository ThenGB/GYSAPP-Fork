import 'dart:async';
import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../data/data.dart';
import '../../../domain/entity/bible_book/bible_book.dart';
import '../../../domain/entity/verse/verse.dart';

@RoutePage()
class BibleListView extends StatefulWidget {
  final double textScale;
  final String bibleCode;
  final List<BibleBook> books;
  final Future<List<Verse>> Function(int? bookId, int? chapterId) getBibles;
  final Function(Verse newBible) onSelected;
  const BibleListView({
    super.key,
    required this.books,
    required this.getBibles,
    required this.onSelected,
    required this.textScale,
    required this.bibleCode,
  });

  @override
  State<BibleListView> createState() => _BibleListViewState();
}

class _BibleListViewState extends State<BibleListView> {
  int pageIndex = 0;
  bool allowForceClose = false;
  bool isGridViewMode = true;

  BibleBook? selectedBook;
  int? chapter;
  int? verse;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (allowForceClose) return true;
        if (pageIndex > 0) {
          pageIndex--;
          if (pageIndex == 0) {
            selectedBook = null;
          } else if (pageIndex == 1) {
            chapter = null;
          }
          setState(() {});
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: context.colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          backgroundColor: context.colorScheme.surfaceContainerLowest,
          title: Text(
            '${selectedBook?.longName ?? 'Search'.tr()} ${chapter?.toString() ?? ''}',
          ),
          actions: [
            AnimatedSize(
              duration: kThemeAnimationDuration,
              child: pageIndex != 0
                  ? SizedBox()
                  : IconButton(
                      onPressed: () {
                        isGridViewMode = !isGridViewMode;
                        setState(() {});
                      },
                      icon: Icon(
                        isGridViewMode
                            ? Icons.format_list_bulleted_rounded
                            : Icons.grid_view_outlined,
                      ),
                    ),
            ),
          ],
        ),
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
              SharedAxisTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                fillColor: context.colorScheme.surfaceContainerLowest,
                transitionType: SharedAxisTransitionType.vertical,
                child: child,
              ),
          child: MediaQuery(
            data: context.mediaQuery.copyWith(
              textScaler: TextScaler.linear(widget.textScale),
            ),
            child: IndexedStack(
              index: pageIndex,
              key: ValueKey(pageIndex),
              alignment: Alignment.topCenter,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.colorScheme.surfaceContainerLowest,
                        context.colorScheme.surface,
                      ],
                    ),
                  ),
                  child: FutureBuilder(
                    future: FirebaseUtils.jsonConfig('bible_name'),
                    builder: (context, snapshot) {
                      log('test ${snapshot.data}');
                      return ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              snapshot.data?['Perjanjian lama']?[widget
                                      .bibleCode] ??
                                  'Perjanjian lama'.tr(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          buildGridList(widget.books.sublist(0, 39)),
                          Padding(
                            padding: EdgeInsets.only(bottom: 8, top: 12),
                            child: Text(
                              snapshot.data?['Perjanjian baru']?[widget
                                      .bibleCode] ??
                                  'Perjanjian baru'.tr(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          buildGridList(widget.books.sublist(39)),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: LayoutBuilder(
                      builder: (context, constraints) => Wrap(
                        children: [
                          ...List.generate(
                            selectedBook?.chapterCount ?? 0,
                            (index) => index,
                          ).asMap().entries.map(
                            (e) => Container(
                              padding: const EdgeInsets.all(2),
                              width: (constraints.maxWidth / 5),
                              height:
                                  (constraints.maxWidth / 8) * widget.textScale,
                              child: Material(
                                borderRadius: BorderRadius.circular(8),
                                color: context.colorScheme.surfaceContainerLow,
                                child: InkWell(
                                  onTap: () {
                                    chapter = e.value + 1;
                                    pageIndex++;
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: context
                                            .colorScheme
                                            .outlineVariant
                                            .withValues(alpha: 0.52),
                                      ),
                                    ),
                                    child: Text(
                                      (e.value + 1).toString(),
                                      textAlign: TextAlign.center,
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
                ),
                FutureBuilder(
                  future: widget.getBibles(selectedBook?.id, chapter),
                  builder: (context, snapshot) => SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (snapshot.data == null) return const SizedBox();
                        return SingleChildScrollView(
                          child: Wrap(
                            children: [
                              ...List.generate(
                                snapshot.data!.length,
                                (index) => index,
                              ).asMap().entries.map(
                                (e) => Container(
                                  padding: const EdgeInsets.all(2),
                                  width: (constraints.maxWidth / 5),
                                  height:
                                      (constraints.maxWidth / 8) *
                                      widget.textScale,
                                  child: Material(
                                    borderRadius: BorderRadius.circular(8),
                                    color:
                                        context.colorScheme.surfaceContainerLow,
                                    child: InkWell(
                                      onTap: () {
                                        allowForceClose = true;
                                        widget.onSelected(
                                          snapshot.data![e.key],
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: context
                                                .colorScheme
                                                .outlineVariant
                                                .withValues(alpha: 0.52),
                                          ),
                                        ),
                                        child: Text(
                                          (e.value + 1).toString(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LayoutBuilder buildGridList(List<BibleBook> data) {
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        children: [
          ...data.asMap().entries.map(
            (e) => AnimatedContainer(
              duration: kThemeAnimationDuration,
              padding: const EdgeInsets.all(2),
              width: isGridViewMode
                  ? (constraints.maxWidth / 6)
                  : constraints.maxWidth,
              height:
                  (isGridViewMode ? (constraints.maxWidth / 8) : 48) *
                  widget.textScale,
              child: Material(
                borderRadius: BorderRadius.circular(8),
                color: context.colorScheme.surfaceContainerLow,
                child: InkWell(
                  onTap: () {
                    selectedBook = e.value;
                    pageIndex++;
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: context.colorScheme.outlineVariant.withValues(
                          alpha: 0.52,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.all(isGridViewMode ? 4 : 8),
                    alignment: isGridViewMode
                        ? Alignment.center
                        : Alignment.centerLeft,
                    child: Text(
                      isGridViewMode
                          ? (e.value.shortName ?? '')
                          : (e.value.longName ?? ''),
                      textAlign: TextAlign.center,
                    ),
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

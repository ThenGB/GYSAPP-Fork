import 'dart:async';

import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../data/utilities/extensions/context_ext.dart';
import '../../../domain/entity/bible_book/bible_book.dart';
import '../../../domain/entity/verse/verse.dart';

@RoutePage()
class BibleListView extends StatefulWidget {
  final List<BibleBook> books;
  final Future<List<Verse>> Function(int? bookId, int? chapterId) getBibles;
  final Function(Verse newBible) onSelected;
  const BibleListView(
      {super.key,
      required this.books,
      required this.getBibles,
      required this.onSelected});

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
        appBar: AppBar(
          title: Text(
              '${selectedBook?.longName ?? 'Search'} ${chapter?.toString() ?? ''}'),
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
            )
          ],
        ),
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
              SharedAxisTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            fillColor: context.colorScheme.background,
            transitionType: SharedAxisTransitionType.vertical,
            child: child,
          ),
          child: IndexedStack(
            index: pageIndex,
            key: ValueKey(pageIndex),
            alignment: Alignment.topCenter,
            children: [
              Container(
                color: context.colorScheme.background,
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Perjanjian Lama',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    buildGridList(widget.books.sublist(0, 39)),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, top: 12),
                      child: Text(
                        'Perjanjian Baru',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    buildGridList(widget.books.sublist(39)),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) => Wrap(
                      children: [
                        ...List.generate(selectedBook?.chapterCount ?? 0,
                                (index) => index).asMap().entries.map(
                              (e) => Container(
                                padding: const EdgeInsets.all(2),
                                width: isGridViewMode
                                    ? (constraints.maxWidth / 6)
                                    : constraints.maxWidth,
                                height: constraints.maxWidth / 6,
                                child: Material(
                                  borderRadius: BorderRadius.circular(4),
                                  color: context.colorScheme.secondaryContainer,
                                  child: InkWell(
                                    onTap: () {
                                      chapter = e.value + 1;
                                      pageIndex++;
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      alignment: Alignment.center,
                                      child: Text(
                                        (e.value + 1).toString(),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
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
                                    snapshot.data!.length, (index) => index)
                                .asMap()
                                .entries
                                .map(
                                  (e) => Container(
                                    padding: const EdgeInsets.all(2),
                                    width: isGridViewMode
                                        ? (constraints.maxWidth / 6)
                                        : constraints.maxWidth,
                                    height: constraints.maxWidth / 6,
                                    child: Material(
                                      borderRadius: BorderRadius.circular(4),
                                      color: context
                                          .colorScheme.secondaryContainer,
                                      child: InkWell(
                                        onTap: () {
                                          allowForceClose = true;
                                          widget.onSelected(
                                              snapshot.data![e.key]);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          alignment: Alignment.center,
                                          child: Text(
                                            (e.value + 1).toString(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
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
                  height: isGridViewMode ? (constraints.maxWidth / 6) : 48,
                  child: Material(
                    borderRadius: BorderRadius.circular(4),
                    color: context.colorScheme.secondaryContainer,
                    child: InkWell(
                      onTap: () {
                        selectedBook = e.value;
                        pageIndex++;
                        setState(() {});
                      },
                      child: Container(
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
              )
        ],
      ),
    );
  }
}

import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../data/data.dart';
import '../../../domain/entity/bible_book/bible_book.dart';

@RoutePage()
class BibleSearchFilterView extends StatefulWidget {
  final double textScale;
  final List<BibleBook> allBooks;
  final List<BibleBook> initialValues;
  final String bibleCode;
  final Function(List<BibleBook> filtered) onFiltered;

  const BibleSearchFilterView({
    super.key,
    required this.allBooks,
    required this.initialValues,
    required this.onFiltered,
    required this.textScale,
    required this.bibleCode,
  });

  @override
  State<BibleSearchFilterView> createState() => _BibleSearchFilterViewState();
}

class _BibleSearchFilterViewState extends State<BibleSearchFilterView> {
  bool isGridViewMode = true;
  late List<BibleBook> values = List.from(widget.initialValues);
  void onTapItem(BibleBook book) {
    if (values.contains(book)) {
      values.remove(book);
    } else {
      values.add(book);
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed:
                widget.initialValues.toSet().containsAll(values) &&
                    values.toSet().containsAll(widget.initialValues)
                ? null
                : () {
                    widget.onFiltered(values);
                  },
            child: Text('Apply Filter'.tr()),
          ),
        ),
      ),
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(color: context.colorScheme.outlineVariant),
        ),
        title: const Text('Kidung Rohani'),
        centerTitle: true,
        actions: [
          AnimatedSize(
            duration: kThemeAnimationDuration,
            child: IconButton(
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
              fillColor: context.colorScheme.surface,
              transitionType: SharedAxisTransitionType.vertical,
              child: child,
            ),
        child: Container(
          color: context.colorScheme.surface,
          child: FutureBuilder(
            future: FirebaseUtils.jsonConfig('bible_name'),
            builder: (context, snapshot) => ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    snapshot.data?['Perjanjian lama']?[widget.bibleCode] ??
                        'Perjanjian lama'.tr(),
                    style: context.textTheme.headlineSmall,
                  ),
                ),
                buildGridList(widget.allBooks.sublist(0, 39)),
                Padding(
                  padding: EdgeInsets.only(bottom: 8, top: 12),
                  child: Text(
                    snapshot.data?['Perjanjian baru']?[widget.bibleCode] ??
                        'Perjanjian baru'.tr(),
                    style: context.textTheme.headlineSmall,
                  ),
                ),
                buildGridList(widget.allBooks.sublist(39)),
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
                borderRadius: BorderRadius.circular(12),
                color: values.contains(e.value)
                    ? context.colorScheme.secondaryContainer
                    : context.colorScheme.surfaceContainerLow,
                child: InkWell(
                  onTap: () {
                    onTapItem(e.value);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: values.contains(e.value)
                          ? Border.all(
                              color: context.colorScheme.secondary,
                              strokeAlign: BorderSide.strokeAlignInside,
                            )
                          : Border.all(
                              color: context.colorScheme.outlineVariant,
                              strokeAlign: BorderSide.strokeAlignInside,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textScaler: TextScaler.linear(widget.textScale),
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

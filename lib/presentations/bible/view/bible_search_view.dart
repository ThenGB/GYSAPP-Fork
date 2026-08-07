import 'dart:async';
import '../../../components/components.dart';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../../router/router.dart';
import '../../presentations.dart';

@RoutePage()
class BibleSearchView extends StatefulWidget {
  const BibleSearchView({super.key, required this.cubit, required this.onTap});
  final BibleCubit cubit;
  final Function(Verse item) onTap;

  @override
  State<BibleSearchView> createState() => _BibleSearchViewState();
}

class _BibleSearchViewState extends State<BibleSearchView> {
  late final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  Future<List<Verse>>? _searchFuture;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final text = searchController.text;
    if (text == _searchText) return;
    _searchText = text;
    _debounce?.cancel();
    if (text.isEmpty) {
      _searchFuture = Future.value(<Verse>[]);
      if (mounted) setState(() {});
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _searchFuture = widget.cubit.searchBibleByString(text);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: BlocBuilder<BibleCubit, BibleState>(
        buildWhen: (prev, curr) =>
            prev.currentBook != curr.currentBook ||
            prev.books != curr.books ||
            prev.currentBibleCode != curr.currentBibleCode ||
            prev.selectedFilterBooks != curr.selectedFilterBooks ||
            prev.defaultTextScale != curr.defaultTextScale,
        builder: (context, state) => Scaffold(
          backgroundColor: context.colorScheme.surfaceContainerLowest,
          appBar: AppBar(
            backgroundColor: context.colorScheme.surfaceContainerLowest,
            shape: Border(
              bottom: BorderSide(
                color: context.colorScheme.outlineVariant.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            title: Text('bible_search_title'.tr()),
            centerTitle: true,
          ),
          body: MediaQuery(
            data: context.mediaQuery.copyWith(
              textScaler: TextScaler.linear(
                widget.cubit.state.defaultTextScale,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerLow,
                      borderRadius: context.appRadius(8),
                      border: Border.all(
                        color: context.colorScheme.outlineVariant.withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ),
                    child: TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          CupertinoIcons.doc_text_search,
                          color: context.colorScheme.primary,
                        ),
                        suffixIcon: IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            searchController.clear();
                          },
                        ),
                        filled: true,
                        fillColor: context.colorScheme.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: context.appRadius(8),
                          borderSide: BorderSide(
                            color: context.colorScheme.outlineVariant,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: context.appRadius(8),
                          borderSide: BorderSide(
                            color: context.colorScheme.outlineVariant,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: context.appRadius(8),
                          borderSide: BorderSide(
                            color: context.colorScheme.primary,
                            width: 1.2,
                          ),
                        ),
                        isDense: true,
                        hintText: 'Search verses'.tr(),
                      ),
                    ),
                  ),
                ),
                FutureBuilder(
                  future: AppConfigStore.jsonConfig('bible_name'),
                  builder: (context, snapshot) => Wrap(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          widget.cubit.onFilterPerjanjianLama();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: state.isSelectedPerjanjianLama,
                              tristate: true,
                              onChanged: (value) {
                                widget.cubit.onFilterPerjanjianLama();
                              },
                            ),
                            Text(
                              snapshot.data?['Perjanjian lama']?[state
                                      .currentBibleCode] ??
                                  'Perjanjian lama'.tr(),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          widget.cubit.onFilterPerjanjianBaru();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: state.isSelectedPerjanjianBaru,
                              tristate: true,
                              onChanged: (value) {
                                widget.cubit.onFilterPerjanjianBaru();
                              },
                            ),
                            Text(
                              snapshot.data?['Perjanjian baru']?[state
                                      .currentBibleCode] ??
                                  'Perjanjian baru'.tr(),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          widget.cubit.onFilterCurrentBible();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: state.isSelectedCurrentBook,
                              tristate: true,
                              onChanged: (value) {
                                widget.cubit.onFilterCurrentBible();
                              },
                            ),
                            Text(state.currentBook?.longName ?? ''),
                          ],
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          router.push(
                            BibleSearchFilterRoute(
                              textScale: state.defaultTextScale,
                              allBooks: state.books,
                              bibleCode: state.currentBibleCode,
                              initialValues: state.selectedFilterBooks,
                              onFiltered: (filter) {
                                widget.cubit.updateFilterBook(filter);
                                router.maybePop();
                              },
                            ),
                          );
                        },
                        color: context.colorScheme.primary,
                        icon: Icon(Icons.menu_book_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Verse>>(
                    future: _searchFuture,
                    builder: (context, snapshot) =>
                        (!snapshot.hasData || snapshot.data?.isEmpty == true)
                        ? searchController.text.isEmpty
                              ? NoDataFound(
                                  title: 'Search terms to start'.tr(),
                                  description:
                                      'Make sure your spellings is correct'
                                          .tr(),
                                )
                              : NoDataFound(
                                  title: 'not found'.tr(
                                    args: ['"${searchController.text}"'],
                                  ),
                                  description:
                                      'Correct your spellings or search another terms'
                                          .tr(),
                                )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              var item = snapshot.data![index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: context.colorScheme.surfaceContainerLow,
                                  borderRadius: context.appRadius(8),
                                  border: Border.all(
                                    color: context.colorScheme.outlineVariant.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  onTap: () {
                                    widget.onTap(item);
                                  },
                                  title: FutureBuilder(
                                    future: widget.cubit.getBibleTitle([
                                      item,
                                    ], withVerse: true),
                                    builder: (context, snapshot) => Builder(
                                      builder: (context) {
                                        var sentence = (item.verse ?? '')
                                            .replaceAll('  ', ' ');
                                        sentence = removeTextBetweenTags(
                                          sentence,
                                          'f',
                                        );
                                        sentence = sentence.replaceAll(
                                          '<pb/>',
                                          '    ',
                                        );
                                        sentence = sentence.replaceAll(
                                          '<t>',
                                          '',
                                        );
                                        sentence = sentence.replaceAll(
                                          '</t>',
                                          '',
                                        );
                                        sentence = sentence.replaceAll(
                                          '<i>',
                                          '',
                                        );
                                        sentence = sentence.replaceAll(
                                          '</i>',
                                          '',
                                        );
                                        sentence = sentence.replaceAll(
                                          '<J>',
                                          '',
                                        );
                                        sentence = sentence.replaceAll(
                                          '</J>',
                                          '',
                                        );

                                        return Text.rich(
                                          style: TextStyle(fontSize: context.appFontSize(12)),
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    snapshot.data ??
                                                    'Loading...'.tr(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              TextSpan(text: ' : '),
                                              buildHighlightedText(
                                                isUnderline: true,
                                                style: TextStyle(
                                                  fontSize: context.appFontSize(12),
                                                ),
                                                sentence,
                                                () {
                                                  var list =
                                                      RegExp(r'"([^"]+)"')
                                                          .allMatches(
                                                            searchController
                                                                .text,
                                                          )
                                                          .map(
                                                            (e) =>
                                                                e.group(1)!,
                                                          )
                                                          .toList();
                                                  list.addAll(
                                                    searchController.text
                                                        .split(' '),
                                                  );
                                                  return list;
                                                }(),
                                                context,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
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

  TextSpan mergeBuildStyledText(TextSpan originalSpan) {
    String text = originalSpan.text ?? '';
    List<TextSpan> spans = [];
    int currentIndex = 0;

    TextStyle baseStyle = originalSpan.style ?? TextStyle();

    while (currentIndex < text.length) {
      int startTagIndex = text.indexOf('<J>', currentIndex);
      if (startTagIndex == -1) {
        spans.add(
          TextSpan(text: text.substring(currentIndex), style: baseStyle),
        );
        break;
      }

      int endTagIndex = text.indexOf('</J>', startTagIndex);
      if (endTagIndex == -1) {
        spans.add(
          TextSpan(text: text.substring(currentIndex), style: baseStyle),
        );
        break;
      }

      spans.add(
        TextSpan(
          text: text.substring(currentIndex, startTagIndex),
          style: baseStyle,
        ),
      );
      spans.add(
        TextSpan(
          text: text.substring(startTagIndex + 3, endTagIndex),
          style: baseStyle.copyWith(
            color: context.isLight
                ? Color(0xffFF3131)
                : Color(0xffEE4B2B), // Apply red color
          ),
        ),
      );

      currentIndex = endTagIndex + 4; // +4 to skip </J>
    }

    return TextSpan(children: spans);
  }
}

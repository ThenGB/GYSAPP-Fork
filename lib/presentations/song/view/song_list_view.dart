import 'package:auto_route/auto_route.dart';
import 'package:church/data/utilities/extensions/context_ext.dart';
import 'package:church/domain/entity/song/song_entity.dart';
import 'package:church/router/router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SongListView extends StatefulWidget {
  final List<SongBook> Function() books;
  final List<SongBook> Function() favoriteBooks;
  final SongBook Function() currentBook;
  final Function(String pageNumber) onTapPageNumber;
  final Function(Song song) onTapFavorite;
  final Function(String bookCode) onChangeBookCode;
  final bool Function(Song song) isFavorite;
  final Function(Song song) onFavorite;

  const SongListView(
      {super.key,
      required this.books,
      required this.currentBook,
      required this.onTapPageNumber,
      required this.onChangeBookCode,
      required this.isFavorite,
      required this.onFavorite,
      required this.favoriteBooks,
      required this.onTapFavorite});

  @override
  State<SongListView> createState() => _SongListViewState();
}

class _SongListViewState extends State<SongListView>
    with SingleTickerProviderStateMixin {
  late final TextEditingController searchController = TextEditingController()
    ..addListener(searchListener);
  late final TabController tabController = TabController(length: 2, vsync: this)
    ..addListener(tabListener);
  @override
  void dispose() {
    searchController.dispose();
    tabController.dispose();
    super.dispose();
  }

  searchListener() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  tabListener() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  List<Song> getFilteredItems(List<Song> data) {
    var value = searchController.text;
    List<Song> result = [];
    if (value.isNotEmpty) {
      result = List.from(data.where((element) =>
          (element.number?.toLowerCase().contains(value.toLowerCase()) ??
              false) ||
          (element.title?.toLowerCase().contains(value.toLowerCase()) ??
              true)));
    } else {
      result = List.from(data);
    }
    return result;
  }

  int forceRefresh = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 56,
        titleSpacing: 0,
        leading: Center(
          child: GestureDetector(
            onTap: () {
              router.pop();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: context.theme.disabledColor),
                shape: BoxShape.circle,
                color: context.theme.canvasColor,
              ),
              child: Icon(
                Icons.home,
                color: context.theme.disabledColor,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    fixedSize: const Size(100, 32),
                    backgroundColor: tabController.index == 0
                        ? context.colorScheme.primaryContainer
                        : Colors.transparent,
                    side: BorderSide(
                      strokeAlign: BorderSide.strokeAlignCenter,
                      width: 1,
                      color: tabController.index == 0
                          ? context.colorScheme.primary
                          : context.theme.disabledColor,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(100),
                      ),
                    )),
                onPressed: () {
                  tabController.animateTo(0);
                },
                child: Text('Lists'.tr()),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    fixedSize: const Size(100, 32),
                    backgroundColor: tabController.index == 1
                        ? context.colorScheme.primaryContainer
                        : Colors.transparent,
                    side: BorderSide(
                      strokeAlign: BorderSide.strokeAlignCenter,
                      width: 1,
                      color: tabController.index == 1
                          ? context.colorScheme.primary
                          : context.theme.disabledColor,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(100),
                      ),
                    )),
                onPressed: () {
                  tabController.animateTo(1);
                },
                child: Text('Favorite'.tr()),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          Container(
            color: context.colorScheme.background,
            child: Column(children: [
              const Divider(
                height: 1,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Stack(
                  children: [
                    TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                        isDense: true,
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8)
                            .add(
                          const EdgeInsets.only(right: 100),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        hintText: 'Search number or keyword'.tr(),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: PopupMenuButton(
                          onSelected: (value) async {
                            await widget.onChangeBookCode(value);
                            await Future.delayed(
                                const Duration(milliseconds: 100));
                            setState(() {
                              forceRefresh++;
                            });
                          },
                          initialValue: widget.currentBook().code,
                          itemBuilder: (context) {
                            return widget
                                .books()
                                .map((e) => PopupMenuItem(
                                    value: e.code, child: Text(e.code ?? '')))
                                .toList();
                          },
                          child: Container(
                              width: 100,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.all(2),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(7)),
                                color: context.colorScheme.secondaryContainer,
                              ),
                              child: Text(
                                widget.currentBook().code ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount:
                      getFilteredItems(widget.currentBook().songs).length,
                  itemBuilder: (context, index) {
                    var item =
                        getFilteredItems(widget.currentBook().songs)[index];
                    return Column(
                      children: [
                        ListTile(
                          onTap: () {
                            widget.onTapPageNumber(item.number!);
                          },
                          leading: Text(item.number ?? ''),
                          trailing: IconButton(
                              onPressed: () async {
                                widget.onFavorite(item);
                                await Future.delayed(
                                    const Duration(milliseconds: 100));
                                setState(() {
                                  forceRefresh++;
                                });
                              },
                              icon: Icon(
                                widget.isFavorite(item)
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: widget.isFavorite(item)
                                    ? Colors.amber
                                    : null,
                              )),
                          title: Text(
                            item.title ?? '',
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    );
                  },
                ),
              ),
            ]),
          ),
          ListView.builder(
            itemCount: widget.favoriteBooks().length,
            itemBuilder: (context, index) {
              var book = widget.favoriteBooks()[index];
              if (book.songs.isEmpty) return const SizedBox();
              return Column(
                children: [
                  ListTile(
                    title: Text(book.code ?? ''),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: book.songs.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var item = book.songs[index];
                      return Column(
                        children: [
                          ListTile(
                            onTap: () {
                              widget.onTapFavorite(item);
                            },
                            leading: Text(item.number ?? ''),
                            trailing: IconButton(
                                onPressed: () async {
                                  widget.onFavorite(item);
                                  await Future.delayed(
                                      const Duration(milliseconds: 100));
                                  setState(() {
                                    forceRefresh++;
                                  });
                                },
                                icon: Icon(
                                  widget.isFavorite(item)
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: widget.isFavorite(item)
                                      ? Colors.amber
                                      : null,
                                )),
                            title: Text(
                              item.title ?? '',
                            ),
                          ),
                          const Divider(height: 1),
                        ],
                      );
                    },
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

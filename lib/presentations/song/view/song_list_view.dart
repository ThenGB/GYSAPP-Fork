import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../data/data.dart';
import '../../../domain/entity/song/song_entity.dart';
import '../../../router/router.dart';
import '../../presentations.dart';

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

  final String initialSearchText;
  final Function(String text) onSearchTermsChanged;

  const SongListView(
      {super.key,
      required this.books,
      required this.currentBook,
      required this.onTapPageNumber,
      required this.onChangeBookCode,
      required this.isFavorite,
      required this.onFavorite,
      required this.favoriteBooks,
      required this.onTapFavorite,
      required this.initialSearchText,
      required this.onSearchTermsChanged});

  @override
  State<SongListView> createState() => _SongListViewState();
}

class _SongListViewState extends State<SongListView>
    with SingleTickerProviderStateMixin {
  late final TextEditingController searchController =
      TextEditingController(text: widget.initialSearchText)
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
      result = List.from(
        data.where(
          (element) {
            var title = element.title?.toLowerNoSpace ?? '';
            var lyric = element.verses.join().toLowerNoSpace;
            var search = value.toLowerNoSpace;
            bool containNumber =
                (element.number?.toLowerNoSpace.contains(search) ?? false);
            bool containTitle = title.contains(search);
            bool containLyric = lyric.contains(search);
            return containNumber || containTitle || containLyric;
          },
        ),
      );

      // Sort based on priority (Title match first, then Lyrics match)
      // result.sort((a, b) {
      //   var aNumber = int.tryParse(a.number?.toLowerNoSpace ?? '') ?? 0;
      //   var bNumber = int.tryParse(b.number?.toLowerNoSpace ?? '') ?? 0;

      //   var aTitle = a.title?.toLowerCase() ?? '';
      //   var bTitle = b.title?.toLowerCase() ?? '';
      //   var aLyric = a.verses.join().toLowerCase();
      //   var bLyric = b.verses.join().toLowerCase();

      //   if (aTitle.contains(value)) {
      //     return -1; // Put aTitle first
      //   } else if (bTitle.contains(value)) {
      //     return 1; // Put bTitle first
      //   } else {
      //     if (aNumber != bNumber) {
      //       return aNumber.compareTo(bNumber);
      //     } else {
      //       return aLyric.compareTo(bLyric);
      //     }
      //   }
      // });
    } else {
      result = List.from(data);
    }

    return result;
  }

  int forceRefresh = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.background,
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
                          const EdgeInsets.only(right: 100 + 48),
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
                          offset: Offset(0, 48),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedBuilder(
                                animation: searchController,
                                builder: (context, child) =>
                                    searchController.text.isEmpty
                                        ? SizedBox.shrink()
                                        : CloseButton(
                                            onPressed: () {
                                              searchController.clear();
                                            },
                                          ),
                              ),
                              Container(
                                  width: 100,
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.all(2),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.horizontal(
                                        right: Radius.circular(7)),
                                    color:
                                        context.colorScheme.secondaryContainer,
                                  ),
                                  child: Text(
                                    widget.currentBook().code ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  )),
                            ],
                          ),
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
                        Material(
                          child: ListTile(
                            onTap: () {
                              widget
                                  .onSearchTermsChanged(searchController.text);
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
                              (item.title ?? '').capitalizeEachWord(),
                            ),
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
          Visibility(
            visible: widget.favoriteBooks().fold<int>(
                    0,
                    (previousValue, element) =>
                        previousValue + element.songs.length) >
                0,
            replacement: NoDataFound(
              title: 'No favorite',
              description: 'Add favorite and see it here'.tr(),
            ),
            child: ListView.builder(
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
                                widget.onSearchTermsChanged(
                                    searchController.text);
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
          ),
        ],
      ),
    );
  }
}

extension StringLowerSpace on String {
  String get toLowerNoSpace {
    return toLowerCase().replaceAll(' ', '');
  }
}

class PageTurnWidget extends StatefulWidget {
  const PageTurnWidget({
    Key? key,
    required this.amount,
    this.backgroundColor = const Color(0xFFFFFFCC),
    required this.child,
  }) : super(key: key);

  final Animation<double> amount;
  final Color backgroundColor;
  final Widget child;

  @override
  _PageTurnWidgetState createState() => _PageTurnWidgetState();
}

class _PageTurnWidgetState extends State<PageTurnWidget> {
  final _boundaryKey = GlobalKey();
  ui.Image? _image;

  @override
  void didUpdateWidget(PageTurnWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      _image = null;
    }
  }

  void _captureImage(Duration timeStamp) async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final boundary = _boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    setState(() => _image = image);
  }

  @override
  Widget build(BuildContext context) {
    if (_image != null) {
      return CustomPaint(
        painter: _PageTurnEffect(
          amount: widget.amount,
          image: _image!,
          backgroundColor: widget.backgroundColor,
        ),
        size: Size.infinite,
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback(_captureImage);
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final size = constraints.biggest;
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: 1 + size.width,
                top: 1 + size.height,
                width: size.width,
                height: size.height,
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: widget.child,
                ),
              ),
            ],
          );
        },
      );
    }
  }
}

class _PageTurnEffect extends CustomPainter {
  _PageTurnEffect({
    required this.amount,
    required this.image,
    required this.backgroundColor,
  }) : super(repaint: amount);

  final Animation<double> amount;
  final ui.Image image;
  final Color backgroundColor;
  final double radius = 0.18;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final pos = amount.value;
    final movX = (1.0 - pos) * 0.85;
    final calcR = (movX < 0.20) ? radius * movX * 5 : radius;
    final wHRatio = 1 - calcR;
    final hWRatio = image.height / image.width;
    final hWCorrection = (hWRatio - 1.0) / 2.0;

    final w = size.width.toDouble();
    final h = size.height.toDouble();
    final c = canvas;
    final shadowXf = (wHRatio - movX);
    final shadowSigma =
        Shadow.convertRadiusToSigma(8.0 + (32.0 * (1.0 - shadowXf)));
    final pageRect = Rect.fromLTRB(0.0, 0.0, w * shadowXf, h);
    c.drawRect(pageRect, Paint()..color = backgroundColor);
    c.drawRect(
      pageRect,
      Paint()
        ..color = Colors.black54
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, shadowSigma),
    );

    final ip = Paint();
    for (double x = 0; x < size.width; x++) {
      final xf = (x / w);
      final v = (calcR * (math.sin(math.pi / 0.5 * (xf - (1.0 - pos)))) +
          (calcR * 1.1));
      final xv = (xf * wHRatio) - movX;
      final sx = (xf * image.width);
      final sr = Rect.fromLTRB(sx, 0.0, sx + 1.0, image.height.toDouble());
      final yv = ((h * calcR * movX) * hWRatio) - hWCorrection;
      final ds = (yv * v);
      final dr = Rect.fromLTRB(xv * w, 0.0 - ds, xv * w + 1.0, h + ds);
      c.drawImageRect(image, sr, dr, ip);
    }
  }

  @override
  bool shouldRepaint(_PageTurnEffect oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.amount.value != amount.value;
  }
}

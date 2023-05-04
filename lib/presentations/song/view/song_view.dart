import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:church/data/utilities/extensions/context_ext.dart';
import 'package:church/data/utilities/variables/assets.dart';
import 'package:church/presentations/song/cubit/song_cubit.dart';
import 'package:church/router/router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

@RoutePage()
class SongView extends StatefulWidget {
  const SongView({super.key});

  @override
  State<SongView> createState() => _SongViewState();
}

class _SongViewState extends State<SongView> {
  late final PageController pageController = PageController()
    ..addListener(pageListener);

  PageController? verseController;

  int currentPageIndex = 0;
  int currentVerseIndex = 0;

  pageListener() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      currentPageIndex = pageController.page?.toInt() ?? 0;
      currentVerseIndex = 0;
      context.read<SongCubit>().changePage(currentPageIndex, currentVerseIndex);
      setState(() {});
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongCubit, SongState>(
      builder: (context, state) => Scaffold(
          appBar: AppBar(
            leadingWidth: 56,
            titleSpacing: 0,
            leading: Center(
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
            title: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          strokeAlign: BorderSide.strokeAlignCenter,
                          width: 1,
                          color: context.theme.disabledColor,
                        ),
                        backgroundColor: context
                                .read<SongCubit>()
                                .isSongFavorite(
                                    state.currentSong?.songs[currentPageIndex])
                            ? Colors.amber.shade100
                            : Colors.transparent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(100),
                          ),
                        )),
                    onPressed: () {
                      router.push(SongListRoute(
                          onTapFavorite: (song) {
                            /// change the book
                            context
                                .read<SongCubit>()
                                .changeBookcode(song.code!);
                            Future.delayed(const Duration(milliseconds: 100))
                                .then((value) {
                              /// change the page number
                              var index = state.currentSong?.songs.indexWhere(
                                  (element) => element.number == song.number);
                              if (index == null) return;
                              pageController.animateToPage(index,
                                  duration: kThemeAnimationDuration,
                                  curve: Curves.easeOut);

                              router.pop();
                            });
                          },
                          favoriteBooks: () =>
                              context.read<SongCubit>().state.favoriteSongBook,
                          onFavorite: (song) {
                            context.read<SongCubit>().modifyFavorite(song);
                          },
                          isFavorite: (song) =>
                              context.read<SongCubit>().isSongFavorite(song),
                          currentBook: () =>
                              context.read<SongCubit>().state.currentSong!,
                          books: () => context.read<SongCubit>().state.songBook,
                          onChangeBookCode: (bookCode) {
                            context.read<SongCubit>().changeBookcode(bookCode);
                          },
                          onTapPageNumber: (pageNumber) {
                            var index = state.currentSong?.songs.indexWhere(
                                (element) => element.number == pageNumber);
                            if (index == null) return;
                            pageController.animateToPage(index,
                                duration: kThemeAnimationDuration,
                                curve: Curves.easeOut);
                            router.pop();
                          }));
                    },
                    child: Text(
                      state.currentSong?.songs[currentPageIndex].number
                              .toString() ??
                          '--',
                      style: TextStyle(
                        color: context.read<SongCubit>().isSongFavorite(
                                state.currentSong?.songs[currentPageIndex])
                            ? Colors.orange
                            : null,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          strokeAlign: BorderSide.strokeAlignCenter,
                          width: 1,
                          color: context.theme.disabledColor,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(100),
                          ),
                        )),
                    onPressed: () {},
                    child: Text(state.currentSong?.code ?? ''),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  currentVerseIndex = 0;
                  context.read<SongCubit>().changeMode();
                },
                visualDensity: VisualDensity.compact,
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      context.theme.disabledColor, BlendMode.srcIn),
                  child: Image.asset(
                    state.isImageMode
                        ? Assets.assetsIconsLyrics
                        : Assets.assetsIconsNote,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              PopupMenuButton(
                onSelected: (value) async {
                  if (value == 'fav') {
                    context.read<SongCubit>().modifyFavorite(
                        state.currentSong!.songs[currentPageIndex]);
                  } else if (value == 'copy') {
                    var number =
                        state.currentSong!.songs[currentPageIndex].number;
                    var title =
                        state.currentSong!.songs[currentPageIndex].title;
                    var verse = state.currentSong!.songs[currentPageIndex]
                        .verses[currentVerseIndex];
                    var text =
                        '$number - $title\n\n${currentVerseIndex + 1}. $verse';
                    await Clipboard.setData(ClipboardData(text: text));
                    Fluttertoast.cancel();
                    Fluttertoast.showToast(msg: 'Copied to clipboard'.tr());
                  } else if (value == 'size') {
                    context.read<SongCubit>().toggleSizer();
                  } else if (value == 'share') {
                    var number =
                        state.currentSong!.songs[currentPageIndex].number;
                    var title =
                        state.currentSong!.songs[currentPageIndex].title;
                    var verse = state.currentSong!.songs[currentPageIndex]
                        .verses[currentVerseIndex];
                    var text =
                        '$number - $title\n\n${currentVerseIndex + 1}. $verse';
                    Share.share(text, subject: '$number - $title');
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                itemBuilder: (context) => [
                  ['Copy'.tr(), 'copy'],
                  [
                    (context.read<SongCubit>().isSongFavorite(
                                state.currentSong?.songs[currentPageIndex])
                            ? 'Remove from Favorite'
                            : 'Add to Favorite')
                        .tr(),
                    'fav'
                  ],
                  [
                    (state.showSizer ? 'Hide Sizer' : 'Show Sizer').tr(),
                    'size'
                  ],
                  ['Share'.tr(), 'share']
                ]
                    .map(
                      (e) => PopupMenuItem(
                        value: e[1],
                        child: Text(e[0]),
                      ),
                    )
                    .toList(),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: context.theme.disabledColor,
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
            ],
          ),
          body: Container(
            color: context.colorScheme.background,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                PageView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  itemCount: state.currentSong?.songs.length ?? 0,
                  itemBuilder: (context, songIndex) {
                    var song = state.songBook
                        .firstWhere((element) => element.code == state.bookCode)
                        .songs[songIndex];
                    double tempScale = state.textScaleFactor;
                    return GestureDetector(
                      onScaleEnd: (details) {
                        if (details.pointerCount > 0) {
                          context.read<SongCubit>().changeScale(tempScale);
                        }
                        log('updating scale $tempScale');
                      },
                      onScaleUpdate: (details) {
                        tempScale = details.scale.clamp(1, 1.5);
                        // context.read<SongCubit>().changeScale(tempScale);
                      },
                      child: Column(
                        children: [
                          Text(
                            song.title ?? '',
                            textAlign: TextAlign.center,
                            textScaleFactor: state.textScaleFactor,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Divider(),
                          Expanded(
                            child: PageView.builder(
                              controller: () {
                                verseController = PageController();
                                return verseController;
                              }(),
                              onPageChanged: (value) {
                                currentVerseIndex = value;
                                setState(() {});
                              },
                              scrollDirection: Axis.vertical,
                              itemCount: state.isImageMode
                                  ? state
                                      .currentSong!.songs[songIndex].pageLength
                                  : state.currentSong!.songs[songIndex].verses
                                      .length,
                              itemBuilder: (context, index) {
                                if (state.isImageMode) {
                                  return FutureBuilder(
                                    future: state.getImageLyricPath(
                                        song.pageStart ?? 0,
                                        song.pageLength ?? 0),
                                    builder: (context, snapshot) {
                                      if (snapshot.data?.isNotEmpty == true) {
                                        precacheImage(
                                            MemoryImage(snapshot.data![index]),
                                            context);
                                        return Image.memory(
                                            snapshot.data![index]);
                                      }
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  );
                                }
                                var item = song.verses[index];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    item,
                                    textAlign: TextAlign.center,
                                    textScaleFactor: state.textScaleFactor,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          pageController.previousPage(
                              duration: kThemeAnimationDuration,
                              curve: Curves.easeOut);
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_left_rounded,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          pageController.nextPage(
                              duration: kThemeAnimationDuration,
                              curve: Curves.easeOut);
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_right_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          verseController?.previousPage(
                              duration: kThemeAnimationDuration,
                              curve: Curves.easeOut);
                        },
                        icon: const Icon(Icons.keyboard_arrow_up_rounded),
                      ),
                      Text(
                          '${currentVerseIndex + 1}/${state.isImageMode ? state.currentSong!.songs[currentPageIndex].pageLength : state.currentSong!.songs[currentPageIndex].verses.length}'),
                      IconButton(
                        onPressed: () {
                          verseController?.nextPage(
                              duration: kThemeAnimationDuration,
                              curve: Curves.easeOut);
                        },
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ],
                  ),
                ),
                if (state.showSizer)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        shape: const StadiumBorder(),
                        elevation: 2,
                        child: SizedBox(
                          height: 32,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [-.1, .1]
                                .map((e) => IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () {
                                      context
                                          .read<SongCubit>()
                                          .modifyTextScaleFactor(e);
                                    },
                                    icon: Icon(e.isNegative
                                        ? Icons.remove
                                        : Icons.add)))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          )),
    );
  }
}

import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/variables/assets.dart';
import '../../../router/router.dart';
import '../cubit/song_cubit.dart';

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
  double _baseScale = 1;
  late double _currentScale = context.read<SongCubit>().state.textScaleFactor;

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

  Set<int> touches = {};

  bool onScaling = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongCubit, SongState>(
      builder: (context, state) => Scaffold(
          backgroundColor: context.colorScheme.background,
          bottomNavigationBar: AnimatedSize(
            duration: kThemeAnimationDuration,
            alignment: Alignment.bottomCenter,
            curve: Curves.easeOut,
            child: state.isAudioLoading
                ? const SizedBox(
                    width: double.infinity,
                  )
                : SizedBox(
                    height: 48,
                    child: ListTile(
                      tileColor: context.colorScheme.background,
                      leading: StreamBuilder<PlayerState>(
                        stream: context
                            .read<SongCubit>()
                            .audioPlayer
                            .onPlayerStateChanged,
                        builder: (context, snapshot) => IconButton(
                          onPressed: () {
                            if (snapshot.data == PlayerState.playing) {
                              context.read<SongCubit>().pause();
                            } else if (snapshot.data == PlayerState.paused) {
                              context.read<SongCubit>().play();
                            } else {
                              context.read<SongCubit>().play();
                            }
                          },
                          icon: !snapshot.hasData
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Center(
                                      child: CircularProgressIndicator()))
                              : Icon(
                                  snapshot.data == PlayerState.playing
                                      ? Icons.pause_circle
                                      : Icons.play_circle_rounded,
                                ),
                        ),
                      ),
                      dense: true,
                      horizontalTitleGap: 0,
                      title: FutureBuilder(
                        future:
                            context.read<SongCubit>().audioPlayer.getDuration(),
                        builder: (context, futureSnapshot) =>
                            StreamBuilder<Duration>(
                          stream: context
                              .read<SongCubit>()
                              .audioPlayer
                              .onPositionChanged,
                          builder: (context, positionSnapshot) =>
                              StreamBuilder<Duration>(
                            stream: context
                                .read<SongCubit>()
                                .audioPlayer
                                .onDurationChanged,
                            builder: (context, durationSnapshot) => Slider(
                              value: ((positionSnapshot.data?.inSeconds ?? 0) /
                                      (durationSnapshot.data?.inSeconds ??
                                          futureSnapshot.data?.inSeconds ??
                                          0))
                                  .clamp(0, 1),
                              onChanged: (value) {
                                var second =
                                    (durationSnapshot.data?.inSeconds ??
                                            futureSnapshot.data?.inSeconds ??
                                            1) *
                                        value;
                                context
                                    .read<SongCubit>()
                                    .audioPlayer
                                    .seek(Duration(seconds: second.toInt()));
                              },
                            ),
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StreamBuilder<Duration>(
                            stream: context
                                .read<SongCubit>()
                                .audioPlayer
                                .onPositionChanged,
                            builder: (context, positionSnapshot) =>
                                StreamBuilder<Duration>(
                              stream: context
                                  .read<SongCubit>()
                                  .audioPlayer
                                  .onDurationChanged,
                              builder: (context, durationSnapshot) {
                                String durationToString(Duration duration) {
                                  if (duration.inHours >= 1) {
                                    final hours = duration.inHours;
                                    final minutes =
                                        duration.inMinutes.remainder(60);
                                    final seconds =
                                        duration.inSeconds.remainder(60);
                                    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                                  } else {
                                    final minutes = duration.inMinutes;
                                    final seconds =
                                        duration.inSeconds.remainder(60);
                                    return '$minutes:${seconds.toString().padLeft(2, '0')}';
                                  }
                                }

                                var text = '--';
                                if (positionSnapshot.data != null) {
                                  text =
                                      durationToString(positionSnapshot.data!);
                                }
                                if (durationSnapshot.data != null) {
                                  text =
                                      '$text/${durationToString(durationSnapshot.data!)}';
                                }
                                return Text(
                                  text,
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          PopupMenuButton(
                            initialValue: state.defaultAudioFormat,
                            onSelected: (value) {
                              context
                                  .read<SongCubit>()
                                  .changeAudioFormat(value);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 8, bottom: 4, top: 4),
                              decoration: BoxDecoration(
                                color: context.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                state.defaultAudioFormat == 'mp3'
                                    ? 'MP3'
                                    : 'MIDI',
                              ),
                            ),
                            itemBuilder: (context) {
                              return ['mp3', 'mid']
                                  .map(
                                    (e) => PopupMenuItem(
                                      value: e,
                                      child: Text(e == 'mp3' ? 'MP3' : 'MIDI'),
                                    ),
                                  )
                                  .toList();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
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
          body: Listener(
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
            onPointerMove: (event) {
              log(touches.toString());
            },
            child: Container(
              color: context.colorScheme.background,
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  PageView.builder(
                    controller: pageController,
                    physics: onScaling
                        ? NeverScrollableScrollPhysics()
                        : AlwaysScrollableScrollPhysics(),
                    itemCount: state.currentSong?.songs.length ?? 0,
                    itemBuilder: (context, songIndex) {
                      var song = state.songBook
                          .firstWhere(
                              (element) => element.code == state.bookCode)
                          .songs[songIndex];

                      return GestureDetector(
                        onScaleStart: (ScaleStartDetails details) {
                          _baseScale = _currentScale;
                        },
                        onScaleUpdate: (ScaleUpdateDetails details) {
                          log('Scaling');
                          setState(() {
                            _currentScale = _baseScale * details.scale;
                          });
                        },
                        onScaleEnd: (details) {
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) {
                            context
                                .read<SongCubit>()
                                .changeScale(_baseScale * _currentScale);
                          });
                        },
                        child: Column(
                          children: [
                            if (!state.isImageMode)
                              Text(
                                song.title ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            const Divider(),
                            Expanded(
                              child: PageView.builder(
                                physics: onScaling
                                    ? NeverScrollableScrollPhysics()
                                    : AlwaysScrollableScrollPhysics(),
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
                                    ? state.currentSong!.songs[songIndex]
                                        .pageLength
                                    : state.currentSong!.songs[songIndex].verses
                                        .length,
                                itemBuilder: (context, index) {
                                  if (state.isImageMode) {
                                    return FutureBuilder(
                                      future: state.getImageLyricPath(
                                          context,
                                          song.pageStart ?? 0,
                                          song.pageLength ?? 0),
                                      builder: (context, snapshot) {
                                        if (snapshot.data?.isNotEmpty == true) {
                                          precacheImage(
                                              MemoryImage(
                                                  snapshot.data![index]),
                                              context);
                                          return OrientationBuilder(
                                            builder: (context, orientation) {
                                              var child = Image.memory(
                                                snapshot.data![index],
                                                width: double.infinity,
                                                fit: BoxFit.fitWidth,
                                              );
                                              if (orientation ==
                                                  Orientation.portrait) {
                                                return InteractiveViewer(
                                                  child: child,
                                                );
                                              } else {
                                                return SingleChildScrollView(
                                                    child: child);
                                              }
                                            },
                                          );
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
                                      textScaleFactor: _currentScale,
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
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: AnimatedCrossFade(
                        alignment: Alignment.centerLeft,
                        duration: Duration(milliseconds: 100),
                        crossFadeState: !onScaling
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        secondChild: Container(
                          width: 80,
                          height: 48,
                          color: Colors.transparent,
                        ),
                        firstChild: Row(
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
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: AnimatedCrossFade(
                        alignment: Alignment.centerLeft,
                        duration: Duration(milliseconds: 100),
                        crossFadeState: !onScaling
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        secondChild: Container(
                          height: 110,
                          width: 48,
                          color: Colors.transparent,
                        ),
                        firstChild: Column(
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
                                '${currentVerseIndex + 1}/${state.isImageMode ? (state.currentSong?.songs[currentPageIndex].pageLength ?? 0) : (state.currentSong?.songs[currentPageIndex].verses.length ?? 0)}'),
                            IconButton(
                              onPressed: () {
                                verseController?.nextPage(
                                    duration: kThemeAnimationDuration,
                                    curve: Curves.easeOut);
                              },
                              icon:
                                  const Icon(Icons.keyboard_arrow_down_rounded),
                            ),
                          ],
                        ),
                      ),
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
            ),
          )),
    );
  }
}

class BookPaper extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder builder;
  final ValueChanged<int>? onPageChanged;

  const BookPaper(
      {super.key,
      required this.itemCount,
      required this.builder,
      this.onPageChanged});

  @override
  _BookPaperState createState() => _BookPaperState();
}

class _BookPaperState extends State<BookPaper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSwipeLeft() {
    if (_currentPage < widget.itemCount - 1) {
      setState(() {
        _currentPage++;
        _controller.reset();
        _controller.forward();
      });
      widget.onPageChanged?.call(_currentPage);
    }
  }

  void _onSwipeRight() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _controller.reset();
        _controller.forward();
      });
      widget.onPageChanged?.call(_currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          _onSwipeRight();
        } else if (details.primaryVelocity! < 0) {
          _onSwipeLeft();
        }
      },
      child: Container(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(3.14 * _animation.value),
                  origin: Offset(_animation.value < 0.5 ? 0 : 1, 0.5),
                  child: _buildPage(_currentPage),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity:
                      _animation.value < 0.5 ? 0 : (_animation.value - 0.5) * 2,
                  child: Transform(
                    transform: Matrix4.identity()..rotateY(3.14),
                    alignment: Alignment.centerRight,
                    child: _buildPage(_currentPage + 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    if (index >= 0 && index < widget.itemCount) {
      return widget.builder(context, index);
    }
    return Container();
  }
}

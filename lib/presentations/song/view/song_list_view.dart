import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../data/data.dart';
import '../../../domain/entity/song/song_entity.dart';
import '../../presentations.dart';

@RoutePage()
class SongListView extends StatefulWidget {
  final Function() onBack;
  final List<SongBook> Function() books;
  final SongBook Function() currentBook;
  final Function(String pageNumber) onTapPageNumber;
  final Function(Song song) onOpenSong;
  final Function(String bookCode) onChangeBookCode;

  final String initialSearchText;
  final Function(String text) onSearchTermsChanged;

  const SongListView({
    super.key,
    required this.books,
    required this.currentBook,
    required this.onTapPageNumber,
    required this.onChangeBookCode,
    required this.onOpenSong,
    required this.initialSearchText,
    required this.onSearchTermsChanged,
    required this.onBack,
  });

  @override
  State<SongListView> createState() => _SongListViewState();
}

class _SongListViewState extends State<SongListView>
    with SingleTickerProviderStateMixin {
  late final TextEditingController searchController = TextEditingController(
    text: widget.initialSearchText,
  )..addListener(searchListener);
  late final TabController tabController = TabController(length: 2, vsync: this)
    ..addListener(tabListener);
  @override
  void dispose() {
    searchController.dispose();
    tabController.dispose();
    super.dispose();
  }

  void searchListener() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  void tabListener() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  List<Song> getFilteredItems(List<Song> data) {
    var value = searchController.text;
    List<Song> result = [];
    bool isMatch(String text, String query) {
      // Normalize the text and the query by converting them to lower case
      var normalizedText = text.toLowerCase();
      var normalizedQuery = query.toLowerCase();

      // Split the query into words
      var queryWords = normalizedQuery.split(RegExp(r'\s+'));

      int lastIndex = 0; // Start from the beginning of the text
      for (var qWord in queryWords) {
        // Find the position of the query word in the text, starting from lastIndex
        int wordPos = normalizedText.indexOf(qWord, lastIndex);

        // If the word is not found, or is found before lastIndex, return false
        if (wordPos == -1) {
          return false;
        }

        // Update lastIndex to the position after the found word
        lastIndex = wordPos + qWord.length;
      }

      // All words are found in order with possible other words in between
      return true;
    }

    if (value.isNotEmpty) {
      result = List.from(
        data.where((element) {
          var title = element.title?.toLowerCase() ?? '';
          var lyric = element.verses.join().toLowerCase();
          var search = value.toLowerCase();

          bool containNumber =
              element.number != null &&
              isMatch(element.number.toString().toLowerCase(), search);
          bool containTitle = isMatch(title, search);
          bool containLyric = isMatch(lyric, search);

          return containNumber || containTitle || containLyric;
        }),
      );
    } else {
      result = List.from(data);
    }

    return result;
  }

  int forceRefresh = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(color: context.colorScheme.outlineVariant),
        ),
        leadingWidth: 56,
        titleSpacing: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        centerTitle: true,
        actions: [
          if (tabController.index == 1) ...[
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => _showCreatePlaylistDialog(context),
              icon: const Icon(Icons.playlist_add_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ],
        title: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SongListTabButton(
                selected: tabController.index == 0,
                label: 'Lists'.tr(),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(100),
                ),
                onPressed: () => tabController.animateTo(0),
              ),
              _SongListTabButton(
                selected: tabController.index == 1,
                label: 'Playlist',
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(100),
                ),
                onPressed: () => tabController.animateTo(1),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          Container(
            color: context.colorScheme.surface,
            child: Column(
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Stack(
                    children: [
                      TextFormField(
                        controller: searchController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: context.colorScheme.surfaceContainerLowest,
                          isDense: true,
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: context.colorScheme.primary,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ).add(const EdgeInsets.only(right: 100 + 48)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: context.colorScheme.outlineVariant,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: context.colorScheme.outlineVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: context.colorScheme.primary,
                              width: 1.2,
                            ),
                          ),
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
                                const Duration(milliseconds: 100),
                              );
                              setState(() {
                                forceRefresh++;
                              });
                            },
                            initialValue: widget.currentBook().code,
                            itemBuilder: (context) {
                              return widget
                                  .books()
                                  .map(
                                    (e) => PopupMenuItem(
                                      value: e.code,
                                      child: Text(e.code ?? ''),
                                    ),
                                  )
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
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.horizontal(
                                      right: Radius.circular(13),
                                    ),
                                    color:
                                        context.colorScheme.secondaryContainer,
                                    border: Border.all(
                                      color: context.colorScheme.secondary,
                                    ),
                                  ),
                                  child: Text(
                                    widget.currentBook().code ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: context
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                BlocBuilder<SongCubit, SongState>(
                  buildWhen: (prev, cur) =>
                      prev.histories != cur.histories ||
                      prev.songBook != cur.songBook,
                  builder: (context, state) {
                    final last = state.lastOpenedSong;
                    if (last == null || searchController.text.isNotEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Material(
                      color: context.colorScheme.secondaryContainer
                          .withValues(alpha: 0.45),
                      child: InkWell(
                        onTap: () => widget.onOpenSong(last),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: 18,
                                color: context.colorScheme.secondary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Terakhir dibuka',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: context
                                                .colorScheme.onSecondaryContainer
                                                .withValues(alpha: 0.7),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      '${last.number ?? ''} — ${last.title ?? ''}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: context.colorScheme
                                                .onSecondaryContainer,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.tonal(
                                style: FilledButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => widget.onOpenSong(last),
                                child: const Text('Buka'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: getFilteredItems(
                      widget.currentBook().songs,
                    ).length,
                    itemBuilder: (context, index) {
                      var item = getFilteredItems(
                        widget.currentBook().songs,
                      )[index];
                      return Column(
                        children: [
                          Material(
                            color: context.colorScheme.surfaceContainerLowest,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 2,
                              ),
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                widget.onSearchTermsChanged(
                                  searchController.text,
                                );
                                widget.onTapPageNumber(item.number!);
                              },
                              leading: SizedBox(
                                width: 36,
                                child: Text(
                                  item.number ?? '',
                                  style: TextStyle(
                                    fontFamily: 'EB Garamond',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: context.colorScheme.primary,
                                  ),
                                ),
                              ),
                              trailing: SizedBox(
                                width: 48,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      tooltip: 'Tambah ke playlist',
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        context
                                            .read<SongCubit>()
                                            .addSongToActivePlaylist(item);
                                        Fluttertoast.showToast(
                                          msg: 'Ditambahkan ke playlist',
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.playlist_add_rounded,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              title: Text(
                                (item.title ?? '').capitalizeEachWord(),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 72, right: 20),
                            child: Divider(
                              height: 1,
                              color: context.colorScheme.outlineVariant
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          _PlaylistTab(
            books: widget.books,
            onOpenSong: (song) {
              widget.onSearchTermsChanged(searchController.text);
              FocusManager.instance.primaryFocus?.unfocus();
              widget.onOpenSong(song);
            },
            onCreatePlaylist: () => _showCreatePlaylistDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    final cubit = context.read<SongCubit>();
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama playlist'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Buat'),
          ),
        ],
      ),
    );
    if (!mounted || name == null) return;
    cubit.createPlaylist(name);
  }
}

class _SongListTabButton extends StatelessWidget {
  final bool selected;
  final String label;
  final BorderRadius borderRadius;
  final VoidCallback onPressed;

  const _SongListTabButton({
    required this.selected,
    required this.label,
    required this.borderRadius,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        fixedSize: const Size(90, 34),
        backgroundColor: selected
            ? context.colorScheme.secondaryContainer
            : Colors.transparent,
        side: BorderSide(
          strokeAlign: BorderSide.strokeAlignCenter,
          width: 1,
          color: selected
              ? context.colorScheme.secondary
              : context.colorScheme.outlineVariant,
        ),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        foregroundColor: selected
            ? context.colorScheme.primary
            : context.colorScheme.onSurfaceVariant,
        padding: EdgeInsets.zero,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PlaylistTab extends StatelessWidget {
  final List<SongBook> Function() books;
  final ValueChanged<Song> onOpenSong;
  final VoidCallback onCreatePlaylist;

  const _PlaylistTab({
    required this.books,
    required this.onOpenSong,
    required this.onCreatePlaylist,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongCubit, SongState>(
      builder: (context, state) {
        final cubit = context.read<SongCubit>();
        if (state.playlists.isEmpty) {
          return NoDataFound(
            title: 'Belum ada playlist',
            description: 'Buat playlist lalu tambahkan lagu dari tab Lists.',
            action: FilledButton.icon(
              onPressed: onCreatePlaylist,
              icon: const Icon(Icons.playlist_add_rounded),
              label: const Text('Buat Playlist'),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _AutoNextModeSelector(
              selectedMode: state.playlistAutoNextMode,
              onSelected: cubit.setPlaylistAutoNextMode,
            ),
            const SizedBox(height: 12),
            ...state.playlists.map(
              (playlist) => _PlaylistCard(
                playlist: playlist,
                active:
                    state.isPlaylistLoopModeActive &&
                    playlist.id == state.activePlaylistId,
                books: books,
                onActivate: () => cubit.setActivePlaylist(playlist.id),
                onDelete: () => cubit.deletePlaylist(playlist.id),
                onRemoveSong: (index) =>
                    cubit.removeSongFromPlaylist(playlist.id, index),
                onOpenSong: onOpenSong,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AutoNextModeSelector extends StatelessWidget {
  final String selectedMode;
  final ValueChanged<String> onSelected;

  const _AutoNextModeSelector({
    required this.selectedMode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const options = {
      SongPlaylistAutoNextMode.off: 'Mati',
      SongPlaylistAutoNextMode.one: '1 Lagu',
      SongPlaylistAutoNextMode.number: 'Nomor',
      SongPlaylistAutoNextMode.playlist: 'Playlist',
      SongPlaylistAutoNextMode.shuffleAll: 'Shuffle',
      SongPlaylistAutoNextMode.shufflePlaylist: 'Shuffle PL',
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries
          .map(
            (entry) => ChoiceChip(
              label: Text(entry.value),
              selected: selectedMode == entry.key,
              onSelected: (_) => onSelected(entry.key),
            ),
          )
          .toList(),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final SongPlaylist playlist;
  final bool active;
  final List<SongBook> Function() books;
  final VoidCallback onActivate;
  final VoidCallback onDelete;
  final ValueChanged<int> onRemoveSong;
  final ValueChanged<Song> onOpenSong;

  const _PlaylistCard({
    required this.playlist,
    required this.active,
    required this.books,
    required this.onActivate,
    required this.onDelete,
    required this.onRemoveSong,
    required this.onOpenSong,
  });

  @override
  Widget build(BuildContext context) {
    final songs = playlist.songs
        .map((item) => _resolveSong(item, books()))
        .whereType<Song>()
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              active ? Icons.playlist_play_rounded : Icons.queue_music_rounded,
              color: active ? context.colorScheme.primary : null,
            ),
            title: Text(playlist.name),
            subtitle: Text('${songs.length} lagu${active ? ' • Aktif' : ''}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'active') onActivate();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'active',
                  child: Text('Jadikan aktif'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Hapus playlist'),
                ),
              ],
            ),
          ),
          if (songs.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Playlist kosong'),
              ),
            )
          else
            ...songs.indexed.map((entry) {
              final index = entry.$1;
              final song = entry.$2;
              return Column(
                children: [
                  const Divider(height: 1),
                  ListTile(
                    dense: true,
                    leading: Text(song.number ?? ''),
                    title: Text(song.title ?? ''),
                    onTap: () {
                      onActivate();
                      onOpenSong(song);
                    },
                    trailing: IconButton(
                      tooltip: 'Hapus dari playlist',
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => onRemoveSong(index),
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Song? _resolveSong(SongPlaylistItem item, List<SongBook> books) {
    for (final book in books) {
      for (final song in book.songs) {
        if (item.matches(song)) return song;
      }
    }
    return null;
  }
}

extension StringLowerSpace on String {
  String get toLowerNoSpace {
    return toLowerCase().replaceAll(' ', '');
  }
}

class PageTurnWidget extends StatefulWidget {
  const PageTurnWidget({
    super.key,
    required this.amount,
    this.backgroundColor = const Color(0xFFFFFFCC),
    required this.child,
  });

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
    final boundary =
        _boundaryKey.currentContext?.findRenderObject()
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
                child: RepaintBoundary(key: _boundaryKey, child: widget.child),
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
    final shadowSigma = Shadow.convertRadiusToSigma(
      8.0 + (32.0 * (1.0 - shadowXf)),
    );
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
      final v =
          (calcR * (math.sin(math.pi / 0.5 * (xf - (1.0 - pos)))) +
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

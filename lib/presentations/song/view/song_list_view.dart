import '../../../components/components.dart';
import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../data/data.dart';
import '../../../domain/entity/song/song_entity.dart';
import '../../presentations.dart';

const double _songListMaxContentWidth = 1080;
const double _songPlaylistMaxContentWidth = 980;

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

  Timer? _debounce;
  List<Song>? _filteredCache;
  String? _lastFilterQuery;

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    tabController.dispose();
    super.dispose();
  }

  /// Memoized filter so keyboard-triggered resizes do not re-scan the whole
  /// song list on every frame while the query is unchanged.
  List<Song> _getFiltered(List<Song> data) {
    final query = searchController.text;
    if (_filteredCache != null && _lastFilterQuery == query) {
      return _filteredCache!;
    }
    _filteredCache = getFilteredItems(data);
    _lastFilterQuery = query;
    return _filteredCache!;
  }

  void searchListener() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      setState(() {});
    });
  }

  void tabListener() {
    setState(() {});
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
          var lyric = element.verses.isNotEmpty
              ? element.verses.first.toLowerCase()
              : '';
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
    final colors = context.colorScheme;
    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colors.surfaceContainerLowest,
        shape: Border(
          bottom: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.68),
          ),
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
            // Single-button shuffle toggle.  The 6-chip mode selector
            // used to live at the top of the playlist list; replacing
            // it with a single header button keeps the initial view
            // compact while still exposing the most common action.
            // Other auto-next modes (one / number / playlist) remain
            // reachable via the floating MIDI controls' cycle button.
            BlocSelector<SongCubit, SongState, _ShuffleToggleView>(
              selector: (state) {
                final mode = state.playlistAutoNextMode;
                final on =
                    mode == SongPlaylistAutoNextMode.shuffleAll ||
                    mode == SongPlaylistAutoNextMode.shufflePlaylist;
                return _ShuffleToggleView(
                  isOn: on,
                  isPlaylist: mode == SongPlaylistAutoNextMode.shufflePlaylist,
                );
              },
              builder: (context, view) {
                return IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: view.isOn
                      ? (view.isPlaylist
                            ? 'Shuffle playlist — matikan'
                            : 'Shuffle all — matikan')
                      : 'Aktifkan shuffle',
                  onPressed: () => context.read<SongCubit>().toggleShuffle(),
                  icon: Icon(
                    Icons.shuffle_rounded,
                    color: view.isOn ? context.colorScheme.primary : null,
                  ),
                );
              },
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => _showCreatePlaylistDialog(context),
              icon: const Icon(Icons.playlist_add_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ],
        title: Row(
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
      body: TabBarView(
        controller: tabController,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.surfaceContainerLowest, colors.surface],
              ),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: _songListMaxContentWidth,
                ),
                child: Column(
                  children: [
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 460;
                          return Row(
                            children: [
                              // Search field — modern rounded field with an
                              // in-field clear button; the book selector is a
                              // separate pill next to it (no more tag crammed
                              // inside the field).
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: colors.surfaceContainerLow,
                                    isDense: true,
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      color: colors.primary,
                                    ),
                                    suffixIcon: AnimatedBuilder(
                                      animation: searchController,
                                      builder: (context, child) =>
                                          searchController.text.isEmpty
                                          ? const SizedBox.shrink()
                                          : IconButton(
                                              tooltip: 'Clear',
                                              visualDensity:
                                                  VisualDensity.compact,
                                              icon: const Icon(
                                                Icons.cancel_rounded,
                                                size: 18,
                                              ),
                                              onPressed: () =>
                                                  searchController.clear(),
                                            ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 12,
                                    ),
                                    hintText: 'Search number or keyword'.tr(),
                                    hintStyle: TextStyle(
                                      color: colors.onSurfaceVariant
                                          .withValues(alpha: 0.65),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: context.appRadius(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: context.appRadius(16),
                                      borderSide: BorderSide(
                                        color: colors.outlineVariant
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: context.appRadius(16),
                                      borderSide: BorderSide(
                                        color: colors.primary,
                                        width: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                offset: const Offset(0, 48),
                                onSelected: (value) async {
                                  await widget.onChangeBookCode(value);
                                  _filteredCache = null;
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
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(e.code ?? ''),
                                              ),
                                              if (e.code ==
                                                  widget.currentBook().code)
                                                Icon(
                                                  Icons.check_rounded,
                                                  size: 16,
                                                  color: colors.primary,
                                                ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList();
                                },
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: context.appRadius(16),
                                    color: colors.primaryContainer.withValues(
                                      alpha: 0.35,
                                    ),
                                    border: Border.all(
                                      color: colors.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        widget.currentBook().code ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: compact ? 12 : 13,
                                          color: colors.onPrimaryContainer,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 18,
                                        color: colors.onPrimaryContainer,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
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
                        final textColor = colors.onSecondaryContainer;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: context.appRadius(16),
                              onTap: () => widget.onOpenSong(last),
                              child: Ink(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: context.appRadius(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      colors.secondaryContainer.withValues(
                                        alpha: 0.75,
                                      ),
                                      colors.secondaryContainer.withValues(
                                        alpha: 0.22,
                                      ),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: colors.outlineVariant.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.shadow.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Play avatar — instantly signals the
                                    // "resume listening" action.
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            colors.primary,
                                            colors.primary.withValues(
                                              alpha: 0.75,
                                            ),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colors.primary.withValues(
                                              alpha: 0.35,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.history_rounded,
                                                size: 13,
                                                color: textColor.withValues(
                                                  alpha: 0.7,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Terakhir dibuka',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: textColor
                                                          .withValues(
                                                            alpha: 0.8,
                                                          ),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 0.6,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${last.number ?? ''} \u2014 ${last.title ?? ''}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  color: textColor,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: textColor.withValues(alpha: 0.6),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final filteredItems = _getFiltered(
                            widget.currentBook().songs,
                          );
                          if (filteredItems.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 48,
                                      color: context
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'no_songs_found'.tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: context
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final cardWidth = constraints.maxWidth < 560
                                  ? 170.0
                                  : 200.0;
                              final columns = (constraints.maxWidth / cardWidth)
                                  .floor()
                                  .clamp(1, 8);
                              return GridView.builder(
                                // ignore: deprecated_member_use
                                cacheExtent: 300,
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  10,
                                  14,
                                  24,
                                ),
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                      childAspectRatio:
                                          constraints.maxWidth < 560
                                          ? 1.05
                                          : 1.55,
                                    ),
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  var item = filteredItems[index];
                                  final colors = context.colorScheme;
                                  return RepaintBoundary(
                                    child: Material(
                                      color: colors.surfaceContainerLow,
                                      borderRadius: context.appRadius(14),
                                      clipBehavior: Clip.antiAlias,
                                      child: InkWell(
                                        onTap: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          widget.onSearchTermsChanged(
                                            searchController.text,
                                          );
                                          final number = item.number;
                                          if (number == null) return;
                                          widget.onTapPageNumber(number);
                                        },
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 4,
                                              right: 2,
                                              child: IconButton(
                                                tooltip: 'Tambah ke playlist',
                                                visualDensity:
                                                    VisualDensity.compact,
                                                padding: EdgeInsets.zero,
                                                onPressed: () {
                                                  context
                                                      .read<SongCubit>()
                                                      .addSongToActivePlaylist(
                                                        item,
                                                      );
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        'Ditambahkan ke playlist',
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.playlist_add_rounded,
                                                  size: 20,
                                                  color: colors.onSurfaceVariant
                                                      .withValues(alpha: 0.8),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                    12,
                                                    10,
                                                    10,
                                                    8,
                                                  ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    item.number ?? '',
                                                    style: TextStyle(
                                                      fontFamily: DesignSystem
                                                          .fontHeading,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: context
                                                          .appFontSize(20),
                                                      color: colors.primary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    (item.title ?? '')
                                                        .capitalizeEachWord(),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          height: 1.25,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
        title: Text('playlist_create_title'.tr()),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama playlist'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text('Buat'.tr()),
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
    final compact = MediaQuery.sizeOf(context).width < 430;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(compact ? 72 : 84, 32),
        backgroundColor: selected
            ? context.colorScheme.primaryContainer.withValues(alpha: 0.4)
            : context.colorScheme.surfaceContainerLow,
        side: BorderSide(
          width: 1,
          color: selected
              ? context.colorScheme.primary
              : context.colorScheme.outlineVariant,
        ),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        foregroundColor: selected
            ? context.colorScheme.primary
            : context.colorScheme.onSurfaceVariant,
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: DesignSystem.fontUI,
          fontWeight: FontWeight.w700,
          fontSize: context.appFontSize(12),
        ),
      ),
    );
  }
}

class _PlaylistTab extends StatefulWidget {
  final List<SongBook> Function() books;
  final ValueChanged<Song> onOpenSong;
  final VoidCallback onCreatePlaylist;

  const _PlaylistTab({
    required this.books,
    required this.onOpenSong,
    required this.onCreatePlaylist,
  });

  @override
  State<_PlaylistTab> createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<_PlaylistTab> {
  // Memoized song→map lookup. Playlist mutations (rename / reorder / remove)
  // rebuild the list without re-scanning every song in the book. The cache
  // is keyed on the book-list content (identity + each book's song identity)
  // so in-place song data updates (e.g. a lyrics refresh) also invalidate it.
  Map<String, Song>? _songMapCache;
  List<Object?>? _songMapKey;

  Map<String, Song> _songMap() {
    final books = widget.books();
    final key = <Object?>[
      for (final book in books) book.code,
      for (final book in books) book.songs,
    ];
    if (_songMapCache != null && _listEquals(_songMapKey, key)) {
      return _songMapCache!;
    }
    final songMap = <String, Song>{};
    for (final book in books) {
      for (final song in book.songs) {
        songMap['${book.code}:${song.number}'] = song;
      }
    }
    _songMapCache = songMap;
    _songMapKey = key;
    return songMap;
  }

  static bool _listEquals(List<Object?>? a, List<Object?>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!identical(a[i], b[i])) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongCubit, SongState>(
      buildWhen: (prev, curr) =>
          prev.playlists != curr.playlists ||
          prev.playlistAutoNextMode != curr.playlistAutoNextMode ||
          prev.isPlaylistLoopModeActive != curr.isPlaylistLoopModeActive ||
          prev.activePlaylistId != curr.activePlaylistId ||
          prev.songBook != curr.songBook,
      builder: (context, state) {
        final cubit = context.read<SongCubit>();
        final songMap = _songMap();
        if (state.playlists.isEmpty) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _songPlaylistMaxContentWidth,
              ),
              child: NoDataFound(
                title: 'Belum ada playlist',
                description:
                    'Buat playlist lalu tambahkan lagu dari tab Lists.',
                action: FilledButton.icon(
                  onPressed: widget.onCreatePlaylist,
                  icon: const Icon(Icons.playlist_add_rounded),
                  label: const Text('Buat Playlist'),
                ),
              ),
            ),
          );
        }

        Widget frame(Widget child) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: _songPlaylistMaxContentWidth,
            ),
            child: child,
          ),
        );

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: state.playlists.length,
          itemBuilder: (context, index) {
            final playlist = state.playlists[index];
            return frame(
              RepaintBoundary(
                child: _PlaylistCard(
                  playlist: playlist,
                  active:
                      state.isPlaylistLoopModeActive &&
                      playlist.id == state.activePlaylistId,
                  songMap: songMap,
                  onActivate: () => cubit.setActivePlaylist(playlist.id),
                  onDelete: () => cubit.deletePlaylist(playlist.id),
                  onRemoveSong: (index) =>
                      cubit.removeSongFromPlaylist(playlist.id, index),
                  onOpenSong: widget.onOpenSong,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Lightweight value type for the AppBar shuffle toggle so the
/// BlocSelector can rebuild the button only when the relevant
/// fields of the cubit state change.
class _ShuffleToggleView {
  const _ShuffleToggleView({required this.isOn, required this.isPlaylist});
  final bool isOn;
  final bool isPlaylist;

  @override
  bool operator ==(Object other) =>
      other is _ShuffleToggleView &&
      other.isOn == isOn &&
      other.isPlaylist == isPlaylist;

  @override
  int get hashCode => Object.hash(isOn, isPlaylist);
}

class _PlaylistCard extends StatefulWidget {
  final SongPlaylist playlist;
  final bool active;
  final Map<String, Song> songMap;
  final VoidCallback onActivate;
  final VoidCallback onDelete;
  final ValueChanged<int> onRemoveSong;
  final ValueChanged<Song> onOpenSong;

  const _PlaylistCard({
    required this.playlist,
    required this.active,
    required this.songMap,
    required this.onActivate,
    required this.onDelete,
    required this.onRemoveSong,
    required this.onOpenSong,
  });

  @override
  State<_PlaylistCard> createState() => _PlaylistCardState();
}

class _PlaylistCardState extends State<_PlaylistCard> {
  // Collapsed by default so the playlist tab renders compactly on
  // first paint.  The user can tap the card header (or the chevron)
  // to expand and see the song list.
  bool _expanded = false;

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final songs = widget.playlist.songs
        .map((item) => widget.songMap['${item.code}:${item.number}'])
        .whereType<Song>()
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: context.appRadius(12),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              widget.active
                  ? Icons.playlist_play_rounded
                  : Icons.queue_music_rounded,
              color: widget.active ? context.colorScheme.primary : null,
            ),
            title: Text(widget.playlist.name),
            subtitle: Text(
              '${songs.length} lagu${widget.active ? ' • Aktif' : ''}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: _expanded ? 'Ciutkan' : 'Bentangkan',
                  onPressed: _toggleExpanded,
                  icon: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more_rounded),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'active') widget.onActivate();
                    if (value == 'delete') widget.onDelete();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'active',
                      child: Text('Jadikan aktif'.tr()),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Hapus playlist'.tr()),
                    ),
                  ],
                ),
              ],
            ),
            onTap: _toggleExpanded,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: _expanded
                ? (songs.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Playlist kosong'.tr()),
                          ),
                        )
                      : Column(
                          children: songs.indexed.map((entry) {
                            final index = entry.$1;
                            final song = entry.$2;
                            return Column(
                              children: [
                                const Divider(height: 1),
                                ListTile(
                                  dense: true,
                                  leading: SizedBox(
                                    width: 36,
                                    child: Text(
                                      song.number ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: DesignSystem.fontHeading,
                                        fontWeight: FontWeight.w700,
                                        fontSize: context.appFontSize(16),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    song.title ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () {
                                    widget.onActivate();
                                    widget.onOpenSong(song);
                                  },
                                  trailing: IconButton(
                                    tooltip: 'Hapus dari playlist',
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    onPressed: () => widget.onRemoveSong(index),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ))
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

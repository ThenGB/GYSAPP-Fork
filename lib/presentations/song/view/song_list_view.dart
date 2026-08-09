import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../components/components.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../domain/entity/song/song_entity.dart';
import '../../presentations.dart';

const double _songListMaxContentWidth = 1120;
const double _songPlaylistMaxContentWidth = 980;

enum _SongBrowseLayout { list, grid }

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
  late final TextEditingController _searchController = TextEditingController(
    text: widget.initialSearchText,
  )..addListener(_onSearchChanged);
  late final TabController _tabController = TabController(length: 2, vsync: this)
    ..addListener(_onTabChanged);

  Timer? _searchDebounce;
  _SongBrowseLayout _layout = _SongBrowseLayout.grid;
  List<Song>? _cachedFilteredSongs;
  List<Song>? _cachedSource;
  String _cachedQuery = '';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() {
        _cachedFilteredSongs = null;
      });
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging && mounted) setState(() {});
  }

  List<Song> _filteredSongs(List<Song> source) {
    final query = _searchController.text.trim().toLowerCase();
    if (_cachedFilteredSongs != null &&
        identical(_cachedSource, source) &&
        _cachedQuery == query) {
      return _cachedFilteredSongs!;
    }

    bool orderedMatch(String value) {
      if (query.isEmpty) return true;
      final normalized = value.toLowerCase();
      var cursor = 0;
      for (final token in query.split(RegExp(r'\s+')).where((e) => e.isNotEmpty)) {
        final index = normalized.indexOf(token, cursor);
        if (index < 0) return false;
        cursor = index + token.length;
      }
      return true;
    }

    final filtered = query.isEmpty
        ? List<Song>.unmodifiable(source)
        : source.where((song) {
            final lyric = song.verses.isEmpty ? '' : song.verses.first;
            return orderedMatch(song.number ?? '') ||
                orderedMatch(song.title ?? '') ||
                orderedMatch(lyric);
          }).toList(growable: false);

    _cachedSource = source;
    _cachedQuery = query;
    _cachedFilteredSongs = filtered;
    return filtered;
  }

  void _openSong(Song song) {
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onSearchTermsChanged(_searchController.text);
    final number = song.number;
    if (number != null) widget.onTapPageNumber(number);
  }

  Future<void> _changeBook(String bookCode) async {
    await widget.onChangeBookCode(bookCode);
    _cachedFilteredSongs = null;
    _cachedSource = null;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: _TopTabs(
          selectedIndex: _tabController.index,
          onSelected: _tabController.animateTo,
        ),
        actions: [
          if (_tabController.index == 1)
            BlocSelector<SongCubit, SongState, bool>(
              selector: (state) =>
                  state.playlistAutoNextMode == SongPlaylistAutoNextMode.shuffleAll ||
                  state.playlistAutoNextMode ==
                      SongPlaylistAutoNextMode.shufflePlaylist,
              builder: (context, active) => IconButton(
                tooltip: active ? 'Matikan shuffle' : 'Aktifkan shuffle',
                onPressed: context.read<SongCubit>().toggleShuffle,
                icon: Icon(
                  Icons.shuffle_rounded,
                  color: active ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ),
          if (_tabController.index == 1)
            IconButton(
              tooltip: 'Buat playlist',
              onPressed: () => _showCreatePlaylistDialog(context),
              icon: const Icon(Icons.playlist_add_rounded),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBrowseTab(context),
          _PlaylistTab(
            books: widget.books,
            onOpenSong: (song) {
              widget.onSearchTermsChanged(_searchController.text);
              FocusManager.instance.primaryFocus?.unfocus();
              widget.onOpenSong(song);
            },
            onCreatePlaylist: () => _showCreatePlaylistDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseTab(BuildContext context) {
    final colors = context.colorScheme;
    final book = widget.currentBook();
    final songs = _filteredSongs(book.songs);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.surface, colors.surfaceContainerLowest],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _songListMaxContentWidth),
            child: Column(
              children: [
                _SelectorToolbar(
                  searchController: _searchController,
                  currentBook: book,
                  books: widget.books(),
                  layout: _layout,
                  onLayoutChanged: (layout) => setState(() => _layout = layout),
                  onBookChanged: _changeBook,
                ),
                BlocBuilder<SongCubit, SongState>(
                  buildWhen: (previous, current) =>
                      previous.histories != current.histories ||
                      previous.songBook != current.songBook,
                  builder: (context, state) {
                    final last = state.lastOpenedSong;
                    if (last == null || _searchController.text.isNotEmpty) {
                      return const SizedBox.shrink();
                    }
                    return _ResumeSongCard(
                      song: last,
                      onTap: () => widget.onOpenSong(last),
                    );
                  },
                ),
                Expanded(
                  child: songs.isEmpty
                      ? _EmptySongResults(query: _searchController.text)
                      : AnimatedSwitcher(
                          duration: DesignSystem.animNormal,
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: _layout == _SongBrowseLayout.grid
                              ? _SongGrid(
                                  key: const ValueKey('song-grid'),
                                  songs: songs,
                                  onOpen: _openSong,
                                )
                              : _SongList(
                                  key: const ValueKey('song-list'),
                                  songs: songs,
                                  onOpen: _openSong,
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

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    final cubit = context.read<SongCubit>();
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Nama playlist',
            prefixIcon: Icon(Icons.queue_music_rounded),
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Buat'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || name == null || name.trim().isEmpty) return;
    cubit.createPlaylist(name);
  }
}

class _TopTabs extends StatelessWidget {
  const _TopTabs({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(
          value: 0,
          icon: Icon(Icons.library_music_rounded, size: 17),
          label: Text('Pujian'),
        ),
        ButtonSegment(
          value: 1,
          icon: Icon(Icons.queue_music_rounded, size: 17),
          label: Text('Playlist'),
        ),
      ],
      selected: {selectedIndex},
      onSelectionChanged: (selection) => onSelected(selection.first),
      showSelectedIcon: false,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _SelectorToolbar extends StatelessWidget {
  const _SelectorToolbar({
    required this.searchController,
    required this.currentBook,
    required this.books,
    required this.layout,
    required this.onLayoutChanged,
    required this.onBookChanged,
  });

  final TextEditingController searchController;
  final SongBook currentBook;
  final List<SongBook> books;
  final _SongBrowseLayout layout;
  final ValueChanged<_SongBrowseLayout> onLayoutChanged;
  final ValueChanged<String> onBookChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Cari nomor, judul, atau lirik',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: AnimatedBuilder(
                      animation: searchController,
                      builder: (context, _) => searchController.text.isEmpty
                          ? const SizedBox.shrink()
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              onPressed: searchController.clear,
                              icon: const Icon(Icons.close_rounded, size: 19),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _BookPicker(
                currentBook: currentBook,
                books: books,
                onSelected: onBookChanged,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentBook.code ?? 'Pujian',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${currentBook.songs.length} pujian',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SegmentedButton<_SongBrowseLayout>(
                segments: const [
                  ButtonSegment(
                    value: _SongBrowseLayout.list,
                    icon: Icon(Icons.view_agenda_outlined, size: 18),
                    tooltip: 'Daftar',
                  ),
                  ButtonSegment(
                    value: _SongBrowseLayout.grid,
                    icon: Icon(Icons.grid_view_rounded, size: 18),
                    tooltip: 'Kotak',
                  ),
                ],
                selected: {layout},
                onSelectionChanged: (selection) =>
                    onLayoutChanged(selection.first),
                showSelectedIcon: false,
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookPicker extends StatelessWidget {
  const _BookPicker({
    required this.currentBook,
    required this.books,
    required this.onSelected,
  });

  final SongBook currentBook;
  final List<SongBook> books;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return PopupMenuButton<String>(
      tooltip: 'Pilih buku pujian',
      initialValue: currentBook.code,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final book in books)
          PopupMenuItem(
            value: book.code,
            child: Row(
              children: [
                Expanded(child: Text(book.code ?? '')),
                if (book.code == currentBook.code)
                  Icon(Icons.check_rounded, color: colors.primary, size: 18),
              ],
            ),
          ),
      ],
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: colors.primaryContainer.withValues(alpha: 0.42),
          borderRadius: context.appRadius(16),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, size: 18, color: colors.primary),
            const SizedBox(width: 7),
            Text(
              currentBook.code ?? '',
              style: context.textTheme.labelLarge?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w800,
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
    );
  }
}

class _ResumeSongCard extends StatelessWidget {
  const _ResumeSongCard({required this.song, required this.onTap});

  final Song song;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Material(
        color: colors.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: context.appRadius(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: colors.onPrimary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LANJUTKAN',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colors.onSecondaryContainer,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${song.number ?? ''} · ${song.title ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSecondaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SongGrid extends StatelessWidget {
  const _SongGrid({super.key, required this.songs, required this.onOpen});

  final List<Song> songs;
  final ValueChanged<Song> onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final targetWidth = constraints.maxWidth < 500 ? 158.0 : 210.0;
        final columns = (constraints.maxWidth / targetWidth).floor().clamp(2, 5);
        return GridView.builder(
          scrollCacheExtent: const ScrollCacheExtent.pixels(420),
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: constraints.maxWidth < 500 ? 0.95 : 1.35,
          ),
          itemCount: songs.length,
          itemBuilder: (context, index) => RepaintBoundary(
            child: _SongGridCard(song: songs[index], onOpen: onOpen),
          ),
        );
      },
    );
  }
}

class _SongGridCard extends StatelessWidget {
  const _SongGridCard({required this.song, required this.onOpen});

  final Song song;
  final ValueChanged<Song> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final lyric = song.verses.isEmpty ? '' : song.verses.first.trim();
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: context.appRadius(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onOpen(song),
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.34),
            ),
            borderRadius: context.appRadius(18),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: context.appRadius(999),
                      ),
                      child: Text(
                        song.number ?? '—',
                        style: context.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _AddToPlaylistButton(song: song),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  song.title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.22,
                  ),
                ),
                if (lyric.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      lyric,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ] else
                  const Spacer(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      size: 15,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      song.code ?? 'Pujian',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 17,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SongList extends StatelessWidget {
  const _SongList({super.key, required this.songs, required this.onOpen});

  final List<Song> songs;
  final ValueChanged<Song> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollCacheExtent: const ScrollCacheExtent.pixels(500),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: songs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => RepaintBoundary(
        child: _SongListCard(song: songs[index], onOpen: onOpen),
      ),
    );
  }
}

class _SongListCard extends StatelessWidget {
  const _SongListCard({required this.song, required this.onOpen});

  final Song song;
  final ValueChanged<Song> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final lyric = song.verses.isEmpty ? '' : song.verses.first.trim();
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: context.appRadius(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onOpen(song),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.72),
                  borderRadius: context.appRadius(14),
                ),
                child: Text(
                  song.number ?? '—',
                  maxLines: 1,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (lyric.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        lyric,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _AddToPlaylistButton(song: song),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant.withValues(alpha: 0.72),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddToPlaylistButton extends StatelessWidget {
  const _AddToPlaylistButton({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Tambah ke playlist',
      onPressed: () {
        context.read<SongCubit>().addSongToActivePlaylist(song);
        Fluttertoast.showToast(msg: 'Ditambahkan ke playlist');
      },
      icon: const Icon(Icons.playlist_add_rounded, size: 20),
    );
  }
}

class _EmptySongResults extends StatelessWidget {
  const _EmptySongResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: colors.onSurfaceVariant,
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              query.trim().isEmpty ? 'Belum ada pujian' : 'Pujian tidak ditemukan',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              query.trim().isEmpty
                  ? 'Pilih buku pujian lain untuk melihat daftar.'
                  : 'Coba nomor, judul, atau kata dari lirik yang berbeda.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistTab extends StatelessWidget {
  const _PlaylistTab({
    required this.books,
    required this.onOpenSong,
    required this.onCreatePlaylist,
  });

  final List<SongBook> Function() books;
  final ValueChanged<Song> onOpenSong;
  final VoidCallback onCreatePlaylist;

  Map<String, Song> _songMap() {
    final map = <String, Song>{};
    for (final book in books()) {
      for (final song in book.songs) {
        map['${book.code}:${song.number}'] = song;
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongCubit, SongState>(
      buildWhen: (previous, current) =>
          previous.playlists != current.playlists ||
          previous.activePlaylistId != current.activePlaylistId ||
          previous.isPlaylistLoopModeActive != current.isPlaylistLoopModeActive ||
          previous.songBook != current.songBook,
      builder: (context, state) {
        final cubit = context.read<SongCubit>();
        if (state.playlists.isEmpty) {
          return _EmptyPlaylists(onCreatePlaylist: onCreatePlaylist);
        }
        final songMap = _songMap();
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _songPlaylistMaxContentWidth),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              itemCount: state.playlists.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final playlist = state.playlists[index];
                final active = playlist.id == state.activePlaylistId;
                return _PlaylistCard(
                  playlist: playlist,
                  active: active,
                  songMap: songMap,
                  onActivate: () => cubit.setActivePlaylist(playlist.id),
                  onDelete: () => cubit.deletePlaylist(playlist.id),
                  onRemoveSong: (songIndex) =>
                      cubit.removeSongFromPlaylist(playlist.id, songIndex),
                  onOpenSong: onOpenSong,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _EmptyPlaylists extends StatelessWidget {
  const _EmptyPlaylists({required this.onCreatePlaylist});

  final VoidCallback onCreatePlaylist;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.queue_music_rounded, size: 54, color: colors.primary),
            const SizedBox(height: 14),
            Text(
              'Belum ada playlist',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Buat playlist untuk menyiapkan urutan pujian yang ingin diputar.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onCreatePlaylist,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Buat Playlist'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({
    required this.playlist,
    required this.active,
    required this.songMap,
    required this.onActivate,
    required this.onDelete,
    required this.onRemoveSong,
    required this.onOpenSong,
  });

  final SongPlaylist playlist;
  final bool active;
  final Map<String, Song> songMap;
  final VoidCallback onActivate;
  final VoidCallback onDelete;
  final ValueChanged<int> onRemoveSong;
  final ValueChanged<Song> onOpenSong;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final songs = playlist.songs
        .map((item) => songMap['${item.code}:${item.number}'])
        .toList(growable: false);
    return Material(
      color: active
          ? colors.primaryContainer.withValues(alpha: 0.36)
          : colors.surfaceContainerLow,
      borderRadius: context.appRadius(18),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: active ? colors.primary : colors.surfaceContainerHighest,
            borderRadius: context.appRadius(13),
          ),
          child: Icon(
            active ? Icons.playlist_play_rounded : Icons.queue_music_rounded,
            color: active ? colors.onPrimary : colors.primary,
          ),
        ),
        title: Text(
          playlist.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '${playlist.songs.length} pujian${active ? ' · Aktif' : ''}',
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'Opsi playlist',
          onSelected: (value) {
            if (value == 'activate') onActivate();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            if (!active)
              const PopupMenuItem(
                value: 'activate',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.play_circle_outline_rounded),
                  title: Text('Jadikan aktif'),
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.delete_outline_rounded),
                title: Text('Hapus playlist'),
              ),
            ),
          ],
        ),
        children: [
          if (playlist.songs.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Text(
                'Belum ada pujian di playlist ini.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            )
          else
            for (var index = 0; index < playlist.songs.length; index++)
              _PlaylistSongRow(
                item: playlist.songs[index],
                resolvedSong: songs[index],
                onOpen: onOpenSong,
                onRemove: () => onRemoveSong(index),
              ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PlaylistSongRow extends StatelessWidget {
  const _PlaylistSongRow({
    required this.item,
    required this.resolvedSong,
    required this.onOpen,
    required this.onRemove,
  });

  final SongPlaylistItem item;
  final Song? resolvedSong;
  final ValueChanged<Song> onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: context.colorScheme.surfaceContainerHighest,
        child: Text(
          item.number,
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(item.code),
      enabled: resolvedSong != null,
      onTap: resolvedSong == null ? null : () => onOpen(resolvedSong!),
      trailing: IconButton(
        tooltip: 'Hapus dari playlist',
        onPressed: onRemove,
        icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
      ),
    );
  }
}

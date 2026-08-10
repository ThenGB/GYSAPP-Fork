import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/components.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../domain/domain.dart';
import '../../../router/router.dart';
import '../../bible/bible.dart';
import '../../dashboard/dashboard.dart';
import '../../song/song.dart';

/// Which content the global search opens with.
enum GlobalSearchSection { bible, song }

/// One search entry point for both the Bible and the hymnal.
///
/// A single search box drives either content; the segmented control switches
/// between Alkitab and Pujian without losing the query. Results open the
/// matching reader directly (Bible chapter / hymn page).
@RoutePage()
class GlobalSearchView extends StatefulWidget {
  const GlobalSearchView({super.key, this.initialSection = GlobalSearchSection.bible});

  final GlobalSearchSection initialSection;

  @override
  State<GlobalSearchView> createState() => _GlobalSearchViewState();
}

class _GlobalSearchViewState extends State<GlobalSearchView> {
  late final TextEditingController _searchController = TextEditingController();
  Timer? _bibleDebounce;
  Future<List<Verse>>? _bibleFuture;
  String _bibleQuery = '';
  GlobalSearchSection _section = GlobalSearchSection.bible;

  @override
  void initState() {
    super.initState();
    _section = widget.initialSection;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _bibleDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final text = _searchController.text;
    if (_section != GlobalSearchSection.bible) return;
    if (text == _bibleQuery) return;
    _bibleQuery = text;
    _bibleDebounce?.cancel();
    if (text.trim().isEmpty) {
      _bibleFuture = Future.value(<Verse>[]);
      if (mounted) setState(() {});
      return;
    }
    _bibleDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _bibleFuture = context.read<BibleCubit>().searchBibleByString(text);
      setState(() {});
    });
  }

  void _setSection(GlobalSearchSection section) {
    if (_section == section) return;
    setState(() => _section = section);
    if (section == GlobalSearchSection.bible) {
      _onSearchChanged();
    }
  }

  void _openVerse(Verse verse) {
    FocusManager.instance.primaryFocus?.unfocus();
    final cubit = context.read<BibleCubit>();
    router.maybePop();
    dashboardTabsRouter?.setActiveIndex(1);
    unawaited(cubit.getContent(verse));
  }

  void _openSong(Song song) {
    FocusManager.instance.primaryFocus?.unfocus();
    final cubit = context.read<SongCubit>();
    router.maybePop();
    dashboardTabsRouter?.setActiveIndex(2);
    unawaited(cubit.openSong(song));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        titleSpacing: 12,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Cari Alkitab atau pujian'.tr(),
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.close_rounded),
              onPressed: _searchController.clear,
            ),
            filled: true,
            fillColor: colors.surfaceContainerLow,
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: context.appRadius(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: SegmentedButton<GlobalSearchSection>(
              segments: const [
                ButtonSegment(
                  value: GlobalSearchSection.bible,
                  icon: Icon(Icons.menu_book_outlined),
                  label: Text('Alkitab'),
                ),
                ButtonSegment(
                  value: GlobalSearchSection.song,
                  icon: Icon(Icons.music_note_outlined),
                  label: Text('Pujian'),
                ),
              ],
              selected: {_section},
              onSelectionChanged: (selection) =>
                  _setSection(selection.first),
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: _section == GlobalSearchSection.bible
            ? _BibleSearchResults(
                key: const ValueKey('bible'),
                future: _bibleFuture,
                query: _bibleQuery,
                onTap: _openVerse,
              )
            : _SongSearchResults(
                key: const ValueKey('song'),
                query: _searchController.text,
                onTap: _openSong,
              ),
      ),
    );
  }
}

class _BibleSearchResults extends StatelessWidget {
  const _BibleSearchResults({
    super.key,
    required this.future,
    required this.query,
    required this.onTap,
  });

  final Future<List<Verse>>? future;
  final String query;
  final void Function(Verse) onTap;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BibleCubit>();
    return MediaQuery(
      data: context.mediaQuery.copyWith(
        textScaler: TextScaler.linear(cubit.state.defaultTextScale),
      ),
      child: FutureBuilder<List<Verse>>(
        future: future,
        builder: (context, snapshot) {
          final results = snapshot.data ?? const <Verse>[];
          if (!snapshot.hasData || results.isEmpty) {
            return NoDataFound(
              title: query.trim().isEmpty
                  ? 'Search terms to start'.tr()
                  : 'not found'.tr(args: ['"$query"']),
              description: 'Make sure your spellings is correct'.tr(),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final item = results[index];
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  onTap: () => onTap(item),
                  title: FutureBuilder<String>(
                    future: cubit.getBibleTitle([item], withVerse: true),
                    builder: (context, snapshot) => Text(
                      snapshot.data ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  subtitle: Text(
                    item.verse ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      height: 1.4,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SongSearchResults extends StatelessWidget {
  const _SongSearchResults({
    super.key,
    required this.query,
    required this.onTap,
  });

  final String query;
  final void Function(Song) onTap;

  bool _orderedMatch(String value, List<String> tokens) {
    if (tokens.isEmpty) return true;
    final normalized = value.toLowerCase();
    var cursor = 0;
    for (final token in tokens) {
      final index = normalized.indexOf(token, cursor);
      if (index < 0) return false;
      cursor = index + token.length;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SongCubit>();
    final state = cubit.state;
    final tokens = query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    final results = tokens.isEmpty
        ? const <Song>[]
        : state.songs.where((song) {
            final lyric = song.verses.isEmpty ? '' : song.verses.first;
            return _orderedMatch(song.number ?? '', tokens) ||
                _orderedMatch(song.title ?? '', tokens) ||
                _orderedMatch(lyric, tokens);
          }).toList(growable: false);

    if (results.isEmpty) {
      return NoDataFound(
        title: query.trim().isEmpty
            ? 'Search terms to start'.tr()
            : 'not found'.tr(args: ['"$query"']),
        description: 'Make sure your spellings is correct'.tr(),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final song = results[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLow,
            borderRadius: context.appRadius(8),
            border: Border.all(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            onTap: () => onTap(song),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer.withValues(
                  alpha: 0.66,
                ),
                borderRadius: context.appRadius(12),
              ),
              child: Icon(
                Icons.music_note_rounded,
                size: 20,
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(
              '${song.number ?? ''} ${song.title ?? ''}'.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              '${state.bookCode} • ${song.verses.isEmpty ? '' : song.verses.first}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(height: 1.35),
            ),
          ),
        );
      },
    );
  }
}

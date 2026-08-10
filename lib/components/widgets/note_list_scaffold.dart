import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/utilities/extensions/context_ext.dart';
import '../../data/utilities/extensions/datetime_ext.dart';
import '../themes/app_theme_extras.dart';
import 'no_data_found.dart';

/// Shared notes list used by the Bible, Faith, and Hymnal note systems.
///
/// All three legacy screens were structurally identical (search field, sort
/// menu, filtered list with quill previews); only the cubit, the note type,
/// and the title resolver differed. This widget removes that duplication —
/// the storage models stay untouched.
class NoteListScaffold<C extends StateStreamable<S>, S, T>
    extends StatefulWidget {
  const NoteListScaffold({
    super.key,
    required this.cubit,
    required this.countOf,
    required this.sortNotesByOf,
    required this.onSortSelected,
    required this.filteredOf,
    required this.titleOf,
    required this.bodyOf,
    required this.dateOf,
    required this.onTapNote,
    this.initialSearch,
  });

  final C cubit;
  final int Function(S state) countOf;
  final String Function(S state) sortNotesByOf;
  final ValueChanged<String> onSortSelected;
  final Future<List<T>> Function(S state, String query) filteredOf;
  final Future<String> Function(T note) titleOf;
  final String Function(T note) bodyOf;
  final DateTime Function(T note) dateOf;
  final void Function(T note) onTapNote;
  final String? initialSearch;

  @override
  State<NoteListScaffold<C, S, T>> createState() => _NoteListScaffoldState<C, S, T>();
}

class _NoteListScaffoldState<C extends StateStreamable<S>, S, T>
    extends State<NoteListScaffold<C, S, T>> {
  late TextEditingController searchController = TextEditingController(
    text: widget.initialSearch,
  );

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: BlocBuilder<C, S>(
        bloc: widget.cubit,
        builder: (context, state) {
          final count = widget.countOf(state);
          final sortNotesBy = widget.sortNotesByOf(state);
          return Scaffold(
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
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notes'.tr()),
                  Text(
                    '$count ${'notes saved'.tr()}',
                    style: context.textTheme.labelSmall,
                  ),
                ],
              ),
              actions: [
                PopupMenuButton<String>(
                  offset: const Offset(0, 48),
                  onSelected: widget.onSortSelected,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _SortIcon(sortNotesBy: sortNotesBy),
                  ),
                  itemBuilder: (context) {
                    return ['Newest', 'Oldest', 'A-Z', 'Z-A']
                        .map(
                          (e) => PopupMenuItem(value: e, child: Text(e)),
                        )
                        .toList();
                  },
                ),
              ],
            ),
            body: Visibility(
              visible: count > 0,
              replacement: NoDataFound(
                title: 'No notes found'.tr(),
                description: 'Create a note and view it here'.tr(),
                action: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    foregroundColor: context.colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  child: Text('Back'.tr()),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.colorScheme.surfaceContainerLowest,
                            context.colorScheme.surfaceContainerLow,
                          ],
                        ),
                        borderRadius: context.appRadius(8),
                        border: Border.all(
                          color: context.colorScheme.outlineVariant
                              .withValues(alpha: 0.62),
                        ),
                      ),
                      child: TextFormField(
                        controller: searchController,
                        decoration: InputDecoration(
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
                          hintText: 'Search notes'.tr(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: searchController,
                      builder: (context, _) => FutureBuilder<List<T>>(
                        future: widget.filteredOf(
                          state,
                          searchController.text,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.data?.isEmpty == true) {
                            return NoDataFound(
                              title: 'not found'.tr(
                                args: ['"${searchController.text}"'],
                              ),
                              description:
                                  'Correct your spellings or search another terms'
                                      .tr(),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 12),
                            itemCount: snapshot.data?.length ?? 0,
                            itemBuilder: (context, index) {
                              final item = snapshot.data![index];
                              return Material(
                                child: InkWell(
                                  onTap: () => widget.onTapNote(item),
                                  child: _NoteCard(
                                    titleFuture: widget.titleOf(item),
                                    body: widget.bodyOf(item),
                                    date: widget.dateOf(item),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SortIcon extends StatelessWidget {
  const _SortIcon({required this.sortNotesBy});

  final String sortNotesBy;

  @override
  Widget build(BuildContext context) {
    final (icon, direction) = switch (sortNotesBy) {
      'Oldest' => (Icons.access_time_rounded, Icons.arrow_downward_rounded),
      'A-Z' => (Icons.sort_by_alpha_rounded, Icons.arrow_upward_rounded),
      'Z-A' => (Icons.sort_by_alpha_rounded, Icons.arrow_downward_rounded),
      _ => (Icons.access_time_rounded, Icons.arrow_upward_rounded),
    };
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(icon),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomRight,
            child: CircleAvatar(radius: 6, child: Icon(direction, size: 10)),
          ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.titleFuture,
    required this.body,
    required this.date,
  });

  final Future<String> titleFuture;
  final String body;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: titleFuture,
      builder: (context, snapshot) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.colorScheme.surfaceContainerLowest,
              context.colorScheme.surfaceContainerLow,
            ],
          ),
          borderRadius: context.appRadius(8),
          border: Border.all(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      snapshot.data ?? 'Loading...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    date.toHumanDate(),
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

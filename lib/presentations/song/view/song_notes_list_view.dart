import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../../data/utilities/enums.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/extensions/datetime_ext.dart';
import '../../../router/router.dart';
import '../../faith/view/faith_note_list_view.dart';
import '../cubit/song_cubit.dart';

@RoutePage()
class SongNotesListView extends StatefulWidget {
  final SongCubit cubit;
  const SongNotesListView({super.key, required this.cubit});

  @override
  State<SongNotesListView> createState() => _SongNotesListViewState();
}

class _SongNotesListViewState extends State<SongNotesListView> {
  late TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: BlocBuilder<SongCubit, SongState>(
        builder: (context, state) => GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            backgroundColor: context.colorScheme.background,
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notes'.tr()),
                  Text(
                    '${state.notes.length} ${'notes saved'.tr()}',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              actions: [
                PopupMenuButton(
                  offset: Offset(0, 48),
                  onSelected: (value) {
                    context.read<SongCubit>().changeSortNote(value);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: () {
                      switch (state.sortNotesBy) {
                        case 'Newest':
                          return Stack(
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(Icons.access_time_rounded),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: CircleAvatar(
                                      radius: 6,
                                      child: Icon(
                                        Icons.arrow_upward_rounded,
                                        size: 10,
                                      )),
                                ),
                              ),
                            ],
                          );
                        case 'Oldest':
                          return Stack(
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(Icons.access_time_rounded),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: CircleAvatar(
                                      radius: 6,
                                      child: Icon(
                                        Icons.arrow_downward_rounded,
                                        size: 10,
                                      )),
                                ),
                              ),
                            ],
                          );
                        case 'A-Z':
                          return Stack(
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(Icons.sort_by_alpha_rounded),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: CircleAvatar(
                                      radius: 6,
                                      child: Icon(
                                        Icons.arrow_upward_rounded,
                                        size: 10,
                                      )),
                                ),
                              ),
                            ],
                          );
                        case 'Z-A':
                          return Stack(
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(Icons.sort_by_alpha_rounded),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: CircleAvatar(
                                      radius: 6,
                                      child: Icon(
                                        Icons.arrow_downward_rounded,
                                        size: 10,
                                      )),
                                ),
                              ),
                            ],
                          );
                        default:
                          return Icon(Icons.sort);
                      }
                    }(),
                  ),
                  itemBuilder: (context) {
                    return ['Newest', 'Oldest', 'A-Z', 'Z-A']
                        .map(
                          (e) => PopupMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList();
                  },
                ),
              ],
            ),
            body: Visibility(
              visible: state.notes.isNotEmpty,
              replacement: NoDataFound(
                title: 'No notes found'.tr(),
                description: 'Create a note and view it here'.tr(),
                action: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    foregroundColor: context.colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    router.pop();
                  },
                  child: Text('Back'.tr()),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        hintText: 'Search notes'.tr(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: searchController,
                      builder: (context, _) => FutureBuilder(
                        future: state.filteredNote(searchController.text),
                        builder: (context, snapshot) {
                          if (snapshot.data?.isEmpty == true) {
                            return NoDataFound(
                              title: 'not found'
                                  .tr(args: ['"${searchController.text}"']),
                              description:
                                  'Correct your spellings or search another terms'
                                      .tr(),
                            );
                          }
                          return ListView.builder(
                            itemCount: snapshot.data?.length ?? 0,
                            itemBuilder: (context, index) {
                              var item = snapshot.data![index];
                              return Material(
                                child: InkWell(
                                  onTap: () {
                                    router.push(SongNoteRoute(
                                      initialData: item,
                                      cubit: widget.cubit,
                                      mode: NoteMode.viewOnly,
                                      onSave: (data) {
                                        context
                                            .read<SongCubit>()
                                            .saveNote(data);
                                        router.pop();
                                        // router.push(SongNoteListRoute(cubit: context.read()));
                                      },
                                    ));
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.song.title ?? '',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  item.createdDate
                                                      .toHumanDate(),
                                                  style: context
                                                      .textTheme.bodySmall,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              quill.Document.fromJson(
                                                      jsonDecode(item.text!))
                                                  .toPlainText()
                                                  .trim()
                                                  .replaceAll('\n', ' .. '),
                                              maxLines: 2,
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        indent: 16,
                                        endIndent: 16,
                                        height: 1,
                                      ),
                                    ],
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
          ),
        ),
      ),
    );
  }
}

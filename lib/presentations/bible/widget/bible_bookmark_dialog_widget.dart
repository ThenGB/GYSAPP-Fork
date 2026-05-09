import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../../domain/entity/bible_bookmark/bible_bookmark.dart';
import '../bible.dart';

class BibleBookmarkDialog extends StatefulWidget {
  const BibleBookmarkDialog({
    super.key,
    required this.cubit,
    required this.onTap,
    required this.onModified,
  });
  final BibleCubit cubit;
  final Function(Verse item) onTap;

  final FutureOr<bool> Function(List<BibleBookmark> modified) onModified;

  @override
  State<BibleBookmarkDialog> createState() => _BibleBookmarkDialogState();
}

class _BibleBookmarkDialogState extends State<BibleBookmarkDialog> {
  late List<BibleBookmark> bookmarks = List.from(widget.cubit.state.bookmarks);

  late List<BibleBookmark> modifiedBookmarks = List.from(bookmarks);
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (bookmarks.length == modifiedBookmarks.length) {
          return true;
        }
        return widget.onModified(
          bookmarks
            ..retainWhere((element) => modifiedBookmarks.contains(element)),
        );
      },
      child: BlocProvider<BibleCubit>.value(
        value: widget.cubit,
        child: BlocBuilder<BibleCubit, BibleState>(
          builder: (context, state) => MediaQuery(
            data: context.mediaQuery.copyWith(
              textScaler: TextScaler.linear(state.defaultTextScale),
            ),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 16),
                    title: Text(
                      'Bookmarks'.tr(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: CloseButton(),
                  ),
                  Divider(height: 1),
                  Flexible(
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: bookmarks.isEmpty
                            ? ListTile(title: Text('Empty'.tr()))
                            : Column(
                                children: bookmarks.reversed
                                    .map(
                                      (e) => FutureBuilder(
                                        future: context
                                            .read<BibleCubit>()
                                            .getBibleTitle([
                                              e.verse,
                                            ], withVerse: !e.isBookmarkAll),
                                        builder: (context, snapshot) => ListTile(
                                          contentPadding: EdgeInsets.only(
                                            left: 16,
                                          ),
                                          trailing: IconButton(
                                            onPressed: () {
                                              if (modifiedBookmarks.contains(
                                                e,
                                              )) {
                                                modifiedBookmarks.remove(e);
                                              } else {
                                                modifiedBookmarks.add(e);
                                              }
                                              setState(() {});
                                            },
                                            icon: Icon(
                                              modifiedBookmarks.contains(e)
                                                  ? Icons.bookmark
                                                  : Icons
                                                        .bookmark_outline_rounded,
                                            ),
                                          ),
                                          onTap: () async {
                                            widget.onTap(e.verse);
                                          },
                                          title: Text(snapshot.data ?? ''),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
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

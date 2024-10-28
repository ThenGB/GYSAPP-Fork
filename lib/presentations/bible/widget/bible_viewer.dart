import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../data/data.dart';
import '../../../router/router.dart';
import '../bible.dart';

class BibleViewer extends StatefulWidget {
  const BibleViewer({
    super.key,
    required this.scrollController,
    required this.verseKeys,
    required this.selectedVerseMenuHeight,
    required this.cubit,
    required this.isSplit,
    required this.scrollFunction,
    required this.onVerseVisibility,
    required this.listener,
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.onScaleEnd,
    required this.textScale,
  });

  final Function(ScaleStartDetails details) onScaleStart;
  final Function(ScaleUpdateDetails details) onScaleUpdate;
  final Function(ScaleEndDetails details) onScaleEnd;
  final double textScale;

  final ScrollController scrollController;
  final List<GlobalKey<VerseWidgetState>> verseKeys;
  final Future<double> selectedVerseMenuHeight;
  final BibleCubit cubit;
  final bool isSplit;
  final Function(int index) scrollFunction;
  final Function(int index, Size size, double visiblePercentage)
      onVerseVisibility;
  final Function(ScrollableState scrollable, BuildContext context) listener;

  @override
  State<BibleViewer> createState() => _BibleViewerState();
}

class _BibleViewerState extends State<BibleViewer> {
  Set<int> touches = {};

  bool onScaling = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibleCubit, BibleState>(
      bloc: widget.cubit,
      builder: (context, state) {
        var verses = widget.isSplit ? state.versesSplit : state.verses;
        var pericopes = widget.isSplit ? state.pericopesSplit : state.pericopes;
        var pericopeParalels = widget.isSplit
            ? state.pericopesParalelsSplit
            : state.pericopesParalels;
        return Listener(
          onPointerCancel: (event) {
            touches.clear();
            log(touches.toString());
            if (touches.length <= 1) {
              if (onScaling) {
                setState(() {
                  onScaling = false;
                });
              }
            }
          },
          onPointerUp: (event) {
            touches.remove(event.pointer);
            log(touches.toString());
            if (touches.length <= 1) {
              if (onScaling) {
                setState(() {
                  onScaling = false;
                });
              }
            }
          },
          onPointerDown: (event) {
            touches.add(event.pointer);
            log(event.pointer.toString(), name: 'Pointer');
            log(touches.toString());
            if (touches.length > 1) {
              if (!onScaling) {
                setState(() {
                  onScaling = true;
                });
              }
            }
          },
          child: GestureDetector(
            onScaleStart: widget.onScaleStart,
            onScaleUpdate: widget.onScaleUpdate,
            onScaleEnd: widget.onScaleEnd,
            child: SingleChildScrollView(
              physics: onScaling
                  ? NeverScrollableScrollPhysics()
                  : AlwaysScrollableScrollPhysics(),
              controller: widget.scrollController,
              child: Container(
                color: context.colorScheme.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...verses.asMap().entries.map((e) {
                      var index = e.key;

                      return VisibilityDetector(
                        key: ValueKey('${widget.isSplit}_$index'),
                        onVisibilityChanged: (info) {
                          widget.onVerseVisibility(
                            e.value.verseId,
                            info.size,
                            info.visibleFraction,
                          );
                        },
                        child: VerseWidget(
                          textScale: widget.textScale,
                          isSpeaking:
                              state.isSpeaking && state.currentBible == e.value,
                          verse: e.value,
                          scrollFunction: widget.scrollFunction,
                          onTapNote: (note) async {
                            router.push(BibleNoteListRoute(
                                // ignore: use_build_context_synchronously
                                cubit: context.read(),
                                initialSearch: await context
                                    .read<BibleCubit>()
                                    .getBibleTitle(
                                  [note.first.verses.first],
                                )));
                            // router.push(BibleNoteRoute(
                            //   initialData: note.first,
                            //   cubit: cubit,
                            //   mode: NoteMode.viewOnly,
                            //   onSave: (data) {
                            //     cubit.saveNote(data);
                            //     router.maybePop();
                            //     // router.push(BibleNoteListRoute(cubit: context.read()));
                            //   },
                            // ));
                          },
                          notes: state.notes
                              .where((element) =>
                                  element.verses.firstWhereOrNull(
                                      (element) => element.id == e.value.id) !=
                                  null)
                              .toList(),
                          references:
                              state.references.getById(verses[index].id),
                          hightlightedVerse: state.hightlightedVerse,
                          selectedVerse: state.selectedVerse,
                          key: index > (widget.verseKeys.length - 1)
                              ? GlobalKey()
                              : widget.verseKeys[index],
                          index: index,
                          hasBookmark: state.bookmarks.firstWhereOrNull(
                                  (element) =>
                                      element.verse.id == verses[index].id &&
                                      !element.isBookmarkAll) !=
                              null,
                          pericope: pericopes.getById(verses[index].id),
                          pericopeParalels:
                              pericopeParalels.getById(verses[index].id),
                        ),
                      );
                    }).toList(),
                    FutureBuilder(
                      future: widget.selectedVerseMenuHeight,
                      builder: (context, snapshot) {
                        double height = ((state.selectedVerse.isNotEmpty
                                    ? (snapshot.data ?? 0)
                                    : 0) -
                                80.0)
                            .clamp(0, 1000);
                        return SizedBox(
                          height: height == 0 ? 60 : height,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

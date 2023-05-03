import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:church/data/utilities/extensions/context_ext.dart';
import 'package:church/presentations/bible/cubit/bible_cubit.dart';
import 'package:church/presentations/bible/widget/bible_select_widget.dart';
import 'package:church/router/router.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

@RoutePage()
class BibleView extends StatelessWidget {
  const BibleView({super.key});

  onTapSelectBible(BuildContext context) async {
    log('onTapSelectBible');
    context.read<BibleCubit>().getBibles();
    var bibleCodes = context
        .read<BibleCubit>()
        .state
        .bibleCodes
        .map((e) => e.split('.').first.toUpperCase())
        .toList();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BibleSelectWidget(
        bibleCodes: bibleCodes,
        onTap: (index) async {
          await context.read<BibleCubit>().selectBibleCode(index);
          router.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibleCubit, BibleState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Material(
                clipBehavior: Clip.antiAlias,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    context.read<BibleCubit>().previousChapter();
                  },
                  child: const CircleAvatar(
                    child: Icon(Icons.keyboard_arrow_left_rounded),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  state.bookTitle ?? '',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Material(
                clipBehavior: Clip.antiAlias,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    context.read<BibleCubit>().nextChapter();
                  },
                  child: const CircleAvatar(
                    child: Icon(Icons.keyboard_arrow_right_rounded),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            AnimatedCrossFade(
              alignment: Alignment.center,
              duration: kThemeAnimationDuration,
              crossFadeState: state.selectedVerse.length != 1
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: const SizedBox(
                width: 10,
                height: 48,
              ),
              secondChild: IconButton(
                icon: const Icon(Icons.short_text),
                onPressed: () async {},
              ),
            ),
            AnimatedCrossFade(
              alignment: Alignment.center,
              duration: kThemeAnimationDuration,
              crossFadeState: state.selectedVerse.isEmpty
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: const SizedBox(
                width: 10,
                height: 48,
              ),
              secondChild: IconButton(
                icon: const Icon(Icons.more_horiz_rounded),
                onPressed: () async {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    isScrollControlled: true,
                    builder: (c) => BlocProvider.value(
                        value: context.read<BibleCubit>(),
                        child: BibleMenu(
                          onDeleted: () {
                            context.read<BibleCubit>().hightLightBible(state
                                .selectedVerse
                                .map((e) =>
                                    e.copyWith(color: Colors.transparent))
                                .toList());
                          },
                          onHightlighted: (color) {
                            context.read<BibleCubit>().hightLightBible(state
                                .selectedVerse
                                .map((e) => e.copyWith(color: color))
                                .toList());
                          },
                        )),
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Info'),
                    content: Text.rich(TextSpan(children: [
                      TextSpan(
                        text: 'Bible code: ${state.currentBibleCode ?? 'none'}',
                      ),
                      const WidgetSpan(
                          child: SizedBox(
                        width: 8,
                      )),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: ElevatedButton(
                          onPressed: () {
                            router.pop().then((value) {
                              onTapSelectBible(context);
                            });
                          },
                          child: const Text('Change'),
                        ),
                      )
                    ])),
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          color: context.colorScheme.background,
          child: ScrollablePositionedList.builder(
            itemCount: state.bibles.length,
            itemBuilder: (context, index) {
              bool hasPericope =
                  state.pericopes.getById(state.bibles[index].id) != null;
              bool hasPericopeParalel =
                  state.pericopesParalels.getById(state.bibles[index].id) !=
                      null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasPericope)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          state.pericopes
                              .getById(state.bibles[index].id)!
                              .title!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (hasPericopeParalel)
                    Text(
                      state.pericopesParalels
                          .getById(state.bibles[index].id)!
                          .t!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  InkWell(
                    onTap: () {
                      context
                          .read<BibleCubit>()
                          .selectBible(state.bibles[index]);
                    },
                    child: AnimatedContainer(
                      duration: kThemeAnimationDuration,
                      color: state.selectedVerse.contains(state.bibles[index])
                          ? Colors.blue
                          : context.colorScheme.background,
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedDefaultTextStyle(
                        style: context.textTheme.bodyMedium!.copyWith(
                          fontSize: 16,
                          color:
                              state.selectedVerse.contains(state.bibles[index])
                                  ? Colors.white
                                  : null,
                        ),
                        duration: kThemeAnimationDuration,
                        child: Text(
                          '${state.bibles[index].verseId.toString()}. ${state.bibles[index].verse ?? ''}',
                          style: TextStyle(
                            backgroundColor: state.hightlightedVerse
                                .firstWhereOrNull((element) =>
                                    element.isSame(state.bibles[index]))
                                ?.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class BibleMenu extends StatelessWidget {
  final Function(Color color) onHightlighted;
  final Function() onDeleted;
  const BibleMenu({
    super.key,
    required this.onHightlighted,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibleCubit, BibleState>(
      builder: (context, state) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .5,
        maxChildSize: .5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: context.colorScheme.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                const ListTile(
                  title: Text('Copy'),
                ),
                const ListTile(
                  title: Text('Note'),
                ),
                ListTile(
                  title: const Text('Hightlight'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Future.delayed(kThemeAnimationDuration);
                    var result = await showDialog(
                      context: context,
                      builder: (context) => const ColorPickDialog(),
                    );
                    var color;
                    if (result[0] == 'apply') {
                      color = result[1];
                    } else {
                      onDeleted();
                      return;
                    }
                    if (color != null) {
                      onHightlighted(color);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ColorPickDialog extends StatefulWidget {
  const ColorPickDialog({
    super.key,
  });

  @override
  State<ColorPickDialog> createState() => _ColorPickDialogState();
}

class _ColorPickDialogState extends State<ColorPickDialog> {
  Color? selectedColor;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 300,
        width: 200,
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                double maxWidth = (constraints.maxWidth / 4).clamp(0, 60);
                return Wrap(
                  runSpacing: 16,
                  children: [
                    Colors.amber.shade200,
                    Colors.blue.shade200,
                    Colors.brown.shade200,
                    Colors.cyan.shade200,
                    Colors.red.shade200,
                    Colors.green.shade200,
                    Colors.orange.shade200,
                    Colors.purple.shade200,
                    Colors.teal.shade200,
                    Colors.indigo.shade200,
                    Colors.pink.shade200,
                    Colors.lime.shade200,
                  ]
                      .map((e) => SizedBox(
                            width: maxWidth,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedColor = e;
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: e,
                                child: selectedColor == e
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(onPressed: () {}, child: const Text('More color')),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colorScheme.error,
                      foregroundColor: context.colorScheme.onError,
                    ),
                    onPressed: () {
                      Navigator.pop(context, ['delete']);
                    },
                    child: const Text('Delete')),
                const SizedBox(
                  width: 8,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colorScheme.primary,
                      foregroundColor: context.colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      if (selectedColor == null) {
                        Fluttertoast.cancel();
                        Fluttertoast.showToast(
                          msg: 'Please select color'.tr(),
                          gravity: ToastGravity.CENTER,
                        );
                        return;
                      }
                      Navigator.pop(context, ['apply', selectedColor]);
                    },
                    child: const Text('Apply')),
              ],
            )
          ],
        ),
      ),
    );
  }
}

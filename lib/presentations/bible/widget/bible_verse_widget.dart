import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../../data/data.dart';
import '../../../data/utilities/toast_utils.dart';
import '../../../domain/domain.dart';
import '../bible.dart';
import 'bible_ref_dialog_widget.dart';

class VerseWidget extends StatefulWidget {
  const VerseWidget({
    super.key,
    required this.index,
    required this.verse,
    required this.pericope,
    required this.pericopeParalels,
    required this.selectedVerse,
    required this.hightlightedVerse,
    required this.notes,
    required this.onTapNote,
    required this.references,
    required this.hasBookmark,
    required this.scrollFunction,
    required this.isSpeaking,
    required this.textScale,
    required this.lockScroll,
    required this.isSplit,
  });
  final double textScale;
  final bool lockScroll;
  final bool isSplit;
  final int index;
  final bool isSpeaking;
  final List<BibleNote> notes;
  final List<Pericope> pericope;
  final bool hasBookmark;
  final List<PericopeParalel> pericopeParalels;
  final List<Verse> selectedVerse;
  final List<BibleRef> references;
  final List<Verse> hightlightedVerse;
  final Function(List<BibleNote> notes) onTapNote;
  final Function(int index) scrollFunction;
  final Verse verse;
  bool get hasNote => notes.isNotEmpty;

  bool get hasPericope => pericope.isNotEmpty;
  bool get hasPericopeParalel => pericopeParalels.isNotEmpty;
  bool get hasReferences => references.isNotEmpty;

  @override
  State<VerseWidget> createState() => VerseWidgetState();
}

class VerseWidgetState extends State<VerseWidget>
    with SingleTickerProviderStateMixin {
  GlobalKey widgetKey = GlobalKey();
  late AnimationController animationController = AnimationController(
    vsync: this,
    duration: kThemeAnimationDuration,
  );
  late Animation<Color?> animation = ColorTween(
    begin: Colors.transparent,
    end: Colors.transparent,
  ).animate(animationController);
  void playAnimation() async {
    for (var i = 0; i < 3; i++) {
      await animationController.play();
      await animationController.playReverse();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) => SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            if (widget.hasPericope || widget.hasPericopeParalel)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text.rich(
                  textAlign: TextAlign.center,
                  style: context
                      .read<BibleCubit>()
                      .state
                      .defaultTextTheme
                      .bodyMedium,
                  textScaler: TextScaler.linear(widget.textScale),
                  TextSpan(
                    children: [
                      if (widget.hasPericope) ...[
                        ...widget.pericope.asMap().entries.map((e) {
                          bool isLast = widget.pericope.length == e.key + 1;
                          return TextSpan(
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              height: context
                                  .read<BibleCubit>()
                                  .state
                                  .defaultTextHeight,
                            ),
                            text:
                                '${widget.verse.verseId > 1 && (!isLast || widget.pericope.length == 1) ? '\n' : ''}${e.value.title!}${!isLast ? '\n' : ''}',
                          );
                        }),
                      ],
                      if (widget.hasPericopeParalel) ...[
                        TextSpan(text: '\n'),
                        ...List.generate(
                          widget.pericopeParalels.length,
                          (index) => TextSpan(
                            children: [
                              WidgetSpan(
                                child: InkWell(
                                  onTap: () async {
                                    var item = widget.pericopeParalels[index];
                                    var bcv = Bcvbc.fromBibleId(item.id1!);
                                    safeToastCancel();
                                    safeShowToast(
                                      msg:
                                          'Opening ${widget.pericopeParalels[index].t}'
                                              .tr(),
                                    );
                                    await context.read<BibleCubit>().getContent(
                                      Verse(
                                        id: item.id1!,
                                        bookId: int.tryParse(bcv.b!) ?? 1,
                                        chapterId: int.tryParse(bcv.c!) ?? 1,
                                        verseId: int.tryParse(bcv.v!) ?? 1,
                                      ),
                                      mode: widget.lockScroll
                                          ? VerseMode.both
                                          : widget.isSplit
                                          ? VerseMode.bottomOnly
                                          : VerseMode.topOnly,
                                    );

                                    // Scroll after content is loaded
                                    final targetVerse =
                                        int.tryParse(bcv.v!) ?? 1;
                                    widget.scrollFunction(targetVerse - 1);
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        style: GoogleFonts.arima(
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                        '${widget.pericopeParalels[index].t}${(widget.pericopeParalels.length - 1) == index ? '' : ';'} ',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            Container(
              width: double.infinity,
              color:
                  widget.selectedVerse.contains(widget.verse) ||
                      widget.isSpeaking
                  ? context.colorScheme.surfaceContainerHigh
                  : animation.value,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Builder(
                builder: (context) {
                  var sentence = (widget.verse.verse ?? '').replaceAll(
                    '  ',
                    ' ',
                  );
                  sentence = removeTextBetweenTags(sentence, 'f');
                  sentence = sentence.replaceAll('<pb/>', '    ');
                  sentence = sentence.replaceAll('<t>', '');
                  sentence = sentence.replaceAll('</t>', '');
                  // var startIndex =
                  //     context.read<BibleCubit>().state.currentStartWord;
                  // var endIndex = context.read<BibleCubit>().state.currentEndWord;
                  // if (widget.hasPericope) {
                  //   startIndex = startIndex -
                  //       (widget.pericope
                  //               .map((e) => '${e.title}')
                  //               .join('. ')
                  //               .length +
                  //           1);
                  //   endIndex = endIndex -
                  //       (widget.pericope
                  //           .map((e) => '${e.title}')
                  //           .join('. ')
                  //           .length);
                  //   if (startIndex < 0) startIndex = 0;
                  //   if (endIndex < 0) endIndex = 0;
                  // }
                  // String beforeWord = '';
                  // String highlightedWord = '';
                  // String afterWord = '';
                  // if (context.read<BibleCubit>().state.isSpeaking &&
                  //     context.read<BibleCubit>().state.currentBible ==
                  //         widget.verse) {
                  //   try {
                  //     beforeWord = sentence.substring(
                  //         0, (startIndex).clamp(0, sentence.length - 1));
                  //     highlightedWord = sentence.substring(
                  //         startIndex, (endIndex).clamp(0, sentence.length - 1));
                  //     afterWord = sentence
                  //         .substring((endIndex).clamp(0, sentence.length - 1));
                  //   } catch (e) {
                  //     beforeWord = '';
                  //     highlightedWord = '';
                  //     afterWord = '';
                  //   }
                  // }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((widget.verse.verse ?? '').contains('<t>'))
                        GestureDetector(
                          onTap: () {
                            if (widget.hasNote) {
                              widget.onTapNote(widget.notes);
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 4 * widget.textScale),
                            alignment: !widget.hasNote
                                ? null
                                : Alignment.center,
                            decoration: widget.hasNote
                                ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        context.colorScheme.secondaryContainer,
                                  )
                                : null,
                            width: !widget.hasNote
                                ? 24
                                : 18 +
                                      ((widget.verse.verseId.toString().length -
                                                      1) *
                                                  4 +
                                              (widget.hasBookmark ? 10 : 0))
                                          .toDouble(),
                            height: !widget.hasNote ? null : 16,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.hasBookmark)
                                  Icon(
                                    Icons.bookmark,
                                    color: context.colorScheme.primary,
                                    size: 14,
                                  ),
                                Text(
                                  '${widget.verse.verseId} ',
                                  softWrap: false,

                                  maxLines: 1,
                                  overflow: TextOverflow.visible,
                                  //superscript is usually smaller in size
                                  textScaler: TextScaler.linear(
                                    0.7 * widget.textScale,
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'EB Garamond',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: widget.hasNote
                                        ? context
                                              .colorScheme
                                              .onSecondaryContainer
                                        : context.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text.rich(
                          style: context
                              .read<BibleCubit>()
                              .state
                              .defaultTextTheme
                              .bodyMedium
                              ?.copyWith(
                                fontFamily: 'EB Garamond',
                                fontSize: 20,
                                height: 1.55,
                                color: context.colorScheme.onSurface,
                              ),
                          textScaler: TextScaler.linear(widget.textScale),
                          textAlign: TextAlign.start,
                          TextSpan(
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child:
                                    (widget.verse.verse ?? '').contains('<t>')
                                    ? SizedBox()
                                    : GestureDetector(
                                        onTap: () {
                                          if (widget.hasNote) {
                                            widget.onTapNote(widget.notes);
                                          }
                                        },
                                        child: Container(
                                          alignment: !widget.hasNote
                                              ? null
                                              : Alignment.center,
                                          decoration: widget.hasNote
                                              ? BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: context
                                                      .colorScheme
                                                      .secondaryContainer,
                                                )
                                              : null,
                                          width: !widget.hasNote
                                              ? null
                                              : 18 +
                                                    ((widget.verse.verseId
                                                                        .toString()
                                                                        .length -
                                                                    1) *
                                                                4 +
                                                            (widget.hasBookmark
                                                                ? 10
                                                                : 0))
                                                        .toDouble(),
                                          height: !widget.hasNote ? null : 16,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (widget.hasBookmark)
                                                Icon(
                                                  Icons.bookmark,
                                                  color: context
                                                      .colorScheme
                                                      .primary,
                                                  size: 14,
                                                ),
                                              Text(
                                                '${widget.verse.verseId}  ',
                                                softWrap: false,

                                                maxLines: 1,
                                                overflow: TextOverflow.visible,
                                                //superscript is usually smaller in size
                                                textScaler:
                                                    const TextScaler.linear(
                                                      0.7,
                                                    ),
                                                style: TextStyle(
                                                  fontFamily: 'EB Garamond',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: widget.hasNote
                                                      ? context
                                                            .colorScheme
                                                            .onSecondaryContainer
                                                      : context
                                                            .colorScheme
                                                            .primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                              TextSpan(
                                text: '',
                                style: TextStyle(
                                  height: context
                                      .read<BibleCubit>()
                                      .state
                                      .defaultTextHeight,
                                  color: null,
                                  background: Paint()
                                    ..color =
                                        widget.hightlightedVerse
                                            .firstWhereOrNull(
                                              (element) =>
                                                  element.isSame(widget.verse),
                                            )
                                            ?.color ??
                                        Colors.transparent
                                    ..isAntiAlias = true
                                    ..strokeCap = StrokeCap.round
                                    ..strokeWidth = 10000
                                    ..strokeJoin = StrokeJoin.round,
                                  // backgroundColor: widget.hightlightedVerse
                                  //     .firstWhereOrNull(
                                  //         (element) => element.isSame(widget.verse))
                                  //     ?.color,
                                ),
                                children: [
                                  buildStyledText(sentence),
                                  // TextSpan(
                                  //   text: sentence,
                                  //   recognizer: TapGestureRecognizer()
                                  //     ..onTap = () async {
                                  //       context
                                  //           .read<BibleCubit>()
                                  //           .selectBible(widget.verse);
                                  //       if (widget.selectedVerse.isEmpty) {
                                  //         var terlalubawah = context
                                  //                 .read<BibleCubit>()
                                  //                 .state
                                  //                 .selectedVerse
                                  //                 .first
                                  //                 .verseId >
                                  //             (context
                                  //                     .read<BibleCubit>()
                                  //                     .state
                                  //                     .verses
                                  //                     .length -
                                  //                 4);
                                  //         if (terlalubawah) {
                                  //           await Future.delayed(
                                  //               kThemeAnimationDuration +
                                  //                   kThemeAnimationDuration +
                                  //                   kThemeAnimationDuration);
                                  //         } else {
                                  //           await Future.delayed(
                                  //               kThemeAnimationDuration);
                                  //         }
                                  //       }
                                  //       // ignore: use_build_context_synchronously
                                  //       if (context
                                  //           .read<BibleCubit>()
                                  //           .state
                                  //           .selectedVerse
                                  //           .contains(widget.verse)) {
                                  //         // ignore: use_build_context_synchronously
                                  //         Scrollable.ensureVisible(
                                  //           context,
                                  //           alignmentPolicy:
                                  //               ScrollPositionAlignmentPolicy
                                  //                   .explicit,
                                  //           alignment: .3,
                                  //           curve: Curves.linear,
                                  //           duration: kThemeAnimationDuration,
                                  //         );
                                  //       }
                                  //     },
                                  // ),
                                ],
                              ),
                              if (widget.hasReferences)
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: PopupMenuButton(
                                    padding: EdgeInsets.zero,
                                    elevation: 0,
                                    position: PopupMenuPosition.under,

                                    constraints: BoxConstraints(minHeight: 0),
                                    color: Colors.transparent,
                                    // offset: Offset(0, 12), // SET THE (X,Y) POSITION
                                    itemBuilder: (context) {
                                      return [
                                        PopupMenuItem(
                                          enabled: false,
                                          height: 0,
                                          padding: EdgeInsets.zero,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              bottom: 48,
                                            ),
                                            child: BibleRefDialog(
                                              textScaleFactor: widget.textScale,
                                              cubit: context.read(),
                                              selectedVerse: widget.verse,
                                              references: widget.references,
                                              scrollFunction: (index) {
                                                widget.scrollFunction(index);
                                              },
                                            ),
                                          ),
                                        ),
                                      ];
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        // color: context.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '*',
                                        key: widgetKey,
                                        textScaler: TextScaler.linear(
                                          widget.textScale,
                                        ),

                                        /// REF*
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          // color: context.colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
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
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  TextSpan buildStyledText(String text) {
    List<TextSpan> spans = [];
    int currentIndex = 0;
    var recognizer = TapGestureRecognizer()
      ..onTap = () {
        context.read<BibleCubit>().selectBible(widget.verse);
        if (widget.selectedVerse.isEmpty) {
          var terlalubawah =
              context.read<BibleCubit>().state.selectedVerse.first.verseId >
              (context.read<BibleCubit>().state.verses.length - 4);
          if (terlalubawah) {
            Future.delayed(
              kThemeAnimationDuration +
                  kThemeAnimationDuration +
                  kThemeAnimationDuration,
              () {
                // Your delay logic
              },
            );
          } else {
            Future.delayed(kThemeAnimationDuration, () {
              // Your delay logic
            });
          }
        }

        if (context.read<BibleCubit>().state.selectedVerse.contains(
          widget.verse,
        )) {
          Scrollable.ensureVisible(
            context,
            alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
            alignment: 0.3,
            curve: Curves.linear,
            duration: kThemeAnimationDuration,
          );
        }
      };
    while (currentIndex < text.length) {
      int startTagIndex = text.indexOf('<J>', currentIndex);
      if (startTagIndex == -1) {
        spans.add(
          TextSpan(text: text.substring(currentIndex), recognizer: recognizer),
        );
        break;
      }

      int endTagIndex = text.indexOf('</J>', startTagIndex);
      if (endTagIndex == -1) {
        spans.add(
          TextSpan(text: text.substring(currentIndex), recognizer: recognizer),
        );
        break;
      }

      spans.add(
        TextSpan(
          text: text.substring(currentIndex, startTagIndex),
          recognizer: recognizer,
        ),
      );
      spans.add(
        TextSpan(
          text: text.substring(startTagIndex + 3, endTagIndex),
          recognizer: recognizer, // +3 to skip <J>
          style: TextStyle(
            color: context.isLight ? Color(0xffFF3131) : Color(0xffEE4B2B),
          ), // Apply red color
        ),
      );

      currentIndex = endTagIndex + 4; // +4 to skip </J>
    }

    return TextSpan(children: spans);
  }
}

String removeWordsFromText(List<String> removeWords, String text) {
  // Join the list of words to remove into a single pattern for regex
  String removePattern = removeWords.join('|');

  // Create a regular expression pattern for the words to remove
  RegExp regex = RegExp(
    r'\b(?:' + removePattern + r')\b',
    caseSensitive: false,
  );

  // Replace the matched words with an empty string
  String modifiedText = text.replaceAll(regex, '');

  return modifiedText;
}

String removeTextBetweenTags(String text, String tag) {
  String startTag = '<$tag>';
  String endTag = '</$tag>';

  RegExp regex = RegExp(
    '$startTag.*?$endTag',
    multiLine: true,
    caseSensitive: false,
  );
  return text.replaceAll(regex, '');
}

class StyleBetween {
  final int start;
  final int end;

  StyleBetween(this.start, this.end);
}

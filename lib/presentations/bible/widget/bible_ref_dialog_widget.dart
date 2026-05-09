import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../../router/router.dart';
import '../bible.dart';

class BibleRefDialog extends StatefulWidget {
  const BibleRefDialog({
    super.key,
    required this.references,
    required this.cubit,
    required this.selectedVerse,
    required this.scrollFunction,
    required this.textScaleFactor,
  });

  final List<BibleRef> references;
  final Verse selectedVerse;
  final double textScaleFactor;
  final BibleCubit cubit;
  final Function(int index) scrollFunction;

  @override
  State<BibleRefDialog> createState() => _BibleRefDialogState();
}

class _BibleRefDialogState extends State<BibleRefDialog> {
  late BibleRef currentRef = widget.references.first;

  late List<Verse> currentVerses = [];

  @override
  void initState() {
    getCurrentVerse();
    super.initState();
  }

  void getCurrentVerse() {
    Future.microtask(() async {
      currentVerses = await widget.cubit.getVersesByIdRange(
        currentRef.sv,
        currentRef.ev,
      );
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: context.mediaQuery.copyWith(
        textScaler: TextScaler.linear(widget.textScaleFactor),
      ),
      child: BlocProvider.value(
        value: widget.cubit,
        child: Container(
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            border: Border.all(
              strokeAlign: BorderSide.strokeAlignInside,
              color: Colors.blueGrey.withValues(alpha: .3),
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                spreadRadius: 0,
                blurStyle: BlurStyle.normal,
                offset: Offset(0, 2),
                color: Colors.blueGrey.withValues(alpha: .3),
              ),
            ],
          ),
          child: SimpleDialog(
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            insetPadding: EdgeInsets.zero,
            backgroundColor: context.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            alignment: Alignment.topCenter,
            contentPadding: EdgeInsets.all(0),
            children: [
              Container(width: double.infinity),
              IconTheme(
                data: IconThemeData(color: Colors.black),
                child: Row(
                  children: [
                    CloseButton(color: context.textColor),
                    Expanded(
                      child: FutureBuilder(
                        future: widget.cubit.getBibleTitle([
                          widget.selectedVerse,
                        ], withVerse: true),
                        builder: (context, snapshot) => Text(
                          snapshot.data ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        router.maybePop();
                        widget.cubit.getContent(currentVerses.first);
                        widget.scrollFunction(currentVerses.first.verseId - 1);
                      },
                      icon: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          context.textColor ?? Colors.black,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          Assets.assetsIconsOpenInApp,
                          width: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IntrinsicHeight(
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: widget.references
                                  .map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: FutureBuilder(
                                        future: widget.cubit.getBibleTitle([
                                          if (e.sv != null)
                                            Verse(
                                              id: e.sv!,
                                              bookId: e.sv! ~/ 1000000,
                                              chapterId:
                                                  (e.sv! % 1000000) ~/ 1000,
                                              verseId: e.sv! % 1000,
                                            ),
                                          if (e.ev != null && e.ev != 0)
                                            Verse(
                                              id: e.ev!,
                                              bookId: e.ev! ~/ 1000000,
                                              chapterId:
                                                  (e.ev! % 1000000) ~/ 1000,
                                              verseId: e.ev! % 1000,
                                            ),
                                        ], withVerse: true),
                                        builder: (context, snapshot) {
                                          return ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: currentRef == e
                                                  ? context.colorScheme.primary
                                                  : context
                                                        .colorScheme
                                                        .secondaryContainer,
                                              foregroundColor: currentRef == e
                                                  ? context
                                                        .colorScheme
                                                        .onPrimary
                                                  : context
                                                        .colorScheme
                                                        .onSecondaryContainer,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                              ),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            onPressed: () {
                                              Scrollable.ensureVisible(
                                                context,
                                                duration:
                                                    kThemeAnimationDuration,
                                                curve: Curves.easeOut,
                                                alignment: .2,
                                              );
                                              currentRef = e;
                                              setState(() {});
                                              getCurrentVerse();
                                            },
                                            child: Text(snapshot.data ?? ''),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 20),
                              width: 20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    context.colorScheme.surface.withValues(
                                      alpha: 0,
                                    ),
                                    context.colorScheme.surface,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: context.height / 2,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...currentVerses.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () {
                                    router.maybePop();
                                    widget.cubit.getContent(e);
                                    widget.scrollFunction(e.verseId - 1);
                                  },
                                  child: Builder(
                                    builder: (context) {
                                      var sentence = (e.verse ?? '').replaceAll(
                                        '  ',
                                        ' ',
                                      );
                                      sentence = removeTextBetweenTags(
                                        sentence,
                                        'f',
                                      );
                                      sentence = sentence.replaceAll(
                                        '<pb/>',
                                        '    ',
                                      );
                                      sentence = sentence.replaceAll('<t>', '');
                                      sentence = sentence.replaceAll(
                                        '</t>',
                                        '',
                                      );
                                      return Text.rich(
                                        style: widget
                                            .cubit
                                            .state
                                            .defaultTextTheme
                                            .bodyMedium,
                                        textScaler: TextScaler.linear(
                                          widget.textScaleFactor,
                                        ),
                                        textAlign: TextAlign.justify,
                                        TextSpan(
                                          children: [
                                            if (!(e.verse ?? '').contains(
                                              '<t>',
                                            ))
                                              WidgetSpan(
                                                alignment:
                                                    PlaceholderAlignment.middle,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '${e.verseId}  ',
                                                      softWrap: false,

                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.visible,
                                                      //superscript is usually smaller in size
                                                      textScaler:
                                                          const TextScaler.linear(
                                                            0.7,
                                                          ),
                                                      style: TextStyle(
                                                        color: context
                                                            .colorScheme
                                                            .onSecondaryContainer,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            TextSpan(
                                              text: '',
                                              style: TextStyle(
                                                height: widget
                                                    .cubit
                                                    .state
                                                    .defaultTextHeight,
                                              ),
                                              children: [
                                                buildStyledText(sentence),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
  }

  TextSpan buildStyledText(String text) {
    List<TextSpan> spans = [];
    int currentIndex = 0;

    while (currentIndex < text.length) {
      int startTagIndex = text.indexOf('<J>', currentIndex);
      if (startTagIndex == -1) {
        spans.add(TextSpan(text: text.substring(currentIndex)));
        break;
      }

      int endTagIndex = text.indexOf('</J>', startTagIndex);
      if (endTagIndex == -1) {
        spans.add(TextSpan(text: text.substring(currentIndex)));
        break;
      }

      spans.add(TextSpan(text: text.substring(currentIndex, startTagIndex)));
      spans.add(
        TextSpan(
          text: text.substring(startTagIndex + 3, endTagIndex),
          // +3 to skip <J>
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

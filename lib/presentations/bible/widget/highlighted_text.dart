import 'package:flutter/material.dart';

import '../../../data/data.dart';

TextSpan buildHighlightedText(
  String text,
  List<String> terms,
  BuildContext context, {
  TextStyle? style,
  bool isUnderline = false,
}) {
  List<TextSpan> textSpans = [];

  String pattern = terms.map((term) => RegExp.escape(term)).join('|');
  RegExp regex = RegExp(pattern, caseSensitive: false);
  List<Match> matches = regex.allMatches(text).toList();

  int currentIndex = 0;

  for (var match in matches) {
    if (currentIndex < match.start) {
      textSpans.add(TextSpan(text: text.substring(currentIndex, match.start)));
    }

    textSpans.add(
      TextSpan(
        text: text.substring(match.start, match.end),
        style: TextStyle(
          backgroundColor: isUnderline
              ? null
              : Colors.yellow, // Set background color
          fontWeight: FontWeight.bold,
          decorationThickness: 3,
          decorationStyle: TextDecorationStyle.solid,
          decoration: isUnderline
              ? TextDecoration.underline
              : TextDecoration.none,
          decorationColor: isUnderline ? Colors.yellow : null,
        ),
      ),
    );

    currentIndex = match.end;
  }

  if (currentIndex < text.length) {
    textSpans.add(TextSpan(text: text.substring(currentIndex)));
  }

  return TextSpan(
    style: TextStyle(
      fontSize: 14,
      color: context.textTheme.bodyMedium?.color,
    ).merge(style),
    children: textSpans,
  );
}

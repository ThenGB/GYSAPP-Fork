import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/services/pdf_note_extractor.dart';

// Base vertical gap (percent of page height) between the chord badge and the
// note it annotates. Kept small so chords sit close to the note numbers;
// users can widen it via the chord offset setting.
const double _chordYOffsetPagePercent = 2.6;
const double _chordBaseFontPdfPoints = 7.0;
const double _chordMinFontSize = 4.5;
const double _chordMaxFontSize = 28.0;

class ChordBadgeLayout {
  final Offset center;
  final double fontSize;
  final EdgeInsets padding;

  const ChordBadgeLayout({
    required this.center,
    required this.fontSize,
    required this.padding,
  });
}

ChordBadgeLayout calculateChordBadgeLayout({
  required NotePosition notePosition,
  required Size renderedPageSize,
  required Size pdfPageSize,
  required int fontSizePercent,
  required int paddingPercent,
  int offsetPercent = 100,
}) {
  final scale = _pageScale(renderedPageSize, pdfPageSize);
  final fontSize = (_chordBaseFontPdfPoints * scale * fontSizePercent / 100.0)
      .clamp(_chordMinFontSize, _chordMaxFontSize)
      .toDouble();
  final paddingScale = paddingPercent / 100.0;
  // Clamp the offset the same way as the other percent settings so a corrupt
  // persisted value (e.g. a tampered hydration blob) can never push the badge
  // arbitrarily far off the page. The UI slider already bounds it 0-300.
  final offsetScale = (offsetPercent / 100.0).clamp(0.0, 3.0);

  return ChordBadgeLayout(
    center: Offset(
      notePosition.xPct / 100.0 * renderedPageSize.width,
      (notePosition.yPct -
              _chordYOffsetPagePercent * offsetScale) /
          100.0 *
          renderedPageSize.height,
    ),
    fontSize: fontSize,
    padding: EdgeInsets.symmetric(
      horizontal: math.max(1.0, fontSize * 0.48 * paddingScale),
      vertical: math.max(0.75, fontSize * 0.2 * paddingScale),
    ),
  );
}

double _pageScale(Size renderedPageSize, Size pdfPageSize) {
  if (pdfPageSize.width <= 0 || pdfPageSize.height <= 0) return 1.0;
  return math.min(
    renderedPageSize.width / pdfPageSize.width,
    renderedPageSize.height / pdfPageSize.height,
  );
}

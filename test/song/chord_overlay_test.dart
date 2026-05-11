import 'package:church/presentations/song/widgets/chord_badge_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('chord badge layout', () {
    test('places the chord higher than the note baseline', () {
      final layout = calculateChordBadgeLayout(
        notePosition: (xPct: 50, yPct: 50),
        renderedPageSize: const Size(500, 700),
        pdfPageSize: const Size(500, 700),
        fontSizePercent: 100,
        paddingPercent: 100,
      );

      expect(layout.center.dx, 250);
      expect(layout.center.dy, closeTo(323.4, 0.01));
    });

    test('scales font and padding with the rendered PDF zoom', () {
      final small = calculateChordBadgeLayout(
        notePosition: (xPct: 50, yPct: 50),
        renderedPageSize: const Size(250, 350),
        pdfPageSize: const Size(500, 700),
        fontSizePercent: 100,
        paddingPercent: 100,
      );
      final large = calculateChordBadgeLayout(
        notePosition: (xPct: 50, yPct: 50),
        renderedPageSize: const Size(1000, 1400),
        pdfPageSize: const Size(500, 700),
        fontSizePercent: 100,
        paddingPercent: 100,
      );

      expect(small.fontSize, lessThan(large.fontSize));
      expect(small.padding.horizontal, lessThan(large.padding.horizontal));
    });

    test('keeps user font-size percentage applied after zoom scaling', () {
      final normal = calculateChordBadgeLayout(
        notePosition: (xPct: 50, yPct: 50),
        renderedPageSize: const Size(500, 700),
        pdfPageSize: const Size(500, 700),
        fontSizePercent: 100,
        paddingPercent: 100,
      );
      final enlarged = calculateChordBadgeLayout(
        notePosition: (xPct: 50, yPct: 50),
        renderedPageSize: const Size(500, 700),
        pdfPageSize: const Size(500, 700),
        fontSizePercent: 140,
        paddingPercent: 100,
      );

      expect(enlarged.fontSize, greaterThan(normal.fontSize));
    });
  });
}

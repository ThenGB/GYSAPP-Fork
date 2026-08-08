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
      // Default offset (100%) sits 2.6% of the page height above the note:
      // 350 - (0.026 * 700) = 331.8.
      expect(layout.center.dy, closeTo(331.8, 0.01));
    });

    test('vertical offset scales with the offset percent setting', () {
      ChordBadgeLayout build(int offsetPercent) => calculateChordBadgeLayout(
        notePosition: (xPct: 50, yPct: 50),
        renderedPageSize: const Size(500, 700),
        pdfPageSize: const Size(500, 700),
        fontSizePercent: 100,
        paddingPercent: 100,
        offsetPercent: offsetPercent,
      );

      final closer = build(50);
      final default_ = build(100);
      final farther = build(200);

      // Lower offset % = closer to the note number (higher on the page the
      // chord sits), higher offset % = pushed further away.
      expect(closer.center.dy, greaterThan(default_.center.dy));
      expect(default_.center.dy, greaterThan(farther.center.dy));
      // 50% of the 2.6% base: 350 - (0.026*0.5*700) = 340.9.
      expect(closer.center.dy, closeTo(340.9, 0.01));
      // 200%: 350 - (0.026*2*700) = 313.6.
      expect(farther.center.dy, closeTo(313.6, 0.01));
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

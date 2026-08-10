import 'package:church/presentations/bible/view/bible_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bible split layout', () {
    test('ratio remains readable on both panes', () {
      expect(normalizeBibleSplitRatio(null), 0.5);
      expect(normalizeBibleSplitRatio(double.nan), 0.5);
      expect(normalizeBibleSplitRatio(0.05), kBibleSplitMinRatio);
      expect(normalizeBibleSplitRatio(0.95), kBibleSplitMaxRatio);
      expect(normalizeBibleSplitRatio(0.42), 0.42);
    });
  });

  group('held book scrubber', () {
    const panel = Rect.fromLTWH(12, 100, 336, 440);

    test('maps the first and last cells without overflow', () {
      expect(
        bibleQuickBookIndexForPosition(
          globalPosition: const Offset(13, 101),
          panelRect: panel,
          bookCount: 66,
          columnCount: 3,
        ),
        0,
      );
      expect(
        bibleQuickBookIndexForPosition(
          globalPosition: const Offset(347, 539),
          panelRect: panel,
          bookCount: 66,
          columnCount: 3,
        ),
        65,
      );
    });

    test('clamps a held drag that leaves the visible panel', () {
      expect(
        bibleQuickBookIndexForPosition(
          globalPosition: const Offset(-100, -100),
          panelRect: panel,
          bookCount: 66,
          columnCount: 3,
        ),
        0,
      );
      expect(
        bibleQuickBookIndexForPosition(
          globalPosition: const Offset(900, 900),
          panelRect: panel,
          bookCount: 66,
          columnCount: 3,
        ),
        65,
      );
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:church/components/widgets/swipe_detector_widget.dart';

void main() {
  group('SwipeDetectorWidget thresholds', () {
    testWidgets('ignores short horizontal drag below minDistance', (
      tester,
    ) async {
      var swipes = 0;
      await tester.pumpWidget(
        SwipeDetectorWidget(
          minDistance: 60,
          minVelocity: 250,
          onSwipeLeft: () => swipes++,
          onSwipeRight: () => swipes++,
          child: const SizedBox(width: 400, height: 400),
        ),
      );
      // 40px horizontal drag with low velocity — below threshold.
      final gesture = await tester.startGesture(const Offset(200, 200));
      await gesture.moveBy(const Offset(40, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(swipes, 0);
    });

    testWidgets('triggers on long fast horizontal drag', (tester) async {
      var left = 0, right = 0;
      await tester.pumpWidget(
        SwipeDetectorWidget(
          minDistance: 60,
          minVelocity: 250,
          onSwipeLeft: () => left++,
          onSwipeRight: () => right++,
          child: const SizedBox(width: 400, height: 400),
        ),
      );
      // 200px fast drag to the left using timedDragFrom (real velocity).
      await tester.timedDragFrom(
        const Offset(300, 200),
        const Offset(-200, 0),
        const Duration(milliseconds: 100),
      );
      await tester.pumpAndSettle();
      expect(left, 1);
      expect(right, 0);
    });

    testWidgets('ignores vertical drag (no horizontal threshold met)', (
      tester,
    ) async {
      var swipes = 0;
      await tester.pumpWidget(
        SwipeDetectorWidget(
          onSwipeLeft: () => swipes++,
          onSwipeRight: () => swipes++,
          child: const SizedBox(width: 400, height: 400),
        ),
      );
      final gesture = await tester.startGesture(const Offset(200, 100));
      await gesture.moveBy(const Offset(0, 200));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(swipes, 0);
    });
  });
}

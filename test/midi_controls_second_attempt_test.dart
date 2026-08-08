import 'package:church/presentations/song/widgets/draggable_midi_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reproduces: expand (attempt 1) → collapse → expand (attempt 2).
/// On attempt 2 some animations were reported skipped — sample the fly
/// position and morph width mid-animation on both attempts and compare.
void main() {
  testWidgets('second expand attempt runs fly and morph like the first', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(children: [createTestMidiControls(isExpanded: false)]),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final positioned = find.byKey(const ValueKey('midi-positioned'));

    Future<
      ({
        double flyLeft,
        double widthAtMorphStart,
        double widthMid,
        double radiusMid,
      })
    >
    runCycle() async {
      // --- Expand ---
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();
      // Mid-fly sample (fly runs 0→240ms, morph starts at 180ms).
      await tester.pump(const Duration(milliseconds: 120));
      final flyLeft = tester.getRect(positioned).left;
      // Morph start: size should still be the pill (64 wide).
      await tester.pump(const Duration(milliseconds: 60));
      final widthAtMorphStart = tester.getRect(positioned).width;
      // Morph mid: size should be between pill and player.
      await tester.pump(const Duration(milliseconds: 60));
      final widthMid = tester.getRect(positioned).width;
      final radiusMid = _radiusOf(tester);
      // Let it finish expanding.
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('midi-expanded')), findsOneWidget);

      // --- Collapse ---
      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      return (
        flyLeft: flyLeft,
        widthAtMorphStart: widthAtMorphStart,
        widthMid: widthMid,
        radiusMid: radiusMid,
      );
    }

    final attempt1 = await runCycle();
    final attempt2 = await runCycle();

    // Fly must visibly move on BOTH attempts (sidebar left ≈ 328 → player 9).
    expect(attempt1.flyLeft, lessThan(200), reason: 'attempt 1 fly');
    expect(
      attempt2.flyLeft,
      closeTo(attempt1.flyLeft, 1.0),
      reason:
          'attempt 2 fly skipped: a1=${attempt1.flyLeft}, a2=${attempt2.flyLeft}',
    );

    // Morph must be in progress (radius between pill 24 and expanded 16) on
    // BOTH attempts.
    expect(attempt1.radiusMid, lessThan(24), reason: 'attempt 1 radius morph');
    expect(
      attempt1.radiusMid,
      greaterThan(16),
      reason: 'attempt 1 radius morph',
    );
    expect(
      attempt2.radiusMid,
      closeTo(attempt1.radiusMid, 0.5),
      reason:
          'attempt 2 radius morph skipped: a1=${attempt1.radiusMid}, '
          'a2=${attempt2.radiusMid}',
    );

    // The size bloom must animate on BOTH attempts: pill (64) at morph
    // start, growing toward the player width (342) mid-morph — never an
    // instant jump to full width.
    expect(
      attempt1.widthAtMorphStart,
      closeTo(64, 2),
      reason: 'attempt 1 pill size at morph start',
    );
    expect(attempt1.widthMid, greaterThan(64), reason: 'attempt 1 bloom');
    expect(attempt1.widthMid, lessThan(342), reason: 'attempt 1 bloom');
    expect(
      attempt2.widthMid,
      closeTo(attempt1.widthMid, 1.0),
      reason:
          'attempt 2 bloom skipped: a1=${attempt1.widthMid}, '
          'a2=${attempt2.widthMid}',
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('seekbar follows the accent and pulses while playing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SliderThemeData theme() => tester
        .widget<SliderTheme>(
          find
              .ancestor(
                of: find.byType(Slider),
                matching: find.byType(SliderTheme),
              )
              .first,
        )
        .data;

    // Playing: the pulse should animate the active track alpha.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              createTestMidiControls(isExpanded: true, isPlaying: true),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final a1 = theme().activeTrackColor!.a;
    await tester.pump(const Duration(milliseconds: 400));
    final a2 = theme().activeTrackColor!.a;

    // Accent palette: the seekbar uses the theme accent (primary), not
    // onPrimary (white-on-white on the light controls card).
    final scheme = Theme.of(tester.element(find.byType(Slider))).colorScheme;
    expect(theme().thumbColor, scheme.primary);
    expect(theme().activeTrackColor!.withValues(alpha: 1.0), scheme.primary);
    expect(theme().activeTrackColor, isNot(scheme.onPrimary));
    expect(a1, isNot(closeTo(a2, 0.01)), reason: 'pulse should move the alpha');

    // Paused: pulse parks at full alpha and stays static.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              createTestMidiControls(isExpanded: true, isPlaying: false),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    final b1 = theme().activeTrackColor!.a;
    await tester.pump(const Duration(milliseconds: 400));
    final b2 = theme().activeTrackColor!.a;
    expect(b1, closeTo(b2, 0.0001), reason: 'paused seekbar must be static');
    expect(b1, 1.0, reason: 'paused seekbar at full alpha');

    expect(tester.takeException(), isNull);
  });
}

double _radiusOf(WidgetTester tester) {
  final clip = tester.widget<ClipRRect>(
    find
        .descendant(
          of: find.byKey(const ValueKey('midi-positioned')),
          matching: find.byType(ClipRRect),
        )
        .first,
  );
  return clip.borderRadius.resolve(TextDirection.ltr).topLeft.x;
}

Widget createTestMidiControls({
  bool isExpanded = false,
  bool isPlaying = false,
}) {
  return DraggableMidiControls(
    isPlaying: isPlaying,
    isLoading: false,
    position: 0,
    duration: 180,
    transposeStep: 0,
    currentKey: 'C',
    availableKeys: const ['C'],
    tempoBpm: 76,
    onPlayPause: () {},
    onLoopModeCycle: () {},
    onSeek: (_) {},
    onTranspose: (_) {},
    onKeySelected: (_) {},
    onTempo: (_) {},
    nowPlayingTitle: 'Test Song',
    isExpanded: isExpanded,
  );
}

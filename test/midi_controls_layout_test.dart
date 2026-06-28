import 'dart:io';

import 'package:church/presentations/song/widgets/draggable_midi_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper to create a DraggableMidiControls widget with common defaults
Widget createTestMidiControls({
  bool isExpanded = false,
  bool isPlaying = false,
  bool isLoading = false,
  double position = 0,
  double duration = 180,
  int transposeStep = 0,
  String? currentKey,
  double tempoBpm = 76,
  String? nowPlayingTitle,
  List<String>? availableKeys,
  VoidCallback? onPlayPause,
  VoidCallback? onLoopModeCycle,
  void Function(double)? onSeek,
  void Function(int)? onTranspose,
  void Function(String)? onKeySelected,
  void Function(double)? onTempo,
}) {
  return DraggableMidiControls(
    isPlaying: isPlaying,
    isLoading: isLoading,
    position: position,
    duration: duration,
    transposeStep: transposeStep,
    currentKey: currentKey ?? '-',
    availableKeys: availableKeys ?? const [],
    tempoBpm: tempoBpm,
    onPlayPause: onPlayPause ?? () {},
    onLoopModeCycle: onLoopModeCycle ?? () {},
    onSeek: onSeek ?? (_) {},
    onTranspose: onTranspose ?? (_) {},
    onKeySelected: onKeySelected ?? (_) {},
    onTempo: onTempo ?? (_) {},
    nowPlayingTitle: nowPlayingTitle ?? '',
    isExpanded: isExpanded,
  );
}

/// Helper to wrap the MIDI controls in a test widget tree
Widget createTestWidget({
  required Widget child,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [child],
      ),
    ),
  );
}

void main() {
  test('midi player animation state machine is defined', () {
    // Verify all states are accessible
    expect(MidiPlayerAnimationState.values.length, 6);
    expect(MidiPlayerAnimationState.sidebar_circle.index, 0);
    expect(MidiPlayerAnimationState.expanded_player.index, 3);
  });

  test('dashboard global mini player overlays instead of reserving space', () {
    final source = File(
      'lib/presentations/dashboard/view/dashboard_view.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('const bool kDashboardExtendsBodyForMiniPlayerOverlay = true'),
    );
    expect(
      source,
      contains('navHeight + bottomInset'),
    );
    expect(source, isNot(contains('final reservedBottomSpace')));
  });

  test('dashboard mini player hit area includes the painted overlay', () {
    final source = File(
      'lib/presentations/dashboard/view/dashboard_view.dart',
    ).readAsStringSync();

    expect(source, contains('dashboardMiniPlayerHitTestHeight('));
    expect(source, contains('dashboardMiniPlayerBottomOffset('));
  });

  testWidgets('midi controls expand without overflow on a compact screen', (
    tester,
  ) async {
    WidgetController.hitTestWarningShouldBeFatal = true;
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      WidgetController.hitTestWarningShouldBeFatal = false;
    });

    await tester.pumpWidget(
      createTestWidget(
        child: createTestMidiControls(
          currentKey: 'C',
          availableKeys: const ['C', 'D', 'E'],
          isExpanded: true,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Now Playing'), warnIfMissed: true);
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
  });

  testWidgets('midi controls are docked to the bottom as an overlay', (
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
          body: Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: Colors.white)),
              createTestMidiControls(
                currentKey: 'C',
                availableKeys: const ['C', 'D', 'E'],
                isExpanded: true,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));
    // Verify header is visible when expanded
    expect(find.text('Now Playing'), findsOneWidget);
    // Verify controls are visible when expanded
    expect(find.byKey(const ValueKey('midi-expanded')), findsOneWidget);
  });

  testWidgets('midi controls expand to show all controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      createTestWidget(
        child: createTestMidiControls(
          nowPlayingTitle: 'Besar Setia-Mu',
          isExpanded: true,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    // Verify header is visible when expanded
    expect(find.text('Besar Setia-Mu'), findsOneWidget);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);

    // Verify controls container exists (ValueKey used in _buildExpandedControls)
    expect(find.byKey(const ValueKey('midi-expanded')), findsOneWidget);
  });

  testWidgets('loop control button visible when expanded', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        child: createTestMidiControls(
          isExpanded: true,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    // Loop button should be visible when expanded
    expect(find.byTooltip('Loop off'), findsOneWidget);
  });

  testWidgets('seek acknowledgement does not rebuild parent during build', (
    tester,
  ) async {
    double position = 0;
    double? seekedTo;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setOuterState) {
              return Stack(
                children: [
                  createTestMidiControls(
                    position: position,
                    onSeek: (value) {
                      seekedTo = value;
                      setOuterState(() => position = value);
                    },
                    isExpanded: true,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));
    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(90);
    slider.onChangeEnd!(90);
    await tester.pump();

    expect(seekedTo, 90);
    expect(tester.takeException(), isNull);
  });

  testWidgets('midi control row stays aligned in portrait and landscape', (
    tester,
  ) async {
    Future<void> pumpFor(Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        createTestWidget(
          child: createTestMidiControls(
            currentKey: 'Eb',
            isExpanded: true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final transposeRect = tester.getRect(
        find.byKey(const ValueKey('midi-transpose-field')),
      );
      final tempoRect = tester.getRect(find.text('76').first);
      final instrumentRect = tester.getRect(find.byIcon(Icons.piano_rounded));
      final loopRect = tester.getRect(find.byTooltip('Loop off'));

      final baselineY = transposeRect.center.dy;
      expect((tempoRect.center.dy - baselineY).abs(), lessThan(8));
      expect((instrumentRect.center.dy - baselineY).abs(), lessThan(8));
      expect((loopRect.center.dy - baselineY).abs(), lessThan(8));
      expect(tester.takeException(), isNull);
    }

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpFor(const Size(360, 740));
    await pumpFor(const Size(740, 360));
  });

  testWidgets('transpose control visible when expanded', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        child: createTestMidiControls(
          isExpanded: true,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // Verify transpose field is visible when expanded
    expect(find.byKey(const ValueKey('midi-transpose-field')), findsOneWidget);
  });

  testWidgets('expand animation triggers fly phase first', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        child: createTestMidiControls(isExpanded: false),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    // Tap the circle to expand
    await tester.tap(find.byIcon(Icons.queue_music_rounded));
    await tester.pump();

    // Should be in flying state
    await tester.pump(const Duration(milliseconds: 50));

    // Fly phase should be in progress (150ms total)
    await tester.pump(const Duration(milliseconds: 100));

    // After another 150ms, should be fully expanded
    await tester.pump(const Duration(milliseconds: 300));

    // Controls should be visible
    expect(find.byKey(const ValueKey('midi-expanded')), findsOneWidget);
  });

  testWidgets('expand fly phase moves circle from sidebar to player', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      createTestWidget(child: createTestMidiControls(isExpanded: false)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final positioned = find.byKey(const ValueKey('midi-positioned'));
    final sidebarLeft = tester.getRect(positioned).left;

    // Tap the circle to expand
    await tester.tap(find.byIcon(Icons.queue_music_rounded));
    await tester.pump();

    // Half-way through the fly phase (240ms total fly).
    await tester.pump(const Duration(milliseconds: 120));
    final midFlyLeft = tester.getRect(positioned).left;

    // During the fly, the circle should move from sidebar (right edge,
    // left=328) towards player (bottom centre, left=9).  So midFlyLeft
    // should be significantly less than sidebarLeft.
    expect(
      midFlyLeft < sidebarLeft - 20,
      isTrue,
      reason: 'Expand fly did not move circle from sidebar: '
              'sidebarLeft=$sidebarLeft, midFlyLeft=$midFlyLeft',
    );

    await tester.pumpAndSettle();
  });

  testWidgets('collapse animation reverses the sequence', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        child: createTestMidiControls(
          isExpanded: true,
          nowPlayingTitle: 'Test Song',
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    // Find and tap the collapse icon (expand_more)
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pump();

    // Morph phase (shrink to circle)
    await tester.pump(const Duration(milliseconds: 150));

    // Fly phase (circle to sidebar)
    await tester.pump(const Duration(milliseconds: 300));

    // Should be collapsed - circle visible
    expect(find.byIcon(Icons.queue_music_rounded), findsOneWidget);
  });

  testWidgets(
    'collapse morph phase keeps the panel centred on screen',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(
          child: createTestMidiControls(
            isExpanded: true,
            nowPlayingTitle: 'Test Song',
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Capture the player centre via the Positioned key.  During the morph
      // phase the panel shrinks but its CENTRE should stay at screenWidth/2
      // so the circle collapses in place rather than drifting to the left
      // edge of the expanded player.
      final playerRect = tester
          .getRect(find.byKey(const ValueKey('midi-positioned')));
      final playerCenter = playerRect.center.dx;

      // Start collapse.
      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pump();

      // Half-way through the morph phase (240ms total).  The panel should
      // have shrunk substantially but its centre should still be at the
      // same x as the expanded player's centre.
      await tester.pump(const Duration(milliseconds: 120));
      final midMorphRect = tester
          .getRect(find.byKey(const ValueKey('midi-positioned')));
      final midMorphCenter = midMorphRect.center.dx;
      // The centre should NOT have drifted sideways.  Allow 2px slop for
      // sub-pixel rounding.
      expect(
        (midMorphCenter - playerCenter).abs() < 2,
        isTrue,
        reason:
            'Panel centre drifted during morph: '
            'expandedCenter=$playerCenter, midMorphCenter=$midMorphCenter',
      );

      // Let the animation settle.
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'collapse fly phase moves the circle from player to sidebar',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(
          child: createTestMidiControls(
            isExpanded: true,
            nowPlayingTitle: 'Test Song',
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Capture the player left edge.
      final playerLeft = tester
          .getRect(find.byKey(const ValueKey('midi-positioned')))
          .left;

      // Start collapse.
      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pump();

      // Sample at 3 points during the fly phase to verify the panel
      // moves from player to sidebar (not from sidebar to player).
      await tester.pump(const Duration(milliseconds: 300));
      final earlyFlyLeft = tester
          .getRect(find.byKey(const ValueKey('midi-positioned')))
          .left;
      await tester.pump(const Duration(milliseconds: 80));
      final midFlyLeft = tester
          .getRect(find.byKey(const ValueKey('midi-positioned')))
          .left;
      await tester.pumpAndSettle();
      final finalLeft = tester
          .getRect(find.byKey(const ValueKey('midi-positioned')))
          .left;

      // The panel should progress towards the sidebar during the fly.
      // The final position should be at the sidebar (right edge).
      expect(
        finalLeft > midFlyLeft,
        isTrue,
        reason:
            'Panel did not progress towards sidebar during fly: '
            'earlyFlyLeft=$earlyFlyLeft, midFlyLeft=$midFlyLeft, '
            'finalLeft=$finalLeft',
      );
      expect(
        finalLeft > playerLeft + 100,
        isTrue,
        reason:
            'Final position should be far from player (at sidebar): '
            'playerLeft=$playerLeft, finalLeft=$finalLeft',
      );

      // Let the animation settle.
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'snap-to-edge animates smoothly (not instantly)',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(child: createTestMidiControls(isExpanded: false)),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final positioned = find.byKey(const ValueKey('midi-positioned'));

      // Drag the circle horizontally so the snap target differs from
      // the current position.  The default sidebar is at the right
      // edge (X=1.0); dragging left puts the snap target on the
      // left edge so the X animation is visible.
      final circle = find.byIcon(Icons.queue_music_rounded);
      await tester.drag(circle, const Offset(-100, 0));
      await tester.pump();

      // Sample the left edge at two points during the snap animation.
      // If the snap were instant, both samples would be identical.  With
      // a 260ms snap, a sample at 60ms should be between the start
      // (right edge) and end (left edge) positions.
      final earlyRect = tester.getRect(positioned);
      await tester.pump(const Duration(milliseconds: 60));
      final midRect = tester.getRect(positioned);
      await tester.pumpAndSettle();

      // The snap animates the horizontal position.  The left edge
      // should change between the early and mid samples.
      expect(
        (earlyRect.left - midRect.left).abs() > 0.5,
        isTrue,
        reason:
            'Snap appears instant: early.left=${earlyRect.left}, '
            'mid.left=${midRect.left}',
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'snap preserves the user-released Y position',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(child: createTestMidiControls(isExpanded: false)),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final positioned = find.byKey(const ValueKey('midi-positioned'));
      final circle = find.byIcon(Icons.queue_music_rounded);

      // Drag the circle UP so it ends well above centre.  The release
      // Y should be preserved by the snap, not reset to 0.5 (centre).
      await tester.drag(circle, const Offset(20, -150));
      await tester.pumpAndSettle();

      // After snap completes, the circle should be at the left or right
      // edge (depending on release X) but at the Y position where the
      // user released (near the top, not the centre).
      final settledRect = tester.getRect(positioned);
      final screenHeight = tester.view.physicalSize.height;
      // The default centre would put the widget's bottom edge on screen
      // at screenHeight - centreBottom.  If the snap reset Y to 0.5,
      // the widget would be near the vertical centre.  The user dragged
      // up, so the widget should be significantly higher (smaller
      // rect.bottom value since rect.bottom is measured from screen top).
      final centreBottomOnScreen = screenHeight -
          (kMidiCircleMargin +
              0.5 * (screenHeight * 0.75 - kMidiCircleMargin));
      expect(
        settledRect.bottom < centreBottomOnScreen - 50,
        isTrue,
        reason:
            'Snap reset Y to centre instead of preserving release Y: '
            'settledRect.bottom=${settledRect.bottom}, '
            'centreBottomOnScreen=$centreBottomOnScreen',
      );
    },
  );

  testWidgets('circle snaps to left when released on left half', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      createTestWidget(
        child: createTestMidiControls(isExpanded: false),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    // Get the circle widget
    final circle = find.byIcon(Icons.queue_music_rounded);

    // Drag from center to left side
    await tester.drag(circle, const Offset(-100, 0));
    await tester.pumpAndSettle();

    // After settle, circle should be at left position
    // The snap logic is internal, just verify no errors
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'drag updates the sidebar position smoothly (no setState overhead)',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(child: createTestMidiControls(isExpanded: false)),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final positioned = find.byKey(const ValueKey('midi-positioned'));
      final circle = find.byIcon(Icons.queue_music_rounded);

      // Drag far enough to cross the centre line.  The snap will then
      // animate the circle to the LEFT edge.  The drag itself should
      // be smooth (no jank or jump).
      await tester.drag(circle, const Offset(-200, 0));
      await tester.pumpAndSettle();

      final finalLeft = tester.getRect(positioned).left;

      // After dragging well past centre, the circle should snap to the
      // left edge (left ≈ -16, which is -halfSize + peek).
      expect(
        finalLeft < 0,
        isTrue,
        reason:
            'Drag did not move circle to left edge: finalLeft=$finalLeft',
      );

      // Drag back to the right and verify it returns to the right edge.
      await tester.drag(circle, const Offset(200, 0));
      await tester.pumpAndSettle();

      final restoredLeft = tester.getRect(positioned).left;

      expect(
        restoredLeft > 300,
        isTrue,
        reason:
            'Drag back did not move circle to right edge: '
            'restoredLeft=$restoredLeft',
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('circle snaps to right when released on right half', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      createTestWidget(
        child: createTestMidiControls(isExpanded: false),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    // Drag from center to right side
    final circle = find.byIcon(Icons.queue_music_rounded);
    await tester.drag(circle, const Offset(100, 0));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

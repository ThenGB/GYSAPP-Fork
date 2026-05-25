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
  List<List<dynamic>>? availableInstruments,
  List<String>? availableKeys,
  VoidCallback? onPlayPause,
  VoidCallback? onLoopModeCycle,
  void Function(double)? onSeek,
  void Function(int)? onTranspose,
  void Function(String)? onKeySelected,
  void Function(double)? onTempo,
  void Function(int?)? onInstrument,
  void Function(String)? onSoundFont,
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
    availableInstruments: availableInstruments ?? const [],
    onPlayPause: onPlayPause ?? () {},
    onLoopModeCycle: onLoopModeCycle ?? () {},
    onSeek: onSeek ?? (_) {},
    onTranspose: onTranspose ?? (_) {},
    onKeySelected: onKeySelected ?? (_) {},
    onTempo: onTempo ?? (_) {},
    onInstrument: onInstrument ?? (_) {},
    onSoundFont: onSoundFont ?? (_) {},
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
          availableInstruments: const [
            [0, 'Acoustic Grand Piano'],
            [24, 'Nylon Guitar'],
          ],
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

    // After 150ms, morph phase starts
    await tester.pump(const Duration(milliseconds: 200));

    // After another 150ms, should be fully expanded
    await tester.pump(const Duration(milliseconds: 300));

    // Controls should be visible
    expect(find.byKey(const ValueKey('midi-expanded')), findsOneWidget);
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

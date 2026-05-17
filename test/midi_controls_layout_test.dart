import 'dart:io';

import 'package:church/presentations/song/widgets/draggable_midi_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
      contains('navHeight + bottomInset + kDashboardBodyBottomSafetyGap'),
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
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              DraggableMidiControls(
                isPlaying: false,
                isLoading: false,
                position: 0,
                duration: 180,
                transposeStep: 0,
                currentKey: 'C',
                availableKeys: const ['C', 'D', 'E'],
                tempoBpm: 76,
                availableInstruments: const [
                  [0, 'Acoustic Grand Piano'],
                  [24, 'Nylon Guitar'],
                ],
                onPlayPause: () {},
                onLoopModeCycle: () {},
                onSeek: (_) {},
                onTranspose: (_) {},
                onKeySelected: (_) {},
                onTempo: (_) {},
                onInstrument: (_) {},
                onSoundFont: (_) {},
              ),
            ],
          ),
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
              DraggableMidiControls(
                isPlaying: false,
                isLoading: false,
                position: 0,
                duration: 180,
                transposeStep: 0,
                currentKey: 'C',
                availableKeys: const ['C', 'D', 'E'],
                tempoBpm: 76,
                onPlayPause: () {},
                onLoopModeCycle: () {},
                onSeek: (_) {},
                onTranspose: (_) {},
                onKeySelected: (_) {},
                onTempo: (_) {},
                onInstrument: (_) {},
                onSoundFont: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));
    final panelRect = tester.getRect(
      find.byKey(const ValueKey('midi-expanded')),
    );
    expect(panelRect.bottom, closeTo(640, 0.1));
  });

  testWidgets('midi controls collapse to a draggable side trigger', (
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
              DraggableMidiControls(
                isPlaying: false,
                isLoading: false,
                position: 0,
                duration: 180,
                transposeStep: 0,
                nowPlayingTitle: 'Besar Setia-Mu',
                tempoBpm: 76,
                onPlayPause: () {},
                onLoopModeCycle: () {},
                onSeek: (_) {},
                onTranspose: (_) {},
                onKeySelected: (_) {},
                onTempo: (_) {},
                onInstrument: (_) {},
                onSoundFont: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('midi-collapse-toggle')));
    await tester.pump(const Duration(milliseconds: 300));

    final collapsed = find.byKey(const ValueKey('midi-collapsed'));
    final collapsedRect = tester.getRect(collapsed);
    expect(collapsedRect.height, closeTo(kMidiSidebarBarHeight, 0.1));
    expect(collapsedRect.width, closeTo(kMidiSidebarBarWidth, 0.1));
    expect(collapsedRect.top, closeTo(200, 0.1));
    expect(collapsedRect.right, closeTo(360, 0.1));
    expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
  });

  testWidgets('repeat control cycles loop mode instead of stopping playback', (
    tester,
  ) async {
    var cycleCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              DraggableMidiControls(
                isPlaying: false,
                isLoading: false,
                position: 0,
                duration: 180,
                transposeStep: 0,
                tempoBpm: 76,
                onPlayPause: () {},
                onLoopModeCycle: () => cycleCount++,
                onSeek: (_) {},
                onTranspose: (_) {},
                onKeySelected: (_) {},
                onTempo: (_) {},
                onInstrument: (_) {},
                onSoundFont: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));
    final loopButton = find.byTooltip('Loop off');
    await tester.ensureVisible(loopButton);
    await tester.tap(loopButton, warnIfMissed: false);
    await tester.pump();

    expect(cycleCount, 1);
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
                  DraggableMidiControls(
                    isPlaying: false,
                    isLoading: false,
                    position: position,
                    duration: 180,
                    transposeStep: 0,
                    tempoBpm: 76,
                    onPlayPause: () {},
                    onLoopModeCycle: () {},
                    onSeek: (value) {
                      seekedTo = value;
                      setOuterState(() => position = value);
                    },
                    onTranspose: (_) {},
                    onKeySelected: (_) {},
                    onTempo: (_) {},
                    onInstrument: (_) {},
                    onSoundFont: (_) {},
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
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                DraggableMidiControls(
                  isPlaying: false,
                  isLoading: false,
                  position: 0,
                  duration: 180,
                  transposeStep: 0,
                  currentKey: 'Eb',
                  tempoBpm: 76,
                  onPlayPause: () {},
                  onLoopModeCycle: () {},
                  onSeek: (_) {},
                  onTranspose: (_) {},
                  onKeySelected: (_) {},
                  onTempo: (_) {},
                  onInstrument: (_) {},
                  onSoundFont: (_) {},
                ),
              ],
            ),
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

  testWidgets('transpose popup wraps out-of-range values to zero', (tester) async {
    int? lastTranspose;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              DraggableMidiControls(
                isPlaying: false,
                isLoading: false,
                position: 0,
                duration: 180,
                transposeStep: 0,
                tempoBpm: 76,
                onPlayPause: () {},
                onLoopModeCycle: () {},
                onSeek: (_) {},
                onTranspose: (value) => lastTranspose = value,
                onKeySelected: (_) {},
                onTempo: (_) {},
                onInstrument: (_) {},
                onSoundFont: (_) {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    Future<void> submitTranspose(String value) async {
      await tester.tap(find.byKey(const ValueKey('midi-transpose-field')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextField), value);
      await tester.tap(find.text('Simpan'));
      await tester.pump(const Duration(milliseconds: 300));
    }

    await submitTranspose('12');
    expect(lastTranspose, 0);

    await submitTranspose('-12');
    expect(lastTranspose, 0);

    await submitTranspose('-11');
    expect(lastTranspose, -11);

    await submitTranspose('11');
    expect(lastTranspose, 11);
  });
}

import 'package:church/presentations/song/widgets/draggable_midi_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
                onStop: () {},
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

    await tester.tap(find.text('Now Playing'), warnIfMissed: true);
    await tester.pumpAndSettle();

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
                onStop: () {},
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

    final panelRect = tester.getRect(
      find.byKey(const ValueKey('midi-expanded')),
    );
    expect(panelRect.bottom, closeTo(640, 0.1));
  });

  testWidgets('midi controls collapse to a compact Stitch mini bar', (
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
                onStop: () {},
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

    await tester.tap(find.byKey(const ValueKey('midi-collapse-toggle')));
    await tester.pumpAndSettle();

    final collapsed = find.byKey(const ValueKey('midi-collapsed'));
    final collapsedRect = tester.getRect(collapsed);
    expect(collapsedRect.bottom, closeTo(640, 0.1));
    expect(collapsedRect.height, lessThanOrEqualTo(52));
    expect(collapsedRect.width, lessThanOrEqualTo(220));
    expect(collapsedRect.right, closeTo(344, 0.1));
    expect(find.textContaining('Besar Setia-Mu'), findsOneWidget);
    expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
  });
}

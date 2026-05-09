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
}

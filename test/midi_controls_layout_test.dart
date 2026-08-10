import 'package:church/data/services/chord_service.dart';
import 'package:church/presentations/song/widgets/draggable_midi_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _midiControls({
  bool isExpanded = true,
  double position = 0,
  String chordAccidentalMode = ChordService.accidentalSharp,
  VoidCallback? onToggleAccidental,
  ValueChanged<double>? onSeek,
}) {
  return DraggableMidiControls(
    isPlaying: false,
    isLoading: false,
    position: position,
    duration: 180,
    transposeStep: 0,
    currentKey: 'C',
    availableKeys: const ['C', 'D', 'E'],
    tempoBpm: 76,
    onPlayPause: () {},
    onLoopModeCycle: () {},
    onSeek: onSeek ?? (_) {},
    onTranspose: (_) {},
    onKeySelected: (_) {},
    onTempo: (_) {},
    isExpanded: isExpanded,
    chordAccidentalMode: chordAccidentalMode,
    onToggleAccidental: onToggleAccidental,
  );
}

Widget _testApp(Widget child) => MaterialApp(
  home: Scaffold(body: Stack(children: [child])),
);

void main() {
  test('MIDI player retains its complete animation state machine', () {
    expect(MidiPlayerAnimationState.values.length, 6);
    expect(MidiPlayerAnimationState.sidebar_circle.index, 0);
    expect(MidiPlayerAnimationState.expanded_player.index, 3);
  });

  testWidgets('expanded controls fit a compact screen', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_testApp(_midiControls()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('midi-expanded')), findsOneWidget);
    expect(find.byKey(const ValueKey('midi-transpose-field')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MIDI owns one sharp/flat toggle and updates it', (tester) async {
    var mode = ChordService.accidentalSharp;
    var toggleCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Stack(
              children: [
                _midiControls(
                  chordAccidentalMode: mode,
                  onToggleAccidental: () {
                    toggleCount++;
                    setState(() {
                      mode = mode == ChordService.accidentalSharp
                          ? ChordService.accidentalFlat
                          : ChordService.accidentalSharp;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final toggle = find.byKey(const ValueKey('midi-accidental-toggle'));
    expect(toggle, findsOneWidget);
    expect(find.text('♯'), findsOneWidget);

    await tester.tap(toggle);
    await tester.pump(const Duration(milliseconds: 200));

    expect(toggleCount, 1);
    expect(find.text('♭'), findsOneWidget);
    expect(find.byKey(const ValueKey('midi-accidental-toggle')), findsOneWidget);
  });

  testWidgets('seek acknowledgement can update the parent safely', (
    tester,
  ) async {
    var position = 0.0;
    double? seekedTo;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Stack(
              children: [
                _midiControls(
                  position: position,
                  onSeek: (value) {
                    seekedTo = value;
                    setState(() => position = value);
                  },
                ),
              ],
            ),
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
}

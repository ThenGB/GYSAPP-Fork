import 'dart:typed_data';

import 'package:church/data/services/native_midi/midi_render_settings.dart';
import 'package:church/data/services/native_midi/midi_tempo_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MidiTempoDetector', () {
    test('detects the first MIDI set-tempo event as BPM', () {
      final midi = Uint8List.fromList([
        ...'MThd'.codeUnits,
        0x00,
        0x00,
        0x00,
        0x06,
        0x00,
        0x00,
        0x00,
        0x01,
        0x01,
        0xE0,
        ...'MTrk'.codeUnits,
        0x00,
        0x00,
        0x00,
        0x0B,
        0x00,
        0xFF,
        0x51,
        0x03,
        0x07,
        0xA1,
        0x20,
        0x00,
        0xFF,
        0x2F,
        0x00,
      ]);

      expect(MidiTempoDetector.detectBpm(midi), 120);
    });

    test('falls back when a MIDI file has no tempo event', () {
      final midi = Uint8List.fromList([
        ...'MThd'.codeUnits,
        0x00,
        0x00,
        0x00,
        0x06,
        0x00,
        0x00,
        0x00,
        0x01,
        0x01,
        0xE0,
        ...'MTrk'.codeUnits,
        0x00,
        0x00,
        0x00,
        0x04,
        0x00,
        0xFF,
        0x2F,
        0x00,
      ]);

      expect(MidiTempoDetector.detectBpm(midi, fallbackBpm: 76), 76);
    });
  });

  group('MidiRenderSettings', () {
    test('clamps musical controls to supported ranges', () {
      const settings = MidiRenderSettings(
        transpose: 24,
        tempoBpm: 500,
        baseTempoBpm: 10,
        instrument: 400,
        soundFont: 'GeneralUser-GS.sf2',
      );

      expect(settings.normalized.transpose, 12);
      expect(settings.normalized.tempoBpm, 220);
      expect(settings.normalized.baseTempoBpm, 30);
      expect(settings.normalized.instrument, 127);
      expect(settings.normalized.soundFont, 'GeneralUser-GS.sf2');
    });

    test('maps tempo to a rate against detected base tempo', () {
      const settings = MidiRenderSettings(
        tempoBpm: 114,
        baseTempoBpm: 76,
        soundFont: 'GeneralUser-GS.sf2',
      );

      expect(settings.tempoRate, closeTo(1.5, 0.0001));
    });
  });
}

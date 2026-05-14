import 'dart:io';
import 'dart:typed_data';

import 'package:church/data/services/midi_engine_service.dart';
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
        soundFont: 'TimGM6mb.sf2',
      );

      expect(settings.normalized.transpose, 12);
      expect(settings.normalized.tempoBpm, 220);
      expect(settings.normalized.baseTempoBpm, 30);
      expect(settings.normalized.instrument, 127);
      expect(settings.normalized.soundFont, 'TimGM6mb.sf2');
    });

    test('maps tempo to a rate against detected base tempo', () {
      const settings = MidiRenderSettings(
        tempoBpm: 114,
        baseTempoBpm: 76,
        soundFont: 'TimGM6mb.sf2',
      );

      expect(settings.tempoRate, closeTo(1.5, 0.0001));
    });
  });

  group('MidiEngineService cache policy', () {
    test('memory pruning keeps rendered wav files as warm disk cache', () {
      final source = File(
        'lib/data/services/midi_engine_service.dart',
      ).readAsStringSync();
      final pruneBody =
          RegExp(
            r'Future<void> _pruneSourceCache\(\) async \{([\s\S]*?)\n  \}',
          ).firstMatch(source)?.group(1) ??
          '';

      expect(pruneBody, isNot(contains('.delete()')));
    });

    test(
      'loadMidi starts buffer-stream autoplay before full render completes',
      () {
        final source = File(
          'lib/data/services/midi_engine_service.dart',
        ).readAsStringSync();
        final loadBody =
            RegExp(
              r'Future<void> loadMidi\([\s\S]*?\n  String _wavCachePath',
            ).firstMatch(source)?.group(0) ??
            '';

        expect(loadBody, contains('setBufferStream'));
        expect(loadBody, contains('addAudioDataStream'));
        final streamIndex = loadBody.indexOf('setBufferStream');
        final awaitRenderIndex = loadBody.indexOf('await renderedFuture');
        final streamAutoplayIndex = loadBody.indexOf(
          'if (autoplay)',
          streamIndex,
        );
        expect(streamIndex, lessThan(awaitRenderIndex));
        expect(streamAutoplayIndex, lessThan(awaitRenderIndex));
      },
    );

    test('seeked stream positions are reported as absolute song positions', () {
      expect(
        MidiEngineService.absoluteSourcePositionSecondsForTest(
          sourcePosition: const Duration(seconds: 7),
          sourceStartOffsetSeconds: 120,
        ),
        127,
      );
      expect(
        MidiEngineService.relativeSourcePositionForTest(
          absoluteSeconds: 127,
          sourceStartOffsetSeconds: 120,
        ),
        const Duration(seconds: 7),
      );
      expect(
        MidiEngineService.relativeSourcePositionForTest(
          absoluteSeconds: 100,
          sourceStartOffsetSeconds: 120,
        ),
        Duration.zero,
      );
    });

    test('seeked streams are not rendered into the full-song cache key', () {
      final source = File(
        'lib/data/services/midi_engine_service.dart',
      ).readAsStringSync();
      final loadBody =
          RegExp(
            r'Future<void> loadMidi\([\s\S]*?\n  Future<void> _finishBackgroundRender',
          ).firstMatch(source)?.group(0) ??
          '';

      expect(loadBody, contains('if (startAt == Duration.zero)'));
      expect(loadBody, isNot(contains('startAt: startAt,')));
    });
  });
}

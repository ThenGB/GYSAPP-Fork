import 'dart:math' as math;

import 'package:dart_melty_soundfont/dart_melty_soundfont.dart';
import 'package:flutter/foundation.dart';

import 'midi_render_settings.dart';

const int nativeMidiSampleRate = 44100;

class RenderedMidiAudio {
  final Uint8List wavBytes;
  final Duration duration;
  final List<List<dynamic>> instruments;

  const RenderedMidiAudio({
    required this.wavBytes,
    required this.duration,
    required this.instruments,
  });
}

class NativeMidiRenderer {
  const NativeMidiRenderer._();

  static Future<RenderedMidiAudio> render({
    required Uint8List midiBytes,
    required Uint8List soundFontBytes,
    required MidiRenderSettings settings,
  }) {
    final normalized = settings.normalized;
    return compute(_renderMidiAudio, {
      'midiBytes': midiBytes,
      'soundFontBytes': soundFontBytes,
      'transpose': normalized.transpose,
      'tempoBpm': normalized.tempoBpm,
      'baseTempoBpm': normalized.baseTempoBpm,
      'instrument': normalized.instrument,
      'soundFont': normalized.soundFont,
    });
  }

  static Future<List<List<dynamic>>> readInstruments(Uint8List soundFontBytes) {
    return compute(_readSoundFontInstruments, soundFontBytes);
  }
}

RenderedMidiAudio _renderMidiAudio(Map<String, dynamic> args) {
  final midiBytes = args['midiBytes'] as Uint8List;
  final soundFontBytes = args['soundFontBytes'] as Uint8List;
  final settings = MidiRenderSettings(
    transpose: args['transpose'] as int? ?? 0,
    tempoBpm: args['tempoBpm'] as double? ?? 76,
    baseTempoBpm: args['baseTempoBpm'] as double? ?? 76,
    instrument: args['instrument'] as int?,
    soundFont: args['soundFont'] as String? ?? 'GeneralUser-GS.sf2',
  ).normalized;

  final synth = Synthesizer.loadByteData(
    ByteData.sublistView(soundFontBytes),
    SynthesizerSettings(
      sampleRate: nativeMidiSampleRate,
      blockSize: 64,
      maximumPolyphony: 128,
      enableReverbAndChorus: true,
    ),
  );
  final midiFile = MidiFile.fromByteData(ByteData.sublistView(midiBytes));
  final sequencer = MidiFileSequencer(synth)
    ..speed = settings.tempoRate
    ..onSendMessage = _messageHook(settings);

  sequencer.play(midiFile, loop: false);

  final estimatedFrames = _estimateRenderedFrames(midiFile, settings.tempoRate);
  final output = BytesBuilder(copy: false);
  final chunkFrames = nativeMidiSampleRate;
  var renderedFrames = 0;
  var tailFrames = nativeMidiSampleRate * 2;

  while (!sequencer.endOfSequence || tailFrames > 0) {
    final frames = math.min(chunkFrames, estimatedFrames - renderedFrames);
    final safeFrames = frames <= 0 ? chunkFrames : frames;
    final buffer = ArrayInt16.zeros(numShorts: safeFrames * 2);
    sequencer.renderInterleavedInt16(buffer);
    output.add(buffer.bytes.buffer.asUint8List());
    renderedFrames += safeFrames;
    if (sequencer.endOfSequence) {
      tailFrames -= safeFrames;
    }
    if (renderedFrames > nativeMidiSampleRate * 60 * 12) {
      break;
    }
  }

  final pcmBytes = output.toBytes();
  return RenderedMidiAudio(
    wavBytes: _encodePcm16Wav(
      pcmBytes,
      sampleRate: nativeMidiSampleRate,
      channels: 2,
    ),
    duration: Duration(
      microseconds:
          ((pcmBytes.length / 4) /
                  nativeMidiSampleRate *
                  Duration.microsecondsPerSecond)
              .round(),
    ),
    instruments: _instrumentsFromSynth(synth),
  );
}

MessageHook _messageHook(MidiRenderSettings settings) {
  final transpose = settings.transpose;
  final instrument = settings.instrument;
  return (synthesizer, channel, command, data1, data2) {
    final isDrum = channel == 9;
    if (!isDrum && instrument != null && command == 0xC0) {
      synthesizer.processMidiMessage(
        channel: channel,
        command: command,
        data1: instrument,
        data2: data2,
      );
      return;
    }

    var nextData1 = data1;
    if (!isDrum && transpose != 0 && (command == 0x80 || command == 0x90)) {
      nextData1 = (data1 + transpose).clamp(0, 127);
    }

    if (!isDrum && instrument != null && command == 0x90 && data2 > 0) {
      synthesizer.processMidiMessage(
        channel: channel,
        command: 0xC0,
        data1: instrument,
        data2: 0,
      );
    }

    synthesizer.processMidiMessage(
      channel: channel,
      command: command,
      data1: nextData1,
      data2: data2,
    );
  };
}

int _estimateRenderedFrames(MidiFile midiFile, double tempoRate) {
  final safeRate = tempoRate <= 0 ? 1 : tempoRate;
  final seconds =
      midiFile.length.inMicroseconds /
      Duration.microsecondsPerSecond /
      safeRate;
  return ((seconds + 2.0) * nativeMidiSampleRate).ceil();
}

List<List<dynamic>> _readSoundFontInstruments(Uint8List soundFontBytes) {
  final synth = Synthesizer.loadByteData(ByteData.sublistView(soundFontBytes));
  return _instrumentsFromSynth(synth);
}

List<List<dynamic>> _instrumentsFromSynth(Synthesizer synth) {
  final seen = <int>{};
  final result = <List<dynamic>>[];
  for (final preset in synth.soundFont.presets) {
    if (preset.bankNumber != 0) continue;
    final program = preset.patchNumber;
    if (program < 0 || program > 127 || !seen.add(program)) continue;
    result.add([program, preset.name]);
  }
  result.sort((a, b) => (a[0] as int).compareTo(b[0] as int));
  return result;
}

Uint8List _encodePcm16Wav(
  Uint8List pcmBytes, {
  required int sampleRate,
  required int channels,
}) {
  final byteRate = sampleRate * channels * 2;
  final blockAlign = channels * 2;
  final output = BytesBuilder(copy: false);
  final header = ByteData(44);

  _writeAscii(header, 0, 'RIFF');
  header.setUint32(4, 36 + pcmBytes.length, Endian.little);
  _writeAscii(header, 8, 'WAVE');
  _writeAscii(header, 12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);
  header.setUint16(22, channels, Endian.little);
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, byteRate, Endian.little);
  header.setUint16(32, blockAlign, Endian.little);
  header.setUint16(34, 16, Endian.little);
  _writeAscii(header, 36, 'data');
  header.setUint32(40, pcmBytes.length, Endian.little);

  output.add(header.buffer.asUint8List());
  output.add(pcmBytes);
  return output.toBytes();
}

void _writeAscii(ByteData data, int offset, String value) {
  for (var i = 0; i < value.length; i++) {
    data.setUint8(offset + i, value.codeUnitAt(i));
  }
}

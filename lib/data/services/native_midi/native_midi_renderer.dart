import 'dart:math' as math;

import 'package:dart_melty_soundfont/dart_melty_soundfont.dart';
import 'package:flutter/foundation.dart';

import 'midi_render_settings.dart';
import 'midi_worker.dart';

const int nativeMidiSampleRate = 32000;

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

  /// Perform a render for the given MIDI.
  /// Uses a persistent MidiWorker for massive performance gains.
  ///
  /// [onProgress] is optional callback (0.0 - 1.0) for progress reporting.
  static Future<RenderedMidiAudio> render({
    required Uint8List midiBytes,
    required Uint8List soundFontBytes,
    required MidiRenderSettings settings,
    bool fastDry = false,
    Duration startAt = Duration.zero,
    void Function(double)? onProgress,
  }) {
    // Use persistent MidiWorker for massive performance gains.
    return MidiWorker().render(
      midiBytes: midiBytes,
      soundFontBytes: soundFontBytes,
      soundFontName: settings.soundFont,
      settings: settings.normalized,
      fastDry: fastDry,
      startAt: startAt,
      onProgress: onProgress,
    );
  }

  static RenderedMidiAudio renderWithParsedComponents({
    required MidiFile midiFile,
    required Synthesizer synth,
    required MidiRenderSettings settings,
    Duration startAt = Duration.zero,
  }) {
    return _renderMidiAudioWithParsedComponents(
      midiFile,
      synth,
      settings,
      startAt: startAt,
    );
  }

  static RenderedMidiAudio renderWithSoundFont({
    required Uint8List midiBytes,
    required SoundFont soundFont,
    required MidiRenderSettings settings,
    bool fastDry = false,
    Duration startAt = Duration.zero,
  }) {
    return _renderMidiAudioWithParsedSF(
      midiBytes,
      soundFont,
      settings,
      fastDry: fastDry,
      startAt: startAt,
    );
  }

  static Future<List<List<dynamic>>> readInstruments(Uint8List soundFontBytes) {
    return compute(_readSoundFontInstruments, soundFontBytes);
  }

  static List<List<dynamic>> getInstrumentsFromSynth(Synthesizer synth) {
    return _instrumentsFromSynth(synth);
  }

  static MessageHook messageHookForSettings(MidiRenderSettings settings) {
    return _messageHook(settings);
  }
}

RenderedMidiAudio _renderMidiAudioWithParsedComponents(
  MidiFile midiFile,
  Synthesizer synth,
  MidiRenderSettings settings, {
  Duration startAt = Duration.zero,
}) {
  final sequencer = MidiFileSequencer(synth)
    ..speed = settings.tempoRate
    ..onSendMessage = _messageHook(settings);

  sequencer.play(midiFile, loop: false);

  // Fast-forward to the requested start point
  if (startAt > Duration.zero) {
    sequencer.seek(startAt);
  }

  final remainingSeconds =
      (midiFile.length - sequencer.position).inMicroseconds /
      1000000 /
      settings.tempoRate;
  final estimatedRemainingFrames =
      ((remainingSeconds + 2.0) * nativeMidiSampleRate).ceil();

  // Pre-allocate buffer for remaining audio
  final totalBytes = estimatedRemainingFrames * 4;
  final pcmBuffer = Uint8List(totalBytes);

  var renderedFrames = 0;
  var tailFrames = nativeMidiSampleRate * 2;

  while (!sequencer.endOfSequence || tailFrames > 0) {
    final framesToRender = math.min(
      nativeMidiSampleRate,
      estimatedRemainingFrames - renderedFrames,
    );
    if (framesToRender <= 0) break;

    final numShorts = framesToRender * 2;
    final buffer = ArrayInt16(
      bytes: pcmBuffer.buffer.asByteData(renderedFrames * 4, numShorts * 2),
    );

    sequencer.renderInterleavedInt16(buffer);

    renderedFrames += framesToRender;
    if (sequencer.endOfSequence) {
      tailFrames -= framesToRender;
    }

    if (renderedFrames > nativeMidiSampleRate * 60 * 15) break;
  }

  final finalPcmBytes = pcmBuffer.sublist(0, renderedFrames * 4);

  return RenderedMidiAudio(
    wavBytes: _encodePcm16Wav(
      finalPcmBytes,
      sampleRate: nativeMidiSampleRate,
      channels: 2,
    ),
    duration: Duration(
      microseconds:
          ((finalPcmBytes.length / 4) /
                  nativeMidiSampleRate *
                  Duration.microsecondsPerSecond)
              .round(),
    ),
    instruments: _instrumentsFromSynth(synth),
  );
}

RenderedMidiAudio _renderMidiAudioWithParsedSF(
  Uint8List midiBytes,
  SoundFont soundFont,
  MidiRenderSettings settings, {
  bool fastDry = false,
  Duration startAt = Duration.zero,
}) {
  final synth = Synthesizer.load(
    soundFont,
    SynthesizerSettings(
      sampleRate: nativeMidiSampleRate,
      blockSize: 128,
      maximumPolyphony: 64,
      enableReverbAndChorus: !fastDry,
    ),
  );
  final midiFile = MidiFile.fromByteData(ByteData.sublistView(midiBytes));
  return _renderMidiAudioWithParsedComponents(
    midiFile,
    synth,
    settings,
    startAt: startAt,
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

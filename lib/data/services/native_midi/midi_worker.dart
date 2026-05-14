import 'dart:async';
import 'dart:isolate';
import 'package:dart_melty_soundfont/dart_melty_soundfont.dart';
import 'midi_render_settings.dart';
import 'native_midi_renderer.dart';

/// Commands for the background MIDI worker isolate.
enum MidiWorkerCommand {
  loadSoundFont,
  render,
  startStream,
  fillStream,
  seekStream,
  shutdown,
}

class MidiWorkerRequest {
  final MidiWorkerCommand command;
  final Uint8List? soundFontBytes;
  final String? soundFontName;
  final Uint8List? midiBytes;
  final MidiRenderSettings? settings;
  final bool fastDry;
  final int? streamFrames;
  final double? seekSeconds;

  MidiWorkerRequest({
    required this.command,
    this.soundFontBytes,
    this.soundFontName,
    this.midiBytes,
    this.settings,
    this.fastDry = false,
    this.streamFrames,
    this.seekSeconds,
  });
}

class MidiWorkerResponse {
  final Uint8List? wavBytes;
  final Float32List? leftBuf;
  final Float32List? rightBuf;
  final Duration? duration;
  final List<List<dynamic>>? instruments;
  final bool streamEnded;
  final String? error;

  MidiWorkerResponse({
    this.wavBytes,
    this.leftBuf,
    this.rightBuf,
    this.duration,
    this.instruments,
    this.streamEnded = false,
    this.error,
  });
}

class MidiStreamStartResult {
  final List<List<dynamic>> instruments;
  final Duration duration;

  const MidiStreamStartResult({
    required this.instruments,
    required this.duration,
  });
}

/// A persistent background worker for high-performance MIDI rendering and streaming.
class MidiWorker {
  static final MidiWorker _instance = MidiWorker._internal();
  factory MidiWorker() => _instance;
  MidiWorker._internal();

  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;

  Completer<void>? _initCompleter;
  String? _loadedSoundFontName;

  Future<void> _ensureInitialized() async {
    if (_isolate != null) return;
    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer<void>();
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_workerMain, _receivePort!.sendPort);
    _sendPort = await _receivePort!.first as SendPort;

    _initCompleter!.complete();
    _initCompleter = null;
  }

  Future<void> prepareSoundFont(Uint8List bytes, String name) async {
    await _ensureInitialized();
    if (_loadedSoundFontName == name) return;

    final responsePort = ReceivePort();
    _sendPort!.send([
      responsePort.sendPort,
      MidiWorkerRequest(
        command: MidiWorkerCommand.loadSoundFont,
        soundFontBytes: bytes,
        soundFontName: name,
      ),
    ]);
    final response = await responsePort.first as MidiWorkerResponse;
    if (response.error != null) throw Exception(response.error);
    _loadedSoundFontName = name;
  }

  Future<RenderedMidiAudio> render({
    required Uint8List midiBytes,
    required Uint8List soundFontBytes,
    required String soundFontName,
    required MidiRenderSettings settings,
    bool fastDry = false,
    Duration startAt = Duration.zero,
    void Function(double)? onProgress,
  }) async {
    await prepareSoundFont(soundFontBytes, soundFontName);

    // Report initial progress
    onProgress?.call(0.1);

    final responsePort = ReceivePort();
    _sendPort!.send([
      responsePort.sendPort,
      MidiWorkerRequest(
        command: MidiWorkerCommand.render,
        midiBytes: midiBytes,
        settings: settings,
        fastDry: fastDry,
        seekSeconds: startAt.inMilliseconds / 1000.0,
      ),
    ]);

    // Report mid progress while waiting
    onProgress?.call(0.5);

    final renderResponse = await responsePort.first as MidiWorkerResponse;
    if (renderResponse.error != null) throw Exception(renderResponse.error);

    // Report completion
    onProgress?.call(1.0);

    return RenderedMidiAudio(
      wavBytes: renderResponse.wavBytes!,
      duration: renderResponse.duration!,
      instruments: renderResponse.instruments!,
    );
  }

  /// Start a streaming session for a MIDI file.
  Future<MidiStreamStartResult> startStream({
    required Uint8List midiBytes,
    required MidiRenderSettings settings,
    bool fastDry = false,
  }) async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort!.send([
      responsePort.sendPort,
      MidiWorkerRequest(
        command: MidiWorkerCommand.startStream,
        midiBytes: midiBytes,
        settings: settings,
        fastDry: fastDry,
      ),
    ]);
    final response = await responsePort.first as MidiWorkerResponse;
    if (response.error != null) throw Exception(response.error);
    return MidiStreamStartResult(
      instruments: response.instruments!,
      duration: response.duration!,
    );
  }

  /// Request the next chunk of audio from the active stream.
  Future<({Float32List left, Float32List right, bool isEnded})> fillStream(
    int frames,
  ) async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort!.send([
      responsePort.sendPort,
      MidiWorkerRequest(
        command: MidiWorkerCommand.fillStream,
        streamFrames: frames,
      ),
    ]);
    final response = await responsePort.first as MidiWorkerResponse;
    if (response.error != null) throw Exception(response.error);
    return (
      left: response.leftBuf!,
      right: response.rightBuf!,
      isEnded: response.streamEnded,
    );
  }

  /// Seek the active stream to a specific position.
  Future<void> seekStream(double seconds) async {
    await _ensureInitialized();
    final responsePort = ReceivePort();
    _sendPort!.send([
      responsePort.sendPort,
      MidiWorkerRequest(
        command: MidiWorkerCommand.seekStream,
        seekSeconds: seconds,
      ),
    ]);
    final response = await responsePort.first as MidiWorkerResponse;
    if (response.error != null) throw Exception(response.error);
  }

  void dispose() {
    _isolate?.kill();
    _isolate = null;
    _sendPort = null;
    _receivePort?.close();
    _receivePort = null;
    _loadedSoundFontName = null;
  }

  static void _workerMain(SendPort mainSendPort) {
    final workerReceivePort = ReceivePort();
    mainSendPort.send(workerReceivePort.sendPort);

    SoundFont? activeSoundFont;
    Synthesizer? activeSynth;
    MidiFileSequencer? activeSequencer;

    // Cache parsed MIDI files to avoid re-parsing
    final Map<int, MidiFile> midiCache = {};

    workerReceivePort.listen((message) {
      final replyPort = message[0] as SendPort;
      final request = message[1] as MidiWorkerRequest;

      try {
        switch (request.command) {
          case MidiWorkerCommand.loadSoundFont:
            activeSoundFont = SoundFont.fromByteData(
              ByteData.sublistView(request.soundFontBytes!),
            );
            // Clear synth so it's recreated with the new soundfont
            activeSynth = null;
            replyPort.send(MidiWorkerResponse());
            break;

          case MidiWorkerCommand.render:
            if (activeSoundFont == null) {
              replyPort.send(MidiWorkerResponse(error: 'No SoundFont loaded'));
              return;
            }

            if (activeSynth == null) {
              activeSynth = Synthesizer.load(
                activeSoundFont!,
                SynthesizerSettings(
                  sampleRate: nativeMidiSampleRate,
                  blockSize: 512,
                  maximumPolyphony: 64,
                  enableReverbAndChorus: !request.fastDry,
                ),
              );
            } else {
              activeSynth!.reset();
            }

            final midiHash = request.midiBytes!.length ^ request.midiBytes![0];
            final midiFile = midiCache.putIfAbsent(
              midiHash,
              () => MidiFile.fromByteData(
                ByteData.sublistView(request.midiBytes!),
              ),
            );

            final rendered = NativeMidiRenderer.renderWithParsedComponents(
              midiFile: midiFile,
              synth: activeSynth!,
              settings: request.settings!,
              startAt: Duration(
                milliseconds: ((request.seekSeconds ?? 0) * 1000).round(),
              ),
            );

            replyPort.send(
              MidiWorkerResponse(
                wavBytes: rendered.wavBytes,
                duration: rendered.duration,
                instruments: rendered.instruments,
              ),
            );
            break;

          case MidiWorkerCommand.startStream:
            if (activeSoundFont == null) {
              replyPort.send(MidiWorkerResponse(error: 'No SoundFont loaded'));
              return;
            }
            final synth = Synthesizer.load(
              activeSoundFont!,
              SynthesizerSettings(
                sampleRate: nativeMidiSampleRate,
                blockSize: 512,
                maximumPolyphony: 64,
                enableReverbAndChorus: !request.fastDry,
              ),
            );
            final midiFile = MidiFile.fromByteData(
              ByteData.sublistView(request.midiBytes!),
            );
            activeSequencer = MidiFileSequencer(synth)
              ..speed = request.settings!.tempoRate
              ..onSendMessage = NativeMidiRenderer.messageHookForSettings(
                request.settings!,
              );
            activeSequencer!.play(midiFile, loop: false);

            replyPort.send(
              MidiWorkerResponse(
                instruments: NativeMidiRenderer.getInstrumentsFromSynth(synth),
                duration: Duration(
                  microseconds:
                      (midiFile.length.inMicroseconds /
                              request.settings!.tempoRate)
                          .round(),
                ),
              ),
            );
            break;

          case MidiWorkerCommand.fillStream:
            if (activeSequencer == null) {
              replyPort.send(MidiWorkerResponse(error: 'No active stream'));
              return;
            }
            final frames = request.streamFrames!;
            final left = Float32List(frames);
            final right = Float32List(frames);
            activeSequencer!.render(left, right);
            replyPort.send(
              MidiWorkerResponse(
                leftBuf: left,
                rightBuf: right,
                streamEnded: activeSequencer!.endOfSequence,
              ),
            );
            break;

          case MidiWorkerCommand.seekStream:
            if (activeSequencer == null) {
              replyPort.send(MidiWorkerResponse(error: 'No active stream'));
              return;
            }
            final target = Duration(
              milliseconds: (request.seekSeconds! * 1000).round(),
            );
            final midiFile = activeSequencer!.midiFile;
            if (midiFile != null) {
              activeSequencer!.play(midiFile, loop: false);
              activeSequencer!.seek(target);
            }
            replyPort.send(MidiWorkerResponse());
            break;

          case MidiWorkerCommand.shutdown:
            Isolate.current.kill();
            break;
        }
      } catch (e) {
        replyPort.send(MidiWorkerResponse(error: e.toString()));
      }
    });
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'local_asset_service.dart';

class MidiPlaybackState {
  final bool isPlaying;
  final double position;
  final double duration;
  final bool isLoading;
  final double loadProgress;
  final String? currentSong;

  const MidiPlaybackState({
    this.isPlaying = false,
    this.position = 0,
    this.duration = 0,
    this.isLoading = false,
    this.loadProgress = 0,
    this.currentSong,
  });
}

class MidiEngineService extends ChangeNotifier {
  final LocalAssetService _assetService;

  InAppWebViewController? _controller;
  bool _initialized = false;
  bool _webEngineReady = false;
  bool _disposed = false;
  final List<String> _pendingJsCalls = [];
  Timer? _engineReadyTimeout;

  MidiPlaybackState _state = const MidiPlaybackState();

  List<List<dynamic>> _instruments = [];
  List<List<dynamic>> get instruments =>
      _instruments.isEmpty ? _generalMidiInstruments : _instruments;

  final _stateController = StreamController<MidiPlaybackState>.broadcast();
  Stream<MidiPlaybackState> get stateStream => _stateController.stream;

  MidiPlaybackState get state => _state;
  bool get isInitialized => _initialized;

  MidiEngineService(this._assetService);

  Future<List<String>> getAvailableSoundFonts() {
    return _assetService.getAvailableSoundFonts();
  }

  bool isCurrentSong(String midiPath) => _state.currentSong == midiPath;

  Future<void> initialize() async {
    if (_initialized) return;

    _initialized = true;
    log('MidiEngineService initialized', name: 'MidiEngine');
  }

  void onWebViewCreated(InAppWebViewController controller) {
    _controller = controller;
    _webEngineReady = false;

    controller.addJavaScriptHandler(
      handlerName: 'midiStateChanged',
      callback: (args) {
        final data = args[0] as Map<String, dynamic>?;
        if (data != null) {
          _updateState(data);
        }
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'midiProgress',
      callback: (args) {
        final progress = (args[0] as num?)?.toDouble() ?? 0;
        _state = MidiPlaybackState(
          isPlaying: _state.isPlaying,
          position: _state.position,
          duration: _state.duration,
          isLoading: true,
          loadProgress: progress,
          currentSong: _state.currentSong,
        );
        _emitState();
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'midiReady',
      callback: (args) {
        _webEngineReady = true;
        _engineReadyTimeout?.cancel();
        _engineReadyTimeout = null;
        log('MIDI engine WebView bridge ready', name: 'MidiEngine');
        _flushPendingJsCalls();
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'midiError',
      callback: (args) {
        final message = args.isEmpty ? 'Unknown MIDI error' : '${args.first}';
        log('MIDI JS error: $message', name: 'MidiEngine');
        _state = MidiPlaybackState(
          isPlaying: false,
          position: _state.position,
          duration: _state.duration,
          isLoading: false,
          loadProgress: _state.loadProgress,
          currentSong: _state.currentSong,
        );
        _emitState();
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'midiSongEnd',
      callback: (args) {
        log('MIDI song ended', name: 'MidiEngine');
        _state = MidiPlaybackState(
          isPlaying: false,
          position: _state.position,
          duration: _state.duration,
          isLoading: false,
          loadProgress: _state.loadProgress,
          currentSong: _state.currentSong,
        );
        _emitState();
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'midiInstrumentsUpdated',
      callback: (args) {
        final list = args.isNotEmpty ? args.first : null;
        if (list is List) {
          _instruments = list
              .whereType<List>()
              .where((entry) => entry.length >= 2)
              .map((entry) => <dynamic>[
                    entry[0] is num
                        ? (entry[0] as num).toInt()
                        : int.tryParse(entry[0].toString()) ?? -1,
                    entry[1].toString(),
                  ])
              .where((entry) => entry[0] >= 0)
              .toList();
          log('Instruments updated: ${_instruments.length} presets',
              name: 'MidiEngine');
          if (!_disposed) notifyListeners();
        }
      },
    );
  }

  void _updateState(Map<String, dynamic> data) {
    _state = MidiPlaybackState(
      isPlaying:
          data['isPlaying'] as bool? ?? data['playing'] as bool? ?? false,
      position: (data['position'] as num?)?.toDouble() ??
          (data['time'] as num?)?.toDouble() ??
          0,
      duration: (data['duration'] as num?)?.toDouble() ?? 0,
      isLoading:
          data['isLoading'] as bool? ?? data['loading'] as bool? ?? false,
      loadProgress:
          (data['loadProgress'] as num?)?.toDouble() ?? _state.loadProgress,
      currentSong: _state.currentSong,
    );
    _emitState();
  }

  Future<void> initializeWebEngine(String soundFontFileUrl) async {
    _engineReadyTimeout?.cancel();
    _engineReadyTimeout = Timer(const Duration(seconds: 30), () {
      if (!_webEngineReady && !_disposed) {
        log('MIDI engine init timed out - flushing pending calls anyway',
            name: 'MidiEngine');
        _webEngineReady = true;
        _flushPendingJsCalls();
      }
    });

    // Init must bypass the _webEngineReady check to avoid circular wait
    if (_controller != null && !_disposed) {
      try {
        await _controller!.evaluateJavascript(source:
            'window.FlutterMidiBridge && window.FlutterMidiBridge.init(${jsonEncode(soundFontFileUrl)});');
      } catch (e) {
        log('JS init call failed: $e', name: 'MidiEngine');
      }
    }
  }

  Future<void> loadMidi(
    String midiPath, {
    int transpose = 0,
    double tempoBpm = 76,
    int? instrument,
    bool autoplay = false,
  }) async {
    if (_state.currentSong == midiPath && !_state.isLoading) {
      await setTranspose(transpose);
      await setTempo(tempoBpm);
      await setInstrument(instrument ?? -1);
      if (autoplay) {
        await play();
      }
      return;
    }

    _state = MidiPlaybackState(
      isPlaying: false,
      position: 0,
      duration: _state.duration,
      isLoading: true,
      loadProgress: 0,
      currentSong: midiPath,
    );
    _emitState();

    final base64Data = await _midiToBase64(midiPath);

    await _callJs('''
      if (window.FlutterMidiBridge) {
        window.FlutterMidiBridge.loadMidiFromBase64(${jsonEncode(base64Data)}, {
          transpose: $transpose,
          tempoBpm: $tempoBpm,
          instrument: ${instrument ?? -1},
          autoplay: $autoplay
        });
      }
    ''');
  }

  Future<String> _midiToBase64(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    return base64Encode(bytes);
  }

  Future<void> play() async {
    await _callJs('window.FlutterMidiBridge.play();');
    _state = MidiPlaybackState(
      isPlaying: true,
      position: _state.position,
      duration: _state.duration,
      isLoading: _state.isLoading,
      loadProgress: _state.loadProgress,
      currentSong: _state.currentSong,
    );
    _emitState();
  }

  Future<void> pause() async {
    await _callJs('window.FlutterMidiBridge.pause();');
    _state = MidiPlaybackState(
      isPlaying: false,
      position: _state.position,
      duration: _state.duration,
      isLoading: _state.isLoading,
      loadProgress: _state.loadProgress,
      currentSong: _state.currentSong,
    );
    _emitState();
  }

  Future<void> stop() async {
    await _callJs('window.FlutterMidiBridge.stop();');
    _state = const MidiPlaybackState();
    _emitState();
  }

  Future<void> seek(double seconds) async {
    await _callJs('window.FlutterMidiBridge.seek($seconds);');
    _state = MidiPlaybackState(
      isPlaying: _state.isPlaying,
      position: seconds.clamp(0, _state.duration).toDouble(),
      duration: _state.duration,
      isLoading: _state.isLoading,
      loadProgress: _state.loadProgress,
      currentSong: _state.currentSong,
    );
    _emitState();
  }

  Future<void> setTranspose(int semitones) async {
    await _callJs('window.FlutterMidiBridge.setTranspose($semitones);');
  }

  Future<void> setTempo(double bpm) async {
    await _callJs('window.FlutterMidiBridge.setTempoBpm($bpm);');
  }

  Future<void> setInstrument(int program) async {
    await _callJs('window.FlutterMidiBridge.setInstrument($program);');
  }

  Future<void> changeSoundFont(String soundFontFileUrl) async {
    _instruments = [];
    if (!_disposed) notifyListeners();
    await _callJs(
      'window.FlutterMidiBridge.changeSoundFont(${jsonEncode(soundFontFileUrl)});',
    );
  }

  Future<void> setVolume(double volume) async {
    await _callJs('window.FlutterMidiBridge.setVolume($volume);');
  }

  Future<void> preload(
    String midiPath, {
    int transpose = 0,
    int? instrument,
  }) async {
    final base64Data = await _midiToBase64(midiPath);
    await _callJs(
      'window.FlutterMidiBridge && window.FlutterMidiBridge.preloadFromBase64(${jsonEncode(base64Data)}, $transpose, ${instrument ?? -1});',
    );
  }

  Future<void> _callJs(String jsCode) async {
    if (_disposed) return;
    if (_controller == null) {
      _pendingJsCalls.add(jsCode);
      log('Queued JS call (no controller yet)', name: 'MidiEngine');
      return;
    }
    if (!_webEngineReady) {
      _pendingJsCalls.add(jsCode);
      return;
    }
    try {
      await _controller!.evaluateJavascript(source: jsCode);
    } catch (e) {
      log('JS call failed: $e', name: 'MidiEngine');
    }
  }

  Future<void> _flushPendingJsCalls() async {
    if (_controller == null || _pendingJsCalls.isEmpty) {
      return;
    }

    final calls = List<String>.from(_pendingJsCalls);
    _pendingJsCalls.clear();
    log('Flushing ${calls.length} pending JS calls', name: 'MidiEngine');
    for (final jsCode in calls) {
      try {
        await _controller!.evaluateJavascript(source: jsCode);
      } catch (e) {
        log('Pending JS call failed: $e', name: 'MidiEngine');
      }
    }
  }

  void _emitState() {
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> disposeEngine() async {
    if (_disposed) return;
    _engineReadyTimeout?.cancel();
    _engineReadyTimeout = null;
    await _callJs(
      'window.FlutterMidiBridge && window.FlutterMidiBridge.destroy();',
    );
    _disposed = true;
    _pendingJsCalls.clear();
    await _stateController.close();
    super.dispose();
  }
}

const List<List<dynamic>> _generalMidiInstruments = [
  [0, 'Acoustic Grand Piano'],
  [1, 'Bright Acoustic Piano'],
  [2, 'Electric Grand Piano'],
  [3, 'Honky-tonk Piano'],
  [4, 'Electric Piano 1'],
  [5, 'Electric Piano 2'],
  [6, 'Harpsichord'],
  [7, 'Clavinet'],
  [8, 'Celesta'],
  [9, 'Glockenspiel'],
  [10, 'Music Box'],
  [11, 'Vibraphone'],
  [12, 'Marimba'],
  [13, 'Xylophone'],
  [14, 'Tubular Bells'],
  [15, 'Dulcimer'],
  [16, 'Drawbar Organ'],
  [17, 'Percussive Organ'],
  [18, 'Rock Organ'],
  [19, 'Church Organ'],
  [20, 'Reed Organ'],
  [21, 'Accordion'],
  [22, 'Harmonica'],
  [23, 'Tango Accordion'],
  [24, 'Acoustic Guitar nylon'],
  [25, 'Acoustic Guitar steel'],
  [26, 'Electric Guitar jazz'],
  [27, 'Electric Guitar clean'],
  [28, 'Electric Guitar muted'],
  [29, 'Overdriven Guitar'],
  [30, 'Distortion Guitar'],
  [31, 'Guitar Harmonics'],
  [32, 'Acoustic Bass'],
  [33, 'Electric Bass finger'],
  [34, 'Electric Bass pick'],
  [35, 'Fretless Bass'],
  [36, 'Slap Bass 1'],
  [37, 'Slap Bass 2'],
  [38, 'Synth Bass 1'],
  [39, 'Synth Bass 2'],
  [40, 'Violin'],
  [41, 'Viola'],
  [42, 'Cello'],
  [43, 'Contrabass'],
  [44, 'Tremolo Strings'],
  [45, 'Pizzicato Strings'],
  [46, 'Orchestral Harp'],
  [47, 'Timpani'],
  [48, 'String Ensemble 1'],
  [49, 'String Ensemble 2'],
  [50, 'Synth Strings 1'],
  [51, 'Synth Strings 2'],
  [52, 'Choir Aahs'],
  [53, 'Voice Oohs'],
  [54, 'Synth Voice'],
  [55, 'Orchestra Hit'],
  [56, 'Trumpet'],
  [57, 'Trombone'],
  [58, 'Tuba'],
  [59, 'Muted Trumpet'],
  [60, 'French Horn'],
  [61, 'Brass Section'],
  [62, 'Synth Brass 1'],
  [63, 'Synth Brass 2'],
  [64, 'Soprano Sax'],
  [65, 'Alto Sax'],
  [66, 'Tenor Sax'],
  [67, 'Baritone Sax'],
  [68, 'Oboe'],
  [69, 'English Horn'],
  [70, 'Bassoon'],
  [71, 'Clarinet'],
  [72, 'Piccolo'],
  [73, 'Flute'],
  [74, 'Recorder'],
  [75, 'Pan Flute'],
  [76, 'Blown Bottle'],
  [77, 'Shakuhachi'],
  [78, 'Whistle'],
  [79, 'Ocarina'],
  [80, 'Lead 1 square'],
  [81, 'Lead 2 sawtooth'],
  [82, 'Lead 3 calliope'],
  [83, 'Lead 4 chiff'],
  [84, 'Lead 5 charang'],
  [85, 'Lead 6 voice'],
  [86, 'Lead 7 fifths'],
  [87, 'Lead 8 bass lead'],
  [88, 'Pad 1 new age'],
  [89, 'Pad 2 warm'],
  [90, 'Pad 3 polysynth'],
  [91, 'Pad 4 choir'],
  [92, 'Pad 5 bowed'],
  [93, 'Pad 6 metallic'],
  [94, 'Pad 7 halo'],
  [95, 'Pad 8 sweep'],
  [96, 'FX 1 rain'],
  [97, 'FX 2 soundtrack'],
  [98, 'FX 3 crystal'],
  [99, 'FX 4 atmosphere'],
  [100, 'FX 5 brightness'],
  [101, 'FX 6'],
  [102, 'FX 7 echoes'],
  [103, 'FX 8 sci-fi'],
  [104, 'Sitar'],
  [105, 'Banjo'],
  [106, 'Shamisen'],
  [107, 'Koto'],
  [108, 'Kalimba'],
  [109, 'Bag Pipe'],
  [110, 'Fiddle'],
  [111, 'Shanai'],
  [112, 'Tinkle Bell'],
  [113, 'Agogo'],
  [114, 'Steel Drums'],
  [115, 'Woodblock'],
  [116, 'Taiko Drum'],
  [117, 'Melodic Tom'],
  [118, 'Synth Drum'],
  [119, 'Reverse Cymbal'],
  [120, 'Guitar Fret Noise'],
  [121, 'Breath Noise'],
  [122, 'Seashore'],
  [123, 'Bird Tweet'],
  [124, 'Telephone Ring'],
  [125, 'Helicopter'],
  [126, 'Applause'],
  [127, 'Gunshot'],
];

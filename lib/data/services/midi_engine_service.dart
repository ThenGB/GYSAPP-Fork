import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

import 'local_asset_service.dart';

/// State object representing the current playback state from the MIDI engine.
class MidiPlaybackState {
  final bool isPlaying;
  final double position; // seconds
  final double duration; // seconds
  final bool isLoading;
  final double loadProgress; // 0-1
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

/// Wrapper around InAppWebView that hosts the FluidSynth WASM MIDI engine.
class MidiEngineService extends ChangeNotifier {
  final LocalAssetService _assetService;

  InAppWebViewController? _controller;
  bool _initialized = false;
  bool _webEngineReady = false;
  bool _disposed = false;
  final List<String> _pendingJsCalls = [];

  MidiPlaybackState _state = const MidiPlaybackState();

  // Controllers for external listeners
  final _stateController = StreamController<MidiPlaybackState>.broadcast();
  Stream<MidiPlaybackState> get stateStream => _stateController.stream;

  MidiPlaybackState get state => _state;
  bool get isInitialized => _initialized;

  MidiEngineService(this._assetService);

  Future<void> initialize() async {
    if (_initialized) return;

    // Ensure soundfont is available in filesystem
    await _prepareSoundFont();

    _initialized = true;
    log('MidiEngineService initialized', name: 'MidiEngine');
  }

  Future<void> _prepareSoundFont() async {
    try {
      final path = await _assetService.getSoundFontPath('GeneralUser-GS.sf2');
      final soundFontReady = await File(path).exists();
      log(
        'SoundFont ready at: $path (exists: $soundFontReady)',
        name: 'MidiEngine',
      );
    } catch (e) {
      log('Failed to prepare SoundFont: $e', name: 'MidiEngine');
    }
  }

  void onWebViewCreated(InAppWebViewController controller) {
    _controller = controller;
    _webEngineReady = false;

    // Setup JS handlers for state callbacks
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
    await _callJs(
      'window.FlutterMidiBridge && window.FlutterMidiBridge.init(${jsonEncode(soundFontFileUrl)});',
      requireEngineReady: false,
    );
  }

  Future<void> loadMidi(
    String midiPath, {
    int transpose = 0,
    int? instrument,
    bool autoplay = false,
  }) async {
    // Copy MIDI asset to filesystem so WebView can access it
    final fileUrl = await _copyMidiToFilesystem(midiPath);

    _state = MidiPlaybackState(
      isPlaying: false,
      position: 0,
      duration: _state.duration,
      isLoading: true,
      loadProgress: 0,
      currentSong: midiPath,
    );
    _emitState();

    await _callJs('''
      if (window.FlutterMidiBridge) {
        window.FlutterMidiBridge.loadMidi(${jsonEncode(fileUrl)}, {
          transpose: $transpose,
          instrument: ${instrument ?? -1},
          autoplay: $autoplay
        });
      }
    ''');
  }

  Future<String> _copyMidiToFilesystem(String assetPath) async {
    final dir = await getTemporaryDirectory();
    final fileName = assetPath.split('/').last;
    final targetFile = File('${dir.path}/midi/$fileName');

    if (await targetFile.exists()) {
      return Uri.file(targetFile.path).toString();
    }

    await targetFile.parent.create(recursive: true);

    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    await targetFile.writeAsBytes(bytes, flush: true);

    return Uri.file(targetFile.path).toString();
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

  Future<void> setVolume(double volume) async {
    await _callJs('window.FlutterMidiBridge.setVolume($volume);');
  }

  Future<void> preload(String midiPath) async {
    final fileUrl = await _copyMidiToFilesystem(midiPath);
    await _callJs(
      'window.FlutterMidiBridge && window.FlutterMidiBridge.preload(${jsonEncode(fileUrl)});',
    );
  }

  Future<void> _callJs(
    String jsCode, {
    bool requireEngineReady = true,
  }) async {
    if (_disposed) return;
    if (_controller == null) {
      _pendingJsCalls.add(jsCode);
      log('Queued JS call while WebView is not ready', name: 'MidiEngine');
      return;
    }
    if (requireEngineReady && !_webEngineReady) {
      _pendingJsCalls.add(jsCode);
      log('Queued JS call while MIDI engine is not ready', name: 'MidiEngine');
      return;
    }
    try {
      await _controller!.evaluateJavascript(source: jsCode);
    } catch (e) {
      log('JS call failed: $e', name: 'MidiEngine');
    }
  }

  Future<void> _flushPendingJsCalls() async {
    if (_controller == null || !_webEngineReady || _pendingJsCalls.isEmpty) {
      return;
    }

    final calls = List<String>.from(_pendingJsCalls);
    _pendingJsCalls.clear();
    for (final jsCode in calls) {
      await _callJs(jsCode);
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
    await _callJs(
      'window.FlutterMidiBridge && window.FlutterMidiBridge.destroy();',
      requireEngineReady: false,
    );
    _disposed = true;
    _pendingJsCalls.clear();
    await _stateController.close();
    super.dispose();
  }
}

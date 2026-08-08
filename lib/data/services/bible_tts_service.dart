import 'dart:async';
import 'dart:developer';

import 'package:edge_tts/edge_tts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import '../utilities/platform_utils.dart';

/// Which text-to-speech engine to use for Bible audio.
enum BibleTtsEngine { edge, native }

/// Internal outcome of an Edge synthesis request.
enum _SpeakResult { played, failed, invalidated }

/// Text-to-speech engine for the Bible.
///
/// Primary engine is **Microsoft Edge TTS** (via `edge_tts`, no API key —
/// it talks to Edge's public neural-TTS endpoint over WebSocket). The audio
/// is received as MP3 bytes and played through `flutter_soloud`, which works
/// on every platform (Android, iOS, Windows, macOS, Linux, web).
///
/// When [engine] is [BibleTtsEngine.edge] but the network is unavailable
/// (or Edge synthesis fails), it automatically falls back to the built-in
/// [FlutterTts] native engine so the feature keeps working offline. The user
/// can also explicitly pick the native engine in settings; the native engine
/// always remains available as a fallback.
class BibleTtsService {
  BibleTtsService({BibleTtsEngine engine = BibleTtsEngine.edge})
    : _engine = engine;

  BibleTtsEngine _engine;
  BibleTtsEngine get engine => _engine;
  set engine(BibleTtsEngine value) => _engine = value;

  final FlutterTts? _nativeTts = isTextToSpeechConfiguredForCurrentPlatform
      ? FlutterTts()
      : null;

  final SoLoud _soloud = SoLoud.instance;

  SoundHandle? _edgeHandle;
  AudioSource? _edgeSource;
  bool _isDisposed = false;

  /// Monotonic counter incremented on every stop/pause; a pending Edge
  /// synthesis checks it before playing so audio started after a stop
  /// request is discarded.
  int _generation = 0;

  bool _lastUsedEdge = false;

  /// True when the most recent playback used the Edge engine.
  bool get usedEdgeEngine => _lastUsedEdge;

  /// Whether a native fallback engine is available on this platform.
  bool get hasNativeFallback => _nativeTts != null;

  /// The native fallback engine instance (the one that actually speaks
  /// during native playback). Null when unsupported on this platform.
  FlutterTts? get nativeTts => _nativeTts;

  /// Edge TTS works on every platform (incl. web) via `edge_tts`.
  static bool get isEdgeAvailable => true;

  /// Configures the native fallback with the saved voice/pitch/speed.
  Future<void> configureNative({
    Map<String, String>? voice,
    double pitch = 0.9,
    double speed = 0.35,
  }) async {
    final tts = _nativeTts;
    if (tts == null) return;
    try {
      if (voice != null && voice.isNotEmpty) {
        await tts.setVoice(voice);
      }
      await tts.setPitch(pitch);
      await tts.setSpeechRate(speed);
    } catch (e) {
      log('Native TTS configure failed: $e', name: 'BibleTtsService');
    }
  }

  /// Speaks [text] with the selected engine, falling back to native when
  /// Edge is unavailable. Returns false if nothing could be spoken.
  Future<bool> speak(String text, {BibleTtsEngine? engine}) async {
    final target = engine ?? _engine;
    if (target == BibleTtsEngine.edge && isEdgeAvailable) {
      final result = await _speakEdge(text);
      if (result == _SpeakResult.played) {
        _lastUsedEdge = true;
        return true;
      }
      if (result == _SpeakResult.invalidated) {
        // The request was stopped/paused while synthesizing — do NOT
        // fall back to native, the user asked to stop.
        return false;
      }
      // Edge failed (offline / endpoint error) → fall back to native.
    }
    final ok = await _speakNative(text);
    _lastUsedEdge = false;
    return ok;
  }

  Future<_SpeakResult> _speakEdge(String text) async {
    final generation = ++_generation;
    try {
      await _stopEdge();
      final comm = Communicate(
        text: text,
        voice: _edgeVoice,
        rate: _edgeRate,
        pitch: _edgePitch,
        volume: _edgeVolume,
      );
      final bytes = await comm.toBytes().timeout(const Duration(seconds: 45));
      if (_isDisposed || generation != _generation) {
        return _SpeakResult.invalidated;
      }
      if (bytes.isEmpty) {
        // Genuinely empty Edge response — treat as a failed synthesis so
        // the native fallback can take over.
        return _SpeakResult.failed;
      }
      if (!_soloud.isInitialized) {
        await _soloud.init();
      }
      if (generation != _generation) return _SpeakResult.invalidated;
      if (_edgeSource != null) {
        try {
          await _soloud.disposeSource(_edgeSource!);
        } catch (_) {}
      }
      final source = await _soloud.loadMem(
        'bible-edge-tts',
        bytes,
        mode: LoadMode.memory,
      );
      if (generation != _generation) {
        try {
          await _soloud.disposeSource(source);
        } catch (_) {}
        return _SpeakResult.invalidated;
      }
      _edgeSource = source;
      _edgeHandle = _soloud.play(source);
      return _SpeakResult.played;
    } catch (e) {
      if (generation != _generation || _isDisposed) {
        // Request was stopped/paused while the in-flight synthesis threw
        // (timeout / network drop) — do NOT fall back to native.
        return _SpeakResult.invalidated;
      }
      log(
        'Edge TTS failed, falling back to native: $e',
        name: 'BibleTtsService',
      );
      return _SpeakResult.failed;
    }
  }

  Future<bool> _speakNative(String text) async {
    final tts = _nativeTts;
    if (tts == null) return false;
    try {
      await _stopNative();
      // Ensures sequential speech (each verse waits for the previous one)
      // on platforms that need it (e.g. Windows).
      await tts.awaitSpeakCompletion(true);
      await tts.speak(text);
      return true;
    } catch (e) {
      log('Native TTS speak failed: $e', name: 'BibleTtsService');
      return false;
    }
  }

  Future<void> _stopEdge() async {
    final handle = _edgeHandle;
    if (handle != null) {
      try {
        await _soloud.stop(handle);
      } catch (_) {}
    }
    _edgeHandle = null;
  }

  Future<void> _stopNative() async {
    try {
      await _nativeTts?.stop();
    } catch (_) {}
  }

  /// Stops any current speech (Edge or native).
  Future<void> stop() async {
    _generation++;
    await _stopEdge();
    await _stopNative();
  }

  /// Disposes native TTS and any held audio source.
  Future<void> dispose() async {
    _isDisposed = true;
    await stop();
    final source = _edgeSource;
    if (source != null) {
      try {
        await _soloud.disposeSource(source);
      } catch (_) {}
    }
    _edgeSource = null;
  }

  // ─── Edge voice configuration (exposed for the settings page) ────────────

  String _edgeVoice = 'id-ID-ArdiNeural';
  String get edgeVoice => _edgeVoice;
  set edgeVoice(String value) => _edgeVoice = value;

  String _edgeRate = '+0%';
  String get edgeRate => _edgeRate;
  set edgeRate(String value) => _edgeRate = value;

  String _edgePitch = '+0Hz';
  String get edgePitch => _edgePitch;
  set edgePitch(String value) => _edgePitch = value;

  String _edgeVolume = '+0%';
  String get edgeVolume => _edgeVolume;
  set edgeVolume(String value) => _edgeVolume = value;

  /// Fetches the available Edge neural voices from Microsoft.
  static Future<List<Voice>> fetchEdgeVoices() async {
    try {
      return await listVoices();
    } catch (e) {
      log('Edge voices fetch failed: $e', name: 'BibleTtsService');
      return [];
    }
  }

  /// Formats a signed percentage for the Edge TTS `rate`/`volume` params
  /// (regex `^[+-]\d+%$`). Zero and positive values keep a leading `+`.
  static String formatEdgePercent(int value) =>
      value >= 0 ? '+$value%' : '$value%';

  /// Parses an Edge `rate`/`volume` string like `+25%` or `-10%` back to a
  /// plain integer.
  static int parseEdgePercent(String value) =>
      int.tryParse(value.replaceAll('%', '').replaceAll('+', '')) ?? 0;

  /// Formats a signed frequency for the Edge TTS `pitch` param
  /// (regex `^[+-]\d+Hz$`). Zero and positive values keep a leading `+`.
  static String formatEdgePitch(int value) =>
      value >= 0 ? '+${value}Hz' : '${value}Hz';

  /// Parses an Edge `pitch` string like `+25Hz` or `-10Hz` back to a plain
  /// integer.
  static int parseEdgePitch(String value) =>
      int.tryParse(value.replaceAll('Hz', '').replaceAll('+', '')) ?? 0;
}

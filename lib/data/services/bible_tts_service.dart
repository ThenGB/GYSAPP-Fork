import 'dart:async';
import 'dart:developer';

import 'package:edge_tts/edge_tts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:meta/meta.dart';

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
  BibleTtsService({this.engine = BibleTtsEngine.edge});

  BibleTtsEngine engine;

  final FlutterTts? _nativeTts = isTextToSpeechConfiguredForCurrentPlatform
      ? FlutterTts()
      : null;

  // Lazily resolved so constructing the service in tests/edge cases does not
  // force-load the native SoLoud library.
  SoLoud get _soloud => SoLoud.instance;

  SoundHandle? _edgeHandle;
  AudioSource? _edgeSource;

  /// LRU cache of preloaded Edge audio sources (keyed by synthesized text).
  /// Preloading the next verse/chapter while the current one plays makes
  /// playback seamless — the next `speak` for a cached text plays instantly
  /// instead of waiting for a network round-trip.
  final Map<String, AudioSource> _edgeCache = {};
  static const int _edgeCacheMax = 16;

  /// Maximum number of preloaded audio sources kept in the Edge cache.
  static int get edgeCacheMax => _edgeCacheMax;

  /// In-flight synthesis futures keyed by cache key. `getOrSynthesize`
  /// awaits an existing future instead of starting a second synthesis, so a
  /// preload started for verse N+1 is joined by (not duplicated by) the
  /// speak of verse N+1.
  final Map<String, Future<AudioSource?>> _inFlight = {};
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
    final target = engine ?? this.engine;
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
    // NOTE: do NOT bump _generation here. Incrementing on every verse would
    // invalidate the in-flight preload for the NEXT verse (which shares the
    // generation) and force a redundant network synthesis. _generation is
    // only bumped by stop()/pause() so a preload survives until it is used.
    final generation = _generation;
    try {
      await _stopEdge();
      final source = await getOrSynthesize(text, generation);
      if (source == null) {
        // synthesize() returns null for BOTH genuine failure and
        // invalidation. Distinguish: if the generation moved while we
        // awaited (pause/stop landed mid-synthesis), the request was
        // invalidated — do NOT fall back to native, the user asked to stop.
        if (generation != _generation || _isDisposed) {
          return _SpeakResult.invalidated;
        }
        return _SpeakResult.failed;
      }
      if (generation != _generation) {
        // Invalidated after acquisition. Do NOT dispose here: the source is
        // either still cache-owned (peek never removed it) or held by a
        // joining preload that will cache or dispose it. Disposing here
        // could double-free a source shared with that preload.
        return _SpeakResult.invalidated;
      }
      // Take sole ownership: remove from cache so it is not double-disposed.
      _edgeCache.remove(_cacheKeyFor(text));
      // Dispose the previous source (stale handle) before overwriting — it
      // is not the same source we are about to play.
      final previous = _edgeSource;
      if (previous != null && !identical(previous, source)) {
        try {
          await _soloud.disposeSource(previous);
        } catch (_) {}
      }
      // Re-check after the await: a stop/pause landing while we disposed
      // the previous handle must not play this source.
      if (generation != _generation || _isDisposed) {
        try {
          await _soloud.disposeSource(source);
        } catch (_) {}
        return _SpeakResult.invalidated;
      }
      // A concurrent preload() of the same text may have re-cached this
      // exact source while we awaited the previous-source disposal above
      // (preload's identical(_edgeSource, source) check reads the OLD
      // source during that window). Re-remove it (only if it is still this
      // source — a brand-new synthesis for the same key belongs to the
      // preload) so ownership is unambiguous: the player ends as the sole
      // owner and dispose() cannot double-free.
      if (identical(_edgeCache[_cacheKeyFor(text)], source)) {
        _edgeCache.remove(_cacheKeyFor(text));
      }
      _edgeSource = source;
      final handle = _soloud.play(source);
      _edgeHandle = handle;
      // _soloud.play() returns as soon as the voice STARTS; the audio keeps
      // playing in the background. Block here until the verse finishes so
      // sequential playback cannot cut a still-speaking verse short — the
      // previous behaviour returned immediately, then the next verse's
      // _stopEdge() chopped the tail off (skipped / clipped audio).
      await awaitEdgePlayback(handle, generation);
      // Playback ended naturally, or was stopped/paused mid-way. Either way
      // the caller decides what to do from its own state (paused keeps the
      // reading loop alive, stopped breaks it) — and we must NOT fall back
      // to the native engine, the user asked to stop/pause.
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

  /// Returns a playable [AudioSource] for [text] — from the preload cache
  /// when available, otherwise joining an in-flight synthesis for the same
  /// text, otherwise synthesizing it now. Returns null when the request was
  /// invalidated or synthesis failed. Does NOT cache here (the caller
  /// decides ownership).
  ///
  /// Protected so subclasses (tests) can inject fake sources without SoLoud.
  @protected
  Future<AudioSource?> getOrSynthesize(String text, int generation) async {
    final cacheKey = _cacheKeyFor(text);
    // Peek without removing: ownership of a cached source transfers only
    // when the caller actually plays it (in _speakEdge, after the
    // generation check). If we removed it here and the request is then
    // invalidated, the source would be ownerless → leak.
    final cached = _edgeCache[cacheKey];
    if (cached != null) {
      return cached;
    }
    final inFlight = _inFlight[cacheKey];
    if (inFlight != null) {
      // A preload for the same text is already synthesizing — join it.
      // IMPORTANT: do NOT dispose here. Only the awaiter that STARTED this
      // future owns disposal, so a stop landing between resolution and
      // resumption cannot cause a double-free of the shared source.
      final source = await inFlight;
      if (source == null) return null;
      if (generation != _generation || _isDisposed) {
        return null;
      }
      return source;
    }
    final future = synthesize(text, generation, cacheKey);
    _inFlight[cacheKey] = future;
    try {
      final source = await future;
      if (source != null && (generation != _generation || _isDisposed)) {
        // We started this synthesis, so we own it: dispose on invalidation.
        try {
          await _soloud.disposeSource(source);
        } catch (_) {}
        return null;
      }
      return source;
    } finally {
      _inFlight.remove(cacheKey);
    }
  }

  /// Waits until the Edge voice started by [handle] finishes playing.
  ///
  /// `_soloud.play()` returns the moment the voice starts, so this poll is
  /// what turns fire-and-forget playback into sequential verse speech: a
  /// verse plays to its end before the next `speak` is allowed to start.
  ///
  /// Exits early when the service is disposed or a stop/pause request
  /// (generation bump) landed while the verse was playing — the handle is
  /// invalidated by `stop()` anyway, the loop just stops polling.
  @protected
  Future<void> awaitEdgePlayback(SoundHandle handle, int generation) async {
    while (!_isDisposed && generation == _generation) {
      bool valid;
      try {
        valid = _soloud.getIsValidVoiceHandle(handle);
      } catch (_) {
        // Engine not initialized (e.g. in unit tests) — treat as finished.
        valid = false;
      }
      if (!valid) break;
      await Future.delayed(const Duration(milliseconds: 50));
    }
    if (identical(_edgeHandle, handle)) {
      _edgeHandle = null;
    }
  }

  /// Performs the actual network synthesis + SoLoud load. Protected so
  /// subclasses (tests) can simulate latency without the plugin.
  @protected
  Future<AudioSource?> synthesize(
    String text,
    int generation,
    String cacheKey,
  ) async {
    final comm = Communicate(
      text: text,
      voice: edgeVoice,
      rate: edgeRate,
      pitch: edgePitch,
      volume: edgeVolume,
    );
    final bytes = await comm.toBytes().timeout(const Duration(seconds: 45));
    if (_isDisposed || generation != _generation) {
      return null;
    }
    if (bytes.isEmpty) return null;
    if (!_soloud.isInitialized) {
      await _soloud.init();
    }
    if (generation != _generation) return null;
    final source = await _soloud.loadMem(
      'bible-edge-tts',
      bytes,
      mode: LoadMode.memory,
    );
    if (generation != _generation) {
      try {
        await _soloud.disposeSource(source);
      } catch (_) {}
      return null;
    }
    return source;
  }

  /// Preloads [text] into the Edge cache so a later `speak` for the same
  /// text plays instantly. No-op on the native engine (it synthesizes on
  /// demand) and for non-Edge engines. Fire-and-forget by the caller.
  Future<void> preload(String text, {BibleTtsEngine? engine}) async {
    final target = engine ?? this.engine;
    if (target != BibleTtsEngine.edge || !isEdgeAvailable) return;
    if (_isDisposed) return;
    final cacheKey = _cacheKeyFor(text);
    if (_edgeCache.containsKey(cacheKey)) return;
    final generation = _generation;
    try {
      final source = await getOrSynthesize(text, generation);
      if (source == null) return;
      // Guard: a speak for the same text may have claimed this source while
      // we awaited — if so, the player owns it (and removed it from the
      // cache). Do not cache a source the player already owns.
      if (_isDisposed || generation != _generation) {
        // Stopped/paused while we synthesized — the source is ours to
        // dispose (the player never acquired it).
        try {
          await _soloud.disposeSource(source);
        } catch (_) {}
        return;
      }
      if (identical(_edgeSource, source)) {
        // The player already claimed this exact source — it owns it now.
        return;
      }
      _edgeCache[cacheKey] = source;
      // Keep the LRU bounded.
      while (_edgeCache.length > _edgeCacheMax) {
        final oldest = _edgeCache.keys.first;
        final src = _edgeCache.remove(oldest);
        if (src != null) {
          try {
            await _soloud.disposeSource(src);
          } catch (_) {}
        }
      }
    } catch (e) {
      log('Edge TTS preload failed: $e', name: 'BibleTtsService');
    }
  }

  String _cacheKeyFor(String text) {
    return '$text|$edgeVoice|$edgeRate|$edgePitch|$edgeVolume';
  }

  Future<bool> _speakNative(String text) async {
    final tts = _nativeTts;
    if (tts == null) return false;
    try {
      await _stopNative();
      // Ensures sequential speech (each verse waits for the previous one)
      // on platforms that need it (e.g. Windows).
      await tts.awaitSpeakCompletion(true);
      _nativeIsSpeaking = true;
      try {
        await tts.speak(text);
      } finally {
        _nativeIsSpeaking = false;
      }
      return true;
    } catch (e) {
      _nativeIsSpeaking = false;
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
    final tts = _nativeTts;
    if (tts == null) return;
    // On Windows the flutter_tts native plugin's `stop()` dereferences the
    // SAPI voice object even when no utterance was ever started, crashing
    // the process with an access violation (observed on every tab switch
    // that called stopSpeaking()). Only stop a native utterance that is
    // actually playing; idle engines are left untouched.
    if (!_nativeIsSpeaking && !canStopIdleTextToSpeechForCurrentPlatform) {
      return;
    }
    final hook = nativeTtsStopHook;
    if (hook != null) {
      await hook();
      return;
    }
    try {
      await tts.stop();
    } catch (_) {}
  }

  /// Tracks whether a native utterance is currently being spoken, so that
  /// [stop] can avoid touching the native engine while it is idle.
  bool _nativeIsSpeaking = false;

  /// Test hook: overrides the native engine stop call so tests can assert
  /// whether an idle stop touches the native plugin.
  @visibleForTesting
  Future<void> Function()? nativeTtsStopHook;

  /// Test hook: marks the native engine as actively speaking so tests can
  /// exercise the active-utterance stop path without a real plugin.
  @visibleForTesting
  void markNativeSpeakingForTest() => _nativeIsSpeaking = true;

  /// Test hook: resets the speaking flag so tests cannot leak state.
  @visibleForTesting
  void resetNativeSpeakingForTest() => _nativeIsSpeaking = false;

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
    for (final entry in _edgeCache.values) {
      try {
        await _soloud.disposeSource(entry);
      } catch (_) {}
    }
    _edgeCache.clear();
  }

  // ─── Edge voice configuration (exposed for the settings page) ────────────

  String edgeVoice = 'id-ID-ArdiNeural';

  String edgeRate = '+0%';

  String edgePitch = '+0Hz';

  String edgeVolume = '+0%';

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

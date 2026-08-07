import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import 'local_asset_service.dart';
import 'native_midi/midi_render_settings.dart';
import 'native_midi/midi_worker.dart';
import 'native_midi/native_midi_renderer.dart';
import '../../presentations/song/cubit/song_preload_key.dart';

const String defaultMidiSoundFont = 'TimGM6mb.sf2';

class MidiPlaybackState {
  final bool isPlaying;
  final double position;
  final double duration;
  final bool isLoading;
  final String? currentSong;

  const MidiPlaybackState({
    this.isPlaying = false,
    this.position = 0,
    this.duration = 0,
    this.isLoading = false,
    this.currentSong,
  });

  MidiPlaybackState copyWith({
    bool? isPlaying,
    double? position,
    double? duration,
    bool? isLoading,
    Object? currentSong = _sentinel,
  }) {
    final next = MidiPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isLoading: isLoading ?? this.isLoading,
      currentSong: identical(currentSong, _sentinel)
          ? this.currentSong
          : currentSong as String?,
    );
    return next;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MidiPlaybackState &&
        other.isPlaying == isPlaying &&
        other.position == position &&
        other.duration == duration &&
        other.isLoading == isLoading &&
        other.currentSong == currentSong;
  }

  @override
  int get hashCode => Object.hash(
        isPlaying,
        position,
        duration,
        isLoading,
        currentSong,
      );
}

class MidiEngineService {
  static const int _defaultMaxCachedSources = 12;
  static const int _streamChunkFrames = nativeMidiSampleRate ~/ 4;
  static const int _initialStreamChunks = 4;
  static const Duration _streamPumpInterval = Duration(milliseconds: 120);

  final LocalAssetService _assetService;
  final String _cacheDir;
  final Map<String, Uint8List> _midiBytesCache = {};
  final Map<String, Uint8List> _soundFontBytesCache = {};
  final Map<String, AudioSource> _sourceCache = {};
  final List<String> _cacheOrder = [];

  bool _initialized = false;
  bool _disposed = false;
  int _renderGeneration = 0;
  Timer? _positionTimer;
  Timer? _streamPumpTimer;
  Future<void>? _streamPumpInFlight;
  int _maxCachedSources = _defaultMaxCachedSources;

  String _soundFont = defaultMidiSoundFont;
  String? _currentMidiPath;
  MidiRenderSettings _settings = const MidiRenderSettings(
    soundFont: defaultMidiSoundFont,
  );
  AudioSource? _currentSource;
  AudioSource? _streamSource;
  SoundHandle? _currentHandle;
  double _currentSourceStartOffsetSeconds = 0;
  double _volume = 1;
  bool _streamEnded = false;
  int _playbackIntentGeneration = 0;
  bool _wantsPlayback = false;

  MidiPlaybackState _state = const MidiPlaybackState();

  final _stateController = StreamController<MidiPlaybackState>.broadcast();
  Stream<MidiPlaybackState> get stateStream => _stateController.stream;
  MidiPlaybackState? _lastBroadcast;

  MidiPlaybackState get state => _state;
  bool get isInitialized => _initialized;

  MidiEngineService(this._assetService, {required String cacheDir})
    : _cacheDir = cacheDir;

  @visibleForTesting
  static double absoluteSourcePositionSecondsForTest({
    required Duration sourcePosition,
    required double sourceStartOffsetSeconds,
  }) =>
      _absoluteSourcePositionSeconds(sourcePosition, sourceStartOffsetSeconds);

  @visibleForTesting
  static Duration relativeSourcePositionForTest({
    required double absoluteSeconds,
    required double sourceStartOffsetSeconds,
  }) => _relativeSourcePosition(absoluteSeconds, sourceStartOffsetSeconds);

  static double _absoluteSourcePositionSeconds(
    Duration sourcePosition,
    double sourceStartOffsetSeconds,
  ) {
    return sourceStartOffsetSeconds + sourcePosition.inMilliseconds / 1000;
  }

  static Duration _relativeSourcePosition(
    double absoluteSeconds,
    double sourceStartOffsetSeconds,
  ) {
    final relativeSeconds = absoluteSeconds - sourceStartOffsetSeconds;
    if (relativeSeconds <= 0) return Duration.zero;
    return Duration(milliseconds: (relativeSeconds * 1000).round());
  }

  void _setCurrentSource(AudioSource? source, {double startOffsetSeconds = 0}) {
    _currentSource = source;
    _currentSourceStartOffsetSeconds = source == null ? 0 : startOffsetSeconds;
  }

  int _registerPlaybackIntent() {
    _wantsPlayback = true;
    return ++_playbackIntentGeneration;
  }

  void _cancelPlaybackIntent() {
    _wantsPlayback = false;
    _playbackIntentGeneration++;
  }

  bool _canHonorPlayIntent(int generation) {
    return !_disposed &&
        _wantsPlayback &&
        generation == _playbackIntentGeneration;
  }

  void setCacheMax(int max) {
    _maxCachedSources = max.clamp(4, 32);
    unawaited(_pruneSourceCache());
  }

  Future<List<String>> getAvailableSoundFonts() {
    return _assetService.getAvailableSoundFonts();
  }

  bool isCurrentSong(String midiPath) =>
      _state.currentSong == midiPath && _currentSource != null;

  Future<void> initialize() async {
    if (_initialized) return;
    await SoLoud.instance.init();
    _initialized = true;
    log('Native MIDI engine initialized', name: 'MidiEngine');
  }

  /// Pre-warm MIDI by loading bytes and rendering to AudioSource in memory.
  /// This is called during idle time so playback starts instantly when user presses play.
  Future<void> warmUp(
    String midiPath, {
    int transpose = 0,
    double tempoBpm = 76,
    double? baseTempoBpm,
    int? instrument,
  }) async {
    await initialize();

    // Always warm up regardless of tempo settings - we want the source ready
    // even if tempo changes later (will need re-render but source is close)

    try {
      // Load bytes first (these are cached)
      final midiBytes = await _loadMidiBytes(midiPath);
      final soundFontBytes = await _loadSoundFontBytes(_soundFont);

      final settings = MidiRenderSettings(
        transpose: transpose,
        tempoBpm: tempoBpm,
        baseTempoBpm: baseTempoBpm ?? _settings.baseTempoBpm,
        instrument: instrument,
        soundFont: _soundFont,
      ).normalized;

      // Generate cache key
      final cacheKey = generateMidiPreloadKey(
        midiPath: midiPath,
        transpose: settings.transpose,
        tempoBpm: settings.tempoBpm,
        baseTempoBpm: settings.baseTempoBpm,
        instrument: settings.instrument,
        soundFont: settings.soundFont,
      );

      // Check if already cached
      if (_sourceCache.containsKey(cacheKey)) {
        log(
          'Warm-up: source already in memory for $midiPath',
          name: 'MidiEngine',
        );
        return;
      }

      // Check disk cache first
      final wavFile = File(_wavCachePath(cacheKey));
      if (await wavFile.exists()) {
        try {
          final wavBytes = await wavFile.readAsBytes();
          final source = await SoLoud.instance.loadMem(
            'midi-cache-$cacheKey',
            wavBytes,
            mode: LoadMode.memory,
          );
          _sourceCache[cacheKey] = source;
          _touchCacheKey(cacheKey);
          await _pruneSourceCache();
          log(
            'Warm-up: loaded from disk cache for $midiPath',
            name: 'MidiEngine',
          );
          return;
        } catch (e) {
          log(
            'Warm-up: failed to load from disk cache: $e',
            name: 'MidiEngine',
          );
        }
      }

      // Render the MIDI to WAV (this is the slow part, but done in background)
      log('Warm-up: rendering $midiPath', name: 'MidiEngine');
      final rendered = await NativeMidiRenderer.render(
        midiBytes: midiBytes,
        soundFontBytes: soundFontBytes,
        settings: settings,
      );

      // Save to disk cache for future use
      await _ensureCacheDir();
      await wavFile.writeAsBytes(rendered.wavBytes);

      // Load into memory
      final source = await SoLoud.instance.loadMem(
        'midi-cache-$cacheKey',
        rendered.wavBytes,
        mode: LoadMode.memory,
      );
      _sourceCache[cacheKey] = source;
      _touchCacheKey(cacheKey);
      await _pruneSourceCache();

      log('Warm-up: rendered and cached for $midiPath', name: 'MidiEngine');
    } catch (e, stackTrace) {
      log(
        'Warm-up failed for $midiPath: $e',
        name: 'MidiEngine',
        stackTrace: stackTrace,
      );
    }
  }

  /// Robust MIDI loading with streaming playback for instant audio start.
  ///
  /// This method provides fast MIDI playback by:
  /// 1. Loading MIDI and SoundFont bytes in parallel (cached)
  /// 2. Using streaming playback from the worker for immediate audio
  /// 3. Falling back to pre-rendered sources if available
  /// 4. Supporting seek via the streaming controller
  Future<void> loadMidi(
    String midiPath, {
    int transpose = 0,
    double tempoBpm = 76,
    double? baseTempoBpm,
    int? instrument,
    bool autoplay = false,
    Duration startAt = Duration.zero,
  }) async {
    await initialize();
    final generation = ++_renderGeneration;
    final startSeconds = startAt.inMilliseconds / 1000;
    final previousDuration = _state.currentSong == midiPath
        ? _state.duration
        : 0.0;
    final autoplayIntentGeneration = autoplay
        ? _registerPlaybackIntent()
        : _playbackIntentGeneration;

    _currentMidiPath = midiPath;
    _settings = MidiRenderSettings(
      transpose: transpose,
      tempoBpm: tempoBpm,
      baseTempoBpm: baseTempoBpm ?? _settings.baseTempoBpm,
      instrument: instrument,
      soundFont: _soundFont,
    ).normalized;

    _setState(
      _state.copyWith(
        isPlaying: false,
        isLoading: true,
        currentSong: midiPath,
        position: startSeconds,
        duration: previousDuration,
      ),
    );

    try {
      await _stopCurrentHandle(emit: false);
      _stopStreamSource(disposeSource: true);
      final normalized = _settings.normalized;
      final cacheKey = generateMidiPreloadKey(
        midiPath: midiPath,
        transpose: normalized.transpose,
        tempoBpm: normalized.tempoBpm,
        baseTempoBpm: normalized.baseTempoBpm,
        instrument: normalized.instrument,
        soundFont: normalized.soundFont,
      );

      // FAST PATH 1: Try cached source immediately if no seek offset
      if (startAt == Duration.zero) {
        final cachedSource = _sourceCache[cacheKey];
        if (cachedSource != null) {
          _setCurrentSource(cachedSource);
          final duration =
              SoLoud.instance.getLength(cachedSource).inMilliseconds / 1000;
          _setState(
            _state.copyWith(
              isLoading: false,
              duration: duration,
            ),
          );
          if (autoplay) {
            await play();
          }
          return;
        }
      }

      // FAST PATH 1.5: disk cache populated by warm-up / background render.
      // Without this the cache-ahead feature only helps while the source
      // survives in memory; after a prune or app restart the next song
      // re-renders from scratch even though the WAV is on disk.
      if (startAt == Duration.zero) {
        final wavFile = File(_wavCachePath(cacheKey));
        if (await wavFile.exists()) {
          try {
            final wavBytes = await wavFile.readAsBytes();
            final source = await SoLoud.instance.loadMem(
              'midi-cache-$cacheKey',
              wavBytes,
              mode: LoadMode.memory,
            );
            _sourceCache[cacheKey] = source;
            _touchCacheKey(cacheKey);
            await _pruneSourceCache();
            _setCurrentSource(source);
            final duration =
                SoLoud.instance.getLength(source).inMilliseconds / 1000;
            _setState(
              _state.copyWith(
                isLoading: false,
                duration: duration,
              ),
            );
            log(
              'loadMidi: loaded from disk cache for $midiPath',
              name: 'MidiEngine',
            );
            if (autoplay) {
              await play();
            }
            return;
          } catch (e) {
            log(
              'loadMidi: disk cache load failed for $midiPath: $e',
              name: 'MidiEngine',
            );
          }
        }
      }

      // Load bytes in parallel - these are cached so this is fast
      final loadFuture = Future.wait([
        _loadMidiBytes(midiPath),
        _loadSoundFontBytes(_settings.soundFont),
      ]);

      final results = await loadFuture;
      if (_disposed || generation != _renderGeneration) return;

      final midiBytes = results[0];
      final soundFontBytes = results[1];

      // FAST PATH 2: feed rendered chunks into a SoLoud buffer stream.
      final worker = MidiWorker();
      await worker.prepareSoundFont(soundFontBytes, _settings.soundFont);
      final streamInfo = await worker.startStream(
        midiBytes: midiBytes,
        settings: _settings,
        fastDry: false,
      );
      if (startAt > Duration.zero) {
        await worker.seekStream(startAt.inMilliseconds / 1000);
      }

      if (_disposed || generation != _renderGeneration) return;
      final streamSource = SoLoud.instance.setBufferStream(
        maxBufferSizeDuration: const Duration(minutes: 30),
        bufferingType: BufferingType.released,
        bufferingTimeNeeds: 0.08,
        sampleRate: nativeMidiSampleRate,
        channels: Channels.stereo,
        format: BufferType.f32le,
      );
      _streamSource = streamSource;
      _setCurrentSource(streamSource, startOffsetSeconds: startSeconds);
      _streamEnded = false;

      for (var i = 0; i < _initialStreamChunks; i++) {
        final keepStreaming = await _appendNextStreamChunk(
          streamSource,
          generation,
        );
        if (!keepStreaming) break;
      }

      if (_disposed || generation != _renderGeneration) return;
      _setState(
        _state.copyWith(
          isLoading: false,
          duration: streamInfo.duration.inMilliseconds / 1000,
          position: startAt.inMilliseconds / 1000,
        ),
      );
      _startStreamPump(streamSource, generation);

      if (autoplay) {
        if (_canHonorPlayIntent(autoplayIntentGeneration)) {
          await play(startAt: Duration.zero);
        }
        return;
      }

      // Render to WAV for caching only when the stream is primed but not
      // currently playing. The stream pump uses the same worker, so a full
      // render during playback would starve later chunks.
      if (startAt == Duration.zero) {
        final renderedFuture = NativeMidiRenderer.render(
          midiBytes: midiBytes,
          soundFontBytes: soundFontBytes,
          settings: _settings,
        );

        unawaited(
          _finishBackgroundRender(
            renderedFuture: renderedFuture,
            cacheKey: cacheKey,
            streamSource: streamSource,
            generation: generation,
          ),
        );
      }
    } catch (e, st) {
      log('Load MIDI failed: $e', name: 'MidiEngine', stackTrace: st);
      if (!_disposed && generation == _renderGeneration) {
        _setState(_state.copyWith(isLoading: false));
      }
    }
  }

  Future<void> _finishBackgroundRender({
    required Future<RenderedMidiAudio> renderedFuture,
    required String cacheKey,
    required AudioSource streamSource,
    required int generation,
  }) async {
    try {
      final rendered = await renderedFuture;

      if (_disposed || generation != _renderGeneration) return;

      await _ensureCacheDir();
      await File(_wavCachePath(cacheKey)).writeAsBytes(rendered.wavBytes);

      final renderedSource = await SoLoud.instance.loadMem(
        'midi-cache-$cacheKey',
        rendered.wavBytes,
        mode: LoadMode.memory,
      );
      _sourceCache[cacheKey] = renderedSource;
      _touchCacheKey(cacheKey);
      await _pruneSourceCache();

      final keepCurrentStream =
          _currentSource == streamSource && _state.isPlaying;
      if (!keepCurrentStream && _currentSource == streamSource) {
        _stopStreamSource(disposeSource: true);
        _setCurrentSource(renderedSource);
      }

      final totalDuration = rendered.duration.inMilliseconds / 1000;
      final position = _state.position.clamp(0, totalDuration).toDouble();
      _setState(
        _state.copyWith(
          isLoading: false,
          duration: totalDuration,
          position: position,
        ),
      );
    } catch (e, st) {
      log(
        'Background MIDI render failed: $e',
        name: 'MidiEngine',
        stackTrace: st,
      );
    }
  }

  Future<bool> _appendNextStreamChunk(
    AudioSource source,
    int generation,
  ) async {
    if (_disposed ||
        generation != _renderGeneration ||
        _streamEnded ||
        _streamSource != source) {
      return false;
    }

    final chunk = await MidiWorker().fillStream(_streamChunkFrames);
    if (_disposed ||
        generation != _renderGeneration ||
        _streamSource != source) {
      return false;
    }

    SoLoud.instance.addAudioDataStream(
      source,
      _interleaveFloat32Stereo(chunk.left, chunk.right),
    );

    if (chunk.isEnded) {
      _streamEnded = true;
      SoLoud.instance.setDataIsEnded(source);
      return false;
    }

    return true;
  }

  void _startStreamPump(AudioSource source, int generation) {
    _streamPumpTimer?.cancel();
    _streamPumpTimer = Timer.periodic(_streamPumpInterval, (_) {
      if (_streamPumpInFlight != null || _streamEnded) return;
      _streamPumpInFlight = _appendNextStreamChunk(source, generation)
          .whenComplete(() {
            _streamPumpInFlight = null;
          });
    });
  }

  void _stopStreamSource({required bool disposeSource}) {
    _streamPumpTimer?.cancel();
    _streamPumpTimer = null;
    _streamPumpInFlight = null;
    final source = _streamSource;
    _streamSource = null;
    _streamEnded = false;
    if (source != null) {
      try {
        SoLoud.instance.setDataIsEnded(source);
      } catch (_) {
        // The stream may already be ended or disposed.
      }
      if (_currentSource == source) {
        _setCurrentSource(null);
      }
      if (disposeSource) {
        unawaited(SoLoud.instance.disposeSource(source));
      }
    }
  }

  String _wavCachePath(String cacheKey) {
    final safeKey = cacheKey.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return '$_cacheDir/$safeKey.wav';
  }

  Future<void> _ensureCacheDir() async {
    final dir = Directory(_cacheDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  Future<Uint8List> _loadMidiBytes(String assetPath) async {
    final cached = _midiBytesCache[assetPath];
    if (cached != null) return cached;
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    _midiBytesCache[assetPath] = bytes;
    return bytes;
  }

  Future<Uint8List> _loadSoundFontBytes(String fileName) async {
    final normalized = _normaliseSoundFontFileName(fileName);
    final cached = _soundFontBytesCache[normalized];
    if (cached != null) return cached;
    final data = await rootBundle.load('assets/data/soundfont/$normalized');
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    _soundFontBytesCache[normalized] = bytes;
    return bytes;
  }

  String _normaliseSoundFontFileName(String soundFontFileName) {
    return soundFontFileName
        .split(RegExp(r'[\\/]'))
        .where((part) => part.isNotEmpty)
        .last;
  }

  Future<void> play({Duration startAt = Duration.zero}) async {
    await initialize();
    final playIntentGeneration = _registerPlaybackIntent();

    // FAST PATH: If we have a source, play immediately
    if (_currentSource != null) {
      await _startPlaybackFromSource(startAt);
      return;
    }

    // If no source but we have a MIDI path, try to load and play
    if (_currentMidiPath != null) {
      // Check if we have a cached source that we can use immediately
      final cacheKey = generateMidiPreloadKey(
        midiPath: _currentMidiPath!,
        transpose: _settings.transpose,
        tempoBpm: _settings.tempoBpm,
        baseTempoBpm: _settings.baseTempoBpm,
        instrument: _settings.instrument,
        soundFont: _settings.soundFont,
      );

      final cachedSource = _sourceCache[cacheKey];
      if (cachedSource != null) {
        _setCurrentSource(cachedSource);
        await _startPlaybackFromSource(startAt);
        return;
      }

      // Try to load from disk cache first (faster than re-rendering)
      _loadFromDiskCache(_currentMidiPath!, _settings).then((source) async {
        if (source != null && _canHonorPlayIntent(playIntentGeneration)) {
          _setCurrentSource(source);
          await _startPlaybackFromSource(Duration.zero);
        }
      });

      // Also trigger full render in background for future use
      unawaited(
        loadMidi(
          _currentMidiPath!,
          transpose: _settings.transpose,
          tempoBpm: _settings.tempoBpm,
          baseTempoBpm: _settings.baseTempoBpm,
          instrument: _settings.instrument,
        ),
      );

      // No cache available, trigger full load if disk cache failed
      // (The disk cache load above will handle playback once ready)
    }
  }

  Future<void> _startPlaybackFromSource(Duration startAt) async {
    final source = _currentSource;
    if (source == null) return;

    await _stopCurrentHandle(emit: false);
    _currentHandle = SoLoud.instance.play(
      source,
      volume: _volume,
      paused: true,
    );

    // Handle stream sources differently - cannot seek on buffer streams
    final isStreamSource = source == _streamSource;

    if (isStreamSource) {
      // Stream sources cannot be seeked. If startAt > 0, we need to re-load
      // from that point. Otherwise just play from current position.
      if (startAt > Duration.zero) {
        // Re-render from seek point for stream sources
        SoLoud.instance.stop(_currentHandle!);
        _currentHandle = null;
        final seconds = startAt.inMilliseconds / 1000;
        await _seekViaRerender(seconds.clamp(0, _state.duration));
        return;
      }
      // For stream sources without seek, just play
    } else {
      // Non-stream sources (pre-rendered WAV) can be seeked
      final absoluteStartSeconds = startAt > Duration.zero
          ? startAt.inMilliseconds / 1000
          : _state.position;
      final relativeStart = _relativeSourcePosition(
        absoluteStartSeconds,
        _currentSourceStartOffsetSeconds,
      );
      if (relativeStart > Duration.zero) {
        try {
          SoLoud.instance.seek(_currentHandle!, relativeStart);
        } catch (e) {
          log(
            'Seek in _startPlaybackFromSource failed: $e',
            name: 'MidiEngine',
          );
        }
      }
    }

    SoLoud.instance.setPause(_currentHandle!, false);
    _startPositionTimer();
    _setState(_state.copyWith(isPlaying: true, isLoading: false));
  }

  /// Try to load a cached source from disk without re-rendering.
  Future<AudioSource?> _loadFromDiskCache(
    String midiPath,
    MidiRenderSettings settings,
  ) async {
    try {
      final normalized = settings.normalized;
      final cacheKey = generateMidiPreloadKey(
        midiPath: midiPath,
        transpose: normalized.transpose,
        tempoBpm: normalized.tempoBpm,
        baseTempoBpm: normalized.baseTempoBpm,
        instrument: normalized.instrument,
        soundFont: normalized.soundFont,
      );

      final wavFile = File(_wavCachePath(cacheKey));
      if (await wavFile.exists()) {
        final wavBytes = await wavFile.readAsBytes();
        return await SoLoud.instance.loadMem(
          'midi-cache-$cacheKey',
          wavBytes,
          mode: LoadMode.memory,
        );
      }
    } catch (e) {
      log('Failed to load from disk cache: $e', name: 'MidiEngine');
    }
    return null;
  }

  Future<void> pause() async {
    _cancelPlaybackIntent();
    final handle = _currentHandle;
    if (handle != null && SoLoud.instance.getIsValidVoiceHandle(handle)) {
      SoLoud.instance.setPause(handle, true);
    }
    _positionTimer?.cancel();
    _setState(_state.copyWith(isPlaying: false));
  }

  Future<void> stop() async {
    _cancelPlaybackIntent();
    await _stopCurrentHandle(emit: false);
    _stopStreamSource(disposeSource: true);
    _positionTimer?.cancel();
    // Clear currentMidiPath to prevent play() from restarting after stop
    final stoppedMidiPath = _currentMidiPath;
    _currentMidiPath = null;
    _setState(
      _state.copyWith(
        isPlaying: false,
        position: 0,
        isLoading: false,
        currentSong: stoppedMidiPath, // Keep track of what was stopped
      ),
    );
  }

  Future<void> seek(double seconds) async {
    final midiPath = _currentMidiPath;
    if (midiPath == null) return;

    final clamped = seconds.clamp(0, _state.duration).toDouble();

    // CRITICAL: Buffer streams with BufferingType.released CANNOT be seeked
    // via SoLoud.seek(). This causes SoLoudBufferStreamWithReleasedBufferTypeCannotBeSeekedCppException.
    // Always use re-render approach for stream sources.
    if (_currentSource != null &&
        _currentSource == _streamSource &&
        _state.duration > 0) {
      // For stream sources, re-render from the seek point
      await _seekViaRerender(clamped);
      return;
    }

    // For non-stream sources (pre-rendered WAV in memory), standard seek works
    if (_currentSource != null && _state.duration > 0) {
      final handle = _currentHandle;
      if (handle != null && SoLoud.instance.getIsValidVoiceHandle(handle)) {
        try {
          SoLoud.instance.seek(
            handle,
            _relativeSourcePosition(clamped, _currentSourceStartOffsetSeconds),
          );
          _setState(_state.copyWith(position: clamped));
          return;
        } catch (e) {
          // Fall back to re-render if seek fails
          log('Standard seek failed, trying re-render: $e', name: 'MidiEngine');
          await _seekViaRerender(clamped);
          return;
        }
      }
    }

    // No loaded source - re-render from the seek point
    await _seekViaRerender(clamped);
  }

  /// Re-render from a specific seek point. This is the fallback method for
  /// buffer streams which cannot be seeked via SoLoud.seek().
  Future<void> _seekViaRerender(double seconds) async {
    final midiPath = _currentMidiPath;
    if (midiPath == null) return;

    final clamped = seconds.clamp(0, _state.duration).toDouble();
    final wasPlaying = _state.isPlaying;

    // Stop current playback and reset position to 0 first
    await _stopCurrentHandle(emit: false);
    _stopStreamSource(disposeSource: true);
    _positionTimer?.cancel();

    // Set loading state with position reset to 0 (will be updated after load)
    _setState(
      _state.copyWith(
        isPlaying: false,
        position: clamped,
        isLoading: true,
        currentSong: midiPath,
      ),
    );

    await loadMidi(
      midiPath,
      transpose: _settings.transpose,
      tempoBpm: _settings.tempoBpm,
      baseTempoBpm: _settings.baseTempoBpm,
      instrument: _settings.instrument,
      autoplay: wasPlaying,
      startAt: Duration(milliseconds: (clamped * 1000).round()),
    );
  }

  Future<void> setTranspose(int semitones) async {
    await _rerenderCurrent(_settings.copyWith(transpose: semitones));
  }

  Future<void> setTempo(double bpm) async {
    await _rerenderCurrent(_settings.copyWith(tempoBpm: bpm));
  }

  Future<void> setTempoBase(double bpm) async {
    await _rerenderCurrent(
      _settings.copyWith(tempoBpm: bpm, baseTempoBpm: bpm),
    );
  }

  Future<void> setInstrument(int program) async {
    await _rerenderCurrent(
      _settings.copyWith(instrument: program < 0 ? null : program),
    );
  }

  void setSoundFont(String soundFontFileName) {
    _soundFont = _normaliseSoundFontFileName(soundFontFileName);
    _settings = _settings.copyWith(soundFont: _soundFont).normalized;
  }

  Future<void> changeSoundFont(String soundFontFileName) async {
    await initialize();
    try {
      setSoundFont(soundFontFileName);
      await _rerenderCurrent(_settings, force: true);
    } catch (e, stackTrace) {
      log(
        'Failed to load soundfont $soundFontFileName, falling back to TimGM6mb.sf2: $e',
        name: 'MidiEngine',
        stackTrace: stackTrace,
      );
      // Fallback to the smaller, more compatible soundfont
      setSoundFont(defaultMidiSoundFont);
      await _rerenderCurrent(_settings, force: true);
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0, 1).toDouble();
    final handle = _currentHandle;
    if (handle != null && SoLoud.instance.getIsValidVoiceHandle(handle)) {
      SoLoud.instance.setVolume(handle, _volume);
    }
  }

  Future<void> _rerenderCurrent(
    MidiRenderSettings nextSettings, {
    bool force = false,
  }) async {
    final midiPath = _currentMidiPath;
    if (midiPath == null) {
      _settings = nextSettings.normalized;
      return;
    }

    final normalizedNext = nextSettings.normalized;
    // REDUNDANCY CHECK: Avoid re-rendering if settings are identical
    if (!force &&
        _settings.transpose == normalizedNext.transpose &&
        _settings.tempoBpm == normalizedNext.tempoBpm &&
        _settings.baseTempoBpm == normalizedNext.baseTempoBpm &&
        _settings.instrument == normalizedNext.instrument &&
        _settings.soundFont == normalizedNext.soundFont) {
      return;
    }

    _settings = normalizedNext;

    // Proceed with re-render if it's the active song or if we are currently loading it.
    // The generation counter in loadMidi will handle canceling stale loads.
    final wasPlaying = _state.isPlaying;
    final handle = _currentHandle;
    final streamSource = _streamSource;
    final position =
        handle != null && SoLoud.instance.getIsValidVoiceHandle(handle)
        ? Duration(
            milliseconds:
                (_absoluteSourcePositionSeconds(
                          streamSource != null && _currentSource == streamSource
                              ? SoLoud.instance.getStreamTimeConsumed(
                                  streamSource,
                                )
                              : SoLoud.instance.getPosition(handle),
                          _currentSourceStartOffsetSeconds,
                        ) *
                        1000)
                    .round(),
          )
        : Duration(milliseconds: (_state.position * 1000).round());
    await _stopCurrentHandle(emit: false);
    await loadMidi(
      midiPath,
      transpose: _settings.transpose,
      tempoBpm: _settings.tempoBpm,
      baseTempoBpm: _settings.baseTempoBpm,
      instrument: _settings.instrument,
      autoplay: false,
    );
    if (wasPlaying) {
      await play(startAt: position);
    } else {
      await seek(position.inMilliseconds / 1000);
    }
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final handle = _currentHandle;
      if (handle == null || !SoLoud.instance.getIsValidVoiceHandle(handle)) {
        _positionTimer?.cancel();
        _setState(_state.copyWith(isPlaying: false));
        return;
      }
      final streamSource = _streamSource;
      final sourcePosition =
          streamSource != null && _currentSource == streamSource
          ? SoLoud.instance.getStreamTimeConsumed(streamSource)
          : SoLoud.instance.getPosition(handle);
      final seconds = _absoluteSourcePositionSeconds(
        sourcePosition,
        _currentSourceStartOffsetSeconds,
      );
      final ended = _state.duration > 0 && seconds >= _state.duration - 0.1;
      _setState(
        _state.copyWith(
          isPlaying: !ended,
          position: seconds.clamp(0, _state.duration).toDouble(),
        ),
      );
      if (ended) {
        _positionTimer?.cancel();
      }
    });
  }

  Future<void> _stopCurrentHandle({required bool emit}) async {
    final handle = _currentHandle;
    _currentHandle = null;
    if (handle != null && SoLoud.instance.getIsValidVoiceHandle(handle)) {
      await SoLoud.instance.stop(handle);
    }
    if (emit) {
      _setState(_state.copyWith(isPlaying: false));
    }
  }

  void _touchCacheKey(String cacheKey) {
    _cacheOrder.remove(cacheKey);
    _cacheOrder.add(cacheKey);
  }

  Future<void> _pruneSourceCache() async {
    final futures = <Future<void>>[];
    while (_cacheOrder.length > _maxCachedSources) {
      final cacheKey = _cacheOrder.removeAt(0);
      final source = _sourceCache[cacheKey];
      if (source != null && source == _currentSource) {
        // Keep current song alive so switching back doesn't force re-render.
        _cacheOrder.add(cacheKey);
        continue;
      }
      _sourceCache.remove(cacheKey);
      if (source != null) {
        futures.add(SoLoud.instance.disposeSource(source));
      }
      // Keep rendered WAV files on disk as a warm cache; memory pruning should
      // not force expensive MIDI rendering on later revisits.
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  void _setState(MidiPlaybackState state) {
    _state = state;
    _emitState();
  }

  void _emitState() {
    if (_stateController.isClosed) return;
    // Compare with the previously broadcast snapshot and skip the add if
    // nothing actually changed.  Avoids per-tick (4 Hz) wakeups for the
    // position timer when neither isPlaying/isLoading nor the song path
    // has changed.
    final last = _lastBroadcast;
    if (last != null && last == _state) return;
    _lastBroadcast = _state;
    _stateController.add(_state);
  }

  Future<void> disposeEngine() async {
    if (_disposed) return;
    _disposed = true;
    _positionTimer?.cancel();
    _streamPumpTimer?.cancel();
    await _stopCurrentHandle(emit: false);
    _stopStreamSource(disposeSource: true);
    await Future.wait(
      _sourceCache.values.map((s) => SoLoud.instance.disposeSource(s)),
    );
    _sourceCache.clear();
    _cacheOrder.clear();
    await _stateController.close();
  }

  /// Interleaves a left/right [Float32List] pair into a single stereo
  /// PCM byte stream ready for [SoLoud.addAudioDataStream].
  static Uint8List _interleaveFloat32Stereo(
    Float32List left,
    Float32List right,
  ) {
    final frames = left.length < right.length ? left.length : right.length;
    final interleaved = Float32List(frames * 2);
    for (var i = 0; i < frames; i++) {
      final outputIndex = i * 2;
      interleaved[outputIndex] = left[i];
      interleaved[outputIndex + 1] = right[i];
    }
    return interleaved.buffer.asUint8List();
  }
}

const Object _sentinel = Object();

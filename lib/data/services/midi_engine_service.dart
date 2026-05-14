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

const String defaultMidiSoundFont = 'GeneralUser-GS.sf2';

/// Stream-based playback that renders audio chunks in real-time.
/// This provides instant playback without waiting for full render.
class MidiStreamingController {
  final List<int> _leftSamples = [];
  final List<int> _rightSamples = [];
  bool _isComplete = false;

  void addChunk(Float32List left, Float32List right) {
    for (var i = 0; i < left.length; i++) {
      _leftSamples.add((left[i] * 32767).round().clamp(-32768, 32767));
      _rightSamples.add((right[i] * 32767).round().clamp(-32768, 32767));
    }
  }

  void setComplete() => _isComplete = true;

  bool get isComplete => _isComplete;

  Uint8List getWavBytes({int? maxMs}) {
    final targetSamples = maxMs != null
        ? (maxMs * nativeMidiSampleRate / 1000).round().clamp(
            0,
            _leftSamples.length,
          )
        : _leftSamples.length;

    final pcmBytes = Uint8List(targetSamples * 4);
    for (var i = 0; i < targetSamples; i++) {
      final byteData = ByteData(4);
      byteData.setInt16(
        i * 4,
        _leftSamples[i].clamp(-32768, 32767),
        Endian.little,
      );
      byteData.setInt16(
        i * 4 + 2,
        _rightSamples[i].clamp(-32768, 32767),
        Endian.little,
      );
      pcmBytes.setRange(i * 4, i * 4 + 4, byteData.buffer.asUint8List());
    }

    return _encodePcm16Wav(
      pcmBytes,
      sampleRate: nativeMidiSampleRate,
      channels: 2,
    );
  }

  static Uint8List _encodePcm16Wav(
    Uint8List pcmBytes, {
    required int sampleRate,
    required int channels,
  }) {
    final byteRate = sampleRate * channels * 2;
    final blockAlign = channels * 2;
    final output = _StringBuffer();
    final header = ByteData(44);

    void writeAscii(ByteData data, int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        data.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    writeAscii(header, 0, 'RIFF');
    header.setUint32(4, 36 + pcmBytes.length, Endian.little);
    writeAscii(header, 8, 'WAVE');
    writeAscii(header, 12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, 16, Endian.little);
    writeAscii(header, 36, 'data');
    header.setUint32(40, pcmBytes.length, Endian.little);

    output.add(header.buffer.asUint8List());
    output.add(pcmBytes);
    return output.toBytes();
  }
}

/// Simple BytesBuilder replacement to avoid deprecation warning.
class _StringBuffer {
  final List<Uint8List> _chunks = [];

  void add(Uint8List bytes) => _chunks.add(bytes);

  Uint8List toBytes() {
    final totalLength = _chunks.fold(0, (sum, chunk) => sum + chunk.length);
    final result = Uint8List(totalLength);
    var offset = 0;
    for (final chunk in _chunks) {
      result.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    return result;
  }
}

@visibleForTesting
Uint8List interleaveFloat32Stereo(Float32List left, Float32List right) {
  final frames = left.length < right.length ? left.length : right.length;
  final interleaved = Float32List(frames * 2);
  for (var i = 0; i < frames; i++) {
    final outputIndex = i * 2;
    interleaved[outputIndex] = left[i];
    interleaved[outputIndex + 1] = right[i];
  }
  return interleaved.buffer.asUint8List();
}

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

  MidiPlaybackState copyWith({
    bool? isPlaying,
    double? position,
    double? duration,
    bool? isLoading,
    double? loadProgress,
    Object? currentSong = _sentinel,
  }) {
    return MidiPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isLoading: isLoading ?? this.isLoading,
      loadProgress: loadProgress ?? this.loadProgress,
      currentSong: identical(currentSong, _sentinel)
          ? this.currentSong
          : currentSong as String?,
    );
  }
}

class MidiEngineService extends ChangeNotifier {
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
  double _volume = 1;
  bool _streamEnded = false;

  MidiPlaybackState _state = const MidiPlaybackState();

  List<List<dynamic>> _instruments = [];
  List<List<dynamic>> get instruments =>
      _instruments.isEmpty ? _generalMidiInstruments : _instruments;

  final _stateController = StreamController<MidiPlaybackState>.broadcast();
  Stream<MidiPlaybackState> get stateStream => _stateController.stream;

  MidiPlaybackState get state => _state;
  bool get isInitialized => _initialized;

  MidiEngineService(this._assetService, {required String cacheDir})
    : _cacheDir = cacheDir;

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
        loadProgress: 0.05,
        currentSong: midiPath,
        duration: _state.duration > 0 ? _state.duration : 0,
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
          _currentSource = cachedSource;
          final duration =
              SoLoud.instance.getLength(cachedSource).inMilliseconds / 1000;
          _setState(
            _state.copyWith(
              isLoading: false,
              loadProgress: 1,
              duration: duration,
            ),
          );
          if (autoplay) {
            await play();
          }
          return;
        }
      }

      // Load bytes in parallel - these are cached so this is fast
      final loadFuture = Future.wait([
        _loadMidiBytes(midiPath),
        _loadSoundFontBytes(_settings.soundFont),
      ]);

      _setState(_state.copyWith(loadProgress: 0.2));
      final results = await loadFuture;
      if (_disposed || generation != _renderGeneration) return;

      final midiBytes = results[0];
      final soundFontBytes = results[1];
      _setState(_state.copyWith(loadProgress: 0.4));

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
      _currentSource = streamSource;
      _streamEnded = false;
      _instruments = streamInfo.instruments;

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
          loadProgress: 0.65,
          duration: streamInfo.duration.inMilliseconds / 1000,
          position: startAt.inMilliseconds / 1000,
        ),
      );
      _startStreamPump(streamSource, generation);

      if (autoplay) {
        await play(startAt: Duration.zero);
        return;
      }

      // Render to WAV for caching only when the stream is primed but not
      // currently playing. The stream pump uses the same worker, so a full
      // render during playback would starve later chunks.
      final renderedFuture = NativeMidiRenderer.render(
        midiBytes: midiBytes,
        soundFontBytes: soundFontBytes,
        settings: _settings,
        startAt: startAt,
      );

      unawaited(
        _finishBackgroundRender(
          renderedFuture: renderedFuture,
          cacheKey: cacheKey,
          streamSource: streamSource,
          generation: generation,
          startAt: startAt,
        ),
      );
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
    required Duration startAt,
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
        _currentSource = renderedSource;
      }

      final totalDuration = rendered.duration.inMilliseconds / 1000;
      _setState(
        _state.copyWith(
          isLoading: false,
          loadProgress: 1,
          duration: startAt.inSeconds > 0 ? _state.duration : totalDuration,
          position: startAt.inMilliseconds / 1000,
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
      interleaveFloat32Stereo(chunk.left, chunk.right),
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
        _currentSource = null;
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
        _currentSource = cachedSource;
        await _startPlaybackFromSource(startAt);
        return;
      }

      // Try to load from disk cache first (faster than re-rendering)
      _loadFromDiskCache(_currentMidiPath!, _settings).then((source) async {
        if (source != null && !_disposed) {
          _currentSource = source;
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
    if (startAt > Duration.zero) {
      SoLoud.instance.seek(_currentHandle!, startAt);
    } else if (_state.position > 0) {
      SoLoud.instance.seek(
        _currentHandle!,
        Duration(milliseconds: (_state.position * 1000).round()),
      );
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
    final handle = _currentHandle;
    if (handle != null && SoLoud.instance.getIsValidVoiceHandle(handle)) {
      SoLoud.instance.setPause(handle, true);
    }
    _positionTimer?.cancel();
    _setState(_state.copyWith(isPlaying: false));
  }

  Future<void> stop() async {
    await _stopCurrentHandle(emit: false);
    _stopStreamSource(disposeSource: true);
    _positionTimer?.cancel();
    _setState(
      _state.copyWith(
        isPlaying: false,
        position: 0,
        isLoading: false,
        currentSong: _currentMidiPath,
      ),
    );
  }

  Future<void> seek(double seconds) async {
    final clamped = seconds.clamp(0, _state.duration).toDouble();

    // If the song is already loaded in memory, use standard seek
    final currentSource = _currentSource;
    if (currentSource != null &&
        currentSource != _streamSource &&
        _state.duration > 0) {
      final handle = _currentHandle;
      if (handle != null && SoLoud.instance.getIsValidVoiceHandle(handle)) {
        SoLoud.instance.seek(
          handle,
          Duration(milliseconds: (clamped * 1000).round()),
        );
        _setState(_state.copyWith(position: clamped));
        return;
      }
    }

    // NEW ROBUST SEEK: Re-render from the seek point if streaming/loading is slow.
    // This provides "Instant render playback" feel.
    final wasPlaying = _state.isPlaying;
    await stop();

    _setState(_state.copyWith(isLoading: true, position: clamped));

    await loadMidi(
      _currentMidiPath!,
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
    _instruments = [];
    if (!_disposed) notifyListeners();
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
    final position =
        _currentHandle != null &&
            SoLoud.instance.getIsValidVoiceHandle(_currentHandle!)
        ? SoLoud.instance.getPosition(_currentHandle!)
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
      final position = streamSource != null && _currentSource == streamSource
          ? SoLoud.instance.getStreamTimeConsumed(streamSource)
          : SoLoud.instance.getPosition(handle);
      final seconds = position.inMilliseconds / 1000;
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
        await SoLoud.instance.disposeSource(source);
      }
      // Keep rendered WAV files on disk as a warm cache; memory pruning should
      // not force expensive MIDI rendering on later revisits.
    }
  }

  void _setState(MidiPlaybackState state) {
    _state = state;
    _emitState();
  }

  void _emitState() {
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> disposeEngine() async {
    if (_disposed) return;
    _disposed = true;
    _positionTimer?.cancel();
    _streamPumpTimer?.cancel();
    await _stopCurrentHandle(emit: false);
    _stopStreamSource(disposeSource: true);
    for (final source in _sourceCache.values) {
      await SoLoud.instance.disposeSource(source);
    }
    _sourceCache.clear();
    _cacheOrder.clear();
    await _stateController.close();
    super.dispose();
  }
}

const Object _sentinel = Object();

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

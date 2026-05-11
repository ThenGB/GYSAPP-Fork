import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import 'local_asset_service.dart';
import 'native_midi/midi_render_settings.dart';
import 'native_midi/midi_tempo_detector.dart';
import 'native_midi/native_midi_renderer.dart';
import '../../presentations/song/cubit/song_preload_key.dart';

const String defaultMidiSoundFont = 'GeneralUser-GS.sf2';

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
  static const int _defaultMaxCachedSources = 6;

  final LocalAssetService _assetService;
  final String _cacheDir;
  final Map<String, Uint8List> _midiBytesCache = {};
  final Map<String, Uint8List> _soundFontBytesCache = {};
  final Map<String, AudioSource> _sourceCache = {};
  final Map<String, Future<AudioSource>> _inflightSourceLoads = {};
  final List<String> _cacheOrder = [];

  bool _initialized = false;
  bool _disposed = false;
  int _renderGeneration = 0;
  int _pendingRenderCount = 0;
  Timer? _positionTimer;
  int _maxCachedSources = _defaultMaxCachedSources;

  String _soundFont = defaultMidiSoundFont;
  String? _currentMidiPath;
  MidiRenderSettings _settings = const MidiRenderSettings(
    soundFont: defaultMidiSoundFont,
  );
  AudioSource? _currentSource;
  SoundHandle? _currentHandle;
  double _volume = 1;

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

  /// Cache-ahead render for the given MIDI without touching playback state.
  /// Errors are swallowed and logged so that background warm-up never
  /// interrupts the user.
  Future<void> warmUp(
    String midiPath, {
    int transpose = 0,
    double tempoBpm = 76,
    double? baseTempoBpm,
    int? instrument,
  }) async {
    await initialize();
    
    // Skip preload for non-neutral tempo rates (song-state specific)
    if (!isTempoNeutral(tempoBpm, baseTempoBpm ?? 76)) {
      return;
    }
    
    try {
      final settings = MidiRenderSettings(
        transpose: transpose,
        tempoBpm: tempoBpm,
        baseTempoBpm: baseTempoBpm ?? _settings.baseTempoBpm,
        instrument: instrument,
        soundFont: _soundFont,
      ).normalized;
      await _loadRenderedSource(midiPath, settings, emitProgress: false);
    } catch (e, stackTrace) {
      log('Warm-up failed for $midiPath: $e', name: 'MidiEngine', stackTrace: stackTrace);
    }
  }

  Future<void> loadMidi(
    String midiPath, {
    int transpose = 0,
    double tempoBpm = 76,
    double? baseTempoBpm,
    int? instrument,
    bool autoplay = false,
  }) async {
    await initialize();
    final generation = ++_renderGeneration;
    _pendingRenderCount++;
    final previousPosition = _state.currentSong == midiPath
        ? Duration(milliseconds: (_state.position * 1000).round())
        : Duration.zero;

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
        position: 0,
        isLoading: true,
        loadProgress: 0.05,
        currentSong: midiPath,
      ),
    );

    try {
      final midiBytes = await _loadMidiBytes(midiPath);
      final detectedBaseTempo =
          baseTempoBpm ??
          MidiTempoDetector.detectBpm(
            midiBytes,
            fallbackBpm: _settings.baseTempoBpm,
          );
      _settings = _settings.copyWith(baseTempoBpm: detectedBaseTempo);
      final source = await _loadRenderedSource(
        midiPath,
        _settings,
        emitProgress: true,
      );
      if (_disposed || generation != _renderGeneration) return;

      _currentSource = source;
      final duration = SoLoud.instance.getLength(source);
      _setState(
        _state.copyWith(
          isLoading: false,
          loadProgress: 1,
          duration: duration.inMilliseconds / 1000,
          position: 0,
        ),
      );

      if (autoplay) {
        await play(startAt: previousPosition);
      }
    } catch (e, stackTrace) {
      log(
        'Failed to load native MIDI: $e',
        name: 'MidiEngine',
        stackTrace: stackTrace,
      );
      if (!_disposed && generation == _renderGeneration) {
        _setState(
          _state.copyWith(isPlaying: false, isLoading: false, loadProgress: 0),
        );
      }
    } finally {
      _decrementPending();
    }
  }

  void _decrementPending() {
    _pendingRenderCount--;
    if (_pendingRenderCount <= 0 && !_disposed) {
      _pendingRenderCount = 0;
      _setState(_state.copyWith(isLoading: false));
    }
  }

  Future<AudioSource> _loadRenderedSource(
    String midiPath,
    MidiRenderSettings settings, {
    bool emitProgress = false,
  }) async {
    final normalized = settings.normalized;
    final cacheKey = generateMidiPreloadKey(
      midiPath: midiPath,
      transpose: normalized.transpose,
      tempoBpm: normalized.tempoBpm,
      baseTempoBpm: normalized.baseTempoBpm,
      instrument: normalized.instrument,
      soundFont: normalized.soundFont,
    );
    final inflight = _inflightSourceLoads[cacheKey];
    if (inflight != null) {
      return inflight;
    }

    final pending = _loadRenderedSourceInternal(
      midiPath,
      normalized,
      cacheKey,
      emitProgress: emitProgress,
    );
    _inflightSourceLoads[cacheKey] = pending;
    try {
      return await pending;
    } finally {
      if (identical(_inflightSourceLoads[cacheKey], pending)) {
        _inflightSourceLoads.remove(cacheKey);
      }
    }
  }

  Future<AudioSource> _loadRenderedSourceInternal(
    String midiPath,
    MidiRenderSettings settings,
    String cacheKey, {
    required bool emitProgress,
  }) async {
    final cachedSource = _sourceCache[cacheKey];
    if (cachedSource != null) {
      _touchCacheKey(cacheKey);
      return cachedSource;
    }

    final wavFile = File(_wavCachePath(cacheKey));
    if (await wavFile.exists()) {
      final wavBytes = await wavFile.readAsBytes();
      final source = await SoLoud.instance.loadMem(
        'midi-${cacheKey.hashCode}.wav',
        wavBytes,
        mode: LoadMode.memory,
      );
      _sourceCache[cacheKey] = source;
      _touchCacheKey(cacheKey);
      await _pruneSourceCache();
      return source;
    }

    if (emitProgress) _setState(_state.copyWith(loadProgress: 0.2));
    final midiBytes = await _loadMidiBytes(midiPath);
    final soundFontBytes = await _loadSoundFontBytes(settings.soundFont);
    if (emitProgress) _setState(_state.copyWith(loadProgress: 0.35));

    final rendered = await NativeMidiRenderer.render(
      midiBytes: midiBytes,
      soundFontBytes: soundFontBytes,
      settings: settings,
    );
    if (rendered.instruments.isNotEmpty) {
      _instruments = rendered.instruments;
      if (!_disposed) notifyListeners();
    }
    if (emitProgress) _setState(_state.copyWith(loadProgress: 0.82));

    await _ensureCacheDir();
    await wavFile.writeAsBytes(rendered.wavBytes);

    final source = await SoLoud.instance.loadMem(
      'midi-${cacheKey.hashCode}.wav',
      rendered.wavBytes,
      mode: LoadMode.memory,
    );
    _sourceCache[cacheKey] = source;
    _touchCacheKey(cacheKey);
    await _pruneSourceCache();
    return source;
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
    if (_currentSource == null && _currentMidiPath != null) {
      await loadMidi(
        _currentMidiPath!,
        transpose: _settings.transpose,
        tempoBpm: _settings.tempoBpm,
        baseTempoBpm: _settings.baseTempoBpm,
        instrument: _settings.instrument,
      );
    }
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
    final handle = _currentHandle;
    if (handle != null && SoLoud.instance.getIsValidVoiceHandle(handle)) {
      SoLoud.instance.seek(
        handle,
        Duration(milliseconds: (clamped * 1000).round()),
      );
    }
    _setState(_state.copyWith(position: clamped));
    // Pause position timer briefly after seek to allow SoLoud to settle
    // and prevent the slider from jumping due to timer updates
    _positionTimer?.cancel();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_state.isPlaying && _currentHandle != null) {
        _startPositionTimer();
      }
    });
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
      log('Failed to load soundfont $soundFontFileName, falling back to TimGM6mb.sf2: $e',
          name: 'MidiEngine', stackTrace: stackTrace);
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
    _settings = nextSettings.normalized;
    if (midiPath == null) return;
    if (!force && _state.currentSong != midiPath && _currentSource == null) {
      return;
    }
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
      final position = SoLoud.instance.getPosition(handle);
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
    await _stopCurrentHandle(emit: false);
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

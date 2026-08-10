import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;

/// Lightweight HydratedBloc storage for native platforms.
///
/// State is kept in memory after startup and mirrored to small JSON files.
/// User-facing state must survive an abrupt process kill, so writes are
/// explicitly flushed to disk before the storage call completes.
class FastFileStorage implements Storage {
  static const String _blocStatePrefix = '__bloc_';

  FastFileStorage({Directory? cacheDir}) : _cacheDirOverride = cacheDir;

  final Directory? _cacheDirOverride;
  Directory? _cacheDir;
  final Map<String, String> _memoryCache = {};
  /// Last value actually flushed to disk per key. Consecutive writes of the
  /// same content (e.g. TTS word progress after transient fields are
  /// stripped) skip the synchronous disk flush entirely.
  final Map<String, String> _flushedCache = {};
  bool _initialized = false;

  void _debugLog(String message) {
    if (kDebugMode) log(message, name: 'FastFileStorage');
  }

  Future<void> init() async {
    if (_initialized) return;
    _cacheDir = _cacheDirOverride ??
        (Platform.isAndroid
            ? Directory('/data/data/id.sch.kanaan.egys/files/bloc_state')
            : await _resolveSupportDir());
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
    await _preloadCache();
    _initialized = true;
    _debugLog(
      'initialized ${_memoryCache.length} entries from ${_cacheDir!.path}',
    );
  }

  static Future<Directory> _resolveSupportDir() async {
    try {
      final support = await getApplicationSupportDirectory();
      return Directory('${support.path}/bloc_state');
    } catch (_) {
      return Directory('${Directory.systemTemp.path}/gys_bloc_state');
    }
  }

  Future<void> _preloadCache() async {
    final cacheDir = _cacheDir;
    if (cacheDir == null || !await cacheDir.exists()) return;

    await for (final entity in cacheDir.list()) {
      if (entity is! File || !entity.path.contains(_blocStatePrefix)) continue;
      try {
        final content = await entity.readAsString();
        final fileName = entity.path.split(Platform.pathSeparator).last;
        final key = fileName
            .replaceFirst(_blocStatePrefix, '')
            .replaceAll('.json', '');
        _memoryCache[key] = content;
        _flushedCache[key] = content;
      } catch (error) {
        _debugLog('unable to preload ${entity.path}: $error');
      }
    }
  }

  File _file(String key) =>
      File('${_cacheDir!.path}/$_blocStatePrefix$key.json');

  @override
  Future<void> clear() async {
    _memoryCache.clear();
    _flushedCache.clear();
    final cacheDir = _cacheDir;
    if (!_initialized || cacheDir == null || !await cacheDir.exists()) return;

    await for (final entity in cacheDir.list()) {
      if (entity is File && entity.path.contains(_blocStatePrefix)) {
        try {
          await entity.delete();
        } catch (_) {}
      }
    }
  }

  @override
  Future<void> close() async {
    _memoryCache.clear();
  }

  @override
  Future<void> delete(String key) async {
    _memoryCache.remove(key);
    _flushedCache.remove(key);
    if (!_initialized) await init();
    final file = _file(key);
    if (!await file.exists()) return;
    try {
      await file.delete();
    } catch (_) {}
  }

  @override
  dynamic read(String key) {
    final cached = _memoryCache[key];
    if (cached == null) return null;
    try {
      return jsonDecode(cached);
    } catch (error) {
      _debugLog('decode failed for $key: $error');
      return cached;
    }
  }

  @override
  Future<void> write(String key, dynamic value) async {
    if (!_initialized) await init();
    final encoded = value is String ? value : jsonEncode(value);
    _memoryCache[key] = encoded;

    // High-frequency emits (TTS word progress, audio position) can produce
    // many identical snapshots per second. Reads are already served from the
    // memory cache, so skipping the disk flush for unchanged content removes
    // the synchronous write storm from the UI thread entirely.
    if (_flushedCache[key] == encoded) return;

    // These files are deliberately tiny preference/state snapshots. A
    // synchronous flushed write is preferable here: HydratedBloc may invoke
    // Storage.write without awaiting the returned Future, and an immediate
    // Android force-kill could otherwise interrupt the pending async write.
    // Completing the disk write before this method yields makes settings much
    // more resilient to that exact lifecycle edge case.
    _file(key).writeAsStringSync(encoded, flush: true);
    _flushedCache[key] = encoded;
  }
}

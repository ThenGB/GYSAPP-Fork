import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Fast Storage for native platforms (Android, iOS, Desktop).
/// Uses Dart File I/O directly — no platform channels, no SharedPreferences.
class FastFileStorage implements Storage {
  static const String _blocStatePrefix = '__bloc_';

  Directory? _cacheDir;
  final Map<String, String> _memoryCache = {};
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _cacheDir = Directory('/data/data/id.sch.kanaan.egys/files/bloc_state');
    log('[FastFileStorage] init: cacheDir=${_cacheDir!.path}');
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
      log('[FastFileStorage] init: created cache dir');
    }
    await _preloadCache();
    _initialized = true;
    log('[FastFileStorage] init: done, preloaded ${_memoryCache.length} entries');
  }

  Future<void> _preloadCache() async {
    if (_cacheDir == null || !await _cacheDir!.exists()) {
      log('[FastFileStorage] preload: cacheDir missing');
      return;
    }
    await for (final entity in _cacheDir!.list()) {
      if (entity is File && entity.path.contains(_blocStatePrefix)) {
        try {
          final content = await entity.readAsString();
          final fileName = entity.path.split(Platform.pathSeparator).last;
          final key = fileName
              .replaceFirst(_blocStatePrefix, '')
              .replaceAll('.json', '');
          _memoryCache[key] = content;
          log('[FastFileStorage] preload: loaded key=$key (${content.length} bytes)');
        } catch (e) {
          log('[FastFileStorage] preload: error reading ${entity.path}: $e');
        }
      }
    }
  }

  File _file(String key) => File('${_cacheDir!.path}/$_blocStatePrefix$key.json');

  @override
  Future<void> clear() async {
    _memoryCache.clear();
    if (_initialized && _cacheDir != null && await _cacheDir!.exists()) {
      await for (final f in _cacheDir!.list()) {
        if (f is File && f.path.contains(_blocStatePrefix)) {
          await f.delete().catchError((_) => File(''));
        }
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
    if (!_initialized) await init();
    final f = _file(key);
    if (await f.exists()) await f.delete().catchError((_) => File(''));
  }

  @override
  dynamic read(String key) {
    final cached = _memoryCache[key];
    if (cached != null) {
      try {
        final decoded = jsonDecode(cached);
        log('[FastFileStorage] read: key=$key → HIT (${cached.length} bytes)');
        return decoded;
      } catch (e) {
        log('[FastFileStorage] read: key=$key → HIT but decode failed: $e');
        return cached;
      }
    }
    log('[FastFileStorage] read: key=$key → MISS (cache has ${_memoryCache.length} entries: ${_memoryCache.keys.toList()})');
    return null;
  }

  @override
  Future<void> write(String key, dynamic value) async {
    if (!_initialized) await init();
    final encoded = value is String ? value : jsonEncode(value);
    _memoryCache[key] = encoded;
    await _file(key).writeAsString(encoded, flush: true);
    log('[FastFileStorage] write: key=$key (${encoded.length} bytes)');
  }
}

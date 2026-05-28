import 'dart:convert';
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
    _cacheDir = Directory('/data/data/id.sch.kanaan.egys/cache/bloc_state');
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
    _initialized = true;
  }

  File _file(String key) => File('${_cacheDir!.path}/$_blocStatePrefix$key.json');

  @override
  Future<void> clear() async {
    _memoryCache.clear();
    if (_initialized && _cacheDir != null && await _cacheDir!.exists()) {
      await for (final f in _cacheDir!.list()) {
        if (f is File && f.path.contains(_blocStatePrefix)) {
          await f.delete().catchError((_) {});
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
    if (await f.exists()) await f.delete().catchError((_) {});
  }

  @override
  Future<dynamic> read(String key) async {
    final cached = _memoryCache[key];
    if (cached != null) {
      try { return jsonDecode(cached); } catch (_) { return cached; }
    }
    if (!_initialized) await init();
    final f = _file(key);
    if (!await f.exists()) return null;
    try {
      final content = await f.readAsString();
      _memoryCache[key] = content;
      return jsonDecode(content);
    } catch (_) { return null; }
  }

  @override
  Future<void> write(String key, dynamic value) async {
    if (!_initialized) await init();
    final encoded = value is String ? value : jsonEncode(value);
    _memoryCache[key] = encoded;
    await _file(key).writeAsString(encoded, flush: true);
  }
}

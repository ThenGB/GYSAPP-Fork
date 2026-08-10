// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_web_libraries_in_flutter, override_on_non_overriding_member
import 'dart:convert';
import 'dart:html' as html;

import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Fast Storage for Web platform.
/// Uses localStorage via dart:html — synchronous, always fast, no platform channels.
class FastFileStorage implements Storage {
  static const String _blocStatePrefix = '__bloc_';
  final Map<String, String> _memoryCache = {};
  /// Last value written to localStorage per key; identical consecutive writes
  /// are skipped so transient high-frequency state never touches the DOM.
  final Map<String, String> _flushedCache = {};

  FastFileStorage() {
    // localStorage is always available on web, no init needed
  }

  @override
  Future<void> init() async {
    // No-op on web — localStorage is always available
  }

  @override
  Future<void> clear() async {
    _memoryCache.clear();
    _flushedCache.clear();
    try {
      final keys = html.window.localStorage.keys
          .where((k) => k.startsWith(_blocStatePrefix))
          .toList();
      for (final k in keys) {
        html.window.localStorage.remove(k);
      }
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    _memoryCache.clear();
  }

  @override
  Future<void> delete(String key) async {
    _memoryCache.remove(key);
    _flushedCache.remove(key);
    try {
      html.window.localStorage.remove('$_blocStatePrefix$key');
    } catch (_) {}
  }

  @override
  dynamic read(String key) {
    final cached = _memoryCache[key];
    if (cached != null) {
      try { return jsonDecode(cached); } catch (_) { return cached; }
    }
    try {
      final raw = html.window.localStorage['$_blocStatePrefix$key'];
      if (raw == null) return null;
      _memoryCache[key] = raw;
      _flushedCache[key] = raw;
      return jsonDecode(raw);
    } catch (_) { return null; }
  }

  @override
  Future<void> write(String key, dynamic value) async {
    final encoded = value is String ? value : jsonEncode(value);
    _memoryCache[key] = encoded;
    if (_flushedCache[key] == encoded) return;
    try {
      html.window.localStorage['$_blocStatePrefix$key'] = encoded;
      _flushedCache[key] = encoded;
    } catch (_) {}
  }
}

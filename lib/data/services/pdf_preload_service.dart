import 'dart:async';
import 'dart:developer';

import 'package:pdfrx/pdfrx.dart' as pdfrx;

/// Service for preloading PDF documents to reduce flicker
/// when navigating between songs.
///
/// Uses an LRU cache with configurable max entries.
class PdfPreloadService {
  static const int _defaultMaxCachedDocuments = 6;

  final Map<String, pdfrx.PdfDocument> _cache = {};
  final List<String> _cacheOrder = [];
  int _maxCachedDocuments = _defaultMaxCachedDocuments;

  /// Get the current cache size limit
  int get maxCachedDocuments => _maxCachedDocuments;

  /// Set the cache size limit
  void setMaxCachedDocuments(int max) {
    _maxCachedDocuments = max.clamp(4, 32);
    _pruneCache();
  }

  /// Check if a PDF is currently cached
  bool isCached(String pdfPath) {
    return _cache.containsKey(pdfPath);
  }

  /// Get a cached PDF document if available
  pdfrx.PdfDocument? getCached(String pdfPath) {
    return _cache[pdfPath];
  }

  /// Preload a PDF document into the cache
  Future<pdfrx.PdfDocument?> preload(String pdfPath) async {
    if (_cache.containsKey(pdfPath)) {
      return _cache[pdfPath];
    }

    try {
      final document = await pdfrx.PdfDocument.openAsset(pdfPath);
      _cache[pdfPath] = document;
      _touchCacheKey(pdfPath);
      await _pruneCache();
      log('PDF preloaded: $pdfPath', name: 'PdfPreloadService');
      return document;
    } catch (e, stackTrace) {
      log('Failed to preload PDF $pdfPath: $e', name: 'PdfPreloadService',
          stackTrace: stackTrace);
      return null;
    }
  }

  /// Remove a specific document from cache
  void evict(String pdfPath) {
    final document = _cache.remove(pdfPath);
    if (document != null) {
      document.dispose();
    }
    _cacheOrder.remove(pdfPath);
  }

  /// Clear all cached documents
  Future<void> clear() async {
    for (final document in _cache.values) {
      document.dispose();
    }
    _cache.clear();
    _cacheOrder.clear();
  }

  void _touchCacheKey(String key) {
    _cacheOrder.remove(key);
    _cacheOrder.add(key);
  }

  Future<void> _pruneCache() async {
    while (_cacheOrder.length > _maxCachedDocuments) {
      final key = _cacheOrder.removeAt(0);
      final document = _cache.remove(key);
      if (document != null) {
        document.dispose();
      }
    }
  }
}

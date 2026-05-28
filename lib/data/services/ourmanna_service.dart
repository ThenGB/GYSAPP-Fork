import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentations/home/bloc/home_state.dart';

class OurMannnaService {
  static const String _cacheKey = 'ourmanna_verse';
  static const String _cacheTimestampKey = 'ourmanna_verse_timestamp';
  static const Duration _cacheDuration = Duration(hours: 24);

  final Dio _dio;

  OurMannnaService(this._dio);

  Future<OurMannaVerse?> getVerse() async {
    // Check cache first
    final cached = await _getCachedVerse();
    if (cached != null) return cached;

    // Fetch from API
    try {
      final response = await _dio.get(
        'https://beta.ourmanna.com/api/v1/get',
      );

      if (response.statusCode == 200) {
        // API returns plain text: "Verse text - Reference (Version)"
        final responseText = response.data.toString();
        final verse = _parseVerseResponse(responseText);
        if (verse != null && verse.text.isNotEmpty) {
          await _cacheVerse(verse);
          return verse;
        }
      }
    } catch (e) {
      // Return null on error - card will be hidden
    }
    return null;
  }

  /// Parses the API response which is in format:
  /// "Verse text - Reference (Version)"
  /// Example: "You are my refuge and my shield; I have put my hope in your word. - Psalm 119:114 (NIV)"
  OurMannaVerse? _parseVerseResponse(String response) {
    try {
      // Split by " - " to separate verse text from reference
      final parts = response.split(' - ');
      if (parts.length < 2) return null;

      final text = parts[0].trim();
      final refWithVersion = parts.sublist(1).join(' - ').trim();

      // Remove version in parentheses, e.g., " (NIV)"
      String reference = refWithVersion;
      final versionMatch = RegExp(r'\s*\([^)]+\)\s*$').firstMatch(refWithVersion);
      if (versionMatch != null) {
        reference = refWithVersion.substring(0, versionMatch.start).trim();
      }

      if (text.isEmpty || reference.isEmpty) return null;

      return OurMannaVerse(text: text, reference: reference);
    } catch (e) {
      return null;
    }
  }

  Future<OurMannaVerse?> _getCachedVerse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);
      if (timestamp == null) return null;

      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cachedTime) > _cacheDuration) {
        return null;
      }

      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson == null) return null;

      final data = jsonDecode(cachedJson);
      return OurMannaVerse.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheVerse(OurMannaVerse verse) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(verse.toJson()));
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Ignore cache errors
    }
  }
}
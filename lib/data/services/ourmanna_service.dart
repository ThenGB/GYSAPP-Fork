import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OurMannnaService {
  static const String _cacheKey = 'ourmanna_verse';
  static const String _cacheTimestampKey = 'ourmanna_verse_timestamp';
  static const Duration _cacheDuration = Duration(hours: 24);

  final Dio _dio;

  OurMannaService(this._dio);

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
        final data = response.data;
        final verse = OurMannaVerse(
          text: data['verse'] ?? '',
          reference: data['reference'] ?? '',
        );
        if (verse.text.isNotEmpty) {
          await _cacheVerse(verse);
          return verse;
        }
      }
    } catch (e) {
      // Return null on error - card will be hidden
    }
    return null;
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

class OurMannaVerse {
  final String text;
  final String reference;

  OurMannaVerse({required this.text, required this.reference});

  factory OurMannaVerse.fromJson(Map<String, dynamic> json) {
    return OurMannaVerse(
      text: json['text'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'text': text, 'reference': reference};
}

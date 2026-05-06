import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class FirebaseStorageHelper {
  static const _bucket = 'hatiku-4c1de.appspot.com';
  static const _baseUrl = 'https://firebasestorage.googleapis.com/v0/b/$_bucket/o';

  static bool _quotaExceeded = false;
  static DateTime? _quotaExceededAt;
  static const _quotaRetryHours = 1;

  static bool get isQuotaExceeded {
    if (_quotaExceeded && _quotaExceededAt != null) {
      if (DateTime.now().difference(_quotaExceededAt!).inHours >= _quotaRetryHours) {
        _quotaExceeded = false;
        _quotaExceededAt = null;
      }
    }
    return _quotaExceeded;
  }

  static void resetQuotaState() {
    _quotaExceeded = false;
    _quotaExceededAt = null;
  }

  static String get quotaExceededMessage =>
      'Kuota penyimpanan Firebase telah terlampaui. '
      'Silakan coba lagi nanti atau hubungi administrator.';

  static void handleError(Object e) {
    if (e is FirebaseException && e.code == 'quota-exceeded') {
      _quotaExceeded = true;
      _quotaExceededAt = DateTime.now();
      log('Firebase Storage quota exceeded', name: 'Storage');
    }
  }

  static Future<RestListResult> restListFiles(String path) async {
    final encodedPrefix =
        Uri.encodeComponent(path.endsWith('/') ? path : '$path/');
    final response = await http
        .get(Uri.parse('$_baseUrl?prefix=$encodedPrefix'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) return RestListResult([], []);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (decoded['items'] as List<dynamic>? ?? []);
    final files = <String>[];
    final prefixes = <String>[];

    for (final item in items) {
      final name =
          (item as Map<String, dynamic>)['name'] as String? ?? '';
      if (name.isEmpty) continue;
      final relative = name.startsWith('$path/')
          ? name.substring('$path/'.length)
          : name;
      if (relative.contains('/')) {
        final prefix = relative.split('/').first;
        if (!prefixes.contains('$path/$prefix')) {
          prefixes.add('$path/$prefix');
        }
      } else {
        files.add(name);
      }
    }
    return RestListResult(files, prefixes);
  }

  static String restMediaUrl(String objectPath) {
    return '$_baseUrl/${Uri.encodeComponent(objectPath)}?alt=media';
  }
}

class RestListResult {
  final List<String> files;
  final List<String> prefixes;

  RestListResult(this.files, this.prefixes);

  List<String> get fileNames => files.map((f) => f.split('/').last).toList();
}

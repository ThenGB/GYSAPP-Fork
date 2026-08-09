import 'dart:convert';

import 'package:http/http.dart' as http;

class FaithPdfDocument {
  const FaithPdfDocument({
    required this.beliefNumber,
    required this.name,
    required this.uri,
  });

  final int beliefNumber;
  final String name;
  final Uri uri;
}

/// Resolves the explanatory PDFs that historically lived under the
/// `10dasar/` folder. The old implementation depended on the Firebase SDK,
/// a cache manager and native file opening. This version uses the public
/// Storage REST surface only, keeps one small in-memory catalog, and returns
/// an HTTPS URI that works on Android, iOS, Windows and Web.
class FaithPdfService {
  FaithPdfService({http.Client? client}) : _client = client ?? http.Client();

  static const _bucket = 'hatiku-4c1de.appspot.com';
  static const _folder = '10dasar/';
  static const _host = 'firebasestorage.googleapis.com';

  final http.Client _client;
  Map<int, String>? _catalog;
  DateTime? _catalogFetchedAt;

  Future<FaithPdfDocument?> documentFor(int beliefNumber) async {
    final catalog = await _loadCatalog();
    final objectName = catalog[beliefNumber];
    if (objectName == null || objectName.isEmpty) return null;

    final encodedObject = Uri.encodeComponent(objectName);
    final uri = Uri.parse(
      'https://$_host/v0/b/$_bucket/o/$encodedObject?alt=media',
    );
    if (uri.scheme != 'https' || uri.host != _host) return null;

    return FaithPdfDocument(
      beliefNumber: beliefNumber,
      name: objectName.split('/').last,
      uri: uri,
    );
  }

  Future<Map<int, String>> _loadCatalog() async {
    final fetchedAt = _catalogFetchedAt;
    final cached = _catalog;
    if (cached != null &&
        fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < const Duration(hours: 1)) {
      return cached;
    }

    try {
      final uri = Uri.https(
        _host,
        '/v0/b/$_bucket/o',
        const {'prefix': _folder},
      );
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return cached ?? const {};

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return cached ?? const {};
      final items = decoded['items'];
      if (items is! List) return cached ?? const {};

      final result = <int, String>{};
      for (final item in items) {
        if (item is! Map) continue;
        final objectName = item['name']?.toString() ?? '';
        if (!objectName.startsWith(_folder)) continue;
        final filename = objectName.substring(_folder.length);
        final number = int.tryParse(filename.split('-').first);
        if (number == null || number < 1 || number > 10) continue;
        result.putIfAbsent(number, () => objectName);
      }

      _catalog = result;
      _catalogFetchedAt = DateTime.now();
      return result;
    } catch (_) {
      return cached ?? const {};
    }
  }

  void dispose() => _client.close();
}

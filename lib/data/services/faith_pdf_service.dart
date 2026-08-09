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

/// Resolves the explanatory PDFs for the Ten Basic Beliefs from the same
/// public GitHub data repository that distributes Bibles, hymnals and
/// SoundFonts. No Firebase SDK/API is used by the application.
class FaithPdfService {
  FaithPdfService({http.Client? client}) : _client = client ?? http.Client();

  static const _manifestUri =
      'https://raw.githubusercontent.com/ThenGB/GYSApp-Data/main/latest/faith-pdfs-manifest.json';
  static const _allowedDownloadHost = 'github.com';

  final http.Client _client;
  Map<int, FaithPdfDocument>? _catalog;
  DateTime? _catalogFetchedAt;

  Future<FaithPdfDocument?> documentFor(int beliefNumber) async {
    if (beliefNumber < 1 || beliefNumber > 10) return null;
    final catalog = await _loadCatalog();
    return catalog[beliefNumber];
  }

  Future<Map<int, FaithPdfDocument>> _loadCatalog() async {
    final fetchedAt = _catalogFetchedAt;
    final cached = _catalog;
    if (cached != null &&
        fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < const Duration(hours: 1)) {
      return cached;
    }

    try {
      final response = await _client
          .get(Uri.parse(_manifestUri))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return cached ?? const {};

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> ||
          decoded['kind'] != 'faith-pdfs' ||
          decoded['schemaVersion'] != 1) {
        return cached ?? const {};
      }

      final rawItems = decoded['items'];
      if (rawItems is! List) return cached ?? const {};

      final result = <int, FaithPdfDocument>{};
      for (final raw in rawItems) {
        if (raw is! Map) continue;
        final number = int.tryParse(raw['number']?.toString() ?? '');
        final name = raw['name']?.toString().trim() ?? '';
        final downloadUrl = raw['downloadUrl']?.toString().trim() ?? '';
        final uri = Uri.tryParse(downloadUrl);
        if (number == null || number < 1 || number > 10) continue;
        if (name.isEmpty || uri == null) continue;
        if (uri.scheme != 'https' || uri.host != _allowedDownloadHost) continue;
        if (!uri.path.startsWith('/ThenGB/GYSApp-Data/releases/download/')) {
          continue;
        }
        result.putIfAbsent(
          number,
          () => FaithPdfDocument(
            beliefNumber: number,
            name: name,
            uri: uri,
          ),
        );
      }

      if (result.length == 10) {
        _catalog = result;
        _catalogFetchedAt = DateTime.now();
        return result;
      }
      return cached ?? result;
    } catch (_) {
      return cached ?? const {};
    }
  }

  void dispose() => _client.close();
}

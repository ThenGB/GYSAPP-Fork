import 'dart:convert';
import 'dart:developer' as developer;

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
  static const _releaseApiBase =
      'https://api.github.com/repos/ThenGB/GYSApp-Data/releases/tags/';

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
      var manifestNeedsReleaseResolution = false;
      for (final raw in rawItems) {
        if (raw is! Map) continue;
        final number = int.tryParse(raw['number']?.toString() ?? '');
        final rawName = raw['name']?.toString().trim() ?? '';
        final rawDownloadUrl = raw['downloadUrl']?.toString().trim() ?? '';
        if (number == null || number < 1 || number > 10) continue;
        if (rawName.isEmpty || rawDownloadUrl.isEmpty) continue;

        final wasLegacyName =
            rawName.contains(' ') || rawDownloadUrl.contains('%20');
        final sourceUri = Uri.tryParse(rawDownloadUrl);
        // Validate the publisher-controlled URL before normalizing its legacy
        // filename. Rebuilding a URI from decoded path segments can change its
        // canonical representation, but it cannot broaden an already-checked
        // host/release prefix.
        if (sourceUri == null || !_isAllowedReleaseUri(sourceUri)) continue;
        final uri = _normalizeLegacyReleaseUri(sourceUri, wasLegacyName);
        final name = wasLegacyName ? rawName.replaceAll(' ', '.') : rawName;

        manifestNeedsReleaseResolution |= wasLegacyName;
        result.putIfAbsent(
          number,
          () => FaithPdfDocument(
            beliefNumber: number,
            name: name,
            uri: uri,
          ),
        );
      }

      final tag = decoded['tag']?.toString().trim() ?? '';
      final resolved = manifestNeedsReleaseResolution && tag.isNotEmpty
          ? await _resolveReleaseAssets(tag, fallback: result)
          : result;

      if (resolved.length == 10) {
        _catalog = resolved;
        _catalogFetchedAt = DateTime.now();
      }
      return resolved.isNotEmpty ? resolved : (cached ?? const {});
    } catch (error, stackTrace) {
      developer.log(
        'Unable to load the faith PDF catalog',
        name: 'FaithPdfService',
        error: error,
        stackTrace: stackTrace,
      );
      return cached ?? const {};
    }
  }

  Future<Map<int, FaithPdfDocument>> _resolveReleaseAssets(
    String tag, {
    required Map<int, FaithPdfDocument> fallback,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_releaseApiBase${Uri.encodeComponent(tag)}'),
            headers: const {
              'Accept': 'application/vnd.github+json',
              'X-GitHub-Api-Version': '2022-11-28',
              'User-Agent': 'GYS-App',
            },
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return fallback;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return fallback;
      final assets = decoded['assets'];
      if (assets is! List) return fallback;

      final resolved = Map<int, FaithPdfDocument>.from(fallback);
      for (final raw in assets) {
        if (raw is! Map) continue;
        final name = raw['name']?.toString().trim() ?? '';
        if (!name.toLowerCase().endsWith('.pdf')) continue;
        final match = RegExp(r'^(\d{2})-').firstMatch(name);
        final number = int.tryParse(match?.group(1) ?? '');
        final uri = Uri.tryParse(
          raw['browser_download_url']?.toString().trim() ?? '',
        );
        if (number == null || number < 1 || number > 10 || uri == null) {
          continue;
        }
        if (!_isAllowedReleaseUri(uri)) continue;
        resolved[number] = FaithPdfDocument(
          beliefNumber: number,
          name: name,
          uri: uri,
        );
      }
      return resolved;
    } catch (error, stackTrace) {
      developer.log(
        'Unable to resolve faith PDF release assets',
        name: 'FaithPdfService',
        error: error,
        stackTrace: stackTrace,
      );
      return fallback;
    }
  }

  bool _isAllowedReleaseUri(Uri uri) {
    final path = uri.pathSegments;
    return uri.scheme.toLowerCase() == 'https' &&
        uri.host.toLowerCase() == _allowedDownloadHost &&
        path.length >= 5 &&
        path[0].toLowerCase() == 'thengb' &&
        path[1].toLowerCase() == 'gysapp-data' &&
        path[2].toLowerCase() == 'releases' &&
        path[3].toLowerCase() == 'download';
  }

  Uri _normalizeLegacyReleaseUri(Uri uri, bool isLegacy) {
    if (!isLegacy) return uri;
    final normalized = uri
        .toString()
        .replaceAll(RegExp('%20', caseSensitive: false), '.')
        .replaceAll(' ', '.');
    return Uri.parse(normalized);
  }

  void dispose() => _client.close();
}

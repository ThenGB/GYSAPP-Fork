import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'models.dart';

typedef ProgressCallback = void Function(int received, int total);

class GitHubTrackRelease {
  const GitHubTrackRelease({
    required this.tagName,
    required this.manifestUrl,
    required this.publishedAt,
  });

  final String tagName;
  final String manifestUrl;
  final DateTime publishedAt;
}

class GitHubReleaseAssetClient {
  GitHubReleaseAssetClient(
    this._dio, {
    this.owner = 'ThenGB',
    this.repo = 'GYSApp-Data',
  });

  final Dio _dio;
  final String owner;
  final String repo;

  static const _manifestNames = {
    AssetReleaseTrack.bibles: 'bibles-manifest.json',
    AssetReleaseTrack.hymnals: 'hymnals-manifest.json',
    AssetReleaseTrack.soundfont: 'soundfont-manifest.json',
  };

  Future<RemoteAssetManifest?> fetchLatestManifest(
    AssetReleaseTrack track,
  ) async {
    final stableManifest = await _fetchStableManifest(track);
    if (stableManifest != null) {
      return stableManifest;
    }

    final response = await _dio.get<dynamic>(
      'https://api.github.com/repos/$owner/$repo/releases',
      options: Options(
        headers: const {
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      ),
    );
    final releases = _decodeJsonList(response.data);
    final selected = selectLatestReleaseForTrack(releases, track);
    if (selected == null) return null;

    final manifestResponse = await _dio.get<dynamic>(selected.manifestUrl);
    return parseManifest(_decodeJsonMap(manifestResponse.data), track);
  }

  Future<RemoteAssetManifest?> _fetchStableManifest(
    AssetReleaseTrack track,
  ) async {
    final manifestName = _manifestNames[track];
    if (manifestName == null) {
      return null;
    }

    try {
      final response = await _dio.get<dynamic>(
        'https://raw.githubusercontent.com/$owner/$repo/main/latest/$manifestName',
      );
      return parseManifest(_decodeJsonMap(response.data), track);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> downloadPackage(
    RemoteAssetPackage package,
    String destinationPath, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    await _dio.download(
      package.downloadUrl,
      destinationPath,
      onReceiveProgress: onProgress,
      cancelToken: cancelToken,
    );
  }

  /// Downloads a package as raw bytes (web only).
  ///
  /// Dio's `download(url, savePath)` is not implemented on web (it throws
  /// `UnimplementedError`), so web fetches bytes; native uses the streaming
  /// [downloadPackage] file path instead so large assets never sit fully in
  /// memory.
  Future<Uint8List> downloadPackageBytes(
    RemoteAssetPackage package, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<List<int>>(
      package.downloadUrl,
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: onProgress,
      cancelToken: cancelToken,
    );
    return Uint8List.fromList(response.data ?? const []);
  }

  static GitHubTrackRelease? selectLatestReleaseForTrack(
    List<Map<String, dynamic>> releases,
    AssetReleaseTrack track,
  ) {
    final prefix = '${track.name}-';
    final manifestName = _manifestNames[track];
    final candidates =
        releases.where((release) {
          if (release['draft'] == true || release['prerelease'] == true) {
            return false;
          }
          final tag = release['tag_name'] as String? ?? '';
          if (!tag.startsWith(prefix)) return false;
          final assets = (release['assets'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>();
          return assets.any((asset) => asset['name'] == manifestName);
        }).toList()..sort((a, b) {
          final aDate =
              DateTime.tryParse(a['published_at'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bDate =
              DateTime.tryParse(b['published_at'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });

    if (candidates.isEmpty) return null;
    final release = candidates.first;
    final assets = (release['assets'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final manifestAsset = assets.firstWhere(
      (asset) => asset['name'] == manifestName,
    );
    return GitHubTrackRelease(
      tagName: release['tag_name'] as String? ?? '',
      manifestUrl: manifestAsset['browser_download_url'] as String? ?? '',
      publishedAt:
          DateTime.tryParse(release['published_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static RemoteAssetManifest parseManifest(
    Map<String, dynamic> json,
    AssetReleaseTrack expectedTrack,
  ) {
    final trackName = json['track'] as String? ?? expectedTrack.name;
    final track = AssetReleaseTrack.values.byName(trackName);
    final packages = (json['packages'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(RemoteAssetPackage.fromJson)
        .toList();
    return RemoteAssetManifest(
      track: track,
      releaseTag: json['releaseTag'] as String? ?? '',
      publishedAt:
          DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      packages: packages,
    );
  }

  static List<Map<String, dynamic>> _decodeJsonList(dynamic data) {
    final normalized = switch (data) {
      List<dynamic> list => list,
      String value => jsonDecode(value) as List<dynamic>,
      null => const <dynamic>[],
      _ => throw const FormatException('Expected a JSON array response.'),
    };
    return normalized.map(_coerceMap).toList();
  }

  static Map<String, dynamic> _decodeJsonMap(dynamic data) {
    return switch (data) {
      Map<String, dynamic> value => value,
      Map<dynamic, dynamic> value => value.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      String value => _coerceMap(jsonDecode(value)),
      null => const <String, dynamic>{},
      _ => throw const FormatException('Expected a JSON object response.'),
    };
  }

  static Map<String, dynamic> _coerceMap(dynamic value) {
    return switch (value) {
      Map<String, dynamic> map => map,
      Map<dynamic, dynamic> map => map.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      _ => throw const FormatException('Expected a JSON object entry.'),
    };
  }
}

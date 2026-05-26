import 'dart:convert';
import 'dart:typed_data';

import 'package:church/data/services/asset_distribution/github_release_asset_client.dart';
import 'package:church/data/services/asset_distribution/models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'selects newest matching release for a track and ignores prereleases',
    () {
      final releases = [
        {
          'tag_name': 'hymnals-2026.05.10',
          'prerelease': false,
          'draft': false,
          'published_at': '2026-05-10T10:00:00Z',
          'assets': [
            {
              'name': 'hymnals-manifest.json',
              'browser_download_url': 'https://example.com/hymnals-1.json',
            },
          ],
        },
        {
          'tag_name': 'hymnals-2026.05.20',
          'prerelease': true,
          'draft': false,
          'published_at': '2026-05-20T10:00:00Z',
          'assets': [
            {
              'name': 'hymnals-manifest.json',
              'browser_download_url': 'https://example.com/hymnals-pre.json',
            },
          ],
        },
        {
          'tag_name': 'hymnals-2026.05.21',
          'prerelease': false,
          'draft': false,
          'published_at': '2026-05-21T10:00:00Z',
          'assets': [
            {
              'name': 'hymnals-manifest.json',
              'browser_download_url': 'https://example.com/hymnals-2.json',
            },
          ],
        },
      ];

      final selected = GitHubReleaseAssetClient.selectLatestReleaseForTrack(
        releases,
        AssetReleaseTrack.hymnals,
      );

      expect(selected, isNotNull);
      expect(selected!.tagName, 'hymnals-2026.05.21');
      expect(selected.manifestUrl, 'https://example.com/hymnals-2.json');
    },
  );

  test('parses release manifest into remote package entries', () {
    final manifest = GitHubReleaseAssetClient.parseManifest({
      'track': 'bibles',
      'releaseTag': 'bibles-2026.05.21',
      'publishedAt': '2026-05-21T00:00:00Z',
      'packages': [
        {
          'code': 'b_kjv',
          'version': '2026.05.21',
          'fileName': 'b_kjv.gyspkg',
          'downloadUrl': 'https://example.com/b_kjv.gyspkg',
          'installFileName': 'b_kjv.db',
          'sizeBytes': 123,
        },
      ],
    }, AssetReleaseTrack.bibles);

    expect(manifest.releaseTag, 'bibles-2026.05.21');
    expect(manifest.track, AssetReleaseTrack.bibles);
    expect(manifest.packages.single.code, 'b_kjv');
    expect(manifest.packages.single.installFileName, 'b_kjv.db');
  });

  test('fetchLatestManifest prefers stable raw manifest payloads', () async {
    final dio = Dio()..httpClientAdapter = _FakeGitHubAdapter();
    final client = GitHubReleaseAssetClient(dio);

    final manifest = await client.fetchLatestManifest(
      AssetReleaseTrack.hymnals,
    );

    expect(manifest, isNotNull);
    expect(manifest!.releaseTag, 'hymnals-2026.05.21');
    expect(manifest.packages.single.code, 'HYMNE');
    expect(manifest.packages.single.installFileName, 'hymne_master.pdf');
  });

  test(
    'fetchLatestManifest falls back to releases API on 404 stable manifest',
    () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeGitHubAdapter(return404ForStable: true);
      final client = GitHubReleaseAssetClient(dio);

      final manifest = await client.fetchLatestManifest(
        AssetReleaseTrack.hymnals,
      );

      expect(manifest, isNotNull);
      expect(manifest!.releaseTag, 'hymnals-2026.05.21');
      expect(manifest.packages.single.code, 'HYMNE_FALLBACK');
    },
  );
}

class _FakeGitHubAdapter implements HttpClientAdapter {
  _FakeGitHubAdapter({this.return404ForStable = false});

  final bool return404ForStable;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path ==
        'https://raw.githubusercontent.com/ThenGB/GYSApp-Data/main/latest/hymnals-manifest.json') {
      if (return404ForStable) {
        return ResponseBody.fromString('Not found', 404);
      }
      return ResponseBody.fromString(
        jsonEncode({
          'track': 'hymnals',
          'releaseTag': 'hymnals-2026.05.21',
          'publishedAt': '2026-05-21T10:00:00Z',
          'packages': [
            {
              'code': 'HYMNE',
              'version': '2026.05.21',
              'fileName': 'hymne.gyspkg',
              'downloadUrl': 'https://example.com/hymne.gyspkg',
              'installFileName': 'hymne_master.pdf',
              'sizeBytes': 123,
            },
          ],
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['text/plain'],
        },
      );
    }

    if (options.path.endsWith('/releases')) {
      return ResponseBody.fromString(
        jsonEncode([
          {
            'tag_name': 'hymnals-2026.05.21',
            'prerelease': false,
            'draft': false,
            'published_at': '2026-05-21T10:00:00Z',
            'assets': [
              {
                'name': 'hymnals-manifest.json',
                'browser_download_url':
                    'https://example.com/hymnals-manifest.json',
              },
            ],
          },
        ]),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }

    if (options.path == 'https://example.com/hymnals-manifest.json') {
      return ResponseBody.fromString(
        jsonEncode({
          'track': 'hymnals',
          'releaseTag': 'hymnals-2026.05.21',
          'publishedAt': '2026-05-21T10:00:00Z',
          'packages': [
            {
              'code': 'HYMNE_FALLBACK',
              'version': '2026.05.21',
              'fileName': 'hymne_fallback.gyspkg',
              'downloadUrl': 'https://example.com/hymne_fallback.gyspkg',
              'installFileName': 'hymne_fallback.pdf',
              'sizeBytes': 123,
            },
          ],
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }

    return ResponseBody.fromString('Not found', 404);
  }
}

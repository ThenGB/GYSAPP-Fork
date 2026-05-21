import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  final version = options['version'];
  if (version == null || version.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/asset_distribution/publish_release_assets.dart --version=2026.05.21',
    );
    exitCode = 64;
    return;
  }

  final token = Platform.environment['GITHUB_TOKEN'];
  if (token == null || token.isEmpty) {
    stderr.writeln('Missing GITHUB_TOKEN environment variable.');
    exitCode = 78;
    return;
  }

  final owner = options['owner'] ?? 'ThenGB';
  final repo = options['repo'] ?? 'GYSApp-Data';
  final inputRoot = Directory(
    options['input'] ?? 'build/asset_distribution/$version',
  );
  if (!await inputRoot.exists()) {
    stderr.writeln('Missing packaged asset directory: ${inputRoot.path}');
    exitCode = 66;
    return;
  }

  final publisher = GitHubReleasePublisher(
    dio: Dio(
      BaseOptions(
        headers: {
          'Accept': 'application/vnd.github+json',
          'Authorization': 'Bearer $token',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      ),
    ),
    owner: owner,
    repo: repo,
  );

  await publisher.publishTrackDirectory(
    releaseTag: 'bibles-$version',
    trackDirectory: Directory('${inputRoot.path}/bibles'),
    releaseName: 'Alkitab $version',
    body:
        'Encrypted Alkitab release for GYS App. Files are intended for in-app download and decryption only.',
  );
  await publisher.publishTrackDirectory(
    releaseTag: 'hymnals-$version',
    trackDirectory: Directory('${inputRoot.path}/hymnals'),
    releaseName: 'Hymnal $version',
    body:
        'Encrypted hymnal release for GYS App. Files are intended for in-app download and decryption only.',
  );
}

class GitHubReleasePublisher {
  GitHubReleasePublisher({
    required this.dio,
    required this.owner,
    required this.repo,
  });

  final Dio dio;
  final String owner;
  final String repo;

  Future<void> publishTrackDirectory({
    required String releaseTag,
    required Directory trackDirectory,
    required String releaseName,
    required String body,
  }) async {
    if (!await trackDirectory.exists()) {
      stdout.writeln(
        'Skipping missing track directory: ${trackDirectory.path}',
      );
      return;
    }

    final files = await trackDirectory
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .toList();
    if (files.isEmpty) {
      stdout.writeln('Skipping empty track directory: ${trackDirectory.path}');
      return;
    }

    final release = await _findOrCreateRelease(
      releaseTag: releaseTag,
      releaseName: releaseName,
      body: body,
    );
    final existingAssets = (release['assets'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((asset) => Map<String, dynamic>.from(asset))
        .toList();
    final uploadUrl = (release['upload_url'] as String).split('{').first;

    for (final file in files) {
      final fileName = file.uri.pathSegments.last;
      final matchingAsset = existingAssets
          .cast<Map<String, dynamic>?>()
          .firstWhere(
            (asset) => asset?['name'] == fileName,
            orElse: () => null,
          );
      if (matchingAsset != null) {
        await dio.delete(
          'https://api.github.com/repos/$owner/$repo/releases/assets/${matchingAsset['id']}',
        );
      }

      await dio.post(
        uploadUrl,
        queryParameters: {'name': fileName},
        data: await file.readAsBytes(),
        options: Options(
          contentType: 'application/octet-stream',
          headers: {'Content-Length': await file.length()},
        ),
      );
      stdout.writeln('Uploaded $fileName to $owner/$repo@$releaseTag');
    }

    final manifestFile = files.cast<File?>().firstWhere(
      (file) => file?.uri.pathSegments.last.endsWith('-manifest.json') ?? false,
      orElse: () => null,
    );
    if (manifestFile != null) {
      await _publishStableManifest(
        releaseTag: releaseTag,
        manifestFile: manifestFile,
      );
    }
  }

  Future<Map<String, dynamic>> _findOrCreateRelease({
    required String releaseTag,
    required String releaseName,
    required String body,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        'https://api.github.com/repos/$owner/$repo/releases/tags/$releaseTag',
      );
      return response.data ?? const {};
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) rethrow;
    }

    final response = await dio.post<Map<String, dynamic>>(
      'https://api.github.com/repos/$owner/$repo/releases',
      data: jsonEncode({
        'tag_name': releaseTag,
        'name': releaseName,
        'body': body,
        'draft': false,
        'prerelease': false,
      }),
      options: Options(contentType: Headers.jsonContentType),
    );
    return response.data ?? const {};
  }

  Future<void> _publishStableManifest({
    required String releaseTag,
    required File manifestFile,
  }) async {
    final manifestName = manifestFile.uri.pathSegments.last;
    final contentPath = 'latest/$manifestName';
    String? sha;

    try {
      final existing = await dio.get<Map<String, dynamic>>(
        'https://api.github.com/repos/$owner/$repo/contents/$contentPath',
      );
      sha = existing.data?['sha'] as String?;
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) rethrow;
    }

    await dio.put<Map<String, dynamic>>(
      'https://api.github.com/repos/$owner/$repo/contents/$contentPath',
      data: jsonEncode({
        'message': 'Update $manifestName for $releaseTag',
        'content': base64Encode(await manifestFile.readAsBytes()),
        'branch': 'main',
        if (sha != null) 'sha': sha,
      }),
      options: Options(contentType: Headers.jsonContentType),
    );
    stdout.writeln('Updated stable manifest $contentPath for $releaseTag');
  }
}

Map<String, String> _parseArgs(List<String> args) {
  final result = <String, String>{};
  for (final arg in args) {
    if (!arg.startsWith('--') || !arg.contains('=')) continue;
    final split = arg.substring(2).split('=');
    if (split.length != 2) continue;
    result[split.first] = split.last;
  }
  return result;
}

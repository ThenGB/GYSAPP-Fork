import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../di/injection.dart';

/// Result of a chord sync pass against the gyschordweb repository.
class ChordSyncResult {
  const ChordSyncResult({
    required this.downloaded,
    required this.updated,
    required this.skipped,
    required this.failed,
  });

  final int downloaded;
  final int updated;
  final int skipped;
  final int failed;

  bool get changed => downloaded + updated > 0;

  @override
  String toString() =>
      'ChordSyncResult(downloaded: $downloaded, updated: $updated, '
      'skipped: $skipped, failed: $failed)';
}

/// Syncs chord JSON files from the gyschordweb repository
/// (github.com/gyspnk/gyschordweb, `docs/assets/chord/`) into the app's
/// support directory. Only files whose Git blob SHA differs from the last
/// synced state are re-downloaded, so unchanged chords are never fetched
/// again. The files are no longer bundled with the app.
class ChordSyncService {
  ChordSyncService(this._appDirectory, this._http);

  final AppDirectory _appDirectory;
  final http.Client _http;

  static const String repoOwner = 'gyspnk';
  static const String repoName = 'gyschordweb';
  static const String defaultBranch = 'main';
  static const String chordDir = 'docs/assets/chord';

  static const String _apiBase =
      'https://api.github.com/repos/$repoOwner/$repoName';
  static const String _rawBase =
      'https://raw.githubusercontent.com/$repoOwner/$repoName/$defaultBranch';

  String get _chordFolder => _appDirectory.chordFolder;
  String get _statePath => '$_chordFolder/sync_state.json';

  Directory get chordDirectory => Directory(_chordFolder);

  /// Fetches the remote chord list with blob SHAs, downloads every chord
  /// whose SHA differs from the last sync, and persists the new state.
  /// Returns the counts so callers can decide whether to notify the user.
  Future<ChordSyncResult> sync() async {
    final remote = await _fetchRemoteChords();
    if (remote == null) {
      return const ChordSyncResult(
        downloaded: 0,
        updated: 0,
        skipped: 0,
        failed: 0,
      );
    }

    final state = await _loadState();
    var downloaded = 0;
    var updated = 0;
    var skipped = 0;
    var failed = 0;

    await Directory(_chordFolder).create(recursive: true);

    for (final entry in remote.entries) {
      final fileName = entry.key;
      final sha = entry.value;
      try {
        if (state[fileName] == sha) {
          skipped++;
          continue;
        }
        final response = await _http.get(
          Uri.parse('$_rawBase/$chordDir/$fileName'),
        );
        if (response.statusCode != 200) {
          failed++;
          continue;
        }
        final target = File('$_chordFolder/$fileName');
        await target.writeAsBytes(response.bodyBytes, flush: true);
        if (state.containsKey(fileName)) {
          updated++;
        } else {
          downloaded++;
        }
        state[fileName] = sha;
      } catch (e) {
        failed++;
      }
    }

    // Drop local files that no longer exist upstream so the app follows
    // the repository's availability.
    final localDir = Directory(_chordFolder);
    if (await localDir.exists()) {
      await for (final entity in localDir.list()) {
        if (entity is File && entity.path.endsWith('.chord.json')) {
          final name = entity.uri.pathSegments.last;
          if (!remote.containsKey(name)) {
            try {
              await entity.delete();
              state.remove(name);
            } catch (_) {}
          }
        }
      }
    }

    await _saveState(state);
    return ChordSyncResult(
      downloaded: downloaded,
      updated: updated,
      skipped: skipped,
      failed: failed,
    );
  }

  /// Deletes every synced chord file and the sync state so the next sync
  /// re-downloads everything from the repository.
  Future<void> reset() async {
    final dir = Directory(_chordFolder);
    if (await dir.exists()) {
      try {
        await dir.delete(recursive: true);
      } catch (_) {}
    }
  }

  /// Resolves an installed chord file for a song, or null when the sync
  /// has not provided it yet. Tries the exact basename first (the song
  /// index writes underscores while gyschordweb uses spaces), then falls
  /// back to matching by song number regardless of title spelling.
  Future<String?> resolveInstalledChordPath(String? chordFile) async {
    if (chordFile == null || chordFile.trim().isEmpty) return null;
    final fileName = chordFile.replaceAll('\\', '/').split('/').last;
    if (!fileName.endsWith('.chord.json')) return null;

    for (final name in {fileName, fileName.replaceAll('_', ' '), fileName.replaceAll(' ', '_')}) {
      final candidate = File('$_chordFolder/$name');
      if (await candidate.exists()) return candidate.path;
    }

    final numberMatch = RegExp(r'(\d+)[._\-]').firstMatch(fileName);
    if (numberMatch != null) {
      final number = numberMatch.group(1)!;
      final dir = Directory(_chordFolder);
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File && entity.path.endsWith('.chord.json')) {
            final stored = entity.uri.pathSegments.last;
            if (stored.startsWith('$number.') ||
                stored.startsWith('${number}_') ||
                stored.startsWith('$number-')) {
              return entity.path;
            }
          }
        }
      }
    }
    return null;
  }

  Future<Map<String, String>?> _fetchRemoteChords() async {
    try {
      final response = await _http.get(
        Uri.parse(
          '$_apiBase/git/trees/$defaultBranch?recursive=1',
        ),
        headers: const {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'church-app',
        },
      );
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final tree = body['tree'] as List<dynamic>? ?? const [];
      final chords = <String, String>{};
      for (final node in tree) {
        final path = (node as Map<String, dynamic>)['path'] as String?;
        final type = node['type'] as String?;
        if (type == 'blob' &&
            path != null &&
            path.startsWith('$chordDir/') &&
            path.endsWith('.chord.json')) {
          chords[path.split('/').last] = node['sha'] as String? ?? '';
        }
      }
      return chords;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> _loadState() async {
    final file = File(_statePath);
    if (!await file.exists()) return {};
    try {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveState(Map<String, String> state) async {
    try {
      final file = File(_statePath);
      await file.parent.create(recursive: true);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(state),
        flush: true,
      );
    } catch (_) {}
  }
}

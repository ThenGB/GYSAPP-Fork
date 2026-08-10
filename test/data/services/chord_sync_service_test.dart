import 'dart:convert';
import 'dart:io';

import 'package:church/data/services/asset_distribution/installed_asset_store.dart';
import 'package:church/data/services/asset_distribution/installed_asset_store_io.dart';
import 'package:church/data/services/chord_sync_service.dart';
import 'package:church/di/injection.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _validChordJson = '{"version":2,"type":"note-aligned","pages":{"1":[]}}';

String _sha256(String text) => sha256.convert(utf8.encode(text)).toString();

Map<String, dynamic> _entry({
  required String book,
  required String number,
  String title = 'Test',
  String? sha256,
  int size = 0,
  String? raw,
}) {
  final content = raw ?? _validChordJson;
  return {
    'id': '$book:$number',
    'bookCode': book,
    'songNumber': number,
    'title': title,
    'path': 'docs/assets/chord/$number-$title.chord.json',
    'formatVersion': 2,
    'size': size > 0 ? size : content.length,
    'sha256': sha256 ?? _sha256(content),
  };
}

Map<String, dynamic> _manifest(String commit, List<Map<String, dynamic>> files) =>
    {'schemaVersion': 1, 'sourceCommit': commit, 'files': files};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDirectory appDir;
  late FileSystemInstalledAssetStore store;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('chord_sync_test_');
    appDir = AppDirectory(
      '${tempDir.path}/doc',
      '${tempDir.path}/cache',
      '${tempDir.path}/support',
    );
    store = FileSystemInstalledAssetStore(
      installedAssetsRoot: '${tempDir.path}/support/installed_assets',
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  ChordSyncService serviceWith(http.Client client, {InstalledAssetStore? store}) =>
      ChordSyncService(appDir, client, installedAssetStore: store);

  test('downloads only changed files and stores canonically', () async {
    final chord1 = _validChordJson;
    final chord2 =
        '{"version":2,"type":"note-aligned","pages":{"1":[{"noteIdx":0,"chord":"C"}]}}';
    final manifest = _manifest('a' * 40, [
      _entry(book: 'KR', number: '001', raw: chord1),
      _entry(book: 'KR', number: '002', raw: chord2),
    ]);
    final requests = <String>[];
    final client = MockClient((request) async {
      requests.add(request.url.path);
      if (request.url.path.endsWith('assets-chord-manifest.json')) {
        return http.Response(
          jsonEncode(manifest),
          200,
          headers: {'etag': '"v1"'},
        );
      }
      final file = request.url.pathSegments.last;
      final content = file.startsWith('001') ? chord1 : chord2;
      return http.Response(content, 200);
    });

    final service = serviceWith(client, store: store);
    final result = await service.sync(priorityBookCode: 'KR', prioritySongNumber: '001');

    expect(result.downloaded, 2);
    expect(result.failed, 0);
    // Priority song downloads first; the manifest request comes before files.
    final chordRequests =
        requests.where((r) => r.contains('/docs/assets/chord/')).toList();
    expect(chordRequests, hasLength(2));
    expect(chordRequests.first, contains('001-Test.chord.json'));

    final stored = await store.readFile('chord/KR/001.chord.json');
    expect(stored, isNotNull);
    expect(utf8.decode(stored!), chord1);
    expect(await store.exists('chord/KR/002.chord.json'), isTrue);
    expect(await store.exists('chord/manifest.last.json'), isTrue);

    final path = await service.resolveInstalledChordPathForSong('KR', '001');
    expect(path, isNotNull);
    expect(File(path!).existsSync(), isTrue);

    final bytes = await service.readChordBytes('KR', '002');
    expect(utf8.decode(bytes!), chord2);
  });

  test('skips files whose sha matches last known good manifest', () async {
    final chord = _validChordJson;
    final manifest = _manifest('a' * 40, [_entry(book: 'KR', number: '001', raw: chord)]);
    var downloadHits = 0;
    final client = MockClient((request) async {
      if (request.url.path.endsWith('assets-chord-manifest.json')) {
        return http.Response(jsonEncode(manifest), 200);
      }
      downloadHits++;
      return http.Response(chord, 200);
    });

    final service = serviceWith(client, store: store);
    final first = await service.sync();
    expect(first.downloaded, 1);

    final second = await service.sync();
    expect(second.downloaded, 0);
    expect(second.skipped, 1);
    expect(downloadHits, 1); // unchanged file is never fetched again
  });

  test('304 not-modified skips all work', () async {
    final manifest = _manifest('a' * 40, [_entry(book: 'KR', number: '001')]);
    final client = MockClient((request) async {
      if (request.url.path.endsWith('assets-chord-manifest.json')) {
        return http.Response(jsonEncode(manifest), 200, headers: {'etag': '"v1"'});
      }
      return http.Response(_validChordJson, 200);
    });

    final service = serviceWith(client, store: store);
    await service.sync();
    expect(await store.exists('chord/KR/001.chord.json'), isTrue);

    final conditional = MockClient((request) async {
      expect(request.headers['If-None-Match'], '"v1"');
      return http.Response('', 304);
    });
    final result = await serviceWith(conditional, store: store).sync();
    expect(result.changed, isFalse);
    expect(await store.exists('chord/KR/001.chord.json'), isTrue);
  });

  test('rejects tampered downloads and keeps the old cache', () async {
    final good = _validChordJson;
    final manifest = _manifest(
      'a' * 40,
      [
        _entry(book: 'KR', number: '001', raw: good),
        _entry(book: 'KR', number: '002', raw: good, sha256: _sha256(good)),
      ],
    );
    var serveTampered = false;
    final client = MockClient((request) async {
      if (request.url.path.endsWith('assets-chord-manifest.json')) {
        return http.Response(jsonEncode(manifest), 200);
      }
      if (request.url.pathSegments.last.startsWith('002')) {
        return serveTampered
            ? http.Response('tampered', 200)
            : http.Response(good, 200);
      }
      return http.Response(good, 200);
    });

    final service = serviceWith(client, store: store);
    final first = await service.sync();
    expect(first.failed, 0);

    // Update the manifest so 002 has a NEW sha256, then serve tampered bytes.
    final newSha = _sha256('tampered');
    final newManifest = _manifest('a' * 40, [
      _entry(book: 'KR', number: '001', raw: good),
      _entry(book: 'KR', number: '002', raw: good, sha256: newSha),
    ]);
    serveTampered = true;
    final second = await serviceWith(
      MockClient((request) async {
        if (request.url.path.endsWith('assets-chord-manifest.json')) {
          return http.Response(jsonEncode(newManifest), 200);
        }
        return http.Response('tampered', 200);
      }),
      store: store,
    ).sync();

    expect(second.failed, 1);
    // Old verified content survives the failed pass.
    final stored = await store.readFile('chord/KR/002.chord.json');
    expect(stored, isNotNull);
    expect(utf8.decode(stored!), good);
    final lastGood = jsonDecode(utf8.decode((await store.readFile('chord/manifest.last.json'))!));
    expect(
      (lastGood['files'] as List).firstWhere((f) => f['id'] == 'KR:002')['sha256'],
      _sha256(good),
    );
  });

  test('migrates legacy cache files that still hash-match', () async {
    final chord = _validChordJson;
    final legacyDir = Directory(appDir.chordFolder);
    await legacyDir.create(recursive: true);
    await File('${legacyDir.path}/001_Title Old.chord.json').writeAsString(chord);

    final manifest = _manifest('a' * 40, [_entry(book: 'KR', number: '001', raw: chord)]);
    final client = MockClient((request) async {
      if (request.url.path.endsWith('assets-chord-manifest.json')) {
        return http.Response(jsonEncode(manifest), 200);
      }
      fail('must not download a file that exists in the legacy cache');
    });

    final service = serviceWith(client, store: store);
    final result = await service.sync();

    expect(result.downloaded, 1);
    expect(await store.exists('chord/KR/001.chord.json'), isTrue);
    expect(utf8.decode((await store.readFile('chord/KR/001.chord.json'))!), chord);
  });

  test('unsupported schema keeps cache untouched', () async {
    final chord = _validChordJson;
    final manifest = _manifest('a' * 40, [_entry(book: 'KR', number: '001', raw: chord)]);
    final client = MockClient((request) async {
      if (request.url.path.endsWith('assets-chord-manifest.json')) {
        return http.Response(jsonEncode(manifest), 200);
      }
      return http.Response(chord, 200);
    });
    final service = serviceWith(client, store: store);
    await service.sync();
    expect(await store.exists('chord/KR/001.chord.json'), isTrue);

    final unsupported = _manifest('a' * 40, []);
    unsupported['schemaVersion'] = 99;
    final result = await serviceWith(
      MockClient((request) async {
        if (request.url.path.endsWith('assets-chord-manifest.json')) {
          return http.Response(jsonEncode(unsupported), 200);
        }
        return http.Response(chord, 200);
      }),
      store: store,
    ).sync();

    expect(result.changed, isFalse);
    expect(await store.exists('chord/KR/001.chord.json'), isTrue);
  });

  test('prunes removed files only after a fully valid pass', () async {
    final chord = _validChordJson;
    final twoFileManifest = _manifest('a' * 40, [
      _entry(book: 'KR', number: '001', raw: chord),
      _entry(book: 'KR', number: '002', raw: chord),
    ]);
    final client = MockClient((request) async {
      if (request.url.path.endsWith('assets-chord-manifest.json')) {
        return http.Response(jsonEncode(twoFileManifest), 200);
      }
      return http.Response(chord, 200);
    });
    final service = serviceWith(client, store: store);
    await service.sync();
    expect(await store.exists('chord/KR/002.chord.json'), isTrue);

    final oneFileManifest = _manifest('a' * 40, [
      _entry(book: 'KR', number: '001', raw: chord),
    ]);
    final second = await serviceWith(
      MockClient((request) async {
        if (request.url.path.endsWith('assets-chord-manifest.json')) {
          return http.Response(jsonEncode(oneFileManifest), 200);
        }
        return http.Response(chord, 200);
      }),
      store: store,
    ).sync();

    expect(second.changed, isFalse);
    expect(await store.exists('chord/KR/002.chord.json'), isFalse);
  });

  test('reset clears both the store and the legacy folder', () async {
    final chord = _validChordJson;
    final manifest = _manifest('a' * 40, [_entry(book: 'KR', number: '001', raw: chord)]);
    final client = MockClient((request) async {
      if (request.url.path.endsWith('assets-chord-manifest.json')) {
        return http.Response(jsonEncode(manifest), 200);
      }
      return http.Response(chord, 200);
    });
    final service = serviceWith(client, store: store);
    await service.sync();
    expect(await store.exists('chord/KR/001.chord.json'), isTrue);

    await service.reset();

    expect(await store.exists('chord/KR/001.chord.json'), isFalse);
    expect(await store.exists('chord/manifest.last.json'), isFalse);
    expect(Directory(appDir.chordFolder).existsSync(), isFalse);
  });
}

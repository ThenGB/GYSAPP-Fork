import 'dart:convert';

import 'package:church/data/services/faith_pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  Map<String, dynamic> manifest({String host = 'github.com'}) => {
        'schemaVersion': 1,
        'kind': 'faith-pdfs',
        'tag': 'faith-pdfs-test',
        'items': [
          for (var number = 1; number <= 10; number++)
            {
              'number': number,
              'name': '${number.toString().padLeft(2, '0')}-belief.pdf',
              'downloadUrl':
                  'https://$host/ThenGB/GYSApp-Data/releases/download/faith-pdfs-test/${number.toString().padLeft(2, '0')}-belief.pdf',
            },
        ],
      };

  Map<String, dynamic> legacyManifest() {
    final data = manifest();
    final items = data['items'] as List<dynamic>;
    final first = Map<String, dynamic>.from(items.first as Map)
      ..['name'] = '01-Yesus Kristus.pdf'
      ..['downloadUrl'] =
          'https://github.com/ThenGB/GYSApp-Data/releases/download/faith-pdfs-test/01-Yesus%20Kristus.pdf';
    items[0] = first;
    return data;
  }

  test('resolves all belief PDFs from the GYSApp-Data manifest', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'raw.githubusercontent.com');
      expect(request.url.path, contains('/ThenGB/GYSApp-Data/'));
      return http.Response(jsonEncode(manifest()), 200);
    });
    final service = FaithPdfService(client: client);
    addTearDown(service.dispose);

    for (var number = 1; number <= 10; number++) {
      final document = await service.documentFor(number);
      expect(document, isNotNull);
      expect(document!.beliefNumber, number);
      expect(document.uri.scheme, 'https');
      expect(document.uri.host, 'github.com');
      expect(
        document.uri.path,
        startsWith('/ThenGB/GYSApp-Data/releases/download/'),
      );
    }
  });

  test('resolves legacy spaced names against real release assets', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      if (request.url.host == 'raw.githubusercontent.com') {
        return http.Response(jsonEncode(legacyManifest()), 200);
      }

      expect(request.url.host, 'api.github.com');
      expect(request.url.path, contains('/releases/tags/faith-pdfs-test'));
      return http.Response(
        jsonEncode({
          'assets': [
            for (var number = 1; number <= 10; number++)
              {
                'name': number == 1
                    ? '01-Yesus.Kristus.pdf'
                    : '${number.toString().padLeft(2, '0')}-belief.pdf',
                'browser_download_url': number == 1
                    ? 'https://github.com/ThenGB/GYSApp-Data/releases/download/faith-pdfs-test/01-Yesus.Kristus.pdf'
                    : 'https://github.com/ThenGB/GYSApp-Data/releases/download/faith-pdfs-test/${number.toString().padLeft(2, '0')}-belief.pdf',
              },
          ],
        }),
        200,
      );
    });
    final service = FaithPdfService(client: client);
    addTearDown(service.dispose);

    final document = await service.documentFor(1);
    expect(calls, 2, reason: 'manifest and release API should both be queried');
    expect(document, isNotNull, reason: 'resolver completed after $calls calls');
    expect(document!.name, '01-Yesus.Kristus.pdf');
    expect(document.uri.path, endsWith('/01-Yesus.Kristus.pdf'));
  });

  test('legacy first PDF remains usable when release API is unavailable', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      if (request.url.host == 'raw.githubusercontent.com') {
        return http.Response(jsonEncode(legacyManifest()), 200);
      }
      return http.Response('unavailable', 503);
    });
    final service = FaithPdfService(client: client);
    addTearDown(service.dispose);

    final document = await service.documentFor(1);
    expect(calls, 2, reason: 'manifest and release API should both be queried');
    expect(document, isNotNull, reason: 'fallback completed after $calls calls');
    expect(document!.name, '01-Yesus.Kristus.pdf');
    expect(document.uri.path, endsWith('/01-Yesus.Kristus.pdf'));
  });

  test('rejects manifest download URLs outside GYSApp-Data releases', () async {
    final client = MockClient(
      (_) async => http.Response(jsonEncode(manifest(host: 'example.com')), 200),
    );
    final service = FaithPdfService(client: client);
    addTearDown(service.dispose);

    expect(await service.documentFor(1), isNull);
  });

  test('does not request invalid belief numbers', () async {
    var calls = 0;
    final client = MockClient((_) async {
      calls++;
      return http.Response(jsonEncode(manifest()), 200);
    });
    final service = FaithPdfService(client: client);
    addTearDown(service.dispose);

    expect(await service.documentFor(0), isNull);
    expect(await service.documentFor(11), isNull);
    expect(calls, 0);
  });
}

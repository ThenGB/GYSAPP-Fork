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

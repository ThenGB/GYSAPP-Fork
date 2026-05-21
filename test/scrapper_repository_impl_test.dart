import 'dart:convert';

import 'package:church/data/repository/scrapper_repository_impl.dart';
import 'package:chaleno/chaleno.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('prefers today slug when present in sauh post feed', () {
    final posts = [
      {
        'slug': 'sbj260520',
        'date_gmt': '2026-05-19T17:00:52',
        'title': {'rendered': 'Merasa Cukup'},
      },
      {
        'slug': 'sbj260521',
        'date_gmt': '2026-05-20T17:00:13',
        'title': {'rendered': 'Kita adalah Orang yang Berhutang'},
      },
    ];

    final selected = selectPreferredSauhPost(
      posts,
      now: DateTime(2026, 5, 21),
    );

    expect(selected?['slug'], 'sbj260521');
  });

  test('returns most recent sauh post when today slug is unavailable', () {
    final posts = [
      {
        'slug': 'sbj260519',
        'date_gmt': '2026-05-18T17:00:29',
        'title': {'rendered': 'Jadilah Kehendak-Mu'},
      },
      {
        'slug': 'sbj260520',
        'date_gmt': '2026-05-19T17:00:52',
        'title': {'rendered': 'Merasa Cukup'},
      },
    ];

    final selected = selectPreferredSauhPost(
      posts,
      now: DateTime(2026, 5, 21),
    );

    expect(selected?['slug'], 'sbj260520');
  });

  test('getSauh fetches todays direct slug before falling back to feed', () async {
    final requests = <Uri>[];
    final client = MockClient((request) async {
      requests.add(request.url);
      final slug = request.url.queryParameters['slug'];
      if (slug == 'sbj260521') {
        return http.Response(
          jsonEncode([
            {
              'slug': 'sbj260521',
              'title': {'rendered': 'Kita adalah Orang yang Berhutang'},
              'link': 'https://tjc.org/id/gerakan-baca-alkitab/sbj260521/',
              'excerpt': {'rendered': '<p>Roma 8:12</p>'},
              '_embedded': {
                'wp:featuredmedia': [
                  {'source_url': 'https://tjc.org/example.jpg'},
                ],
              },
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response(jsonEncode([]), 200);
    });

    final repository = ScrapperRepositoryImpl(Chaleno(), client: client);
    final result = await repository.getSauh(now: DateTime(2026, 5, 21));

    expect(result.isRight(), isTrue);
    final sauhs = result.getOrElse(() => const []);
    expect(sauhs, hasLength(1));
    expect(sauhs.first.title, 'Kita adalah Orang yang Berhutang');
    expect(
      requests.first.queryParameters['slug'],
      'sbj260521',
    );
  });
}

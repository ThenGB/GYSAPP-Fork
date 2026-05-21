import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:chaleno/chaleno.dart';
import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;


import '../../domain/entity/kesaksian/kesaksian_entity.dart';
import '../../domain/entity/panduan/panduan_entity.dart';
import '../../domain/entity/renungan/renungan_entity.dart';
import '../../domain/entity/sauh/sauh_entity.dart';
import '../../domain/entity/truevoice/truevoice_entity.dart';
import '../../domain/entity/warta/warta_entity.dart';
import '../../domain/repository/scrapper_repository.dart';
import '../data.dart';

class ScrapperRepositoryImpl implements ScrapperRepository {
  final Chaleno chaleno;
  final http.Client _client;

  ScrapperRepositoryImpl(this.chaleno, {http.Client? client})
    : _client = client ?? http.Client();
  @override
  Future<Either<Failure, List<Sauh>>> getSauh({DateTime? now}) async {
    return _getSauhFromHtml(now: now ?? DateTime.now());
  }

  Future<Either<Failure, List<Sauh>>> _getSauhFromHtml({
    required DateTime now,
  }) async {
    bool hasError = false;
    List<Sauh> data = [];
    late Failure failure;
    try {
      final expectedSlug = expectedSauhSlugForDate(now);
      var posts = await _fetchSauhPosts(slug: expectedSlug, perPage: 1);
      posts = posts.isNotEmpty ? posts : await _fetchSauhPosts(perPage: 6);

      final preferredPost = selectPreferredSauhPost(posts, now: now);
      if (preferredPost == null) throw "Can't parse Sauh Bagi Jiwa";

      final orderedPosts = orderSauhPostsByFreshness(
        posts,
        now: now,
        preferredPost: preferredPost,
      );
      final seenUrls = <String>{};
      for (final post in orderedPosts) {
        final title = (post['title']?['rendered'] ?? '').trim();
        final url = _absoluteTjcUrl(post['link'] ?? '#');
        String imageUrl = '';
        final embedded = post['_embedded'];
        if (embedded != null && embedded is Map) {
          final media = embedded['wp:featuredmedia'];
          if (media is List && media.isNotEmpty) {
            imageUrl = media[0]['source_url'] ?? '';
          }
        }
        
        // Extract Bible verse from excerpt or content
        String description = _extractBibleVerse(post);
        
        log('SBJ API: title="$title" imageUrl="$imageUrl" verse="$description"', name: 'Scrapper');
        if (title.isEmpty || url == '#' || seenUrls.contains(url)) {
          continue;
        }
        seenUrls.add(url);
        data.add(
          Sauh(
            title: title,
            description: description,
            url: url,
            imageUrl: _absoluteTjcUrl(imageUrl),
          ),
        );
      }
      if (data.isEmpty) throw "Can't parse Sauh Bagi Jiwa";
    } catch (e) {
      hasError = true;
      failure = Failure.fromError(e);
    }
    return hasError ? Left(failure) : Right(data);
  }

  Future<List<Map<String, dynamic>>> _fetchSauhPosts({
    String? slug,
    int perPage = 6,
  }) async {
    final response = await _client.get(
      buildSauhPostsApiUri(slug: slug, perPage: perPage),
    );
    if (response.statusCode != 200) {
      throw 'HTTP ${response.statusCode}';
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((post) => Map<String, dynamic>.from(post))
        .toList();
  }

  String _extractImageUrl(dynamic element) {
    final img = element.querySelector('img');
    if (img == null) return '';

    final bestFromSrcSet = _bestSrcSetUrl(
      img.attr('data-tf-srcset') ??
          img.attr('data-srcset') ??
          img.attr('srcset') ??
          '',
    );
    if (bestFromSrcSet.isNotEmpty) return bestFromSrcSet;
    final candidates = [
      img.attr('data-tf-src'),
      img.attr('data-src'),
      img.attr('src'),
    ];
    final result = candidates.whereType<String>().firstWhereOrNull(
            (value) => value.isNotEmpty && !value.startsWith('data:image')) ??
        '';
    if (result.isNotEmpty) return result;

    final noscriptImg = element.querySelector('noscript img');
    if (noscriptImg != null) {
      final nsSrc = noscriptImg.attr('src') ?? '';
      if (nsSrc.isNotEmpty && !nsSrc.startsWith('data:image')) return nsSrc;
      final nsSrcSet = noscriptImg.attr('srcset') ?? '';
      if (nsSrcSet.isNotEmpty) {
        return _bestSrcSetUrl(nsSrcSet);
      }
    }
    return '';
  }

  String _bestSrcSetUrl(String srcSet) {
    if (srcSet.isEmpty) return '';
    final candidates = srcSet
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .map((value) {
      final parts = value.split(RegExp(r'\s+'));
      final url = parts.first;
      final width = parts.length > 1
          ? int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0
          : 0;
      return MapEntry(url, width);
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return candidates.firstWhereOrNull((item) => item.key.isNotEmpty)?.key ??
        '';
  }

  String _preferOriginalWordPressImage(String url) {
    if (url.isEmpty || url.startsWith('data:image')) return '';
    return url.replaceFirst(
      RegExp(r'(-\d+x\d+)+\.(jpe?g|png|webp)$', caseSensitive: false),
      r'.$2',
    );
  }

  String _absoluteTjcUrl(String url) {
    if (url.startsWith('http')) return url;
    if (url.startsWith('/')) return 'https://tjc.org$url';
    return url;
  }

  String _extractBibleVerse(Map<String, dynamic> post) {
    // Try to extract from excerpt first
    final excerpt = post['excerpt']?['rendered'] ?? '';
    if (excerpt.isNotEmpty) {
      final verseFromExcerpt = _parseVerseFromHtml(excerpt);
      if (verseFromExcerpt.isNotEmpty) {
        return verseFromExcerpt;
      }
    }

    // Try to extract from content
    final content = post['content']?['rendered'] ?? '';
    if (content.isNotEmpty) {
      final verseFromContent = _parseVerseFromHtml(content);
      if (verseFromContent.isNotEmpty) {
        return verseFromContent;
      }
    }

    // Fallback to ---
    return '---';
  }

  String _parseVerseFromHtml(String html) {
    // Remove HTML tags
    final text = html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    
    // Look for Bible verse pattern (e.g., "Matius 6:1-4", "Kejadian 1:1", etc.)
    // Common Indonesian Bible book names
    final bookNames = [
      'Kejadian', 'Keluaran', 'Imamat', 'Bilangan', 'Ulangan',
      'Yosua', 'Hakim-hakim', 'Rut', '1 Samuel', '2 Samuel',
      '1 Raja-raja', '2 Raja-raja', '1 Tawarikh', '2 Tawarikh',
      'Ezra', 'Nehemia', 'Ester', 'Ayub', 'Mazmur',
      'Amsal', 'Pengkhotbah', 'Kidung Agung', 'Yesaya', 'Yeremia',
      'Ratapan', 'Yehezkiel', 'Daniel', 'Hosea', 'Yoel',
      'Amos', 'Obaja', 'Yona', 'Mikha', 'Nahum',
      'Habakuk', 'Zefanya', 'Haggai', 'Zakharia', 'Maleakhi',
      'Matius', 'Markus', 'Lukas', 'Yohanes', 'Kisah Para Rasul',
      'Roma', '1 Korintus', '2 Korintus', 'Galatia', 'Efesus',
      'Filipi', 'Kolose', '1 Tesalonika', '2 Tesalonika',
      '1 Timotius', '2 Timotius', 'Titus', 'Filemon', 'Ibrani',
      'Yakobus', '1 Petrus', '2 Petrus', '1 Yohanes', '2 Yohanes',
      '3 Yohanes', 'Yudas', 'Wahyu'
    ];

    for (final book in bookNames) {
      // Pattern: BookName chapter:verse (e.g., "Matius 6:1-4")
      final pattern = RegExp('$book\\s+\\d+:\\d+(?:-\\d+)?', caseSensitive: false);
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(0) ?? '';
      }
    }

    // Fallback pattern: any word followed by chapter:verse
    final fallbackPattern = RegExp(r'\b[A-Za-z]+\s+\d+:\d+(?:-\d+)?');
    final fallbackMatch = fallbackPattern.firstMatch(text);
    if (fallbackMatch != null) {
      return fallbackMatch.group(0) ?? '';
    }

    return '';
  }

  @override
  Future<Either<Failure, List<TrueVoice>>> getSuaraSejati() async {
    bool hasError = false;
    List<TrueVoice> data = [];
    late Failure failure;
    try {
      log('SS: Loading page...', name: 'Scrapper');
      var parser = await chaleno.load('https://tjc.org/id/suarasejati/');
      if (parser == null) throw 'Can\'t get data online';

      log('SS: Page loaded, querying articles...', name: 'Scrapper');
      var articles = parser.querySelectorAll('.grid4 article');
      log('SS: Found ${articles.length} articles', name: 'Scrapper');

      final List<Future<TrueVoice?>> tasks = [];

      for (var i = 0; i < articles.length; i++) {
        final article = articles[i];
        final title = article.querySelector('.post-title')?.text ?? '';
        final description = (article.querySelector('p')?.text ?? '').trim();
        final url = article.querySelector('a')?.attr('href') ?? '#';
        final imageUrl = _absoluteTjcUrl(
          _preferOriginalWordPressImage(_extractImageUrl(article)),
        );

        tasks.add(() async {
          try {
            var creator = description;
            if (url != '#') {
              final articleParser = await chaleno.load(url);
              if (articleParser != null) {
                // Try to find in the first paragraph or first 500 chars of body
                final firstP = articleParser.querySelector('.entry-content p').text ?? '';
                final bodyText = articleParser.querySelector('body').text ?? '';
                var searchArea = firstP.length > 20 ? firstP : bodyText.substring(0, bodyText.length > 500 ? 500 : bodyText.length);
                
                // Improved regex: handles Indonesian quotes and multiple city/location parts
                final creatorPattern = RegExp(
                  r'(?:Sdri\.|Sdr\.|Pdt\.|Pnt\.|Dkn\.)\s*[^,”，"(\n]+(?:,\s*Gereja\s+cabang\s+[^,”，"(\n]+)?(?:,\s*[^,”，"(\n]+)?',
                  caseSensitive: false,
                );
                
                var match = creatorPattern.firstMatch(searchArea);
                
                // If not found in search area, search whole body (less efficient but robust fallback)
                match ??= creatorPattern.firstMatch(bodyText);

                if (match != null) {
                  creator = match.group(0)?.trim() ?? description;
                  // Clean up trailing quotes or commas
                  creator = creator.replaceAll(RegExp(r'[”，"，" ]+$'), '').replaceAll(RegExp(r'^[，“" ]+'), '');
                }
              }
            }
            return TrueVoice(
              title: title,
              description: description,
              url: url,
              imageUrl: imageUrl,
              creator: creator,
            );
          } catch (e) {
            return null;
          }
        }());
      }

      final results = await Future.wait(tasks);
      data = results.whereType<TrueVoice>().toList();

      if (data.isEmpty) throw 'No articles found or parsed';
      log('SS: Successfully parsed ${data.length} articles', name: 'Scrapper');
    } catch (e) {
      log('SS Error: $e', name: 'Scrapper');
      hasError = true;
      failure = Failure.fromError(e);
    }
    return hasError ? Left(failure) : Right(data);
  }

  @override
  Future<Either<Failure, List<Kesaksian>>> getKesaksian(String selector) async {
    bool hasError = false;
    List<Kesaksian> data = [];
    late Failure failure;
    try {
      var parser = await chaleno.load('https://tjc.org/id/literatur/');
      if (parser == null) throw "Can't get data online";

      var articles = parser.querySelectorAll(selector);
      for (var article in articles) {
        var title = article.text ?? '';
        var description = (article.querySelector('p')?.text ?? '').trim();
        var url = article.attr('href') ?? '';
        var imageUrl = article.querySelector('img')?.src ?? '';

        data.add(
          Kesaksian(
            title: title,
            description: description,
            url: url,
            imageUrl: imageUrl,
          ),
        );
      }
      log(articles.toString());
    } catch (e) {
      hasError = true;
      failure = Failure.fromError(e);
    }
    return hasError ? Left(failure) : Right(data);
  }

  @override
  Future<Either<Failure, List<Warta>>> getWarta(String selector) async {
    bool hasError = false;
    List<Warta> data = [];
    late Failure failure;
    try {
      var parser =
          await chaleno.load('https://tjc.org/id/literatur/warta-sejati/');
      if (parser == null) throw "Can't get data online";

      var articles = parser.querySelectorAll('.grid4 article');
      if (articles.isNotEmpty) {
        for (var article in articles) {
          var title = article.querySelector('.post-title')?.text ?? '';
          var description = (article.querySelector('p')?.text ?? '').trim();
          var url = article.querySelector('a')?.attr('href') ?? '#';
          var imageUrl = article.querySelector('img')?.attr('src') ?? '';

          data.add(
            Warta(
              title: title,
              description: description,
              url: url,
              imageUrl: imageUrl,
            ),
          );
        }
      }
      log(articles.toString());
    } catch (e) {
      hasError = true;
      failure = Failure.fromError(e);
    }
    return hasError ? Left(failure) : Right(data);
  }

  @override
  Future<Either<Failure, List<Renungan>>> getRenungan(String selector) async {
    bool hasError = false;
    List<Renungan> data = [];
    late Failure failure;
    try {
      var parser = await chaleno.load('https://tjc.org/id/literatur/');
      if (parser == null) throw "Can't get data online";

      var articles = parser.querySelectorAll(selector);
      for (var article in articles) {
        var title = article.text ?? '';
        var description = (article.querySelector('p')?.text ?? '').trim();
        var url = article.attr('href') ?? '';
        var imageUrl = article.querySelector('img')?.src ?? '';

        data.add(
          Renungan(
            title: title,
            description: description,
            url: url,
            imageUrl: imageUrl,
          ),
        );
      }
    } catch (e) {
      hasError = true;
      failure = Failure.fromError(e);
    }
    return hasError ? Left(failure) : Right(data);
  }

  @override
  Future<Either<Failure, List<Panduan>>> getPanduan(String selector) async {
    bool hasError = false;
    List<Panduan> data = [];
    late Failure failure;
    try {
      var articles =
          await AppConfigStore.listMapConfig('literature_panduan_alkitab');
      for (var article in articles) {
        data.add(
          Panduan(
            title: article['title'],
            description: '',
            url: article['link'],
            imageUrl: article['img'],
          ),
        );
      }
    } catch (e) {
      hasError = true;
      failure = Failure.fromError(e);
    }
    return hasError ? Left(failure) : Right(data);
  }
}

Uri buildSauhPostsApiUri({String? slug, int perPage = 6}) {
  return Uri.https('tjc.org', '/id/wp-json/wp/v2/posts', {
    'categories': '229',
    'per_page': perPage.toString(),
    'orderby': 'date',
    'order': 'desc',
    '_embed': 'wp:featuredmedia',
    if (slug != null && slug.isNotEmpty) 'slug': slug,
  });
}

String expectedSauhSlugForDate(DateTime date) {
  final local = date.toLocal();
  final yy = (local.year % 100).toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  final dd = local.day.toString().padLeft(2, '0');
  return 'sbj$yy$mm$dd';
}

Map<String, dynamic>? selectPreferredSauhPost(
  List<Map<String, dynamic>> posts, {
  DateTime? now,
}) {
  if (posts.isEmpty) return null;
  final expectedSlug = expectedSauhSlugForDate(now ?? DateTime.now());
  final normalizedPosts = List<Map<String, dynamic>>.from(posts)
    ..sort(
      (a, b) => _parseSauhPostDate(
        b,
      ).compareTo(_parseSauhPostDate(a)),
    );

  return normalizedPosts.firstWhereOrNull(
        (post) => ((post['slug'] ?? '') as String).toLowerCase() == expectedSlug,
      ) ??
      normalizedPosts.first;
}

List<Map<String, dynamic>> orderSauhPostsByFreshness(
  List<Map<String, dynamic>> posts, {
  DateTime? now,
  Map<String, dynamic>? preferredPost,
}) {
  if (posts.isEmpty) return const [];
  final preferred = preferredPost ?? selectPreferredSauhPost(posts, now: now);
  final ordered = List<Map<String, dynamic>>.from(posts)
    ..sort(
      (a, b) => _parseSauhPostDate(
        b,
      ).compareTo(_parseSauhPostDate(a)),
    );
  if (preferred == null) return ordered;

  final preferredSlug = ((preferred['slug'] ?? '') as String).toLowerCase();
  final rest = ordered
      .where(
        (post) => ((post['slug'] ?? '') as String).toLowerCase() != preferredSlug,
      )
      .toList();
  return [preferred, ...rest];
}

DateTime _parseSauhPostDate(Map<String, dynamic> post) {
  final raw = (post['date_gmt'] ?? post['date'] ?? '') as String;
  final parsed = DateTime.tryParse(raw);
  return parsed?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}


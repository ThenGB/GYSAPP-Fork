import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chaleno/chaleno.dart';
import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController webViewController = WebViewController()
    ..setNavigationDelegate(NavigationDelegate(
      onProgress: (progress) {
        if (progress == 100 && !scrapperCompleter.isCompleted) {
          scrapperCompleter.complete(true);
        }
      },
      onUrlChange: (change) {
        log(change.url ?? '', name: 'URL Changed');
      },
    ))
    ..setJavaScriptMode(JavaScriptMode.unrestricted)

    /// Platform apple = Ipod, Ipad, Iphone, Macintosh
    ..setUserAgent('$Platform.operatingSystem; $Platform.localHostname');

  ScrapperRepositoryImpl(this.chaleno);

  Completer<bool> scrapperCompleter = Completer();
  @override
  Future<Either<Failure, List<Sauh>>> getSauh() async {
    if (!isWebViewConfiguredForCurrentPlatform) {
      return _getSauhFromHtml();
    }
    List<Sauh> data = [];
    try {
      scrapperCompleter = Completer();
      await webViewController
          .loadRequest(Uri.parse('https://tjc.org/id/sauhbagijiwa/'));
      final config = await FirebaseUtils.stringConfig('sauhconfig');
      final req = await scrapperCompleter.future;
      if (!req) throw 'Tidak dapat mengambil data dari internet';
      final jsR = await webViewController.runJavaScriptReturningResult(config);
      final List res = jsonDecode(jsR as String);
      for (final map in res) {
        data.add(
          Sauh(
            title: map['title'],
            description: '---',
            url: map['linkUrl'],
            imageUrl: _preferOriginalWordPressImage(map['imageUrl'] ?? ''),
          ),
        );
      }
      if (data.isEmpty) {
        return _getSauhFromHtml();
      }
    } catch (e) {
      return _getSauhFromHtml();
    }
    return Right(data);
  }

  Future<Either<Failure, List<Sauh>>> _getSauhFromHtml() async {
    bool hasError = false;
    List<Sauh> data = [];
    late Failure failure;
    try {
      final parser = await chaleno.load('https://tjc.org/id/sauhbagijiwa/');
      if (parser == null) throw "Can't get data online";

      final slides = parser.querySelectorAll('.tf_swiper-slide');
      final seenUrls = <String>{};
      for (final slide in slides) {
        final title = (slide.querySelector('.slide-title a')?.text ??
                slide.querySelector('img')?.attr('title') ??
                slide.querySelector('img')?.attr('alt') ??
                '')
            .trim();
        final url = _absoluteTjcUrl(
          slide.querySelector('.slide-image a')?.attr('href') ??
              slide.querySelector('.slide-title a')?.attr('href') ??
              '#',
        );
        final imageUrl = _preferOriginalWordPressImage(_bestImageUrl(slide));
        if (title.isEmpty || url == '#' || seenUrls.contains(url)) {
          continue;
        }
        seenUrls.add(url);
        data.add(
          Sauh(
            title: title,
            description: '---',
            url: url,
            imageUrl: imageUrl,
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

  String _bestImageUrl(dynamic parent) {
    final img = parent.querySelector('img');
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
    return candidates.whereType<String>().firstWhereOrNull(
            (value) => value.isNotEmpty && !value.startsWith('data:image')) ??
        '';
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
      RegExp(r'-\d+x\d+(\.(?:jpe?g|png|webp))$', caseSensitive: false),
      r'$1',
    );
  }

  String _absoluteTjcUrl(String url) {
    if (url.startsWith('http')) return url;
    if (url.startsWith('/')) return 'https://tjc.org$url';
    return url;
  }

  @override
  Future<Either<Failure, List<TrueVoice>>> getSuaraSejati() async {
    bool hasError = false;
    List<TrueVoice> data = [];
    late Failure failure;
    try {
      var parser = await chaleno.load('https://tjc.org/id/suarasejati/');
      if (parser == null) throw "Can't get data online";
      var parent = Parser(parser.querySelector('.grid4').html);

      var articles = parent.getElementsByTagName('article')?.toList();
      if (articles != null) {
        for (var article in articles) {
          var title = article.querySelector('.post-title')?.text ?? '';
          var description = (article.querySelector('p')?.text ?? '').trim();
          var url = article.querySelector('a')?.href ?? '#';
          var imageUrl = _bestImageUrl(article);

          data.add(
            TrueVoice(
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
      var parent = Parser(parser.querySelector('.grid4').html);

      var articles = parent.getElementsByTagName('article')?.toList();
      if (articles != null) {
        for (var article in articles) {
          var title = article.querySelector('.post-title')?.text ?? '';
          var description = (article.querySelector('p')?.text ?? '').trim();
          var url = article.querySelector('a')?.href ?? '#';
          var imageUrl = article.querySelector('img')?.src ?? '';

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
          await FirebaseUtils.listMapConfig('literature_panduan_alkitab');
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

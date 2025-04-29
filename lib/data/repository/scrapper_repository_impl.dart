import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chaleno/chaleno.dart';
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
    bool hasError = false;
    List<Sauh> data = [];
    late Failure failure;
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
            imageUrl: map['imageUrl'],
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
          var imageUrl = article.querySelector('img')?.src ?? '';

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

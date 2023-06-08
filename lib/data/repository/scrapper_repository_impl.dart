import 'dart:developer';

import 'package:chaleno/chaleno.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entity/kesaksian/kesaksian_entity.dart';
import '../../domain/entity/panduan/panduan_entity.dart';
import '../../domain/entity/renungan/renungan_entity.dart';
import '../../domain/entity/sauh/sauh_entity.dart';
import '../../domain/entity/truevoice/truevoice_entity.dart';
import '../../domain/entity/warta/warta_entity.dart';
import '../../domain/repository/scrapper_repository.dart';
import '../utilities/variables/failure.dart';

class ScrapperRepositoryImpl implements ScrapperRepository {
  final Chaleno chaleno;

  ScrapperRepositoryImpl(this.chaleno);
  @override
  Future<Either<Failure, List<Sauh>>> getSauh() async {
    bool hasError = false;
    List<Sauh> data = [];
    late Failure failure;
    try {
      var parser = await chaleno.load('https://tjc.org/id/sauhbagijiwa/');
      if (parser == null) throw "Can't get data online";
      var parent = Parser(parser.querySelector('.grid4').html);

      var articles = parent.getElementsByTagName('article')?.toList();
      if (articles != null) {
        for (var article in articles) {
          var title = article.querySelector('.post-title')?.text ?? '';
          var time = article.querySelector('.year')?.text ?? '';
          var url = article.querySelector('a')?.href ?? '#';
          var imageUrl = article.querySelector('img')?.src ?? '';
          data.add(Sauh(
              title: title, description: time, url: url, imageUrl: imageUrl));
        }
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
      var parser = await chaleno.load('https://tjc.org/id/literatur/');
      if (parser == null) throw "Can't get data online";

      var articles = parser.querySelectorAll(selector);
      for (var article in articles) {
        var title = article.text ?? '';
        var description = (article.querySelector('p')?.text ?? '').trim();
        var url = article.attr('href') ?? '';
        var imageUrl = article.querySelector('img')?.src ?? '';
        if (title.isNotEmpty) {
          data.add(
            Panduan(
              title: title,
              description: description,
              url: url,
              imageUrl: imageUrl,
            ),
          );
        }
      }
    } catch (e) {
      hasError = true;
      failure = Failure.fromError(e);
    }
    return hasError ? Left(failure) : Right(data);
  }
}

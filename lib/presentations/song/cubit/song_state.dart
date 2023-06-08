import 'dart:io';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pdf_render/pdf_render.dart';

import '../../../di/injection.dart';
import '../../../domain/entity/song/song_entity.dart';

part 'song_state.freezed.dart';
part 'song_state.g.dart';

@freezed
class SongState with _$SongState {
  const SongState._();
  const factory SongState({
    @Default(false) bool isLoading,
    @Default(false) bool isAudioLoading,
    @Default([]) List<SongBook> songBook,
    @Default([]) List<SongBook> favoriteSongBook,
    @Default('KR') String bookCode,
    @Default(0) int pageIndex,
    @Default(0) int verseIndex,
    @Default(false) isImageMode,
    @Default(1) double textScaleFactor,
    @Default(false) bool showSizer,
    @Default('mid') String defaultAudioFormat,
  }) = _SongState;

  SongBook? get currentSong {
    return songBook.firstWhereOrNull((element) => element.code == bookCode);
  }

  Future<List<Uint8List>> getImageLyricPath(
      BuildContext context, int pageStart, int pageLength) async {
    final result = <Uint8List>[];
    var data = await rootBundle.load('assets/data/$bookCode.pdf');
    var file = File('${di<AppDirectory>().cache}/$bookCode.pdf');
    if (!file.existsSync()) {
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await file.writeAsBytes(bytes, flush: true);
    }
    var doc = await PdfDocument.openFile(file.path);
    for (var i = 0; i < pageLength; i++) {
      var page = await doc.getPage(pageStart + i);
      var image = await page.render(
        backgroundFill: true,
        height: (page.height * 2).toInt(),
        width: (page.width * 2).toInt(),
      );
      var img = await image.createImageDetached();
      var imgBytes = await img.toByteData(format: ImageByteFormat.png);
      var libImage = imgBytes!.buffer
          .asUint8List(imgBytes.offsetInBytes, imgBytes.lengthInBytes);
      result.add(libImage);
    }
    return result;
  }

  factory SongState.fromJson(Map<String, dynamic> json) =>
      _$SongStateFromJson(json);
}

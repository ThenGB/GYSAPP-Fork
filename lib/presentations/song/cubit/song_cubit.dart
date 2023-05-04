import 'dart:developer';
import 'dart:io';

import 'package:church/data/utilities/variables/assets.dart';
import 'package:church/di/injection.dart';
import 'package:church/domain/entity/song/song_entity.dart';
import 'package:church/domain/repository/song_repository.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'song_state.dart';

export 'song_state.dart';

class SongCubit extends HydratedCubit<SongState> {
  final SongRepository songRepository;
  SongCubit(this.songRepository) : super(const SongState()) {
    initDb().then((value) {
      getData();
    });
  }

  Database? songDb;

  Future initDb() async {
    var dbPath = di<AppDirectory>().songDbPath;
    var exists = await databaseExists(dbPath);
    if (!exists) {
      log('Creating new copy of song db from assets', name: 'song_cubit.dart');

      ///
      try {
        await Directory(dirname(dbPath)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(Assets.assetsDataSong);
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(dbPath).writeAsBytes(bytes, flush: true);
    } else {
      log('Opening existing database', name: 'song_cubit.dart');
    }
    songDb = await openDatabase(dbPath, readOnly: true);
    return;
  }

  modifyTextScaleFactor(double factor) {
    emit(state.copyWith(textScaleFactor: state.textScaleFactor + factor));
  }

  toggleSizer() {
    emit(state.copyWith(showSizer: !state.showSizer));
  }

  changeScale(double scale) {
    emit(state.copyWith(textScaleFactor: scale));
  }

  changePage(int index, int verseIndex) {
    emit(state.copyWith(pageIndex: index, verseIndex: verseIndex));
  }

  changeMode() {
    emit(state.copyWith(isImageMode: !state.isImageMode));
  }

  getData() async {
    final response = await songRepository.getData(songDb!);
    response.fold(
      (failure) {
        Fluttertoast.cancel();
        Fluttertoast.showToast(msg: failure.message);
      },
      (res) {
        emit(state.copyWith(songBook: res));
      },
    );
  }

  modifyFavorite(Song song) {
    List<SongBook> modifiedSongBook = [];
    if (state.favoriteSongBook.isEmpty) {
      modifiedSongBook =
          state.songBook.map((e) => e.copyWith(songs: [])).toList();
    } else {
      modifiedSongBook = List.from(state.favoriteSongBook);
    }
    modifiedSongBook = modifiedSongBook.map((e) {
      var temp = e;
      if (temp.code == song.code) {
        List<Song> tempSongs = List.from(e.songs);
        if (tempSongs.any((element) => element.number == song.number)) {
          tempSongs.removeWhere((element) => element.number == song.number);
        } else {
          tempSongs.add(song);
        }
        temp = temp.copyWith(songs: tempSongs);
      }
      return temp;
    }).toList();
    emit(state.copyWith(favoriteSongBook: modifiedSongBook));
  }

  bool isSongFavorite(Song? song) {
    if (song == null) return false;
    if (state.favoriteSongBook.map((e) => e.code).contains(song.code)) {
      SongBook songBook = state.favoriteSongBook
          .firstWhere((element) => element.code == song.code);
      return songBook.songs.map((e) => e.number).contains(song.number);
    } else {
      return false;
    }
  }

  changeBookcode(String bookCode) {
    emit(state.copyWith(bookCode: bookCode));
  }

  @override
  SongState? fromJson(Map<String, dynamic> json) {
    return SongState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(SongState state) {
    return state.toJson();
  }
}

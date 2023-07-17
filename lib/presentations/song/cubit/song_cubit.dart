import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../data/utilities/variables/assets.dart';
import '../../../di/injection.dart';
import '../../../domain/entity/song/song_entity.dart';
import '../../../domain/entity/song_history/song_history.dart';
import '../../../domain/entity/song_note/song_note.dart';
import '../../../domain/repository/song_repository.dart';
import 'song_state.dart';

export 'song_state.dart';

class SongCubit extends HydratedCubit<SongState> {
  final SongRepository songRepository;

  bool get isSelectingSong => state.selectedSong != null;

  SongCubit(this.songRepository) : super(const SongState()) {
    initDb().then((value) {
      getData().then(
        (value) => fetchAvailableSong(
          state.currentSong?.songs[state.pageIndex] ??
              state.songBook.firstOrNull?.songs[0],
        ),
      );
    });
  }

  onSearchTermsChanged(String text) {
    emit(state.copyWith(searchTerms: text));
  }

  toggleShuffle() async {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
        msg: 'Shuffle mode ${state.shuffleMode ? 'disabled' : 'enabled'}');
    emit(state.copyWith(shuffleMode: !state.shuffleMode));
  }

  changeSortNote(String sortBy) {
    emit(state.copyWith(sortNotesBy: sortBy));
  }

  saveNote(SongNote data) {
    var notes = List<SongNote>.from(state.notes);
    notes.add(data);

    emit(state.copyWith(notes: notes));
  }

  deleteNote(SongNote data) async {
    var notes = List<SongNote>.from(state.notes);
    notes.remove(data);

    emit(state.copyWith(notes: notes));
  }

  removeSelection() async {
    emit(state.copyWith(selectedSong: null));
  }

  selectSong(Song song) {
    emit(state.copyWith(selectedSong: song));
  }

  AudioPlayer audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

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

  Future<String?> isMidiAvailable(Song song) async {
    if (song.code != 'KR') return null;
    try {
      var asset = 'assets/data/sounds/${song.number}.MID';
      await rootBundle.load(asset);
      return asset;
    } catch (e) {
      return null;
    }
  }

  pause() {
    audioPlayer.pause();
  }

  play() {
    audioPlayer.play(audioPlayer.source!);
  }

  Reference get storage => FirebaseStorage.instance.ref();

  Future<String?> fetchAvailableSong(Song? song) async {
    if (song == null) return null;
    emit(state.copyWith(isAudioLoading: true));
    String? midi = await isMidiAvailable(song);
    String? mp3 = await isMp3Available(song);
    List<String> data = [];
    if (midi != null) data.add(midi);
    if (mp3 != null) data.add(mp3);
    final result = data.firstWhereOrNull((element) =>
            element.toLowerCase().contains(state.defaultAudioFormat)) ??
        data.firstOrNull;
    if (result != null) {
      late Source url;
      var source = result;
      if (result.startsWith('assets')) {
        url = AssetSource(source.replaceAll('assets/', ''));

        audioPlayer.setSource(url).then((value) async {
          emit(state.copyWith(isAudioLoading: false));
          await Future.delayed(const Duration(seconds: 1));
          audioPlayer
              .play(audioPlayer.source!)
              .then((value) => audioPlayer.stop());
        });
      } else {
        DefaultCacheManager().getSingleFile(source).then((value) {
          url = DeviceFileSource(value.path);
          audioPlayer.setSource(url).then((value) async {
            emit(state.copyWith(isAudioLoading: false));
            await Future.delayed(const Duration(seconds: 1));

            audioPlayer
                .play(audioPlayer.source!)
                .then((value) => audioPlayer.stop());
          });
        });
      }
    }
    return result;
  }

  changeAudioFormat(String format) {
    emit(state.copyWith(defaultAudioFormat: format));
    fetchAvailableSong(state.currentSong!.songs[state.pageIndex]);
  }

  Future<String?> isMp3Available(Song song) async {
    if (song.code != 'KR') return null;
    try {
      final result = await storage
          .child('/Kidungpujian/song/${song.number}.mp3')
          .getDownloadURL();
      return result;
    } catch (e) {
      return null;
    }
  }

  toggleSizer() {
    emit(state.copyWith(showSizer: !state.showSizer));
  }

  toggleAudio() {
    emit(state.copyWith(showAudio: !state.showAudio));
  }

  changeScale(double scale) {
    emit(state.copyWith(textScaleFactor: scale));
  }

  changePage(int index, int verseIndex) async {
    await audioPlayer.seek(Duration.zero);
    audioPlayer.stop();
    debounce(() => fetchAvailableSong(state.currentSong!.songs[index]));
    emit(state.copyWith(pageIndex: index, verseIndex: verseIndex));
  }

  Timer? debouncer;

  debounce(Function() callback) {
    if (debouncer?.isActive == true) {
      debouncer?.cancel();
    }
    debouncer = Timer(const Duration(seconds: 1), callback);
  }

  changeMode() {
    emit(state.copyWith(isImageMode: !state.isImageMode));
  }

  Future getData() async {
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

  changeBookcode(String bookCode, [bool isFavorite = false]) {
    List<Song> songs = [];
    for (var book in state.favoriteSongBook) {
      songs.addAll(book.songs);
    }
    emit(
      state.copyWith(
        bookCode: bookCode,
        playOnlyFavorite: isFavorite,
        shuffleIndex: getRandomUniqueIndex(songs.length),
      ),
    );
  }

  deleteHistory(SongHistory history) {
    emit(state.copyWith(
        histories: List<SongHistory>.from(state.histories)..remove(history)));
  }

  addToHistory(SongHistory item) {
    List<SongHistory> data = List.from(state.histories);

    if (data.length >= 20) {
      data = List<SongHistory>.from(data).sublist(0, 20);
    }
    data.add(item);
    emit(state.copyWith(histories: data));
  }

  @override
  SongState? fromJson(Map<String, dynamic> json) {
    return SongState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(SongState state) {
    return state
        .copyWith(isAudioLoading: false, isLoading: false, selectedSong: null)
        .toJson();
  }

  @override
  Future<void> close() {
    audioPlayer.dispose();
    debouncer?.cancel();
    return super.close();
  }
}

List<int> getRandomUniqueIndex(int length) {
  math.Random random = math.Random();
  List<int> indices = List.generate(length, (index) => index);

  for (int i = length - 1; i > 0; i--) {
    int randomIndex = random.nextInt(i + 1);

    // Swap the elements at randomIndex and i
    int temp = indices[randomIndex];
    indices[randomIndex] = indices[i];
    indices[i] = temp;
  }

  return indices;
}

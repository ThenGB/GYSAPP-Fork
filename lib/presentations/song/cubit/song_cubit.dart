import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../data/data.dart';
import '../../../data/utilities/song_handler.dart';
import '../../../di/injection.dart';
import '../../../domain/entity/song/song_entity.dart';
import '../../../domain/entity/song_history/song_history.dart';
import '../../../domain/entity/song_note/song_note.dart';
import '../../../domain/repository/song_repository.dart';
import 'song_state.dart';

export 'song_state.dart';

class SongCubit extends HydratedCubit<SongState> {
  final SongRepository songRepository;
  final SongHandler songHandler;
  AudioPlayer get audioPlayer => songHandler.player;

  bool get isSelectingSong => state.selectedSong != null;

  SongCubit(this.songRepository, this.songHandler) : super(const SongState()) {
    initDb().then((value) {
      getData().then(
        (value) => fetchAvailableSong(
          state.songs[state.pageIndex],
        ),
      );
      Map<String, DateTime> lastSync = Map.from(state.lastSync);
      if (!lastSync.containsKey('song.db')) {
        lastSync['song.db'] = DateTime(2023, 9, 15);
        emit(state.copyWith(lastSync: lastSync));
      }
      checkIsSynced();
    });
  }
  Future<bool> downloadLyric(
      String sRemoteName,
      File localFile,
      Function(double progressInPercent, int totalReceived, int fileSize)
          onProgress) async {
    try {
      final storage = FirebaseStorage.instance;
      final fileRef = storage.ref('v2/song/lyrics/$sRemoteName');

      final downloadUrl = await fileRef.getDownloadURL();

      final dio = Dio();

      // Create a temporary file to hold the download
      var tempFile = File('${localFile.path}.tmp');

      final response = await dio.download(
        downloadUrl,
        tempFile.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double percentage = (received / total) * 100;
            onProgress(percentage, received, total);
          }
        },
      );

      if (response.statusCode == 200) {
        // If download was successful, move the temp file to the desired location
        await tempFile.rename(localFile.path);

        Map<String, DateTime> lastSync = Map.from(state.lastSync);
        lastSync[basename(sRemoteName)] = DateTime.now();
        emit(state.copyWith(lastSync: lastSync));
        return true;
      } else {
        // If the download was unsuccessful, delete the temp file
        await tempFile.delete();
      }

      return false;
    } catch (e) {
      log('Error downloading lyric $sRemoteName from Firebase with Dio: $e');
      return false;
    }
  }

  Future<bool> downloadSongDb(
      String sRemoteName,
      File localFile,
      Function(double progressInPercent, int totalReceived, int fileSize)
          onProgress) async {
    try {
      final storage = FirebaseStorage.instance;
      final fileRef = storage.ref('v2/song/$sRemoteName');

      final downloadUrl = await fileRef.getDownloadURL();

      final dio = Dio();

      // Create a temporary file to hold the download
      var tempFile = File('${localFile.path}.tmp');

      final response = await dio.download(
        downloadUrl,
        tempFile.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double percentage = (received / total) * 100;
            onProgress(percentage, received, total);
          }
        },
      );

      if (response.statusCode == 200) {
        // If download was successful, move the temp file to the desired location
        await tempFile.rename(localFile.path);

        Map<String, DateTime> lastSync = Map.from(state.lastSync);
        lastSync[basename(sRemoteName)] = DateTime.now();
        emit(state.copyWith(lastSync: lastSync));
        return true;
      } else {
        // If the download was unsuccessful, delete the temp file
        await tempFile.delete();
      }

      return false;
    } catch (e) {
      log('Error downloading lyric $sRemoteName from Firebase with Dio: $e');
      return false;
    }
  }

  Future<bool> isSynced() async {
    bool synced = true; // assuming all files are synced by default

    await checkingSyncCompleter.future.then((connectionSuccess) {
      if (connectionSuccess) {
        Map<String, DateTime> remoteLyricsUpdateAt =
            Map.from(state.remoteLyricsUpdateAt);
        Map<String, DateTime> lastSync = Map.from(state.lastSync);

        // Check if any of the remote files have been updated since the last sync
        for (var filename in remoteLyricsUpdateAt.keys) {
          if (!lastSync.containsKey(filename) ||
              remoteLyricsUpdateAt[filename]!
                  .isAfter(lastSync[filename] ?? DateTime(2022))) {
            /// why 2022? bisa semua tahun yang penting dibelakang terkahir kali update
            synced = false; // found a file that is not synced
            break; // exit the loop since we found a non-synced file
          }
        }
      }
      // If connection is unsuccessful, synced remains true.
    });

    return synced;
  }

  Future<List<String>> getUnsyncedFiles() async {
    List<String> unsyncedFiles = [];

    bool connectionSuccess = await checkingSyncCompleter.future;
    if (connectionSuccess) {
      Map<String, DateTime> remoteLyricsUpdateAt =
          Map.from(state.remoteLyricsUpdateAt);
      Map<String, DateTime> lastSync = Map.from(state.lastSync);

      // Check which files in the remote map have been updated since the last sync
      for (var filename in remoteLyricsUpdateAt.keys) {
        if (!lastSync.containsKey(filename) ||
            remoteLyricsUpdateAt[filename]!
                .isAfter(lastSync[filename] ?? DateTime(2022))) {
          unsyncedFiles.add(filename); // add the unsynced file to the list
        }
      }
    }

    return unsyncedFiles;
  }

  Completer<bool> checkingSyncCompleter = Completer();

  Future checkIsSynced() async {
    checkingSyncCompleter = Completer();
    AppDirectory localDir = di();
    try {
      Map<String, DateTime> remoteLyricsUpdateAt =
          Map.from(state.remoteLyricsUpdateAt);
      final storage = FirebaseStorage.instance;
      final songDbRef = storage.ref('v2/song/song.db');
      FullMetadata db = await songDbRef.getMetadata();
      if (db.updated != null || db.timeCreated != null) {
        remoteLyricsUpdateAt[basename(db.name)] = db.updated ?? db.timeCreated!;
      }
      var difference = db.updated
              ?.difference(
                state.lastSync[basename(db.name)] ??
                    db.updated ??
                    DateTime.now(),
              )
              .inMinutes ??
          0;
      var localFile = File(localDir.songDbPath);
      bool isExist = localFile.existsSync();
      bool isSyncronized =
          (difference.isNegative || difference == 0) && isExist;
      if (isSyncronized) {
        Map<String, DateTime> lastSync = Map.from(state.lastSync);
        lastSync[basename(db.name)] = DateTime.now();
        emit(state.copyWith(lastSync: lastSync));
      }
      final lyricFolderRef = await storage.ref('v2/song/lyrics').listAll();

      for (var book in state.songBook) {
        // lyricFolderRef.
        var remoteBook = lyricFolderRef.items
            .firstWhereOrNull((element) => element.name == '${book.code}.pdf');
        if (remoteBook != null) {
          final meta = await remoteBook.getMetadata();
          remoteLyricsUpdateAt[remoteBook.name] =
              meta.updated ?? meta.timeCreated ?? DateTime.now();
        }
      }
      emit(state.copyWith(remoteLyricsUpdateAt: remoteLyricsUpdateAt));
      checkingSyncCompleter.complete(true);
    } catch (e) {
      checkingSyncCompleter.complete(false);
      log(e.toString());
    }
  }

  sync(SongState songState) {
    emit(songState);
  }

  syncDbAndLyric({required Function(String status) onProgress}) async {
    AppDirectory localDir = di();
    try {
      final db = (await getUnsyncedFiles())
          .firstWhereOrNull((element) => element.contains('.db'));
      if (db != null) {
        bool isDownloaded = await downloadSongDb(db, File(localDir.songDbPath),
            (progressInPercent, totalReceived, fileSize) {
          onProgress(
              '${basenameWithoutExtension(db)} ${progressInPercent.toInt()}%');
        });
        if (isDownloaded) {
          await songDb?.close();
          songDb = null;
          songDb = await openDatabase(localDir.songDbPath, readOnly: true);
          getData().then(
            (value) => fetchAvailableSong(
              state.currentSong?.songs[state.pageIndex] ??
                  state.songBook.firstOrNull?.songs[0],
            ),
          );
          await checkIsSynced();
        }
      }
      final lyrics = (await getUnsyncedFiles())
          .where((element) => !element.contains('.db'))
          .toList();
      for (int i = 0; i < lyrics.length; i++) {
        var file = lyrics[i];
        await downloadLyric(file, File('${localDir.songLyricFolder}/$file'),
            (progressInPercent, totalReceived, fileSize) {
          int progressPercentage = progressInPercent.toInt();
          String progressMessage =
              '${'Syncronizing'.tr()} ${i + 1} ${'of'.tr()} ${lyrics.length}: $progressPercentage%';
          onProgress(progressMessage);
          log('$file $progressPercentage%');
        });
      }
      onProgress('');
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: 'Update complete!'.tr());
    } catch (e) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: Failure.fromError(e).message);
    }
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
    int index = notes.indexWhere((note) => note.id == data.id);

    if (index != -1) {
      notes[index] = data; // Replace the note with the same id
    } else {
      notes.add(data); // Add the note if it doesn't exist in the list
    }

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
    emit(state.copyWith(defaultTextScale: state.defaultTextScale + factor));
  }

  syncSong() async {
    // final response = await repository
  }

  Future<String?> isMidiAvailable(Song song) async {
    List<String> enableMusicCode =
        (await FirebaseUtils.stringConfig('enabled_music_code')).split(',');
    if (enableMusicCode.contains(song.code)) return null;
    try {
      var asset = 'assets/data/sounds/${song.number}.MID';
      await rootBundle.load(asset);
      return asset;
    } catch (e) {
      return null;
    }
  }

  pause() {
    songHandler.pause();
  }

  play() {
    songHandler.play();
  }

  Reference get storage => FirebaseStorage.instance.ref();

  Future<String?> fetchAvailableSong(Song? song, [bool? reload]) async {
    if (song == null) return null;
    emit(state.copyWith(isAudioLoading: true));
    String? midi = await isMidiAvailable(song);
    String? mp3 = await isMp3Available(song);
    List<String> data = [];
    if (midi != null) data.add(midi);
    if (mp3 != null) data.add(mp3);
    var result = data.firstWhereOrNull(
        (element) => element.toLowerCase().contains(state.defaultAudioFormat));
    if (result == null && data.isNotEmpty) {
      result = data.firstOrNull;
      if (result != null) {
        changeAudioFormat(result.startsWith('assets') ? 'midi' : 'mp3', false);
        if (reload == true) {
          Fluttertoast.cancel();
          Fluttertoast.showToast(
              msg: '${!result.startsWith('assets') ? 'MIDI' : 'MP3'} not found'
                  .tr());
        }
      }
    }
    if (result != null) {
      late Source url;
      var source = result;
      if (result.startsWith('assets')) {
        url = AssetSource(source.replaceAll('assets/', ''));
        await audioPlayer.audioCache.clearAll();

        songHandler.setSource(url, song).then((value) async {
          emit(state.copyWith(isAudioLoading: false));
          // await Future.delayed(const Duration(seconds: 1));
          // audioPlayer
          //     .play(audioPlayer.source!)
          //     .then((value) => audioPlayer.stop());
        });
      } else {
        DefaultCacheManager().getSingleFile(source).then((value) {
          url = DeviceFileSource(value.path);
          songHandler.setSource(url, song).then((value) async {
            emit(state.copyWith(isAudioLoading: false));
            // await Future.delayed(const Duration(seconds: 1));

            // audioPlayer
            //     .play(audioPlayer.source!)
            //     .then((value) => audioPlayer.stop());
          });
        });
      }
    } else {
      emit(
        state.copyWith(
          isAudioLoading: false,
          showAudio: false,
        ),
      );
    }
    return result;
  }

  changeAudioFormat(String format, bool reload) {
    emit(state.copyWith(defaultAudioFormat: format));
    if (reload) {
      fetchAvailableSong(state.currentSong!.songs[state.pageIndex], reload);
    }
  }

  Future<String?> isMp3Available(Song song) async {
    List<String> enableMusicCode =
        (await FirebaseUtils.stringConfig('enabled_music_code')).split(',');
    if (enableMusicCode.contains(song.code)) return null;
    try {
      final result = await storage
          .child('/Kidungpujian/song/${song.number}.mp3')
          .getDownloadURL()
          .timeout(
            Duration(seconds: 5),
          );
      return result;
    } catch (e) {
      return null;
    }
  }

  toggleSizer() {
    emit(state.copyWith(showSizer: !state.showSizer));
  }

  toggleAudio([bool? show]) {
    emit(state.copyWith(showAudio: show ?? !state.showAudio));
  }

  changeFont(String font) {
    emit(state.copyWith(defaultFont: font));
  }

  changeTextScale(double value) {
    emit(state.copyWith(defaultTextScale: value));
  }

  changeTextHeight(double value) {
    emit(state.copyWith(defaultTextHeight: value));
  }

  changePage(int index, int verseIndex) async {
    await songHandler.seek(Duration.zero);
    songHandler.stop();
    debounce(() => fetchAvailableSong(state.songs[index]));
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

  changeBookcode(String bookCode, {bool isFavorite = false}) {
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
      data = List<SongHistory>.from(data).sublist(1, 20);
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

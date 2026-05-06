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

import 'package:pdfx/pdfx.dart';

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

  final _playerStateController = StreamController<PlayerState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();

  Stream<PlayerState> get playerStateStream => _playerStateController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  Timer? _midiPollTimer;
  DateTime _midiStartedAt = DateTime.now();
  Duration _midiAccumulated = Duration.zero;
  Duration _midiDuration = Duration.zero;

  bool get _isMidiActive =>
      Platform.isWindows && songHandler.windowsMidiPlayer.isReady;

  SongCubit(this.songRepository, this.songHandler) : super(const SongState()) {
    _setupAudioStreams();
    initDb().then((value) {
      if (Platform.isIOS) {
        changeAudioFormat('mp3', false);
      }
      getData().then(
        (value) => fetchAvailableSong(
          state.songs[state.pageIndex],
        ),
      );
      Map<String, DateTime> lastSync = Map.from(state.lastSync);
      if (!lastSync.containsKey('song.db')) {
        lastSync['song.db'] = DateTime(2025, 12, 18);
        emit(state.copyWith(lastSync: lastSync));
      }
      checkIsSynced();
    });
  }

  void _setupAudioStreams() {
    _playerStateSub = audioPlayer.onPlayerStateChanged.listen((state) {
      if (!_isMidiActive) _playerStateController.add(state);
    });
    _positionSub = audioPlayer.onPositionChanged.listen((pos) {
      if (!_isMidiActive) _positionController.add(pos);
    });
    _durationSub = audioPlayer.onDurationChanged.listen((dur) {
      if (!_isMidiActive) _durationController.add(dur);
    });
    audioPlayer.onPlayerComplete.listen((_) {
      if (!_isMidiActive) _playerStateController.add(PlayerState.completed);
    });
  }
  Future<bool> downloadLyric(
      String sRemoteName,
      File localFile,
      Function(double progressInPercent, int totalReceived, int fileSize)
          onProgress) async {
    if (!isFirebaseStorageConfiguredForCurrentPlatform) {
      return false;
    }
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
    if (!isFirebaseStorageConfiguredForCurrentPlatform) {
      return false;
    }
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
/*
  int imageLyricRequestId = 0;
  Future<List<Uint8List>> getImageLyricPath(
      String bookCode,
      int pageStart, int pageLength) async {
    final result = <Uint8List>[];
    final int requestId = ++imageLyricRequestId;
    try {
      var file = File('${di<AppDirectory>().songLyricFolder}/$bookCode.pdf');
      if (!file.existsSync()) {
        var data = await rootBundle.load('assets/data/$bookCode.pdf');
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await file.writeAsBytes(bytes, flush: true);
      }

      final document = await PdfDocument.openFile(file.path);
      for (var i = 0; i < pageLength; i++) {
        // cek apakah request masih valid 
        if (requestId != imageLyricRequestId) { 
          await document.close(); 
          return []; // future lama dibatalkan 
        }
        final page = await document.getPage(pageStart + i);
        // cek sebelum render (render paling berat)
        if (requestId != imageLyricRequestId) {
          await page.close();
          await document.close();
          return [];
        }
        final pageImage = await page.render(
          width: (page.width * 2).toDouble(),
          height: (page.height * 2).toDouble(),
          format: PdfPageImageFormat.png,
          backgroundColor: '#FFFAFAFA', // tetap putih
        );
        result.add(pageImage!.bytes);
        await page.close();
      }
      await document.close();

      log('###PDF: $bookCode [LEN=${result.length}] ==> ${file.path}');
    } catch (e) {
      log(e.toString());
    }
    return result;
  }
*/

  int imageLyricRequestId = 0;

  // cache terakhir untuk reuse Future
  Future<List<Uint8List>>? imageLyricLastFuture;
  String? imageLyricLastKey;

  Future<List<Uint8List>> getImageLyricPath(
      String bookCode, int pageStart, int pageLength) async {
    final key = '$bookCode-$pageStart-$pageLength';

    // kalau request sama dengan yang terakhir, pakai Future sebelumnya
    if (imageLyricLastFuture != null && imageLyricLastKey == key) {
      return imageLyricLastFuture!;
    }

    final int requestId = ++imageLyricRequestId;
    imageLyricLastKey = key;

    // async function yang benar
    Future<List<Uint8List>> loader() async {
      final result = <Uint8List>[];
      try {
        var file = File('${di<AppDirectory>().songLyricFolder}/$bookCode.pdf');
        if (!file.existsSync()) {
          var data = await rootBundle.load('assets/data/$bookCode.pdf');
          List<int> bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await file.writeAsBytes(bytes, flush: true);
        }

        final document = await PdfDocument.openFile(file.path);

        for (var i = 0; i < pageLength; i++) {
          if (requestId != imageLyricRequestId) {
            await document.close();
            return []; // cancel future lama
          }

          final page = await document.getPage(pageStart + i);

          if (requestId != imageLyricRequestId) {
            await page.close();
            await document.close();
            return [];
          }

          final pageImage = await page.render(
            width: (page.width * 2).toDouble(),
            height: (page.height * 2).toDouble(),
            format: PdfPageImageFormat.png,
            backgroundColor: '#FFFAFAFA',
          );

          result.add(pageImage!.bytes);
          await page.close();
        }

        await document.close();

        log('###PDF: $bookCode [LEN=${result.length}] ==> ${file.path}');
      } catch (e) {
        log('Error getImageLyricPath: $e');
      }
      return result;
    }

    imageLyricLastFuture = loader();
    return imageLyricLastFuture!;
  }

  Future<bool> isSynced() async {
    await checkingSyncCompleter.future;

    return !state.remoteLyricsUpdateAt.keys.any((filename) =>
        !state.lastSync.containsKey(filename) ||
        state.remoteLyricsUpdateAt[filename]!
            .isAfter(state.lastSync[filename] ?? DateTime(2022)));
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
  Future<bool> checkIsSynced() async {
    checkingSyncCompleter = Completer();
    if (!isFirebaseStorageConfiguredForCurrentPlatform) {
      if (!checkingSyncCompleter.isCompleted) {
        checkingSyncCompleter.complete(false);
      }
      return true;
    }
    AppDirectory localDir = di();
    try {
      Map<String, DateTime> remoteLyricsUpdateAt =
          Map.from(state.remoteLyricsUpdateAt);
      final storage = FirebaseStorage.instance;
      final songDbRef = storage.ref('v2/song/song.db');

      final db = await songDbRef.getMetadata();
      if (db.updated != null || db.timeCreated != null) {
        remoteLyricsUpdateAt[basename(db.name)] = db.updated ?? db.timeCreated!;
      }

      final difference = db.updated
              ?.difference(
                state.lastSync[basename(db.name)] ??
                    db.updated ??
                    DateTime.now(),
              )
              .inMinutes ??
          0;

      final localFile = File(localDir.songDbPath);
      final isSyncronized =
          (difference.isNegative || difference == 0) && localFile.existsSync();

      if (isSyncronized) {
        final Map<String, DateTime> lastSync = Map.from(state.lastSync)
          ..[basename(db.name)] = DateTime.now();
        emit(state.copyWith(lastSync: lastSync));
      }

      final lyricFolderRef = await storage.ref('v2/song/lyrics').listAll();

      for (var book in state.songBook) {
        final remoteBook = lyricFolderRef.items
            .firstWhereOrNull((element) => element.name == '${book.code}.pdf');

        if (remoteBook != null) {
          final meta = await remoteBook.getMetadata();
          remoteLyricsUpdateAt[remoteBook.name] =
              meta.updated ?? meta.timeCreated ?? DateTime.now();
        }
      }

      emit(state.copyWith(remoteLyricsUpdateAt: remoteLyricsUpdateAt));
      if (!checkingSyncCompleter.isCompleted) {
        checkingSyncCompleter.complete(true);
      }
      return isSyncronized;
    } catch (e) {
      if (!checkingSyncCompleter.isCompleted) {
        checkingSyncCompleter.complete(false);
      }
      log(e.toString());
    }
    return true;
  }

  void sync(SongState songState) {
    emit(songState);
  }

  Future<void> syncDbAndLyric(
      {required Function(String status) onProgress}) async {
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

  void onSearchTermsChanged(String text) {
    emit(state.copyWith(searchTerms: text));
  }

  Future<void> toggleShuffle() async {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
        msg: 'Shuffle mode ${state.shuffleMode ? 'disabled' : 'enabled'}');
    emit(state.copyWith(shuffleMode: !state.shuffleMode));
  }

  void changeSortNote(String sortBy) {
    emit(state.copyWith(sortNotesBy: sortBy));
  }

  void saveNote(SongNote data) {
    var notes = List<SongNote>.from(state.notes);
    int index = notes.indexWhere((note) => note.id == data.id);

    if (index != -1) {
      notes[index] = data; // Replace the note with the same id
    } else {
      notes.add(data); // Add the note if it doesn't exist in the list
    }

    emit(state.copyWith(notes: notes));
  }

  Future<void> deleteNote(SongNote data) async {
    var notes = List<SongNote>.from(state.notes);
    notes.remove(data);

    emit(state.copyWith(notes: notes));
  }

  Future<void> removeSelection() async {
    emit(state.copyWith(selectedSong: null));
  }

  void selectSong(Song song) {
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

  void modifyTextScaleFactor(double factor) {
    emit(state.copyWith(defaultTextScale: state.defaultTextScale + factor));
  }

  Future<void> syncSong() async {
    // final response = await repository
  }

  Future<String?> isMidiAvailable(Song song) async {
    List<String> enableMusicCode =
        (await FirebaseUtils.stringConfig('enabled_music_code')).split(',');
    if (enableMusicCode.contains(song.code)) return null;
    try {
      final upperCode = song.code?.toUpperCase() ?? '';
      if (!['KR', 'HYMNE', 'MDR'].any(upperCode.contains)) {
        return null;
      }
      var asset = 'assets/data/sounds/${song.number}.MID';
      await rootBundle.load(asset);
      return asset;
    } catch (e) {
      return null;
    }
  }

  void pause() {
    if (_isMidiActive) {
      songHandler.pause();
      _stopMidiPolling();
      _midiAccumulated = _midiAccumulated +
          (DateTime.now().difference(_midiStartedAt));
      _playerStateController.add(PlayerState.paused);
      return;
    }
    songHandler.pause().catchError(
          (e) => log('Song pause failed: $e', name: 'SongCubit'),
        );
  }

  void play() {
    if (_isMidiActive) {
      songHandler.play();
      _midiStartedAt = DateTime.now();
      _startMidiPolling();
      _playerStateController.add(PlayerState.playing);
      return;
    }
    songHandler.play().catchError(
          (e) => log('Song play failed: $e', name: 'SongCubit'),
        );
  }

  void _startMidiPolling() {
    _stopMidiPolling();
    _midiPollTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!_isMidiActive) {
        _stopMidiPolling();
        return;
      }
      final mode = songHandler.windowsMidiPlayer.getMode();
      if (mode == null || mode == 'stopped') {
        _stopMidiPolling();
        _playerStateController.add(PlayerState.completed);
        return;
      }
      final posMs = songHandler.windowsMidiPlayer.getPositionMs();
      if (posMs != null) {
        _positionController.add(Duration(milliseconds: posMs));
      } else {
        final elapsed = DateTime.now().difference(_midiStartedAt) + _midiAccumulated;
        _positionController.add(elapsed);
      }
      final lenMs = songHandler.windowsMidiPlayer.getLengthMs();
      if (lenMs != null && lenMs > 0) {
        _midiDuration = Duration(milliseconds: lenMs);
      } else if (_midiDuration == Duration.zero) {
        _midiDuration = const Duration(seconds: 300);
      }
      _durationController.add(_midiDuration);
    });
  }

  void _stopMidiPolling() {
    _midiPollTimer?.cancel();
    _midiPollTimer = null;
  }

  void _resetMidiState() {
    _stopMidiPolling();
    _midiAccumulated = Duration.zero;
    _midiStartedAt = DateTime.now();
    _midiDuration = Duration.zero;
    _playerStateController.add(PlayerState.stopped);
  }

  Reference get storage => FirebaseStorage.instance.ref();

  Future<String?> fetchAvailableSong(Song? song, [bool? reload]) async {
    if (song == null) return null;
    emit(state.copyWith(isAudioLoading: true));
    String? midi = Platform.isIOS ? null : await isMidiAvailable(song);
    // String? mp3 = await isMp3Available(song); //.apm:20251219:ref hy:hanya allow midi;
    List<String> data = [];
    if (midi != null) data.add(midi);
    // if (mp3 != null) data.add(mp3); //.apm:20251219:ref hy:hanya allow midi;
    var result = data.firstWhereOrNull(
        (element) => element.toLowerCase().contains(state.defaultAudioFormat));
    if (result == null && data.isNotEmpty) {
      result = data.firstOrNull;
      if (result != null) {
        changeAudioFormat(result.startsWith('assets') ? 'midi' : 'mp3', false);
        if (reload == true) {
          try { Fluttertoast.cancel(); } catch (_) {}
          try {
            Fluttertoast.showToast(
                msg: '${!result.startsWith('assets') ? 'MIDI' : 'MP3'} not found'
                    .tr());
          } catch (_) {}
        }
      }
    }
    if (result != null) {
      late Source url;
      var source = result;
      if (result.startsWith('assets')) {
        if (Platform.isWindows && result.toLowerCase().endsWith('.mid')) {
          final midiOk = await songHandler.setWindowsMidiAsset(source, song);
          if (!midiOk) {
            try { Fluttertoast.cancel(); } catch (_) {}
            try { Fluttertoast.showToast(msg: 'MIDI playback not available'.tr()); } catch (_) {}
            emit(state.copyWith(isAudioLoading: false, showAudio: false));
            return null;
          }
          _resetMidiState();
          _positionController.add(Duration.zero);
          _durationController.add(Duration.zero);
          emit(state.copyWith(isAudioLoading: false));
          return result;
        }
        url = AssetSource(source.replaceAll('assets/', ''));
        try {
          await audioPlayer.audioCache.clearAll();
        } catch (_) {
          // abaikan karena cache mungkin memang kosong atau belum dibuat
        }

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

  void changeAudioFormat(String format, bool reload) {
    emit(state.copyWith(defaultAudioFormat: format));
    if (reload) {
      fetchAvailableSong(state.currentSong!.songs[state.pageIndex], reload);
    }
  }

  Map<String, String> downloadUrls = {};

  Future<String?> isMp3Available(Song song) async {
    if (!isFirebaseStorageConfiguredForCurrentPlatform) {
      return null;
    }
    List<String> enableMusicCode =
        (await FirebaseUtils.stringConfig('enabled_music_code')).split(',');
    if (enableMusicCode.contains(song.code)) return null;
    try {
      if (downloadUrls.containsKey(song.number)) {
        return downloadUrls[song.number];
      }
      final result = await storage
          .child('/Kidungpujian/song/${song.number}.mp3')
          .getDownloadURL()
          .timeout(
            Duration(seconds: 30),
          );
      downloadUrls[song.number!] = result;
      return result;
    } catch (e) {
      return null;
    }
  }

  void toggleSizer() {
    emit(state.copyWith(showSizer: !state.showSizer));
  }

  void toggleAudio([bool? show]) {
    emit(state.copyWith(showAudio: show ?? !state.showAudio));
  }

  void changeFont(String font) {
    emit(state.copyWith(defaultFont: font));
  }

  void changeTextScale(double value) {
    emit(state.copyWith(defaultTextScale: value));
  }

  void changeTextHeight(double value) {
    emit(state.copyWith(defaultTextHeight: value));
  }

  Future<void> changePage(int index, int verseIndex) async {
    await songHandler.seek(Duration.zero);
    songHandler.stop();
    if (_isMidiActive) _resetMidiState();
    fetchAvailableSong(state.songs[index]);
    emit(state.copyWith(pageIndex: index, verseIndex: verseIndex));
  }

  Timer? debouncer;

  void debounce(Function() callback) {
    if (debouncer?.isActive == true) {
      debouncer?.cancel();
    }
    debouncer = Timer(const Duration(seconds: 1), callback);
  }

  void changeMode() {
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

  void modifyFavorite(Song song, {bool playOnlyFav = true}) {
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
    final hasFavoriteSongs = modifiedSongBook.any((sb) => sb.songs.isNotEmpty);
    emit(state.copyWith(
        favoriteSongBook: modifiedSongBook,
        playOnlyFavorite: playOnlyFav && hasFavoriteSongs));
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

  void changeBookcode(String bookCode, {bool isFavorite = false}) {
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

  void deleteHistory(SongHistory history) {
    emit(state.copyWith(
        histories: List<SongHistory>.from(state.histories)..remove(history)));
  }

  void addToHistory(SongHistory item) {
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
    _stopMidiPolling();
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateController.close();
    _positionController.close();
    _durationController.close();
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

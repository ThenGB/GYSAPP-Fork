import 'dart:developer';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:sqflite_common/sqflite.dart' show Database;

import '../../../data/services/bible_tts_service.dart';
import '../../../data/services/installed_bible_db.dart';
import '../../../data/services/local_bible_asset_service.dart';
import '../../../data/utilities/string_utils.dart';
import '../../../di/injection.dart';
import '../../../domain/entity/bcvbc/bcvbc.dart';
import '../../../domain/entity/bible_book/bible_book.dart';
import '../../../domain/entity/bible_bookmark/bible_bookmark.dart';
import '../../../domain/entity/bible_note/bible_note.dart';
import '../../../domain/entity/bible_ref/bible_ref.dart';
import '../../../domain/entity/pericope/pericope.dart';
import '../../../domain/entity/pericope_paralel/pericope_paralel.dart';
import '../../../domain/entity/verse/verse.dart';
import '../../../domain/repository/bible_repository.dart';
import '../bible.dart';

export 'bible_state.dart';

class BibleCubit extends HydratedCubit<BibleState> {
  BibleCubit() : super(const BibleState()) {
    initBible();
    initTts();
    log('Initialized BibleCubit');
    incrementTodayReading();
  }

  final BibleTtsService tts = BibleTtsService();

  /// Whether the Edge engine is currently selected (falls back to native
  /// automatically when offline).
  BibleTtsEngine get activeTtsEngine =>
      state.ttsEngine == 'native'
          ? BibleTtsEngine.native
          : BibleTtsEngine.edge;

  bool get isSelectingBible => state.selectedVerse.isNotEmpty;

  BibleRepository bibleRepository = di();
  LocalBibleAssetService bibleAssetService = di();

  Database? bibleDb;
  Database? splitBibleDb;
  bool get _usesAssetBible =>
      bibleAssetService.isBundledCode(state.currentBibleCode);

  /// Pure decision helper for the main-version switch: should the split pane
  /// follow the new main version?
  ///
  /// True when the split was mirroring the main — either sharing the same
  /// database handle, or both using the same bundled (non-DB) code. False
  /// when the split holds an independently selected version, so switching
  /// the main pane leaves the split untouched.
  static bool splitShouldFollowMain({
    required Database? splitBibleDb,
    required Database? previousBibleDb,
    required String splitBibleCode,
    required String currentBibleCode,
  }) {
    // Note: the null-guard matters — when both handles are null (bundled
    // versions), sharing is decided by code equality, and an independent
    // bundled split (B != A) must NOT be re-pointed.
    return (splitBibleDb != null && splitBibleDb == previousBibleDb) ||
        (splitBibleDb == null && splitBibleCode == currentBibleCode);
  }
  bool get _usesSplitAssetBible =>
      bibleAssetService.isBundledCode(state.splitBibleCode);

  Future<void> initBible() async {
    if (_usesAssetBible) {
      await getBibles();
      await getContent(state.currentBible);
      return;
    }

    Database? bibleDbOpened;
    try {
      bibleDbOpened = await InstalledBibleDb.open(
        state.currentBibleCode,
        readOnly: true,
      );
    } catch (e) {
      log('Failed to open Bible DB for ${state.currentBibleCode}: $e',
          name: 'BibleCubit');
      return;
    }
    if (bibleDbOpened == null) {
      log(
        'Failed to open Bible DB for ${state.currentBibleCode}',
        name: 'BibleCubit',
      );
      return;
    }
    bibleDb = bibleDbOpened;
    splitBibleDb = bibleDb;
    getContent(state.currentBible);
  }

  void updateFilterBook(List<BibleBook> values) {
    emit(state.copyWith(selectedFilterBooks: values));
  }

  void sync(BibleState bibleState) {
    emit(bibleState);
  }

  void applyTtsSetting(Map<String, Map> voices, double pitch, double speed) {
    emit(state.copyWith(voices: voices, pitchRate: pitch, speedRate: speed));
  }

  void onFilterPerjanjianLama() {
    if (state.isSelectedPerjanjianLama == null ||
        state.isSelectedPerjanjianLama == true) {
      List<BibleBook> listPerjanjianLama = List.from(state.selectedFilterBooks)
        ..removeWhere((element) => element.id <= 39);
      updateFilterBook(listPerjanjianLama);
    } else if (state.isSelectedPerjanjianLama == false) {
      List<BibleBook> listAdd = List.from(state.books)
        ..removeWhere((element) => element.id > 39);
      updateFilterBook(List.from(state.selectedFilterBooks)..addAll(listAdd));
    }
  }

  void onFilterCurrentBible() {
    if (state.selectedFilterBooks.length == 1 &&
        state.selectedFilterBooks.single == state.currentBook) {
      updateFilterBook([]);
    } else {
      updateFilterBook([state.currentBook!]);
    }
  }

  void onFilterPerjanjianBaru() {
    if (state.isSelectedPerjanjianBaru == null ||
        state.isSelectedPerjanjianBaru == true) {
      List<BibleBook> listPerjanjianLama = List.from(state.selectedFilterBooks)
        ..removeWhere((element) => element.id > 39);
      updateFilterBook(listPerjanjianLama);
    } else if (state.isSelectedPerjanjianBaru == false) {
      List<BibleBook> listAdd = List.from(state.books)
        ..removeWhere((element) => element.id <= 39);
      updateFilterBook(List.from(state.selectedFilterBooks)..addAll(listAdd));
    }
  }

  late List<GlobalKey<VerseWidgetState>> verseKeys = List.generate(
    state.verses.length,
    (index) => GlobalKey<VerseWidgetState>(debugLabel: index.toString()),
  );
  late List<GlobalKey<VerseWidgetState>> verseKeys2 = List.generate(
    state.verses.length,
    (index) => GlobalKey<VerseWidgetState>(debugLabel: index.toString()),
  );

  void modifyBookmark() {
    List<BibleBookmark> bookmarks = List.from(state.bookmarks);
    List<BibleBookmark> newValues = List.from(state.selectedVerse)
        .map(
          (e) => BibleBookmark(
            createdAt: DateTime.now(),
            isBookmarkAll: false,
            verse: e,
          ),
        )
        .toList();
    if (newValues.isEmpty) {
      newValues.add(
        BibleBookmark(
          createdAt: DateTime.now(),
          isBookmarkAll: true,
          verse: state.verses.first,
        ),
      );
    }

    for (BibleBookmark item in newValues) {
      var savedItem = bookmarks.indexWhere(
        (element) =>
            element.isBookmarkAll == item.isBookmarkAll &&
            element.verse.verseId == item.verse.verseId,
      );
      if (!savedItem.isNegative) {
        bookmarks.removeAt(savedItem);
      } else {
        bookmarks.add(item);
      }
    }

    if (bookmarks.length > 20) {
      // Keep the latest 20 bookmarks
      bookmarks = bookmarks.sublist(bookmarks.length - 20);
    }
    // Fluttertoast.cancel();
    // Fluttertoast.showToast(
    //     msg:
    //         'Bookmarks modified! To see all bookmark, tap on "See all bookmarks"'
    //             .tr());
    emit(
      state.copyWith(
        bookmarks: List.from(bookmarks)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      ),
    );
  }

  /// Builds the TTS sentence for [verse], stripping markup and applying the
  /// pronunciation tweaks used across all playback modes.
  String _buildTtsSentence(Verse verse) {
    List<Pericope>? pericope = state.pericopes.getById(verse.id);
    String sentence = '';
    if (pericope.isNotEmpty) {
      sentence += pericope.map((e) => '${e.title ?? ''}. ').join();
    }
    sentence += (verse.verse ?? '').replaceAll('  ', ' ');
    sentence = sentence.replaceAll('Allah', 'Alla');
    sentence = sentence.replaceAll('allah', 'alla');
    sentence = sentence.replaceAll('Demikian', 'Demi kian');
    sentence = sentence.replaceAll('demikian', 'demi kian');
    sentence = sentence.replaceAll('Pentakosta', 'Penta kosta');
    sentence = sentence.replaceAll('pentakosta', 'penta kosta');
    sentence = removeTextBetweenTags(sentence, 'f');
    sentence = sentence.replaceAll('<pb/>', '    ');
    sentence = sentence.replaceAll('<t>', '');
    sentence = sentence.replaceAll('</t>', '');
    sentence = sentence.replaceAll('<i>', '');
    sentence = sentence.replaceAll('</i>', '');
    sentence = sentence.replaceAll('<J>', '');
    sentence = sentence.replaceAll('</J>', '');
    return sentence;
  }

  /// Plays the Bible starting from [fromVerseId] (or the current verse when
  /// null). When [onlyThisVerse] is true, a single verse is spoken; otherwise
  /// the chapter is read from that verse to the end, optionally continuing to
  /// the next chapter when [autoNextChapter] (state) is enabled.
  Future<void> speakTheBible({
    int? fromVerseId,
    bool onlyThisVerse = false,
  }) async {
    if (state.isSpeaking) {
      await stopSpeaking();
    }
    emit(
      state.copyWith(
        isSpeaking: true,
        isTtsPaused: false,
        isSpeakingSelectedOnly: onlyThisVerse || state.selectedVerse.isNotEmpty,
      ),
    );

    List<Verse> verses;
    if (state.selectedVerse.isNotEmpty && !onlyThisVerse) {
      verses = List.from(
        state.selectedVerse.sorted((a, b) => a.verseId.compareTo(b.verseId)),
      );
    } else if (onlyThisVerse) {
      final match = state.verses.where(
        (v) => fromVerseId == null || v.verseId == fromVerseId,
      );
      verses = match.isNotEmpty
          ? [match.first]
          : List.from(state.verses);
    } else {
      verses = List.from(state.verses);
      if (fromVerseId != null) {
        final startIndex = verses.indexWhere(
          (v) => v.verseId >= fromVerseId,
        );
        if (startIndex > 0) {
          verses = verses.sublist(startIndex);
        } else if (startIndex == -1) {
          verses = [];
        }
      }
    }

    for (var i = 0; i < verses.length; i++) {
      if (!state.isSpeaking) break;
      while (state.isTtsPaused && state.isSpeaking) {
        await Future.delayed(const Duration(milliseconds: 250));
      }
      if (!state.isSpeaking) break;

      final verse = verses[i];
      emit(
        state.copyWith(
          currentBible: verse,
          ttsCurrentVerseIndex: i,
          currentStartWord: 0,
          currentEndWord: 0,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (!state.isSpeaking) break;

      final sentence = _buildTtsSentence(verse);
      final ok = await tts.speak(
        sentence,
        engine: activeTtsEngine,
      );
      if (!ok) {
        log('TTS speak failed for verse ${verse.verseId}', name: 'BibleCubit');
        emit(state.copyWith(isSpeaking: false));
        return;
      }
    }

    // Auto-continue to the next chapter when enabled and this chapter ended.
    if (state.isSpeaking &&
        state.autoNextChapter &&
        verses.isNotEmpty &&
        !state.isSpeakingSelectedOnly) {
      final next = await _nextChapterForTts();
      if (next != null) {
        await speakTheBible(fromVerseId: next);
        return;
      }
    }
    emit(state.copyWith(isSpeaking: false));
  }

  /// Resolves the first verse id of the next chapter (or null at the end of
  /// the Bible). Used by the auto-next-chapter playback option.
  Future<int?> _nextChapterForTts() async {
    final currentBook = state.currentBook ?? state.books.firstOrNull;
    if (currentBook == null) return null;
    final currentVerse = state.currentBible;
    if (currentVerse == null) return null;

    BibleBook? nextBook = currentBook;
    final currentChapterCount = currentBook.chapterCount ?? 1;
    int nextChapter = currentVerse.chapterId + 1;
    if (nextChapter > currentChapterCount) {
      nextChapter = 1;
      final idx = state.books.indexWhere((b) => b.id == currentBook.id);
      if (idx == -1 || idx + 1 >= state.books.length) return null;
      nextBook = state.books[idx + 1];
    }
    try {
      await getContent(
        Verse(
          id: nextBook.id * 1000000 + nextChapter * 1000 + 1,
          bookId: nextBook.id,
          chapterId: nextChapter,
          verseId: 1,
        ),
      );
      return state.verses.firstOrNull?.verseId;
    } catch (e) {
      log('Auto-next chapter failed: $e', name: 'BibleCubit');
      return null;
    }
  }

  /// Pauses or resumes the current speech.
  Future<void> togglePauseTts() async {
    if (!state.isSpeaking) return;
    final paused = !state.isTtsPaused;
    emit(state.copyWith(isTtsPaused: paused));
    if (paused) {
      await tts.stop();
    }
  }

  Future<void> stopSpeaking() async {
    await tts.stop();
    emit(state.copyWith(isSpeaking: false, isTtsPaused: false));
  }

  void replaceBookmarks(List<BibleBookmark> items) {
    emit(state.copyWith(bookmarks: items));
  }

  Future<List<Verse>> searchBibleByString(String searchText) async {
    if (searchText.isEmpty) return [];
    if (_usesAssetBible) {
      return bibleAssetService.search(
        state.currentBibleCode,
        searchText,
        state.selectedFilterBooks,
      );
    }
    final response = await bibleRepository.search(
      bibleDb!,
      searchText,
      state.selectedFilterBooks,
    );
    return response;
  }

  void toggleAudio() {
    emit(state.copyWith(enableAudio: !state.enableAudio));
  }

  /// Selects the TTS engine: 'edge' (default) or 'native'. Edge falls back
  /// to the built-in native engine automatically when offline.
  void setTtsEngine(String engine) {
    final normalized = engine == 'native' ? 'native' : 'edge';
    emit(state.copyWith(ttsEngine: normalized));
    tts.engine = normalized == 'native'
        ? BibleTtsEngine.native
        : BibleTtsEngine.edge;
  }

  void setAutoNextChapter(bool value) {
    emit(state.copyWith(autoNextChapter: value));
  }

  void setEdgeVoice(String voice) => emit(state.copyWith(edgeVoice: voice));
  void setEdgeRate(String rate) => emit(state.copyWith(edgeRate: rate));
  void setEdgePitch(String pitch) => emit(state.copyWith(edgePitch: pitch));
  void setEdgeVolume(String volume) =>
      emit(state.copyWith(edgeVolume: volume));

  Future<void> initTts() async {
    tts.engine = state.ttsEngine == 'native'
        ? BibleTtsEngine.native
        : BibleTtsEngine.edge;
    tts.edgeVoice = state.edgeVoice;
    tts.edgeRate = state.edgeRate;
    tts.edgePitch = state.edgePitch;
    tts.edgeVolume = state.edgeVolume;

    // Configure the native fallback engine — the same instance the service
    // uses to speak, so config + progress handlers stay in sync.
    final nativeTts = tts.nativeTts;
    if (nativeTts == null) return;
    try {
      await nativeTts.awaitSpeakCompletion(true);
      if (!Platform.isWindows) {
        await nativeTts.awaitSynthCompletion(true);
      }
      await nativeTts.setSpeechRate(state.speedRate);
      await nativeTts.setPitch(state.pitchRate);
      List<String> langs = ((await nativeTts.getLanguages) as List<Object?>)
          .cast<String>()
          .toList();
      final lang = langs
          .map((e) => e.split('-').first)
          .toList()
          .indexWhere(
            (element) => element == state.currentBibleLanguage.split('-').first,
          );
      if (!lang.isNegative) {
        await nativeTts.setLanguage(langs[lang]);
      }
      List<Map> voices = (await nativeTts.getVoices as List<Object?>)
          .cast<Map>()
          .toList()
          .map(
            (e) => e.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          )
          .toList();
      var currentLang = state.currentBibleLanguage;
      var langPrefix = currentLang.split('-').first;
      Map<String, String>? voice = (voices.firstWhereOrNull(
        (element) => element['locale'] == currentLang,
      ))?.map((key, value) => MapEntry(key.toString(), value.toString()));
      voice ??= (voices.firstWhereOrNull(
        (element) => element['locale'] == langPrefix,
      ))?.map((key, value) => MapEntry(key.toString(), value.toString()));
      voice ??= (voices.firstWhereOrNull(
        (element) => element['locale'].toString().startsWith('$langPrefix-'),
      ))?.map((key, value) => MapEntry(key.toString(), value.toString()));
      if (voice != null) {
        var savedVoice = state.voices[currentLang];
        if (savedVoice == null) {
          var savedVoices = Map.from(state.voices);
          savedVoices[currentLang] = voice;
          emit(state.copyWith(voices: savedVoices.cast()));
        }
        await nativeTts.setVoice(savedVoice?.cast() ?? voice);
      }
      await nativeTts.setVolume(1);
      await tts.configureNative(
        voice: voice,
        pitch: state.pitchRate,
        speed: state.speedRate,
      );
    } catch (e) {
      log('TTS initialization failed: $e', name: 'BibleCubit');
      return;
    }

    nativeTts.setProgressHandler((text, start, end, word) {
      log(
        'TTS Speaking \ntext: $text\nstart: $start\nend: $end\nword: $word\n',
        name: 'Speaking',
      );
      var mustAdd = [
        'Alla',
        'alla',
        'Penta kosta',
        'Demi kian',
        'penta kosta',
        'demi kian',
      ];
      log(end.toString(), name: 'END BEFORE ADD');
      if (mustAdd.any((element) => text.contains(element))) {
        start =
            start + countSelectedWords(text.substring(0, end + 4), mustAdd) - 1;
        if (start.isNegative) {
          start = 0;
        }
        end = end + countSelectedWords(text.substring(0, end + 4), mustAdd);
      }
      log(end.toString(), name: 'END AFTER ADD');
      if (mustAdd.contains(word)) {
        // end = end + 1;
        word = word.replaceAll('Alla', 'Allah');
        word = word.replaceAll('alla', 'allah');
        word = word.replaceAll('Demi kian', 'Demikian');
        word = word.replaceAll('demi kian', 'demikian');
        word = word.replaceAll('Penta kosta', 'Pentakosta');
        word = word.replaceAll('penta kosta', 'pentakosta');
      }

      emit(
        state.copyWith(
          currentWord: word,
          currentStartWord: start,
          currentEndWord: end,
        ),
      );
    });
  }

  /// Advances the daily reading target to today.
  ///
  /// The target advances one chapter per calendar day missed since the last
  /// time the user opened the Bible, so a reader who opens the app after
  /// three days lands on the chapter for today (catch-up), not three days
  /// behind. Safe on cold start: book metadata is reloaded when needed and
  /// the Bible end is handled by stopping at the last chapter.
  Future<void> incrementTodayReading() async {
    final target = state.todayReading;
    final last = state.lastOpenBible;
    if (target == null || last == null) return;

    final now = DateTime.now();
    final lastDay = DateTime(last.year, last.month, last.day);
    final today = DateTime(now.year, now.month, now.day);
    // Date-based (not 24h-based): reading at 23:00 and opening at 06:00
    // the next day must still advance.
    final missedDays = today.difference(lastDay).inDays;
    if (missedDays < 1) return;

    final books = await _ensureBooksLoaded();
    if (books.isEmpty || isClosed) return;

    final next = advanceReadingFrom(
      books,
      target.bookId,
      target.chapterId,
      missedDays,
    );
    if (next == null || isClosed) return;
    setTodayReading(next);
  }

  /// Ensures the book list is available even on cold start, where
  /// `state.books` is empty because chapter content has not loaded yet.
  Future<List<BibleBook>> _ensureBooksLoaded() async {
    if (state.books.isNotEmpty) return state.books;
    final code = state.currentBibleCode;
    if (bibleAssetService.isBundledCode(code)) {
      return bibleAssetService.getBooks(code);
    }
    if (bibleDb == null) {
      await initBible();
      if (isClosed) return const [];
    }
    final db = bibleDb;
    if (db == null) return const [];
    return bibleRepository.getBooks(db);
  }

  /// Walks [steps] chapters forward from [bookId]/[chapterId] through
  /// [books], crossing book boundaries. Returns null at the end of the
  /// Bible. Pure function — no I/O, no state — so it is directly testable.
  static Verse? advanceReadingFrom(
    List<BibleBook> books,
    int bookId,
    int chapterId,
    int steps,
  ) {
    if (steps < 1 || books.isEmpty) return null;
    final firstBook = books.firstWhereOrNull((e) => e.id == bookId);
    if (firstBook == null || (firstBook.chapterCount ?? 0) < 1) return null;

    var currentBook = firstBook;
    var b = bookId;
    var c = chapterId;
    var remaining = steps;

    while (remaining > 0) {
      final chaptersInBook = currentBook.chapterCount ?? 0;
      final canAdvance = chaptersInBook - c;
      if (canAdvance > 0) {
        final step = math.min(canAdvance, remaining);
        c += step;
        remaining -= step;
      } else {
        // End of this book — move to the first chapter of the next one.
        final idx = books.indexWhere((e) => e.id == b);
        if (idx < 0 || idx == books.length - 1) return null;
        currentBook = books[idx + 1];
        b = currentBook.id;
        c = 1;
        remaining -= 1;
      }
    }

    return Verse(
      id: b * 1000000 + c * 1000 + 1,
      bookId: b,
      chapterId: c,
      verseId: 1,
    );
  }

  int countSelectedWords(String text, List<String> selectedWords) {
    final words = text.split(RegExp(r'\W+'));
    int totalCount = 0;

    for (var word in words) {
      if (selectedWords.contains(word)) {
        totalCount++;
      }
    }
    log(totalCount.toString(), name: 'totalCount');
    return totalCount;
  }

  void setTodayReading(Verse? bible) {
    emit(state.copyWith(todayReading: bible, lastOpenBible: DateTime.now()));
    if (bible != null) changeContent(bible);
  }

  @override
  BibleState? fromJson(Map<String, dynamic> json) {
    return BibleState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(BibleState state) {
    final json = state.toJson();
    // Chapter content is reloadable from the bundled asset / DB and does not
    // need to be persisted. Serializing it on every emit (chapter nav,
    // bookmark toggle, TTS state…) caused multi-hundred-KB jsonEncode + flush
    // disk writes on the UI thread per interaction.
    for (final key in const [
      'books',
      'booksSplit',
      'verses',
      'versesSplit',
      'references',
      'referencesSplit',
      'pericopes',
      'pericopesSplit',
      'pericopesParalels',
      'pericopesParalelsSplit',
      'currentBook',
      'currentBookSplit',
      'selectedVerse',
      'hightlightedVerse',
    ]) {
      json.remove(key);
    }
    return json;
  }

  Future<void> getBibles() async {
    final bibles = <String>{
      ...await InstalledBibleDb.listInstalledCodes(),
      for (final code in await bibleAssetService.getBundledBibleCodes())
        code.split('.').first,
    }.toList()..sort();
    emit(state.copyWith(bibleCodes: bibles));
  }

  Future<void> refreshAvailableBibles() async {
    await getBibles();
    if (!state.bibleCodes.contains(state.currentBibleCode)) {
      await selectBibleCodeByName('b_tb');
    }
  }

  Future<void> releaseResourcesForMaintenance() async {
    final openDatabases = [bibleDb, splitBibleDb].whereType<Database>().toSet();
    bibleDb = null;
    splitBibleDb = null;
    for (final database in openDatabases) {
      await database.close();
    }
    final tts = this.tts;
    await tts.stop();
  }

  Future<List<Verse>> getVersesByBook(int bookId, int chapterId) async {
    if (_usesAssetBible) {
      return bibleAssetService.getVerses(
        state.currentBibleCode,
        bookId: bookId,
        chapterId: chapterId,
      );
    }
    final response = await bibleRepository.getVerses(
      bibleDb!,
      bookId: bookId,
      chapterId: chapterId,
    );
    return response;
  }

  Future<void> selectBibleCode(int index, [bool secondary = false]) async {
    var bibleCode = state.bibleCodes[index].split('.').first;
    await selectBibleCodeByName(bibleCode, secondary: secondary);
  }

  Future<void> selectBibleCodeByName(
    String bibleCode, {
    bool secondary = false,
  }) async {
    /// close current bible
    if (secondary) {
      // Open the new split handle first, then close the old one — a failed
      // switch keeps the current split pane loaded instead of emptying it.
      final previousSplitDb = splitBibleDb;
      Database? nextSplitDb;
      var splitOpened = false;
      try {
        if (bibleAssetService.isBundledCode(bibleCode)) {
          nextSplitDb = null;
          splitOpened = true;
        } else {
          nextSplitDb = await InstalledBibleDb.open(bibleCode);
          splitOpened = nextSplitDb != null;
        }
      } catch (e) {
        log('Failed to open split Bible DB: $e', name: 'BibleCubit');
        nextSplitDb = null;
        splitOpened = false;
      }
      if (!splitOpened) {
        splitBibleDb = previousSplitDb;
        return;
      }
      splitBibleDb = nextSplitDb;
      // If the split pane was sharing the main handle, detach before
      // closing it is not needed here (the main handle stays open), but
      // close the old split handle if it was a distinct database.
      if (previousSplitDb != null && previousSplitDb != bibleDb) {
        await previousSplitDb.close();
      }
      emit(state.copyWith(splitBibleCode: bibleCode));
    } else {
      // Open the new handle first, then close the old one — a failed switch
      // keeps the current Bible loaded instead of leaving an empty pane or
      // claiming a version whose DB could not be opened.
      final previousBibleDb = bibleDb;
      Database? nextBibleDb;
      var opened = false;
      try {
        if (bibleAssetService.isBundledCode(bibleCode)) {
          nextBibleDb = null;
          opened = true;
        } else {
          nextBibleDb = await InstalledBibleDb.open(bibleCode);
          opened = nextBibleDb != null;
        }
      } catch (e) {
        log('Failed to open Bible DB: $e', name: 'BibleCubit');
        nextBibleDb = null;
        opened = false;
      }
      if (!opened) {
        // Keep the previous handle (and code) so the pane stays usable.
        bibleDb = previousBibleDb;
        getContent(state.currentBible);
        return;
      }
      // If the split pane was mirroring the main pane (shared handle, or the
      // same bundled code with no DB), re-point it to the new main handle so
      // it follows the main instead of blanking under a stale label. An
      // independently selected split version stays untouched.
      final splitFollowsMain = splitShouldFollowMain(
        splitBibleDb: splitBibleDb,
        previousBibleDb: previousBibleDb,
        splitBibleCode: state.splitBibleCode,
        currentBibleCode: state.currentBibleCode,
      );
      final nextSplitBibleDb = splitFollowsMain ? nextBibleDb : splitBibleDb;
      final nextSplitCode = splitFollowsMain ? bibleCode : state.splitBibleCode;

      bibleDb = nextBibleDb;
      splitBibleDb = nextSplitBibleDb;
      // Close the old main handle only if the split no longer uses it.
      if (previousBibleDb != null && previousBibleDb != nextSplitBibleDb) {
        await previousBibleDb.close();
      }
      emit(state.copyWith(
        currentBibleCode: bibleCode,
        splitBibleCode: nextSplitCode,
      ));
      initTts();
    }

    getContent(state.currentBible);
  }

  void selectBook(BibleBook book) {
    emit(state.copyWith(currentBook: book));
  }

  Future<String> getBibleTitle(
    List<Verse?> verses, {
    bool withVerse = false,
    bool splitMode = false,
  }) async {
    List<int> parsedVerses = [];
    for (var element in verses) {
      if (element != null) parsedVerses.add(element.id);
    }
    if (splitMode ? _usesSplitAssetBible : _usesAssetBible) {
      return await bibleAssetService.getBibleTitle(
            splitMode ? state.splitBibleCode : state.currentBibleCode,
            parsedVerses,
            isLong: true,
            withVerse: withVerse,
          ) ??
          'Unknown';
    }
    String? title = await convertIDsToNameAlkitab(
      parsedVerses,
      bibleDb: splitMode ? splitBibleDb! : bibleDb!,
      isLong: true,
      withVerse: withVerse,
    );

    return title ?? 'Unknown';
  }

  Future<List<Verse>> getVersesByIdRange(int? start, int? end) async {
    if (_usesAssetBible) {
      return bibleAssetService.getVersesByIdRange(
        state.currentBibleCode,
        fromId: start ?? 1,
        toId: end,
      );
    }
    final response = await bibleRepository.getVersesByIdRange(
      bibleDb!,
      fromId: start ?? 1,
      toId: end,
    );
    return response;
  }

  void saveToHistory(Verse verse) {
    Map<DateTime, Verse> map = Map.from(state.histories);

    // Add the new entry to the map
    map[DateTime.now()] = verse;

    // Convert the map to a list of key-value pairs and sort it by keys in descending order
    List<MapEntry<DateTime, Verse>> sortedEntries = map.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    // Truncate the list to keep only the latest 20 entries
    if (sortedEntries.length > 20) {
      sortedEntries = sortedEntries.sublist(0, 20);
    }

    // Convert the sorted list back into a map
    Map<DateTime, Verse> sortedMap = Map.fromEntries(sortedEntries);

    emit(state.copyWith(histories: sortedMap));
  }

  Future getContent(Verse? bible, {VerseMode mode = VerseMode.both}) async {
    final shouldSyncBottom = [VerseMode.both, VerseMode.bottomOnly].contains(
      mode,
    );
    if (shouldSyncBottom) {
      emit(state.copyWith(isSplitContentLoading: true));
    }
    if (shouldSyncBottom) {
      await getContent2(bible);
    }
    if (mode == VerseMode.bottomOnly) {
      if (shouldSyncBottom) {
        emit(state.copyWith(isSplitContentLoading: false));
      }
      return;
    }
    emit(state.copyWith(selectedVerse: []));
    if (bible == null) {
      emit(
        state.copyWith(
          prevBible: state.currentBible,
          currentBible: const Verse(
            id: 1001001,
            bookId: 1,
            chapterId: 1,
            verseId: 1,
          ),
        ),
      );
    } else {
      emit(state.copyWith(prevBible: state.currentBible, currentBible: bible));
    }
    int bibleId = state.currentBible!.id;
    // int verseId = state.currentBible!.verseId;
    Bcvbc bcvbc = Bcvbc.fromBibleId(bibleId);
    int bookId = state.currentBible!.bookId;
    int chapterId = state.currentBible!.chapterId;
    // String? title = await convertIDtoNameAlkitab(
    //   bibleId,
    //   null,
    //   bibleDb: bibleDb!,
    //   isLong: true,
    //   withVerse: false,
    // );

    // Parallelize all data fetches for better performance
    late List<Verse> bibleContent;
    late List<BibleBook> bookContent;
    late List<Pericope> pericopes;
    late List<PericopeParalel> pericopeParalels;
    late List<BibleRef> references;

    if (_usesAssetBible) {
      // Fetch all data in parallel when using asset Bible
      final results = await Future.wait([
        bibleAssetService.getVerses(
          state.currentBibleCode,
          bookId: bookId,
          chapterId: chapterId,
        ),
        bibleAssetService.getBooks(state.currentBibleCode),
        bibleAssetService.getPericopes(
          state.currentBibleCode,
          bookId: bookId,
          chapterId: chapterId,
        ),
        bibleAssetService.getPericopeParalels(
          state.currentBibleCode,
          bc: bcvbc.bc!,
        ),
        bibleAssetService.getRefs(state.currentBibleCode, bc: bcvbc.bc!),
      ]);
      bibleContent = results[0] as List<Verse>;
      bookContent = results[1] as List<BibleBook>;
      pericopes = results[2] as List<Pericope>;
      pericopeParalels = results[3] as List<PericopeParalel>;
      references = results[4] as List<BibleRef>;
    } else if (bibleDb != null) {
      // Fetch all data in parallel when using database
      final results = await Future.wait([
        bibleRepository.getVerses(
          bibleDb!,
          bookId: bookId,
          chapterId: chapterId,
        ),
        bibleRepository.getBooks(bibleDb!),
        bibleRepository.getPericope(
          bibleDb!,
          bookId: bookId,
          chapterId: chapterId,
        ),
        bibleRepository.getPericopeParalel(bibleDb!, bc: bcvbc.bc!),
        bibleRepository.getRef(bibleDb!, bc: bcvbc.bc!),
      ]);
      bibleContent = results[0] as List<Verse>;
      bookContent = results[1] as List<BibleBook>;
      pericopes = results[2] as List<Pericope>;
      pericopeParalels = results[3] as List<PericopeParalel>;
      references = results[4] as List<BibleRef>;
    } else {
      // Default to empty lists if no data source is available
      bibleContent = <Verse>[];
      bookContent = <BibleBook>[];
      pericopes = <Pericope>[];
      pericopeParalels = <PericopeParalel>[];
      references = <BibleRef>[];
    }
    var book = bookContent.firstWhereOrNull((element) => element.id == bookId);
    verseKeys = List.generate(
      bibleContent.length,
      (index) => GlobalKey<VerseWidgetState>(debugLabel: index.toString()),
    );
    emit(
      state.copyWith(
        books: bookContent,
        selectedFilterBooks: bookContent,
        currentBook: book,
        verses: bibleContent,
        references: references,
        pericopes: pericopes,
        pericopesParalels: pericopeParalels,
        lastOpenBible: DateTime.now(),
      ),
    );
    if (shouldSyncBottom) {
      emit(state.copyWith(isSplitContentLoading: false));
    }
  }

  Future getContent2(Verse? bible) async {
    try {
      emit(state.copyWith(selectedVerse: []));
      if (bible == null) {
        emit(
          state.copyWith(
            prevBibleSplit: state.currentBibleSplit,
            currentBibleSplit: const Verse(
              id: 1001001,
              bookId: 1,
              chapterId: 1,
              verseId: 1,
            ),
          ),
        );
      } else {
        emit(
          state.copyWith(
            prevBibleSplit: state.currentBibleSplit,
            currentBibleSplit: bible,
          ),
        );
      }
      int bibleId = state.currentBibleSplit!.id;
      // int verseId = state.currentBible!.verseId;
      Bcvbc bcvbc = Bcvbc.fromBibleId(bibleId);
      int bookId = state.currentBibleSplit!.bookId;
      int chapterId = state.currentBibleSplit!.chapterId;
      // String? title = await convertIDtoNameAlkitab(
      //   bibleId,
      //   null,
      //   bibleDb: bibleDb!,
      //   isLong: true,
      //   withVerse: false,
      // );

      final bibleContent = _usesSplitAssetBible
          ? await bibleAssetService.getVerses(
              state.splitBibleCode,
              bookId: bookId,
              chapterId: chapterId,
            )
          : splitBibleDb != null
          ? await bibleRepository.getVerses(
              splitBibleDb!,
              bookId: bookId,
              chapterId: chapterId,
            )
          : <Verse>[];
      final bookContent = _usesSplitAssetBible
          ? await bibleAssetService.getBooks(state.splitBibleCode)
          : splitBibleDb != null
          ? await bibleRepository.getBooks(splitBibleDb!)
          : <BibleBook>[];
      final pericopes = _usesSplitAssetBible
          ? await bibleAssetService.getPericopes(
              state.splitBibleCode,
              bookId: bookId,
              chapterId: chapterId,
            )
          : splitBibleDb != null
          ? await bibleRepository.getPericope(
              splitBibleDb!,
              bookId: bookId,
              chapterId: chapterId,
            )
          : <Pericope>[];
      final pericopeParalels = _usesSplitAssetBible
          ? await bibleAssetService.getPericopeParalels(
              state.splitBibleCode,
              bc: bcvbc.bc!,
            )
          : splitBibleDb != null
          ? await bibleRepository.getPericopeParalel(
              splitBibleDb!,
              bc: bcvbc.bc!,
            )
          : <PericopeParalel>[];
      final references = _usesSplitAssetBible
          ? await bibleAssetService.getRefs(state.splitBibleCode, bc: bcvbc.bc!)
          : splitBibleDb != null
          ? await bibleRepository.getRef(splitBibleDb!, bc: bcvbc.bc!)
          : <BibleRef>[];

      var book = bookContent.firstWhereOrNull(
        (element) => element.id == bookId,
      );

      verseKeys2 = List.generate(
        bibleContent.length,
        (index) => GlobalKey<VerseWidgetState>(debugLabel: index.toString()),
      );

      emit(
        state.copyWith(
          booksSplit: bookContent,
          currentBookSplit: book,
          versesSplit: bibleContent,
          referencesSplit: references,
          pericopesSplit: pericopes,
          pericopesParalelsSplit: pericopeParalels,
          lastOpenBible: DateTime.now(),
        ),
      );
    } catch (e, stackTrace) {
      log(
        'Error in getContent: $e',
        name: 'BibleCubit',
        stackTrace: stackTrace,
      );
    }
  }

  Future previousChapter(VerseMode mode) async {
    emit(state.copyWith(selectedVerse: []));
    int bookId = state.currentBible!.bookId;
    int chapterId = state.currentBible!.chapterId;
    if (chapterId == 1) {
      if (bookId == 1) {
        return;
      }
      bookId--;
      chapterId = state.books[bookId - 1].chapterCount!;
    } else {
      chapterId--;
    }
    int bibleId = bookId * 1000000 + chapterId * 1000 + 1;
    return await getContent(
      Verse(id: bibleId, bookId: bookId, chapterId: chapterId, verseId: 1),
      mode: mode,
    );
  }

  void previousVerse() {}

  void hightLightBible(List<Verse> bible) {
    List<Verse> temp = List.from(state.hightlightedVerse);
    var existsAndSelected = state.hightlightedVerse.where(
      (element) => state.selectedVerse.map((e) => e.id).contains(element.id),
    );
    for (var b in bible) {
      var exists = temp.any((element) => element.isSame(b));

      if (exists) {
        var index = temp.indexOf(
          temp.firstWhereOrNull((element) => element.isSame(b)) ?? b,
        );
        if (temp[index].color == b.color) {
          temp.removeAt(index);
        } else {
          if (!existsAndSelected.map((e) => e.color).contains(b.color)) {
            temp[index] = b;
          }
        }
      } else {
        if (!existsAndSelected.map((e) => e.color).contains(b.color)) {
          temp.add(b);
        }
      }
    }
    temp = temp.toSet().toList();
    emit(state.copyWith(hightlightedVerse: temp));
  }

  void selectBible(Verse bible) {
    List<Verse> temp = List.from(state.selectedVerse);
    if (temp.contains(bible)) {
      temp.remove(bible);
    } else {
      temp.add(bible);
    }
    temp = temp.toSet().toList();
    emit(state.copyWith(selectedVerse: temp));
  }

  void removeSelection() {
    emit(state.copyWith(selectedVerse: []));
  }

  Future nextChapter([
    int? step,
    bool fromTodayReading = false,
    VerseMode? mode,
  ]) async {
    if (step != null && step < 1) {
      return; // Exit the function if step is less than 1
    }

    step ??= 1; // If step is null, set it to the default value of 1

    emit(state.copyWith(selectedVerse: []));

    int bookId = state.currentBible!.bookId;
    int chapterId = state.currentBible!.chapterId;
    if (fromTodayReading) {
      bookId = state.todayReading!.bookId;
      chapterId = state.todayReading!.chapterId;
    }

    // Calculate the maximum chapterId based on the step
    int maxChapterId = state.currentBook!.chapterCount ?? 0;
    if (step > 0) {
      maxChapterId = math.min(maxChapterId, chapterId + step);
    } else if (step < 0) {
      maxChapterId = math.max(1, chapterId + step);
    }

    if (chapterId == maxChapterId) {
      if (bookId == state.books.length) {
        return;
      }
      // Redirect to next book
      bookId++;
      chapterId = 1;
    } else {
      chapterId += step;
    }

    int bibleId = bookId * 1000000 + chapterId * 1000 + 1;
    getContent(
      Verse(id: bibleId, bookId: bookId, chapterId: chapterId, verseId: 1),
      mode: mode ?? VerseMode.topOnly,
    );
  }

  Future<void> changeContent(Verse newBible) async {
    emit(state.copyWith(selectedVerse: []));
    // int bibleId = newBible.bookId * 1000000 + newBible.chapterId * 1000 + 1;
    getContent(newBible);
  }

  void changeFont(String font) {
    emit(state.copyWith(defaultFont: font, followGlobalFontSettings: false));
  }

  void changeTextScale(double value) {
    emit(state.copyWith(defaultTextScale: value, followGlobalFontSettings: false));
  }

  void changeTextHeight(double value) {
    emit(state.copyWith(defaultTextHeight: value, followGlobalFontSettings: false));
  }

  void toggleFollowGlobalFontSettings(bool value) {
    emit(state.copyWith(followGlobalFontSettings: value));
  }

  void syncFromGlobalFontSettings(String font, double scale, double height) {
    if (state.followGlobalFontSettings) {
      emit(state.copyWith(
        defaultFont: font,
        defaultTextScale: scale,
        defaultTextHeight: height,
      ));
    }
  }

  void saveNote(BibleNote data) {
    var notes = List<BibleNote>.from(state.notes);
    bool isNoteFound = false;

    for (int i = 0; i < notes.length; i++) {
      if (notes[i].id == data.id) {
        notes[i] = data; // Replace the note with the same id
        isNoteFound = true;
        break;
      }
    }

    if (!isNoteFound) {
      notes.add(data); // Add the note if it doesn't exist in the list
    }

    emit(state.copyWith(notes: notes));
  }

  void changeSortNote(String sortBy) {
    emit(state.copyWith(sortNotesBy: sortBy));
  }

  void deleteNote(BibleNote data) {
    var notes = List<BibleNote>.from(state.notes);
    notes.remove(data);

    emit(state.copyWith(notes: notes));
  }
}

Future<String?> convertIDtoNameAlkitab(
  int? id1,
  int? id2, {
  bool isLong = false,
  bool withVerse = true,
  required Database bibleDb,
}) async {
  String? query;
  String? zb1;
  String? zc1;
  String? zv1;
  String? zb2;
  String? zc2;
  String? zv2;
  String? zvt;
  int error = 0;
  int type = 0; //0 single,1 =book=chapter, 2 =book!chapter, 3 !book
  // Non-nullable local variable for id1 (initialized to 0, will be set if id1 is not null)
  int id1Val = 0;

  if (id1 != null) {
    id1Val = id1;
    query = 'select bs,bl from book where id = (?/1000000)';
    var data = await bibleDb.rawQuery(query, [id1]);
    zb1 = StringUtil.castToString(data.first['bs']);
    if (isLong) {
      zb1 = StringUtil.castToString(data.first['bl']);
    }
    String id1s = id1.toString();
    zc1 = id1s.substring(id1s.length - 6, id1s.length).substring(0, 3);
    zv1 = id1s.substring(id1s.length - 3, id1s.length);
  } else {
    error = 1;
  }

  if (id2 != null && error == 0) {
    // Use id1Val which is non-null when error == 0
    if (((id1Val / 1000000) - (id2 / 1000000)) <= 0) {
      // book validation
      String id2s = id2.toString();
      zc2 = id2s.substring(id2s.length - 6, id2s.length).substring(0, 3);
      zv2 = id2s.substring(id2s.length - 3, id2s.length);

      if (((id1Val / 1000000) - (id2 / 1000000)) < 0) {
        //second book
        query = 'select bs, bl from book where id = (?/1000000)';
        var data = await bibleDb.rawQuery(query, [id2]);
        zb2 = StringUtil.castToString(data.first['bs']);
        if (isLong) {
          zb2 = StringUtil.castToString(data.first['bl']);
        }
        type = 3;
      }
      if ((id1Val / 1000000).floor() - (id2 / 1000000).floor() == 0) {
        //same book
        if (int.parse(zc1!) - int.parse(zc2) <= 0) {
          // chapter validation
          if (zc1 != zc2) {
            type = 2; // 2 =book!chapter
          } else {
            type = 1; // 1 =book=chapter
          }
        } else {
          error = 1;
        }
      }
    } else {
      error = 1;
    }
  }
  if (error == 0) {
    zc1 = convertZeroNumber(zc1) ?? '';
    zc2 = convertZeroNumber(zc2) ?? '';
    zv1 = convertZeroNumber(zv1) ?? '';
    zv2 = convertZeroNumber(zv2) ?? '';
    if (withVerse) {
      if (type == 0) {
        zvt = '$zb1 $zc1:$zv1';
      } else if (type == 1) {
        zvt = '$zb1 $zc1:$zv1-$zv2';
      } else if (type == 2) {
        zvt = '$zb1 $zc1:$zv1-$zc2:$zv2';
      } else if (type == 3) {
        zvt = '$zb1 $zc1:$zv1-$zb2 $zc2:$zv2';
      }
    } else {
      if (type == 0) {
        zvt = '$zb1 $zc1';
      } else if (type == 1) {
        zvt = '$zb1 $zc1';
      } else if (type == 2) {
        zvt = '$zb1 $zc1-$zc2';
      } else if (type == 3) {
        zvt = '$zb1 $zc1-$zb2 $zc2';
      }
    }

    return zvt;
  } else {
    return null;
  }
}

Future<String?> convertIDsToNameAlkitab(
  List<int> verseIds, {
  bool isLong = false,
  bool withVerse = true,
  required Database bibleDb,
}) async {
  if (verseIds.isEmpty) {
    return '-';
  }

  verseIds.sort();

  final firstId = verseIds.first;

  // Cek panjang ID minimal 7 digit
  final s = firstId.toString();
  if (s.length < 7) {
    return '-';
  }

  // Ambil ID kitab
  final bookId = firstId ~/ 1000000;

  // Query
  final data = await bibleDb.rawQuery(
    'SELECT bs, bl FROM book WHERE id = ?', [bookId]
  );

  if (data.isEmpty) {
    // Tidak ada record
    return '-';
  }

  // Ambil nama kitab
  String bookName = isLong
      ? StringUtil.castToString(data.first['bl'])
      : StringUtil.castToString(data.first['bs']);

  // Ambil pasal
  String chapter = int.parse(
    s.substring(s.length - 6, s.length - 3),
  ).toString();

  // Konstruksi daftar ayat
  int? prevVerseNumber;
  List<int> tempVerseNumbers = [];
  List<List<int>> verseNumbers = [];

  for (var verseId in verseIds) {
    final ss = verseId.toString();
    // Jika format ID tidak valid, skip
    if (ss.length < 3) continue;

    int verseNumber = int.tryParse(ss.substring(ss.length - 3)) ?? 0;

    if (prevVerseNumber == null || prevVerseNumber + 1 == verseNumber) {
      tempVerseNumbers.add(verseNumber);
    } else {
      verseNumbers.add(List.from(tempVerseNumbers));
      tempVerseNumbers.clear();
      tempVerseNumbers.add(verseNumber);
    }

    prevVerseNumber = verseNumber;
  }

  if (tempVerseNumbers.isNotEmpty) {
    verseNumbers.add(List.from(tempVerseNumbers));
  }

  if (withVerse) {
    final parsedVerse = verseNumbers
        .map((e) => '${e.first}${e.last == e.first ? '' : '-${e.last}'}')
        .join(', ');

    return '$bookName $chapter:$parsedVerse';
  } else {
    return '$bookName $chapter';
  }
}

String? convertZeroNumber(String? number) {
  if (number != null) {
    if (number.isNotEmpty) {
      if (number.startsWith('0')) {
        number = number.replaceFirst('0', '');
        number = convertZeroNumber(number);
        return number;
      } else {
        return number;
      }
    } else {
      return number;
    }
  } else {
    return null;
  }
}

enum VerseMode { both, topOnly, bottomOnly }

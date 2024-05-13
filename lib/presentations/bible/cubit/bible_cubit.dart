import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
  final FlutterTts tts = FlutterTts();

  bool get isSelectingBible => state.selectedVerse.isNotEmpty;

  BibleRepository bibleRepository = di();

  Database? bibleDb;
  Database? splitBibleDb;
  initBible() async {
    await openDatabase(join(
            di<AppDirectory>().bibleFolder, '${state.currentBibleCode}.db'))
        .then((value) {
      bibleDb = value;
      splitBibleDb = bibleDb;
      // getBooks();
      getContent(state.currentBible);
    });
  }

  updateFilterBook(List<BibleBook> values) {
    emit(state.copyWith(selectedFilterBooks: values));
  }

  sync(BibleState bibleState) {
    emit(bibleState);
  }

  applyTtsSetting(Map<String, Map> voices, double pitch, double speed) {
    emit(state.copyWith(voices: voices, pitchRate: pitch, speedRate: speed));
    initTts();
  }

  onFilterPerjanjianLama() {
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

  onFilterCurrentBible() {
    if (state.selectedFilterBooks.length == 1 &&
        state.selectedFilterBooks.single == state.currentBook) {
      updateFilterBook([]);
    } else {
      updateFilterBook([state.currentBook!]);
    }
  }

  onFilterPerjanjianBaru() {
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
      (index) => GlobalKey<VerseWidgetState>(debugLabel: index.toString()));
  late List<GlobalKey<VerseWidgetState>> verseKeys2 = List.generate(
      state.verses.length,
      (index) => GlobalKey<VerseWidgetState>(debugLabel: index.toString()));

  modifyBookmark() {
    List<BibleBookmark> bookmarks = List.from(state.bookmarks);
    List<BibleBookmark> newValues = List.from(state.selectedVerse)
        .map((e) => BibleBookmark(
            createdAt: DateTime.now(), isBookmarkAll: false, verse: e))
        .toList();
    if (newValues.isEmpty) {
      newValues.add(BibleBookmark(
          createdAt: DateTime.now(),
          isBookmarkAll: true,
          verse: state.verses.first));
    }

    for (BibleBookmark item in newValues) {
      var savedItem = bookmarks.indexWhere((element) =>
          element.isBookmarkAll == item.isBookmarkAll &&
          element.verse.verseId == item.verse.verseId);
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
          ..sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          ),
      ),
    );
  }

  speakTheBible() async {
    emit(state.copyWith(isSpeaking: true));
    List<Verse> verses = [];

    if (state.selectedVerse.isNotEmpty) {
      verses = List.from(
          state.selectedVerse.sorted((a, b) => a.verseId.compareTo(b.verseId)));
    } else {
      verses = List.from(state.verses);
    }
    for (var verse in verses) {
      if (state.isSpeaking) {
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
        emit(state.copyWith(currentBible: verse));
        await Future.delayed(
          Duration(milliseconds: 600),
        );
        await tts.speak(sentence);
        emit(state.copyWith(currentStartWord: 0, currentEndWord: 0));
      }
    }
    emit(state.copyWith(isSpeaking: false));
  }

  stopSpeaking() async {
    await tts.stop();
    emit(state.copyWith(isSpeaking: false));
  }

  replaceBookmarks(List<BibleBookmark> items) {
    emit(state.copyWith(bookmarks: items));
  }

  Future<List<Verse>> searchBibleByString(String searchText) async {
    if (searchText.isEmpty) return [];
    final response = await bibleRepository.search(
        bibleDb!, searchText, state.selectedFilterBooks);
    return response;
  }

  toggleAudio() {
    emit(state.copyWith(enableAudio: !state.enableAudio));
  }

  initTts() async {
    await tts.awaitSpeakCompletion(true);
    await tts.awaitSynthCompletion(true);
    await tts.setSpeechRate(state.speedRate);
    await tts.setPitch(state.pitchRate);
    List<String> langs =
        ((await tts.getLanguages) as List<Object?>).cast<String>().toList();
    int? lang = langs.map((e) => e.split('-').first).toList().indexWhere(
        (element) => element == state.currentBibleLanguage.split('-').first);
    await tts.setLanguage(langs[lang]);
    // List<Map<String, String>> voices =
    //     ((await tts.getVoices) as List).cast<Map<String, String>>().toList();
    List<Map> voices = (await tts.getVoices as List<Object?>)
        .cast<Map>()
        .toList()
        .map((e) =>
            e.map((key, value) => MapEntry(key.toString(), value.toString())))
        .toList();
    var currentLang = state.currentBibleLanguage;
    Map<String, String>? voice =
        (voices.firstWhereOrNull((element) => element['locale'] == currentLang))
            ?.map((key, value) => MapEntry(key.toString(), value.toString()));
    if (voice != null) {
      var savedVoice = state.voices[currentLang];
      if (savedVoice == null) {
        var savedVoices = Map.from(state.voices);
        savedVoices[currentLang] = voice;
        emit(state.copyWith(voices: savedVoices.cast()));
      }
      await tts.setVoice(savedVoice?.cast() ?? voice);
    }
    await tts.setVolume(1);
    tts.setProgressHandler((text, start, end, word) {
      log('TTS Speaking \ntext: $text\nstart: $start\nend: $end\nword: $word\n',
          name: 'Speaking');
      var mustAdd = [
        'Alla',
        'alla',
        'Penta kosta',
        'Demi kian',
        'penta kosta',
        'demi kian'
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

      emit(state.copyWith(
          currentWord: word, currentStartWord: start, currentEndWord: end));
    });
  }

  incrementTodayReading() async {
    if (state.todayReading == null) return;
    DateTime now = DateTime.now();

    Duration difference = now.difference(state.lastOpenBible ?? DateTime.now());
    int days = difference.inDays;
    nextChapter(days, true).then((value) {
      setTodayReading(state.currentBible);
    });
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

  setTodayReading(Verse? bible) {
    emit(
      state.copyWith(
        todayReading: bible,
        lastOpenBible: DateTime.now(),
      ),
    );
    if (bible != null) changeContent(bible);
  }

  @override
  BibleState? fromJson(Map<String, dynamic> json) {
    return BibleState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(BibleState state) {
    return state.toJson();
  }

  getBibles() {
    var folder = Directory(di<AppDirectory>().bibleFolder);
    var files = folder.listSync();
    var bibles = files.map((e) => basename(e.path)).toList();
    bibles.removeWhere((element) => element.split('.').last != 'db');
    emit(state.copyWith(bibleCodes: bibles.toSet().toList()));
  }

  Future<List<Verse>> getVersesByBook(int bookId, int chapterId) async {
    final response = await bibleRepository.getVerses(bibleDb!,
        bookId: bookId, chapterId: chapterId);
    return response;
  }

  selectBibleCode(int index, [bool secondary = false]) async {
    var bibleCode = state.bibleCodes[index].split('.').first;

    /// close current bible
    if (secondary) {
      splitBibleDb = await openDatabase(
        join(di<AppDirectory>().bibleFolder, '$bibleCode.db'),
      );
      emit(
        state.copyWith(splitBibleCode: bibleCode),
      );
    } else {
      bibleDb = await openDatabase(
        join(di<AppDirectory>().bibleFolder, '$bibleCode.db'),
      );
      emit(
        state.copyWith(currentBibleCode: bibleCode),
      );
      initTts();
    }

    // getBooks();
    getContent(state.currentBible);
  }

  // getBooks() {
  //   bibleDb!.query('book').then((value) {
  //     List<BibleBook> books = value.map((e) => BibleBook.fromJson(e)).toList();
  //     emit(state.copyWith(books: books));
  //   });
  // }

  selectBook(BibleBook book) {
    emit(state.copyWith(currentBook: book));
  }

  Future<String> getBibleTitle(List<Verse?> verses,
      {bool withVerse = false, bool splitMode = false}) async {
    List<int> parsedVerses = [];
    for (var element in verses) {
      if (element != null) parsedVerses.add(element.id);
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
    final response = await bibleRepository.getVersesByIdRange(bibleDb!,
        fromId: start ?? 1, toId: end);
    return response;
  }

  saveToHistory(Verse verse) {
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
    if ([VerseMode.both, VerseMode.bottomOnly].contains(mode)) {
      getContent2(bible);
    }
    if (mode == VerseMode.bottomOnly) {
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

    List<Verse> bibleContent = await bibleRepository.getVerses(
      bibleDb!,
      bookId: bookId,
      chapterId: chapterId,
    );
    List<BibleBook> bookContent = await bibleRepository.getBooks(
      bibleDb!,
      // bookId: bookId,
    );
    List<Pericope> pericopes = await bibleRepository.getPericope(
      bibleDb!,
      bookId: bookId,
      chapterId: chapterId,
    );
    List<PericopeParalel> pericopeParalels =
        await bibleRepository.getPericopeParalel(
      bibleDb!,
      bc: bcvbc.bc!,
    );
    List<BibleRef> references =
        await bibleRepository.getRef(bibleDb!, bc: bcvbc.bc!);
    var book = bookContent.firstWhereOrNull((element) => element.id == bookId);
    verseKeys = List.generate(bibleContent.length,
        (index) => GlobalKey<VerseWidgetState>(debugLabel: index.toString()));
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
        emit(state.copyWith(
            prevBibleSplit: state.currentBibleSplit, currentBibleSplit: bible));
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

      List<Verse> bibleContent = await bibleRepository.getVerses(
        splitBibleDb!,
        bookId: bookId,
        chapterId: chapterId,
      );
      List<BibleBook> bookContent = await bibleRepository.getBooks(
        splitBibleDb!,
        // bookId: bookId,
      );
      List<Pericope> pericopes = await bibleRepository.getPericope(
        splitBibleDb!,
        bookId: bookId,
        chapterId: chapterId,
      );
      List<PericopeParalel> pericopeParalels =
          await bibleRepository.getPericopeParalel(
        splitBibleDb!,
        bc: bcvbc.bc!,
      );

      List<BibleRef> references =
          await bibleRepository.getRef(splitBibleDb!, bc: bcvbc.bc!);

      var book =
          bookContent.firstWhereOrNull((element) => element.id == bookId);

      verseKeys2 = List.generate(bibleContent.length,
          (index) => GlobalKey<VerseWidgetState>(debugLabel: index.toString()));

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
    } catch (e) {
      log('test');
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
      Verse(
        id: bibleId,
        bookId: bookId,
        chapterId: chapterId,
        verseId: 1,
      ),
      mode: mode,
    );
  }

  previousVerse() {}

  hightLightBible(List<Verse> bible) {
    List<Verse> temp = List.from(state.hightlightedVerse);
    var existsAndSelected = state.hightlightedVerse.where(
        (element) => state.selectedVerse.map((e) => e.id).contains(element.id));
    for (var b in bible) {
      var exists = temp.any((element) => element.isSame(b));

      if (exists) {
        var index = temp.indexOf(
            temp.firstWhereOrNull((element) => element.isSame(b)) ?? b);
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

  selectBible(Verse bible) {
    List<Verse> temp = List.from(state.selectedVerse);
    if (temp.contains(bible)) {
      temp.remove(bible);
    } else {
      temp.add(bible);
    }
    temp = temp.toSet().toList();
    emit(state.copyWith(selectedVerse: temp));
  }

  removeSelection() {
    emit(state.copyWith(selectedVerse: []));
  }

  Future nextChapter(
      [int? step, bool fromTodayReading = false, VerseMode? mode]) async {
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
      Verse(
        id: bibleId,
        bookId: bookId,
        chapterId: chapterId,
        verseId: 1,
      ),
      mode: mode ?? VerseMode.topOnly,
    );
  }

  changeContent(Verse newBible) async {
    emit(state.copyWith(selectedVerse: []));
    // int bibleId = newBible.bookId * 1000000 + newBible.chapterId * 1000 + 1;
    getContent(newBible);
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

  saveNote(BibleNote data) {
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

  changeSortNote(String sortBy) {
    emit(state.copyWith(sortNotesBy: sortBy));
  }

  deleteNote(BibleNote data) {
    var notes = List<BibleNote>.from(state.notes);
    notes.remove(data);

    emit(state.copyWith(notes: notes));
  }
}

Future<String?> convertIDtoNameAlkitab(int? id1, int? id2,
    {bool isLong = false,
    bool withVerse = true,
    required Database bibleDb}) async {
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

  if (id1 != null) {
    query = 'select bs,bl from book where id = ($id1/1000000)';
    var data = await bibleDb.rawQuery(query);
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
    if (((id1! / 1000000) - (id2 / 1000000)) <= 0) {
      // book validation
      String id2s = id2.toString();
      zc2 = id2s.substring(id2s.length - 6, id2s.length).substring(0, 3);
      zv2 = id2s.substring(id2s.length - 3, id2s.length);

      if (((id1 / 1000000) - (id2 / 1000000)) < 0) {
        //second book
        query = 'select bs, bl from book where id = ($id2/1000000)';
        var data = await bibleDb.rawQuery(query);
        zb2 = StringUtil.castToString(data.first['bs']);
        if (isLong) {
          zb2 = StringUtil.castToString(data.first['bl']);
        }
        type = 3;
      }
      if ((id1 / 1000000).floor() - (id2 / 1000000).floor() == 0) {
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

Future<String?> convertIDsToNameAlkitab(List<int> verseIds,
    {bool isLong = false,
    bool withVerse = true,
    required Database bibleDb}) async {
  String bookName = '-';
  String chapter = '-';

  verseIds.sort();

  String query =
      'select bs,bl from book where id = (${verseIds.first}/1000000)';
  var data = await bibleDb.rawQuery(query);
  bookName = StringUtil.castToString(data.first['bs']);
  if (isLong) {
    bookName = StringUtil.castToString(data.first['bl']);
  }
  chapter = verseIds.first.toString();
  chapter = int.parse(chapter.substring(chapter.length - 6, chapter.length - 3))
      .toString();
  int? prevVerseNumber;
  List<int> tempVerseNumbers = [];
  List<List<int>> verseNumbers = [];
  for (var verseId in verseIds) {
    int verseNumber = int.tryParse(verseId.toString().substring(
            verseId.toString().length - 3, verseId.toString().length)) ??
        0;
    if (prevVerseNumber == null) {
      tempVerseNumbers.add(verseNumber);
    } else {
      if (prevVerseNumber + 1 == verseNumber) {
        /// if the verseNumber not jumped;
        tempVerseNumbers.add(verseNumber);
      } else {
        /// if jumped
        verseNumbers.add(List.from(tempVerseNumbers));
        tempVerseNumbers.clear();
        tempVerseNumbers.add(verseNumber);
      }
    }
    prevVerseNumber = verseNumber;
  }
  if (tempVerseNumbers.isNotEmpty) {
    verseNumbers.add(List.from(tempVerseNumbers));
  }
  if (withVerse) {
    String parsedVerse = verseNumbers
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

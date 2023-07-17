import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../data/utilities/string_utils.dart';
import '../../../di/injection.dart';
import '../../../domain/entity/bcvbc/bcvbc.dart';
import '../../../domain/entity/bible_book/bible_book.dart';
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
    log('Initialized BibleCubit');
    incrementTodayReading();
  }

  bool get isSelectingBible => state.selectedVerse.isNotEmpty;

  BibleRepository bibleRepository = di();

  Database? bibleDb;
  Database? splitBibleDb;
  initBible() async {
    if (state.currentBibleCode == null) return;
    await openDatabase(join(
            di<AppDirectory>().bibleFolder, '${state.currentBibleCode}.db'))
        .then((value) {
      bibleDb = value;
      // getBooks();
      getContent(state.currentBible);
    });
  }

  late List<GlobalKey<VerseWidgetState>> verseKeys = List.generate(
      state.verses.length,
      (index) => GlobalKey<VerseWidgetState>(debugLabel: index.toString()));
  late List<GlobalKey<VerseWidgetState>> verseKeys2 = List.generate(
      state.verses.length, (index) => GlobalKey<VerseWidgetState>());

  modifyBookmark(Verse item) {
    List<Verse> bookmarks = (List.from(state.bookmarks));
    if (bookmarks.contains(item)) {
      bookmarks.remove(item);
    } else {
      bookmarks.add(item);
    }
    if (bookmarks.length > 20) {
      bookmarks = bookmarks.sublist(1);
    }
    emit(state.copyWith(bookmarks: bookmarks));
  }

  replaceBookmarks(List<Verse> items) {
    emit(state.copyWith(bookmarks: items));
  }

  Future<List<Verse>> searchBibleByString(String searchText) async {
    if (searchText.isEmpty) return [];
    final response = await bibleRepository.search(bibleDb!, searchText);
    return response;
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
    if (map.length >= 20) {
      map = Map.fromIterable(List.from(map.entries).sublist(1, 21));
    }
    map[DateTime.now()] = verse;
    emit(state.copyWith(histories: map));
  }

  Future getContent(Verse? bible) async {
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

    List<Verse> splitBibleContent = [];
    List<BibleBook> splitBookContent = [];
    List<Pericope> splitPericopes = [];
    List<PericopeParalel> splitPericopeParalels = [];
    if (splitBibleDb != null) {
      splitBibleContent = await bibleRepository.getVerses(
        splitBibleDb!,
        bookId: bookId,
        chapterId: chapterId,
      );
      splitBookContent = await bibleRepository.getBooks(
        splitBibleDb!,
        // bookId: bookId,
      );
      splitPericopes = await bibleRepository.getPericope(
        splitBibleDb!,
        bookId: bookId,
        chapterId: chapterId,
      );
      splitPericopeParalels = await bibleRepository.getPericopeParalel(
        splitBibleDb!,
        bc: bcvbc.bc!,
      );
    }
    var book = bookContent.firstWhereOrNull((element) => element.id == bookId);
    var book2 =
        splitBookContent.firstWhereOrNull((element) => element.id == bookId);

    verseKeys = List.generate(bibleContent.length,
        (index) => GlobalKey<VerseWidgetState>(debugLabel: index.toString()));
    verseKeys2 = List.generate(
        bibleContent.length, (index) => GlobalKey<VerseWidgetState>());

    emit(
      state.copyWith(
        books: bookContent,
        currentBook: book,
        splitBook: book2,
        verses: bibleContent,
        references: references,
        splitVerses: splitBibleContent,
        pericopes: pericopes,
        splitPericopes: splitPericopes,
        pericopesParalels: pericopeParalels,
        splitPericopesParalels: splitPericopeParalels,
        lastOpenBible: DateTime.now(),
      ),
    );
  }

  Future previousChapter() async {
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
    return await getContent(Verse(
      id: bibleId,
      bookId: bookId,
      chapterId: chapterId,
      verseId: 1,
    ));
  }

  previousVerse() {}

  hightLightBible(List<Verse> bible) {
    List<Verse> temp = List.from(state.hightlightedVerse);
    for (var b in bible) {
      var exists = temp.any((element) => element.isSame(b));

      if (exists) {
        var index = temp.indexOf(
            temp.firstWhereOrNull((element) => element.isSame(b)) ?? b);
        if (temp[index].color == b.color) {
          temp.removeAt(index);
        }
      } else {
        temp.add(b);
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

  Future nextChapter([int? step, bool fromTodayReading = false]) async {
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
    notes.add(data);

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

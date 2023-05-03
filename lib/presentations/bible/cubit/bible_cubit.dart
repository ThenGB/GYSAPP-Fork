import 'dart:developer';
import 'dart:io';

import 'package:church/di/injection.dart';
import 'package:church/domain/entity/bcvbc/bcvbc.dart';
import 'package:church/domain/entity/bible/bible.dart';
import 'package:church/domain/entity/pericope/pericope.dart';
import 'package:church/domain/entity/pericope_paralel/pericope_paralel.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../data/utilities/string_utils.dart';
import '../../../domain/entity/bible_book/bible_book.dart';
import '../../../domain/repository/bible_repository/bible_repository.dart';
import 'bible_state.dart';

export 'bible_state.dart';

class BibleCubit extends HydratedCubit<BibleState> {
  BibleCubit() : super(const BibleState()) {
    initBible();
    log('Initialized BibleCubit');
  }

  BibleRepository bibleRepository = di();

  Database? bibleDb;
  initBible() async {
    if (state.currentBibleCode == null) return;
    await openDatabase(join(
            di<AppDirectory>().bibleFolder, '${state.currentBibleCode}.db'))
        .then((value) {
      bibleDb = value;
      getBooks();
      getContent(state.currentBible);
    });
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
    emit(state.copyWith(bibleCodes: bibles));
  }

  selectBibleCode(int index) async {
    var bibleCode = state.bibleCodes[index].split('.').first;

    /// close current bible
    bibleDb = await openDatabase(
      join(di<AppDirectory>().bibleFolder, '$bibleCode.db'),
    );
    emit(
      state.copyWith(currentBibleCode: bibleCode),
    );
    getBooks();
    getContent(state.currentBible);
  }

  getBooks() {
    bibleDb!.query('book').then((value) {
      List<BibleBook> books = value.map((e) => BibleBook.fromJson(e)).toList();
      emit(state.copyWith(books: books));
    });
  }

  selectBook(BibleBook book) {
    emit(state.copyWith(currentBook: book));
  }

  getContent(Bible? bible) async {
    if (bible == null) {
      emit(state.copyWith(
          currentBible: const Bible(
        id: 1001001,
        bookId: 1,
        chapterId: 1,
        verseId: 1,
      )));
    } else {
      emit(state.copyWith(currentBible: bible));
    }
    int bibleId = state.currentBible!.id;
    int verseId = state.currentBible!.verseId;
    Bcvbc bcvbc = Bcvbc.fromBibleId(bibleId);
    int bookId = state.currentBible!.bookId;
    int chapterId = state.currentBible!.chapterId;
    String? title = await convertIDtoNameAlkitab(
      bibleId,
      null,
      bibleDb: bibleDb!,
      isLong: true,
      withVerse: false,
    );
    List<Bible> bibleContent = await bibleRepository.getBible(
      bibleDb!,
      bookId: bookId,
      chapterId: chapterId,
    );
    List<BibleBook> bookContent = await bibleRepository.getBooks(
      bibleDb!,
      bookId: bookId,
    );
    var book = bookContent.firstWhereOrNull((element) => element.id == bookId);
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
    emit(
      state.copyWith(
        books: bookContent,
        bibles: bibleContent,
        currentBook: book,
        pericopes: pericopes,
        pericopesParalels: pericopeParalels,
        bookTitle: title,
      ),
    );
  }

  previousChapter() async {
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
    getContent(Bible(
      id: bibleId,
      bookId: bookId,
      chapterId: chapterId,
      verseId: 1,
    ));
  }

  hightLightBible(List<Bible> bible) {
    List<Bible> temp = List.from(state.hightlightedVerse);
    for (var b in bible) {
      var exists = temp.any((element) => element.isSame(b));
      if (exists) {
        var index = temp.indexOf(
            temp.firstWhereOrNull((element) => element.isSame(b)) ?? b);
        if (b.color == Colors.transparent || b.color == null) {
          temp.removeAt(index);
        } else {
          temp.removeAt(index);
          temp.add(b);
        }
      } else {
        temp.add(b);
      }
    }
    temp = temp.toSet().toList();
    emit(state.copyWith(hightlightedVerse: temp, selectedVerse: []));
  }

  selectBible(Bible bible) {
    List<Bible> temp = List.from(state.selectedVerse);
    if (temp.contains(bible)) {
      temp.remove(bible);
    } else {
      temp.add(bible);
    }
    temp = temp.toSet().toList();
    emit(state.copyWith(selectedVerse: temp));
  }

  nextChapter() async {
    emit(state.copyWith(selectedVerse: []));
    int bookId = state.currentBible!.bookId;
    int chapterId = state.currentBible!.chapterId;
    if (chapterId == state.currentBook!.chapterCount) {
      if (bookId == state.books.length) {
        /// redirect to next book

        return;
      }
      bookId++;
      chapterId = 1;
    } else {
      chapterId++;
    }
    int bibleId = bookId * 1000000 + chapterId * 1000 + 1;
    getContent(
      Bible(
        id: bibleId,
        bookId: bookId,
        chapterId: chapterId,
        verseId: 1,
      ),
    );
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
    query = "select bs,bl from book where id = ($id1/1000000)";
    var data = await bibleDb.rawQuery(query);
    zb1 = StringUtil.castToString(data.first["bs"]);
    if (isLong) {
      zb1 = StringUtil.castToString(data.first["bl"]);
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
        query = "select bs, bl from book where id = ($id2/1000000)";
        var data = await bibleDb.rawQuery(query);
        zb2 = StringUtil.castToString(data.first["bs"]);
        if (isLong) {
          zb2 = StringUtil.castToString(data.first["bl"]);
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
        zvt = "$zb1 $zc1:$zv1";
      } else if (type == 1) {
        zvt = "$zb1 $zc1:$zv1-$zv2";
      } else if (type == 2) {
        zvt = "$zb1 $zc1:$zv1-$zc2:$zv2";
      } else if (type == 3) {
        zvt = "$zb1 $zc1:$zv1-$zb2 $zc2:$zv2";
      }
    } else {
      if (type == 0) {
        zvt = "$zb1 $zc1";
      } else if (type == 1) {
        zvt = "$zb1 $zc1";
      } else if (type == 2) {
        zvt = "$zb1 $zc1-$zc2";
      } else if (type == 3) {
        zvt = "$zb1 $zc1-$zb2 $zc2";
      }
    }

    return zvt;
  } else {
    return null;
  }
}

String? convertZeroNumber(String? number) {
  if (number != null) {
    if (number.isNotEmpty) {
      if (number.startsWith("0")) {
        number = number.replaceFirst("0", "");
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

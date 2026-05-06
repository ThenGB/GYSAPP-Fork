import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../data/utilities/firebase_storage_helper.dart';
import '../../../data/utilities/platform_utils.dart';
import '../../../domain/entity/faith_note/faith_note.dart';
import 'faith_state.dart';

export 'faith_state.dart';

class FaithCubit extends HydratedCubit<FaithState> {
  FaithCubit() : super(FaithState());

  bool get isSelectingFaith => state.selectedFaith.isNotEmpty;

  @override
  FaithState? fromJson(Map<String, dynamic> json) {
    return FaithState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(FaithState state) {
    return state.copyWith(selectedFaith: []).toJson();
  }

  void changeFont(String font) {
    emit(state.copyWith(defaultFont: font));
  }

  void sync(FaithState faithState) {
    emit(faithState);
  }

  void changeTextScale(double value) {
    emit(state.copyWith(defaultTextScale: value));
  }

  void changeTextHeight(double value) {
    emit(state.copyWith(defaultTextHeight: value));
  }

  void setLanguage(Locale locale) {
    emit(state.copyWith(language: locale.languageCode));
  }

  void removeSelection() {
    emit(state.copyWith(selectedFaith: []));
  }

  void saveNote(FaithNote data) {
    var notes = List<FaithNote>.from(state.notes);
    int index = notes.indexWhere((note) => note.id == data.id);

    if (index != -1) {
      notes[index] = data; // Replace the note with the same id
    } else {
      notes.add(data); // Add the note if it doesn't exist in the list
    }

    emit(state.copyWith(notes: notes));
  }

  void changeSortNote(String sortBy) {
    emit(state.copyWith(sortNotesBy: sortBy));
  }

  void deleteNote(FaithNote data) {
    var notes = List<FaithNote>.from(state.notes);
    notes.remove(data);

    emit(state.copyWith(notes: notes));
  }

  void selectVerse(int index) {
    List<int> temp = List.from(state.selectedFaith);
    if (temp.contains(index)) {
      temp.remove(index);
    } else {
      temp.add(index);
    }
    temp = temp.toSet().toList();
    emit(state.copyWith(selectedFaith: temp));
  }

// Create a cache manager specifically for PDF names
  final pdfNameCacheManager = CacheManager(
    Config(
      'pdfNameCache',
      stalePeriod: const Duration(days: 1),
      maxNrOfCacheObjects: 100, // Maximum number of objects in the cache
      repo: JsonCacheInfoRepository(databaseName: 'pdfNameCache.db'),
      fileService: HttpFileService(),
    ),
  );

  void putPdfState(int index, {bool isLoading = true}) {
    Set<int> loadingList = Set.from(state.pdfLoadingList);
    if (isLoading) {
      loadingList.add(index);
    } else {
      loadingList.remove(index);
    }
    emit(state.copyWith(pdfLoadingList: loadingList));
  }

  Future<String?> getPdfName(int index) async {
    try {
      // Try to get the data from the cache
      final cacheData =
          await pdfNameCacheManager.getFileFromCache('cached_pdf_names');
      if (cacheData != null) {
        final List<String> cachedList = List<String>.from(
            jsonDecode(utf8.decode(cacheData.file.readAsBytesSync())));
        final pdfName = _findPdfName(cachedList, index);
        if (pdfName != null) {
          return pdfName; // Cache hit - PDF name found in cache
        }
      }

      if (!isFirebaseStorageConfiguredForCurrentPlatform) {
        return null;
      }

      if (FirebaseStorageHelper.isQuotaExceeded) {
        return null;
      }

      // If not in cache or cache is outdated, fetch from Firebase
      try {
        final storage = FirebaseStorage.instance;
        final folderRef = storage.ref('10dasar');
        final list = await folderRef.listAll();
        FirebaseStorageHelper.resetQuotaState();
        await cachePdfNameList(list.items.map((e) => e.name).toList());
        return _findPdfName(list.items.map((e) => e.name).toList(), index);
      } on FirebaseException catch (e) {
        FirebaseStorageHelper.handleError(e);
        final names = await _getPdfNamesFromRest();
        await cachePdfNameList(names);
        return _findPdfName(names, index);
      } catch (_) {
        final names = await _getPdfNamesFromRest();
        await cachePdfNameList(names);
        return _findPdfName(names, index);
      }
    } catch (e) {
      // Handle any errors here
      return null;
    }
  }

  String? _findPdfName(List<String> list, int index) {
    final remoteFile = list.firstWhereOrNull(
        (element) => (int.tryParse(element.split('-').first) ?? -1) == index);
    return remoteFile;
  }

// Cache the PDF name list
  Future<void> cachePdfNameList(List<String> list) async {
    final dataToCache = Uint8List.fromList(jsonEncode(list).codeUnits);
    await pdfNameCacheManager.putFile('cached_pdf_names', dataToCache);
  }

  Stream<FileResponse> getPdf(int index) async* {
    if (!isFirebaseStorageConfiguredForCurrentPlatform) {
      yield* Stream.empty();
      return;
    }
    if (FirebaseStorageHelper.isQuotaExceeded) {
      yield* Stream.empty();
      return;
    }
    String? url;
    try {
      final storage = FirebaseStorage.instance;
      final folderRef = storage.ref('10dasar');
      final list = await folderRef.listAll();
      FirebaseStorageHelper.resetQuotaState();
      final remoteFile = list.items.firstWhereOrNull((element) =>
          (int.tryParse(element.name.split('-').first) ?? -1) == index);
      url = await remoteFile?.getDownloadURL();
    } on FirebaseException catch (e) {
      FirebaseStorageHelper.handleError(e);
      final names = await _getPdfNamesFromRest();
      final name = _findPdfName(names, index);
      url =
          name == null ? null : FirebaseStorageHelper.restMediaUrl('10dasar/$name');
    } catch (_) {
      final names = await _getPdfNamesFromRest();
      final name = _findPdfName(names, index);
      url =
          name == null ? null : FirebaseStorageHelper.restMediaUrl('10dasar/$name');
    }
    if (url == null) {
      yield* Stream.empty();
      return;
    }
    yield* DefaultCacheManager().getFileStream(url, withProgress: true);
  }

  Future<List<String>> _getPdfNamesFromRest() async {
    final response = await http.get(Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/hatiku-4c1de.appspot.com/o?prefix=10dasar%2F',
    ));
    if (response.statusCode != 200) return [];
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (decoded['items'] as List<dynamic>? ?? []);
    return items
        .map((item) => (item as Map<String, dynamic>)['name'] as String? ?? '')
        .where((name) => name.startsWith('10dasar/'))
        .map((name) => name.replaceFirst('10dasar/', ''))
        .where((name) => name.isNotEmpty)
        .toList();
  }
}

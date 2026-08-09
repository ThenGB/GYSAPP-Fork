import 'dart:io';
import 'dart:typed_data';

import 'package:church/data/services/asset_distribution/installed_asset_registry.dart';
import 'package:church/data/services/asset_distribution/installed_asset_store.dart';
import 'package:church/data/services/local_bible_asset_service.dart';
import 'package:church/domain/entity/bible/bible_book_entity.dart';
import 'package:church/domain/entity/bible/bible_verse_entity.dart';
import 'package:church/domain/repository/bible_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class _FakeBibleRepository implements BibleRepository {
  @override
  Future<Either<dynamic, List<BibleBook>>> getBooks(String version) async =>
      const Right([]);

  @override
  Future<Either<dynamic, List<BibleVerse>>> getVerses(
    String version, {
    required int bookId,
    required int chapterId,
  }) async => const Right([]);

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemStorage implements Storage {
  final Map<String, dynamic> _data = {};
  @override
  Future<void> clear() async => _data.clear();
  @override
  Future<void> close() async {}
  @override
  Future<void> delete(String key) async => _data.remove(key);
  @override
  dynamic read(String key) => _data[key];
  @override
  Future<void> write(String key, dynamic value) async => _data[key] = value;
}

class _EmptyStore implements InstalledAssetStore {
  @override
  Future<List<String>> listFiles(String directory) async => [];
  @override
  Future<Uint8List?> readFile(String relativePath) async => null;
  @override
  Future<void> writeFile(String relativePath, Uint8List bytes) async {}
  @override
  Future<void> deleteFile(String relativePath) async {}
  @override
  Future<bool> exists(String relativePath) async => false;
  @override
  Future<void> clear() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = _MemStorage();
  final di = GetIt.instance;

  setUp(() {
    di.registerSingleton<BibleRepository>(_FakeBibleRepository());
    di.registerSingleton<LocalBibleAssetService>(LocalBibleAssetService());
    di.registerSingleton<InstalledAssetRegistry>(
      InstalledAssetRegistry(
        supportDirectory: Directory(Directory.systemTemp.path),
        store: _EmptyStore(),
      ),
    );
  });

  tearDown(() async {
    await di.reset();
  });

  testWidgets('Bible asset service loads the bundled TB bible', (tester) async {
    final svc = di<LocalBibleAssetService>();

    Future<T> timed<T>(String name, Future<T> Function() fn) async {
      final sw = Stopwatch()..start();
      try {
        final result = await fn();
        debugPrint('OK   $name (${sw.elapsedMilliseconds}ms)');
        return result;
      } catch (error) {
        debugPrint('FAIL $name (${sw.elapsedMilliseconds}ms): $error');
        rethrow;
      }
    }

    final books = await timed('getBooks', () => svc.getBooks('b_tb'));
    debugPrint('books loaded: ${books.length}');
    final verses = await timed(
      'getVerses',
      () => svc.getVerses('b_tb', bookId: 1, chapterId: 1),
    );
    debugPrint('verses loaded: ${verses.length}');

    expect(verses, isNotEmpty, reason: 'verses should load from asset');
    expect(books, isNotEmpty, reason: 'books should load from asset');
  });
}

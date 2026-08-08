import 'package:church/presentations/bible/cubit/bible_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common/sqlite_api.dart' show Database;

/// Regression tests for the split-pane "follow main" decision in
/// BibleCubit.selectBibleCodeByName. The decision is extracted into a pure
/// static helper so it can be tested without constructing the full cubit
/// (which needs DI, FlutterTts and initBible).
void main() {
  late Database mainDb;
  late Database splitDb;
  late Database otherDb;

  setUpAll(() {
    mainDb = _MockDatabase();
    splitDb = _MockDatabase();
    otherDb = _MockDatabase();
  });

  group('splitShouldFollowMain', () {
    test('shared main handle -> follows', () {
      expect(
        BibleCubit.splitShouldFollowMain(
          splitBibleDb: splitDb,
          previousBibleDb: splitDb,
          splitBibleCode: 'b_kjv',
          currentBibleCode: 'b_kjv',
        ),
        isTrue,
      );
    });

    test('independent split handle (different DB) -> untouched', () {
      expect(
        BibleCubit.splitShouldFollowMain(
          splitBibleDb: otherDb,
          previousBibleDb: mainDb,
          splitBibleCode: 'b_cuv',
          currentBibleCode: 'b_kjv',
        ),
        isFalse,
      );
    });

    test('both bundled with the SAME code -> follows', () {
      expect(
        BibleCubit.splitShouldFollowMain(
          splitBibleDb: null,
          previousBibleDb: null,
          splitBibleCode: 'b_tb',
          currentBibleCode: 'b_tb',
        ),
        isTrue,
      );
    });

    test('independent bundled split (different codes) -> untouched', () {
      // Regression for the null-guard: both handles null must NOT be
      // treated as "shared" when the codes differ (main=A, split=B bundled).
      expect(
        BibleCubit.splitShouldFollowMain(
          splitBibleDb: null,
          previousBibleDb: null,
          splitBibleCode: 'b_cuv',
          currentBibleCode: 'b_tb',
        ),
        isFalse,
      );
    });

    test('independent bundled split while main uses a DB -> untouched', () {
      expect(
        BibleCubit.splitShouldFollowMain(
          splitBibleDb: null,
          previousBibleDb: mainDb,
          splitBibleCode: 'b_tb',
          currentBibleCode: 'b_kjv',
        ),
        isFalse,
      );
    });
  });
}

class _MockDatabase extends Mock implements Database {}

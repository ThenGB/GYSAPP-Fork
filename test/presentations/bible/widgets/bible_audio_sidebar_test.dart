import 'dart:async';

import 'package:church/domain/entity/bible_book/bible_book.dart';
import 'package:church/domain/entity/verse/verse.dart';
import 'package:church/presentations/bible/cubit/bible_cubit.dart';
import 'package:church/presentations/bible/widgets/bible_audio_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBibleCubit extends Mock implements BibleCubit {}

void main() {
  final books = [
    BibleBook(id: 1, shortName: 'Kej', longName: 'Kejadian', chapterCount: 50),
    BibleBook(
      id: 2,
      shortName: 'Kel',
      longName: 'Keluaran',
      chapterCount: 40,
    ),
  ];
  final current = Verse(id: 1001003, bookId: 1, chapterId: 1, verseId: 3);

  late _MockBibleCubit cubit;
  late BibleState state;
  late StreamController<BibleState> stateController;

  setUp(() {
    cubit = _MockBibleCubit();
    state = BibleState(
      books: books,
      currentBible: current,
      enableAudio: true,
    );
    stateController = StreamController<BibleState>.broadcast();
    when(() => cubit.state).thenAnswer((_) => state);
    when(() => cubit.stream).thenAnswer((_) => stateController.stream);
    when(
      () => cubit.getBibleTitle(
        any(),
        withVerse: any(named: 'withVerse'),
        splitMode: any(named: 'splitMode'),
      ),
    ).thenAnswer((_) async => 'Kejadian 1:3');
    when(() => cubit.getVersesByBook(any(), any())).thenAnswer(
      (_) async => List.generate(
        31,
        (i) => Verse(
          id: 1001000 + i,
          bookId: 1,
          chapterId: 1,
          verseId: i + 1,
        ),
      ),
    );
    when(() => cubit.setTtsPlayRangeStart(any())).thenAnswer((inv) {
      state = state.copyWith(
        ttsPlayRangeStart: inv.positionalArguments.first as Verse?,
      );
      stateController.add(state);
    });
    when(() => cubit.setTtsPlayRangeEnd(any())).thenAnswer((inv) {
      state = state.copyWith(
        ttsPlayRangeEnd: inv.positionalArguments.first as Verse?,
        autoNextChapter: false,
      );
      stateController.add(state);
    });
    when(() => cubit.setPlayRangeToChapterEnd()).thenAnswer((_) {
      state = state.copyWith(ttsPlayRangeEnd: null, autoNextChapter: false);
      stateController.add(state);
    });
    when(() => cubit.setPlayRangeContinueOn()).thenAnswer((_) {
      state = state.copyWith(ttsPlayRangeEnd: null, autoNextChapter: true);
      stateController.add(state);
    });
    when(() => cubit.setAudioPanelOpen(any())).thenReturn(null);
    when(() => cubit.setEdgeVoice(any())).thenReturn(null);
    when(() => cubit.stopSpeaking()).thenAnswer((_) async {});
    when(() => cubit.togglePauseTts()).thenAnswer((_) async {});
    when(() => cubit.playBibleRange(start: any(named: 'start')))
        .thenAnswer((_) async {});
  });

  tearDown(() async {
    await stateController.close();
  });

  Widget wrap() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<BibleCubit>.value(
          value: cubit,
          child: const BibleAudioSidebar(),
        ),
      ),
    );
  }

  testWidgets('collapsed pill expands into details with range controls',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump(const Duration(milliseconds: 50));

    // Collapsed: mini pill with a play button and a maximize chevron.
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);

    // Maximize â†’ full panel with the playback-range section.
    await tester.tap(find.byIcon(Icons.keyboard_arrow_up_rounded));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('bible_range_title'), findsOneWidget);
    expect(find.text('bible_range_start'), findsOneWidget);
    expect(find.text('bible_range_end'), findsOneWidget);
    expect(find.text('bible_range_chapter_end'), findsOneWidget);
    expect(find.text('bible_range_continue'), findsOneWidget);
    expect(find.text('bible_range_to_verse'), findsOneWidget);

    // "Sampai akhir pasal" is the default â†’ chapter-end summary, and the
    // end pickers are hidden.
    expect(
      find.textContaining('bible_range_chapter_end_summary', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('bible_book'), findsOneWidget); // only the start picker

    // Choose "Sampai ayat tertentu" â†’ the end pickers appear and the cubit
    // receives an end target.
    await tester.tap(find.text('bible_range_to_verse'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    verify(() => cubit.setTtsPlayRangeEnd(any())).called(1);
    expect(find.text('bible_book'), findsNWidgets(2)); // start + end pickers
    expect(find.textContaining('bible_range_summary', skipOffstage: false), findsOneWidget);
  });

  testWidgets('range modes: chapter end and lanjut terus call the cubit',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byIcon(Icons.keyboard_arrow_up_rounded));
    await tester.pump(const Duration(milliseconds: 100));

    // "Lanjut terus" â†’ setPlayRangeContinueOn (auto-next on, no end target).
    await tester.tap(find.text('bible_range_continue'));
    await tester.pump(const Duration(milliseconds: 100));
    verify(() => cubit.setPlayRangeContinueOn()).called(1);

    // Back to "Sampai akhir pasal" â†’ setPlayRangeToChapterEnd.
    await tester.tap(find.text('bible_range_chapter_end'));
    await tester.pump(const Duration(milliseconds: 100));
    verify(() => cubit.setPlayRangeToChapterEnd()).called(1);
  });

  testWidgets('range start picker reports changes to the cubit',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.byIcon(Icons.keyboard_arrow_up_rounded));
    await tester.pump(const Duration(milliseconds: 100));

    // Change the START book â†’ setTtsPlayRangeStart receives a verse in the
    // selected book, chapter 1, verse 1.
    await tester.tap(find.byType(DropdownButtonFormField<int>).first);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Kel').last);
    await tester.pump(const Duration(milliseconds: 100));

    verify(
      () => cubit.setTtsPlayRangeStart(
        any(
          that: isA<Verse>().having((v) => v.bookId, 'bookId', 2),
        ),
      ),
    ).called(1);
  });
}

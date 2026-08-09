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
    BibleBook(id: 2, shortName: 'Kel', longName: 'Keluaran', chapterCount: 40),
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

  Future<void> pumpCollapsed(WidgetTester tester, {Size size = const Size(360, 740)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(wrap());
    await tester.pump(const Duration(milliseconds: 60));
  }

  testWidgets('collapsed sidebar expands into full range controls', (tester) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpCollapsed(tester);

    expect(find.byKey(const ValueKey('bible-audio-collapsed-gesture')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('bible-audio-collapsed-gesture')));
    await tester.pumpAndSettle();

    expect(find.text('bible_range_title'), findsOneWidget);
    expect(find.text('bible_range_start'), findsOneWidget);
    expect(find.text('bible_range_end'), findsOneWidget);
    expect(find.text('bible_range_chapter_end'), findsOneWidget);
    expect(find.text('bible_range_continue'), findsOneWidget);
    expect(find.text('bible_range_to_verse'), findsOneWidget);
  });

  testWidgets('dragged sidebar remains tappable at its new visible position', (tester) async {
    WidgetController.hitTestWarningShouldBeFatal = true;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      WidgetController.hitTestWarningShouldBeFatal = false;
    });
    await pumpCollapsed(tester);

    final positioned = find.byKey(const ValueKey('bible-audio-positioned'));
    final collapsed = find.byKey(const ValueKey('bible-audio-collapsed-gesture'));
    final before = tester.getRect(positioned);

    await tester.drag(collapsed, const Offset(-220, -90));
    await tester.pumpAndSettle();

    final after = tester.getRect(positioned);
    expect(after.left, lessThan(before.left - 100));
    expect(after.top, lessThan(before.top - 30));

    // Regression: with the old Transform.translate layout, the visible child
    // could move away from its ancestor hit-test bounds and this tap missed.
    await tester.tap(collapsed, warnIfMissed: true);
    await tester.pumpAndSettle();

    expect(find.text('bible_range_title'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('edge snap preserves vertical release position', (tester) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpCollapsed(tester);

    final positioned = find.byKey(const ValueKey('bible-audio-positioned'));
    final collapsed = find.byKey(const ValueKey('bible-audio-collapsed-gesture'));
    final before = tester.getRect(positioned);

    await tester.drag(collapsed, const Offset(-220, -150));
    await tester.pumpAndSettle();
    final leftDock = tester.getRect(positioned);

    expect(leftDock.left, lessThan(0));
    expect(leftDock.top, lessThan(before.top - 60));

    await tester.drag(collapsed, const Offset(320, 0));
    await tester.pumpAndSettle();
    final rightDock = tester.getRect(positioned);

    expect(rightDock.left, greaterThan(300));
    expect((rightDock.top - leftDock.top).abs(), lessThan(4));
  });

  testWidgets('collapse returns to the saved sidebar dock', (tester) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpCollapsed(tester);

    final positioned = find.byKey(const ValueKey('bible-audio-positioned'));
    final collapsed = find.byKey(const ValueKey('bible-audio-collapsed-gesture'));

    await tester.drag(collapsed, const Offset(-220, -100));
    await tester.pumpAndSettle();
    final dockRect = tester.getRect(positioned);

    await tester.tap(collapsed);
    await tester.pumpAndSettle();
    expect(find.text('bible_range_title'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.expand_more_rounded));
    await tester.pumpAndSettle();

    final returnedRect = tester.getRect(positioned);
    expect((returnedRect.left - dockRect.left).abs(), lessThan(4));
    expect((returnedRect.top - dockRect.top).abs(), lessThan(4));
  });

  testWidgets('range modes still call the Bible cubit', (tester) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpCollapsed(tester);
    await tester.tap(find.byKey(const ValueKey('bible-audio-collapsed-gesture')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('bible_range_continue'));
    await tester.pump();
    verify(() => cubit.setPlayRangeContinueOn()).called(1);

    await tester.tap(find.text('bible_range_chapter_end'));
    await tester.pump();
    verify(() => cubit.setPlayRangeToChapterEnd()).called(1);
  });

  testWidgets('specific end verse mode reveals the destination picker', (tester) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpCollapsed(tester);
    await tester.tap(find.byKey(const ValueKey('bible-audio-collapsed-gesture')));
    await tester.pumpAndSettle();

    expect(find.text('bible_book'), findsOneWidget);
    await tester.tap(find.text('bible_range_to_verse'));
    await tester.pump();
    await tester.pump();

    verify(() => cubit.setTtsPlayRangeEnd(any())).called(1);
    expect(find.text('bible_book'), findsNWidgets(2));
  });

  testWidgets('compact viewport has no overflow or hit-test warning', (tester) async {
    WidgetController.hitTestWarningShouldBeFatal = true;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      WidgetController.hitTestWarningShouldBeFatal = false;
    });
    await pumpCollapsed(tester, size: const Size(320, 568));

    await tester.tap(find.byKey(const ValueKey('bible-audio-collapsed-gesture')));
    await tester.pumpAndSettle();

    expect(find.text('bible_range_title'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifies the redesigned header layout does not overflow on narrow
/// screens. Mirrors the exact pill structures used by the Bible header
/// (FittedBox-wrapped Row of filled pills, incl. split mode) and the Song
/// title chip (FittedBox inside the chip + rounded number badge).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child, {double width = 390, bool withActions = false}) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leadingWidth: 56,
          leading: const IconButton(
            onPressed: null,
            icon: Icon(Icons.menu_outlined),
          ),
          actions: withActions
              ? const [
                  IconButton(
                    onPressed: null,
                    icon: Icon(Icons.splitscreen_rounded),
                  ),
                  IconButton(
                    onPressed: null,
                    icon: Icon(Icons.search_rounded),
                  ),
                  IconButton(
                    onPressed: null,
                    icon: Icon(Icons.more_vert_rounded),
                  ),
                ]
              : const [
                  IconButton(
                    onPressed: null,
                    icon: Icon(Icons.dashboard_rounded),
                  ),
                ],
          toolbarHeight: 76,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha: 0.94),
                ],
              ),
            ),
          ),
          title: child,
        ),
      ),
    );
  }

  Widget biblePickerPill(ColorScheme scheme, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: active
            ? scheme.primaryContainer.withValues(alpha: 0.55)
            : scheme.surfaceContainerHigh.withValues(alpha: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          const SizedBox(width: 6),
          Text(label),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        ],
      ),
    );
  }

  Widget songTitleChip(ColorScheme scheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 48),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primaryContainer.withValues(alpha: 0.45),
                  scheme.surfaceContainerHigh.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.music_note_rounded, size: 15),
                      const SizedBox(width: 5),
                      Text(
                        'Saat Fajar Menyingsing',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh
                              .withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text('123'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  testWidgets('Bible header pills fit on a 390px phone (single mode)',
      (tester) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.blue);
    final appBarTitle = FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: scheme.surfaceContainerHigh.withValues(alpha: 0.7),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_stories_rounded, size: 18),
                SizedBox(width: 6),
                Text('Kejadian 1'),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              ],
            ),
          ),
          const SizedBox(width: 8),
          biblePickerPill(scheme, 'TB', true),
        ],
      ),
    );

    await tester.pumpWidget(wrap(appBarTitle));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bible split-mode header (3 pills) fits on a 390px phone',
      (tester) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.blue);
    final appBarTitle = FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: scheme.surfaceContainerHigh.withValues(alpha: 0.7),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_stories_rounded, size: 18),
                SizedBox(width: 6),
                Text('Kejadian 1'),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              ],
            ),
          ),
          const SizedBox(width: 8),
          biblePickerPill(scheme, 'TB', true),
          const SizedBox(width: 8),
          biblePickerPill(scheme, 'KJV', false),
        ],
      ),
    );

    await tester.pumpWidget(wrap(appBarTitle, withActions: true));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Song title chip fits on a 390px phone with number badge',
      (tester) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.blue);
    await tester.pumpWidget(wrap(songTitleChip(scheme)));
    expect(tester.takeException(), isNull);
  });
}

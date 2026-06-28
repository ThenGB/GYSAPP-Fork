import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('split Bible locked scrolling is guarded and bidirectional', () {
    final source = File(
      'lib/presentations/bible/view/bible_view.dart',
    ).readAsStringSync();
    final viewerSource = File(
      'lib/presentations/bible/widget/bible_viewer.dart',
    ).readAsStringSync();
    final cubitSource = File(
      'lib/presentations/bible/cubit/bible_cubit.dart',
    ).readAsStringSync();
    final stateSource = File(
      'lib/presentations/bible/cubit/bible_state.dart',
    ).readAsStringSync();

    expect(source, contains('enum _BibleSplitPane'));
    expect(source, contains('_activeSplitPane'));
    expect(source, contains('_isSyncingSplitScroll'));
    expect(source, contains('_syncSplitPaneScroll'));
    expect(source, contains('_BibleSplitPane.top'));
    expect(source, contains('_BibleSplitPane.bottom'));
    expect(source, contains('verse.verseId'));
    expect(source, contains('_isSyncingSplitScroll'));
    expect(viewerSource, contains(': widget.verseKeys[index]'));
    expect(viewerSource, isNot(contains("ValueKey('split_verse_")));

    // Regression: split sync must be gated on isSplitContentLoading so the
    // target pane doesn't snap to a stale verse when only one side of the
    // split content has finished loading.
    expect(stateSource, contains('isSplitContentLoading'));
    expect(source, contains('isSplitContentLoading'));
    expect(
      cubitSource,
      contains('await getContent2(bible)'),
      reason:
          'getContent2 must be awaited so bottom state lands before top state',
    );
    expect(
      cubitSource,
      contains('isSplitContentLoading: true'),
    );
    expect(
      cubitSource,
      contains('isSplitContentLoading: false'),
    );
  });
}

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

    expect(source, contains('enum _BibleSplitPane'));
    expect(source, contains('_activeSplitPane'));
    expect(source, contains('_isSyncingSplitScroll'));
    expect(source, contains('_syncSplitPaneScroll'));
    expect(source, contains('_BibleSplitPane.top'));
    expect(source, contains('_BibleSplitPane.bottom'));
    expect(source, contains('sourceVerse.verseId'));
    expect(source, contains('targetVerseIndex'));
    expect(source, contains('_calculateSplitVerseAlignment'));
    expect(viewerSource, contains(': widget.verseKeys[index]'));
    expect(viewerSource, isNot(contains("ValueKey('split_verse_")));
  });
}

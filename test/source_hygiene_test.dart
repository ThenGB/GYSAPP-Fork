import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('high-frequency gesture and scroll paths do not emit debug logs', () {
    const blockedPatternsByFile = {
      'lib/presentations/bible/widget/bible_viewer.dart': [
        'log(touches.toString())',
        "log(event.pointer.toString(), name: 'Pointer')",
      ],
      'lib/presentations/faith/view/faith_view.dart': [
        'log(event.pointer.toString())',
      ],
      'lib/presentations/bible/widget/bible_verse_widget.dart': [
        "log('Onselect')",
      ],
      'lib/presentations/bible/view/bible_view.dart': [
        "log(splitController.areas.map((e) => e.size).toString(), name: 'Areas')",
        "log(verseIndex.toString(), name: 'Scroll to')",
      ],
      'lib/presentations/song/view/song_list_view.dart': [
        "log('List disposed')",
      ],
    };

    for (final entry in blockedPatternsByFile.entries) {
      final source = File(entry.key).readAsStringSync();
      for (final pattern in entry.value) {
        expect(
          source,
          isNot(contains(pattern)),
          reason: '${entry.key} should not log "$pattern"',
        );
      }
    }
  });

  test('lib does not keep stale Dart backup files', () {
    final backups = Directory('lib')
        .listSync(recursive: true)
        .where((entity) => entity.path.endsWith('.dart.bak'))
        .map((entity) => entity.path)
        .toList();

    expect(backups, isEmpty);
  });
}

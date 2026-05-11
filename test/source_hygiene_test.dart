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

  test('song book loading does not eagerly resolve every midi asset', () {
    final source = File(
      'lib/data/services/local_asset_service.dart',
    ).readAsStringSync();
    final loadSongBookBody =
        RegExp(
          r'Future<SongBook> loadSongBook\(String code\) async \{([\s\S]*?)\n  \}',
        ).firstMatch(source)?.group(1) ??
        '';

    expect(loadSongBookBody, isNot(contains('_resolveAssetPath')));
  });

  test('production code does not keep midi preload paths', () {
    final offenders = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) {
          final path = file.path.replaceAll('\\', '/');
          if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
            return false;
          }
          final source = file.readAsStringSync().toLowerCase();
          return source.contains('preload');
        })
        .map((file) => file.path)
        .toList();

    expect(offenders, isEmpty);
  });

  test('song pdf viewer streams assets without base64 handoff', () {
    final source = File(
      'lib/presentations/song/widgets/song_pdf_viewer.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('base64Encode')));
    expect(source, isNot(contains('rootBundle.load')));
    // Since the rewrite to pdfrx, assets are loaded natively (no JS loadPdfUrl).
    expect(source, contains('pdfrx'));
    expect(source, isNot(contains('InAppWebView')));
  });

  test('large pdf asset folders stay consolidated as master documents', () {
    const mastersByFolder = {
      'mdr': 'mdr_master.pdf',
      'asm_i': 'asm_i_master.pdf',
      'asm_m': 'asm_m_master.pdf',
      'asm_p': 'asm_p_master.pdf',
    };

    for (final entry in mastersByFolder.entries) {
      final pdfs = Directory('assets/data/pdf/${entry.key}')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.toLowerCase().endsWith('.pdf'))
          .map((file) => file.uri.pathSegments.last)
          .toList();

      expect(pdfs, [entry.value]);
      expect(
        File('assets/data/index/${entry.key}_pdf_manifest.json').existsSync(),
        true,
      );
    }
  });
}

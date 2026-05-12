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

  test('production code does not keep stale midi preload scaffolding', () {
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
          return source.contains('old preload') ||
              source.contains('_preloadnearbysongmidi') ||
              source.contains('preload system refactored');
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

  test('obsolete pdf webview assets are not bundled', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, isNot(contains('assets/web/pdf_viewer.html')));
    expect(pubspec, isNot(contains('assets/web/pdfjs')));
  });

  test('local asset service uses Flutter asset manifest API', () {
    final source = File(
      'lib/data/services/local_asset_service.dart',
    ).readAsStringSync();

    expect(source, contains('AssetManifest.loadFromAssetBundle'));
    expect(source, isNot(contains("loadString('AssetManifest.json')")));
    expect(source, isNot(contains("File('assets/AssetManifest.json')")));
  });

  test('windows pdf viewer bundles native PDFium runtime', () {
    final appSource = File('lib/app.dart').readAsStringSync();
    final cmakeSource = File('windows/CMakeLists.txt').readAsStringSync();

    expect(appSource, contains('Pdfrx.pdfiumModulePath'));
    expect(appSource, contains('pdfrxFlutterInitialize'));
    expect(cmakeSource, contains('build/native_assets/windows/pdfium.dll'));
    expect(cmakeSource, contains(r'install(FILES "${PDFIUM_NATIVE_ASSET}"'));
  });

  test('song pdf viewer exposes fit page and native chord fallback', () {
    final viewerSource = File(
      'lib/presentations/song/widgets/song_pdf_viewer.dart',
    ).readAsStringSync();
    final songViewSource = File(
      'lib/presentations/song/view/song_view.dart',
    ).readAsStringSync();

    expect(songViewSource, contains('Icons.fit_screen_rounded'));
    expect(songViewSource, contains('_pdfViewerController'));
    expect(viewerSource, contains('calcMatrixForFit'));
    expect(viewerSource, contains('PdfViewerSizeDelegateProviderLegacy'));
    expect(viewerSource, contains('fitZoom'));
    expect(viewerSource, contains('_fallbackPositions'));
    expect(
      viewerSource,
      contains('notePositions != null && notePositions.isNotEmpty'),
    );
    expect(
      viewerSource,
      isNot(contains('..._fallbackPositions(widget.chords)')),
    );
    expect(viewerSource, isNot(contains('debugPrint(')));
  });

  test(
    'song view refreshes PDF and chord assets after async state changes',
    () {
      final source = File(
        'lib/presentations/song/view/song_view.dart',
      ).readAsStringSync();

      expect(source, contains('previous.songBook != current.songBook'));
      expect(source, contains('previous.showChord != current.showChord'));
    },
  );

  test('song cubit allows HYMNE to use KR chord fallback', () {
    final source = File(
      'lib/presentations/song/cubit/song_cubit.dart',
    ).readAsStringSync();

    expect(source, isNot(contains("song.code != 'KR'")));
  });

  test('song favorite UI and playback paths are removed', () {
    final songViewSource = File(
      'lib/presentations/song/view/song_view.dart',
    ).readAsStringSync();
    final songListSource = File(
      'lib/presentations/song/view/song_list_view.dart',
    ).readAsStringSync();
    final songCubitSource = File(
      'lib/presentations/song/cubit/song_cubit.dart',
    ).readAsStringSync();

    expect(songViewSource, isNot(contains('modifyFavorite')));
    expect(songViewSource, isNot(contains('isSongFavorite')));
    expect(songViewSource, isNot(contains('playOnlyFavorite')));
    expect(songListSource, isNot(contains("label: 'Favorite'")));
    expect(songListSource, isNot(contains('favoriteBooks')));
    expect(songListSource, isNot(contains('onPlayFavorite')));
    expect(songCubitSource, isNot(contains('modifyFavorite')));
    expect(songCubitSource, isNot(contains('isSongFavorite')));
    expect(songCubitSource, isNot(contains('favoriteSongBook')));
    expect(songCubitSource, isNot(contains('playOnlyFavorite')));
  });

  test('dashboard mini player overlays without reserving background space', () {
    final source = File(
      'lib/presentations/dashboard/view/dashboard_view.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('const bool kDashboardExtendsBodyForMiniPlayerOverlay = true'),
    );
    expect(source, isNot(contains('72 + playerHeight')));
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

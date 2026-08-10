import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
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
    expect(source, isNot(contains('PopupMenuButton<String>')));
  });

  test('obsolete pdf webview assets are not bundled', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, isNot(contains('assets/web/pdf_viewer.html')));
    expect(pubspec, isNot(contains('assets/web/pdfjs')));
  });

  test('app source no longer depends on Firebase SDK wiring', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final appSource = File('lib/app.dart').readAsStringSync();
    final mainSource = File('lib/main.dart').readAsStringSync();
    final failureSource = File(
      'lib/data/utilities/variables/failure.dart',
    ).readAsStringSync();

    expect(pubspec, isNot(contains('firebase_')));
    expect(pubspec, isNot(contains('cloud_firestore')));
    expect(appSource, isNot(contains('Firebase')));
    expect(mainSource, isNot(contains('Firebase')));
    expect(failureSource, isNot(contains('Firebase')));
    expect(File('lib/firebase_options.dart').existsSync(), isFalse);
    expect(File('ios/GoogleService-Info.plist').existsSync(), isFalse);
    expect(File('macos/Runner/GoogleService-Info.plist').existsSync(), isFalse);
    expect(File('android/app/google-services.json').existsSync(), isFalse);
    expect(File('firebase.json').existsSync(), isFalse);
  });

  test('app source no longer includes remote storage cloud helpers', () {
    final utilitiesSource = File(
      'lib/data/utilities/utilities.dart',
    ).readAsStringSync();
    final dartSources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync())
        .join('\n');

    expect(
      File('lib/data/utilities/remote_storage_helper.dart').existsSync(),
      isFalse,
    );
    expect(utilitiesSource, isNot(contains('remote_storage_helper.dart')));
    expect(dartSources, isNot(contains('storage.googleapis.com')));
  });

  test('legacy Google auth and Drive backup wiring are removed from app code', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final injection = File('lib/di/injection.dart').readAsStringSync();
    final loginView = File('lib/presentations/auth/view/login_view.dart')
        .readAsStringSync();
    final authCubit = File('lib/presentations/auth/cubit/auth_cubit.dart')
        .readAsStringSync();
    final backupView = File('lib/presentations/backup/view/backup_view.dart')
        .readAsStringSync();
    final backupCubit = File('lib/presentations/backup/cubit/backup_cubit.dart')
        .readAsStringSync();

    // The current app uses native Google Sign-In via google_sign_in package
    // and an in-app WebView flow.  It does NOT use the legacy FlutterAppAuth
    // OAuth path or Google Drive backup.  This test now verifies that the
    // legacy wiring was removed while the current wiring remains intact.
    expect(pubspec, isNot(contains('flutter_appauth:')));
    expect(injection, isNot(contains('FlutterAppAuth(')));
    expect(injection, isNot(contains('GoogleRepository')));
    expect(injection, isNot(contains('BackupSyncRepository')));
    expect(authCubit, isNot(contains('FlutterAppAuth')));
    expect(backupView, isNot(contains('Cloud Backup')));
    expect(backupCubit, isNot(contains('backupToDrive')));
    expect(backupCubit, isNot(contains('syncFromDrive')));
    // Sanity: native Google Sign-In wiring is still present.
    expect(pubspec, contains('google_sign_in:'));
    expect(loginView, contains('GoogleSignIn'));
  });

  test('settings exposes per-kind asset management (no offline library page)', () {
    final settingsView = File('lib/presentations/settings/view/settings_view.dart')
        .readAsStringSync();
    final bibleVersionView = File(
      'lib/presentations/bible/view/bible_version_view.dart',
    ).readAsStringSync();
    final hymnalView = File(
      'lib/presentations/settings/view/hymnal_management_view.dart',
    ).readAsStringSync();

    // The standalone Offline Library page is gone.
    expect(settingsView, isNot(contains('offline_library'.tr())));
    expect(settingsView, isNot(contains('AssetManagementRoute(')));
    // Hymn book management lives in the PUJIAN section.
    expect(settingsView, contains("'hymn_book'.tr()"));
    expect(settingsView, contains('HymnalManagementRoute()'));
    // Cache & full reset moved into LAINNYA.
    expect(settingsView, contains("'delete_app_cache'.tr()"));
    expect(settingsView, contains("'full_app_reset'.tr()"));
    expect(settingsView, contains('clearFastAccessCache()'));
    // Bible versions page drives downloads/updates through the asset tile
    // and is management-only: the active version is chosen inside the Bible
    // view header, so no tap-to-select lives here.
    expect(bibleVersionView, contains('DistributedAssetTile'));
    expect(bibleVersionView, isNot(contains('selectBibleCodeByName(code)')));
    // Hymnal management page lists hymnal assets.
    expect(hymnalView, contains('DistributedAssetTile'));
  });

  test('repo root is free of loose diagnostic artifacts', () {
    const blockedRootArtifacts = [
      '.build_apk.log',
      '.flutter_run.log',
      'COMPREHENSIVE_TESTING_GUIDE.md',
      'CURRENT_STATE_ANALYSIS.md',
      'EDIT_MODE_ANALYSIS.md',
      'IMPLEMENTATION_SUMMARY.md',
      'MANUAL_TESTING_GUIDE.md',
      'MCP_SERVER_STATUS.md',
      'MINI_PLAYER_ANALYSIS.md',
      'chord_positioning_report.json',
      'deep_analysis_screenshot.png',
      'deep_positioning_analysis.json',
      'flutter_01.log',
      'image.png',
      'image2.png',
      'image3.png',
      'image4.png',
      'image5.png',
      'inputimage.txt',
      'ipad.png',
      'ipad2.png',
      'ipad3.png',
      'mini_player_actual.html',
      'mini_player_state.png',
      'mini_player_structure.html',
      'test_pypdf_001.pdf',
      'test_pypdf_2page.pdf',
      'test_storage.dart',
      'web_app_screenshot.png',
      'web_app_screenshot_song0.png',
      'web_app_screenshot_song1.png',
      'web_app_screenshot_song2.png',
      'web_app_screenshot_song3.png',
      'web_app_screenshot_song4.png',
      'web_edit_mode_state.png',
      'web_viewer_state.png',
    ];

    for (final artifact in blockedRootArtifacts) {
      expect(
        File(artifact).existsSync(),
        isFalse,
        reason: '$artifact should be moved out of the repository root',
      );
    }
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
      'lib/presentations/song/widgets/song_pdf_viewer_base.dart',
    ).readAsStringSync();
    final songViewSource = File(
      'lib/presentations/song/view/song_view.dart',
    ).readAsStringSync();

    expect(songViewSource, contains('_fitPdfToPage'));
    expect(songViewSource, contains('_pdfViewerController'));
    // The fit is applied through the retry-with-fallback helper rather than
    // the pdfrx direct matrix call, so the viewer stays visible even when
    // the pdfrx ready callback stalls.
    expect(viewerSource, contains('_fitToPageInstant'));
    expect(viewerSource, contains('_scheduleFitWithFallback'));
    expect(viewerSource, contains('PdfViewerSizeDelegateProviderLegacy'));
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

  test('dashboard navigation reserves space outside reader content', () {
    final source = File(
      'lib/presentations/dashboard/view/dashboard_view.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('const bool kDashboardExtendsBodyForMiniPlayerOverlay = false'),
    );
    // Compact mode places the dock in Scaffold's bottomNavigationBar slot so
    // reader content is never painted underneath it.
    expect(source, contains('bottomNavigationBar: useRail'));
    expect(source, contains('NavigationRail'));
  });

  test('bundled asset manifest keeps only KR song PDFs and TB bible data', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains('- assets/data/bible/b_tb/'));
    expect(pubspec, contains('- assets/data/pdf/kr/'));
    expect(pubspec, isNot(contains('- assets/data/pdf/hymne/')));
    expect(pubspec, isNot(contains('- assets/data/pdf/mdr/')));
    expect(pubspec, isNot(contains('- assets/data/pdf/asm_i/')));
    expect(pubspec, isNot(contains('- assets/data/pdf/asm_m/')));
    expect(pubspec, isNot(contains('- assets/data/pdf/asm_p/')));
  });

  test('bundled song PDFs do not ship prebuilt chunk or pack binaries', () {
    final bundledPdfBins = Directory('assets/data/pdf')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.bin'))
        .map((file) => file.path.replaceAll('\\', '/'))
        .where(
          (path) =>
              path.contains('_chunks.bin') || path.contains('_song_pack'),
        )
        .toList();

    expect(bundledPdfBins, isEmpty);
  });
}

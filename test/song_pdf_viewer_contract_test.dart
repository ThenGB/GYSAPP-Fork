import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PDF range viewer disables pdfrx progressive loading', () {
    final source = File(
      'lib/presentations/song/widgets/song_pdf_viewer.dart',
    ).readAsStringSync();

    expect(
      'useProgressiveLoading: false'.allMatches(source).length,
      greaterThanOrEqualTo(2),
    );
  });

  test('PDF layout cache depends on the page set supplied by pdfrx', () {
    final source = File(
      'lib/presentations/song/widgets/song_pdf_viewer.dart',
    ).readAsStringSync();

    expect(source, contains('pageHash'));
    expect(source, contains(r'#ph$pageHash'));
  });

  test('fit-to-page is guarded when pdfrx controller is between states', () {
    final source = File(
      'lib/presentations/song/widgets/song_pdf_viewer.dart',
    ).readAsStringSync();

    expect(source, contains('_tryCalcFitMatrix'));
    expect(source, contains('on TypeError'));
    expect(source, contains('_scheduleFitWithFallback()'));
    expect(source, isNot(contains('final matrix = _pdfCtrl.calcMatrixForFit')));
  });

  test('initial PDF fit waits for viewer-ready layout', () {
    final source = File(
      'lib/presentations/song/widgets/song_pdf_viewer.dart',
    ).readAsStringSync();
    final parseStart = source.indexOf('void _parsePdfPath()');
    final fallbackStart = source.indexOf('/// Fallback mechanism');
    final parseBody = source.substring(parseStart, fallbackStart);

    expect(parseBody, isNot(contains('_scheduleFitWithFallback();')));
    expect(source, contains('void _onViewerReady('));
    expect(source, contains('_waitForValidSizeAndFit(ctrl, generation);'));
  });

  test(
    'new PDF request is allowed to build chord overlays after fade swap',
    () {
      final source = File(
        'lib/presentations/song/widgets/song_pdf_viewer.dart',
      ).readAsStringSync();

      expect(source, contains('_pdfRequest = newRequest;'));
      expect(source, contains('_isTransitioning = false;'));
    },
  );

  test('initial PDF fit waits for stable viewer dimensions', () {
    final source = File(
      'lib/presentations/song/widgets/song_pdf_viewer.dart',
    ).readAsStringSync();

    expect(source, contains('_waitForStableViewerSize'));
    expect(source, contains('stableFrames'));
    expect(source, contains('lastSize'));
  });

  test('first PDF load has a viewer-ready watchdog', () {
    final source = File(
      'lib/presentations/song/widgets/song_pdf_viewer.dart',
    ).readAsStringSync();

    expect(source, contains('_scheduleViewerReadyWatchdog'));
    expect(source, contains('_viewerInstance'));
    expect(source, contains('_viewerReadyGeneration'));
  });

  test('viewer-ready callbacks are scoped to the active PDF request', () {
    final source = File(
      'lib/presentations/song/widgets/song_pdf_viewer.dart',
    ).readAsStringSync();

    expect(source, contains('int generation,'));
    expect(source, contains('String sourceId,'));
    expect(source, contains('request.sourceId != sourceId'));
    expect(
      source,
      contains('_onViewerReady(document, ctrl, requestGeneration'),
    );
  });

  test('viewer-ready primes key and tempo detection from first PDF page', () {
    final source = File(
      'lib/presentations/song/widgets/song_pdf_viewer.dart',
    ).readAsStringSync();

    expect(source, contains('_primeDetectedMetadataFromFirstPage'));
    expect(
      source,
      contains('_primeDetectedMetadataFromFirstPage(document, request);'),
    );
    expect(source, contains('unawaited(_loadNotePositionsAndInfos(firstPage))'));
  });

  test('detected PDF metadata ignores stale callbacks from old request', () {
    final source = File(
      'lib/presentations/song/widgets/song_pdf_viewer.dart',
    ).readAsStringSync();

    expect(source, contains('final requestSourceId = request.sourceId;'));
    expect(source, contains('_pdfRequest?.sourceId == requestSourceId'));
  });
}

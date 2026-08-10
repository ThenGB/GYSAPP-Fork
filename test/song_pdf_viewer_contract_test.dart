import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/presentations/song/widgets/song_pdf_viewer_base.dart',
  ).readAsStringSync();

  test('PDF range viewer disables pdfrx progressive loading', () {
    expect(
      'useProgressiveLoading: false'.allMatches(source).length,
      greaterThanOrEqualTo(2),
    );
  });

  test('PDF layout cache depends on the page set supplied by pdfrx', () {
    expect(source, contains('pageHash'));
    expect(source, contains(r'#ph$pageHash'));
  });

  test('fit-to-page is guarded when pdfrx controller is between states', () {
    expect(source, contains('_tryCalcFitMatrix'));
    expect(source, contains('on TypeError'));
    expect(source, contains('_scheduleFitWithFallback()'));
    expect(source, isNot(contains('final matrix = _pdfCtrl.calcMatrixForFit')));
  });

  test('initial PDF fit waits for viewer-ready layout', () {
    final parseStart = source.indexOf('void _parsePdfPath()');
    final watchdogStart = source.indexOf('void _scheduleViewerReadyWatchdog');
    final parseBody = source.substring(parseStart, watchdogStart);

    expect(parseBody, isNot(contains('_scheduleFitWithFallback();')));
    expect(source, contains('void _onViewerReady('));
    expect(source, contains('_waitForValidSizeAndFit(ctrl, generation);'));
  });

  test(
    'new PDF request is allowed to build chord overlays after fade swap',
    () {
      expect(source, contains('_pdfRequest = newRequest;'));
      expect(source, contains('_isTransitioning = false;'));
    },
  );

  test('initial PDF fit waits for stable viewer dimensions', () {
    expect(source, contains('_waitForStableViewerSize'));
    expect(source, contains('stableFrames'));
    expect(source, contains('lastSize'));
  });

  test('first PDF load has a viewer-ready watchdog', () {
    expect(source, contains('_scheduleViewerReadyWatchdog'));
    expect(source, contains('_viewerInstance'));
    expect(source, contains('_viewerReadyGeneration'));
  });

  test('viewer-ready callbacks are scoped to the active PDF request', () {
    expect(source, contains('int generation,'));
    expect(source, contains('String sourceId,'));
    expect(source, contains('request.sourceId != sourceId'));
    expect(
      source,
      contains('_onViewerReady(document, ctrl, requestGeneration'),
    );
  });

  test('viewer-ready primes key and tempo detection from first PDF page', () {
    expect(source, contains('_primeDetectedMetadataFromFirstPage'));
    expect(
      source,
      contains('_primeDetectedMetadataFromFirstPage(document, request);'),
    );
    expect(
      source,
      contains(
        'unawaited(_loadNotePositionsAndInfos(document.pages[pageIndex]))',
      ),
    );
  });

  test('detected PDF metadata ignores stale callbacks from old request', () {
    expect(source, contains('final sourceId = request.sourceId;'));
    expect(source, contains('_pdfRequest?.sourceId == sourceId'));
  });
}

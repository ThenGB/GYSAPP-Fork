import 'package:church/data/services/chord_service.dart';
import 'package:church/presentations/song/cubit/song_playback_defaults.dart';
import 'package:church/presentations/song/cubit/song_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SongPlaybackDefaults', () {
    test('resets song-scoped tempo and transpose when a song is opened', () {
      const previous = SongPlaybackDefaults(
        transposeStep: 7,
        tempoBpm: 148,
        defaultTempoBpm: 148,
        originalFamilyChord: 'F#',
        originalPdfKey: 'Fis',
        baseTransposeOffset: 4,
      );

      final reset = previous.resetForSong();

      expect(reset.transposeStep, 0);
      expect(reset.tempoBpm, 76);
      expect(reset.defaultTempoBpm, 76);
      expect(reset.originalFamilyChord, isNull);
      expect(reset.originalPdfKey, isNull);
      expect(reset.baseTransposeOffset, 0);
    });

    test(
      'anchors family chord to detected PDF key baseline at transpose zero',
      () {
      const reset = SongPlaybackDefaults(
        transposeStep: 0,
        tempoBpm: 76,
        defaultTempoBpm: 76,
      );

      final resolved = reset.resolveChordBaseline(
        familyChord: 'C',
        pdfKey: 'Es',
        preferNaturalChords: true,
      );

      expect(resolved.baseTransposeOffset, 3);
      expect(resolved.transposeStep, 0);
      expect(
        ChordService.transposeChord(
          'C',
          resolved.transposeStep,
          baseTransposeOffset: resolved.baseTransposeOffset,
          accidentalMode: ChordService.accidentalFlat,
        ),
        'Eb',
      );
      expect(
        resolved.activeKeyLabel(accidentalMode: ChordService.accidentalFlat),
        'Eb',
      );
    });

    test(
      'prefers natural transpose from pdf key when family chord is missing',
      () {
        const reset = SongPlaybackDefaults(
          transposeStep: 0,
          tempoBpm: 76,
          defaultTempoBpm: 76,
        );

        final blackKey = reset.resolveChordBaseline(
          familyChord: null,
          pdfKey: 'Fis',
          preferNaturalChords: true,
        );
        final whiteKey = reset.resolveChordBaseline(
          familyChord: null,
          pdfKey: 'E',
          preferNaturalChords: true,
        );

        expect(blackKey.transposeStep, -1);
        expect(whiteKey.transposeStep, 0);
      },
    );

    test('detects active key and maps key selection to transpose step', () {
      const baseline = SongPlaybackDefaults(
        transposeStep: -1,
        tempoBpm: 76,
        defaultTempoBpm: 76,
        originalFamilyChord: 'C',
        originalPdfKey: 'Fis',
        baseTransposeOffset: 6,
      );

      expect(
        baseline.activeKeyLabel(accidentalMode: ChordService.accidentalFlat),
        'F',
      );
      expect(
        baseline.keyOptions(accidentalMode: ChordService.accidentalFlat),
        containsAllInOrder(['C', 'Db', 'D', 'Eb']),
      );
      expect(baseline.transposeStepForKey('Ab'), 2);
      expect(
        baseline
            .copyWith(originalFamilyChord: 'C#m', baseTransposeOffset: 0)
            .activeKeyLabel(accidentalMode: ChordService.accidentalFlat),
        'Cm',
      );
    });

    test('state defaults keep automatic chord baseline detection enabled', () {
      expect(const SongState().preferNaturalChords, isTrue);
    });
  });
}

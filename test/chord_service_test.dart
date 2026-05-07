import 'package:church/data/services/chord_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats transposed chords with selected accidental style', () {
    expect(
      ChordService.transposeChord('C', 1),
      'C#',
    );
    expect(
      ChordService.transposeChord(
        'C',
        1,
        accidentalMode: ChordService.accidentalFlat,
      ),
      'Db',
    );
    expect(
      ChordService.transposeChord(
        'F#/A#',
        0,
        accidentalMode: ChordService.accidentalFlat,
      ),
      'Gb/Bb',
    );
  });

  test('detects family chord from note aligned chord pages', () {
    const chords = {
      1: [
        ChordData(noteIdx: 2, chord: 'C', page: 1),
        ChordData(noteIdx: 8, chord: 'G', page: 1),
        ChordData(noteIdx: 12, chord: 'C', page: 1),
      ],
    };

    expect(ChordService.detectFamilyChord(chords), 'C');
  });

  test('maps pdf key notation and aligns chord family to pdf key', () {
    expect(ChordService.parsePdfKeyToSemitone('C'), 0);
    expect(ChordService.parsePdfKeyToSemitone('Bes'), 10);
    expect(ChordService.parsePdfKeyToSemitone('Fis'), 6);
    expect(ChordService.parsePdfKeyToSemitone('H'), 11);

    expect(
      ChordService.calculateBaseTransposeOffset(
        pdfKey: 'F',
        familyChord: 'C',
      ),
      5,
    );
    expect(
      ChordService.formatChordForDisplay('C',
          baseTransposeOffset: 5, accidentalMode: ChordService.accidentalFlat),
      'F',
    );
  });
}

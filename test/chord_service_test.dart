import 'package:church/data/services/chord_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats transposed chords with selected accidental style', () {
    expect(ChordService.transposeChord('C', 1), 'C#');
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

  test('detects minor roots without treating Em as Es-style notation', () {
    const chords = {
      1: [
        ChordData(noteIdx: 0, chord: 'C', page: 1),
        ChordData(noteIdx: 1, chord: 'Em', page: 1),
        ChordData(noteIdx: 2, chord: 'G', page: 1),
        ChordData(noteIdx: 3, chord: 'Em', page: 1),
      ],
    };

    expect(ChordService.detectFamilyChord(chords), 'Em');
  });

  test('keeps slash bass in display-key coordinates like gyschordweb', () {
    expect(
      ChordService.transposeChord(
        'C/G',
        0,
        baseTransposeOffset: 3,
        accidentalMode: ChordService.accidentalFlat,
      ),
      'Eb/G',
    );
  });

  test(
    'normalizes chord extension accidentals for display like gyschordweb',
    () {
      expect(
        ChordService.formatChordForDisplay(
          'C7b9',
          accidentalMode: ChordService.accidentalFlat,
        ),
        'C7♭9',
      );
      expect(
        ChordService.formatChordForDisplay(
          'C7#11',
          accidentalMode: ChordService.accidentalSharp,
        ),
        'C7♯11',
      );
    },
  );

  test('parses gyschordweb note-aligned json using page map keys', () {
    const json = '''
{
  "version": 2,
  "type": "note-aligned",
  "pages": {
    "2": [
      { "noteIdx": -1, "chord": "C" },
      { "noteIdx": 99999, "chord": "G" }
    ]
  }
}
''';

    final chords = ChordService.parseChordJson(json);

    expect(chords.keys, [2]);
    expect(chords[2]!.first.noteIdx, ChordSpecialIndices.before);
    expect(chords[2]!.first.page, 2);
    expect(chords[2]!.last.noteIdx, ChordSpecialIndices.after);
  });

  test('encodes note-aligned json compatible with gyschordweb', () {
    const chords = {
      1: [
        ChordData(noteIdx: 2, chord: 'Am', page: 1),
        ChordData(noteIdx: 0, chord: 'C', page: 1),
      ],
    };

    final decoded = ChordService.parseChordJson(
      ChordService.encodeChordJson(chords),
    );

    expect(decoded[1]!.map((chord) => chord.noteIdx), [0, 2]);
    expect(decoded[1]!.map((chord) => chord.chord), ['C', 'Am']);
  });

  test('maps pdf key notation and aligns chord family to pdf key', () {
    expect(ChordService.parsePdfKeyToSemitone('C'), 0);
    expect(ChordService.parsePdfKeyToSemitone('Bes'), 10);
    expect(ChordService.parsePdfKeyToSemitone('Fis'), 6);
    expect(ChordService.parsePdfKeyToSemitone('H'), 11);

    expect(
      ChordService.calculateBaseTransposeOffset(pdfKey: 'F', familyChord: 'C'),
      5,
    );
    expect(
      ChordService.formatChordForDisplay(
        'C',
        baseTransposeOffset: 5,
        accidentalMode: ChordService.accidentalFlat,
      ),
      'F',
    );
  });

  test('infers accidental mode from PDF key notation', () {
    expect(
      ChordService.preferredAccidentalModeForKey('Bes'),
      ChordService.accidentalFlat,
    );
    expect(
      ChordService.preferredAccidentalModeForKey('Fis'),
      ChordService.accidentalSharp,
    );
    expect(
      ChordService.preferredAccidentalModeForKey(
        'B',
        fallback: ChordService.accidentalSharp,
      ),
      ChordService.accidentalSharp,
    );
  });
}

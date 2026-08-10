import 'package:flutter_test/flutter_test.dart';

import 'package:church/data/services/chord_service.dart';
import 'package:church/data/services/chord_text_layout.dart';

void main() {
  group('chordsForVerse', () {
    test('returns empty slice for empty input', () {
      expect(chordsForVerse(const [], 0, 3), isEmpty);
    });

    test('distributes chords proportionally across verses', () {
      final chords = List.generate(
        12,
        (i) => ChordData(noteIdx: i, chord: 'C', page: 1),
      );
      final v0 = chordsForVerse(chords, 0, 3);
      final v1 = chordsForVerse(chords, 1, 3);
      final v2 = chordsForVerse(chords, 2, 3);
      expect(v0.length, 4);
      expect(v1.length, 4);
      expect(v2.length, 4);
      expect(v0.first.noteIdx, 0);
      expect(v1.first.noteIdx, 4);
      expect(v2.first.noteIdx, 8);
      expect(v0.map((c) => c.noteIdx), [0, 1, 2, 3]);
    });

    test('handles more verses than chords', () {
      final chords = [
        ChordData(noteIdx: 0, chord: 'G', page: 1),
        ChordData(noteIdx: 5, chord: 'C', page: 1),
      ];
      expect(chordsForVerse(chords, 0, 5), isEmpty);
      expect(chordsForVerse(chords, 2, 5), [chords[0]]);
      expect(chordsForVerse(chords, 4, 5), [chords[1]]);
    });

    test('clamps out-of-range verse index', () {
      final chords = [
        ChordData(noteIdx: 0, chord: 'C', page: 1),
        ChordData(noteIdx: 1, chord: 'G', page: 1),
      ];
      expect(chordsForVerse(chords, 9, 2).length, 1);
    });
  });

  group('distributeChordsToLines', () {
    test('returns one empty list per line for empty chords', () {
      final result = distributeChordsToLines(const [], 4);
      expect(result.length, 4);
      expect(result.every((line) => line.isEmpty), isTrue);
    });

    test('distributes chords to lines in note order', () {
      final chords = List.generate(
        8,
        (i) => ChordData(noteIdx: i, chord: 'C', page: 1),
      );
      final result = distributeChordsToLines(chords, 4);
      expect(result.map((line) => line.length).toList(), [2, 2, 2, 2]);
      expect(result[0].map((c) => c.noteIdx).toList(), [0, 1]);
      expect(result[3].map((c) => c.noteIdx).toList(), [6, 7]);
    });

    test('sorts unsorted note indexes before distribution', () {
      final chords = [
        ChordData(noteIdx: 9, chord: 'F', page: 1),
        ChordData(noteIdx: 3, chord: 'Am', page: 1),
      ];
      final result = distributeChordsToLines(chords, 6);
      final flat = result.expand((line) => line).toList();
      expect(flat.map((c) => c.noteIdx), [3, 9]);
      expect(result[0].single.noteIdx, 3);
      expect(result[3].single.noteIdx, 9);
    });
  });

  group('fallbackPlacementsForLine', () {
    test('keeps one chord anchored at line start', () {
      final placements = fallbackPlacementsForLine([
        ChordData(noteIdx: 7, chord: 'C', page: 1),
      ]);
      expect(placements.single.position, 0);
    });

    test('preserves relative note-index spacing', () {
      final placements = fallbackPlacementsForLine([
        ChordData(noteIdx: 10, chord: 'C', page: 1),
        ChordData(noteIdx: 12, chord: 'F', page: 1),
        ChordData(noteIdx: 20, chord: 'G', page: 1),
      ]);
      expect(placements[0].position, 0);
      expect(placements[1].position, closeTo(0.2, 0.0001));
      expect(placements[2].position, 1);
    });
  });

  group('chordFractionInLine', () {
    test('anchors one chord at line start', () {
      expect(chordFractionInLine(0, 1), 0);
    });

    test('uses full line span for two chord anchors', () {
      expect(chordFractionInLine(0, 2), 0);
      expect(chordFractionInLine(1, 2), 1);
    });

    test('returns 0 for empty line', () {
      expect(chordFractionInLine(0, 0), 0);
    });
  });
}

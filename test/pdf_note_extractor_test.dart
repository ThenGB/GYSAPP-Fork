import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart';

import 'package:church/data/services/pdf_note_extractor.dart';

// We test the algorithm with synthetic PdfPageRawText constructed manually,
// since we cannot load real PDF files in unit tests.
//
// PdfRect uses PDF coordinate system: origin at bottom-left, Y-axis pointing up.
// So top >= bottom always. A rect at "visual row y=100..110 on a 600pt page" is:
//   bottom = 600 - 110 = 490, top = 600 - 100 = 500  →  PdfRect(left, 500, right, 490)
//
// NOTE: extractNotePositions stores RAW baseline Y positions (no offset).
// The badge renderer applies NOTE_CHORD_Y_OFFSET_PCT=2.5 separately at render time.
// xPct = centerX / pageWidth * 100
// yPct = (1 - bottom / pageHeight) * 100   [bottom = baseline ≈ rect.bottom]

void main() {
  group('PdfNoteExtractor', () {
    test('returns empty map for empty text', () {
      final raw = _makeRawText('', []);
      final result = extractNotePositions(raw, 595, 842);
      expect(result, isEmpty);
    });

    test('returns empty map when charRects length mismatches text length', () {
      // If the API gives us inconsistent data, we should return empty safely.
      // '12' = 2 chars, but only 1 rect → mismatch → empty
      final raw = _makeRawText('12', [_rect(0, 10, 8, 0)]); // 2 chars, 1 rect
      final result = extractNotePositions(raw, 400, 600);
      expect(result, isEmpty);
    });

    test('extracts note positions from two rows of notes', () {
      // Page 400x600 pts.
      // Row 1: notes '1','2','3' visually at rows y=100..110 from top.
      //   In PDF coords (origin bottom-left): bottom = 600-110=490, top = 600-100=500
      // Row 2: notes '5','6','7' visually at y=200..210 from top.
      //   In PDF coords: bottom = 600-210=390, top = 600-200=400
      // Each char: width=8, spaced 20pt apart starting at x=50
      const pageW = 400.0;
      const pageH = 600.0;

      final chars1 = ['1', '2', '3'];
      final chars2 = ['5', '6', '7'];
      final text = chars1.join() + chars2.join(); // "123567"
      final rects = [
        ...chars1.asMap().entries.map(
              (e) => _rect(50.0 + e.key * 20, 500, 58.0 + e.key * 20, 490),
            ),
        ...chars2.asMap().entries.map(
              (e) => _rect(50.0 + e.key * 20, 400, 58.0 + e.key * 20, 390),
            ),
      ];

      final positions = extractNotePositions(_makeRawText(text, rects), pageW, pageH);

      // Should produce 6 positions (noteIdx 0..5)
      expect(positions.length, 6);

      // Note 0: '1' centerX=54, baseline (bottom)=490
      // xPct = 54/400*100 = 13.5
      // yPct = (1 - 490/600)*100 = 18.33...  (NO extraction offset)
      expect(positions[0]!.xPct, closeTo(54 / 400 * 100, 0.1));
      expect(positions[0]!.yPct, closeTo((1.0 - 490 / 600) * 100, 0.1));

      // Note 3: '5' in row 2, centerX=54, baseline=390
      expect(positions[3]!.xPct, closeTo(54 / 400 * 100, 0.1));
      expect(positions[3]!.yPct, closeTo((1.0 - 390 / 600) * 100, 0.1));
    });

    test('filters out rows with fewer than 2 digit notes (single note row)', () {
      // Single note character — below the 2-digit threshold → empty
      // PDF coords: top=510, bottom=500 for a note visually at y=90..100 on 600pt page
      final raw = _makeRawText('1', [_rect(50, 510, 58, 500)]);
      expect(extractNotePositions(raw, 400, 600), isEmpty);
    });

    test('notes in same row are ordered left to right', () {
      // Two notes in the same row, given in reverse x order in the input.
      // Extractor should sort them left-to-right so noteIdx 0 < noteIdx 1.
      // PDF coords: visually at y=100..110 → bottom=490, top=500
      const pageW = 400.0;
      const pageH = 600.0;
      final text = '21'; // right-then-left in x when constructed
      final rects = [
        _rect(70, 500, 78, 490), // '2' at x=70 (right)
        _rect(50, 500, 58, 490), // '1' at x=50 (left)
      ];
      final positions =
          extractNotePositions(_makeRawText(text, rects), pageW, pageH);

      expect(positions.length, 2);
      // noteIdx 0 should be the leftmost note (x=50, center=54)
      expect(positions[0]!.xPct, closeTo(54 / 400 * 100, 0.1));
      // noteIdx 1 should be the rightmost note (x=70, center=74)
      expect(positions[1]!.xPct, closeTo(74 / 400 * 100, 0.1));
    });

    test('yPct is clamped to minimum 1.0 even for notes at top of page', () {
      // Notes visually at y=0..5 from top (very top of page).
      // PDF coords: bottom=595, top=600 for y=0..5 on 600pt page
      const pageW = 400.0;
      const pageH = 600.0;
      final text = '12';
      final rects = [
        _rect(50, 600, 58, 595), // '1' at very top, fontSize=5
        _rect(70, 600, 78, 595), // '2' at very top, fontSize=5
      ];
      final positions =
          extractNotePositions(_makeRawText(text, rects), pageW, pageH);

      // Both notes pass (2 digit notes in one row)
      expect(positions.length, 2);
      // yPct raw = (1 - 595/600)*100 ≈ 0.83, clamped to 1.0
      expect(positions[0]!.yPct, greaterThanOrEqualTo(1.0));
      expect(positions[1]!.yPct, greaterThanOrEqualTo(1.0));
    });

    test('ignores non-note text when font size differs from dominant', () {
      // Numbers mixed in with letter text (like song lyrics "Verse 1") will have
      // the SAME font size as lyrics → won't match dominant note font size.
      // Pure note rows have a different (dominant) font size.
      // In this test: note rows have fontSize=10, lyrics have fontSize=12.
      const pageW = 400.0;
      const pageH = 600.0;

      // Pure note row: fontSize=10 (dominant), bottom=490, top=500
      // Lyric row with mixed numbers: fontSize=12, different → filtered out
      final notesText = '123'; // note-only chars
      final lyricsText = 'A1B'; // mixed lyrics + number

      final text = notesText + lyricsText;
      final rects = [
        // note chars at fontSize=10 (bottom=490, top=500)
        _rect(10, 500, 18, 490),
        _rect(30, 500, 38, 490),
        _rect(50, 500, 58, 490),
        // lyric chars at fontSize=12 (bottom=300, top=312)
        _rect(10, 312, 18, 300),
        _rect(30, 312, 38, 300),
        _rect(50, 312, 58, 300),
      ];

      final positions = extractNotePositions(_makeRawText(text, rects), pageW, pageH);
      // Should have 3 positions from the note row only
      expect(positions.length, 3);
    });
  });
}

PdfPageRawText _makeRawText(String text, List<PdfRect> rects) {
  return PdfPageRawText(text, rects);
}

/// Create a PdfRect in PDF coordinate system.
/// [l] = left, [t] = top (must be >= b), [r] = right, [b] = bottom.
PdfRect _rect(double l, double t, double r, double b) => PdfRect(l, t, r, b);

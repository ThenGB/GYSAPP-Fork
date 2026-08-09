import 'dart:math' as math;

import 'package:collection/collection.dart';

import 'chord_service.dart';
import 'pdf_note_extractor.dart';

/// Text-mode chord placement helpers.
///
/// Two strategies are available:
///
/// 1. **Note-aligned (preferred)** — mirrors gyschordweb's lyrics-viewer.js.
///    The chord data is note-aligned to the PDF page (each [ChordData] carries
///    a `noteIdx`).  The PDF page's own layout is used to find, for every
///    note row, the lyric text line directly below it; a chord's horizontal
///    position is then `(note.xPct - line.startPct) / line.widthPct`, i.e. the
///    chord lands exactly above the note (which sits on the matching syllable)
///    in the text view too.
/// 2. **Proportional fallback** — distributes a song's chords across its
///    lyric lines in noteIdx order using proportional slices.  Used only when
///    the PDF layout cannot be extracted (missing PDF, extraction failure).
///
/// The matching of JSON verse lines to PDF lyric lines follows gyschordweb:
/// normalized text comparison (verse labels like "1." / "Reff." stripped),
/// then a per-line-index fallback (hymns repeat the same melody for every
/// verse, so line *i* of any verse uses the chords of line *i* of the verse
/// whose text matched the PDF).

/// One chord placed at a horizontal fraction (0.0–1.0) of its lyric line.
class TextChordPlacement {
  final String chord;
  final double position;

  const TextChordPlacement({required this.chord, required this.position});

  /// Position is expected in 0.0–1.0; clamp defensively.
  double get safePosition => position.clamp(0.0, 1.0);
}

/// A PDF lyric line with the chords that belong above it.
class ChordedTextLine {
  final String text;
  final List<TextChordPlacement> chords;

  const ChordedTextLine({required this.text, required this.chords});
}

/// Builds chorded lines for one PDF page: for each note row, finds the
/// closest lyric line below it (within [maxRowGapPct]) and places the page's
/// chords that fall in that row's note range at their x-position relative to
/// the lyric line's text extent.
///
/// Mirrors gyschordweb's `buildChordedLines`:
/// ```
/// pos = clamp((note.xPct - lyr.startPct) / lyr.widthPct, 0, 1)
/// ```
List<ChordedTextLine> buildChordedLines({
  required List<NoteInfo> noteInfos,
  required List<PdfLyricLine> lyricLines,
  required List<ChordData> entries,
  double maxRowGapPct = 45,
}) {
  if (entries.isEmpty || noteInfos.isEmpty || lyricLines.isEmpty) {
    return const [];
  }

  // Group notes into rows by rowY (the extractor already assigns one rowY per
  // visual music row; sort by rowY descending = top to bottom).
  final rows = <({double rowY, int firstIdx, int lastIdx})>[];
  noteInfos.sort((a, b) => b.rowY.compareTo(a.rowY));
  for (final info in noteInfos) {
    final last = rows.isEmpty ? null : rows.last;
    if (last != null && (last.rowY - info.rowY).abs() < 2.0) {
      rows[rows.length - 1] = (
        rowY: last.rowY,
        firstIdx: math.min(last.firstIdx, info.idx),
        lastIdx: math.max(last.lastIdx, info.idx),
      );
    } else {
      rows.add((rowY: info.rowY, firstIdx: info.idx, lastIdx: info.idx));
    }
  }

  // Find, for each note row, the closest lyric line strictly below it.
  final out = <ChordedTextLine>[];
  for (final row in rows) {
    PdfLyricLine? lyric;
    double bestDist = double.infinity;
    for (final line in lyricLines) {
      if (line.y < row.rowY && row.rowY - line.y <= maxRowGapPct) {
        final d = row.rowY - line.y;
        if (d < bestDist) {
          bestDist = d;
          lyric = line;
        }
      }
    }
    if (lyric == null) continue;

    final placements = <TextChordPlacement>[];
    for (final entry in entries) {
      if (entry.noteIdx < row.firstIdx || entry.noteIdx > row.lastIdx) continue;
      final note = noteInfos
          .where((n) => n.idx == entry.noteIdx)
          .firstOrNull;
      if (note == null) continue;
      final pos = ((note.xPct - lyric.startPct) / lyric.widthPct).clamp(0.0, 1.0);
      placements.add(TextChordPlacement(chord: entry.chord, position: pos));
    }
    if (placements.isEmpty) continue;
    out.add(ChordedTextLine(text: lyric.text, chords: placements));
  }
  return out;
}

String _normalizeLine(String s) {
  return s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

/// Strips verse labels ("1.", "Reff.", "(2)", "Ulangan", …) at the start of a
/// line.  Mirrors gyschordweb's `stripVerseLabel`.
String stripVerseLabel(String s) {
  return s.replaceFirst(
    RegExp(
      r'^\s*(?:reff?|refrain|chorus|ulangan|[(（]?[0-9]+[)）]?[.\s]*)+',
      caseSensitive: false,
    ),
    '',
  );
}

/// Finds the chorded PDF line that best matches [jsonLine], mirroring
/// gyschordweb's `findChordedLine`: exact match first, then containment and
/// common-prefix scoring; only matches with a score >= 0.6 are accepted.
ChordedTextLine? findChordedLine(String jsonLine, List<ChordedTextLine> lines) {
  final target = _normalizeLine(stripVerseLabel(jsonLine));
  if (target.isEmpty || lines.isEmpty) return null;

  ChordedTextLine? best;
  var bestScore = 0.0;
  for (final line in lines) {
    final cand = _normalizeLine(stripVerseLabel(line.text));
    if (cand.isEmpty) continue;
    if (cand == target) return line;
    double score;
    if (cand.contains(target) || target.contains(cand)) {
      final lenRatio =
          math.min(cand.length, target.length) / math.max(cand.length, target.length);
      score = 0.85 * lenRatio;
    } else {
      var j = 0;
      while (j < cand.length && j < target.length && cand[j] == target[j]) {
        j++;
      }
      score = j / math.max(cand.length, target.length);
    }
    if (score > bestScore) {
      bestScore = score;
      best = line;
    }
  }
  return bestScore >= 0.6 ? best : null;
}

/// Per-line-index fallback map, mirroring gyschordweb's
/// `buildVerseChordFallback`: hymn melodies repeat across verses, so line *i*
/// of any verse should use the chords of line *i* of the verse whose text
/// matched the PDF.  `byIndex[i]` holds the chorded line for line index *i*.
List<ChordedTextLine?> buildVerseChordFallback(
  List<String> verses,
  List<ChordedTextLine> allLines,
) {
  final byIndex = <ChordedTextLine?>[];
  if (verses.isEmpty || allLines.isEmpty) return byIndex;

  for (final verse in verses) {
    final lines = verse
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    for (var i = 0; i < lines.length; i++) {
      if (byIndex.length > i && byIndex[i] != null) continue;
      final match = findChordedLine(lines[i], allLines);
      if (match != null) {
        while (byIndex.length <= i) {
          byIndex.add(null);
        }
        byIndex[i] = match;
      }
    }
  }
  return byIndex;
}

/// Resolves the chorded line for [jsonLine] at line index [lineIndex],
/// preferring a direct text match and falling back to the by-index map.
ChordedTextLine? resolveChordedLineForVerseLine(
  String jsonLine,
  int lineIndex,
  List<ChordedTextLine> allLines,
  List<ChordedTextLine?> byIndexFallback,
) {
  final direct = findChordedLine(jsonLine, allLines);
  if (direct != null) return direct;
  if (lineIndex < byIndexFallback.length) {
    return byIndexFallback[lineIndex];
  }
  return null;
}

// ---------------------------------------------------------------------------
// Proportional fallback (kept for songs without extractable PDF layout)
// ---------------------------------------------------------------------------

/// Returns the slice of [allChords] that belongs to verse [verseIndex] of
/// [totalVerses], distributing the song's total chords proportionally.
List<ChordData> chordsForVerse(
  List<ChordData> allChords,
  int verseIndex,
  int totalVerses,
) {
  if (allChords.isEmpty || totalVerses <= 0) return allChords;
  final safeVerse = verseIndex.clamp(0, totalVerses - 1);
  final start = (safeVerse * allChords.length) ~/ totalVerses;
  final end = ((safeVerse + 1) * allChords.length) ~/ totalVerses;
  final from = start.clamp(0, allChords.length);
  final to = end.clamp(from, allChords.length);
  return allChords.sublist(from, to);
}

/// Distributes [chords] (already sliced for the current verse) across
/// [lineCount] lyric lines in noteIdx order, returning one list per line.
List<List<ChordData>> distributeChordsToLines(
  List<ChordData> chords,
  int lineCount,
) {
  final result = List<List<ChordData>>.generate(
    lineCount,
    (_) => <ChordData>[],
  );
  if (chords.isEmpty || lineCount <= 0) return result;
  for (var i = 0; i < chords.length; i++) {
    final line = (i * lineCount ~/ chords.length).clamp(0, lineCount - 1);
    result[line].add(chords[i]);
  }
  return result;
}

/// Horizontal position (0.0–1.0) of the chord at [indexInLine] among
/// [lineCount] chords in the same lyric line (centered per slot).
double chordFractionInLine(int indexInLine, int lineCount) {
  if (lineCount <= 0) return 0.0;
  return (indexInLine + 0.5) / lineCount;
}

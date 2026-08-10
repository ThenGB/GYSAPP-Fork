import 'dart:math' as math;

import 'package:collection/collection.dart';

import 'chord_service.dart';
import 'pdf_note_extractor.dart';

/// Text-mode chord placement helpers.
///
/// The primary path mirrors gyschordweb: PDF note positions are projected onto
/// the lyric line underneath them, then converted into a 0..1 horizontal
/// anchor. When PDF layout cannot be extracted, the fallback still preserves
/// the relative noteIdx spacing instead of simply distributing chord labels at
/// equal distances.
class TextChordPlacement {
  const TextChordPlacement({required this.chord, required this.position});

  final String chord;
  final double position;

  double get safePosition => position.clamp(0.0, 1.0).toDouble();
}

class ChordedTextLine {
  const ChordedTextLine({required this.text, required this.chords});

  final String text;
  final List<TextChordPlacement> chords;
}

List<ChordedTextLine> buildChordedLines({
  required List<NoteInfo> noteInfos,
  required List<PdfLyricLine> lyricLines,
  required List<ChordData> entries,
  double maxRowGapPct = 45,
}) {
  if (entries.isEmpty || noteInfos.isEmpty || lyricLines.isEmpty) {
    return const [];
  }

  final sortedNotes = List<NoteInfo>.from(noteInfos)
    ..sort((a, b) => b.rowY.compareTo(a.rowY));
  final rows = <({double rowY, int firstIdx, int lastIdx})>[];
  for (final info in sortedNotes) {
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

  final out = <ChordedTextLine>[];
  for (final row in rows) {
    PdfLyricLine? lyric;
    var bestDist = double.infinity;
    for (final line in lyricLines) {
      if (line.y < row.rowY && row.rowY - line.y <= maxRowGapPct) {
        final distance = row.rowY - line.y;
        if (distance < bestDist) {
          bestDist = distance;
          lyric = line;
        }
      }
    }
    if (lyric == null || lyric.widthPct.abs() < 0.001) continue;

    final placements = <TextChordPlacement>[];
    for (final entry in entries) {
      if (entry.noteIdx < row.firstIdx || entry.noteIdx > row.lastIdx) continue;
      final note = sortedNotes.firstWhereOrNull((note) => note.idx == entry.noteIdx);
      if (note == null) continue;
      final position = ((note.xPct - lyric.startPct) / lyric.widthPct)
          .clamp(0.0, 1.0)
          .toDouble();
      placements.add(
        TextChordPlacement(chord: entry.chord, position: position),
      );
    }
    if (placements.isEmpty) continue;
    placements.sort((a, b) => a.position.compareTo(b.position));
    out.add(ChordedTextLine(text: lyric.text, chords: placements));
  }
  return out;
}

/// Keep every Unicode letter/number intact and only remove separators and
/// punctuation that are irrelevant for line matching. The previous
/// `[^a-z0-9]` normalizer silently erased non-ASCII text and accented letters.
String _normalizeLine(String value) {
  return value
      .toLowerCase()
      .replaceAll(
        RegExp(r'''[\s\.,;:!?"'`~@#\$%\^&*+=_|/\\<>\-–—…，。！？；：、（）()\[\]{}]+'''),
        '',
      );
}

String stripVerseLabel(String value) {
  return value.replaceFirst(
    RegExp(
      r'^\s*(?:reff?|refrain|chorus|ulangan|[(（]?[0-9]+[)）]?[.\s]*)+',
      caseSensitive: false,
    ),
    '',
  );
}

ChordedTextLine? findChordedLine(
  String jsonLine,
  List<ChordedTextLine> lines,
) {
  final target = _normalizeLine(stripVerseLabel(jsonLine));
  if (target.isEmpty || lines.isEmpty) return null;

  ChordedTextLine? best;
  var bestScore = 0.0;
  for (final line in lines) {
    final candidate = _normalizeLine(stripVerseLabel(line.text));
    if (candidate.isEmpty) continue;
    if (candidate == target) return line;

    double score;
    if (candidate.contains(target) || target.contains(candidate)) {
      final ratio = math.min(candidate.length, target.length) /
          math.max(candidate.length, target.length);
      score = 0.85 * ratio;
    } else {
      var commonPrefix = 0;
      while (commonPrefix < candidate.length &&
          commonPrefix < target.length &&
          candidate[commonPrefix] == target[commonPrefix]) {
        commonPrefix++;
      }
      score = commonPrefix / math.max(candidate.length, target.length);
    }
    if (score > bestScore) {
      bestScore = score;
      best = line;
    }
  }
  return bestScore >= 0.6 ? best : null;
}

List<ChordedTextLine?> buildVerseChordFallback(
  List<String> verses,
  List<ChordedTextLine> allLines,
) {
  final byIndex = <ChordedTextLine?>[];
  if (verses.isEmpty || allLines.isEmpty) return byIndex;

  for (final verse in verses) {
    final lines = verse
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    for (var index = 0; index < lines.length; index++) {
      if (byIndex.length > index && byIndex[index] != null) continue;
      final match = findChordedLine(lines[index], allLines);
      if (match == null) continue;
      while (byIndex.length <= index) {
        byIndex.add(null);
      }
      byIndex[index] = match;
    }
  }
  return byIndex;
}

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

List<ChordData> chordsForVerse(
  List<ChordData> allChords,
  int verseIndex,
  int totalVerses,
) {
  if (allChords.isEmpty || totalVerses <= 0) return allChords;
  final safeVerse = verseIndex.clamp(0, totalVerses - 1).toInt();
  final start = (safeVerse * allChords.length) ~/ totalVerses;
  final end = ((safeVerse + 1) * allChords.length) ~/ totalVerses;
  final from = start.clamp(0, allChords.length).toInt();
  final to = end.clamp(from, allChords.length).toInt();
  return allChords.sublist(from, to);
}

List<List<ChordData>> distributeChordsToLines(
  List<ChordData> chords,
  int lineCount,
) {
  final result = List<List<ChordData>>.generate(
    lineCount,
    (_) => <ChordData>[],
  );
  if (chords.isEmpty || lineCount <= 0) return result;

  final sorted = List<ChordData>.from(chords)
    ..sort((a, b) => a.noteIdx.compareTo(b.noteIdx));
  for (var index = 0; index < sorted.length; index++) {
    final line = (index * lineCount ~/ sorted.length)
        .clamp(0, lineCount - 1)
        .toInt();
    result[line].add(sorted[index]);
  }
  return result;
}

/// Create fallback anchors for a single lyric line using noteIdx distance.
/// This is closer to the web renderer than equal-width chord slots: a cluster
/// of chords attached to nearby notes remains clustered in text mode.
List<TextChordPlacement> fallbackPlacementsForLine(List<ChordData> chords) {
  if (chords.isEmpty) return const [];
  final sorted = List<ChordData>.from(chords)
    ..sort((a, b) => a.noteIdx.compareTo(b.noteIdx));
  if (sorted.length == 1) {
    return [TextChordPlacement(chord: sorted.first.chord, position: 0)];
  }

  final normal = sorted.where((chord) => chord.noteIdx >= 0).toList();
  if (normal.length < 2) {
    return [
      for (var index = 0; index < sorted.length; index++)
        TextChordPlacement(
          chord: sorted[index].chord,
          position: index / math.max(1, sorted.length - 1),
        ),
    ];
  }

  final minIndex = normal.first.noteIdx;
  final maxIndex = normal.last.noteIdx;
  final span = math.max(1, maxIndex - minIndex);
  return [
    for (final chord in sorted)
      TextChordPlacement(
        chord: chord.chord,
        position: chord.noteIdx < 0
            ? 0.0
            : ((chord.noteIdx - minIndex) / span)
                .clamp(0.0, 1.0)
                .toDouble(),
      ),
  ];
}

/// Backwards-compatible helper retained for older callers/tests.
double chordFractionInLine(int indexInLine, int lineCount) {
  if (lineCount <= 0) return 0.0;
  if (lineCount == 1) return 0.0;
  return indexInLine / (lineCount - 1);
}

import '../../../data/services/chord_service.dart';

/// Text-mode chord placement helpers.
///
/// The chord data is note-aligned to the PDF page (each [ChordData] carries a
/// `noteIdx`), while text mode only has plain lyric lines.  These helpers
/// distribute a song's chords across its lyric lines in noteIdx order using
/// proportional slices — the standard chord-sheet approach used by most
/// hymn/lyrics apps when no note-to-syllable mapping is available.  This is
/// deterministic and requires no PDF/note extraction, so it behaves the same
/// on every device.

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

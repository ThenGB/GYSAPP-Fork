import 'dart:convert';
import 'dart:developer';

/// Represents a single chord placement on a page.
class ChordData {
  final int noteIdx;
  final String chord;
  final int page;

  const ChordData({
    required this.noteIdx,
    required this.chord,
    required this.page,
  });

  factory ChordData.fromJson(Map<String, dynamic> json) {
    return ChordData(
      noteIdx: json['noteIdx'] as int,
      chord: json['chord'] as String,
      page: json['page'] as int? ?? 1,
    );
  }

  ChordData withTransposedChord(String newChord) {
    return ChordData(noteIdx: noteIdx, chord: newChord, page: page);
  }
}

/// Service for parsing and transposing chord data from JSON.
class ChordService {
  static const List<String> _notesSharp = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];
  static const List<String> _notesFlat = [
    'C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'
  ];

  /// Parse chord JSON string into a map of page number -> list of chords.
  static Map<int, List<ChordData>> parseChordJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final pages = data['pages'] as Map<String, dynamic>;
      final result = <int, List<ChordData>>{};

      pages.forEach((pageNumStr, chordsList) {
        final pageNum = int.parse(pageNumStr);
        final chords = (chordsList as List<dynamic>).map((c) {
          return ChordData.fromJson(c as Map<String, dynamic>);
        }).toList();
        result[pageNum] = chords;
      });

      return result;
    } catch (e) {
      log('Error parsing chord JSON: $e');
      return {};
    }
  }

  /// Transpose a chord string by a number of semitones.
  static String transposeChord(String chord, int semitones) {
    if (semitones == 0) return chord;

    // Parse root note and suffix (e.g., "Am7" -> "A" + "m7")
    String root = '';
    String suffix = '';

    if (chord.length >= 2 && (chord[1] == '#' || chord[1] == 'b')) {
      root = chord.substring(0, 2);
      suffix = chord.substring(2);
    } else {
      root = chord.substring(0, 1);
      suffix = chord.substring(1);
    }

    // Determine if we use sharp or flat notation based on input
    final useSharp = !_notesFlat.contains(root) || _notesSharp.contains(root);
    final noteList = useSharp ? _notesSharp : _notesFlat;

    final currentIndex = noteList.indexOf(root);
    if (currentIndex == -1) return chord; // Unknown root, return as-is

    var newIndex = (currentIndex + semitones) % 12;
    if (newIndex < 0) newIndex += 12;

    return noteList[newIndex] + suffix;
  }

  /// Transpose all chords in a map by a number of semitones.
  static Map<int, List<ChordData>> transposeAll(
    Map<int, List<ChordData>> chords,
    int semitones,
  ) {
    if (semitones == 0) return chords;

    final result = <int, List<ChordData>>{};
    chords.forEach((pageNum, chordList) {
      result[pageNum] = chordList.map((c) {
        return c.withTransposedChord(transposeChord(c.chord, semitones));
      }).toList();
    });
    return result;
  }
}


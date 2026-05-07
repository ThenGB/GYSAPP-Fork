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

class _ParsedChord {
  final int semitone;
  final String suffix;
  final int? bassSemitone;
  final String suffixAfter;

  const _ParsedChord({
    required this.semitone,
    required this.suffix,
    this.bassSemitone,
    this.suffixAfter = '',
  });
}

class _ParsedBass {
  final String suffixBefore;
  final int? bassSemitone;
  final String suffixAfter;

  const _ParsedBass({
    required this.suffixBefore,
    this.bassSemitone,
    this.suffixAfter = '',
  });
}

/// Service for parsing, detecting, normalizing, and transposing chord data.
class ChordService {
  static const String accidentalSharp = 'sharp';
  static const String accidentalFlat = 'flat';

  static const List<String> _notesSharp = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B',
  ];
  static const List<String> _notesFlat = [
    'C',
    'Db',
    'D',
    'Eb',
    'E',
    'F',
    'Gb',
    'G',
    'Ab',
    'A',
    'Bb',
    'B',
  ];
  static const Map<String, int> _naturalNoteIndex = {
    'C': 0,
    'D': 2,
    'E': 4,
    'F': 5,
    'G': 7,
    'A': 9,
    'B': 11,
  };
  static const Map<String, String> _numberToNote = {
    '1': 'C',
    '2': 'D',
    '3': 'E',
    '4': 'F',
    '5': 'G',
    '6': 'A',
    '7': 'B',
  };

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

  static String transposeChord(
    String chord,
    int semitones, {
    String accidentalMode = accidentalSharp,
  }) {
    return formatChordForDisplay(
      chord,
      transpose: semitones,
      accidentalMode: accidentalMode,
    );
  }

  static String normalizeChord(
    String chord, {
    String accidentalMode = accidentalSharp,
  }) {
    return formatChordForDisplay(chord, accidentalMode: accidentalMode);
  }

  static String formatChordForDisplay(
    String chord, {
    int transpose = 0,
    String accidentalMode = accidentalSharp,
  }) {
    final parsed = _parseChordToken(chord);
    if (parsed == null) return chord.trim();

    final notes = accidentalMode == accidentalFlat ? _notesFlat : _notesSharp;
    final root = notes[_wrapSemitone(parsed.semitone + transpose)];
    final suffix = parsed.suffix.replaceAll('♯', '#').replaceAll('♭', 'b');
    final bass = parsed.bassSemitone == null
        ? ''
        : '/${notes[_wrapSemitone(parsed.bassSemitone! + transpose)]}'
            '${parsed.suffixAfter}';

    return '$root$suffix$bass';
  }

  static String? detectFamilyChord(Map<int, List<ChordData>> chords) {
    final allChords = <String>[];
    final sortedPages = chords.keys.toList()..sort();
    for (final page in sortedPages) {
      final entries = List<ChordData>.from(chords[page] ?? [])
        ..sort((a, b) => a.noteIdx.compareTo(b.noteIdx));
      for (final entry in entries) {
        if (entry.chord.trim().isNotEmpty) allChords.add(entry.chord.trim());
      }
    }
    if (allChords.isEmpty) return null;

    String? rootOf(String chordText) {
      final parsed = _parseChordToken(chordText);
      if (parsed == null) return null;
      final isMinor =
          RegExp(r'^[A-Ga-g1-7][#♯b♭]?(min|m(?!aj))').hasMatch(chordText);
      return '${_notesSharp[parsed.semitone]}${isMinor ? 'm' : ''}';
    }

    final roots = allChords.map(rootOf).whereType<String>().toList();
    if (roots.isEmpty) return null;
    final firstRoot = roots.first;
    final lastRoot = roots.last;
    if (firstRoot == lastRoot) return firstRoot;

    final counts = <String, int>{};
    var mostFrequent = firstRoot;
    var maxCount = 0;
    for (final root in roots) {
      final count = (counts[root] ?? 0) + 1;
      counts[root] = count;
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = root;
      }
    }
    return (counts[lastRoot] ?? 0) > 1 ? lastRoot : mostFrequent;
  }

  static int recommendedNaturalTranspose(String? familyChord) {
    if (familyChord == null) return 0;
    final parsed = _parseChordToken(familyChord);
    if (parsed == null) return 0;
    return {1, 3, 6, 8, 10}.contains(parsed.semitone) ? -1 : 0;
  }

  static Map<int, List<ChordData>> transposeAll(
    Map<int, List<ChordData>> chords,
    int semitones, {
    String accidentalMode = accidentalSharp,
  }) {
    if (semitones == 0 && accidentalMode == accidentalSharp) return chords;

    final result = <int, List<ChordData>>{};
    chords.forEach((pageNum, chordList) {
      result[pageNum] = chordList.map((c) {
        return c.withTransposedChord(
          transposeChord(
            c.chord,
            semitones,
            accidentalMode: accidentalMode,
          ),
        );
      }).toList();
    });
    return result;
  }

  static _ParsedChord? _parseChordToken(String chord) {
    final token = chord.trim();
    final match = RegExp(r'^([A-Ga-g1-7])([#♯b♭]?)(.*)$').firstMatch(token);
    if (match == null) return null;

    var root = match.group(1)!;
    final accidentalRaw = match.group(2) ?? '';
    final fullSuffix = match.group(3) ?? '';
    root = _numberToNote[root] ?? root.toUpperCase();

    var semitone = _naturalNoteIndex[root];
    if (semitone == null) return null;
    final accidental = accidentalRaw == '♭'
        ? 'b'
        : accidentalRaw == '♯'
            ? '#'
            : accidentalRaw;
    if (accidental == '#') semitone += 1;
    if (accidental == 'b') semitone -= 1;

    final bass = _parseSlashBass(fullSuffix);
    return _ParsedChord(
      semitone: _wrapSemitone(semitone),
      suffix: bass.suffixBefore,
      bassSemitone: bass.bassSemitone,
      suffixAfter: bass.suffixAfter,
    );
  }

  static _ParsedBass _parseSlashBass(String suffix) {
    final match = RegExp(r'^(.*)/([A-Ga-g])([#♯b♭]?)(.*)$').firstMatch(suffix);
    if (match == null) return _ParsedBass(suffixBefore: suffix);

    final root = match.group(2)!.toUpperCase();
    var semitone = _naturalNoteIndex[root];
    if (semitone == null) return _ParsedBass(suffixBefore: suffix);

    final accidentalRaw = match.group(3) ?? '';
    final accidental = accidentalRaw == '♭'
        ? 'b'
        : accidentalRaw == '♯'
            ? '#'
            : accidentalRaw;
    if (accidental == '#') semitone += 1;
    if (accidental == 'b') semitone -= 1;

    return _ParsedBass(
      suffixBefore: match.group(1) ?? '',
      bassSemitone: _wrapSemitone(semitone),
      suffixAfter: match.group(4) ?? '',
    );
  }

  static int _wrapSemitone(int value) {
    return ((value % 12) + 12) % 12;
  }
}

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
    int baseTransposeOffset = 0,
    String accidentalMode = accidentalSharp,
  }) {
    return formatChordForDisplay(
      chord,
      transpose: semitones,
      baseTransposeOffset: baseTransposeOffset,
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
    int baseTransposeOffset = 0,
    String accidentalMode = accidentalSharp,
  }) {
    final parsed = _parseChordToken(chord);
    if (parsed == null) return chord.trim();

    final notes = accidentalMode == accidentalFlat ? _notesFlat : _notesSharp;
    final root =
        notes[_wrapSemitone(parsed.semitone + transpose + baseTransposeOffset)];
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

  static int recommendedNaturalTranspose(
    String? familyChord, {
    int baseTransposeOffset = 0,
  }) {
    if (familyChord == null) return 0;
    final parsed = _parseChordToken(familyChord);
    if (parsed == null) return 0;
    final finalBaseSemi = _wrapSemitone(parsed.semitone + baseTransposeOffset);
    return {1, 3, 6, 8, 10}.contains(finalBaseSemi) ? -1 : 0;
  }

  static int? parsePdfKeyToSemitone(String? key) {
    if (key == null || key.trim().isEmpty) return null;
    final normalized = key.trim().toLowerCase().replaceFirst(RegExp(r'm$'), '');
    const keyMap = {
      'c': 0,
      'cis': 1,
      'des': 1,
      'db': 1,
      'c#': 1,
      'd': 2,
      'dis': 3,
      'es': 3,
      'eb': 3,
      'd#': 3,
      'e': 4,
      'f': 5,
      'fis': 6,
      'ges': 6,
      'gb': 6,
      'f#': 6,
      'g': 7,
      'gis': 8,
      'as': 8,
      'ab': 8,
      'g#': 8,
      'a': 9,
      'ais': 10,
      'bes': 10,
      'bb': 10,
      'a#': 10,
      'b': 11,
      'h': 11,
    };
    if (keyMap.containsKey(normalized)) return keyMap[normalized];
    final base = _naturalNoteIndex[normalized.substring(0, 1).toUpperCase()];
    if (base == null) return null;
    if (normalized.contains('#')) return _wrapSemitone(base + 1);
    if (normalized.contains('b')) return _wrapSemitone(base - 1);
    return base;
  }

  static int calculateBaseTransposeOffset({
    required String? pdfKey,
    required String? familyChord,
  }) {
    final pdfSemi = parsePdfKeyToSemitone(pdfKey);
    final chordSemi = _parseChordToken(familyChord ?? '')?.semitone;
    if (pdfSemi == null || chordSemi == null) return 0;
    var diff = (pdfSemi - chordSemi) % 12;
    if (diff > 6) diff -= 12;
    if (diff < -5) diff += 12;
    return diff;
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
            baseTransposeOffset: 0,
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

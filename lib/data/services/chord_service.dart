import 'dart:convert';
import 'dart:developer';

/// Represents a single chord placement on a page.
class ChordData {
  final int noteIdx;
  final String chord;
  final int page;
  final String? theme;
  final String? fillMode;

  const ChordData({
    required this.noteIdx,
    required this.chord,
    required this.page,
    this.theme,
    this.fillMode,
  });

  factory ChordData.fromJson(Map<String, dynamic> json) {
    return ChordData(
      noteIdx: (json['noteIdx'] as num).round(),
      chord: (json['chord'] as String).trim(),
      page: (json['page'] as num?)?.round() ?? 1,
      theme: json['theme'] as String?,
      fillMode: json['fillMode'] as String?,
    );
  }

  Map<String, dynamic> toJson({bool includePage = false}) {
    return {
      'noteIdx': noteIdx,
      'chord': chord,
      if (includePage) 'page': page,
      if (theme != null) 'theme': theme,
      if (fillMode != null) 'fillMode': fillMode,
    };
  }

  ChordData withTransposedChord(String newChord) {
    return ChordData(
      noteIdx: noteIdx,
      chord: newChord,
      page: page,
      theme: theme,
      fillMode: fillMode,
    );
  }
}

class ChordSpecialIndices {
  static const int before = -1;
  static const int after = 99999;
}

class ChordFillMode {
  static const String none = 'none';
  static const String soft = 'soft';
  static const String solid = 'solid';
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
      if (data.containsKey('version') && data['version'] != 2) return {};
      if (data.containsKey('type') && data['type'] != 'note-aligned') return {};
      final pages = data['pages'];
      if (pages is! Map<String, dynamic>) return {};
      final result = <int, List<ChordData>>{};

      pages.forEach((pageNumStr, chordsList) {
        final pageNum = int.parse(pageNumStr);
        if (chordsList is! List<dynamic>) return;
        final chords =
            chordsList
                .whereType<Map<String, dynamic>>()
                .map((c) => ChordData.fromJson({...c, 'page': pageNum}))
                .where((c) => c.chord.isNotEmpty)
                .toList()
              ..sort((a, b) => a.noteIdx.compareTo(b.noteIdx));
        if (chords.isNotEmpty) result[pageNum] = chords;
      });

      return result;
    } catch (e) {
      log('Error parsing chord JSON: $e');
      return {};
    }
  }

  static String encodeChordJson(Map<int, List<ChordData>> chords) {
    final pageKeys = chords.keys.toList()..sort();
    final pages = <String, List<Map<String, dynamic>>>{};
    for (final page in pageKeys) {
      final entries = List<ChordData>.from(chords[page] ?? [])
        ..sort((a, b) => a.noteIdx.compareTo(b.noteIdx));
      final encoded = entries
          .where((entry) => entry.chord.trim().isNotEmpty)
          .map((entry) => entry.toJson())
          .toList();
      if (encoded.isNotEmpty) pages['$page'] = encoded;
    }

    return const JsonEncoder.withIndent(
      '  ',
    ).convert({'version': 2, 'type': 'note-aligned', 'pages': pages});
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
    String? rootOf(String chordText) {
      final match = RegExp(
        r'^([A-Ga-g1-7])([#♯b♭]?)(min|m(?!aj))?',
      ).firstMatch(chordText.trim());
      if (match == null) return null;

      var root = match.group(1)!.toUpperCase();
      var accidental = match.group(2) ?? '';
      final isMinor = match.group(3) != null;

      root = _numberToNote[root] ?? root;
      if (accidental == '♭') accidental = 'b';
      if (accidental == '♯') accidental = '#';

      return '$root$accidental${isMinor ? 'm' : ''}';
    }

    final sortedPages = chords.keys.toList()..sort();

    // Mirror gyschordweb's detectNoteAlignedFamilyChord logic:
    // Collect all chord texts (not the ChordData objects)
    final allChordTexts = <String>[];
    for (final page in sortedPages) {
      final entries = List<ChordData>.from(chords[page] ?? [])
        ..sort((a, b) => a.noteIdx.compareTo(b.noteIdx));
      for (final entry in entries) {
        if (entry.chord.trim().isNotEmpty) {
          allChordTexts.add(entry.chord.trim());
        }
      }
    }

    if (allChordTexts.isEmpty) return null;

    // Get roots from all chords
    final roots = allChordTexts.map(rootOf).whereType<String>().toList();
    if (roots.isEmpty) return null;

    // Priority: First and Last chord resolution (most reliable tonic check)
    final firstRoot = roots.first;
    final lastRoot = roots.last;

    // If first and last are the same, that's our detected root
    if (firstRoot == lastRoot) return firstRoot;

    // Otherwise, analyze frequency
    final counts = <String, int>{};
    var max = 0;
    var mostFreq = firstRoot;

    for (final r in roots) {
      counts[r] = (counts[r] ?? 0) + 1;
      if (counts[r]! > max) {
        max = counts[r]!;
        mostFreq = r;
      }
    }

    // If lastRoot appears more than once, prefer it (resolution tonic)
    return (counts[lastRoot] ?? 0) > 1 ? lastRoot : mostFreq;
  }

  static String untransposeChord(
    String chord,
    int transposeStep, {
    int baseTransposeOffset = 0,
    String accidentalMode = accidentalSharp,
  }) {
    return transposeChord(
      chord,
      -(transposeStep + baseTransposeOffset),
      baseTransposeOffset: 0,
      accidentalMode: accidentalMode,
    );
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
    // Match slash notation: anything/slash/bass note/optional accidental/after
    // Handles German notation: Es=Eb, As=Ab, etc.
    final match = RegExp(
      r'^(.*)/([A-Ga-g1-7])([#♯b♭]?)(.*)$',
      caseSensitive: false,
    ).firstMatch(suffix);
    if (match == null) return _ParsedBass(suffixBefore: suffix);

    var bassNote = match.group(2)!.toUpperCase();
    // Handle German/Indonesian notation for bass notes
    if (bassNote == 'E' && suffix.toLowerCase().startsWith('es')) {
      bassNote = 'Eb'; // Es = Eb
    } else if (bassNote == 'A' && suffix.toLowerCase().startsWith('as')) {
      bassNote = 'Ab'; // As = Ab
    } else if (bassNote == 'H') {
      bassNote = 'B'; // H = B natural
    }

    var semitone = _naturalNoteIndex[bassNote];
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

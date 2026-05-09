import '../../../data/services/chord_service.dart';

const double songDefaultTempoBpm = 76;

class SongPlaybackDefaults {
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

  final int transposeStep;
  final double tempoBpm;
  final double defaultTempoBpm;
  final String? originalFamilyChord;
  final String? originalPdfKey;
  final int baseTransposeOffset;

  const SongPlaybackDefaults({
    required this.transposeStep,
    required this.tempoBpm,
    required this.defaultTempoBpm,
    this.originalFamilyChord,
    this.originalPdfKey,
    this.baseTransposeOffset = 0,
  });

  SongPlaybackDefaults resetForSong({double tempoBpm = songDefaultTempoBpm}) {
    return SongPlaybackDefaults(
      transposeStep: 0,
      tempoBpm: tempoBpm,
      defaultTempoBpm: tempoBpm,
      originalFamilyChord: null,
      originalPdfKey: null,
      baseTransposeOffset: 0,
    );
  }

  SongPlaybackDefaults resolveChordBaseline({
    required String? familyChord,
    required String? pdfKey,
    required bool preferNaturalChords,
  }) {
    final offset = ChordService.calculateBaseTransposeOffset(
      pdfKey: pdfKey,
      familyChord: familyChord,
    );
    final transpose = preferNaturalChords
        ? ChordService.recommendedNaturalTranspose(
            familyChord,
            baseTransposeOffset: offset,
          )
        : transposeStep;
    return copyWith(
      transposeStep: transpose,
      originalFamilyChord: familyChord,
      originalPdfKey: pdfKey,
      baseTransposeOffset: offset,
    );
  }

  SongPlaybackDefaults preloadBaseline({
    required bool preferNaturalChords,
    required String? familyChord,
    required String? pdfKey,
  }) {
    final reset = resetForSong(tempoBpm: tempoBpm);
    if (!preferNaturalChords) return reset;
    return reset.resolveChordBaseline(
      familyChord: familyChord,
      pdfKey: pdfKey,
      preferNaturalChords: true,
    );
  }

  String activeKeyLabel({
    String accidentalMode = ChordService.accidentalSharp,
  }) {
    final source = _sourceKey();
    if (source == null) return '-';
    final noteSet = _noteSet(accidentalMode);
    final currentSemi = _wrapSemitone(
      source.semitone +
          transposeStep +
          (originalFamilyChord == null ? 0 : baseTransposeOffset),
    );
    return '${noteSet[currentSemi]}${source.isMinor ? 'm' : ''}';
  }

  List<String> keyOptions({
    String accidentalMode = ChordService.accidentalSharp,
  }) {
    final isMinor = _sourceKey()?.isMinor ?? false;
    return _noteSet(
      accidentalMode,
    ).map((note) => '$note${isMinor ? 'm' : ''}').toList();
  }

  int transposeStepForKey(String key) {
    final source = _sourceKey();
    final targetSemi = ChordService.parsePdfKeyToSemitone(key);
    if (source == null || targetSemi == null) return transposeStep;
    final offset = originalFamilyChord == null ? 0 : baseTransposeOffset;
    var diff = targetSemi - source.semitone - offset;
    diff %= 12;
    if (diff > 6) diff -= 12;
    if (diff < -5) diff += 12;
    return diff;
  }

  _SongKey? _sourceKey() {
    return _parseKey(originalFamilyChord) ?? _parseKey(originalPdfKey);
  }

  SongPlaybackDefaults copyWith({
    int? transposeStep,
    double? tempoBpm,
    double? defaultTempoBpm,
    Object? originalFamilyChord = _sentinel,
    Object? originalPdfKey = _sentinel,
    int? baseTransposeOffset,
  }) {
    return SongPlaybackDefaults(
      transposeStep: transposeStep ?? this.transposeStep,
      tempoBpm: tempoBpm ?? this.tempoBpm,
      defaultTempoBpm: defaultTempoBpm ?? this.defaultTempoBpm,
      originalFamilyChord: identical(originalFamilyChord, _sentinel)
          ? this.originalFamilyChord
          : originalFamilyChord as String?,
      originalPdfKey: identical(originalPdfKey, _sentinel)
          ? this.originalPdfKey
          : originalPdfKey as String?,
      baseTransposeOffset: baseTransposeOffset ?? this.baseTransposeOffset,
    );
  }
}

const Object _sentinel = Object();

class _SongKey {
  final int semitone;
  final bool isMinor;

  const _SongKey(this.semitone, this.isMinor);
}

_SongKey? _parseKey(String? key) {
  final semitone = ChordService.parsePdfKeyToSemitone(key);
  if (semitone == null) return null;
  return _SongKey(semitone, key?.trim().toLowerCase().endsWith('m') ?? false);
}

List<String> _noteSet(String accidentalMode) {
  return accidentalMode == ChordService.accidentalFlat
      ? SongPlaybackDefaults._notesFlat
      : SongPlaybackDefaults._notesSharp;
}

int _wrapSemitone(int value) => ((value % 12) + 12) % 12;

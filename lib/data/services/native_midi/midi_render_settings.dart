class MidiRenderSettings {
  static const double minTempoBpm = 30;
  static const double maxTempoBpm = 220;

  final int transpose;
  final double tempoBpm;
  final double baseTempoBpm;
  final int? instrument;
  final String soundFont;

  const MidiRenderSettings({
    this.transpose = 0,
    this.tempoBpm = 76,
    this.baseTempoBpm = 76,
    this.instrument,
    required this.soundFont,
  });

  MidiRenderSettings get normalized {
    final normalizedInstrument = instrument;
    return copyWith(
      transpose: transpose.clamp(-12, 12),
      tempoBpm: tempoBpm.clamp(minTempoBpm, maxTempoBpm).toDouble(),
      baseTempoBpm: baseTempoBpm.clamp(minTempoBpm, maxTempoBpm).toDouble(),
      instrument: normalizedInstrument?.clamp(0, 127),
      soundFont: soundFont
          .split(RegExp(r'[\\/]'))
          .where((part) => part.isNotEmpty)
          .last,
    );
  }

  double get tempoRate {
    final normalizedSettings = normalized;
    final base = normalizedSettings.baseTempoBpm;
    if (base <= 0) return 1;
    return normalizedSettings.tempoBpm / base;
  }

  String get cacheKey {
    final normalizedSettings = normalized;
    return [
      normalizedSettings.soundFont,
      normalizedSettings.transpose,
      normalizedSettings.tempoBpm.round(),
      normalizedSettings.baseTempoBpm.round(),
      normalizedSettings.instrument ?? -1,
    ].join('|');
  }

  MidiRenderSettings copyWith({
    int? transpose,
    double? tempoBpm,
    double? baseTempoBpm,
    Object? instrument = _sentinel,
    String? soundFont,
  }) {
    return MidiRenderSettings(
      transpose: transpose ?? this.transpose,
      tempoBpm: tempoBpm ?? this.tempoBpm,
      baseTempoBpm: baseTempoBpm ?? this.baseTempoBpm,
      instrument: identical(instrument, _sentinel)
          ? this.instrument
          : instrument as int?,
      soundFont: soundFont ?? this.soundFont,
    );
  }
}

const Object _sentinel = Object();

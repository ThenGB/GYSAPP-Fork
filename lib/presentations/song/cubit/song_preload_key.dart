/// Pure helper for deterministic preload job cache keys.
///
/// Ensures that preload jobs with different render settings
/// (transpose, instrument, soundfont, tempo) have distinct cache keys
/// to prevent stale data reuse.
library;

/// Bump when a render-affecting change lands (e.g. the melty master
/// volume 0.5 → 0.9 fix) so previously cached WAVs are re-rendered.
const int kMidiRenderVersion = 2;

/// Generates a cache key for a MIDI preload job.
///
/// The key includes all render-affecting settings so that
/// different settings produce different cache entries.
String generateMidiPreloadKey({
  required String midiPath,
  required int transpose,
  required double tempoBpm,
  required double baseTempoBpm,
  required int? instrument,
  required String soundFont,
}) {
  // Normalize settings to ensure consistency
  final normalizedTempo = tempoBpm.clamp(30, 220);
  final normalizedBaseTempo = baseTempoBpm.clamp(30, 220);
  final normalizedTranspose = transpose.clamp(-12, 12);
  final normalizedInstrument = instrument?.clamp(0, 127);

  return [
    'v$kMidiRenderVersion',
    midiPath,
    soundFont,
    normalizedTranspose,
    normalizedTempo.round(),
    normalizedBaseTempo.round(),
    normalizedInstrument ?? -1,
  ].join('|');
}

/// Checks if a tempo rate is effectively 1.0 (neutral).
///
/// Preload should be skipped for non-neutral tempo rates
/// because rendered audio is song-state specific.
bool isTempoNeutral(double tempoBpm, double baseTempoBpm) {
  if (baseTempoBpm <= 0) return true;
  final rate = tempoBpm / baseTempoBpm;
  return (rate - 1.0).abs() < 0.0001;
}

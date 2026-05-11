/// Pure helper for deterministic preload job cache keys.
///
/// Ensures that preload jobs with different render settings
/// (transpose, instrument, soundfont, tempo) have distinct cache keys
/// to prevent stale data reuse.
library;

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
    midiPath,
    soundFont,
    normalizedTranspose,
    normalizedTempo.round(),
    normalizedBaseTempo.round(),
    normalizedInstrument ?? -1,
  ].join('|');
}

/// Generates a cache key for a PDF preload job.
///
/// Includes the PDF path only since PDF rendering doesn't
/// have render-affecting settings like MIDI.
String generatePdfPreloadKey({
  required String pdfPath,
}) {
  return pdfPath;
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

import '../../../data/services/native_midi/midi_render_settings.dart';

/// Pure helper for deterministic warm-up (cache-ahead) job keys.
///
/// The key must include every render parameter so that two different
/// settings for the same MIDI file do not collide in the engine cache.
String warmUpKey(String midiPath, MidiRenderSettings settings) {
  final n = settings.normalized;
  return '$midiPath|${n.cacheKey}';
}

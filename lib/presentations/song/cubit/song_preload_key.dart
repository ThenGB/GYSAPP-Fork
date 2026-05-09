import 'song_playback_defaults.dart';

String songPreloadJobKey({
  required String midiPath,
  required SongPlaybackDefaults defaults,
  required String soundFont,
  int? instrument,
}) {
  final normalizedSoundFont = soundFont
      .split(RegExp(r'[\\/]'))
      .where((part) => part.isNotEmpty)
      .last;
  return [
    midiPath,
    normalizedSoundFont,
    defaults.transposeStep,
    defaults.tempoBpm.round(),
    defaults.defaultTempoBpm.round(),
    instrument ?? -1,
    defaults.originalFamilyChord ?? '-',
    defaults.originalPdfKey ?? '-',
    defaults.baseTransposeOffset,
  ].join('|');
}

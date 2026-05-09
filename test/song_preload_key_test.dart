import 'package:church/presentations/song/cubit/song_playback_defaults.dart';
import 'package:church/presentations/song/cubit/song_preload_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preload job key changes with render-affecting settings', () {
    const base = SongPlaybackDefaults(
      transposeStep: 0,
      tempoBpm: 76,
      defaultTempoBpm: 76,
    );

    final original = songPreloadJobKey(
      midiPath: 'assets/data/midi/kr/001.mid',
      defaults: base,
      soundFont: 'assets/data/soundfont/GeneralUser-GS.sf2',
    );
    final transposed = songPreloadJobKey(
      midiPath: 'assets/data/midi/kr/001.mid',
      defaults: base.copyWith(transposeStep: 1),
      soundFont: 'assets/data/soundfont/GeneralUser-GS.sf2',
    );
    final instrument = songPreloadJobKey(
      midiPath: 'assets/data/midi/kr/001.mid',
      defaults: base,
      soundFont: 'assets/data/soundfont/GeneralUser-GS.sf2',
      instrument: 19,
    );
    final soundFont = songPreloadJobKey(
      midiPath: 'assets/data/midi/kr/001.mid',
      defaults: base,
      soundFont: 'TimGM6mb.sf2',
    );

    expect(original, isNot(transposed));
    expect(original, isNot(instrument));
    expect(original, isNot(soundFont));
    expect(original, contains('GeneralUser-GS.sf2'));
    expect(original, isNot(contains('assets/data/soundfont')));
  });
}

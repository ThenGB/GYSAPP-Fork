import 'package:church/presentations/song/cubit/song_state.dart';
import 'package:church/presentations/song/view/song_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('first install opens the hymnal in text mode with chords off', () {
    // A brand-new SongState (nothing hydrated yet) must default to lyrics
    // mode (isImageMode false = text) with the chord toggle off, so a
    // first-time user sees plain lyrics, not a PDF or chord overlay.
    const fresh = SongState();
    expect(fresh.isImageMode, isFalse);
    expect(fresh.showChord, isFalse);
    expect(fresh.bookCode, 'KR');

    // And the chord toggle only ever shows for chord-enabled books anyway.
    expect(
      shouldRenderChordForSongState(const SongState(bookCode: 'KR')),
      isFalse,
    );
  });

  test('renders chord overlay only for chord-enabled books with the toggle on', () {
    expect(
      shouldRenderChordForSongState(
        const SongState(bookCode: 'KR', showChord: true),
      ),
      isTrue,
    );

    expect(
      shouldRenderChordForSongState(
        const SongState(bookCode: 'KR', showChord: false),
      ),
      isFalse,
    );

    expect(
      shouldRenderChordForSongState(
        const SongState(bookCode: 'HYMNE', showChord: true),
      ),
      isFalse,
    );
  });
}

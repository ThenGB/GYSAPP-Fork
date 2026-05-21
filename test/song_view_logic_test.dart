import 'package:church/presentations/song/cubit/song_state.dart';
import 'package:church/presentations/song/view/song_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

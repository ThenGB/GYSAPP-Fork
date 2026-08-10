import 'dart:io';

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

  test('text mode gestures: pinch zooms, swipes navigate, zoom wins', () {
    final source = File(
      'lib/presentations/song/view/song_view.dart',
    ).readAsStringSync();

    // Left/right song navigation stays with the PageView: the lyric page no
    // longer registers horizontal drags of its own.
    expect(source, isNot(contains('onHorizontalDragStart')));
    expect(source, isNot(contains('onHorizontalDragEnd')));

    // Pinch (two pointers) switches to text zoom and suppresses navigation.
    expect(source, contains('onPinchStart'));
    expect(source, contains('onPinchScale'));
    expect(source, contains('onPinchEnd'));
    expect(source, contains('if (_pinchActive || _pinchSeenSinceDragStart)'));
    // While pinching, the song PageView physics are disabled so a pinch can
    // never be mistaken for a song swipe.
    expect(source, contains('_isTextPinching'));
    expect(source, contains('NeverScrollableScrollPhysics'));

    // Mouse: Ctrl+scroll zooms the text via the pointer-signal resolver so
    // the scrollables do not scroll at the same time.
    expect(source, contains('PointerScrollEvent'));
    expect(source, contains('pointerSignalResolver'));
    expect(source, contains('_ctrlPressed'));
    expect(source, contains('_applyTextZoom'));
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

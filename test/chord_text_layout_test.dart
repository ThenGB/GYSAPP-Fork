import 'package:church/data/services/chord_text_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const melodyLine = ChordedTextLine(
    text: 'Kasih Tuhan sungguh indah',
    chords: [
      TextChordPlacement(chord: 'C', position: 0),
      TextChordPlacement(chord: 'G', position: 0.58),
    ],
  );

  test('line matching ignores verse labels and punctuation', () {
    expect(
      findChordedLine('1. Kasih Tuhan, sungguh indah!', const [melodyLine]),
      same(melodyLine),
    );
  });

  test('matching preserves non-ASCII lyric text', () {
    const chinese = ChordedTextLine(
      text: '主耶穌愛我',
      chords: [TextChordPlacement(chord: 'F', position: 0.2)],
    );
    expect(findChordedLine('主耶穌愛我。', const [chinese]), same(chinese));
  });

  test('fallback is learned across all verses like GYSChordWeb', () {
    final fallback = buildVerseChordFallback(
      const [
        'Baris yang tidak cocok',
        'Kasih Tuhan sungguh indah',
      ],
      const [melodyLine],
    );

    expect(fallback, hasLength(1));
    expect(fallback.single, same(melodyLine));
    expect(
      resolveChordedLineForVerseLine(
        'Bait lain dengan melodi sama',
        0,
        const [melodyLine],
        fallback,
      ),
      same(melodyLine),
    );
  });
}

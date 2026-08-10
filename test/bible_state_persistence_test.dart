import 'package:church/presentations/bible/cubit/bible_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('transient TTS word progress is not persisted', () {
    const state = BibleState(
      currentWord: 'firman',
      currentStartWord: 12,
      currentEndWord: 18,
    );

    final json = state.toJson();

    expect(json, isNot(contains('currentWord')));
    expect(json, isNot(contains('currentStartWord')));
    expect(json, isNot(contains('currentEndWord')));
  });

  test('persisted reading position and preferences survive round-trip', () {
    final state = BibleState(
      currentBibleCode: 'b_kjv',
      defaultTextScale: 1.4,
      defaultFont: 'EB Garamond',
      isSpeaking: true,
      ttsCurrentVerseIndex: 3,
    );

    final json = state.toJson();
    expect(json['currentBibleCode'], 'b_kjv');
    expect(json['defaultTextScale'], 1.4);
    expect(json['isSpeaking'], isTrue);
    expect(json['ttsCurrentVerseIndex'], 3);

    final restored = BibleState.fromJson(json);
    expect(restored.currentBibleCode, 'b_kjv');
    expect(restored.defaultTextScale, 1.4);
    expect(restored.isSpeaking, isTrue);
    expect(restored.ttsCurrentVerseIndex, 3);
    // Stripped transient fields fall back to their defaults.
    expect(restored.currentWord, '');
    expect(restored.currentStartWord, 0);
    expect(restored.currentEndWord, 0);
  });
}

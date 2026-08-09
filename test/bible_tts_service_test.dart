import 'package:flutter/foundation.dart' show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter_test/flutter_test.dart';

import 'package:church/data/services/bible_tts_service.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// Test subclass that overrides synthesis so no SoLoud/network is needed.
/// Records the texts passed to synthesize to verify preload ordering and
/// in-flight dedup (the service-level getOrSynthesize runs for real).
class _FakeTts extends BibleTtsService {
  final List<String> synthesized = [];

  @override
  Future<AudioSource?> synthesize(
    String text,
    int generation,
    String cacheKey,
  ) async {
    // Simulate network latency so concurrent calls overlap.
    await Future<void>.delayed(const Duration(milliseconds: 5));
    synthesized.add(text);
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BibleTtsService edge param formatting', () {
    test('formatEdgePercent adds + for zero and positive, keeps - for negative',
        () {
      expect(BibleTtsService.formatEdgePercent(0), '+0%');
      expect(BibleTtsService.formatEdgePercent(25), '+25%');
      expect(BibleTtsService.formatEdgePercent(-10), '-10%');
    });

    test('parseEdgePercent round-trips', () {
      expect(BibleTtsService.parseEdgePercent('+0%'), 0);
      expect(BibleTtsService.parseEdgePercent('+25%'), 25);
      expect(BibleTtsService.parseEdgePercent('-10%'), -10);
      expect(BibleTtsService.parseEdgePercent('+100%'), 100);
    });

    test('formatEdgePitch adds + for zero and positive, keeps - for negative',
        () {
      expect(BibleTtsService.formatEdgePitch(0), '+0Hz');
      expect(BibleTtsService.formatEdgePitch(25), '+25Hz');
      expect(BibleTtsService.formatEdgePitch(-10), '-10Hz');
    });

    test('parseEdgePitch round-trips', () {
      expect(BibleTtsService.parseEdgePitch('+0Hz'), 0);
      expect(BibleTtsService.parseEdgePitch('+25Hz'), 25);
      expect(BibleTtsService.parseEdgePitch('-10Hz'), -10);
      expect(BibleTtsService.parseEdgePitch('+50Hz'), 50);
    });
  });

  group('BibleTtsService preload queue', () {
    test('preload synthesizes the requested text through the engine', () async {
      final tts = _FakeTts()..engine = BibleTtsEngine.edge;
      await tts.preload('verse one');
      expect(tts.synthesized, contains('verse one'));
    });

    test('preload is a no-op for the native engine', () async {
      final tts = _FakeTts()..engine = BibleTtsEngine.native;
      await tts.preload('verse one');
      expect(tts.synthesized, isEmpty);
    });

    test('native speak never touches Edge synthesis', () async {
      final tts = _FakeTts()..engine = BibleTtsEngine.native;
      await tts.speak('verse one');
      expect(tts.synthesized, isEmpty);
    });

    test('concurrent preloads of the same text share one synthesis', () async {
      final tts = _FakeTts()..engine = BibleTtsEngine.edge;
      // Fire two preloads for the same text without awaiting in between.
      final first = tts.preload('verse one');
      final second = tts.preload('verse one');
      await Future.wait([first, second]);
      // In-flight dedup: the second call joins the first instead of
      // starting a duplicate network synthesis.
      expect(
        tts.synthesized.where((t) => t == 'verse one').length,
        1,
      );
    });

    test('speak joins an in-flight preload of the same text', () async {
      final tts = _FakeTts()..engine = BibleTtsEngine.edge;
      final preloadFuture = tts.preload('verse one');
      final speakFuture = tts.speak('verse one');
      await Future.wait([preloadFuture, speakFuture]);
      // Both requests resolve through a single synthesis.
      expect(
        tts.synthesized.where((t) => t == 'verse one').length,
        1,
      );
    });

    test('idle stop on Windows does not touch the native TTS plugin', () async {
      // Regression for the native crash on every tab switch: on Windows
      // (canStopIdleTextToSpeechForCurrentPlatform == false) an idle
      // stop() must NOT call FlutterTts.stop(), whose native plugin
      // dereferences the SAPI voice object when nothing is playing.
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final tts = _FakeTts()..engine = BibleTtsEngine.edge;
      var nativeStopped = false;
      tts.nativeTtsStopHook = () async {
        nativeStopped = true;
      };
      await tts.stop();
      expect(nativeStopped, isFalse,
          reason: 'idle native engine must not be stopped on Windows');
    });

    test('stop after a native speak actually stops the native engine',
        () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final tts = _FakeTts()..engine = BibleTtsEngine.native;
      var nativeStopped = false;
      tts.nativeTtsStopHook = () async {
        nativeStopped = true;
      };
      // Simulate an in-flight native utterance.
      tts.markNativeSpeakingForTest();
      await tts.stop();
      expect(nativeStopped, isTrue,
          reason: 'an active native utterance must be stoppable');
    });
  });
}

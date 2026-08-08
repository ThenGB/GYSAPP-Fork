import 'package:flutter_test/flutter_test.dart';

import 'package:church/data/services/bible_tts_service.dart';

void main() {
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
}

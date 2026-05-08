import 'package:church/data/services/local_asset_service.dart';
import 'package:church/data/services/local_bible_asset_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('resolves indexed midi path to bundled asset path', () async {
    final service = LocalAssetService();

    final path = await service.getMidiPath('KR', '011');

    expect(path, 'assets/data/midi/kr/011_Gembira di Dalam Tuhan.mid');
    final data = await rootBundle.load(path!);
    expect(data.lengthInBytes, greaterThan(0));
  });

  test(
    'resolves non KR pdf path even when index title encoding differs',
    () async {
      final service = LocalAssetService();

      final path = await service.getPdfPath('MDR', '001');

      expect(path, startsWith('assets/data/pdf/mdr/001_'));
      expect(path, endsWith('.pdf'));
      final data = await rootBundle.load(path!);
      expect(data.lengthInBytes, greaterThan(0));
    },
  );

  test(
    'bundled bible versions are exposed as selectable bible codes',
    () async {
      final service = LocalBibleAssetService();

      final codes = await service.getBundledBibleCodes();

      expect(codes, contains('b_tb'));
      expect(codes, isNot(contains('b_tb.db')));
    },
  );

  test('available soundfonts point to bundled sf2 assets', () async {
    final service = LocalAssetService();

    final soundfonts = await service.getAvailableSoundFonts();

    expect(soundfonts.first, 'GeneralUser-GS.sf2');
    expect(soundfonts, contains('GeneralUser-GS.sf2'));
    for (final fileName in soundfonts) {
      final data = await rootBundle.load('assets/data/soundfont/$fileName');
      expect(data.lengthInBytes, greaterThan(0));
    }
  });
}

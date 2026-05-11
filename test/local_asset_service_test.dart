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

  test('resolves HYMNE midi path to KR midi file via cross-reference', () async {
    final service = LocalAssetService();

    final path = await service.getMidiPath('HYMNE', '001');

    expect(path, 'assets/data/midi/kr/001_Pujilah Allah Yang Maha Esa.mid');
    final data = await rootBundle.load(path!);
    expect(data.lengthInBytes, greaterThan(0));
  });

  test('resolves MDR midi path to KR midi file via cross-reference', () async {
    final service = LocalAssetService();

    final path = await service.getMidiPath('MDR', '001');

    expect(path, 'assets/data/midi/kr/001_Pujilah Allah Yang Maha Esa.mid');
    final data = await rootBundle.load(path!);
    expect(data.lengthInBytes, greaterThan(0));
  });

  test(
    'resolves non KR pdf path even when index title encoding differs',
    () async {
      final service = LocalAssetService();

      final path = await service.getPdfPath('MDR', '001');

      expect(path, startsWith('assets/data/pdf/mdr/mdr_master.pdf#'));
      expect(path, contains('page='));
      expect(path, contains('pages='));
      final data = await rootBundle.load(path!.split('#').first);
      expect(data.lengthInBytes, greaterThan(0));
    },
  );

  test('resolves KR pdf path to bundled native PDF asset', () async {
    final service = LocalAssetService();

    final path = await service.getPdfPath('KR', '001');

    expect(path, 'assets/data/pdf/kr/001_Pujilah Allah Yang Maha Esa.pdf');
    final data = await rootBundle.load(path!);
    expect(data.lengthInBytes, greaterThan(0));
  });

  test('resolves HYMNE pdf path to master PDF with page range', () async {
    final service = LocalAssetService();

    final path = await service.getPdfPath('HYMNE', '001');

    expect(path, startsWith('assets/data/pdf/hymne/hymne_master.pdf#'));
    expect(path, contains('page=5'));
    expect(path, contains('pages=1'));
    final data = await rootBundle.load(path!.split('#').first);
    expect(data.lengthInBytes, greaterThan(0));
  });

  test('resolves KR chord path to bundled native overlay data', () async {
    final service = LocalAssetService();

    final path = await service.getChordPath('KR', '001');

    expect(
      path,
      'assets/data/chord/kr/001_Pujilah Allah Yang Maha Esa.chord.json',
    );
    final json = await rootBundle.loadString(path!);
    expect(json, contains('"noteIdx"'));
  });

  test(
    'falls back HYMNE chord path to matching KR native overlay data',
    () async {
      final service = LocalAssetService();

      final path = await service.getChordPath('HYMNE', '001');

      expect(
        path,
        'assets/data/chord/kr/001_Pujilah Allah Yang Maha Esa.chord.json',
      );
      final json = await rootBundle.loadString(path!);
      expect(json, contains('"noteIdx"'));
    },
  );

  test('resolves ASM pdf path to consolidated master range', () async {
    final service = LocalAssetService();

    final path = await service.getPdfPath('ASM-I', '001');

    expect(path, startsWith('assets/data/pdf/asm_i/asm_i_master.pdf#'));
    expect(path, contains('page='));
    expect(path, contains('pages='));
    final data = await rootBundle.load(path!.split('#').first);
    expect(data.lengthInBytes, greaterThan(0));
  });

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

    expect(soundfonts, contains('TimGM6mb.sf2'));
    expect(soundfonts, contains('GeneralUser-GS.sf2'));
    expect(soundfonts.length, greaterThanOrEqualTo(2));
    for (final fileName in soundfonts) {
      final data = await rootBundle.load('assets/data/soundfont/$fileName');
      expect(data.lengthInBytes, greaterThan(0));
    }
  });
}

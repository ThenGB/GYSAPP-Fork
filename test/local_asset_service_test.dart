import 'dart:io';

import 'package:church/data/services/asset_distribution/installed_asset_registry.dart';
import 'package:church/data/services/asset_distribution/models.dart';
import 'package:church/data/services/chord_sync_service.dart';
import 'package:church/data/services/local_asset_service.dart';
import 'package:church/data/services/pdf_chunk_service.dart';
import 'package:church/data/services/local_bible_asset_service.dart';
import 'package:church/di/injection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('church_local_asset_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          return switch (call.method) {
            'getTemporaryDirectory' => tempDir.path,
            'getApplicationSupportDirectory' => tempDir.path,
            'getApplicationDocumentsDirectory' => tempDir.path,
            _ => null,
          };
        });
    if (!di.isRegistered<ChordSyncService>()) {
      di.registerLazySingleton(
        () => ChordSyncService(
          AppDirectory(tempDir.path, tempDir.path, tempDir.path),
          http.Client(),
        ),
      );
    }
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('resolves indexed midi path to bundled asset path', () async {
    final service = LocalAssetService(PdfChunkService());

    final path = await service.getMidiPath('KR', '011');

    expect(path, 'assets/data/midi/kr/011_Gembira di Dalam Tuhan.mid');
    final data = await rootBundle.load(path!);
    expect(data.lengthInBytes, greaterThan(0));
  });

  test(
    'resolves HYMNE midi path to KR midi file via cross-reference',
    () async {
      final service = LocalAssetService(PdfChunkService());

      final path = await service.getMidiPath('HYMNE', '001');

      expect(path, 'assets/data/midi/kr/001_Pujilah Allah Yang Maha Esa.mid');
      final data = await rootBundle.load(path!);
      expect(data.lengthInBytes, greaterThan(0));
    },
  );

  test('resolves MDR midi path to KR midi file via cross-reference', () async {
    final service = LocalAssetService(PdfChunkService());

    final path = await service.getMidiPath('MDR', '001');

    expect(path, 'assets/data/midi/kr/001_Pujilah Allah Yang Maha Esa.mid');
    final data = await rootBundle.load(path!);
    expect(data.lengthInBytes, greaterThan(0));
  });

  test(
    'resolves installed MDR pdf path even when index title encoding differs',
    () async {
      final registry = InstalledAssetRegistry(supportDirectory: tempDir);
      final installedFile = File(
        '${registry.hymnalInstallDirectory.path}/mdr_master.pdf',
      )..createSync(recursive: true);
      await installedFile.writeAsBytes(const [1, 2, 3, 4]);
      await registry.saveInstalled(
        const InstalledAssetRecord(
          kind: DistributedAssetKind.hymnal,
          code: 'MDR',
          version: '2026.05.21',
          installedPath: 'mdr_master.pdf',
          installedAtEpochMs: 100,
        ),
      );
      final service = LocalAssetService(
        PdfChunkService(),
        installedAssetRegistry: registry,
      );

      final path = await service.getPdfPath('MDR', '001');

      expect(path, startsWith(installedFile.path));
      expect(path, contains('page='));
      expect(path, contains('pages='));
    },
  );

  test('resolves KR pdf path with normalized page fragment', () async {
    final service = LocalAssetService(PdfChunkService());

    final path = await service.getPdfPath('KR', '001');

    expect(path, startsWith(p.join(tempDir.path, 'master_pdfs')));
    expect(path, contains('#page='));
    expect(path, contains('pages='));
    final cachedMaster = File(path!.split('#').first);
    expect(await cachedMaster.exists(), isTrue);
    expect(await cachedMaster.length(), greaterThan(0));
  });

  test('resolves installed HYMNE pdf path with page range', () async {
    final registry = InstalledAssetRegistry(supportDirectory: tempDir);
    final installedFile = File(
      '${registry.hymnalInstallDirectory.path}/hymne_master.pdf',
    )..createSync(recursive: true);
    await installedFile.writeAsBytes(const [1, 2, 3, 4]);
    await registry.saveInstalled(
      const InstalledAssetRecord(
        kind: DistributedAssetKind.hymnal,
        code: 'HYMNE',
        version: '2026.05.21',
        installedPath: 'hymne_master.pdf',
        installedAtEpochMs: 100,
      ),
    );
    final service = LocalAssetService(
      PdfChunkService(),
      installedAssetRegistry: registry,
    );

    final path = await service.getPdfPath('HYMNE', '001');

    expect(path, startsWith(installedFile.path));
    expect(path, contains('page='));
    expect(path, contains('pages=1'));
    expect(path, isNotNull);
  });

  test('tracks whether a bundled master pdf still needs first-time preparation', () async {
    final service = LocalAssetService(PdfChunkService());

    expect(await service.needsPdfPreparation('KR', '001'), isTrue);

    final path = await service.getPdfPath('KR', '001');

    expect(path, isNotNull);
    expect(await service.needsPdfPreparation('KR', '001'), isFalse);
  });

  test('resolves KR chord path from synced files only (no bundled chords)', () async {
    final service = LocalAssetService(PdfChunkService());

    // Chords are no longer bundled — without a synced file the path is null.
    expect(await service.getChordPath('KR', '001'), isNull);

    // After a sync places the file in the chord folder, it resolves there.
    final sync = di<ChordSyncService>();
    final file = File(
      '${sync.chordDirectory.path}/001_Pujilah Allah Yang Maha Esa.chord.json',
    );
    await file.create(recursive: true);
    await file.writeAsString('{"noteIdx":[]}');

    final path = await service.getChordPath('KR', '001');
    expect(path?.replaceAll('\\', '/'), file.path.replaceAll('\\', '/'));
    final json = await service.readChordJson('KR', '001');
    expect(json, contains('"noteIdx"'));
  });

  test('does not cross-map HYMNE chord path to KR', () async {
    final service = LocalAssetService(PdfChunkService());

    final path = await service.getChordPath('HYMNE', '001');

    expect(path, isNull);
  });

  test('does not cross-map MDR chord path to KR', () async {
    final service = LocalAssetService(PdfChunkService());

    final path = await service.getChordPath('MDR', '001');

    expect(path, isNull);
  });

  test('does not cross-map ASM-I chord path to KR', () async {
    final service = LocalAssetService(PdfChunkService());

    final path = await service.getChordPath('ASM-I', '001');

    expect(path, isNull);
  });

  test('resolves installed ASM pdf path to consolidated master range', () async {
    final registry = InstalledAssetRegistry(supportDirectory: tempDir);
    final installedFile = File(
      '${registry.hymnalInstallDirectory.path}/asm_i_master.pdf',
    )..createSync(recursive: true);
    await installedFile.writeAsBytes(const [1, 2, 3, 4]);
    await registry.saveInstalled(
      const InstalledAssetRecord(
        kind: DistributedAssetKind.hymnal,
        code: 'ASM-I',
        version: '2026.05.21',
        installedPath: 'asm_i_master.pdf',
        installedAtEpochMs: 100,
      ),
    );
    final service = LocalAssetService(
      PdfChunkService(),
      installedAssetRegistry: registry,
    );

    final path = await service.getPdfPath('ASM-I', '001');

    expect(path, startsWith(installedFile.path));
    expect(path, contains('page='));
    expect(path, contains('pages='));
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
    final service = LocalAssetService(PdfChunkService());

    final soundfonts = await service.getAvailableSoundFonts();

    expect(soundfonts, contains('TimGM6mb.sf2'));
    // GeneralUser-GS.sf2 is no longer bundled — it is hosted on
    // GitHub Releases (GYSAPP-Data) for optional download.
    expect(soundfonts.length, greaterThanOrEqualTo(1));
    for (final fileName in soundfonts) {
      final data = await rootBundle.load('assets/data/soundfont/$fileName');
      expect(data.lengthInBytes, greaterThan(0));
    }
  });

  test('installed hymnals are exposed as available song books when registry is provided', () async {
    final registry = InstalledAssetRegistry(supportDirectory: tempDir);
    final installedFile = File(
      '${registry.hymnalInstallDirectory.path}/hymne_master.pdf',
    )..createSync(recursive: true);
    await installedFile.writeAsBytes(const [1, 2, 3, 4]);
    await registry.saveInstalled(
      const InstalledAssetRecord(
        kind: DistributedAssetKind.hymnal,
        code: 'HYMNE',
        version: '2026.05.21',
        installedPath: 'hymne_master.pdf',
        installedAtEpochMs: 100,
      ),
    );

    final service = LocalAssetService(
      PdfChunkService(),
      installedAssetRegistry: registry,
    );

    final books = await service.loadSongBooks();
    final codes = books.map((book) => book.code).toList();

    expect(codes, contains('KR'));
    expect(codes, contains('HYMNE'));
    expect(codes, isNot(contains('MDR')));
  });

  test('installed hymnals resolve directly to persistent local master files', () async {
    final registry = InstalledAssetRegistry(supportDirectory: tempDir);
    final installedFile = File(
      '${registry.hymnalInstallDirectory.path}/hymne_master.pdf',
    )..createSync(recursive: true);
    await installedFile.writeAsBytes(const [1, 2, 3, 4]);
    await registry.saveInstalled(
      const InstalledAssetRecord(
        kind: DistributedAssetKind.hymnal,
        code: 'HYMNE',
        version: '2026.05.21',
        installedPath: 'hymne_master.pdf',
        installedAtEpochMs: 100,
      ),
    );

    final service = LocalAssetService(
      PdfChunkService(),
      installedAssetRegistry: registry,
    );

    final path = await service.getPdfPath('HYMNE', '001');

    expect(path, startsWith(installedFile.path));
    expect(path, contains('#page='));
    expect(path, contains('pages=1'));
  });
}

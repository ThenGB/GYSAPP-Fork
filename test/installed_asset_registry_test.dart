import 'dart:io';

import 'package:church/data/services/asset_distribution/installed_asset_registry.dart';
import 'package:church/data/services/asset_distribution/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory supportDir;

  setUp(() async {
    supportDir = await Directory.systemTemp.createTemp(
      'church_installed_asset_registry_',
    );
  });

  tearDown(() async {
    if (await supportDir.exists()) {
      await supportDir.delete(recursive: true);
    }
  });

  test('persists installed hymnal metadata and exposes installed file path', () async {
    final registry = InstalledAssetRegistry(supportDirectory: supportDir);
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
        releaseTag: 'hymnals-2026.05.21',
        checksumSha256: 'abc123',
        installedAtEpochMs: 1000,
      ),
    );

    final reloaded = InstalledAssetRegistry(supportDirectory: supportDir);
    final record = await reloaded.getInstalledRecord(
      DistributedAssetKind.hymnal,
      'HYMNE',
    );

    expect(record, isNotNull);
    expect(record!.version, '2026.05.21');
    expect(record.releaseTag, 'hymnals-2026.05.21');
    expect(await reloaded.resolveInstalledHymnalPath('HYMNE'), installedFile.path);
  });

  test('removing an installed asset deletes its registry entry and file', () async {
    final registry = InstalledAssetRegistry(supportDirectory: supportDir);
    final installedFile = File(
      '${registry.bibleInstallDirectory.path}/b_kjv.db',
    )..createSync(recursive: true);
    await installedFile.writeAsBytes(const [9, 8, 7]);

    await registry.saveInstalled(
      const InstalledAssetRecord(
        kind: DistributedAssetKind.bible,
        code: 'b_kjv',
        version: '1',
        installedPath: 'b_kjv.db',
        installedAtEpochMs: 100,
      ),
    );

    await registry.removeInstalled(DistributedAssetKind.bible, 'b_kjv');

    expect(
      await registry.getInstalledRecord(DistributedAssetKind.bible, 'b_kjv'),
      isNull,
    );
    expect(await installedFile.exists(), isFalse);
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:church/data/services/asset_distribution/encrypted_asset_package_service.dart';
import 'package:church/data/services/asset_distribution/models.dart';

Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  final version = options['version'];
  if (version == null || version.isEmpty) {
    stderr.writeln('Usage: dart run tool/asset_distribution/package_release_assets.dart --version=2026.05.21');
    exitCode = 64;
    return;
  }

  final outputRoot = Directory(
    options['output'] ?? 'build/asset_distribution/$version',
  );
  final packager = EncryptedAssetPackageService();

  await _packageTrack(
    version: version,
    track: AssetReleaseTrack.bibles,
    outputRoot: outputRoot,
    packager: packager,
    sourceFiles: const {
      'b_tb': 'Original Alkitab DB/b_tb.db',
      'b_kjv': 'Original Alkitab DB/b_kjv.db',
      'b_cuv': 'Original Alkitab DB/b_cuv.db',
    },
  );

  await _packageTrack(
    version: version,
    track: AssetReleaseTrack.hymnals,
    outputRoot: outputRoot,
    packager: packager,
    sourceFiles: const {
      'KR': 'Original PDF/KR.pdf',
      'HYMNE': 'Original PDF/HYMNE.pdf',
      'MDR': 'Original PDF/MDR.pdf',
      'ASM-I': 'Original PDF/ASM-I.pdf',
      'ASM-M': 'Original PDF/ASM-M.pdf',
      'ASM-P': 'Original PDF/ASM-P.pdf',
    },
  );

  stdout.writeln('Encrypted release assets written to ${outputRoot.path}');
}

Future<void> _packageTrack({
  required String version,
  required AssetReleaseTrack track,
  required Directory outputRoot,
  required EncryptedAssetPackageService packager,
  required Map<String, String> sourceFiles,
}) async {
  final releaseTag = '${track.name}-$version';
  final trackDir = Directory('${outputRoot.path}/${track.name}');
  await trackDir.create(recursive: true);

  final packages = <Map<String, Object?>>[];

  for (final entry in sourceFiles.entries) {
    final definition = assetDefinitionForCode(
      track == AssetReleaseTrack.bibles
          ? DistributedAssetKind.bible
          : DistributedAssetKind.hymnal,
      entry.key,
    );
    if (definition == null) {
      stderr.writeln('Skipping unknown asset code ${entry.key}');
      continue;
    }

    final sourceFile = File(entry.value);
    if (!await sourceFile.exists()) {
      stderr.writeln('Missing source file: ${sourceFile.path}');
      continue;
    }

    final fileName = '${definition.code.toLowerCase().replaceAll('-', '_')}.gyspkg';
    final outputFile = File('${trackDir.path}/$fileName');
    final packageBytes = packager.buildPackageBytes(await sourceFile.readAsBytes());
    await outputFile.writeAsBytes(packageBytes, flush: true);

    packages.add({
      'code': definition.code,
      'version': version,
      'fileName': fileName,
      'downloadUrl':
          'https://github.com/ThenGB/GYSApp-Data/releases/download/$releaseTag/$fileName',
      'installFileName': definition.installFileName,
      'sizeBytes': await outputFile.length(),
      'checksumSha256': sha256
          .convert(await outputFile.readAsBytes())
          .toString(),
    });
  }

  final manifestFile = File('${trackDir.path}/${track.name}-manifest.json');
  await manifestFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert({
      'track': track.name,
      'releaseTag': releaseTag,
      'publishedAt': DateTime.now().toUtc().toIso8601String(),
      'packages': packages,
    }),
  );
}

Map<String, String> _parseArgs(List<String> args) {
  final result = <String, String>{};
  for (final arg in args) {
    if (!arg.startsWith('--') || !arg.contains('=')) continue;
    final split = arg.substring(2).split('=');
    if (split.length != 2) continue;
    result[split.first] = split.last;
  }
  return result;
}

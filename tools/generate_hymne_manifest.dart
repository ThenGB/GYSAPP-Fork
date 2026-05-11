#!/usr/bin/env dart
import 'dart:convert';
import 'dart:io';

/// Generates hymne_pdf_manifest.json from hymne_index.json
///
/// Usage: dart tools/generate_hymne_manifest.dart
void main() async {
  final indexPath = 'assets/data/index/hymne_index.json';
  final outputPath = 'assets/data/index/hymne_pdf_manifest.json';

  print('Reading $indexPath...');
  final indexFile = File(indexPath);
  if (!indexFile.existsSync()) {
    stderr.writeln('Error: $indexPath does not exist');
    exit(1);
  }

  final indexJson = jsonDecode(await indexFile.readAsString()) as List;
  final songs = indexJson.cast<Map<String, dynamic>>();

  print('Processing ${songs.length} songs...');

  final manifest = <String, dynamic>{
    'bookCode': 'HYMNE',
    'masterPath': 'assets/data/pdf/hymne/hymne_master.pdf',
    'sourceFileCount': songs.length,
    'mappedSongCount': songs.length,
    'pageCount': 0,
    'songs': <String, dynamic>{},
  };

  int maxPage = 0;
  for (final song in songs) {
    final number = song['number'] as String;
    final page = song['page'] as int;
    final pages = song['pages'] as int;
    final title = song['title'] as String;

    if (page > maxPage) {
      maxPage = page + pages - 1;
    }

    // Build source filename from title (similar to KR naming convention)
    // Replace special chars with underscores, remove accents
    final sourceTitle = title
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '_')
        .replaceAll("'", '');
    final sourceFile = '${number.padLeft(3, '0')}_${sourceTitle}.pdf';

    manifest['songs'][number] = {
      'path': 'assets/data/pdf/hymne/hymne_master.pdf',
      'startPage': page,
      'pageCount': pages,
      'source': sourceFile,
    };
  }

  manifest['pageCount'] = maxPage;

  print('Generated manifest with ${manifest['songs'].length} entries');
  print('Total pages: $maxPage');

  final outputFile = File(outputPath);
  await outputFile.writeAsString(JsonEncoder.withIndent('  ').convert(manifest));

  print('✓ Written to $outputPath');
}

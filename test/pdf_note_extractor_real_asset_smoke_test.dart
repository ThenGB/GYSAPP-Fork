import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';

import 'package:church/data/services/pdf_note_extractor.dart';

void main() {
  group('PdfNoteExtractor real-asset smoke', () {
    test('detects notes and holds on first songs of MDR/ASM books', () async {
      final root = Directory.current.path;
      final cases = <({String book, String relativePath, int page, bool expectHold})>[
        (
          book: 'MDR',
          relativePath: 'assets/data/pdf/mdr/MDR.pdf',
          page: 17,
          expectHold: true,
        ),
        (
          book: 'ASM-I',
          relativePath: 'assets/data/pdf/asm_i/ASM-I.pdf',
          page: 1,
          expectHold: false,
        ),
        (
          book: 'ASM-M',
          relativePath: 'assets/data/pdf/asm_m/ASM-M.pdf',
          page: 8,
          expectHold: true,
        ),
        (
          book: 'ASM-P',
          relativePath: 'assets/data/pdf/asm_p/ASM-P.pdf',
          page: 1,
          expectHold: false,
        ),
      ];

      for (final entry in cases) {
        final path = p.join(root, entry.relativePath);
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'Missing test asset: $path');

        final doc = await PdfDocument.openFile(path);
        try {
          final page = doc.pages[entry.page - 1];
          final rawText = await page.loadText();
          expect(rawText, isNotNull, reason: '${entry.book}: failed to load text');

          final profile = entry.book == 'MDR'
              ? ExtractionProfile.mdr
              : ExtractionProfile.standard;
          final result = extractPdfContent(
            rawText!,
            page.width,
            page.height,
            profile: profile,
          );
          final notes = result.notes.where((n) => n.isNote).length;
          final holds = result.notes.where((n) => n.isDot).length;
          // ignore: avoid_print
          print('${entry.book} p${entry.page}: notes=$notes holds=$holds');

          expect(
            notes,
            greaterThan(8),
            reason: '${entry.book}: too few notes detected (notes=$notes)',
          );
          if (entry.expectHold) {
            expect(
              holds,
              greaterThan(0),
              reason: '${entry.book}: no holds detected (holds=$holds)',
            );
          }
        } finally {
          await doc.dispose();
        }
      }
    });
  });
}

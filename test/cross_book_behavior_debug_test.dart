import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';

import 'package:church/data/services/pdf_note_extractor.dart';

void main() {
  test('KR page scan for suspicious top-row detection', () async {
    final root = Directory.current.path;
    final path = p.join(root, 'assets/data/pdf/kr/KR.pdf');
    final doc = await PdfDocument.openFile(path);
    try {
      final maxPages = doc.pages.length < 60 ? doc.pages.length : 60;
      for (int pageNo = 1; pageNo <= maxPages; pageNo++) {
        final page = doc.pages[pageNo - 1];
        final raw = await page.loadText();
        if (raw == null) continue;
        final result = extractPdfContent(
          raw,
          page.width,
          page.height,
          profile: ExtractionProfile.standard,
        );
        if (result.notes.isEmpty) continue;
        final notes = result.notes.where((n) => n.isNote).toList();
        final holds = result.notes.where((n) => n.isDot).toList();
        final minY = result.notes.map((e) => e.yPct).reduce((a, b) => a < b ? a : b);
        final maxY = result.notes.map((e) => e.yPct).reduce((a, b) => a > b ? a : b);
        final highCount = result.notes.where((n) => n.yPct < 12).length;
        if (highCount > 0 || notes.length < 8) {
          // ignore: avoid_print
          print(
            'KR p$pageNo suspicious: total=${result.notes.length} '
            'notes=${notes.length} holds=${holds.length} '
            'high(<12)=$highCount y=[${minY.toStringAsFixed(1)}, ${maxY.toStringAsFixed(1)}]',
          );
        }
      }
    } finally {
      await doc.dispose();
    }
  });

  test('Cross-book extraction snapshot', () async {
    final root = Directory.current.path;
    final cases = <({String book, String relPath, int page, ExtractionProfile profile})>[
      (
        book: 'KR',
        relPath: 'assets/data/pdf/kr/KR.pdf',
        page: 1,
        profile: ExtractionProfile.standard,
      ),
      (
        book: 'MDR',
        relPath: 'assets/data/pdf/mdr/MDR.pdf',
        page: 17,
        profile: ExtractionProfile.mdr,
      ),
      (
        book: 'ASM-I',
        relPath: 'assets/data/pdf/asm_i/ASM-I.pdf',
        page: 1,
        profile: ExtractionProfile.standard,
      ),
      (
        book: 'HYMNE',
        relPath: 'assets/data/pdf/hymne/hymne_master.pdf',
        page: 1,
        profile: ExtractionProfile.standard,
      ),
    ];

    for (final c in cases) {
      final path = p.join(root, c.relPath);
      final doc = await PdfDocument.openFile(path);
      try {
        final page = doc.pages[c.page - 1];
        final raw = await page.loadText();
        expect(raw, isNotNull, reason: 'No raw text for ${c.book}');
        final result = extractPdfContent(
          raw!,
          page.width,
          page.height,
          profile: c.profile,
        );
        final notes = result.notes.where((n) => n.isNote).toList();
        final holds = result.notes.where((n) => n.isDot).toList();
        final minY = result.notes.isEmpty
            ? 0.0
            : result.notes.map((e) => e.yPct).reduce((a, b) => a < b ? a : b);
        final maxY = result.notes.isEmpty
            ? 0.0
            : result.notes.map((e) => e.yPct).reduce((a, b) => a > b ? a : b);
        // ignore: avoid_print
        print(
          '${c.book} p${c.page}: total=${result.notes.length} '
          'notes=${notes.length} holds=${holds.length} y=[${minY.toStringAsFixed(1)}, ${maxY.toStringAsFixed(1)}]',
        );
      } finally {
        await doc.dispose();
      }
    }
  });
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:church/data/services/pdf_note_extractor.dart';

/// Debug MDR dash detection.
void main() {
  test('Debug MDR dash detection on page with MDR staff notation', () async {
    final pdfFile = File('assets/data/pdf/mdr/MDR.pdf');

    if (!pdfFile.existsSync()) {
      debugPrint('MDR PDF not found');
      return;
    }

    try {
      final pdfData = await pdfFile.readAsBytes();
      final document = await PdfDocument.openData(pdfData);

      // Try to locate the same page shown in editor screenshot first.
      int pageIndex = 14; // fallback
      for (int i = 0; i < document.pages.length; i++) {
        final t = await document.pages[i].loadText();
        final full = t?.fullText ?? '';
        if (full.contains('REGINALD HEBER')) {
          pageIndex = i;
          break;
        }
      }

      final page = document.pages[pageIndex];
      final rawText = await page.loadText();

      if (rawText == null || rawText.fullText.isEmpty) {
        debugPrint('Page 15: No text found');
        document.dispose();
        return;
      }

      debugPrint('Page ${pageIndex + 1}: ${rawText.fullText.length} chars');

      // Count MDR characters + private-use histogram
      int f00aCount = 0; // MDR note char
      int f00bCount = 0; // MDR hold char
      int f00eCount = 0; // MDR alternate hold char
      int asciiDashCount = 0;
      final puaCounts = <int, int>{};

      for (int i = 0; i < rawText.fullText.length; i++) {
        final ch = rawText.fullText[i];
        final code = ch.codeUnitAt(0);
        if (code == 0xF00A) f00aCount++;
        if (code == 0xF00B) f00bCount++;
        if (code == 0xF00E) f00eCount++;
        if (code == 0x002D) asciiDashCount++; // ASCII hyphen-minus
        if (code >= 0xE000 && code <= 0xF8FF) {
          puaCounts[code] = (puaCounts[code] ?? 0) + 1;
        }
      }

      debugPrint('MDR chars found:');
      debugPrint('  F00A (note): $f00aCount');
      debugPrint('  F00B (hold/rest): $f00bCount');
      debugPrint('  F00E (hold/rest alt): $f00eCount');
      debugPrint('  ASCII dash (-): $asciiDashCount');
      final sortedPua = puaCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      debugPrint('  Top private-use glyphs:');
      for (final entry in sortedPua.take(12)) {
        final hex = entry.key.toRadixString(16).toUpperCase().padLeft(4, '0');
        debugPrint('    U+$hex = ${entry.value}');
      }

      // Check _isMdrHoldChar function
      debugPrint('\nChecking _isMdrHoldChar:');
      debugPrint('  F00B is MDR hold: ${_isMdrHoldChar(String.fromCharCode(0xF00B))}');
      debugPrint('  ASCII - is MDR hold: ${_isMdrHoldChar('-')}');

      // Extract the full page using MDR profile.
      debugPrint('\nExtracting full page with MDR profile...');
      final result = extractPdfContent(
        rawText,
        page.width,
        page.height,
        profile: ExtractionProfile.mdr,
      );

      debugPrint('Result:');
      debugPrint('  Total notes: ${result.notes.length}');
      debugPrint('  isNote: ${result.notes.where((n) => n.isNote).length}');
      debugPrint('  isDot: ${result.notes.where((n) => n.isDot).length}');
      debugPrint('  isRest: ${result.notes.where((n) => n.isRest).length}');

      // Show some extracted notes
      for (int i = 0; i < result.notes.length.clamp(0, 15); i++) {
        final note = result.notes[i];
        debugPrint('  Note[$i]: str="${note.str}" (U+${note.str.codeUnitAt(0).toRadixString(16).toUpperCase().padLeft(4, '0')}), isNote=${note.isNote}, isDot=${note.isDot}');
      }

      document.dispose();
    } catch (e, st) {
      debugPrint('Error: $e');
      debugPrint('Stack: $st');
    }
  });
}

// Helper functions to test - copied from pdf_note_extractor
bool _isMdrHoldChar(String char) {
  if (char.isEmpty || char.length != 1) return false;
  final code = char.codeUnitAt(0);
  return code == 0xF00B || code == 0xF00E;
}

import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:church/data/services/pdf_note_extractor.dart';

void main() {
  test('Simple note extraction test for song 001', () async {
    final pdfFile = File('assets/data/pdf/kr/001_Pujilah Allah Yang Maha Esa.pdf');
    if (!pdfFile.existsSync()) {
      debugPrint('PDF file not found');
      return;
    }

    final pdfData = await pdfFile.readAsBytes();
    final pdfDocument = await PdfDocument.openData(pdfData);
    final page = pdfDocument.pages[0];

    final rawText = await page.loadText();
    if (rawText == null) {
      debugPrint('Failed to load text');
      return;
    }

    debugPrint('PDF text length: ${rawText.fullText.length}');
    debugPrint('First 200 chars: ${rawText.fullText.substring(0, 200)}');
    debugPrint('Number of char rects: ${rawText.charRects.length}');
    debugPrint('Page dimensions: ${page.width} x ${page.height} points');
    
    // Print first few character positions for debugging
    debugPrint('First 5 character positions:');
    for (int i = 0; i < 5 && i < rawText.charRects.length; i++) {
      final rect = rawText.charRects[i];
      final char = rawText.fullText[i];
      debugPrint('  Char "$char": x=${rect.left.toStringAsFixed(1)}, y=${rect.bottom.toStringAsFixed(1)} (baseline), fontSize=${(rect.top - rect.bottom).toStringAsFixed(1)}');
    }

    final positions = extractNotePositions(rawText, page.width, page.height);
    debugPrint('Extracted ${positions.length} note positions');

    if (positions.isNotEmpty) {
      debugPrint('SUCCESS: Note extraction is working!');
      debugPrint('First 5 note positions:');
      int count = 0;
      positions.forEach((noteIdx, pos) {
        if (count < 5) {
          debugPrint('  Note $noteIdx: xPct=${pos.xPct.toStringAsFixed(2)}%, yPct=${pos.yPct.toStringAsFixed(2)}%');
          count++;
        }
      });
      
      // Save to JSON for comparison
      final Map<String, dynamic> jsonData = {};
      positions.forEach((noteIdx, pos) {
        jsonData[noteIdx.toString()] = {
          'xPct': pos.xPct,
          'yPct': pos.yPct,
        };
      });
      
      final jsonString = jsonEncode(jsonData);
      await File('flutter_note_positions.json').writeAsString(jsonString);
      debugPrint('Saved to flutter_note_positions.json');
    } else {
      debugPrint('FAILED: Still extracting 0 notes');
    }
  });
}
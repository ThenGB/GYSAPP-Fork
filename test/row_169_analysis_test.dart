import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  test('Analyze row at yPct=16.9% specifically', () async {
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

    debugPrint('Analyzing row at yPct=16.9% (first music row)...');
    
    // Find characters in row around yPct=16.9%
    final targetRowY = 16.9;
    final rowChars = <Map<String, dynamic>>[];
    
    for (int i = 0; i < rawText.fullText.length; i++) {
      final ch = rawText.fullText[i];
      if (RegExp(r'[1-7.]').hasMatch(ch)) {
        final rect = rawText.charRects[i];
        final baselineY = rect.bottom;
        final yPct = (1.0 - baselineY / page.height) * 100;
        
        // Check if this character is in the target row
        if ((yPct - targetRowY).abs() < 0.5) {
          rowChars.add({
            'index': i,
            'char': ch,
            'x': rect.left,
            'y': baselineY,
            'fontSize': rect.top - rect.bottom,
            'yPct': yPct,
          });
        }
      }
    }
    
    debugPrint('Found ${rowChars.length} characters in row yPct=16.9%');
    
    // Analyze font sizes
    final fontSizes = rowChars.map((r) => r['fontSize'] as double).toList();
    if (fontSizes.isNotEmpty) {
      final minFontSize = fontSizes.reduce((a, b) => a < b ? a : b);
      final maxFontSize = fontSizes.reduce((a, b) => a > b ? a : b);
      final avgFontSize = fontSizes.reduce((a, b) => a + b) / fontSizes.length;
      
      debugPrint('Font sizes in this row:');
      debugPrint('  Min: $minFontSize');
      debugPrint('  Max: $maxFontSize');
      debugPrint('  Avg: $avgFontSize');
      debugPrint('  Range: ${maxFontSize - minFontSize}');
      
      // Show individual character font sizes
      debugPrint('\nIndividual characters:');
      for (final charData in rowChars) {
        debugPrint('  "${charData['char']}" fontSize=${charData['fontSize']}');
      }
      
      // Calculate dominant font size
      final fontSizeCounts = <double, int>{};
      for (final fs in fontSizes) {
        final key = (fs * 10).round() / 10.0;
        fontSizeCounts[key] = (fontSizeCounts[key] ?? 0) + 1;
      }
      
      final dominantFontSize = fontSizeCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      
      debugPrint('\nDominant font size: $dominantFontSize');
      
      // Check how many would pass ±3.0pt filter (current Flutter setting)
      final passedFilter = fontSizes.where((fs) => (fs - dominantFontSize).abs() < 3.0).length;
      debugPrint('Characters passing ±3.0pt filter: $passedFilter / ${fontSizes.length}');
      
      // Check how many would pass ±1.5pt filter (web app setting)
      final passedWebFilter = fontSizes.where((fs) => (fs - dominantFontSize).abs() < 1.5).length;
      debugPrint('Characters passing ±1.5pt filter (web): $passedWebFilter / ${fontSizes.length}');
      
      if (passedFilter < fontSizes.length) {
        debugPrint('\n[PROBLEM] Some characters in first music row are filtered out by font size!');
        debugPrint('This causes Flutter to miss the first music row');
      }
    }
  });
}
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  test('Raw character position analysis for song 001', () async {
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

    debugPrint('Page dimensions: ${page.width} x ${page.height} points');
    debugPrint('Total characters: ${rawText.fullText.length}');
    
    // Find all note characters (1-7, .) and their positions
    final noteChars = <Map<String, dynamic>>[];
    for (int i = 0; i < rawText.fullText.length; i++) {
      final ch = rawText.fullText[i];
      if (RegExp(r'[1-7.]').hasMatch(ch)) {
        final rect = rawText.charRects[i];
        final baselineY = rect.bottom;
        final yPct = (1.0 - baselineY / page.height) * 100;
        final xPct = ((rect.left + rect.right) / 2) / page.width * 100;
        
        noteChars.add({
          'index': i,
          'char': ch,
          'x': rect.left,
          'y': baselineY,
          'fontSize': rect.top - rect.bottom,
          'xPct': xPct,
          'yPct': yPct,
        });
      }
    }
    
    debugPrint('Total note characters (1-7,.): ${noteChars.length}');
    
    // Group by approximate Y position (rows)
    final rows = <double, List<Map<String, dynamic>>>{};
    for (final note in noteChars) {
      final rowY = double.parse((note['yPct'] as double).toStringAsFixed(1));
      if (!rows.containsKey(rowY)) {
        rows[rowY] = [];
      }
      rows[rowY]!.add(note);
    }
    
    debugPrint('Found ${rows.length} distinct rows based on Y position:');
    final sortedRowYs = rows.keys.toList()..sort();
    for (final rowY in sortedRowYs) {
      final notesInRow = rows[rowY]!;
      final digitsInRow = notesInRow.where((n) => RegExp(r'[1-7]').hasMatch(n['char'] as String)).length;
      debugPrint('  Row yPct=$rowY%: ${notesInRow.length} chars, $digitsInRow digits');
      
      // Show first few chars in each row
      if (notesInRow.isNotEmpty) {
        final firstChars = notesInRow.take(5).map((n) => n['char']).join('');
        debugPrint('    First chars: "$firstChars"');
      }
    }
    
    // Specifically check for row around 16.9% (first music row in web app)
    final targetRow = 16.9;
    final nearTargetRows = sortedRowYs.where((y) => (y - targetRow).abs() < 2.0);
    
    debugPrint('\nLooking for rows near yPct=16.9% (web app first music row):');
    if (nearTargetRows.isNotEmpty) {
      for (final rowY in nearTargetRows) {
        debugPrint('  Found row at yPct=$rowY% with ${rows[rowY]!.length} chars');
        debugPrint('  Characters: ${rows[rowY]!.map((n) => n['char']).join()}');
      }
    } else {
      debugPrint('  No rows found near yPct=16.9%');
      debugPrint('  This explains why Flutter misses the first music row!');
    }
  });
}
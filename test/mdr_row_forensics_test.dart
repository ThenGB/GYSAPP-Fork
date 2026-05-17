import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart';

class _RawChar {
  final String ch;
  final double left;
  final double bottom;
  final double fontSize;

  _RawChar({
    required this.ch,
    required this.left,
    required this.bottom,
    required this.fontSize,
  });
}

class _Row {
  final double y;
  final List<_RawChar> chars;
  _Row(this.y, this.chars);
}

void main() {
  test('MDR row forensics (visual notation rows)', () async {
    final pdfFile = File('assets/data/pdf/mdr/MDR.pdf');
    if (!pdfFile.existsSync()) {
      debugPrint('MDR PDF not found');
      return;
    }

    final data = await pdfFile.readAsBytes();
    final doc = await PdfDocument.openData(data);
    try {
      int pageIndex = 16; // page 17 fallback
      for (int i = 0; i < doc.pages.length; i++) {
        final t = await doc.pages[i].loadText();
        final full = t?.fullText ?? '';
        if (full.contains('REGINALD HEBER')) {
          pageIndex = i;
          break;
        }
      }

      final page = doc.pages[pageIndex];
      final raw = await page.loadText();
      if (raw == null) {
        debugPrint('No text for page');
        return;
      }
      debugPrint('Page ${pageIndex + 1}: chars=${raw.fullText.length}');

      final rows = <_Row>[];
      for (int i = 0; i < raw.fullText.length; i++) {
        final ch = raw.fullText[i];
        if (ch == '\n' || ch == '\r') continue;
        final rect = raw.charRects[i];
        final rc = _RawChar(
          ch: ch,
          left: rect.left,
          bottom: rect.bottom,
          fontSize: rect.top - rect.bottom,
        );

        _Row? found;
        for (final row in rows) {
          if ((row.y - rc.bottom).abs() <= 2.0) {
            found = row;
            break;
          }
        }
        if (found == null) {
          rows.add(_Row(rc.bottom, [rc]));
        } else {
          found.chars.add(rc);
        }
      }

      rows.sort((a, b) => b.y.compareTo(a.y));
      debugPrint('Row count: ${rows.length}');

      for (final row in rows) {
        row.chars.sort((a, b) => a.left.compareTo(b.left));

        int digitCount = 0;
        int holdCount = 0;
        int puaCount = 0;
        final puaMap = <int, int>{};

        for (final c in row.chars) {
          final code = c.ch.codeUnitAt(0);
          if (RegExp(r'^[1-7]$').hasMatch(c.ch)) digitCount++;
          if ('-‐‑‒–—―−'.contains(c.ch) || code == 0xF00B || code == 0xF00E) {
            holdCount++;
          }
          if (code >= 0xE000 && code <= 0xF8FF) {
            puaCount++;
            puaMap[code] = (puaMap[code] ?? 0) + 1;
          }
        }

        if (digitCount == 0 && holdCount == 0) continue;

        final meanFont = row.chars.fold<double>(0, (s, c) => s + c.fontSize) /
            row.chars.length;
        final rawText = row.chars.map((c) => c.ch).join();
        final preview = rawText.length > 120 ? '${rawText.substring(0, 120)}...' : rawText;
        final sortedPua = puaMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final puaPreview = sortedPua
            .take(6)
            .map((e) =>
                'U+${e.key.toRadixString(16).toUpperCase().padLeft(4, '0')}=${e.value}')
            .join(', ');

        debugPrint(
          'row y=${row.y.toStringAsFixed(1)} '
          'n=${row.chars.length} fs=${meanFont.toStringAsFixed(2)} '
          'digits=$digitCount holds=$holdCount pua=$puaCount',
        );
        if (puaPreview.isNotEmpty) debugPrint('  pua: $puaPreview');
        debugPrint('  text: $preview');
      }
    } finally {
      doc.dispose();
    }
  });
}


import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';

class _RawChar {
  final String ch;
  final double left;
  final double bottom;
  final double fontSize;
  _RawChar(this.ch, this.left, this.bottom, this.fontSize);
}

class _Row {
  final double y;
  final List<_RawChar> chars;
  _Row(this.y, this.chars);
}

void main() {
  test('KR row forensics on suspicious page', () async {
    final root = Directory.current.path;
    final path = p.join(root, 'assets/data/pdf/kr/KR.pdf');
    final doc = await PdfDocument.openFile(path);
    try {
      const pageNo = 8;
      final page = doc.pages[pageNo - 1];
      final raw = await page.loadText();
      if (raw == null) {
        debugPrint('No raw text');
        return;
      }

      final rows = <_Row>[];
      for (int i = 0; i < raw.fullText.length; i++) {
        final ch = raw.fullText[i];
        if (ch == '\n' || ch == '\r') continue;
        final rect = raw.charRects[i];
        final rc = _RawChar(ch, rect.left, rect.bottom, rect.top - rect.bottom);

        _Row? target;
        for (final r in rows) {
          if ((r.y - rc.bottom).abs() <= 2.0) {
            target = r;
            break;
          }
        }
        if (target == null) {
          rows.add(_Row(rc.bottom, [rc]));
        } else {
          target.chars.add(rc);
        }
      }

      rows.sort((a, b) => b.y.compareTo(a.y));
      debugPrint('KR p$pageNo rows=${rows.length}');

      for (final row in rows) {
        row.chars.sort((a, b) => a.left.compareTo(b.left));
        final text = row.chars.map((c) => c.ch).join();
        final digits = RegExp(r'[1-7]').allMatches(text).length;
        final holds = RegExp(r'[-‐‑‒–—―−.]').allMatches(text).length;
        if (digits < 2 && holds < 2) continue;
        final meanFs = row.chars.fold<double>(0, (s, c) => s + c.fontSize) / row.chars.length;
        final yPct = (1.0 - row.y / page.height) * 100;
        final preview = text.length > 120 ? '${text.substring(0, 120)}...' : text;
        debugPrint(
          'row y=${row.y.toStringAsFixed(1)} yPct=${yPct.toStringAsFixed(1)} '
          'n=${row.chars.length} fs=${meanFs.toStringAsFixed(2)} '
          'digits=$digits holds=$holds',
        );
        debugPrint('  $preview');
      }
    } finally {
      await doc.dispose();
    }
  });
}


import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:pdfrx/pdfrx.dart';

/// Position of a note on a PDF page, as percentage of page dimensions.
typedef NotePosition = ({double xPct, double yPct});

/// Detailed note information including position and label.
class NoteInfo {
  final int idx;
  final double xPct;
  final double yPct;
  final double rowY;
  final String str;
  final bool isNote;
  final bool isDot;
  final bool isRest;

  NoteInfo({
    required this.idx,
    required this.xPct,
    required this.yPct,
    required this.rowY,
    required this.str,
    required this.isNote,
    required this.isDot,
    required this.isRest,
  });

  Map<String, dynamic> toJson() => {
    'idx': idx,
    'xPct': xPct,
    'yPct': yPct,
    'rowY': rowY,
    'str': str,
    'isNote': isNote,
    'isDot': isDot,
    'isRest': isRest,
  };

  factory NoteInfo.fromJson(Map<String, dynamic> json) => NoteInfo(
    idx: json['idx'],
    xPct: (json['xPct'] as num).toDouble(),
    yPct: (json['yPct'] as num).toDouble(),
    rowY: (json['rowY'] as num).toDouble(),
    str: json['str'],
    isNote: json['isNote'],
    isDot: json['isDot'],
    isRest: json['isRest'],
  );
}

/// Result of PDF text extraction including notes, detected key, and tempo.
class PdfExtractionResult {
  final List<NoteInfo> notes;
  final String? detectedKey;
  final double? detectedTempo;

  PdfExtractionResult({required this.notes, this.detectedKey, this.detectedTempo});

  Map<String, dynamic> toJson() => {
    'notes': notes.map((n) => n.toJson()).toList(),
    'detectedKey': detectedKey,
    'detectedTempo': detectedTempo,
  };

  factory PdfExtractionResult.fromJson(Map<String, dynamic> json) => PdfExtractionResult(
    notes: (json['notes'] as List).map((n) => NoteInfo.fromJson(n)).toList(),
    detectedKey: json['detectedKey'],
    detectedTempo: (json['detectedTempo'] as num?)?.toDouble(),
  );
}

/// Extracts note positions from a PDF page's raw text.
///
/// Replicates the JavaScript note-extraction algorithm from
/// `gyschordweb/js/viewer-core.js` (`extractPageNotes` function).
/// Returns a map of noteIdx → (xPct, yPct) where percentages are 0–100.
///
/// [rawText] comes from `PdfPage.loadText()`.
/// [pageWidth] and [pageHeight] come from `PdfPage.width` and `PdfPage.height`.
///
/// IMPORTANT: yPct is the raw Y position of the note character (% from top of
/// page). The chord-badge renderer applies the visual offset above the note
/// no offset is applied here.
Future<Map<int, NotePosition>> extractNotePositionsAsync(
  PdfPageRawText rawText,
  double pageWidth,
  double pageHeight,
) async {
  return compute((args) {
    final result = extractPdfContent(
      args['rawText'] as PdfPageRawText,
      args['pageWidth'] as double,
      args['pageHeight'] as double,
    );
    return {
      for (final info in result.notes) info.idx: (xPct: info.xPct, yPct: info.yPct),
    };
  }, {
    'rawText': rawText,
    'pageWidth': pageWidth,
    'pageHeight': pageHeight,
  });
}

Map<int, NotePosition> extractNotePositions(
  PdfPageRawText rawText,
  double pageWidth,
  double pageHeight,
) {
  final result = extractPdfContent(rawText, pageWidth, pageHeight);
  return {
    for (final info in result.notes) info.idx: (xPct: info.xPct, yPct: info.yPct),
  };
}

/// Extracts detailed content from a PDF page's raw text.
Future<PdfExtractionResult> extractPdfContentAsync(
  PdfPageRawText rawText,
  double pageWidth,
  double pageHeight,
) async {
  return compute((args) {
    return extractPdfContent(
      args['rawText'] as PdfPageRawText,
      args['pageWidth'] as double,
      args['pageHeight'] as double,
    );
  }, {
    'rawText': rawText,
    'pageWidth': pageWidth,
    'pageHeight': pageHeight,
  });
}

PdfExtractionResult extractPdfContent(
  PdfPageRawText rawText,
  double pageWidth,
  double pageHeight,
) {
  final text = rawText.fullText;
  final rects = rawText.charRects;
  if (text.isEmpty || rects.length != text.length) {
    return PdfExtractionResult(notes: []);
  }

  // Step 0: Detect Key (e.g., "1 = C" or "Do = F" or "1=Bes")
  // Mirror gyschordweb detection logic: scan the first part of the text layer.
  String? detectedKey;
  final keyRegex = RegExp(
    r'(?:1|Do|do)\s*[=:]\s*([A-G](?:[#♯b♭]|is|es)?)',
    caseSensitive: false,
  );
  
  // Search the entire text layer but prioritize the beginning
  final keyMatch = keyRegex.firstMatch(text);
  if (keyMatch != null) {
    var rawKey = keyMatch.group(1)?.toLowerCase() ?? '';
    // Normalize notation to standard symbols
    rawKey = rawKey
        .replaceAll('♯', '#')
        .replaceAll('♭', 'b')
        .replaceAll('is', '#')
        .replaceAll('es', 'b');

    // Special case for 'bes' (Bb) and 'as' (Ab) handled by is/es above
    // but ensuring uppercase root
    if (rawKey.length > 1) {
      detectedKey = rawKey[0].toUpperCase() + rawKey.substring(1);
    } else {
      detectedKey = rawKey.toUpperCase();
    }

    log('Detected PDF Key: $detectedKey from text: "${keyMatch.group(0)}"', name: 'PdfNoteExtractor');
  }

  // Step 0.1: Detect Tempo (e.g., "MM = 76" or "♩ = 120" or "M.M. 76")
  // Mirror gyschordweb detection logic with added robustness for PDF text artifacts.
  double? detectedTempo;

  // Normalize text to handle multiple spaces and trim
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();

  // Pattern 1: Musical symbols (J, j, Q, q, ♩, ♪) with optional = or :
  // Mirror: /(?:^|[\s(])(?:J|j|Q|q|♩|♪|𝅘𝅥|𝅘𝅥𝅮)\s*[:=]\s*(\d{2,3})(?=\D|$)/
  final symbolRegex = RegExp(
    r'(?:^|[\s(])(?:J|j|Q|q|♩|♪)\s*[:=]\s*(\d{2,3})(?=\D|$)',
    caseSensitive: false,
  );
  final symbolMatch = symbolRegex.firstMatch(normalized);
  if (symbolMatch != null) {
    detectedTempo = double.tryParse(symbolMatch.group(1) ?? '');
    if (detectedTempo != null) {
      log('Detected PDF Tempo (symbol): $detectedTempo from "${symbolMatch.group(0)}"', name: 'PdfNoteExtractor');
    }
  }

  // Pattern 2: BPM label (tempo, tempi, bpm)
  // Mirror: /(?:tempo|tempi|bpm)\s*[:=]?\s*(\d{2,3})\b/
  if (detectedTempo == null) {
    final bpmRegex = RegExp(
      r'(?:tempo|tempi|bpm)\s*[:=]?\s*(\d{2,3})\b',
      caseSensitive: false,
    );
    final bpmMatch = bpmRegex.firstMatch(normalized);
    if (bpmMatch != null) {
      detectedTempo = double.tryParse(bpmMatch.group(1) ?? '');
      if (detectedTempo != null) {
        log('Detected PDF Tempo (BPM): $detectedTempo from "${bpmMatch.group(0)}"', name: 'PdfNoteExtractor');
      }
    }
  }

  // Pattern 3: Loose match (standalone = followed by number)
  // Mirror: /(?:^|[^0-9A-Za-z])=\s*(\d{2,3})\b/
  if (detectedTempo == null) {
    final looseRegex = RegExp(r'(?:^|[^0-9A-Za-z])=\s*(\d{2,3})\b');
    final looseMatch = looseRegex.firstMatch(normalized);
    if (looseMatch != null) {
      detectedTempo = double.tryParse(looseMatch.group(1) ?? '');
      if (detectedTempo != null) {
        log('Detected PDF Tempo (loose): $detectedTempo from "${looseMatch.group(0)}"', name: 'PdfNoteExtractor');
      }
    }
  }

  // Pattern 4: MM/M.M. style (fallback)
  // Mirror: /(?:MM|M\.M\.|♩)\s+(\d{2,3})/
  if (detectedTempo == null) {
    final mmRegex = RegExp(r'(?:MM|M\.M\.|♩)\s+(\d{2,3})', caseSensitive: false);
    final mmMatch = mmRegex.firstMatch(normalized);
    if (mmMatch != null) {
      detectedTempo = double.tryParse(mmMatch.group(1) ?? '');
      if (detectedTempo != null) {
        log('Detected PDF Tempo (MM): $detectedTempo from "${mmMatch.group(0)}"', name: 'PdfNoteExtractor');
      }
    }
  }

  // Step 1: Build note-like visual rows.
  // pdf.js ignores mixed text items such as "4/4 Es = 1 (3 mol)" because the
  // item is not purely made of notation characters. pdfrx exposes character
  // rectangles, so we recreate that behavior by grouping characters into visual
  // rows and accepting only rows whose visible text is 0-7, dots, and spaces.
  final rawRows = <_RawRow>[];
  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (ch == '\n' || ch == '\r') continue;
    final rect = rects[i];
    final rawChar = _RawChar(
      str: ch,
      left: rect.left,
      right: rect.right,
      bottom: rect.bottom,
      fontSize: rect.top - rect.bottom,
    );
    final row = rawRows
        .where((r) => (r.y - rect.bottom).abs() < 2.0)
        .firstOrNull;
    if (row != null) {
      row.chars.add(rawChar);
    } else {
      rawRows.add(_RawRow(y: rect.bottom, chars: [rawChar]));
    }
  }

  final items = <_TextItem>[];
  for (final row in rawRows) {
    row.chars.sort((a, b) => a.left.compareTo(b.left));
    final rowText = row.chars.map((c) => c.str).join().trim();
    if (rowText.isEmpty ||
        !_multiNotePattern.hasMatch(rowText) ||
        !_containsDigitNotePattern.hasMatch(rowText)) {
      continue;
    }

    final chars = row.chars
        .where((c) => _singleNotePattern.hasMatch(c.str))
        .map(
          (c) => _CharItem(
            str: c.str,
            left: c.left,
            right: c.right,
            bottom: c.bottom,
            fontSize: c.fontSize,
          ),
        )
        .toList();
    if (chars.isEmpty) continue;

    final digitChars = chars.where((c) => _digitNotePattern.hasMatch(c.str));
    final fontSizeSource = digitChars.isNotEmpty ? digitChars : chars;
    items.add(
      _TextItem(
        str: rowText,
        bottom: _median(fontSizeSource.map((c) => c.bottom).toList()),
        fontSize: _dominantRoundedFontSize(
          fontSizeSource.map((c) => c.fontSize),
        ),
        chars: chars,
      ),
    );
  }
  if (items.isEmpty) return PdfExtractionResult(notes: [], detectedKey: detectedKey);

  // Step 2: Find the dominant font size among notation candidates.
  final candidateItems = items
      .where((item) => _multiNotePattern.hasMatch(item.str))
      .where((item) => _containsDigitNotePattern.hasMatch(item.str))
      .toList();
  if (candidateItems.isEmpty) return PdfExtractionResult(notes: [], detectedKey: detectedKey);

  final dominantFontSize = _dominantRoundedFontSize(
    candidateItems.map((item) => item.fontSize),
  );
  const fontSizeTolerance = 1.5;

  // Step 3: Keep only note-like items at the dominant notation font size.
  final filtered = items
      .where((item) => _multiNotePattern.hasMatch(item.str))
      .where(
        (item) => (item.fontSize - dominantFontSize).abs() < fontSizeTolerance,
      )
      .toList();

  // Step 4: Expand multi-char items to individual characters using per-char rects.
  final noteItems = <_TextItem>[];
  for (final item in filtered) {
    for (final ch in item.chars) {
      noteItems.add(
        _TextItem(
          str: ch.str,
          bottom: item.bottom,
          fontSize: item.fontSize,
          chars: [ch],
        ),
      );
    }
  }

  // Step 5: Group into rows by bottom coordinate (baseline Y), ±2pt tolerance.
  // In PDF coords, higher bottom = visually higher on page → sort descending.
  // This matches gyschordweb's yTolerance = 2.0.
  final rows = <_Row>[];
  final sorted = noteItems..sort((a, b) => b.bottom.compareTo(a.bottom));
  for (final item in sorted) {
    final row = rows.where((r) => (r.y - item.bottom).abs() < 2.0).firstOrNull;
    if (row != null) {
      row.items.add(item);
    } else {
      rows.add(_Row(y: item.bottom, items: [item]));
    }
  }

  // Step 6: Keep only rows with at least 2 digit notes (1-7).
  // This avoids stray numbers such as verse labels and page numbers.
  final musicRows = rows
      .where(
        (r) =>
            r.items
                .where((item) => _digitNotePattern.hasMatch(item.str))
                .length >=
            2,
      )
      .toList();

  // Step 7: Build noteIdx-to-position and NoteInfo list.
  // xPct: center of char horizontally, using left edge + half width for better accuracy.
  // yPct: convert PDF baseline Y to % from TOP of page — NO offset applied here.
  //       Offset is applied at badge render time.
  // Matches gyschordweb:
  //   xPct = ((item.x + item.w / 2) / pageWidth) * 100
  //   yPct = ((1 - item.y / pageHeight) * 100)   [item.y = baseline]
  final noteInfos = <NoteInfo>[];
  int noteIdx = 0;
  for (final row in musicRows) {
    for (final item
        in row.items..sort(
          (a, b) => a.chars.single.left.compareTo(b.chars.single.left),
        )) {
      final char = item.chars.single;
      final charWidth = char.right - char.left;
      final centerX = char.left + (charWidth / 2);
      final baselineY = item.bottom;

      final xPct = centerX / pageWidth * 100;
      final yPct = (1.0 - baselineY / pageHeight) * 100;

      final clampedXPct = xPct.clamp(1.0, 99.0);
      final clampedYPct = yPct.clamp(1.0, 99.0);
      final isNote = _digitNotePattern.hasMatch(item.str);
      final isDot = item.str == '.';
      final isRest = item.str == '0';
      noteInfos.add(
        NoteInfo(
          idx: noteIdx,
          xPct: clampedXPct,
          yPct: clampedYPct,
          rowY: row.y,
          str: item.str,
          isNote: isNote,
          isDot: isDot,
          isRest: isRest,
        ),
      );
      noteIdx++;
    }
  }
  return PdfExtractionResult(
    notes: noteInfos,
    detectedKey: detectedKey,
    detectedTempo: detectedTempo,
  );
}

final _singleNotePattern = RegExp(r'^[0-7.]$');
final _multiNotePattern = RegExp(r'^[0-7.\s]+$');
final _digitNotePattern = RegExp(r'^[1-7]$');
final _containsDigitNotePattern = RegExp(r'[1-7]');

class _TextItem {
  final String str;
  final double bottom;
  final double fontSize;
  final List<_CharItem> chars;

  _TextItem({
    required this.str,
    required this.bottom,
    required this.fontSize,
    required this.chars,
  });
}

class _CharItem {
  final String str;
  final double left;
  final double right;
  final double bottom;
  final double fontSize;

  _CharItem({
    required this.str,
    required this.left,
    required this.right,
    required this.bottom,
    required this.fontSize,
  });
}

class _RawChar {
  final String str;
  final double left;
  final double right;
  final double bottom;
  final double fontSize;

  _RawChar({
    required this.str,
    required this.left,
    required this.right,
    required this.bottom,
    required this.fontSize,
  });
}

class _RawRow {
  final double y;
  final List<_RawChar> chars;
  _RawRow({required this.y, required this.chars});
}

class _Row {
  final double y;
  final List<_TextItem> items;
  _Row({required this.y, required this.items});
}

double _dominantRoundedFontSize(Iterable<double> sizes) {
  final counts = <double, int>{};
  for (final size in sizes) {
    final key = (size * 10).round() / 10.0;
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}

double _median(List<double> values) {
  values.sort();
  final middle = values.length ~/ 2;
  if (values.length.isOdd) return values[middle];
  return (values[middle - 1] + values[middle]) / 2.0;
}

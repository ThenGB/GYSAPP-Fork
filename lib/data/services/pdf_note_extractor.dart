import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:pdfrx/pdfrx.dart';

/// Position of a note on a PDF page, as percentage of page dimensions.
typedef NotePosition = ({double xPct, double yPct});

/// A lyric text line detected on a PDF page: the visible text of one visual
/// row (baseline grouped), its start position and width as percentages of the
/// page width.  Mirrors gyschordweb's `extractLyricLines` output and is used
/// by the text-mode chord layout to position chords over lyric syllables.
class PdfLyricLine {
  final double y;
  final String text;
  final double startPct;
  final double widthPct;

  const PdfLyricLine({
    required this.y,
    required this.text,
    required this.startPct,
    required this.widthPct,
  });
}

enum ExtractionProfile { standard, mdr, krLegacy }

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

  PdfExtractionResult({
    required this.notes,
    this.detectedKey,
    this.detectedTempo,
  });

  Map<String, dynamic> toJson() => {
    'notes': notes.map((n) => n.toJson()).toList(),
    'detectedKey': detectedKey,
    'detectedTempo': detectedTempo,
  };

  factory PdfExtractionResult.fromJson(Map<String, dynamic> json) =>
      PdfExtractionResult(
        notes: (json['notes'] as List)
            .map((n) => NoteInfo.fromJson(n))
            .toList(),
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
  {ExtractionProfile profile = ExtractionProfile.standard}
) async {
  return compute((args) {
    final profileIndex = args['profileIndex'] as int;
    final result = extractPdfContent(
      args['rawText'] as PdfPageRawText,
      args['pageWidth'] as double,
      args['pageHeight'] as double,
      profile: ExtractionProfile.values[profileIndex],
    );
    return {
      for (final info in result.notes)
        info.idx: (xPct: info.xPct, yPct: info.yPct),
    };
  }, {
    'rawText': rawText,
    'pageWidth': pageWidth,
    'pageHeight': pageHeight,
    'profileIndex': profile.index,
  });
}

Map<int, NotePosition> extractNotePositions(
  PdfPageRawText rawText,
  double pageWidth,
  double pageHeight,
  {ExtractionProfile profile = ExtractionProfile.standard}
) {
  final result = extractPdfContent(rawText, pageWidth, pageHeight, profile: profile);
  return {
    for (final info in result.notes)
      info.idx: (xPct: info.xPct, yPct: info.yPct),
  };
}

/// Extracts lyric text lines from a PDF page's raw text.
///
/// Mirrors gyschordweb's `extractLyricLines` (lyrics-viewer.js): groups text
/// characters into visual rows by baseline Y (±2pt), drops rows that look like
/// digit-notation rows (`0-7 . -`), and keeps rows that contain letters.
/// Each line reports its text plus start/width percentages of the page width
/// so chords can be placed at `(note.xPct - startPct) / widthPct`.
List<PdfLyricLine> extractLyricLines(PdfPageRawText rawText, double pageWidth) {
  final text = rawText.fullText;
  final rects = rawText.charRects;
  if (text.isEmpty || rects.length != text.length || pageWidth <= 0) {
    return const [];
  }

  // Group characters into visual rows (baseline Y with ±2pt tolerance).
  final rows = <_LyricRow>[];
  final rowsByBucket = <int, _LyricRow>{};
  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (ch == '\n' || ch == '\r') continue;
    final rect = rects[i];
    final row = _findLyricRow(rowsByBucket: rowsByBucket, y: rect.bottom);
    if (row != null) {
      row.chars.add(_LyricChar(str: ch, left: rect.left, right: rect.right));
    } else {
      final newRow = _LyricRow(y: rect.bottom, chars: [
        _LyricChar(str: ch, left: rect.left, right: rect.right),
      ]);
      rows.add(newRow);
      _addLyricRow(rowsByBucket: rowsByBucket, row: newRow);
    }
  }

  final result = <PdfLyricLine>[];
  for (final row in rows) {
    row.chars.sort((a, b) => a.left.compareTo(b.left));
    final rowText = row.chars.map((c) => c.str).join().trim();
    if (rowText.isEmpty || !row.chars.any((c) => _isLetterChar(c.str))) {
      continue;
    }
    // Drop rows that are (mostly) digit-notation — mirror gyschordweb's
    // `digitRe = /^[0-7.\s]+$/` test on each PDF text item.
    if (row.chars.every((c) => _digitZeroToSevenPattern.hasMatch(c.str) || c.str == ' ' || c.str == '.')) {
      continue;
    }
    final startX = row.chars.first.left;
    final endX = row.chars.fold<double>(startX, (m, c) => c.right > m ? c.right : m);
    result.add(
      PdfLyricLine(
        y: row.y,
        text: rowText,
        startPct: startX / pageWidth * 100,
        widthPct: (endX - startX) / pageWidth * 100,
      ),
    );
  }
  return result;
}

bool _isLetterChar(String ch) {
  if (ch.isEmpty) return false;
  final code = ch.codeUnitAt(0);
  return (code >= 0x41 && code <= 0x5A) || // A-Z
      (code >= 0x61 && code <= 0x7A) || // a-z
      code > 0x7F; // any non-ASCII letter/diacritic (Indonesian lyrics)
}

class _LyricChar {
  final String str;
  final double left;
  final double right;
  _LyricChar({required this.str, required this.left, required this.right});
}

class _LyricRow {
  final double y;
  final List<_LyricChar> chars;
  _LyricRow({required this.y, required this.chars});
}

const double _lyricRowTolerance = 2.0;
const double _lyricRowBucketSize = 2.0;

int _lyricRowBucket(double y) => (y / _lyricRowBucketSize).round();

_LyricRow? _findLyricRow({
  required Map<int, _LyricRow> rowsByBucket,
  required double y,
}) {
  final bucket = _lyricRowBucket(y);
  for (final b in [bucket - 1, bucket, bucket + 1]) {
    final row = rowsByBucket[b];
    if (row != null && (row.y - y).abs() < _lyricRowTolerance) {
      return row;
    }
  }
  return null;
}

void _addLyricRow({
  required Map<int, _LyricRow> rowsByBucket,
  required _LyricRow row,
}) {
  rowsByBucket[_lyricRowBucket(row.y)] = row;
}

/// Extracts detailed content from a PDF page's raw text.
Future<PdfExtractionResult> extractPdfContentAsync(
  PdfPageRawText rawText,
  double pageWidth,
  double pageHeight,
  {ExtractionProfile profile = ExtractionProfile.standard}
) async {
  return compute((args) {
    final profileIndex = args['profileIndex'] as int;
    return extractPdfContent(
      args['rawText'] as PdfPageRawText,
      args['pageWidth'] as double,
      args['pageHeight'] as double,
      profile: ExtractionProfile.values[profileIndex],
    );
  }, {
    'rawText': rawText,
    'pageWidth': pageWidth,
    'pageHeight': pageHeight,
    'profileIndex': profile.index,
  });
}

PdfExtractionResult extractPdfContent(
  PdfPageRawText rawText,
  double pageWidth,
  double pageHeight,
  {ExtractionProfile profile = ExtractionProfile.standard}
) {
  bool isHoldSymbol(String char) => _isHoldSymbol(char, profile: profile);
  bool isHoldOrRestSymbol(String char) =>
      isHoldSymbol(char) || char == '0' || _isMdrHoldChar(char);
  bool isNoteSymbol(String char) => _digitNotePattern.hasMatch(char);
  bool isDetachedHoldRowSymbol(String char) {
    if (profile == ExtractionProfile.mdr) {
      return isHoldSymbol(char) || char == '0' || _isMdrHoldChar(char);
    }
    // Standard books: detached rows can also be dash holds.
    return _standardDetachedHoldPattern.hasMatch(char) || char == '0';
  }
  final holdRowMaxDistance =
      profile == ExtractionProfile.mdr ? _mdrHoldRowMaxDistance : _standardHoldRowMaxDistance;
  bool isNotationChar(String char) {
    if (char.isEmpty) return false;
    if (_digitZeroToSevenPattern.hasMatch(char)) return true;
    if (isHoldSymbol(char)) return true;
    if (_isMdrHoldChar(char)) return true;
    return false;
  }

  final text = rawText.fullText;
  final rects = rawText.charRects;
  if (text.isEmpty || rects.length != text.length) {
    return PdfExtractionResult(notes: []);
  }

  // Step 0: Detect Key (e.g., "1 = C" or "Do = F" or "1=Bes")
  // Mirror gyschordweb detection logic: scan the first part of the text layer.
  String? detectedKey;
  // Search the entire text layer but prioritize the beginning
  final keyMatch = _keyRegex.firstMatch(text);
  if (keyMatch != null) {
    var rawKey = (keyMatch.group(1) ?? keyMatch.group(2) ?? '').toLowerCase();
    // Normalize notation to standard symbols.
    rawKey = rawKey.replaceAll('♯', '#').replaceAll('♭', 'b');
    if (rawKey.length >= 2) {
      final root = rawKey[0];
      final suffix = rawKey.substring(1);
      if (suffix == 'is') {
        rawKey = '$root#';
      } else if (suffix == 'es' || suffix == 's' || suffix == 'b') {
        rawKey = '${root}b';
      }
    }

    // Special case for 'bes' (Bb) and 'as' (Ab) handled by is/es above
    // but ensuring uppercase root
    if (rawKey.length > 1) {
      detectedKey = rawKey[0].toUpperCase() + rawKey.substring(1);
    } else {
      detectedKey = rawKey.toUpperCase();
    }

    log(
      'Detected PDF Key: $detectedKey from text: "${keyMatch.group(0)}"',
      name: 'PdfNoteExtractor',
    );
  }

  // Step 0.1: Detect Tempo (e.g., "MM = 76" or "♩ = 120" or "M.M. 76")
  // Mirror gyschordweb detection logic with added robustness for PDF text artifacts.
  double? detectedTempo;

  // Normalize text to handle multiple spaces and trim
  final normalized = text.replaceAll(_whitespaceRegex, ' ').trim();

  // Pattern 1: Musical symbols (J, j, Q, q, ♩, ♪) with optional = or :
  // Mirror: /(?:^|[\s(])(?:J|j|Q|q|♩|♪|𝅘𝅥|𝅘𝅥𝅮)\s*[:=]\s*(\d{2,3})(?=\D|$)/
  final symbolMatch = _tempoSymbolRegex.firstMatch(normalized);
  if (symbolMatch != null) {
    detectedTempo = double.tryParse(symbolMatch.group(1) ?? '');
    if (detectedTempo != null) {
      log(
        'Detected PDF Tempo (symbol): $detectedTempo from "${symbolMatch.group(0)}"',
        name: 'PdfNoteExtractor',
      );
    }
  }

  // Pattern 2: BPM label (tempo, tempi, bpm)
  // Mirror: /(?:tempo|tempi|bpm)\s*[:=]?\s*(\d{2,3})\b/
  if (detectedTempo == null) {
    final bpmMatch = _tempoBpmRegex.firstMatch(normalized);
    if (bpmMatch != null) {
      detectedTempo = double.tryParse(bpmMatch.group(1) ?? '');
      if (detectedTempo != null) {
        log(
          'Detected PDF Tempo (BPM): $detectedTempo from "${bpmMatch.group(0)}"',
          name: 'PdfNoteExtractor',
        );
      }
    }
  }

  // Pattern 3: Loose match (standalone = followed by number)
  // Mirror: /(?:^|[^0-9A-Za-z])=\s*(\d{2,3})\b/
  if (detectedTempo == null) {
    final looseMatch = _tempoLooseRegex.firstMatch(normalized);
    if (looseMatch != null) {
      detectedTempo = double.tryParse(looseMatch.group(1) ?? '');
      if (detectedTempo != null) {
        log(
          'Detected PDF Tempo (loose): $detectedTempo from "${looseMatch.group(0)}"',
          name: 'PdfNoteExtractor',
        );
      }
    }
  }

  // Pattern 4: MM/M.M. style (fallback)
  // Mirror: /(?:MM|M\.M\.|♩)\s+(\d{2,3})/
  if (detectedTempo == null) {
    final mmMatch = _tempoMmRegex.firstMatch(normalized);
    if (mmMatch != null) {
      detectedTempo = double.tryParse(mmMatch.group(1) ?? '');
      if (detectedTempo != null) {
        log(
          'Detected PDF Tempo (MM): $detectedTempo from "${mmMatch.group(0)}"',
          name: 'PdfNoteExtractor',
        );
      }
    }
  }

  if (profile == ExtractionProfile.krLegacy) {
    return _extractPdfContentStandardLegacy(
      rawText: rawText,
      pageWidth: pageWidth,
      pageHeight: pageHeight,
      detectedKey: detectedKey,
      detectedTempo: detectedTempo,
    );
  }

  // Step 1: Build note-like visual rows.
  // pdf.js ignores mixed text items such as "4/4 Es = 1 (3 mol)" because the
  // item is not purely made of notation characters. pdfrx exposes character
  // rectangles, so we recreate that behavior by grouping characters into visual
  // rows and accepting only rows whose visible text is 0-7, dots, and spaces.
  final rawRows = <_RawRow>[];
  final rawRowsByBucket = <int, List<_RawRow>>{};
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
    final row = _findRawRow(rawRowsByBucket: rawRowsByBucket, y: rect.bottom);
    if (row != null) {
      row.chars.add(rawChar);
    } else {
      final newRow = _RawRow(y: rect.bottom, chars: [rawChar]);
      rawRows.add(newRow);
      _addRawRow(rawRowsByBucket: rawRowsByBucket, row: newRow);
    }
  }

  final items = <_TextItem>[];
  for (final row in rawRows) {
    row.chars.sort((a, b) => a.left.compareTo(b.left));
    final rowText = row.chars.map((c) => c.str).join().trim();
    if (rowText.isEmpty) {
      continue;
    }

    final chars = row.chars
        .where((c) => isNotationChar(c.str))
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

    final noteChars = chars.where((c) => isNoteSymbol(c.str));
    final holdChars = chars.where((c) => isHoldOrRestSymbol(c.str));

    // Include row if it has any notation (digits 1-7 or holds)
    // This ensures rows with only holds (no digits) are still tracked
    if (noteChars.isEmpty && holdChars.isEmpty) {
      continue;
    }

    // For font size calculation, prefer note chars if available
    final fontSizeSource = noteChars.isNotEmpty ? noteChars : holdChars;
    final notationText = chars.map((c) => c.str).join();
    items.add(
      _TextItem(
        str: notationText,
        bottom: _median(fontSizeSource.map((c) => c.bottom).toList()),
        fontSize: _dominantRoundedFontSize(
          fontSizeSource.map((c) => c.fontSize),
        ),
        chars: chars,
        rawCharCount: row.chars.length,
      ),
    );
  }
  if (items.isEmpty) {
    return PdfExtractionResult(notes: [], detectedKey: detectedKey);
  }

  // Step 2: Find the dominant font size among notation candidates.
  final candidateItems = items
      .where((item) => item.chars.any((c) => isNoteSymbol(c.str)))
      .toList();
  if (candidateItems.isEmpty) {
    return PdfExtractionResult(notes: [], detectedKey: detectedKey);
  }

  final dominantFontSize = _dominantRoundedFontSize(
    candidateItems.map((item) => item.fontSize ?? item.chars.first.fontSize),
  );
  final fontSizeTolerance = profile == ExtractionProfile.mdr ? 1.5 : 1.0;

  // Step 3: Keep only note-like items at the dominant notation font size.
  // Items containing digit notes (1-7) must match the dominant font size.
  // Items with ONLY hold/rest symbols (no digits) are kept regardless of font size -
  // they may render on a slightly different baseline/font size in ASM/MDR PDFs.
  // Mixed items (digits + holds) are kept if the dominant digit font size matches.
  final filtered = items
      .where(
        (item) {
          final hasNote = item.chars.any((c) => _isNoteSymbol(c.str));
          final hasHoldOrRest = item.chars.any((c) => isHoldOrRestSymbol(c.str));
          if (!hasNote && !hasHoldOrRest) return false;

          // Keep hold-only rows regardless of font size. They can be rendered
          // in a different font size/baseline from note glyphs in MDR/ASM PDFs.
          if (!hasNote) {
            if (profile == ExtractionProfile.mdr) {
              final density = item.rawCharCount <= 0
                  ? 0.0
                  : item.chars.length / item.rawCharCount;
              // MDR pages contain dense staff-symbol rows; keep only hold rows
              // that are mostly notation glyphs.
              return density >= 0.45;
            }
            return true;
          }

          // For rows with note anchors, check font size of note chars only.
          final noteChars = item.chars.where((c) => isNoteSymbol(c.str)).toList();
          if (noteChars.isNotEmpty) {
            if (item.fontSize == null) {
              return noteChars.every(
                  (c) => (c.fontSize - dominantFontSize).abs() < fontSizeTolerance);
            }
            return (item.fontSize! - dominantFontSize).abs() < fontSizeTolerance;
          }
          return false;
        },
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
          fontSize: item.fontSize ?? ch.fontSize,
          chars: [ch],
        ),
      );
    }
  }

  // Step 5: Group into rows by bottom coordinate (baseline Y), ±2pt tolerance.
  // In PDF coords, higher bottom = visually higher on page → sort descending.
  // This matches gyschordweb's yTolerance = 2.0.
  final rows = <_Row>[];
  final rowsByBucket = <int, List<_Row>>{};
  final sorted = noteItems..sort((a, b) => b.bottom.compareTo(a.bottom));
  for (final item in sorted) {
    final row = _findNoteRow(rowsByBucket: rowsByBucket, y: item.bottom);
    if (row != null) {
      row.items.add(item);
      if (isNoteSymbol(item.str)) {
        row.digitCount++;
      }
    } else {
      final newRow = _Row(
        y: item.bottom,
        items: [item],
        digitCount: isNoteSymbol(item.str) ? 1 : 0,
      );
      rows.add(newRow);
      _addNoteRow(rowsByBucket: rowsByBucket, row: newRow);
    }
  }

  // Step 6: Keep only dense numeric rows.
  // Dynamic threshold reduces accidental capture of header/tempo rows
  // that contain a few digits but are not notation lines.
  final maxDigitCount = rows.fold<int>(
    0,
    (max, row) => row.digitCount > max ? row.digitCount : max,
  );
  final minDigitRowCount = maxDigitCount >= 8
      ? (profile == ExtractionProfile.mdr ? 4 : 2)
      : (maxDigitCount >= 5 ? 3 : 2);
  final musicRows = rows.where((r) => r.digitCount >= minDigitRowCount).toList();
  if (profile == ExtractionProfile.standard) {
    // Suppress top-header metadata rows (tempo/key/scripture refs) that
    // often contain a handful of digits but are not notation lines.
    musicRows.removeWhere((row) {
      final yPct = (1.0 - row.y / pageHeight) * 100;
      if (maxDigitCount < 8) return false;
      if (yPct < 12.0) return true;
      return yPct < 15.0 && row.digitCount < 8;
    });
  }
  final numericRows = List<_Row>.from(musicRows);

  // ASM/MDR sometimes render hold markers on a slightly different baseline
  // from digits. Re-attach hold/rest-only rows to the nearest music row.
  // Also include MDR private-use characters in the check.
  final detachedHoldRows = rows.where((row) {
    if (row.digitCount > 0) return false;
    if (row.items.isEmpty) return false;
    if (!_isNearAnyRow(row.y, numericRows, holdRowMaxDistance)) {
      return false;
    }
    return row.items.any((item) => isDetachedHoldRowSymbol(item.str));
  }).toList();

  // Collect attachment operations to avoid concurrent modification
  final attachments = <({_Row target, List<_TextItem> items})>[];
  for (final detached in detachedHoldRows) {
    _Row? nearestRow;
    double nearestDistance = double.infinity;
    for (final musicRow in numericRows) {
      final distance = (musicRow.y - detached.y).abs();
      if (distance <= _holdRowAttachTolerance && distance < nearestDistance) {
        nearestDistance = distance;
        nearestRow = musicRow;
      }
    }
    if (nearestRow != null) {
      final holdItems = detached.items
          .where((item) => isDetachedHoldRowSymbol(item.str))
          .toList();
      if (holdItems.isNotEmpty) {
        attachments.add((target: nearestRow, items: List<_TextItem>.from(holdItems)));
      }
    }
  }

  // Apply attachments after iteration
  for (final attachment in attachments) {
    for (final item in attachment.items) {
      attachment.target.items.add(item);
    }
  }

  // Step 7: Build noteIdx-to-position and NoteInfo list.
  // xPct: center of char horizontally, using left edge + half width for better accuracy.
  // yPct: convert PDF baseline Y to % from TOP of page — NO offset applied here.
  //       Offset is applied at badge render time.
  // Matches gyschordweb:
  //   xPct = ((item.x + item.w / 2) / pageWidth) * 100
  //   yPct = ((1 - item.y / pageHeight) * 100)   [item.y = baseline]
  final noteInfos = <NoteInfo>[];
  int noteIdx = 0;
  // Iterate over a snapshot to avoid concurrent modification
  final musicRowsSnapshot = List<_Row>.from(musicRows);
  for (final row in musicRowsSnapshot) {
    final sortedItems = List<_TextItem>.from(row.items)
      ..sort((a, b) => a.chars.single.left.compareTo(b.chars.single.left));
    for (final item in sortedItems) {
      final char = item.chars.single;
      final charWidth = char.right - char.left;
      final centerX = char.left + (charWidth / 2);
      final baselineY = item.bottom;

      final xPct = centerX / pageWidth * 100;
      final yPct = (1.0 - baselineY / pageHeight) * 100;

      final clampedXPct = xPct.clamp(1.0, 99.0);
      final clampedYPct = yPct.clamp(1.0, 99.0);
      final isNote = isNoteSymbol(item.str);
      final isDot = isHoldSymbol(item.str) || _isMdrHoldChar(item.str);
      // MDR private-use dash glyphs (e.g. U+F00E) are hold markers, not rests.
      // Keep rest semantics strictly for numeric 0.
      final isRest = item.str == '0';
      final normalizedStr = _normalizeNotationChar(item.str, profile: profile);
      noteInfos.add(
        NoteInfo(
          idx: noteIdx,
          xPct: clampedXPct,
          yPct: clampedYPct,
          rowY: row.y,
          str: normalizedStr,
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

const _holdSymbols = '-‐‑‒–—―−\uF00B\uF00E';
const double _holdRowAttachTolerance = 6.0;
const double _mdrHoldRowMaxDistance = 4.5;
const double _standardHoldRowMaxDistance = 7.0;

bool _isHoldSymbol(String char, {ExtractionProfile profile = ExtractionProfile.standard}) {
  if (char == '.') return true;
  if (_holdSymbols.contains(char)) return true;
  return false;
}

bool _isNoteSymbol(String char) =>
    _digitNotePattern.hasMatch(char);

/// Check if character is an MDR-style hold/rest marker (U+F00B).
bool _isMdrHoldChar(String char) {
  if (char.isEmpty || char.length != 1) return false;
  final code = char.codeUnitAt(0);
  // MDR books use multiple private-use hold/rest glyphs.
  return code == 0xF00B || code == 0xF00E;
}

String _normalizeNotationChar(String char, {ExtractionProfile profile = ExtractionProfile.standard}) {
  if (_isHoldSymbol(char, profile: profile)) {
    return char == '.' ? '.' : '-';
  }
  // Handle MDR private-use characters
  if (_isMdrHoldChar(char)) {
    return '-';
  }
  return char;
}

final _digitZeroToSevenPattern = RegExp(r'^[0-7]$');
final _digitNotePattern = RegExp(r'^[1-7]$');
final _containsDigitNotePattern = RegExp(r'[1-7]');
final _legacyStandardSingleNotePattern = RegExp(r'^[0-7.\-‐‑‒–—―−]$');
final _legacyStandardMultiNotePattern = RegExp(r'^[0-7.\-‐‑‒–—―−\s]+$');
final _legacyStandardHoldPattern = RegExp(r'^[.\-‐‑‒–—―−]$');
final _standardDetachedHoldPattern = RegExp(r'^[.\-‐‑‒–—―−]$');
final _whitespaceRegex = RegExp(r'\s+');
final _keyRegex = RegExp(
  r'(?:\b(?:1|Do|do)\s*[=:]\s*([A-G](?:[#♯b♭]|is|es|s)?))|(?:\b([A-G](?:[#♯b♭]|is|es|s)?)\s*[=:]\s*(?:1|Do|do)\b)',
  caseSensitive: false,
);
final _tempoSymbolRegex = RegExp(
  r'(?:^|[\s(])(?:J|j|Q|q|♩|♪)\s*[:=]\s*(\d{2,3})(?=\D|$)',
  caseSensitive: false,
);
final _tempoBpmRegex = RegExp(
  r'(?:tempo|tempi|bpm)\s*[:=]?\s*(\d{2,3})\b',
  caseSensitive: false,
);
final _tempoLooseRegex = RegExp(r'(?:^|[^0-9A-Za-z])=\s*(\d{2,3})\b');
final _tempoMmRegex = RegExp(
  r'(?:MM|M\.M\.|♩)\s+(\d{2,3})',
  caseSensitive: false,
);
const double _rowTolerance = 2.0;
const double _rowBucketSize = 2.0;

int _rowBucket(double y) => (y / _rowBucketSize).round();

_RawRow? _findRawRow({
  required Map<int, List<_RawRow>> rawRowsByBucket,
  required double y,
}) {
  final bucket = _rowBucket(y);
  for (final b in [bucket - 1, bucket, bucket + 1]) {
    final rows = rawRowsByBucket[b];
    if (rows == null) continue;
    for (final row in rows) {
      if ((row.y - y).abs() < _rowTolerance) return row;
    }
  }
  return null;
}

void _addRawRow({
  required Map<int, List<_RawRow>> rawRowsByBucket,
  required _RawRow row,
}) {
  final bucket = _rowBucket(row.y);
  rawRowsByBucket.putIfAbsent(bucket, () => <_RawRow>[]).add(row);
}

_Row? _findNoteRow({
  required Map<int, List<_Row>> rowsByBucket,
  required double y,
}) {
  final bucket = _rowBucket(y);
  for (final b in [bucket - 1, bucket, bucket + 1]) {
    final rows = rowsByBucket[b];
    if (rows == null) continue;
    for (final row in rows) {
      if ((row.y - y).abs() < _rowTolerance) return row;
    }
  }
  return null;
}

void _addNoteRow({
  required Map<int, List<_Row>> rowsByBucket,
  required _Row row,
}) {
  final bucket = _rowBucket(row.y);
  rowsByBucket.putIfAbsent(bucket, () => <_Row>[]).add(row);
}

class _TextItem {
  final String str;
  final double bottom;
  final double? fontSize; // null means use chars' fontSize
  final List<_CharItem> chars;
  final int rawCharCount;

  _TextItem({
    required this.str,
    required this.bottom,
    this.fontSize,
    required this.chars,
    this.rawCharCount = 0,
  });
}

bool _isNearAnyRow(double y, Iterable<_Row> rows, double tolerance) {
  for (final row in rows) {
    if ((row.y - y).abs() <= tolerance) return true;
  }
  return false;
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
  int digitCount;
  _Row({required this.y, required this.items, this.digitCount = 0});
}

PdfExtractionResult _extractPdfContentStandardLegacy({
  required PdfPageRawText rawText,
  required double pageWidth,
  required double pageHeight,
  required String? detectedKey,
  required double? detectedTempo,
}) {
  final text = rawText.fullText;
  final rects = rawText.charRects;
  if (text.isEmpty || rects.length != text.length) {
    return PdfExtractionResult(notes: [], detectedKey: detectedKey, detectedTempo: detectedTempo);
  }

  bool isNotationCharStd(String char) {
    return _legacyStandardSingleNotePattern.hasMatch(char);
  }

  final rawRows = <_RawRow>[];
  final rawRowsByBucket = <int, List<_RawRow>>{};
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
    final row = _findRawRow(rawRowsByBucket: rawRowsByBucket, y: rect.bottom);
    if (row != null) {
      row.chars.add(rawChar);
    } else {
      final newRow = _RawRow(y: rect.bottom, chars: [rawChar]);
      rawRows.add(newRow);
      _addRawRow(rawRowsByBucket: rawRowsByBucket, row: newRow);
    }
  }

  final items = <_TextItem>[];
  for (final row in rawRows) {
    row.chars.sort((a, b) => a.left.compareTo(b.left));
    final rowText = row.chars.map((c) => c.str).join().trim();
    if (rowText.isEmpty ||
        !_legacyStandardMultiNotePattern.hasMatch(rowText) ||
        !_containsDigitNotePattern.hasMatch(rowText)) {
      continue;
    }

    final chars = row.chars
        .where((c) => isNotationCharStd(c.str))
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
        fontSize: _dominantRoundedFontSize(fontSizeSource.map((c) => c.fontSize)),
        chars: chars,
      ),
    );
  }
  if (items.isEmpty) {
    return PdfExtractionResult(notes: [], detectedKey: detectedKey, detectedTempo: detectedTempo);
  }

  final candidateItems = items
      .where((item) => _legacyStandardMultiNotePattern.hasMatch(item.str))
      .where((item) => _containsDigitNotePattern.hasMatch(item.str))
      .toList();
  if (candidateItems.isEmpty) {
    return PdfExtractionResult(notes: [], detectedKey: detectedKey, detectedTempo: detectedTempo);
  }

  final dominantFontSize = _dominantRoundedFontSize(
    candidateItems.map((item) => item.fontSize ?? item.chars.first.fontSize),
  );
  const fontSizeTolerance = 1.5;
  final filtered = items
      .where((item) => _legacyStandardMultiNotePattern.hasMatch(item.str))
      .where((item) => ((item.fontSize ?? item.chars.first.fontSize) - dominantFontSize).abs() < fontSizeTolerance)
      .toList();

  final noteItems = <_TextItem>[];
  for (final item in filtered) {
    for (final ch in item.chars) {
      noteItems.add(
        _TextItem(
          str: ch.str,
          bottom: item.bottom,
          fontSize: item.fontSize ?? ch.fontSize,
          chars: [ch],
        ),
      );
    }
  }

  final rows = <_Row>[];
  final sorted = noteItems..sort((a, b) => b.bottom.compareTo(a.bottom));
  for (final item in sorted) {
    _Row? row;
    for (final candidate in rows) {
      if ((candidate.y - item.bottom).abs() < 2.0) {
        row = candidate;
        break;
      }
    }
    if (row != null) {
      row.items.add(item);
      if (_digitNotePattern.hasMatch(item.str)) {
        row.digitCount++;
      }
    } else {
      final newRow = _Row(
        y: item.bottom,
        items: [item],
        digitCount: _digitNotePattern.hasMatch(item.str) ? 1 : 0,
      );
      rows.add(newRow);
    }
  }

  final musicRows = rows.where((r) => r.digitCount >= 2).toList();

  final noteInfos = <NoteInfo>[];
  int noteIdx = 0;
  for (final row in musicRows) {
    final sortedItems = List<_TextItem>.from(row.items)
      ..sort((a, b) => a.chars.single.left.compareTo(b.chars.single.left));
    for (final item in sortedItems) {
      final char = item.chars.single;
      final charWidth = char.right - char.left;
      final centerX = char.left + (charWidth / 2);
      final baselineY = item.bottom;

      final xPct = centerX / pageWidth * 100;
      final yPct = (1.0 - baselineY / pageHeight) * 100;
      final clampedXPct = xPct.clamp(1.0, 99.0);
      final clampedYPct = yPct.clamp(1.0, 99.0);

      final isNote = _digitNotePattern.hasMatch(item.str);
      final isDot = _legacyStandardHoldPattern.hasMatch(item.str);
      final isRest = item.str == '0';
      final normalizedStr = _legacyStandardHoldPattern.hasMatch(item.str)
          ? (item.str == '.' ? '.' : '-')
          : item.str;

      noteInfos.add(
        NoteInfo(
          idx: noteIdx,
          xPct: clampedXPct,
          yPct: clampedYPct,
          rowY: row.y,
          str: normalizedStr,
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

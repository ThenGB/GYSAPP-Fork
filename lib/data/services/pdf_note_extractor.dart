import 'package:pdfrx/pdfrx.dart';

/// Position of a note on a PDF page, as percentage of page dimensions.
typedef NotePosition = ({double xPct, double yPct});

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
/// (NOTE_CHORD_Y_OFFSET_PCT = 2.5) — no offset is applied here.
Map<int, NotePosition> extractNotePositions(
  PdfPageRawText rawText,
  double pageWidth,
  double pageHeight,
) {
  final text = rawText.fullText;
  final rects = rawText.charRects;
  if (text.isEmpty || rects.length != text.length) return {};

  // Step 1: Build character-level items for note candidates.
  // Matches gyschordweb: filters items where str matches /^[0-7.\s]+$/ AND
  // contains a music digit [1-7]. We iterate char-by-char using pdfrx rects.
  //
  // pdfrx PdfRect: origin bottom-left, Y-axis pointing up.
  //   rect.bottom = lower edge (≈ text baseline in PDF space)
  //   rect.top    = upper edge (≈ ascent)
  //   rect.top - rect.bottom = font size (positive)
  //
  // We group consecutive note-chars into "items" that share approximately the
  // same Y baseline (within yTolerance), matching how PDF.js groups text into
  // items via transform[5] (the baseline Y).

  final items = <_TextItem>[];
  int i = 0;
  while (i < text.length) {
    final ch = text[i];
    if (_isNoteChar(ch)) {
      // Group run of note chars that are adjacent on the same baseline.
      final start = i;
      while (i < text.length && _isNoteChar(text[i])) {
        i++;
      }
      final groupRects = rects.sublist(start, i);
      final str = text.substring(start, i).trim();
      // Only keep groups that contain at least one music digit (1-7).
      if (str.isEmpty || !str.contains(RegExp(r'[1-7]'))) continue;

      // Bounding rect of the group.
      final left = groupRects.map((r) => r.left).reduce((a, b) => a < b ? a : b);
      final top = groupRects.map((r) => r.top).reduce((a, b) => a > b ? a : b);
      final right = groupRects.map((r) => r.right).reduce((a, b) => a > b ? a : b);
      // Use rect.bottom ≈ baseline, matching gyschordweb's item.transform[5].
      final bottom = groupRects.map((r) => r.bottom).reduce((a, b) => a < b ? a : b);

      items.add(_TextItem(
        str: str,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        fontSize: top - bottom, // positive: top > bottom in PDF coords
        charRects: groupRects,
      ));
    } else {
      i++;
    }
  }
  if (items.isEmpty) return {};

  // Step 2: Find dominant font size by frequency (rounded to 1 decimal).
  // Matches gyschordweb's fontSizeCounts approach.
  final fontSizeCounts = <double, int>{};
  for (final item in items) {
    final key = (item.fontSize * 10).round() / 10.0;
    fontSizeCounts[key] = (fontSizeCounts[key] ?? 0) + 1;
  }
  final dominantFontSize = fontSizeCounts.entries
      .reduce((a, b) => a.value >= b.value ? a : b)
      .key;

  // Step 3: Filter to items within ±1.5pt of dominant font size.
  final filtered = items
      .where((item) => (item.fontSize - dominantFontSize).abs() < 1.5)
      .toList();

  // Step 4: Expand multi-char items to individual characters using per-char rects.
  // Matches gyschordweb's slotWidth interpolation for multi-char items.
  final noteItems = <_TextItem>[];
  for (final item in filtered) {
    if (item.str.length == 1) {
      noteItems.add(item);
    } else {
      for (int j = 0; j < item.str.length && j < item.charRects.length; j++) {
        final ch = item.str[j];
        if (!RegExp(r'[0-7.]').hasMatch(ch)) continue;
        final cr = item.charRects[j];
        noteItems.add(_TextItem(
          str: ch,
          left: cr.left,
          top: cr.top,
          right: cr.right,
          bottom: cr.bottom,
          fontSize: cr.top - cr.bottom,
          charRects: [cr],
        ));
      }
    }
  }

  // Step 5: Group into rows by bottom coordinate (baseline Y), ±2pt tolerance.
  // In PDF coords, higher bottom = visually higher on page → sort descending.
  // Matches gyschordweb's yTolerance = 2.0.
  final rows = <_Row>[];
  final sorted = noteItems..sort((a, b) => b.bottom.compareTo(a.bottom));
  for (final item in sorted) {
    final row = rows.where((r) => (r.y - item.bottom).abs() < 2).firstOrNull;
    if (row != null) {
      row.items.add(item);
    } else {
      rows.add(_Row(y: item.bottom, items: [item]));
    }
  }

  // Step 6: Keep only rows with ≥2 music digit notes (1-7).
  // Matches gyschordweb: `digits.length >= 2`.
  final musicRows = rows
      .where((r) =>
          r.items.where((item) => RegExp(r'^[1-7]$').hasMatch(item.str)).length >=
          2)
      .toList();

  // Step 7: Build noteIdx → NotePosition.
  // xPct: center of char horizontally.
  // yPct: convert PDF baseline Y to % from TOP of page — NO offset applied here.
  //       Offset is applied at badge render time (NOTE_CHORD_Y_OFFSET_PCT = 2.5).
  // Matches gyschordweb:
  //   xPct = ((item.x + item.w / 2) / pageWidth) * 100
  //   yPct = ((1 - item.y / pageHeight) * 100)   [item.y = baseline]
  final result = <int, NotePosition>{};
  int noteIdx = 0;
  for (final row in musicRows) {
    for (final item in row.items..sort((a, b) => a.left.compareTo(b.left))) {
      final centerX = (item.left + item.right) / 2;
      // Use bottom (baseline) matching gyschordweb's item.y = transform[5].
      final baselineY = item.bottom;
      final xPct = centerX / pageWidth * 100;
      // PDF Y-axis: 0 at bottom, pageHeight at top → convert to % from top.
      final yPct = (1.0 - baselineY / pageHeight) * 100;
      result[noteIdx] = (xPct: xPct.clamp(1.0, 99.0), yPct: yPct.clamp(1.0, 99.0));
      noteIdx++;
    }
  }
  return result;
}

bool _isNoteChar(String ch) => RegExp(r'[0-7.\s]').hasMatch(ch);

class _TextItem {
  final String str;
  final double left, top, right, bottom, fontSize;
  final List<PdfRect> charRects;

  _TextItem({
    required this.str,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.fontSize,
    required this.charRects,
  });
}

class _Row {
  final double y;
  final List<_TextItem> items;
  _Row({required this.y, required this.items});
}

# PDF Viewer Rework: pdfrx + Flutter Chord Overlay Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the broken WebView/PDF.js-based `SongPdfViewer` with a native `pdfrx`-based viewer that renders PDFs reliably on Windows (and all platforms), while preserving the chord badge overlay feature using Flutter widgets instead of JS.

**Architecture:** `pdfrx` (PDFium-based) renders PDF pages as Flutter widgets. A Dart port of the existing JavaScript note-extraction algorithm extracts note positions from each page's text, then Flutter `Positioned` widgets overlay chord badges on top. The `SongPdfViewer` public API is unchanged — same parameters, same callbacks.

**Tech Stack:** `pdfrx ^2.3.2`, `pdfrx_engine ^0.4.1`, Flutter Stack/Positioned widgets, existing `ChordData`/`ChordService` classes.

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `pubspec.yaml` | Modify | Add `pdfrx` dependency |
| `lib/data/services/pdf_note_extractor.dart` | **Create** | Dart port of JS note-extraction algorithm: `PdfPageRawText → Map<int, ({double xPct, double yPct})>` |
| `lib/presentations/song/widgets/song_pdf_viewer.dart` | **Rewrite** | Drop WebView/HTML/JS. Use `PdfViewer` + Flutter chord overlay. Same public API. |
| `assets/web/pdf_viewer.html` | Keep (no change) | Not used in new implementation but kept for reference. |
| `test/pdf_note_extractor_test.dart` | **Create** | Unit tests for note extraction algorithm |
| `test/source_hygiene_test.dart` | Modify | Update hygiene test that checked for absence of base64/rootBundle in pdf viewer |

---

## Task 1: Add pdfrx dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add pdfrx to pubspec.yaml**

In `pubspec.yaml`, under `dependencies:`, add after `flutter_inappwebview`:

```yaml
  pdfrx: ^2.3.2
```

- [ ] **Step 2: Run flutter pub get**

```
flutter pub get
```

Expected: resolves `pdfrx 2.3.2` and `pdfrx_engine 0.4.1` with no conflicts.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "deps: add pdfrx ^2.3.2 for native PDF rendering"
```

---

## Task 2: Port note-extraction algorithm to Dart

**Files:**
- Create: `lib/data/services/pdf_note_extractor.dart`
- Create: `test/pdf_note_extractor_test.dart`

### Background

The existing JS code in `assets/web/pdf_viewer.html` extracts note positions like this:
1. Get all text items on the page: `{ str, x, y, w, fontSize }` (PDF.js coords: x from left, y from **bottom**)
2. Filter to items matching note characters: `/^[0-7.\s]+$/` and contains `/[1-7]/`
3. Find dominant font size by frequency
4. Filter to items with dominant font size (±1.5pt tolerance)
5. Split multi-char items into individual characters with proportional x positions
6. Group into rows by y coordinate (±2pt tolerance)
7. Keep rows that have ≥2 digit notes (1-7)
8. Collect all notes in order: `noteIdx` increments globally across all rows
9. Each note's position: `xPct = (x + w/2) / pageWidth * 100`, `yPct = (1 - y/pageHeight) * 100`

**pdfrx coordinate system:** `PdfRect(left, top, right, bottom)` — y from **top** (not bottom like PDF.js). Page origin is top-left.

Conversion: `xPct = rect.centerX / page.width * 100`, `yPct = rect.centerY / page.height * 100`

Where `rect.centerX = (rect.left + rect.right) / 2`, `rect.centerY = (rect.top + rect.bottom) / 2`.

### NotePosition record

```dart
typedef NotePosition = ({double xPct, double yPct});
```

### Algorithm (Dart)

```dart
// Input: PdfPageRawText (from pdfrx page.loadText())
// Input: page width and height (from PdfPage.width, PdfPage.height)
// Output: Map<int, NotePosition>  — noteIdx -> position
Map<int, NotePosition> extractNotePositions(
  PdfPageRawText rawText,
  double pageWidth,
  double pageHeight,
) {
  // Step 1: Build per-character items from charRects + fullText
  // PdfPageRawText.charRects has one PdfRect per character in fullText.
  // PdfRect fields: left, top, right, bottom in PDF points (y from top).
  // Width of char = right - left, height = bottom - top.

  final text = rawText.fullText;
  final rects = rawText.charRects;
  if (text.isEmpty || rects.length != text.length) return {};

  // Step 2: Filter to note candidate characters: [0-7.]
  // First group consecutive note chars into items (word-like groups)
  final items = <_TextItem>[];
  int i = 0;
  while (i < text.length) {
    final ch = text[i];
    if (_isNoteChar(ch)) {
      final start = i;
      while (i < text.length && _isNoteChar(text[i])) i++;
      // Build item: bounding box spans all chars in group
      final groupRects = rects.sublist(start, i);
      final left = groupRects.map((r) => r.left).reduce((a, b) => a < b ? a : b);
      final top = groupRects.map((r) => r.top).reduce((a, b) => a < b ? a : b);
      final right = groupRects.map((r) => r.right).reduce((a, b) => a > b ? a : b);
      final bottom = groupRects.map((r) => r.bottom).reduce((a, b) => a > b ? a : b);
      final fontSize = bottom - top; // approximate font size as height
      final str = text.substring(start, i).trim();
      if (str.isNotEmpty && str.contains(RegExp(r'[1-7]'))) {
        items.add(_TextItem(
          str: str,
          left: left, top: top, right: right, bottom: bottom,
          fontSize: fontSize,
          charRects: groupRects,
        ));
      }
    } else {
      i++;
    }
  }

  if (items.isEmpty) return {};

  // Step 3: Dominant font size
  final fontSizeCounts = <double, int>{};
  for (final item in items) {
    final key = (item.fontSize * 10).round() / 10.0;
    fontSizeCounts[key] = (fontSizeCounts[key] ?? 0) + 1;
  }
  final dominantFontSize = fontSizeCounts.entries
      .reduce((a, b) => a.value >= b.value ? a : b)
      .key;

  // Step 4: Filter by dominant font size
  final filtered = items
      .where((item) => (item.fontSize - dominantFontSize).abs() < 1.5)
      .toList();

  // Step 5: Expand multi-char items to individual characters
  final noteItems = <_TextItem>[];
  for (final item in filtered) {
    if (item.str.length == 1) {
      noteItems.add(item);
    } else {
      for (int j = 0; j < item.str.length; j++) {
        final ch = item.str[j];
        if (!RegExp(r'[0-7.]').hasMatch(ch)) continue;
        noteItems.add(_TextItem(
          str: ch,
          left: item.charRects[j].left,
          top: item.charRects[j].top,
          right: item.charRects[j].right,
          bottom: item.charRects[j].bottom,
          fontSize: item.charRects[j].bottom - item.charRects[j].top,
          charRects: [item.charRects[j]],
        ));
      }
    }
  }

  // Step 6: Group into rows by top coordinate (±2pt tolerance)
  final rows = <_Row>[];
  for (final item in noteItems..sort((a, b) => a.top.compareTo(b.top))) {
    final row = rows.where((r) => (r.y - item.top).abs() < 2).firstOrNull;
    if (row != null) {
      row.items.add(item);
    } else {
      rows.add(_Row(y: item.top, items: [item]));
    }
  }

  // Step 7: Keep rows with ≥2 digit notes
  final musicRows = rows
      .where((r) => r.items.where((i) => RegExp(r'^[1-7]$').hasMatch(i.str)).length >= 2)
      .toList();

  // Step 8: Collect notes with global noteIdx, compute xPct/yPct
  const noteYOffsetPercent = 2.2;
  final result = <int, NotePosition>{};
  int noteIdx = 0;
  for (final row in musicRows) {
    for (final item in row.items..sort((a, b) => a.left.compareTo(b.left))) {
      final centerX = (item.left + item.right) / 2;
      final centerY = (item.top + item.bottom) / 2;
      final xPct = centerX / pageWidth * 100;
      final rawYPct = centerY / pageHeight * 100;
      // Apply the same -noteYOffsetPercent so chord badge appears just above the note
      final yPct = (rawYPct - noteYOffsetPercent).clamp(1.0, 99.0);
      result[noteIdx] = (xPct: xPct, yPct: yPct);
      noteIdx++;
    }
  }
  return result;
}

bool _isNoteChar(String ch) => RegExp(r'[0-7.\s]').hasMatch(ch);
```

- [ ] **Step 1: Write the failing test**

Create `test/pdf_note_extractor_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:church/data/services/pdf_note_extractor.dart';

// We can't load real PDFs in unit tests, so we test the algorithm with
// synthetic PdfPageRawText constructed manually.
void main() {
  group('PdfNoteExtractor', () {
    test('returns empty map for empty text', () {
      final raw = _makeFakeRawText('', []);
      final result = extractNotePositions(raw, 595, 842);
      expect(result, isEmpty);
    });

    test('extracts note positions from a simple row of notes', () {
      // Simulate two rows of notes: "1 2 3" and "5 6 7" at y=100 and y=200
      // Each character has fontSize ~10, width ~8
      const pageW = 400.0;
      const pageH = 600.0;
      const fontSize = 10.0;
      // Row 1: notes at x=50, 70, 90 — y from top = 100..110
      // Row 2: notes at x=50, 70, 90 — y from top = 200..210
      final chars1 = ['1', '2', '3'];
      final chars2 = ['5', '6', '7'];
      final text = chars1.join() + chars2.join(); // "123567"
      final rects = [
        ...chars1.asMap().entries.map((e) => _rect(50.0 + e.key * 20, 100, 58.0 + e.key * 20, 110)),
        ...chars2.asMap().entries.map((e) => _rect(50.0 + e.key * 20, 200, 58.0 + e.key * 20, 210)),
      ];
      final raw = _makeFakeRawText(text, rects);
      final positions = extractNotePositions(raw, pageW, pageH);

      // Should have 6 note positions (0..5)
      expect(positions.length, 6);

      // Note 0 is '1' at x=50..58, y=100..110 → center x=54, y=105
      // xPct = 54/400*100 = 13.5, yPct = (105/600*100 - 2.2).clamp(1,99) = 15.3
      expect(positions[0]!.xPct, closeTo(54 / 400 * 100, 0.1));
      expect(positions[0]!.yPct, closeTo((105 / 600 * 100 - 2.2), 0.1));
    });

    test('filters out rows with fewer than 2 digit notes', () {
      // Row with only one note char should be filtered
      const pageW = 400.0;
      const pageH = 600.0;
      final text = '1'; // only 1 char
      final rects = [_rect(50, 100, 58, 110)];
      final raw = _makeFakeRawText(text, rects);
      final positions = extractNotePositions(raw, pageW, pageH);
      expect(positions, isEmpty);
    });
  });
}

PdfPageRawText _makeFakeRawText(String text, List<PdfRect> rects) {
  return PdfPageRawText(text, rects);
}

PdfRect _rect(double l, double t, double r, double b) => PdfRect(l, t, r, b);
```

- [ ] **Step 2: Run test to verify it fails**

```
flutter test test/pdf_note_extractor_test.dart
```

Expected: FAIL — `'package:church/data/services/pdf_note_extractor.dart'` not found.

- [ ] **Step 3: Create `lib/data/services/pdf_note_extractor.dart`**

```dart
import 'package:pdfrx/pdfrx.dart';

/// Position of a note on a PDF page, as percentage of page dimensions.
typedef NotePosition = ({double xPct, double yPct});

/// Extracts note positions from a PDF page's raw text.
///
/// Replicates the JavaScript note-extraction algorithm from `assets/web/pdf_viewer.html`.
/// Returns a map of noteIdx → (xPct, yPct) where percentages are 0–100.
///
/// [rawText] comes from `PdfPage.loadText()`.
/// [pageWidth] and [pageHeight] come from `PdfPage.width` and `PdfPage.height`.
Map<int, NotePosition> extractNotePositions(
  PdfPageRawText rawText,
  double pageWidth,
  double pageHeight,
) {
  final text = rawText.fullText;
  final rects = rawText.charRects;
  if (text.isEmpty || rects.length != text.length) return {};

  // Step 1: Group consecutive note-candidate characters into word-like items.
  final items = <_TextItem>[];
  int i = 0;
  while (i < text.length) {
    final ch = text[i];
    if (_isNoteChar(ch)) {
      final start = i;
      while (i < text.length && _isNoteChar(text[i])) i++;
      final groupRects = rects.sublist(start, i);
      final str = text.substring(start, i).trim();
      if (str.isEmpty || !str.contains(RegExp(r'[1-7]'))) continue;
      final left = groupRects.map((r) => r.left).reduce((a, b) => a < b ? a : b);
      final top = groupRects.map((r) => r.top).reduce((a, b) => a < b ? a : b);
      final right = groupRects.map((r) => r.right).reduce((a, b) => a > b ? a : b);
      final bottom = groupRects.map((r) => r.bottom).reduce((a, b) => a > b ? a : b);
      items.add(_TextItem(
        str: str,
        left: left, top: top, right: right, bottom: bottom,
        fontSize: bottom - top,
        charRects: groupRects,
      ));
    } else {
      i++;
    }
  }
  if (items.isEmpty) return {};

  // Step 2: Find dominant font size by frequency.
  final fontSizeCounts = <double, int>{};
  for (final item in items) {
    final key = (item.fontSize * 10).round() / 10.0;
    fontSizeCounts[key] = (fontSizeCounts[key] ?? 0) + 1;
  }
  final dominantFontSize = fontSizeCounts.entries
      .reduce((a, b) => a.value >= b.value ? a : b)
      .key;

  // Step 3: Filter by dominant font size (±1.5pt).
  final filtered =
      items.where((item) => (item.fontSize - dominantFontSize).abs() < 1.5).toList();

  // Step 4: Expand multi-char items to individual characters.
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
          left: cr.left, top: cr.top, right: cr.right, bottom: cr.bottom,
          fontSize: cr.bottom - cr.top,
          charRects: [cr],
        ));
      }
    }
  }

  // Step 5: Group into rows by top coordinate (±2pt tolerance), sorted top→bottom.
  final rows = <_Row>[];
  final sorted = noteItems..sort((a, b) => a.top.compareTo(b.top));
  for (final item in sorted) {
    final row = rows.where((r) => (r.y - item.top).abs() < 2).firstOrNull;
    if (row != null) {
      row.items.add(item);
    } else {
      rows.add(_Row(y: item.top, items: [item]));
    }
  }

  // Step 6: Keep only rows with ≥2 digit notes (1-7).
  final musicRows = rows
      .where((r) =>
          r.items.where((i) => RegExp(r'^[1-7]$').hasMatch(i.str)).length >= 2)
      .toList();

  // Step 7: Build noteIdx → NotePosition map.
  const noteYOffsetPercent = 2.2;
  final result = <int, NotePosition>{};
  int noteIdx = 0;
  for (final row in musicRows) {
    for (final item in row.items..sort((a, b) => a.left.compareTo(b.left))) {
      final centerX = (item.left + item.right) / 2;
      final centerY = (item.top + item.bottom) / 2;
      final xPct = centerX / pageWidth * 100;
      final rawYPct = centerY / pageHeight * 100;
      final yPct = (rawYPct - noteYOffsetPercent).clamp(1.0, 99.0);
      result[noteIdx] = (xPct: xPct, yPct: yPct);
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
```

- [ ] **Step 4: Run test to verify it passes**

```
flutter test test/pdf_note_extractor_test.dart
```

Expected: All 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/data/services/pdf_note_extractor.dart test/pdf_note_extractor_test.dart
git commit -m "feat: add PdfNoteExtractor - Dart port of JS note position algorithm"
```

---

## Task 3: Rewrite SongPdfViewer with pdfrx

**Files:**
- Modify: `lib/presentations/song/widgets/song_pdf_viewer.dart` (full rewrite)
- Modify: `test/source_hygiene_test.dart` (update hygiene test)

### Public API (UNCHANGED — do not change callers in song_view.dart)

```dart
class SongPdfViewer extends StatefulWidget {
  final String? pdfPath;
  final bool showChord;
  final Map<int, List<ChordData>>? chords;
  final int transposeStep;
  final int baseTransposeOffset;
  final String chordAccidentalMode;
  final bool twoPageMode;         // → pdfrx layoutMode
  final bool verticalScrolling;   // → pdfrx scrollDirection
  final int chordFontSizePercent;
  final int chordFillOpacityPercent;
  final int chordPaddingPercent;
  final PdfViewerController? viewerController;
  final ValueChanged<String?>? onPdfKeyDetected;
  final ValueChanged<double>? onPdfTempoDetected;
  final VoidCallback? onPageChanged;
  final VoidCallback? onPreviousSong;
  final VoidCallback? onNextSong;
}
```

### Design

```
SongPdfViewer
└── _SongPdfViewerState
    ├── PdfDocumentRef  (pdfrx, loaded from asset bytes)
    ├── PdfViewerController (pdfrx controller for zoom)
    ├── Map<int, Map<int, NotePosition>>  (page → {noteIdx → pos})
    └── PdfViewer (pdfrx widget)
        └── PdfViewerParams.pageOverlaysBuilder
            └── For each visible page: Stack
                └── _ChordOverlay widget
```

Key choices:
- Load PDF from asset bytes via `rootBundle.load(assetPath)` → `PdfDocument.openData(bytes)`
- Use `PdfViewerParams.pageOverlaysBuilder` to inject chord overlays per-page
- Extract note positions lazily per page on first render (cache in map)
- `twoPageMode` → `PdfPageLayout.facing` / `PdfPageLayout.oneColumn`
- `verticalScrolling` → standard pdfrx scroll direction (default is always vertical, twoPage handles layout)
- Zoom in/out via `PdfViewerController.zoomUp()` / `PdfViewerController.zoomDown()`

### Chord badge widget

```dart
class _ChordBadge extends StatelessWidget {
  final String chord;
  final double xPct, yPct;
  final double fontSizePercent;
  final double fillOpacityPercent;
  final double paddingPercent;
  // ...
}
```

Positioned as:
```dart
Positioned(
  left: constraints.maxWidth * xPct / 100,
  top: constraints.maxHeight * yPct / 100,
  child: FractionalTranslation(
    translation: const Offset(-0.5, -0.5), // center on position
    child: _ChordBadge(...),
  ),
)
```

### PDF path with fragment (startPage, pageCount)

`SongPdfViewer.pdfPath` can include a fragment: `assets/data/pdf/kr/001.pdf#2,4` (startPage=2, pageCount=4). Parse with `_PdfDocumentRequest` (already in existing file — keep it).

Use `PdfViewerParams.initialPageNumber` for `startPage`. For `pageCount`, load the PDF and only show pages `startPage..(startPage+pageCount-1)` by filtering in `pageOverlaysBuilder` and using a custom `PdfViewerParams.pagePaintCallback` or wrapping in a custom layout. The simplest approach: open the full document but use `PdfViewerController.goToPage(startPage)` on load, and clip display using `PdfViewerParams.pageRange`.

Actually pdfrx supports page ranges via `PdfViewerParams.pageRange`:
```dart
PdfViewerParams(
  pageRange: PdfPageRange(startPage, startPage + pageCount - 1),
)
```
If pageRange is not supported as a named param in v2.3.2, use `initialPageNumber` for startPage and use a `pageOverlaysBuilder` that skips overlay for out-of-range pages.

Check pdfrx API: look for `PdfViewerParams` constructor params in `pdfrx-2.3.2`.

- [ ] **Step 1: Inspect pdfrx PdfViewerParams API**

Run this to see available params:
```
grep -n "pageRange\|initialPage\|layoutMode\|pageOverlays\|oneColumn\|facing\|scrollDirection" "C:/Users/theng/AppData/Local/Pub/Cache/hosted/pub.dev/pdfrx-2.3.2/lib/src/widgets/pdf_viewer_params.dart" | head -40
```

Use the actual available parameters when writing the widget (do not guess).

- [ ] **Step 2: Write the new SongPdfViewer**

Replace `lib/presentations/song/widgets/song_pdf_viewer.dart` entirely with the following (after confirming param names from Step 1):

```dart
// ignore_for_file: use_build_context_synchronously
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../data/services/chord_service.dart';
import '../../../data/services/pdf_note_extractor.dart';

/// Controller for programmatic zoom control on the active PDF viewer.
class PdfViewerController {
  _SongPdfViewerState? _state;

  void _attach(_SongPdfViewerState state) => _state = state;
  void _detach() => _state = null;

  VoidCallback? get zoomIn => _state?._zoomIn;
  VoidCallback? get zoomOut => _state?._zoomOut;
  VoidCallback? get fitToPage => _state?._fitToPage;

  // Keep setters for backward compat with callers that assign lambdas
  set zoomIn(VoidCallback? _) {}
  set zoomOut(VoidCallback? _) {}
  set fitToPage(VoidCallback? _) {}
}

/// PDF viewer backed by pdfrx (PDFium). Renders PDF pages natively on all
/// platforms and overlays chord badges as Flutter widgets.
class SongPdfViewer extends StatefulWidget {
  final String? pdfPath;
  final bool showChord;
  final Map<int, List<ChordData>>? chords;
  final int transposeStep;
  final int baseTransposeOffset;
  final String chordAccidentalMode;
  final bool twoPageMode;
  final bool verticalScrolling;
  final int chordFontSizePercent;
  final int chordFillOpacityPercent;
  final int chordPaddingPercent;
  final PdfViewerController? viewerController;
  final ValueChanged<String?>? onPdfKeyDetected;
  final ValueChanged<double>? onPdfTempoDetected;
  final VoidCallback? onPageChanged;
  final VoidCallback? onPreviousSong;
  final VoidCallback? onNextSong;

  const SongPdfViewer({
    super.key,
    this.pdfPath,
    this.showChord = false,
    this.chords,
    this.transposeStep = 0,
    this.baseTransposeOffset = 0,
    this.chordAccidentalMode = ChordService.accidentalSharp,
    this.twoPageMode = false,
    this.verticalScrolling = false,
    this.chordFontSizePercent = 100,
    this.chordFillOpacityPercent = 94,
    this.chordPaddingPercent = 100,
    this.viewerController,
    this.onPdfKeyDetected,
    this.onPdfTempoDetected,
    this.onPageChanged,
    this.onPreviousSong,
    this.onNextSong,
  });

  @override
  State<SongPdfViewer> createState() => _SongPdfViewerState();
}

class _SongPdfViewerState extends State<SongPdfViewer> {
  PdfDocument? _document;
  String? _loadedPath;
  String? _errorMessage;
  bool _isLoading = false;

  // pdfrx controller for zoom
  final _pdfCtrl = pdfrx.PdfViewerController();

  // Cache: page number (1-based) → note positions map
  final _notePositionCache = <int, Map<int, NotePosition>>{};

  // Detected PDF key (from chord service via text analysis)
  int _startPage = 1;
  int? _pageCount;

  void _zoomIn() => _pdfCtrl.zoomUp();
  void _zoomOut() => _pdfCtrl.zoomDown();
  void _fitToPage() => _pdfCtrl.setZoom(_pdfCtrl.centerPosition, 1.0);

  @override
  void initState() {
    super.initState();
    widget.viewerController?._attach(this);
    _loadDocument();
  }

  @override
  void dispose() {
    widget.viewerController?._detach();
    _document?.dispose();
    _pdfCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SongPdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewerController != widget.viewerController) {
      oldWidget.viewerController?._detach();
      widget.viewerController?._attach(this);
    }
    if (oldWidget.pdfPath != widget.pdfPath) {
      _loadDocument();
    }
  }

  Future<void> _loadDocument() async {
    final path = widget.pdfPath;
    if (path == null) {
      setState(() {
        _document?.dispose();
        _document = null;
        _loadedPath = null;
        _errorMessage = null;
        _isLoading = false;
        _notePositionCache.clear();
      });
      return;
    }

    final request = _PdfDocumentRequest.parse(path);
    if (request.assetPath == _loadedPath) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _notePositionCache.clear();
      _startPage = request.startPage;
      _pageCount = request.pageCount;
    });

    try {
      final data = await rootBundle.load(request.assetPath);
      if (!mounted) return;
      final doc = await PdfDocument.openData(data.buffer.asUint8List());
      if (!mounted) {
        doc.dispose();
        return;
      }

      // Fire callbacks from chord service analysis on first page
      _fireChordCallbacks(doc, request);

      setState(() {
        _document?.dispose();
        _document = doc;
        _loadedPath = request.assetPath;
        _isLoading = false;
      });

      // Jump to start page after render
      if (request.startPage > 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _pdfCtrl.goToPage(pageNumber: request.startPage);
        });
      }
    } catch (e, st) {
      log('SongPdfViewer load error: $e\n$st', name: 'SongPdfViewer');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat PDF: $e';
      });
    }
  }

  void _fireChordCallbacks(PdfDocument doc, _PdfDocumentRequest request) async {
    // Detect PDF key from first page text (for chord transpose reference)
    try {
      final page = doc.pages[0]; // 0-indexed
      final rawText = await page.loadText();
      if (rawText == null) return;
      final positions = extractNotePositions(rawText, page.width, page.height);
      _notePositionCache[1] = positions;

      // Use ChordService to detect family chord / key
      final chords = widget.chords;
      if (chords != null && widget.onPdfKeyDetected != null) {
        final family = ChordService.detectFamilyChord(chords);
        widget.onPdfKeyDetected?.call(family);
      }
    } catch (e) {
      log('SongPdfViewer chord callback error: $e', name: 'SongPdfViewer');
    }
  }

  Future<Map<int, NotePosition>> _getNotesForPage(PdfPage page) async {
    final pageNum = page.pageNumber;
    if (_notePositionCache.containsKey(pageNum)) {
      return _notePositionCache[pageNum]!;
    }
    try {
      final rawText = await page.loadText();
      if (rawText == null) return {};
      final positions = extractNotePositions(rawText, page.width, page.height);
      _notePositionCache[pageNum] = positions;
      return positions;
    } catch (e) {
      log('Note extraction error page $pageNum: $e', name: 'SongPdfViewer');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_errorMessage!, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    final doc = _document;
    if (doc == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return PdfViewer.document(
      doc,
      controller: _pdfCtrl,
      params: PdfViewerParams(
        // Use actual param names confirmed in Step 1
        // pageLayoutMode: widget.twoPageMode ? PdfPageLayoutMode.facing : PdfPageLayoutMode.oneColumn,
        backgroundColor: const Color(0xFFECEFF3),
        onPageChanged: (page) => widget.onPageChanged?.call(),
        pageOverlaysBuilder: (context, pageRect, page) {
          if (!widget.showChord) return [];
          final chords = widget.chords;
          if (chords == null || chords.isEmpty) return [];
          final pageNum = page.pageNumber;
          final pageChords = chords[pageNum];
          if (pageChords == null || pageChords.isEmpty) return [];
          final notePositions = _notePositionCache[pageNum];
          if (notePositions == null) {
            // Trigger async load of note positions
            _getNotesForPage(page).then((_) {
              if (mounted) setState(() {});
            });
            return [];
          }
          final badges = <Widget>[];
          for (final chordData in pageChords) {
            final pos = notePositions[chordData.noteIdx];
            if (pos == null) continue;
            final transposedChord = ChordService.transposeChord(
              chordData.chord,
              widget.transposeStep,
              baseTransposeOffset: widget.baseTransposeOffset,
              accidentalMode: widget.chordAccidentalMode,
            );
            badges.add(Positioned(
              left: pageRect.width * pos.xPct / 100,
              top: pageRect.height * pos.yPct / 100,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: _ChordBadge(
                  chord: transposedChord,
                  fontSizePercent: widget.chordFontSizePercent,
                  fillOpacityPercent: widget.chordFillOpacityPercent,
                  paddingPercent: widget.chordPaddingPercent,
                ),
              ),
            ));
          }
          return badges;
        },
      ),
    );
  }
}

class _ChordBadge extends StatelessWidget {
  const _ChordBadge({
    required this.chord,
    required this.fontSizePercent,
    required this.fillOpacityPercent,
    required this.paddingPercent,
  });

  final String chord;
  final int fontSizePercent;
  final int fillOpacityPercent;
  final int paddingPercent;

  @override
  Widget build(BuildContext context) {
    final baseFontSize = 12.0 * fontSizePercent / 100;
    final basePadV = 2.0 * paddingPercent / 100;
    final basePadH = 6.0 * paddingPercent / 100;
    final opacity = fillOpacityPercent / 100.0;

    return Container(
      padding: EdgeInsets.symmetric(vertical: basePadV, horizontal: basePadH),
      decoration: BoxDecoration(
        color: Color.fromRGBO(231, 242, 255, opacity),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [BoxShadow(color: Color(0x2E000000), blurRadius: 3, offset: Offset(0, 1))],
      ),
      child: Text(
        chord,
        style: TextStyle(
          fontSize: baseFontSize,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F315F),
          fontFamily: 'system-ui',
          height: 1.2,
        ),
      ),
    );
  }
}

class _PdfDocumentRequest {
  const _PdfDocumentRequest({
    required this.assetPath,
    required this.startPage,
    required this.pageCount,
  });

  final String assetPath;
  final int startPage;
  final int? pageCount;

  static _PdfDocumentRequest parse(String value) {
    final normalized = value.replaceAll('\\', '/');
    final fragmentIndex = normalized.indexOf('#');
    if (fragmentIndex < 0) {
      return _PdfDocumentRequest(assetPath: normalized, startPage: 1, pageCount: null);
    }
    final assetPath = normalized.substring(0, fragmentIndex);
    final fragment = normalized.substring(fragmentIndex + 1);
    final parts = fragment.split(',');
    final startPage = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 1) : 1;
    final pageCount = parts.length >= 2 ? int.tryParse(parts[1]) : null;
    return _PdfDocumentRequest(assetPath: assetPath, startPage: startPage, pageCount: pageCount);
  }
}
```

**Important notes before writing:**
1. Run Step 1 to confirm actual `PdfViewerParams` param names — especially for `pageLayoutMode`, `onPageChanged`, `pageOverlaysBuilder`
2. The import for pdfrx controller will need a prefix to avoid conflict with our own `PdfViewerController` class. Use: `import 'package:pdfrx/pdfrx.dart' as pdfrx;` and refer to `pdfrx.PdfViewerController()` and `pdfrx.PdfViewer.document(...)`.
3. Remove `import 'dart:io'` and `import 'package:flutter_inappwebview/flutter_inappwebview.dart'` — no longer needed.
4. Remove `import 'package:path/path.dart' as p` — no longer needed.

- [ ] **Step 3: Run flutter analyze**

```
flutter analyze
```

Expected: No issues. Fix any that appear (usually wrong param names found via Step 1 output).

- [ ] **Step 4: Update source_hygiene_test.dart**

Find the test `'song pdf viewer streams assets without base64 handoff'` in `test/source_hygiene_test.dart` and update it to confirm the new approach:

```dart
test('song pdf viewer uses pdfrx and does not use flutter_inappwebview', () {
  final viewerSource = File(
    'lib/presentations/song/widgets/song_pdf_viewer.dart',
  ).readAsStringSync();
  expect(viewerSource, contains('pdfrx'));
  expect(viewerSource, isNot(contains('flutter_inappwebview')));
  expect(viewerSource, isNot(contains('InAppWebView')));
});
```

- [ ] **Step 5: Run all tests**

```
flutter test
```

Expected: All tests pass. If any test fails, fix the issue before continuing.

- [ ] **Step 6: Commit**

```bash
git add lib/presentations/song/widgets/song_pdf_viewer.dart test/source_hygiene_test.dart
git commit -m "feat: rework SongPdfViewer - replace WebView/PDF.js with pdfrx + Flutter chord overlay"
```

---

## Task 4: Remove flutter_inappwebview (optional cleanup)

Only do this task if no other part of the app still uses `flutter_inappwebview`.

- [ ] **Step 1: Check for remaining usages**

```
grep -rn "flutter_inappwebview\|InAppWebView" lib/ test/
```

Expected: No results (only song_pdf_viewer.dart used it, and that's been rewritten).

- [ ] **Step 2: Remove from pubspec.yaml if no longer used**

If no results in Step 1, remove from `pubspec.yaml`:
```yaml
  flutter_inappwebview: ^6.2.0-beta.2  # DELETE this line
```

Then run:
```
flutter pub get
flutter analyze
```

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "deps: remove flutter_inappwebview (replaced by pdfrx)"
```

---

## Task 5: Build and smoke test

- [ ] **Step 1: Build Windows release**

```
flutter build windows --release
```

Expected: `√ Built build\windows\x64\runner\Release\church.exe`

- [ ] **Step 2: Run all tests one final time**

```
flutter test
```

Expected: All tests pass.

- [ ] **Step 3: Commit (if any fixups happened)**

```bash
git add -A
git commit -m "fix: post-rework cleanup and test fixes"
```

---

## Self-Review Notes

- `PdfViewerController` in our code wraps the pdfrx controller — keep them distinct with `as pdfrx` import alias.
- `pageOverlaysBuilder` return type: check if it's `List<Widget>` or something else in actual pdfrx 2.3.2 API.
- `PdfPage.pageNumber` is 1-indexed in pdfrx.
- `_fireChordCallbacks` currently uses `ChordService.detectFamilyChord` but in the old JS it was detected from PDF text. The new approach uses the existing chord data from state. This matches how the app already works (chord data loaded from JSON, not from PDF text).
- The `onPdfTempoDetected` callback was fed from JS that parsed MIDI metadata from PDF. This was a best-effort feature. In the new native version, we skip this detection (it's too complex to port without test PDF files). Set it to not fire — the app works without it (defaults to state tempo).
- `twoPageMode` → use `PdfPageLayoutMode` if available, otherwise skip for now.

# Chord Viewer/Editor Full Feature Parity Design

**Date:** 2026-05-11
**Status:** Design Complete, Pending Implementation

## Overview

This design specifies full feature parity between the Flutter app's chord viewer/editor and the gyschordweb web version, with emphasis on accurate number notation detection to ensure the chord editor works correctly.

## Architecture

The chord system is structured into three clear layers:

### 1. Note Extraction Layer (`pdf_note_extractor.dart`)
Enhanced extraction algorithm matching web version's precision:
- Dominant font size filtering to isolate music notation from other text
- Stricter row grouping (y-tolerance: 2.0 instead of 4)
- Row filtering requiring ≥2 digit notes (not ≥1)
- Multi-character note splitting (e.g., "1 . . 1" → individual notes)

### 2. Chord Data Layer (`chord_service.dart`)
Extended chord data model:
- Support for special indices (intro/outro)
- Theme system with 12 color options
- Fill mode system (3 modes)
- Font size, opacity, and padding controls

### 3. UI Layer (`song_pdf_viewer.dart`, `chord_overlay_widget.dart`)
Note-aligned chord overlay with:
- Inline editing targets
- Clickable note indicators at each extracted note position
- Intro/outro sentinel targets for special positions
- Dissolve animations for chord updates
- Theme/fill controls in edit mode toolbar

## Data Model

### ChordData Enhancements
```dart
class ChordData {
  final int noteIdx; // -1 for intro, 99999 for outro, 0+ for regular notes
  final String chord;
  final int page;
  final String? theme; // Optional: override per-chord theme
  final String? fillMode; // Optional: override per-chord fill
}
```

### NotePosition Model (Enhanced)
```dart
class NotePosition {
  final double xPct; // 0-100
  final double yPct; // 0-100
  final double rowY; // Original PDF y-coordinate for row grouping
  final bool isNote; // true for 1-7 digits
  final bool isDot; // true for "." (continuation)
  final bool isRest; // true for "0" (rest)
}
```

### NoteInfo Model (For Edit Mode)
```dart
class NoteInfo {
  final int idx; // Sequential index across all notes
  final String str; // Character: "1"-"7", ".", "0"
  final double x; // PDF coordinate
  final double y; // PDF coordinate
  final double w; // Width
  final double xPct; // Percentage position
  final double yPct; // Percentage position
  final double rowY; // Row y-coordinate
  final bool isNote;
  final bool isDot;
  final bool isRest;
}
```

### Theme System
```dart
class ChordTheme {
  static const String blue = 'blue';
  static const String red = 'red';
  static const String green = 'green';
  static const String yellow = 'yellow';
  static const String purple = 'purple';
  static const String pink = 'pink';
  static const String teal = 'teal';
  static const String orange = 'orange';
  static const String brown = 'brown';
  static const String gray = 'gray';
  static const String indigo = 'indigo';
  static const String cyan = 'cyan';

  static Color getColor(String theme) { /* mapping to Flutter colors */ }
}
```

### Fill Mode System
```dart
class ChordFillMode {
  static const String none = 'none';
  static const String soft = 'soft';
  static const String solid = 'solid';
}
```

### Special Index Constants
```dart
class ChordSpecialIndices {
  static const int before = -1; // Intro position
  static const int after = 99999; // Outro position
}
```

## Note Extraction Algorithm

### Step 1: Dominant Font Size Detection
- Filter text items containing note characters (1-7, 0, .)
- Find most common font size among candidate items
- Use tolerance of ±1.5 PDF units for font size matching
- This isolates music notation from other text (page numbers, lyrics, etc.)

### Step 2: Multi-Character Note Splitting
- Handle PDFs that return "1 . . 1" as single text item
- Split by character with interpolated x-positions
- Each character gets equal width slot
- Only keep characters matching /[0-7.]/ pattern

### Step 3: Row Grouping
- Sort notes by y descending (higher y = higher on page)
- Group notes with y-tolerance of 2.0 PDF units (was 4 in Flutter)
- This matches web's tighter grouping

### Step 4: Row Filtering
- Filter rows with ≥2 digit notes (was ≥1 in Flutter)
- This eliminates stray numbers that aren't music notation
- Only rows with actual musical content are kept

### Step 5: Sequential Indexing
- Assign sequential indices (0, 1, 2, ...) across all filtered rows
- Sort rows by y descending, items within rows by x ascending
- This ensures consistent indexing matching web version

## Chord Positioning

### Position Calculation
```dart
x = note.xPct / 100.0 * pageSize.width
y = (note.yPct - 2.5) / 100.0 * pageSize.height  // 2.5% offset above note
```

### Special Positions
- **Intro (NOTE_IDX_BEFORE = -1)**: x = firstNote.xPct - 2.5%, y = firstNote.yPct
- **Outro (NOTE_IDX_AFTER = 99999)**: x = lastNote.xPct + 2.5%, y = lastNote.yPct
- Clamp x to 1-99% range to keep chords within page bounds

## Visual Styling System

### 12 Color Themes
Each theme defines text color and corresponding fill color:

| Theme | Text Color | Fill Color |
|-------|------------|------------|
| Blue | #0b4c99 | #b8dbff |
| Red | #9c1616 | #ffc4c4 |
| Green | #1b5a20 | #b8f0bc |
| Yellow | #b38200 | #ffecb3 |
| Purple | #59117a | #e3bdf2 |
| Pink | #960e44 | #ffbccf |
| Teal | #004d43 | #a5ede4 |
| Orange | #b35600 | #ffcc99 |
| Brown | #3e2923 | #d6c1ba |
| Gray | #383838 | #cfcfcf |
| Indigo | #1e2870 | #c6d0ff |
| Cyan | #00646e | #b5f0f7 |

### 3 Fill Modes
- **None**: Transparent background, no border radius
- **Soft**: 32% fill color mixed with white, 70% opacity, 6px border radius
- **Solid**: 65% fill color mixed with white, 70% opacity, 6px border radius

### Adaptive Font Size
```dart
fontSize = 0.55 * pdfScale * (fontOverridePercent / 100)
// Clamp to 0.2 - 20.0 logical pixels range (scaled by device pixel ratio)
```
This ensures chords scale with PDF zoom level.

### Dissolve Animations
- Fade out (180ms) → update chord → fade in (230ms)
- Applied during transpose and chord edits
- Cubic-bezier easing for smooth transitions

## Edit Mode UX

### Note Targets
- Clickable indicators at each extracted note position
- Display note character (1-7, · for dot, 0 for rest)
- Highlight if chord already assigned
- Tap to open inline chord editor

### Sentinel Targets
- **Intro target** (▸): Before first note, for intro chords
- **Outro target** (◂): After last note, for outro chords
- Special styling to distinguish from regular notes

### Inline Chord Editor
- Bottom sheet or dialog with chord input field
- Real-time chord validation
- Quick transpose buttons (+/- semitone)
- Save/Cancel buttons
- Empty input removes chord

### Edit Mode Toolbar
- Toggle edit mode button
- Theme selector (12 colors)
- Fill mode selector (none/soft/solid)
- Fill opacity slider
- Font size slider
- Padding scale slider
- Save chord configuration button

## Error Handling

### Extraction Failures
- If note extraction fails completely, fall back to grid-based positioning (existing fallback)
- Log extraction errors with page number and error details
- Show user-friendly message if no notes detected

### Chord Validation
- Validate chord format before saving
- Support number notation (1-7) and letter notation (A-G)
- Reject invalid chord patterns
- Show inline validation errors

### State Management
- Persist chord edits in memory during session
- Auto-save on page navigation or song change
- Handle save failures gracefully with retry option

## Testing Strategy

### Unit Tests
- Note extraction algorithm with sample PDF data
- Row grouping logic with various y-tolerance values
- Chord positioning calculations
- Theme and fill color mapping
- Chord validation logic

### Integration Tests
- Full chord overlay rendering with real PDFs
- Edit mode interaction flow
- Transpose functionality with animations
- Save/load chord configuration
- Fallback positioning when extraction fails

### Manual Testing
- Test with songs that have complex note layouts
- Verify intro/outro chord placement
- Test all 12 themes and 3 fill modes
- Verify animations during transpose
- Test on different screen sizes and orientations

## Implementation Phases

### Phase 1: Note Extraction Enhancement
- Update `pdf_note_extractor.dart` with dominant font size filtering
- Implement multi-character note splitting
- Change y-tolerance to 2.0
- Change row filter to ≥2 digits
- Add sequential indexing

### Phase 2: Data Model Extensions
- Add theme and fill mode systems to `chord_service.dart`
- Add special index constants
- Extend `ChordData` model
- Add theme color mapping

### Phase 3: Visual Styling
- Implement 12 color themes
- Implement 3 fill modes
- Add adaptive font size calculation
- Add dissolve animations
- Update chord badge widget styling

### Phase 4: Edit Mode UX
- Add note target indicators
- Add intro/outro sentinel targets
- Implement inline chord editor
- Add edit mode toolbar
- Implement chord validation

### Phase 5: Integration and Testing
- Integrate all components
- Write unit and integration tests
- Manual testing with real songs
- Performance optimization
- Bug fixes and refinement

## Success Criteria

✅ Note extraction accuracy matches web version (within 2px positioning error)
✅ All 12 color themes render correctly
✅ All 3 fill modes work as expected
✅ Dissolve animations play smoothly during transpose
✅ Intro/outro chords place correctly
✅ Edit mode note targets align with extracted notes
✅ Chord validation catches invalid inputs
✅ Fallback positioning works when extraction fails
✅ Performance is acceptable (no lag during PDF rendering)

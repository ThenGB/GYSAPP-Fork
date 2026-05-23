# PDF Viewer Entry & Transition Animation Design

**Date:** 2026-05-23
**Status:** Approved

## Problem

When entering the PDF viewer or changing songs, the PDF briefly displays at an incorrect zoom/size before `fitToPage` applies, causing a flicker/glitch effect.

## Solution

**Hide the PDF completely until fit-to-page is complete, then smoothly fade it in.**

## Animation Timing

| Event | Duration | Behavior |
|-------|----------|----------|
| Exit (song change) | 150ms | Opacity 1.0 → 0.0 |
| Load & Fit | Variable | PDF hidden, no animation |
| Entry (fade in) | 300ms | Opacity 0.0 → 1.0 |
| Initial entry | 300ms | Same as entry |

## Implementation Details

### New State Flag

```dart
bool _pdfFullyVisible = false;  // Controls visibility after fit-to-page completes
```

### Flow: Initial Entry

1. State initialized with `_pdfFullyVisible = false`
2. PDF viewer loads hidden (opacity = 0)
3. `onViewerReady` fires, `_fitToPageInstant()` called
4. Fit completes → `_pdfFullyVisible = true`
5. Fade-in animation starts (opacity 0 → 1 over 300ms)

### Flow: Song Change

1. User navigates to new song
2. `_pdfFullyVisible = false` immediately
3. Fade-out animation (opacity 1 → 0 over 150ms)
4. On fade-out complete → set new `_pdfRequest`, wait for fit
5. Fit completes → `_pdfFullyVisible = true`
6. Fade-in animation starts (opacity 0 → 1 over 300ms)

### Visibility Check in Build

```dart
return Opacity(
  opacity: _pdfFullyVisible ? _navOpacity.value : 0.0,
  child: viewer,
);
```

### Key Improvements

- **No flicker**: PDF never visible until fit-to-page is complete
- **Smooth entry**: 300ms fade-in feels polished
- **Snappy transitions**: 150ms fade-out between songs
- **Consistent behavior**: Same logic for initial entry and song changes

## Files to Modify

- `lib/presentations/song/widgets/song_pdf_viewer.dart`
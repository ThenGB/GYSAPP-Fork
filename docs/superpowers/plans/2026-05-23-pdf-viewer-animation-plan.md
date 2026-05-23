# PDF Viewer Entry & Transition Animation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Hide PDF until fit-to-page completes, then smoothly fade it in. Add 150ms fade-out between songs and 300ms fade-in after fit.

**Architecture:** Single animation controller with `_pdfFullyVisible` flag to control when fade animation is allowed to start. PDF stays at opacity 0 until fit completes.

**Tech Stack:** Flutter AnimatedBuilder, AnimationController, pdfrx PdfViewerController

---

## Task 1: Add `_pdfFullyVisible` flag and update animation controller

**Files:**
- Modify: `lib/presentations/song/widgets/song_pdf_viewer.dart:68-126`

- [ ] **Step 1: Add new state flag after `_isTransitioning`**

```dart
/// True while the viewer is transitioning between PDFs (fading out/in).
/// Used to prevent rendering new chords on the old PDF document.
bool _isTransitioning = false;

/// Controls whether the PDF should be visible (true) or hidden (false).
/// PDF stays hidden until fit-to-page completes, then animates to visible.
bool _pdfFullyVisible = false;
```

- [ ] **Step 2: Update animation controller duration for fade-in**

Change the duration to support 300ms fade-in (we'll manage fade-out timing separately):

```dart
_navFadeCtrl = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 300),
);
```

- [ ] **Step 3: Commit**

```bash
git add lib/presentations/song/widgets/song_pdf_viewer.dart
git commit -m "feat(song_pdf_viewer): add _pdfFullyVisible flag for animation control"
```

---

## Task 2: Update `_parsePdfPath()` for song change flow

**Files:**
- Modify: `lib/presentations/song/widgets/song_pdf_viewer.dart:177-240`

- [ ] **Step 1: Update the song change flow in `_parsePdfPath()`**

Replace the entire block from "Different PDF - start transition" through the else clause:

```dart
    // Different PDF - start transition
    _pathGeneration++;
    _cachedLayout = null;
    _cachedLayoutKey = null;
    _needsInitialFit = true;
    _viewerReadyGeneration = null;
    _viewerReadyWatchdog?.cancel();
    _metadataPrimedSourceId = null;
    _noteStatsLogged.clear();
    _isTransitioning = true;

    // Clear note extraction cache when PDF changes
    _NoteExtractionCache.clear();

    // Hide the viewer immediately when changing songs
    _pdfFullyVisible = false;

    // Start fade out animation if there was a previous PDF
    if (oldRequest != null) {
      // Set controller to fade-out position (value=1, opacity=0)
      _navFadeCtrl.value = 1.0;
      // Animate fade out over 150ms (fast portion of 300ms total)
      _navFadeCtrl.duration = const Duration(milliseconds: 150);
      _navFadeCtrl.forward(from: 0).then((_) {
        if (mounted) {
          setState(() {
            _pdfRequest = newRequest;
            _isTransitioning = false;
          });
          // Schedule watchdog for the new PDF
          _scheduleViewerReadyWatchdog(_pathGeneration);
        }
        // Reset controller to mid-point for fade-in (value=0, opacity=1)
        _navFadeCtrl.value = 0.0;
      });
    } else {
      // No previous PDF, just show the new one hidden
      if (mounted) setState(() => _pdfRequest = newRequest);
      _navFadeCtrl.value = 0.0;
      _isTransitioning = false;
      _scheduleViewerReadyWatchdog(_pathGeneration);
    }
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentations/song/widgets/song_pdf_viewer.dart
git commit -m "feat(song_pdf_viewer): update fade animation for song changes"
```

---

## Task 3: Update `_waitForValidSizeAndFit()` for fade-in trigger

**Files:**
- Modify: `lib/presentations/song/widgets/song_pdf_viewer.dart:386-416`

- [ ] **Step 1: Update the method to set `_pdfFullyVisible` and trigger fade-in**

Replace the entire `_waitForValidSizeAndFit` method:

```dart
  void _waitForValidSizeAndFit(
    pdfrx.PdfViewerController ctrl,
    int generation,
  ) async {
    final stableSize = await _waitForStableViewerSize(ctrl, generation);
    if (stableSize == null || !mounted || generation != _pathGeneration) {
      return;
    }

    // Use a microtask to perform the fit immediately after size is available
    // instead of a hard 100ms delay.
    if (_needsInitialFit) {
      if (!_fitToPageInstant()) {
        _scheduleFitWithFallback();
        return;
      }

      // Use a single frame delay instead of 60ms for the invalidate.
      await Future.microtask(() {});
      if (mounted && generation == _pathGeneration) {
        _invalidatePdfIfReady();
        setState(() {}); // Force overlay rebuild after fit
      }
    }

    // PDF is now fully fitted. Trigger fade-in animation.
    if (mounted && generation == _pathGeneration) {
      _pdfFullyVisible = true;
      _isTransitioning = false;
      // Ensure controller is at start position for fade-in
      _navFadeCtrl.value = 0.0;
      // Use full 300ms for fade-in animation
      _navFadeCtrl.duration = const Duration(milliseconds: 300);
      _navFadeCtrl.forward(from: 0);
    }
  }
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentations/song/widgets/song_pdf_viewer.dart
git commit -m "feat(song_pdf_viewer): trigger fade-in animation after fit completes"
```

---

## Task 4: Update `build()` to control visibility

**Files:**
- Modify: `lib/presentations/song/widgets/song_pdf_viewer.dart:634-642`

- [ ] **Step 1: Update the opacity logic in build()**

Replace the return statement in `build()`:

```dart
    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: _navFadeCtrl,
        child: viewer,
        builder: (context, child) {
          // Only show the PDF when _pdfFullyVisible is true.
          // Before that, keep it hidden (opacity 0).
          final opacity = _pdfFullyVisible ? (1.0 - _navFadeCtrl.value) : 0.0;
          return Opacity(opacity: opacity, child: child);
        },
      ),
    );
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentations/song/widgets/song_pdf_viewer.dart
git commit -m "feat(song_pdf_viewer): add visibility control based on _pdfFullyVisible"
```

---

## Task 5: Handle null PDF path case

**Files:**
- Modify: `lib/presentations/song/widgets/song_pdf_viewer.dart:177-192`

- [ ] **Step 1: Update the null path handling**

In `_parsePdfPath()`, update the null path case to also hide the viewer:

```dart
  void _parsePdfPath() {
    final path = widget.pdfPath;
    if (path == null) {
      // Starting a transition to null (no PDF)
      _pathGeneration++;
      _cachedLayout = null;
      _cachedLayoutKey = null;
      _needsInitialFit = false;
      _viewerReadyGeneration = null;
      _viewerReadyWatchdog?.cancel();
      _pdfFullyVisible = false;
      _isTransitioning = true; // Start transition
      // Quick fade out
      _navFadeCtrl.value = 1.0;
      _navFadeCtrl.duration = const Duration(milliseconds: 150);
      _navFadeCtrl.forward(from: 0); // Fade out current
      _navFadeCtrl.addListener(_onFadeCompleteForNull);
      if (mounted) setState(() => _pdfRequest = null);
      return;
    }
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentations/song/widgets/song_pdf_viewer.dart
git commit -m "feat(song_pdf_viewer): hide viewer when PDF path is null"
```

---

## Task 6: Final integration test

**Files:**
- Test: `lib/presentations/song/widgets/song_pdf_viewer.dart`

- [ ] **Step 1: Run the analyzer to check for errors**

```bash
flutter analyze lib/presentations/song/widgets/song_pdf_viewer.dart
```

Expected: No errors

- [ ] **Step 2: Build to verify compilation**

```bash
flutter build web --debug 2>&1 | head -50
```

Expected: Build succeeds or shows only unrelated errors

- [ ] **Step 3: Commit final changes**

```bash
git add -A
git commit -m "feat(song_pdf_viewer): smooth fade animation for PDF entry and transitions

- Hide PDF until fit-to-page completes
- 150ms fade-out between songs
- 300ms fade-in after fit completes
- Prevents flicker/glitch on entry and song change

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Self-Review Checklist

- [ ] All spec requirements covered: initial entry, song change, animation timing
- [ ] No placeholders (TBD, TODO) in plan
- [ ] Type consistency: `_pdfFullyVisible` flag used consistently
- [ ] Each task commits independently
- [ ] Build/test commands included
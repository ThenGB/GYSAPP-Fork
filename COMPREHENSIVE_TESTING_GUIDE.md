# Comprehensive Testing Guide
## Testing Chord Viewer, Editor Mode, and Mini Player Layout

**Status:** MCP servers are unavailable, so this guide focuses on manual testing and Flutter widget tests.

---

## Test Environment Setup

### Prerequisites
1. Flutter environment set up and working
2. App running on device/emulator or web browser
3. Test PDF files available in the app

### Running the App
```bash
# Run on connected device/emulator
flutter run

# Run on web
flutter run -d chrome
```

---

## Test Component 1: Chord Viewer

### Test Cases

#### 1.1 Basic Chord Display
- [ ] Navigate to a song with chords
- [ ] Verify chord badges appear over the PDF
- [ ] Check that chords are positioned correctly over notes
- [ ] Verify chord badges are readable and not overlapping

#### 1.2 Chord Positioning Accuracy
- [ ] Open a song with known chord positions
- [ ] Compare chord positions with expected locations
- [ ] Check for systematic offset issues (left/right, up/down)
- [ ] Verify chords align with musical notes in the PDF

#### 1.3 Multiple Pages
- [ ] Navigate through pages of a multi-page PDF
- [ ] Verify chords appear correctly on each page
- [ ] Check that chord positions are consistent across pages

#### 1.4 Zoom and Pan
- [ ] Zoom in on the PDF
- [ ] Verify chord badges scale and position correctly
- [ ] Pan around the page
- [ ] Check that chords stay attached to correct positions

#### 1.5 Different PDF Files
- [ ] Test with different PDF files (various fonts, layouts)
- [ ] Verify chord extraction works for different music notation styles
- [ ] Check edge cases (sparse notation, dense notation)

### Expected Behavior
- Chord badges should appear as colored rounded rectangles with chord names
- Chords should be positioned above their corresponding notes
- Positioning should be accurate within ±2% of page width/height
- Chords should remain visible and correctly positioned during zoom/pan

---

## Test Component 2: Editor Mode

### Test Cases

#### 2.1 Enabling Editor Mode
- [ ] Navigate to a song
- [ ] Enable edit mode (via toggle or menu)
- [ ] Verify that note targets appear on the PDF
- [ ] Check that note targets are clickable/tappable

#### 2.2 Note Targets Display
- [ ] Verify note targets appear at detected note positions
- [ ] Check that different note types have appropriate labels:
  - Music digits (1-7) should show the digit
  - Dots should show "·"
  - Other characters should show the character
- [ ] Verify intro/outro sentinels appear (▸ symbols)
- [ ] Check that targets are positioned accurately

#### 2.3 Note Target Count
- [ ] Count the number of note targets displayed
- [ ] Compare with expected count based on PDF content
- [ ] Verify that all music digits are detected
- [ ] Check that dots are also detected

#### 2.4 Clicking Note Targets
- [ ] Click on a note target
- [ ] Verify that a chord editing interface appears
- [ ] Check that the correct note index is selected
- [ ] Verify that chord can be assigned to the note

#### 2.5 Chord Assignment
- [ ] Assign a chord to a note target
- [ ] Verify that a chord badge appears at that position
- [ ] Check that the chord badge shows the assigned chord name
- [ ] Verify that the assignment persists

#### 2.6 Editing Existing Chords
- [ ] Click on an existing chord badge
- [ ] Verify that edit interface opens with current chord
- [ ] Modify the chord
- [ ] Verify that the badge updates with new chord

#### 2.7 Deleting Chords
- [ ] Click on an existing chord badge
- [ ] Delete the chord assignment
- [ ] Verify that the chord badge disappears
- [ ] Verify that the note target remains visible

#### 2.8 Exiting Editor Mode
- [ ] Disable edit mode
- [ ] Verify that note targets disappear
- [ ] Check that assigned chord badges remain visible
- [ ] Verify normal viewing mode is restored

### Expected Behavior
- Note targets should appear as small clickable markers at detected note positions
- Clicking a target should open chord assignment interface
- Assigned chords should appear as badges over the PDF
- Editor mode should toggle cleanly without affecting normal viewing

---

## Test Component 3: Mini Player Layout

### Test Cases

#### 3.1 Mini Player Display
- [ ] Navigate to dashboard
- [ ] Verify mini player appears at bottom of screen
- [ ] Check that it doesn't overlap main content
- [ ] Verify it's properly positioned with bottom offset

#### 3.2 Previous/Next Buttons
- [ ] Verify Previous button appears before Play button
- [ ] Verify Next button appears after Play button
- [ ] Click Previous button when not on first song
  - [ ] Verify navigation to previous song
  - [ ] Check that mini player updates with new song info
- [ ] Click Previous button when on first song
  - [ ] Verify button is disabled (grayed out)
  - [ ] Verify no navigation occurs
- [ ] Click Next button when not on last song
  - [ ] Verify navigation to next song
  - [ ] Check that mini player updates with new song info
- [ ] Click Next button when on last song
  - [ ] Verify button is disabled (grayed out)
  - [ ] Verify no navigation occurs

#### 3.3 Play/Pause Button
- [ ] Verify Play/Pause button works correctly
- [ ] Check that icon changes between play and pause
- [ ] Verify playback state updates correctly

#### 3.4 Tempo Controls
- [ ] Verify tempo control button appears (replaced piano placeholder)
- [ ] Click tempo control button
- [ ] Verify tempo adjustment interface appears
- [ ] Increase tempo
  - [ ] Verify tempo value increases
  - [ ] Check that playback speed increases
- [ ] Decrease tempo
  - [ ] Verify tempo value decreases
  - [ ] Check that playback speed decreases
- [ ] Set tempo to default
  - [ ] Verify tempo resets to 1.0x
  - [ ] Check that playback speed returns to normal

#### 3.5 Accidental Toggle (♯/♭)
- [ ] Verify accidental toggle button appears
- [ ] Check default accidental state (likely ♯)
- [ ] Click accidental toggle button
  - [ ] Verify accidental symbol changes (♯ ↔ ♭)
  - [ ] Check that chord transposition updates
  - [ ] Verify all chords update with new accidental
- [ ] Click again to toggle back
  - [ ] Verify accidental symbol returns to original
  - [ ] Check that chords transpose back

#### 3.6 Mini Player Responsiveness
- [ ] Test on different screen sizes
- [ ] Verify layout adapts correctly
- [ ] Check that buttons remain tappable on small screens
- [ ] Verify no overflow or clipping issues

#### 3.7 Mini Player State Persistence
- [ ] Navigate away from dashboard
- [ ] Return to dashboard
- [ ] Verify mini player state is preserved (song, playback, tempo, accidental)

### Expected Behavior
- Mini player should be fixed at bottom with proper offset
- Previous/Next buttons should navigate between songs with proper disable states
- Tempo control should adjust playback speed with visual feedback
- Accidental toggle should switch between ♯ and ♭ with chord transposition
- All controls should be responsive and work together correctly

---

## Integration Testing

### Test All Components Together

#### Scenario 1: Complete Workflow
1. [ ] Open app and navigate to dashboard
2. [ ] Play a song from mini player
3. [ ] Navigate to song detail view
4. [ ] Verify chord viewer displays chords correctly
5. [ ] Enable editor mode
6. [ ] Assign/modify chords using note targets
7. [ ] Return to dashboard
8. [ ] Use Previous/Next to navigate songs
9. [ ] Adjust tempo
10. [ ] Toggle accidental
11. [ ] Verify all changes persist correctly

#### Scenario 2: Edge Cases
1. [ ] Test with PDF that has no detectable notes
2. [ ] Test with PDF that has very dense notation
3. [ ] Test with single-song playlist
4. [ ] Test with empty playlist
5. [ ] Test rapid navigation between songs
6. [ ] Test rapid tempo changes
7. [ ] Test rapid accidental toggling

---

## Flutter Widget Tests

Create widget tests for the following:

### Test Files to Create
1. `test/dashboard/mini_player_widget_test.dart` - Test mini player layout and controls
2. `test/song/chord_overlay_test.dart` - Test chord overlay and positioning
3. `test/song/editor_mode_test.dart` - Test editor mode and note targets

### Running Widget Tests
```bash
# Run all widget tests
flutter test

# Run specific test file
flutter test test/dashboard/mini_player_widget_test.dart

# Run with coverage
flutter test --coverage
```

---

## Manual Testing Checklist

Use this checklist for systematic manual testing:

### Pre-Testing Setup
- [ ] Flutter environment is working
- [ ] App builds successfully
- [ ] Test device/emulator is connected
- [ ] Test PDF files are available

### Chord Viewer
- [ ] Basic display works
- [ ] Positioning is accurate
- [ ] Multiple pages work
- [ ] Zoom/pan works
- [ ] Different PDFs work

### Editor Mode
- [ ] Mode toggles correctly
- [ ] Note targets appear
- [ ] Targets are clickable
- [ ] Chord assignment works
- [ ] Chord editing works
- [ ] Chord deletion works
- [ ] Mode exit works

### Mini Player
- [ ] Display is correct
- [ ] Previous/Next works
- [ ] Play/Pause works
- [ ] Tempo control works
- [ ] Accidental toggle works
- [ ] Responsive design works
- [ ] State persists

### Integration
- [ ] Complete workflow works
- [ ] Edge cases handled
- [ ] No crashes or errors

---

## Issue Reporting

If any issues are found, document:
1. Component being tested
2. Test case that failed
3. Expected behavior
4. Actual behavior
5. Steps to reproduce
6. Screenshots (if possible)
7. Device/emulator information
8. Flutter version

---

## Next Steps After Testing

1. If all tests pass: Consider committing the changes
2. If issues found: Create bug reports and fix issues
3. If MCP servers become available: Re-run automated visual tests
4. Update documentation with any findings

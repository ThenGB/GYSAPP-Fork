# Manual Testing Guide for Mini Player Features

## Important Note
MCP servers (Playwright, Puppeteer, Marionette, Fetch) are all currently non-functional, so automated visual testing is not possible. Please perform manual testing following this guide.

## What Was Implemented
Based on code analysis of gyschordweb web version, the following features were added to Flutter mini player:

### 1. Previous/Next Navigation Buttons
**Location:** Flanking the Play button in the mini player
**Expected Behavior:**
- Previous button (⏮) should be on the left of Play button
- Next button (⏭) should be on the right of Play button
- Both should be disabled (dimmed) when at first/last song respectively
- Clicking should navigate to previous/next song

### 2. Tempo Control Button
**Location:** Replaced the piano placeholder button
**Expected Behavior:**
- Should show speed icon + BPM value (e.g., "76")
- Clicking should increment tempo by 5 BPM
- Value should clamp between 30-220 BPM
- Should update in real-time

### 3. Accidental Toggle Button
**Location:** After transpose controls, before loop button
**Expected Behavior:**
- Should show ♯ or ♭ symbol
- Clicking should toggle between sharp and flat mode
- Should have Material Design ripple effect
- Should update chord display accordingly

## Manual Testing Steps

### Step 1: Launch App
```bash
cd "d:\GitHub Repo\church"
flutter run -d windows
```

### Step 2: Navigate to Dashboard
- Open the app
- Navigate to the Dashboard tab
- Mini player should be visible at the bottom

### Step 3: Test Previous/Next Buttons
1. **Locate the buttons:** Look for ⏮ and ⏭ buttons around the Play button
2. **Test Previous button:**
   - If not on first song, click ⏮
   - Should navigate to previous song
   - If on first song, button should be disabled/dimmed
3. **Test Next button:**
   - If not on last song, click ⏭
   - Should navigate to next song
   - If on last song, button should be disabled/dimmed

**Expected Result:** Buttons should be positioned correctly and navigation should work smoothly

### Step 4: Test Tempo Control
1. **Locate tempo button:** Look for button with speed icon and BPM number
2. **Click the button:** Should increment by 5 BPM
3. **Observe the number:** Should update (e.g., 76 → 81 → 86)
4. **Test limits:** Try to exceed 220 BPM or go below 30 BPM
5. **Expected Result:** Should clamp at 30-220 BPM range

### Step 5: Test Accidental Toggle
1. **Locate accidental button:** Look for button with ♯ or ♭ symbol
2. **Note current state:** Remember whether it shows ♯ or ♭
3. **Click the button:** Should toggle to the opposite
4. **Verify visual feedback:** Should have ripple effect
5. **Check chord display:** Chords should reflect the accidental change

## Potential Issues to Check

### UI Layout Issues
- [ ] Are Previous/Next buttons positioned correctly around Play button?
- [ ] Is there enough spacing between buttons?
- [ ] Are buttons aligned properly?
- [ ] Is the mini player layout broken or overlapping?

### Functional Issues
- [ ] Do Previous/Next buttons actually navigate songs?
- [ ] Are disabled states working correctly?
- [ ] Does tempo increment work on each click?
- [ ] Does accidental toggle actually change the mode?
- [ ] Is there any crash or error when clicking buttons?

### Visual Issues
- [ ] Do button icons display correctly?
- [ ] Is the BPM text readable?
- [ ] Is the accidental symbol (♯/♭) rendering correctly?
- [ ] Are colors and styling consistent with the rest of the app?

## Comparison with Web Version

### Web Mini Player Layout:
```
[Prev] [Play] [Next]  [Tempo: 76 BPM]  [Transpose] [♯/♭]  [Instruments]
```

### Expected Flutter Layout:
```
[Prev] [Play] [Next]  [Progress]  [Time]  [Transpose] [♯/♭]  [Tempo: 76]  [Loop]
```

## Feedback Needed

Please test each feature and report:
1. **Does the feature appear at all?** (visible in UI)
2. **Is it positioned correctly?** (layout matches expectation)
3. **Does it function as expected?** (click produces correct result)
4. **Are there any visual issues?** (styling, alignment, rendering)
5. **Any errors or crashes?** (console output, app behavior)

## If Issues Found

Please provide:
- Screenshot of the mini player
- Description of what's wrong
- Expected vs actual behavior
- Any error messages from console

This will help identify whether the issue is:
- Code implementation problem
- UI layout problem  
- Missing dependencies
- Logic error
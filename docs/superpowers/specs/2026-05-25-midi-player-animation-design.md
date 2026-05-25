# MIDI Player Animation Design Specification

**Date**: 2026-05-25
**Status**: Approved
**Version**: 1.0

## Overview

Redesign the MIDI player (DraggableMidiControls) with a multi-phase animation system that transforms between a sidebar trigger button and a floating mini-player. The design follows a floating mini-player style where the header floats above the controls.

---

## 1. Visual Design

### 1.1 States

| State | Description |
|-------|-------------|
| `sidebar_circle` | Collapsed sidebar button (56x56 circle) |
| `flying_circle` | Circle animating to target position |
| `expanding_player` | Circle morphing into player shape |
| `expanded_player` | Full MIDI player visible |
| `collapsing_player` | Player shrinking into circle |
| `flying_sidebar` | Circle animating to sidebar position |

### 1.2 Layout Structure

**Expanded Player (Floating Mini-Player Style)**:
```
┌─────────────────────────────────────────┐
│ [🎵 Now Playing - Song Title      ▼]   │  ← Floating header (48px)
├─────────────────────────────────────────┤
│  ▶  ════════════════════════  0:00/3:00 │  ← Controls below header
│  [Transpose] [Tempo] [🎹] [🔁]          │
└─────────────────────────────────────────┘
```

**Sidebar Circle**:
```
┌───┐
│ 🎵│  ← 56x56 circle, draggable
└───┘
```

### 1.3 Color & Style

- **Primary color**: Uses `colorScheme.primary` from theme
- **Background**: `surfaceContainerLowest` with `0.82` opacity + blur
- **Border**: Gold accent `Color(0xFFD4AF37)` at 35% opacity
- **Shadow**: Primary color with 30% opacity, blur 12px

---

## 2. Animation System

### 2.1 Timing Constants

| Phase | Duration | Curve |
|-------|----------|-------|
| Phase 1 (Fly) | 150ms | `Curves.easeOutCubic` |
| Phase 2 (Morph) | 150ms | `Curves.easeInOutCubic` |

**Total expand time**: 300ms
**Total collapse time**: 300ms

### 2.2 Expand Animation Sequence

```
sidebar_circle → flying_circle → expanding_player → expanded_player
```

1. **Phase 1 - Fly (150ms)**:
   - Circle translates from sidebar position to player position (centered, bottom)
   - Shape remains circular
   - Optional: subtle scale pulse (1.0 → 1.05 → 1.0)

2. **Phase 2 - Morph (150ms)**:
   - Border radius morphs: full circle → pill (top corners rounded) → header shape
   - Width expands: 56px → 95% screen width
   - Height expands: 56px → header height (48px)
   - Controls fade in below header

### 2.3 Collapse Animation Sequence

```
expanded_player → collapsing_circle → flying_sidebar → sidebar_circle
```

1. **Phase 1 - Collapse (150ms)**:
   - Controls fade out
   - Shape morphs from header → circle
   - Circle remains at player position

2. **Phase 2 - Fly (150ms)**:
   - Circle translates to snap position (left or right based on `_sidebarX`)
   - Final position: left edge or right edge based on last drag position

### 2.4 Sidebar Drag Behavior

**Drag to Snap Zones**:
- Screen divided by center: left half → snap left, right half → snap right
- During drag: circle has hover effect (subtle scale 1.1x)
- On release within snap zone: animate to final position
- Snap position:
  - Left: `collapsedMargin` from left edge
  - Right: `collapsedMargin` from right edge

**Free Positioning**:
- Circle can be dragged anywhere (Y-axis: top to 75% of screen height)
- X-axis clamped to remain fully visible
- `_sidebarX` stores normalized position (0 = left, 1 = right) for snap direction

---

## 3. Component Architecture

### 3.1 State Machine

```dart
enum MidiPlayerAnimationState {
  sidebar_circle,
  flying_to_player,
  expanding_player,
  expanded_player,
  collapsing_player,
  flying_to_sidebar,
}
```

### 3.2 Animation Controller Setup

```dart
late AnimationController _expandController;  // Phase 1 (fly)
late AnimationController _morphController;  // Phase 2 (morph)

// Or use a single controller with keyframe-like behavior
late AnimationController _mainController;
Animation<double> flyPhase;   // 0.0 → 0.5
Animation<double> morphPhase; // 0.5 → 1.0
```

### 3.3 State Variables

```dart
// Position tracking
double _sidebarX = 0.0;  // 0 = left edge, 1 = right edge (normalized)
double _sidebarY = 0.5; // 0 = top, 1 = bottom (normalized)

// Animation state
MidiPlayerAnimationState _state = MidiPlayerAnimationState.expanded_player;
bool _isExpanding = false;
```

### 3.4 Position Calculation

**Sidebar Snap Position**:
```dart
double get snapX {
  final threshold = MediaQuery.sizeOf(context).width / 2;
  final currentX = _sidebarX * screenWidth;
  return currentX < threshold ? 0.0 : 1.0;
}
```

**Fly Target Positions**:
```dart
Offset get playerPosition {
  // Centered at bottom, above nav bar
  return Offset(
    (screenWidth - playerWidth) / 2,
    bottomOffset,
  );
}

Offset get sidebarPosition {
  final maxLeft = screenWidth - collapsedWidth - collapsedMargin;
  final minLeft = collapsedMargin;
  return Offset(
    minLeft + (snapX * (maxLeft - minLeft)),
    sidebarBottom,
  );
}
```

---

## 4. UI Components

### 4.1 Floating Header

- **Position**: Top of the expanded player
- **Height**: 48px
- **Content**: Music icon + "Now Playing" title + collapse chevron
- **Behavior**: Tap anywhere on header triggers collapse

### 4.2 Control Panel

- **Position**: Below the floating header
- **Content**: Play/pause, seek slider, transpose, tempo, instrument, loop
- **Styling**: Blur background, rounded top corners, gold border

### 4.3 Circle Trigger

- **Size**: 56x56 (when collapsed)
- **Content**: Queue music icon with pulse animation when playing
- **States**:
  - Idle: static circle
  - Playing: subtle pulse/bounce animation
  - Dragging: hover scale (1.1x)

---

## 5. Layout Constants

```dart
const double kMidiOverlayHorizontalMargin = 16;
const double kMidiCollapsedBarHeight = 56;  // Circle size
const double kMidiCollapsedBarWidth = 56;
const double kMidiExpandedHeaderHeight = 48;
const double kMidiSidebarButtonMargin = 16;
const double kMidiSidebarButtonSize = 56;
const double kMidiExpandedMaxWidth = 460;
```

---

## 6. Implementation Notes

### 6.1 Border Radius Morphing

```dart
BorderRadius get borderRadius {
  if (isCircle) {
    return BorderRadius.all(Radius.circular(size / 2));
  } else if (isMorphing) {
    // Interpolate based on animation progress
    return BorderRadius.only(
      topLeft: Radius.circular(lerp(28, 16, progress)),
      topRight: Radius.circular(lerp(28, 16, progress)),
      bottomLeft: Radius.circular(lerp(28, 0, progress)),
      bottomRight: Radius.circular(lerp(28, 0, progress)),
    );
  }
  return BorderRadius.only(
    topLeft: Radius.circular(16),
    topRight: Radius.circular(16),
    bottomLeft: Radius.circular(0),
    bottomRight: Radius.circular(0),
  );
}
```

### 6.2 Sequential Animation with Callbacks

```dart
void expand() {
  setState(() => _state = MidiPlayerAnimationState.flying_to_player);
  
  // Phase 1: Fly
  _expandController.forward().then((_) {
    setState(() => _state = MidiPlayerAnimationState.expanding_player);
    
    // Phase 2: Morph
    _morphController.forward().then((_) {
      setState(() => _state = MidiPlayerAnimationState.expanded_player);
    });
  });
}

void collapse() {
  setState(() => _state = MidiPlayerAnimationState.collapsing_player);
  
  // Phase 1: Collapse
  _morphController.reverse().then((_) {
    setState(() => _state = MidiPlayerAnimationState.flying_to_sidebar);
    
    // Phase 2: Fly
    _expandController.reverse().then((_) {
      setState(() => _state = MidiPlayerAnimationState.sidebar_circle);
    });
  });
}
```

### 6.3 Position-Based Snap Detection

```dart
void _onPanEnd(DragEndDetails details) {
  final centerX = _sidebarX * screenWidth + (kMidiSidebarButtonSize / 2);
  final snapX = centerX < (screenWidth / 2) ? 0.0 : 1.0;
  
  setState(() {
    _targetSnapX = snapX;
    _state = MidiPlayerAnimationState.flying_sidebar;
  });
  
  _animateToSidebarPosition();
}
```

---

## 7. Testing Requirements

### 7.1 Animation Tests

- Expand animation completes in ~300ms
- Collapse animation completes in ~300ms
- Circle stays visible during animation
- No visual glitches during morph

### 7.2 Snap Zone Tests

- Circle snaps to left when released on left half
- Circle snaps to right when released on right half
- Smooth animation to snap position

### 7.3 Drag Tests

- Circle can be dragged to any Y position (0 to 75% screen height)
- Circle stays fully visible (X clamped)
- Position persists after drag ends

---

## 8. Files to Modify

1. `lib/presentations/song/widgets/draggable_midi_controls.dart`
   - Complete rewrite of animation system
   - Add state machine for animation phases
   - Implement floating header + controls layout
   - Add sequential animation controllers

2. `test/midi_controls_layout_test.dart`
   - Update tests for new layout structure
   - Add animation duration tests
   - Add snap zone tests

---

## 9. Acceptance Criteria

- [ ] Circle animates from sidebar to player position (150ms)
- [ ] Circle morphs into player shape (150ms)
- [ ] Header floats above controls
- [ ] Tap header to collapse
- [ ] Tap circle to expand
- [ ] Circle snaps left/right based on screen center
- [ ] Drag anywhere, release snaps to nearest edge
- [ ] Collapse reverses: morphs to circle, then flies to edge
- [ ] Smooth 60fps animations throughout
- [ ] Works on various screen sizes (320px - 1920px)
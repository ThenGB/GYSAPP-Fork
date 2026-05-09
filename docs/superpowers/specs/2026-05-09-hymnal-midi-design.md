# Hymnal MIDI Player and Preload Design

Date: 2026-05-09

## Goal

Fix the Hymnal MIDI experience first, then continue sequentially into full UI polish and codebase audit. This phase focuses on the concrete runtime issues reported by the user:

- MIDI caching and preloading are unreliable.
- The Hymnal mini player sits too high above the bottom navigation.
- The collapsed mini player state feels too wide/large.
- The Hymnal player must match the Stitch mock direction as closely as possible.

## Source Of Truth

Use the Stitch full-width MIDI player pattern as the source of truth for phase 1:

- Player is docked directly above the bottom navigation, not floating high in the content area.
- Expanded player has a maroon header, `Now Playing` label, cream/pink surface, subtle outline, and compact control rows.
- Collapsed player is a compact full-width mini-bar/header, not a large floating bubble.
- Bottom safe-area and bottom nav height are part of layout math so the player does not cover or detach from the navigation area.

## Current Evidence

Initial passive verification before implementation:

- `flutter test` passes: 28 tests.
- `flutter analyze` reports no issues.
- The remaining defects are likely runtime/layout/state issues rather than compilation failures.

Relevant files:

- `lib/data/services/midi_engine_service.dart`
- `lib/presentations/song/cubit/song_cubit.dart`
- `lib/presentations/song/cubit/song_playback_defaults.dart`
- `lib/presentations/song/cubit/song_playlist.dart`
- `lib/presentations/song/view/song_view.dart`
- `lib/presentations/song/widgets/draggable_midi_controls.dart`
- `lib/presentations/dashboard/view/dashboard_view.dart`
- Existing tests under `test/`

## Design

### 1. Docked Player Layout

Refactor `DraggableMidiControls` from a hard-coded floating `Positioned` offset into a component with explicit layout constants for bottom nav height, safe-area inset, and expanded/collapsed heights.

Expected behavior:

- Expanded player sits just above the bottom nav.
- Collapsed player sits in the same docked area as a compact mini-bar.
- Width is full-screen with Stitch-like horizontal padding.
- No state should push the player up by arbitrary extra offsets.
- Compact screens must avoid overflow.

### 2. Collapsed State

Replace the current circular collapsed trigger with a Stitch-style compact mini-bar:

- Header height around 44-48dp.
- Maroon background.
- Music icon, `Now Playing`/song title, and expand chevron.
- Full-width but visually light; not a wide control body and not a large floating FAB.

This satisfies the selected Stitch direction while addressing the user's note that the collapsed button currently feels too wide/large.

### 3. MIDI Cache And Preload State

Keep the existing architecture but make preload/cache behavior deterministic:

- Use stable cache keys that include MIDI path and normalized render settings.
- Do not prune the currently playing source.
- Avoid duplicate inflight render jobs for the same cache key.
- Ensure stale preload jobs cannot overwrite current-song loading state.
- Keep preload failures non-fatal and logged.
- Make current-song load state independent from background preload count.

### 4. SongCubit Coordination

Clarify sequencing in `SongCubit`:

- Resolve per-song playback defaults before loading the current MIDI.
- Load current song with current-song priority.
- Preload nearby songs after current-song setup, without forcing UI loading state.
- Include enough state in preload job keys to avoid stale dedupe across transpose/tempo/soundfont/instrument/natural-chord settings.
- Ensure audio toggling, page changes, transpose, tempo, and soundfont changes consistently refresh current and nearby MIDI caches.

### 5. Tests And Verification

Add or update tests for:

- Collapsed MIDI layout on compact screen.
- Docked player not using the old high bottom offset.
- Preload queue/cache key behavior where feasible without native audio rendering.
- Existing playback defaults and playlist behavior remain intact.

Final verification for this phase:

- `flutter test`
- `flutter analyze`

## Out Of Scope For Phase 1

These remain for later sequential phases:

- Full page-by-page UI polish across every app screen.
- Broad codebase performance audit and dead-code removal.
- Non-Hymnal feature consistency unless required to fix the shared MIDI player behavior.

## Risks

- Real MIDI rendering uses native audio/soundfont code, so unit tests may only cover orchestration and pure logic. Manual runtime verification may still be needed after implementation.
- The working tree already contains many modified files. Implementation must avoid reverting unrelated user changes.
- The dashboard has a separate global mini player; shared visual constants may need careful extraction to avoid drift without introducing a broad refactor.

## Approval

The user approved the phase 1 direction on 2026-05-09: use the Stitch full-width player direction, then continue sequentially with full UI polish and audit after this phase.

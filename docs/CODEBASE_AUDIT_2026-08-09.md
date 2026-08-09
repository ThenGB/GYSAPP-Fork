# GYSAPP-Fork Codebase Audit — 2026-08-09

## Executive summary

The codebase already contains deliberate optimizations in several performance-sensitive areas, including Bible split-scroll throttling, targeted MIDI rebuilds, lazy Bible database initialization, PDF streaming, asset-manifest access, memoized song filtering, and background initial-state preparation. This modernization therefore avoids a risky blanket rewrite and focuses on the highest-value problems found during audit.

The main issues addressed in this branch are application bootstrap cost, unwanted runtime instrumentation, redundant network work, persistence I/O, release logging, theme inconsistency, dashboard composition, hymn-selector UX, narrow-screen resilience, and test reproducibility.

No finite audit can prove that a cross-platform application is literally bug-free. The practical quality target used here is: remove known defects, make failure modes explicit, add regression coverage, and keep `flutter analyze` plus the automated suite as merge gates.

## Fixed in this branch

### Marionette removed completely

`marionette_flutter` was a direct runtime dependency and Marionette binding initialization existed in both `main.dart` and `app.dart`. The package, imports, initialization calls, and lockfile entry are removed. A regression test now rejects Marionette references in app bootstrap and dependency files.

### Startup and dependency graph

- Required DI initialization no longer fails silently and then surfaces as an unrelated feature error later.
- `SongCubit` is lazy, matching the existing lazy Bible strategy, so Song/MIDI dependencies are not constructed before first use.
- Independent desktop path-provider calls are resolved concurrently.
- Existing `InitialCubit` background-first-load behavior is intentionally retained rather than replaced.
- The Android migration marker is corrected to the app's 2.1 migration boundary.

### Translation/network loading

The translation refresh no longer performs a connectivity-plugin check and Google DNS lookup before making the HTTP request that already has timeout/error handling. The refresh stays fire-and-forget so it cannot block the first usable frame. `connectivity_plus` is no longer a direct dependency for this path.

### Persistence and logging

Native HydratedBloc storage no longer logs every state read/write in release builds and no longer forces `flush: true` for every reconstructible state mutation. Authentication/profile diagnostics were also sanitized and restricted so credentials or profile payloads are not written to release logs.

### Build reproducibility

The manifest no longer references a local font directory that is ignored by Git. The committed dependency lockfile has been regenerated with Flutter and no longer contains Marionette. Tests that previously depended on a developer-only `Original Alkitab DB/b_kjv.db` now generate a minimal SQLite fixture during the test, so installed-Bible repository/FFI behavior is exercised on clean CI checkouts.

The real-PDF extraction smoke test remains active where the native PDFium runtime exists. It is skipped specifically on Linux CI images that do not provide the PDFium native library required by `pdfrx`; parser/unit/contract PDF coverage still runs there.

## UI / UX modernization

### Hymn selector

The selector now has two explicit browse modes:

- **Daftar** for dense scanning;
- **Kotak** for a more visual responsive card view.

Both preserve debounced/memoized search, number/title/lyric matching, book switching, last-opened resume behavior, playlist actions, lazy builders, keyboard dismissal, and `RepaintBoundary` around repeated cells.

### Dashboard and visual language

Home/dashboard hierarchy, responsive surfaces, cards, and section presentation were refreshed while retaining the existing functional content. Rebuild boundaries were narrowed with `buildWhen` where only specific Home state changes should redraw a section.

Light and dark themes now share the same primary typography hierarchy and component geometry instead of changing visual density when the theme changes.

### Bible audio compact layout

The floating Bible audio panel now adapts its range controls on narrow viewports. At compact widths, Book, Chapter, and Verse controls stack rather than forcing three labeled dropdowns into a row that can overflow.

## Existing optimizations reviewed and intentionally retained

The audit explicitly keeps these patterns:

- background initial-state preparation after the UI is usable;
- lazy desktop Bible SQLite initialization;
- throttled Bible split-scroll visibility updates;
- `ValueNotifier`/stream isolation for high-frequency MIDI position updates;
- MIDI drag/snap animation without broad parent rebuilds;
- native `pdfrx` PDF rendering rather than base64/WebView handoff;
- Flutter asset-manifest discovery;
- memoized/debounced song filtering;
- existing source-hygiene regression contracts.

## CI and regression strategy

`.github/workflows/flutter_quality.yml` runs dependency resolution, `flutter analyze`, and `flutter test` for `main`, `agent/**`, and pull requests. Push and pull-request events from the same branch share a concurrency group, so stale duplicate runs are cancelled instead of consuming two runners in parallel.

Modernization-specific coverage checks that Marionette stays removed, translation loading does not regain the connectivity/DNS preflight, the hymn selector keeps both list/grid modes, Home keeps narrowed rebuild boundaries, authentication diagnostics stay redacted/debug-only, and light/dark primary typography remains aligned.

## Remaining follow-up candidates

- Replace file-wide `use_build_context_synchronously` suppressions feature-by-feature with explicit liveness checks and widget regression tests.
- Centralize the remaining Android package-private path assumptions behind the app-directory abstraction.
- Incrementally migrate remaining feature-specific headers/cards onto shared primitives where doing so does not remove responsive behavior.
- Prune additional dependencies only when source-reference checks plus Android/Windows/web builds prove them unused.
- Add platform build gates separately from the current Linux analyzer/unit/widget quality gate.

## Manual validation checklist before merge

Validate at least one narrow phone and one desktop/tablet viewport: cold launch; dark/light switching; Dashboard; Pujian selector Daftar/Kotak; search by number/title/lyric; book switching; opening songs; playlist create/add/remove/activate; Bible single/split reading; Bible audio collapsed/expanded controls; PDF hymn open/fit/two-page behavior; MIDI play/pause/seek/expand; and settings persistence across restart.

## Definition of clean

For this repository, a responsible merge target is: analyzer clean; automated tests green except documented environment-specific skips; source-hygiene invariants green; no unwanted runtime instrumentation; no credential-bearing release logs; no broad high-frequency rebuild/log/I/O regressions; startup-critical work minimized; and feature refactors protected by regression tests.

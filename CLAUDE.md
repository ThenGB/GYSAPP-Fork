# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **GYS Church App** - a Flutter application for church worship management. It provides:
- Song book with PDF lyrics display
- MIDI audio playback with chord overlays
- Bible reading with search
- Literature/warta management
- Firebase-backed data sync

Version: 2.0.30+132 | Flutter: ^3.24.0 | Dart: >=3.8.0 <4.0.0

## Common Commands

```bash
# Run the app
flutter run -d chrome                    # Web
flutter run -d windows                  # Windows
flutter run -d android                  # Android

# Build
flutter build web                        # Web build
flutter build apk --debug               # Android debug
flutter build apk --release             # Android release

# Analysis & Code Generation
flutter analyze                         # Run analyzer
flutter pub run build_runner build       # Generate freezed/g.dart files
flutter pub run build_runner build --watch  # Watch mode

# Web debugging
flutter run -d chrome --web-renderer canvaskit --dart-define=FLUTTER_WEB_ENABLE_DEBUG=true
```

## Architecture

### Directory Structure

```
lib/
├── main.dart              # Entry point with MarionetteBinding for screenshots
├── app.dart               # App widget with Firebase/notification init
├── components/            # Reusable UI components and themes
├── data/                  # Data layer
│   ├── repository/        # Repository implementations
│   ├── services/          # Services (MIDI, PDF, assets)
│   └── utilities/         # Helpers, extensions, constants
├── di/                    # Dependency injection (get_it)
├── domain/                # Domain layer
│   ├── entity/            # Business entities (freezed)
│   └── repository/        # Repository interfaces
├── presentations/         # UI layer (BLoC pattern)
│   ├── auth/
│   ├── backup/
│   ├── bible/
│   ├── dashboard/
│   ├── faith/
│   ├── literature/
│   ├── report/
│   ├── settings/
│   └── song/              # Main song viewer with PDF/chord overlay
└── router/                # Auto-route navigation
```

### State Management

Uses **HydratedCubit** (hydrated_bloc) for persistent state:
- `SongCubit` - Main song state, MIDI/PDF loading, playback
- `InitialCubit` - App configuration and theme
- Other cubits for specific features

### Key Services

| Service | File | Purpose |
|---------|------|---------|
| MidiEngineService | `lib/data/services/midi_engine_service.dart` | MIDI playback via flutter_soloud |
| PdfChunkService | `lib/data/services/pdf_chunk_service.dart` | PDF extraction from compressed assets |
| LocalAssetService | `lib/data/services/local_asset_service.dart` | PDF/MIDI/chord path resolution |
| PdfNoteService | `lib/data/services/pdf_note_service.dart` | Note extraction from PDF text layer |
| ChordService | `lib/data/services/chord_service.dart` | Chord parsing and transposition |

### Platform-Specific Code

- **Windows**: Pdfium DLL path configuration in `_initializePdfRuntime()`
- **Web**: MarionetteBinding for screenshots, canvaskit renderer preferred
- **Android/iOS**: Firebase integration, native notifications

## Known Issues & Fixes Required

### 1. SoLoud Buffer Stream Seek Exception

`SoLoudBufferStreamWithReleasedBufferTypeCannotBeSeekedCppException` occurs when seeking on buffer streams with `BufferingType.released`. The streaming controller uses this buffer type but attempting seek operations causes C++ exceptions.

**Location**: `midi_engine_service.dart` lines 469-476, 853-868

**Fix approach**: When seeking on a buffer stream, need to either:
- Use a different buffering type
- Stop and re-create the stream from seek point
- Fall back to pre-rendered source when available

### 2. Seek Logic Inconsistency

The `seek()` method sometimes doesn't seek properly, especially on streaming sources. The position state isn't reliably updated.

**Location**: `midi_engine_service.dart` lines 830-868

**Fix approach**:
- Add explicit state reset before seek
- Ensure _currentSourceStartOffsetSeconds is properly tracked
- Add seek confirmation via position verification

### 3. Song Navigation Time Not Resetting

When navigating to next/previous song, the playback position doesn't start at 0. The position timer and state retain the previous song's position.

**Location**: `midi_engine_service.dart` stop() and loadMidi() methods, `song_cubit.dart` changePage/goToNextSong/goToPreviousSong

**Fix approach**:
- Force position reset to 0 when song changes
- Reset timer state explicitly on song transition
- Ensure startAt parameter is properly passed

### 4. PDF Loading Inconsistency

PDF viewer sometimes fails to load, especially during rapid song navigation. The _isTransitioning flag may not be properly synced.

**Location**: `song_pdf_viewer.dart` lines 94-96, 162-186

**Fix approach**:
- Add generation-based invalidation
- Clear _pdfRequest more aggressively on path change
- Add retry mechanism for failed loads

### 5. Web Compatibility Issues

- MarionetteBinding initialization conflicts with certain web configurations
- SQLite (sqflite) not available on web - uses sqlite3_flutter_libs with FFI
- Some services need web-specific fallbacks

**Location**: `main.dart`, `app.dart`, various service files

**Fix approach**:
- Add kIsWeb checks for platform-specific initialization
- Ensure pdfium paths only set on native platforms
- Review SoLoud initialization for web compatibility

### 6. Chord Viewer Performance

Chord badge rendering is slow on some pages due to FutureBuilder and note extraction overhead.

**Location**: `song_pdf_viewer.dart` _ChordOverlay widget

**Fix approach**:
- Cache extraction results per page
- Use const widgets where possible
- Debounce chord overlay rebuilds

## Asset Structure

```
assets/
├── data/
│   ├── pdf/          # Song lyrics PDFs (chunked)
│   ├── midi/         # MIDI accompaniment files
│   ├── chord/        # Chord JSON files per song
│   ├── bible/        # Bible data
│   └── soundfont/    # SoundFont files (.sf2)
├── translations/     # i18n JSON files
└── images/           # Static images
```

## Dependencies

Key packages (check `pubspec.yaml` for versions):
- `flutter_bloc` / `hydrated_bloc` - State management
- `flutter_soloud` - Audio playback
- `dart_melty_soundfont` - MIDI synthesis (local: `third_party/dart_melty_soundfont`)
- `pdfrx` - PDF rendering
- `auto_route` - Navigation
- `firebase_*` - Firebase integration
- `sqflite` / `sqlite3_flutter_libs` - Database
- `marionette_flutter` - Screenshot support in debug

## Testing

```bash
flutter test                              # Run all tests
flutter test test/widget_test.dart       # Run specific test
```
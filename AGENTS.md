# AGENTS.md

This file provides guidance to opencode agents when working with code in this repository.

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

# Testing
flutter test                              # Run all tests
flutter test test/widget_test.dart       # Run specific test

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

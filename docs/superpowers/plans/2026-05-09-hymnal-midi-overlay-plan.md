# Hymnal MIDI Overlay Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the Hymnal MIDI overlay, collapsed mini-player, and preload/cache orchestration without shifting core Hymnal content.

**Architecture:** Keep the existing `SongCubit` + `MidiEngineService` architecture. Make the player a bottom-docked overlay inside the Hymnal `Stack`, add a small pure preload-key helper for deterministic dedupe, and remove page-change rerender races by passing reset settings directly into `loadMidi` instead of calling async rerender setters first.

**Tech Stack:** Flutter, Dart, flutter_test, hydrated_bloc, dartz, flutter_soloud-backed MIDI service.

---

## File Structure

- Modify: `lib/presentations/song/widgets/draggable_midi_controls.dart`
  - Owns the Hymnal MIDI overlay visuals and docked positioning.
  - Exposes small layout constants for tests.
- Modify: `lib/presentations/song/cubit/song_cubit.dart`
  - Owns playback orchestration, page-change sequencing, and preload scheduling.
- Create: `lib/presentations/song/cubit/song_preload_key.dart`
  - Pure helper for deterministic preload job keys.
- Modify: `test/midi_controls_layout_test.dart`
  - Widget tests for expanded and collapsed overlay layout.
- Create: `test/song_cubit_midi_preload_test.dart`
  - Unit test with fake repository, asset service, and MIDI engine to prove page changes do not rerender the old source before loading the new song.
- Create: `test/song_preload_key_test.dart`
  - Pure tests for preload job key differences across render settings.

---

### Task 1: RED Widget Tests For Docked Overlay

**Files:**
- Modify: `test/midi_controls_layout_test.dart`
- Modify later: `lib/presentations/song/widgets/draggable_midi_controls.dart`

- [ ] **Step 1: Add failing tests for docked expanded and collapsed layout**

Append these tests to `test/midi_controls_layout_test.dart` after the existing compact-screen test:

```dart
testWidgets('midi controls are docked to the bottom as an overlay', (
  tester,
) async {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Colors.white)),
            DraggableMidiControls(
              isPlaying: false,
              isLoading: false,
              position: 0,
              duration: 180,
              transposeStep: 0,
              currentKey: 'C',
              availableKeys: const ['C', 'D', 'E'],
              tempoBpm: 76,
              onPlayPause: () {},
              onStop: () {},
              onSeek: (_) {},
              onTranspose: (_) {},
              onKeySelected: (_) {},
              onTempo: (_) {},
              onInstrument: (_) {},
              onSoundFont: (_) {},
            ),
          ],
        ),
      ),
    ),
  );

  final panelRect = tester.getRect(find.byKey(const ValueKey('midi-expanded')));
  expect(panelRect.bottom, closeTo(640, 0.1));
});

testWidgets('midi controls collapse to a compact Stitch mini bar', (
  tester,
) async {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            DraggableMidiControls(
              isPlaying: false,
              isLoading: false,
              position: 0,
              duration: 180,
              transposeStep: 0,
              nowPlayingTitle: 'Besar Setia-Mu',
              tempoBpm: 76,
              onPlayPause: () {},
              onStop: () {},
              onSeek: (_) {},
              onTranspose: (_) {},
              onKeySelected: (_) {},
              onTempo: (_) {},
              onInstrument: (_) {},
              onSoundFont: (_) {},
            ),
          ],
        ),
      ),
    ),
  );

  await tester.tap(find.byKey(const ValueKey('midi-collapse-toggle')));
  await tester.pumpAndSettle();

  final collapsed = find.byKey(const ValueKey('midi-collapsed'));
  final collapsedRect = tester.getRect(collapsed);
  expect(collapsedRect.bottom, closeTo(640, 0.1));
  expect(collapsedRect.height, lessThanOrEqualTo(52));
  expect(find.textContaining('Besar Setia-Mu'), findsOneWidget);
  expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
});
```

- [ ] **Step 2: Run the focused widget test and verify RED**

Run:

```bash
flutter test test/midi_controls_layout_test.dart
```

Expected: fails because `midi-collapse-toggle` does not exist yet and the expanded panel bottom is still around `508` instead of `640` due to the old `132` bottom offset.

---

### Task 2: GREEN Docked Overlay Player

**Files:**
- Modify: `lib/presentations/song/widgets/draggable_midi_controls.dart`
- Test: `test/midi_controls_layout_test.dart`

- [ ] **Step 1: Replace hard-coded high offsets with docked overlay constants**

In `lib/presentations/song/widgets/draggable_midi_controls.dart`, add these constants near the top of the file:

```dart
const double kMidiOverlayHorizontalMargin = 16;
const double kMidiOverlayBottomOffset = 0;
const double kMidiCollapsedBarHeight = 48;
```

Then update `build` so the `Positioned` uses the docked overlay offset and no bottom safe-area uplift:

```dart
return Positioned(
  left: kMidiOverlayHorizontalMargin,
  right: kMidiOverlayHorizontalMargin,
  bottom: kMidiOverlayBottomOffset,
  child: AnimatedSwitcher(
    duration: const Duration(milliseconds: 220),
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    transitionBuilder: (child, animation) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
          child: child,
        ),
      );
    },
    child: _expanded
        ? _buildExpandedPanel(context, colors)
        : _buildCollapsedTrigger(context, colors),
  ),
);
```

- [ ] **Step 2: Replace collapsed circular button with Stitch mini bar**

Replace `_buildCollapsedTrigger` with:

```dart
Widget _buildCollapsedTrigger(BuildContext context, ColorScheme colors) {
  final title = widget.nowPlayingTitle.trim();
  return Material(
    key: const ValueKey('midi-collapsed'),
    color: colors.primary,
    borderRadius: BorderRadius.circular(16),
    clipBehavior: Clip.antiAlias,
    elevation: 2,
    shadowColor: colors.primary.withValues(alpha: 0.18),
    child: InkWell(
      onTap: () => setState(() => _expanded = true),
      child: SizedBox(
        height: kMidiCollapsedBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(Icons.music_note_rounded, size: 17, color: colors.onPrimary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title.isEmpty ? 'Now Playing' : 'Now Playing: $title',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_up_rounded,
                color: colors.onPrimary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
```

- [ ] **Step 3: Add the collapse-toggle key to the expanded header**

In `_buildExpandedPanel`, add `key: const ValueKey('midi-collapse-toggle')` to the `InkWell` that collapses the player:

```dart
InkWell(
  key: const ValueKey('midi-collapse-toggle'),
  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
  onTap: () => setState(() => _expanded = false),
  child: Container(
    // existing header content
  ),
),
```

- [ ] **Step 4: Run focused tests and verify GREEN**

Run:

```bash
flutter test test/midi_controls_layout_test.dart
```

Expected: all tests in `midi_controls_layout_test.dart` pass.

- [ ] **Step 5: Commit Task 1-2**

```bash
git add test/midi_controls_layout_test.dart lib/presentations/song/widgets/draggable_midi_controls.dart
git commit -m "fix: dock hymnal midi overlay"
```

---

### Task 3: RED Tests For Preload Key And Page-Change Sequencing

**Files:**
- Create: `test/song_preload_key_test.dart`
- Create: `test/song_cubit_midi_preload_test.dart`
- Create later: `lib/presentations/song/cubit/song_preload_key.dart`
- Modify later: `lib/presentations/song/cubit/song_cubit.dart`

- [ ] **Step 1: Add failing pure preload-key test**

Create `test/song_preload_key_test.dart`:

```dart
import 'package:church/presentations/song/cubit/song_playback_defaults.dart';
import 'package:church/presentations/song/cubit/song_preload_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preload job key changes with render-affecting settings', () {
    const base = SongPlaybackDefaults(
      transposeStep: 0,
      tempoBpm: 76,
      defaultTempoBpm: 76,
    );

    final original = songPreloadJobKey(
      midiPath: 'assets/data/midi/kr/001.mid',
      defaults: base,
      soundFont: 'assets/data/soundfont/GeneralUser-GS.sf2',
    );
    final transposed = songPreloadJobKey(
      midiPath: 'assets/data/midi/kr/001.mid',
      defaults: base.copyWith(transposeStep: 1),
      soundFont: 'assets/data/soundfont/GeneralUser-GS.sf2',
    );
    final instrument = songPreloadJobKey(
      midiPath: 'assets/data/midi/kr/001.mid',
      defaults: base,
      soundFont: 'assets/data/soundfont/GeneralUser-GS.sf2',
      instrument: 19,
    );
    final soundFont = songPreloadJobKey(
      midiPath: 'assets/data/midi/kr/001.mid',
      defaults: base,
      soundFont: 'TimGM6mb.sf2',
    );

    expect(original, isNot(transposed));
    expect(original, isNot(instrument));
    expect(original, isNot(soundFont));
    expect(original, contains('GeneralUser-GS.sf2'));
    expect(original, isNot(contains('assets/data/soundfont')));
  });
}
```

- [ ] **Step 2: Add failing SongCubit sequencing test**

Create `test/song_cubit_midi_preload_test.dart`:

```dart
import 'package:church/data/services/local_asset_service.dart';
import 'package:church/data/services/midi_engine_service.dart';
import 'package:church/domain/entity/song/song_entity.dart';
import 'package:church/domain/repository/song_repository.dart';
import 'package:church/presentations/song/cubit/song_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  late _MemoryStorage storage;

  setUp(() {
    storage = _MemoryStorage();
    HydratedBloc.storage = storage;
  });

  test('page change loads the new midi without pre-rerendering old source', () async {
    final engine = _FakeMidiEngine();
    final cubit = SongCubit(_FakeSongRepository(), _FakeAssetService(), engine);
    await _flushAsync();
    engine.events.clear();

    await cubit.changePage(1, 0);

    expect(
      engine.events,
      contains('load:assets/data/midi/kr/002.mid:t0:tempo76.0:base76.0'),
    );
    expect(engine.events, isNot(contains('setTranspose:0')));
    expect(engine.events, isNot(contains('setTempoBase:76.0')));

    await cubit.close();
  });
}

Future<void> _flushAsync() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _MemoryStorage implements Storage {
  final Map<String, dynamic> _values = {};

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<void> close() async {}

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  dynamic read(String key) => _values[key];

  @override
  Future<void> write(String key, dynamic value) async {
    _values[key] = value;
  }
}

class _FakeSongRepository implements SongRepository {
  @override
  Future<Either<dynamic, List<SongBook>>> getData() async {
    return right(const [
      SongBook(
        code: 'KR',
        songs: [
          Song(code: 'KR', number: '001', title: 'One'),
          Song(code: 'KR', number: '002', title: 'Two'),
        ],
      ),
    ]);
  }
}

class _FakeAssetService extends LocalAssetService {
  @override
  Future<String?> getMidiPath(String bookCode, String number) async {
    return 'assets/data/midi/${bookCode.toLowerCase()}/$number.mid';
  }

  @override
  Future<String?> getChordPath(String bookCode, String number) async => null;
}

class _FakeMidiEngine extends MidiEngineService {
  final List<String> events = [];

  _FakeMidiEngine() : super(LocalAssetService(), cacheDir: 'unused');

  @override
  Future<void> initialize() async {
    events.add('initialize');
  }

  @override
  Future<void> changeSoundFont(String soundFontFileName) async {
    events.add('soundfont:$soundFontFileName');
  }

  @override
  void setCacheMax(int max) {
    events.add('cache:$max');
  }

  @override
  Future<void> loadMidi(
    String midiPath, {
    int transpose = 0,
    double tempoBpm = 76,
    double? baseTempoBpm,
    int? instrument,
    bool autoplay = false,
  }) async {
    events.add(
      'load:$midiPath:t$transpose:tempo$tempoBpm:base${baseTempoBpm ?? 76}',
    );
  }

  @override
  Future<void> preload(
    String midiPath, {
    int transpose = 0,
    double? tempoBpm,
    double? baseTempoBpm,
    int? instrument,
    String? soundFont,
  }) async {
    events.add('preload:$midiPath:t$transpose:sf$soundFont');
  }

  @override
  Future<void> setTranspose(int semitones) async {
    events.add('setTranspose:$semitones');
  }

  @override
  Future<void> setTempoBase(double bpm) async {
    events.add('setTempoBase:$bpm');
  }

  @override
  Future<void> disposeEngine() async {
    events.add('dispose');
  }
}
```

- [ ] **Step 3: Run focused tests and verify RED**

Run:

```bash
flutter test test/song_preload_key_test.dart test/song_cubit_midi_preload_test.dart
```

Expected: `song_preload_key_test.dart` fails because `song_preload_key.dart` does not exist. `song_cubit_midi_preload_test.dart` fails because `changePage` currently calls `setTranspose:0` and `setTempoBase:76.0` before loading.

---

### Task 4: GREEN Deterministic Preload And No Old-Source Rerender

**Files:**
- Create: `lib/presentations/song/cubit/song_preload_key.dart`
- Modify: `lib/presentations/song/cubit/song_cubit.dart`
- Test: `test/song_preload_key_test.dart`
- Test: `test/song_cubit_midi_preload_test.dart`

- [ ] **Step 1: Create the pure preload-key helper**

Create `lib/presentations/song/cubit/song_preload_key.dart`:

```dart
import 'song_playback_defaults.dart';

String songPreloadJobKey({
  required String midiPath,
  required SongPlaybackDefaults defaults,
  required String soundFont,
  int? instrument,
}) {
  final normalizedSoundFont = soundFont
      .split(RegExp(r'[\\/]'))
      .where((part) => part.isNotEmpty)
      .last;
  return [
    midiPath,
    normalizedSoundFont,
    defaults.transposeStep,
    defaults.tempoBpm.round(),
    defaults.defaultTempoBpm.round(),
    instrument ?? -1,
    defaults.originalFamilyChord ?? '-',
    defaults.originalPdfKey ?? '-',
    defaults.baseTransposeOffset,
  ].join('|');
}
```

- [ ] **Step 2: Import helper in SongCubit**

Add this import in `lib/presentations/song/cubit/song_cubit.dart`:

```dart
import 'song_preload_key.dart';
```

- [ ] **Step 3: Rework preload dedupe to use resolved render settings**

Replace `_preloadNearbySongMidi`, `_preloadJobKey`, and `_preloadSong` with:

```dart
void _preloadNearbySongMidi(int index) {
  if (!state.preloadEnabled) return;
  final queue = _playbackQueue();
  for (final song in queue.getPreloadSongs(state.preloadCount)) {
    unawaited(_preloadSong(song));
  }
}

Future<void> _preloadSong(Song song) async {
  final midiPath = await _midiPathForSong(song);
  if (midiPath == null) return;
  final preset = await _resolveCacheDefaultsForSong(song);
  final jobKey = songPreloadJobKey(
    midiPath: midiPath,
    defaults: preset,
    soundFont: state.soundFont,
    instrument: state.midiInstrument,
  );
  if (!_activePreloadJobs.add(jobKey)) return;
  try {
    await _midiEngine.preload(
      midiPath,
      transpose: preset.transposeStep,
      tempoBpm: preset.tempoBpm,
      baseTempoBpm: preset.defaultTempoBpm,
      instrument: state.midiInstrument,
      soundFont: state.soundFont,
    );
  } finally {
    _activePreloadJobs.remove(jobKey);
  }
}
```

Delete the old `_preloadJobKey(Song song)` method.

- [ ] **Step 4: Stop page-change pre-rerendering of the old current source**

In `_preloadCurrentSongMidi`, remove these two lines:

```dart
_midiEngine.setTranspose(defaults.transposeStep);
_midiEngine.setTempoBase(defaults.defaultTempoBpm);
```

Then load the current MIDI before nearby preload:

```dart
await _loadMidiForSong(song, force: true);
_preloadNearbySongMidi(state.pageIndex);
```

In `changePage`, remove these two lines:

```dart
_midiEngine.setTranspose(reset.transposeStep);
_midiEngine.setTempoBase(reset.defaultTempoBpm);
```

Keep `_loadMidiForSong(song, autoplay: wasPlaying, force: true)` because it already passes `transpose`, `tempoBpm`, `baseTempoBpm`, and `instrument` directly into `MidiEngineService.loadMidi`.

- [ ] **Step 5: Mark unawaited toggleAudio load explicitly**

In `toggleAudio`, change:

```dart
_loadMidiForSong(state.songs[state.pageIndex]);
```

to:

```dart
unawaited(_loadMidiForSong(state.songs[state.pageIndex]));
```

- [ ] **Step 6: Run focused tests and verify GREEN**

Run:

```bash
flutter test test/song_preload_key_test.dart test/song_cubit_midi_preload_test.dart
```

Expected: both tests pass.

- [ ] **Step 7: Commit Task 3-4**

```bash
git add lib/presentations/song/cubit/song_preload_key.dart lib/presentations/song/cubit/song_cubit.dart test/song_preload_key_test.dart test/song_cubit_midi_preload_test.dart
git commit -m "fix: stabilize hymnal midi preload sequencing"
```

---

### Task 5: Full Verification And Cleanup

**Files:**
- Review all touched files.

- [ ] **Step 1: Run full test suite**

Run:

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 2: Run analyzer**

Run:

```bash
flutter analyze
```

Expected: no issues found.

- [ ] **Step 3: Inspect git diff**

Run:

```bash
git status --short
git diff --stat
```

Expected: only planned files changed, plus pre-existing unrelated worktree changes still present.

- [ ] **Step 4: Final phase commit if needed**

If verification-only cleanup changed files, commit them:

```bash
git add <changed planned files>
git commit -m "test: verify hymnal midi overlay behavior"
```

---

## Self-Review

- Spec coverage: the plan covers overlay layout, collapsed mini-bar, preload dedupe, page-change loading sequence, and verification.
- Placeholder scan: no TBD/TODO/fill-later steps are present.
- Type consistency: `SongPlaybackDefaults`, `SongCubit`, `MidiEngineService`, and test helper names match the current codebase.
- Scope check: full UI polish and broad audit remain out of scope for this phase and should follow after this phase is verified.

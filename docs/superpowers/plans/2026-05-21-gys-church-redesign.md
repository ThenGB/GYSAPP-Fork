# GYS Church App — Pastel UI Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete UI redesign with soft pastel Sky Blue & Cloud White theme, fully customizable theme settings, removal of all extra padding and unnecessary containers.

**Architecture:** This is a 4-phase implementation:
1. Core Theme System (color schemes, PastelPreset model)
2. Component Refinements (cards, nav bar, app bar, lists)
3. Screen Polish (Dashboard, Home, Song List, Bible, other screens)
4. Theme Settings Rework (full customization UI with live preview)

**Tech Stack:** Flutter 3.24+, Dart 3.8+, Material Design 3, HydratedBloc, Freezed

---

## File Structure Overview

### Files to Create:
- `lib/domain/entity/pastel_preset/pastel_preset.dart` — Pastel preset model
- `lib/data/models/theme_preferences.dart` — Theme preferences model
- `lib/data/repositories/theme_preferences_repository.dart` — Theme persistence

### Files to Modify:
- `lib/components/themes/app_accent.dart` — Add pastel presets, update seed colors
- `lib/components/themes/default_theme.dart` — Update spacing, radius, component styles
- `lib/components/themes/dark_theme.dart` — Update dark mode with pastel tones
- `lib/components/design_system/design_system.dart` — Update constants
- `lib/presentations/dashboard/view/dashboard_view.dart` — Clean up padding
- `lib/presentations/home/view/home_view.dart` — Hero, sections, cards
- `lib/presentations/song/view/song_list_view.dart` — Search, list items
- `lib/presentations/bible/view/bible_list_view.dart` — Clean up lists
- `lib/presentations/settings/view/settings_view.dart` — Full rework

---

## Phase 1: Core Theme System

### Task 1: Create PastelPreset Entity Model

**Files:**
- Create: `lib/domain/entity/pastel_preset/pastel_preset.dart`
- Create: `lib/domain/entity/pastel_preset/pastel_preset.freezed.dart`
- Create: `lib/domain/entity/pastel_preset/pastel_preset.g.dart`
- Test: `test/domain/entity/pastel_preset_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/domain/entity/pastel_preset_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gys_church/domain/entity/pastel_preset/pastel_preset.dart';

void main() {
  group('PastelPreset', () {
    test('skyBlue preset has correct values', () {
      final preset = pastelPresets.firstWhere((p) => p.key == 'skyBlue');
      expect(preset.key, 'skyBlue');
      expect(preset.label, 'Sky Blue');
      expect(preset.primary, const Color(0xFF93C5FD));
      expect(preset.container, const Color(0xFFDBEAFE));
      expect(preset.surface, const Color(0xFFF8FAFC));
    });

    test('mintGreen preset has correct values', () {
      final preset = pastelPresets.firstWhere((p) => p.key == 'mintGreen');
      expect(preset.key, 'mintGreen');
      expect(preset.label, 'Mint Green');
      expect(preset.primary, const Color(0xFF6EE7B7));
    });

    test('all presets have valid colors', () {
      for (final preset in pastelPresets) {
        expect(preset.primary.alpha, greaterThan(0));
        expect(preset.container.alpha, greaterThan(0));
        expect(preset.surface.alpha, greaterThan(0));
      }
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/domain/entity/pastel_preset_test.dart -v`
Expected: FAIL — PastelPreset not defined

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/domain/entity/pastel_preset/pastel_preset.dart
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pastel_preset.freezed.dart';
part 'pastel_preset.g.dart';

@freezed
class PastelPreset with _$PastelPreset {
  const factory PastelPreset({
    required String key,
    required String label,
    required Color primary,
    required Color container,
    required Color surface,
    @Default(false) bool isDark,
  }) = _PastelPreset;

  factory PastelPreset.fromJson(Map<String, dynamic> json) =>
      _$PastelPresetFromJson(json);
}

const pastelPresets = [
  PastelPreset(
    key: 'skyBlue',
    label: 'Sky Blue',
    primary: Color(0xFF93C5FD),
    container: Color(0xFFDBEAFE),
    surface: Color(0xFFF8FAFC),
  ),
  PastelPreset(
    key: 'mintGreen',
    label: 'Mint Green',
    primary: Color(0xFF6EE7B7),
    container: Color(0xFFD1FAF5),
    surface: Color(0xFFF0FDF4),
  ),
  PastelPreset(
    key: 'softLavender',
    label: 'Soft Lavender',
    primary: Color(0xFFC4B5FD),
    container: Color(0xFFF3E8FF),
    surface: Color(0xFFFAF5FF),
  ),
  PastelPreset(
    key: 'warmPeach',
    label: 'Warm Peach',
    primary: Color(0xFFFED7AA),
    container: Color(0xFFFFEDD5),
    surface: Color(0xFFFFFBF5),
  ),
  PastelPreset(
    key: 'dustyRose',
    label: 'Dusty Rose',
    primary: Color(0xFFFECDD3),
    container: Color(0xFFFFE4E6),
    surface: Color(0xFFFFF1F2),
  ),
  PastelPreset(
    key: 'softTeal',
    label: 'Soft Teal',
    primary: Color(0xFF5EEAD4),
    container: Color(0xFFCCFBF1),
    surface: Color(0xFFF0FDFA),
  ),
  PastelPreset(
    key: 'softIndigo',
    label: 'Soft Indigo',
    primary: Color(0xFFA5B4FC),
    container: Color(0xFFE0E7FF),
    surface: Color(0xFFEEF2FF),
  ),
  PastelPreset(
    key: 'softAmber',
    label: 'Soft Amber',
    primary: Color(0xFFFCD34D),
    container: Color(0xFFFEF3C7),
    surface: Color(0xFFFFFBEB),
  ),
  PastelPreset(
    key: 'softCyan',
    label: 'Soft Cyan',
    primary: Color(0xFF67E8F9),
    container: Color(0xFFCFFAFE),
    surface: Color(0xFFECFEFF),
  ),
  PastelPreset(
    key: 'softViolet',
    label: 'Soft Violet',
    primary: Color(0xFFA78BFA),
    container: Color(0xFFEDE9FE),
    surface: Color(0xFFF5F3FF),
  ),
  PastelPreset(
    key: 'softPink',
    label: 'Soft Pink',
    primary: Color(0xFFF9A8D4),
    container: Color(0xFFFCE7F3),
    surface: Color(0xFFFDF2F8),
  ),
  PastelPreset(
    key: 'softGray',
    label: 'Soft Gray',
    primary: Color(0xFF9CA3AF),
    container: Color(0xFFF3F4F6),
    surface: Color(0xFFFAFAFA),
  ),
];
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter pub run build_runner build`
Run: `flutter test test/domain/entity/pastel_preset_test.dart -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/domain/entity/pastel_preset/ test/domain/entity/pastel_preset_test.dart
git commit -m "feat: add PastelPreset entity model with 12 pastel color options"
```

---

### Task 2: Update app_accent.dart with new pastel seeds

**Files:**
- Modify: `lib/components/themes/app_accent.dart:1-156`

- [ ] **Step 1: Add new pastel accent options**

Replace the existing `appAccentOptions` array with updated pastel seeds:

```dart
// lib/components/themes/app_accent.dart — replace appAccentOptions
const appAccentOptions = [
  AppAccentOption(
    key: 'skyBlue',
    label: 'Sky Blue',
    seed: Color(0xFF3B82F6),
    container: Color(0xFFDBEAFE),
    fixed: Color(0xFFF8FAFC),
  ),
  AppAccentOption(
    key: 'mintGreen',
    label: 'Mint Green',
    seed: Color(0xFF10B981),
    container: Color(0xFFD1FAF5),
    fixed: Color(0xFFF0FDF4),
  ),
  AppAccentOption(
    key: 'softLavender',
    label: 'Lavender',
    seed: Color(0xFF8B5CF6),
    container: Color(0xFFF3E8FF),
    fixed: Color(0xFFFAF5FF),
  ),
  AppAccentOption(
    key: 'warmPeach',
    label: 'Peach',
    seed: Color(0xFFF97316),
    container: Color(0xFFFFEDD5),
    fixed: Color(0xFFFFFBF5),
  ),
  AppAccentOption(
    key: 'dustyRose',
    label: 'Rose',
    seed: Color(0xFFF43F5E),
    container: Color(0xFFFFE4E6),
    fixed: Color(0xFFFFF1F2),
  ),
  AppAccentOption(
    key: 'softTeal',
    label: 'Teal',
    seed: Color(0xFF14B8A6),
    container: Color(0xFFCCFBF1),
    fixed: Color(0xFFF0FDFA),
  ),
  AppAccentOption(
    key: 'softIndigo',
    label: 'Indigo',
    seed: Color(0xFF6366F1),
    container: Color(0xFFE0E7FF),
    fixed: Color(0xFFEEF2FF),
  ),
  AppAccentOption(
    key: 'softAmber',
    label: 'Amber',
    seed: Color(0xFFF59E0B),
    container: Color(0xFFFEF3C7),
    fixed: Color(0xFFFFFBEB),
  ),
  AppAccentOption(
    key: 'softCyan',
    label: 'Cyan',
    seed: Color(0xFF06B6D4),
    container: Color(0xFFCFFAFE),
    fixed: Color(0xFFECFEFF),
  ),
  AppAccentOption(
    key: 'softViolet',
    label: 'Violet',
    seed: Color(0xFF7C3AED),
    container: Color(0xFFEDE9FE),
    fixed: Color(0xFFF5F3FF),
  ),
  AppAccentOption(
    key: 'softPink',
    label: 'Pink',
    seed: Color(0xFFEC4899),
    container: Color(0xFFFCE7F3),
    fixed: Color(0xFFFDF2F8),
  ),
  AppAccentOption(
    key: 'softGray',
    label: 'Gray',
    seed: Color(0xFF6B7280),
    container: Color(0xFFF3F4F6),
    fixed: Color(0xFFFAFAFA),
  ),
  // Keep legacy options for backward compatibility
  AppAccentOption(
    key: maroonAccentKey,
    label: 'Maroon',
    seed: Color(0xFF7B2E1E),
    container: Color(0xFF99513B),
    fixed: Color(0xFFF7E2D7),
  ),
];
```

- [ ] **Step 2: Update lightHymnalColorScheme for pastel tones**

Replace the function body to use softer tones:

```dart
ColorScheme lightHymnalColorScheme(String? accentKey) {
  final accent = appAccentByKey(accentKey ?? defaultAccentKey);
  return ColorScheme.fromSeed(
    seedColor: accent.seed,
    brightness: Brightness.light,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    surface: accent.surface,
  );
}
```

- [ ] **Step 3: Update darkHymnalColorScheme for pastel dark tones**

Replace the function body:

```dart
ColorScheme darkHymnalColorScheme(String? accentKey) {
  final accent = appAccentByKey(accentKey ?? defaultAccentKey);
  return ColorScheme.fromSeed(
    seedColor: accent.seed.withValues(alpha: 0.8),
    brightness: Brightness.dark,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    surface: const Color(0xFF0F172A),
  );
}
```

- [ ] **Step 4: Run analyzer to verify no errors**

Run: `flutter analyze lib/components/themes/app_accent.dart`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add lib/components/themes/app_accent.dart
git commit -m "feat: update app_accent.dart with 12 pastel color options"
```

---

### Task 3: Update design_system.dart with refined spacing constants

**Files:**
- Modify: `lib/components/design_system/design_system.dart:1-186`

- [ ] **Step 1: Update spacing scale for cleaner layout**

Replace spacing constants:

```dart
// ═══════════════════════════════════════════════════════════════
// SPACING - Minimal 4px-based spacing scale
// ═══════════════════════════════════════════════════════════════

static const double spacing4 = 4;
static const double spacing8 = 8;
static const double spacing12 = 12;
static const double spacing16 = 16;
static const double spacing20 = 20;
static const double spacing24 = 24;
static const double spacing32 = 32;
static const double spacing40 = 40;
static const double spacing48 = 48;
static const double spacing64 = 64;
```

Replace radius constants:

```dart
// ═══════════════════════════════════════════════════════════════
// RADIUS - Consistent, softer border radius
// ═══════════════════════════════════════════════════════════════

static const double radiusNone = 0;
static const double radiusSm = 4;
static const double radiusMd = 8;
static const double radiusLg = 12;
static const double radiusXl = 16;
static const double radiusFull = 9999;
```

Replace navigation constants:

```dart
// ═══════════════════════════════════════════════════════════════
// NAVIGATION - Compact navigation sizes
// ═══════════════════════════════════════════════════════════════

static const double navBarHeightPortrait = 64;  // Reduced from 84
static const double navBarHeightLandscape = 56;   // Reduced from 66
static const double navBarHeightCompact = 48;
```

Update icon sizes:

```dart
// ═══════════════════════════════════════════════════════════════
// ICON SIZES - Consistent icon sizing
// ═══════════════════════════════════════════════════════════════

static const double iconSmall = 16;
static const double iconMedium = 20;
static const double iconLarge = 24;
static const double iconXLarge = 32;
```

Update elevation — remove heavy shadows:

```dart
// ═══════════════════════════════════════════════════════════════
// ELEVATION - Minimal elevation (no heavy shadows)
// ═══════════════════════════════════════════════════════════════

static const double elevationNone = 0;
static const double elevationLow = 1;
static const double elevationMedium = 2;
static const double elevationHigh = 4;
```

- [ ] **Step 2: Update gradients for pastel tones**

Replace Gradients class:

```dart
class Gradients {
  Gradients._();

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
  );

  static const LinearGradient pastelOverlay = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33DBEAFE), Color(0x00F8FAFC)],
  );
}
```

- [ ] **Step 3: Run analyzer**

Run: `flutter analyze lib/components/design_system/design_system.dart`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/components/design_system/design_system.dart
git commit -m "refactor: update design_system.dart with compact spacing and soft radius"
```

---

### Task 4: Update default_theme.dart with refined component styles

**Files:**
- Modify: `lib/components/themes/default_theme.dart:1-376`

- [ ] **Step 1: Update app bar theme**

```dart
appBarTheme: AppBarTheme(
  centerTitle: true,
  toolbarHeight: 56,  // Reduced from 74
  titleSpacing: 0,
  backgroundColor: colorScheme.surface,
  foregroundColor: colorScheme.onSurface,
  iconTheme: IconThemeData(color: colorScheme.onSurface),
  actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
  systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: colorScheme.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  ),
  scrolledUnderElevation: 0,
  surfaceTintColor: Colors.transparent,
  shadowColor: Colors.transparent,
  titleTextStyle: TextStyle(
    fontFamily: _hymnalHeadingFont,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    letterSpacing: 0.1,
    color: colorScheme.onSurface,
  ),
),
```

- [ ] **Step 2: Update card theme — remove shadows, soften borders**

```dart
cardTheme: CardThemeData(
  color: colorScheme.surfaceContainerLow,
  elevation: 0,  // No elevation
  margin: EdgeInsets.zero,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),  // Reduced from 20
    side: BorderSide(
      color: colorScheme.outlineVariant.withValues(alpha: 0.3),  // Subtle border
    ),
  ),
),
```

- [ ] **Step 3: Update navigation bar theme — compact with subtle indicator**

```dart
navigationBarTheme: NavigationBarThemeData(
  height: 64,  // Reduced from 70
  backgroundColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  indicatorColor: colorScheme.primary.withValues(alpha: 0.2),  // Subtle 20%
  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
  iconTheme: WidgetStateProperty.resolveWith((states) {
    final selected = states.contains(WidgetState.selected);
    return IconThemeData(
      size: selected ? 22 : 20,
      color: selected
          ? colorScheme.primary
          : colorScheme.onSurfaceVariant,
    );
  }),
  labelTextStyle: WidgetStateProperty.resolveWith((states) {
    final selected = states.contains(WidgetState.selected);
    return TextStyle(
      fontFamily: _hymnalUiFont,
      fontSize: 11,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      color: selected
          ? colorScheme.primary
          : colorScheme.onSurfaceVariant,
    );
  }),
),
```

- [ ] **Step 4: Update list tile theme — compact padding**

```dart
listTileTheme: ListTileThemeData(
  iconColor: colorScheme.primary,
  textColor: colorScheme.onSurface,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  minVerticalPadding: 4,
),
```

- [ ] **Step 5: Update input decoration theme**

```dart
inputDecorationTheme: InputDecorationTheme(
  filled: true,
  fillColor: colorScheme.surfaceContainerLow,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
  ),
),
```

- [ ] **Step 6: Update bottom sheet theme**

```dart
bottomSheetTheme: BottomSheetThemeData(
  backgroundColor: colorScheme.surface,
  surfaceTintColor: Colors.transparent,
  modalBackgroundColor: colorScheme.surface,
  modalBarrierColor: Colors.black.withValues(alpha: 0.2),
  showDragHandle: true,
  dragHandleColor: colorScheme.outlineVariant,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  ),
),
```

- [ ] **Step 7: Update chip theme**

```dart
chipTheme: ChipThemeData(
  backgroundColor: colorScheme.surfaceContainerLow,
  selectedColor: colorScheme.primaryContainer.withValues(alpha: 0.4),
  side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  labelStyle: TextStyle(
    fontFamily: _hymnalUiFont,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    color: colorScheme.onSurface,
  ),
),
```

- [ ] **Step 8: Run analyzer**

Run: `flutter analyze lib/components/themes/default_theme.dart`
Expected: No errors

- [ ] **Step 9: Commit**

```bash
git add lib/components/themes/default_theme.dart
git commit -m "refactor: update default_theme.dart with compact nav bar, subtle cards, refined components"
```

---

## Phase 2: Component Refinements

### Task 5: Clean up Dashboard View

**Files:**
- Modify: `lib/presentations/dashboard/view/dashboard_view.dart:1-986`

- [ ] **Step 1: Update bottom nav height constant**

```dart
// Replace:
const double kDashboardPortraitBottomNavHeight = 84;
// With:
const double kDashboardPortraitBottomNavHeight = 64;

// Replace:
const double kDashboardLandscapeBottomNavHeight = 66;
// With:
const double kDashboardLandscapeBottomNavHeight = 56;
```

- [ ] **Step 2: Simplify gradient background**

Replace the gradient decoration:

```dart
// Replace complex multi-stop gradient with simple pastel tone:
Positioned.fill(
  child: DecoratedBox(
    decoration: BoxDecoration(
      color: context.colorScheme.surface,
    ),
    child: AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(
        bottom: bodyBottomPadding,
      ),
      child: child,
    ),
  ),
),
```

- [ ] **Step 3: Simplify drawer header**

Replace `_DrawerHeader` decoration:

```dart
Container(
  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        // ... rest of content
      ),
    ],
  ),
),
```

- [ ] **Step 4: Simplify activity tile decoration**

Replace `_DrawerActivityTile` decoration:

```dart
Container(
  margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: onTap != null
        ? colors.primaryContainer.withValues(alpha: 0.3)
        : colors.surfaceContainerLow.withValues(alpha: 0.5),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: onTap != null
          ? colors.primary.withValues(alpha: 0.3)
          : colors.outlineVariant.withValues(alpha: 0.3),
    ),
  ),
),
```

- [ ] **Step 5: Update navigation bar indicator**

```dart
NavigationBar(
  backgroundColor: context.colorScheme.surface,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  indicatorColor: context.colorScheme.primary.withValues(alpha: 0.2),
  // ... rest
),
```

- [ ] **Step 6: Run analyzer**

Run: `flutter analyze lib/presentations/dashboard/view/dashboard_view.dart`
Expected: No errors

- [ ] **Step 7: Commit**

```bash
git add lib/presentations/dashboard/view/dashboard_view.dart
git commit -m "refactor: dashboard_view.dart - remove extra padding, simplify decorations"
```

---

### Task 6: Clean up Home View

**Files:**
- Modify: `lib/presentations/home/view/home_view.dart:1-1160`

- [ ] **Step 1: Update HomeHeader height**

```dart
Container(
  color: context.colorScheme.surface,
  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),  // Reduced from 10
  child: Row(
    // ... content
  ),
),
```

- [ ] **Step 2: Simplify hero panel**

Replace `_HomeHeroPanel` decoration:

```dart
Padding(
  padding: EdgeInsets.fromLTRB(16, compact ? 12 : 16, 16, 12),
  child: Container(
    padding: EdgeInsets.all(compact ? 16 : 20),
    decoration: BoxDecoration(
      color: colors.primaryContainer.withValues(alpha: 0.5),  // Softer fill
      borderRadius: BorderRadius.circular(compact ? 12 : 16),  // Reduced from 20/24
    ),
    // ... content
  ),
),
```

- [ ] **Step 3: Simplify quick launch tiles**

Replace `_QuickLaunchTile` decoration:

```dart
Ink(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),  // Reduced
  decoration: BoxDecoration(
    color: colors.surface.withValues(alpha: 0.8),
    borderRadius: BorderRadius.circular(8),  // Reduced from 16
  ),
),
```

- [ ] **Step 4: Simplify daily verse card**

Replace `_DailyVerseCard` decoration:

```dart
Container(
  decoration: BoxDecoration(
    color: context.colorScheme.secondaryContainer.withValues(alpha: 0.5),  // Softer
    borderRadius: BorderRadius.circular(12),  // Reduced from 20
  ),
  padding: const EdgeInsets.all(16),  // Reduced from 20
),
```

- [ ] **Step 5: Update Section widget usage**

Remove extra padding from Section wrapper usage:
- Banner carousel: 100px height (reduced from 132px)
- Section labels: Remove uppercase letter spacing, use tighter spacing

- [ ] **Step 6: Run analyzer**

Run: `flutter analyze lib/presentations/home/view/home_view.dart`
Expected: No errors

- [ ] **Step 7: Commit**

```bash
git add lib/presentations/home/view/home_view.dart
git commit -m "refactor: home_view.dart - simplify hero, cards, reduce padding"
```

---

### Task 7: Clean up Song List View

**Files:**
- Modify: `lib/presentations/song/view/song_list_view.dart:1-1015`

- [ ] **Step 1: Simplify search bar container**

Replace search bar container decoration:

```dart
Container(
  padding: const EdgeInsets.all(4),
  decoration: BoxDecoration(
    color: colors.surfaceContainerLow,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: colors.outlineVariant.withValues(alpha: 0.4),
    ),
  ),
),
```

- [ ] **Step 2: Simplify song list items**

Replace song item container:

```dart
Container(
  margin: const EdgeInsets.fromLTRB(12, 4, 12, 2),
  decoration: BoxDecoration(
    color: context.colorScheme.surfaceContainerLow,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: context.colorScheme.outlineVariant.withValues(alpha: 0.2),
    ),
  ),
  child: ListTile(
    contentPadding: EdgeInsets.symmetric(
      horizontal: compactList ? 12 : 16,
      vertical: 2,
    ),
    // ... content
  ),
),
```

- [ ] **Step 3: Simplify playlist card**

Replace `_PlaylistCard` decoration:

```dart
Container(
  margin: const EdgeInsets.only(bottom: 8),  // Reduced from 12
  decoration: BoxDecoration(
    color: context.colorScheme.surfaceContainerLow,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
    ),
  ),
),
```

- [ ] **Step 4: Update tab button styles**

Replace `_SongListTabButton`:

```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    minimumSize: Size(compact ? 72 : 84, 32),
    backgroundColor: selected
        ? context.colorScheme.primaryContainer.withValues(alpha: 0.4)  // Softer
        : Colors.transparent,
    // ...
  ),
),
```

- [ ] **Step 5: Run analyzer**

Run: `flutter analyze lib/presentations/song/view/song_list_view.dart`
Expected: No errors

- [ ] **Step 6: Commit**

```bash
git add lib/presentations/song/view/song_list_view.dart
git commit -m "refactor: song_list_view.dart - simplify cards, reduce padding"
```

---

### Task 8: Clean up other screen views

**Files:**
- Modify: `lib/presentations/bible/view/bible_list_view.dart`
- Modify: `lib/presentations/bible/view/bible_search_view.dart`
- Modify: `lib/presentations/faith/view/faith_note_list_view.dart`
- Modify: `lib/presentations/literature/view/literature_view.dart`

- [ ] **Step 1: Apply consistent card style to bible_list_view.dart**

```dart
Container(
  decoration: BoxDecoration(
    color: context.colorScheme.surfaceContainerLow,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: context.colorScheme.outlineVariant.withValues(alpha: 0.2),
    ),
  ),
  child: ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    // ...
  ),
)
```

- [ ] **Step 2: Apply consistent card style to faith_note_list_view.dart**
- [ ] **Step 3: Apply consistent card style to literature_view.dart**
- [ ] **Step 4: Run analyzer on all files**

Run: `flutter analyze lib/presentations/`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add lib/presentations/bible/view/bible_list_view.dart
git add lib/presentations/faith/view/faith_note_list_view.dart
git add lib/presentations/literature/view/literature_view.dart
git commit -m "refactor: clean up cards in bible, faith, literature views"
```

---

## Phase 3: Theme Settings Rework

### Task 9: Create ThemePreferences model

**Files:**
- Create: `lib/data/models/theme_preferences.dart`
- Create: `lib/data/models/theme_preferences.freezed.dart`
- Create: `lib/data/models/theme_preferences.g.dart`

- [ ] **Step 1: Write the model**

```dart
// lib/data/models/theme_preferences.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_preferences.freezed.dart';
part 'theme_preferences.g.dart';

enum SurfaceTone { light, medium, dark }

enum CornerRadiusStyle { soft, medium, sharp }

enum DisplayDensity { compact, standard, comfortable }

enum TypographyScale { compact, normal, comfortable }

@freezed
class ThemePreferences with _$ThemePreferences {
  const factory ThemePreferences({
    @Default('skyBlue') String accentKey,
    @Default(SurfaceTone.light) SurfaceTone surfaceTone,
    @Default(CornerRadiusStyle.soft) CornerRadiusStyle cornerRadius,
    @Default(DisplayDensity.standard) DisplayDensity density,
    @Default(TypographyScale.normal) TypographyScale typographyScale,
    @Default(false) bool compactMode,
  }) = _ThemePreferences;

  factory ThemePreferences.fromJson(Map<String, dynamic> json) =>
      _$ThemePreferencesFromJson(json);
}
```

- [ ] **Step 2: Run build_runner**

Run: `flutter pub run build_runner build`

- [ ] **Step 3: Commit**

```bash
git add lib/data/models/theme_preferences.dart
git commit -m "feat: add ThemePreferences model for customizable theme settings"
```

---

### Task 10: Create ThemePreferencesRepository

**Files:**
- Create: `lib/data/repositories/theme_preferences_repository.dart`

- [ ] **Step 1: Write the repository**

```dart
// lib/data/repositories/theme_preferences_repository.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/theme_preferences.dart';

class ThemePreferencesRepository {
  static const String _boxName = 'theme_preferences';
  static const String _key = 'preferences';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  ThemePreferences get preferences {
    final data = _box.get(_key);
    if (data == null) return const ThemePreferences();
    return ThemePreferences.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> savePreferences(ThemePreferences prefs) async {
    await _box.put(_key, prefs.toJson());
  }

  Future<void> updateAccentKey(String key) async {
    final current = preferences;
    await savePreferences(current.copyWith(accentKey: key));
  }

  Future<void> updateDensity(DisplayDensity density) async {
    final current = preferences;
    await savePreferences(current.copyWith(density: density));
  }

  Future<void> updateTypographyScale(TypographyScale scale) async {
    final current = preferences;
    await savePreferences(current.copyWith(typographyScale: scale));
  }

  Future<void> updateCornerRadius(CornerRadiusStyle style) async {
    final current = preferences;
    await savePreferences(current.copyWith(cornerRadius: style));
  }

  Future<void> reset() async {
    await savePreferences(const ThemePreferences());
  }
}
```

- [ ] **Step 2: Register in dependency injection**

Add to `lib/di/injection.dart`:
```dart
registerFactory<ThemePreferencesRepository>(() => ThemePreferencesRepository());
```

- [ ] **Step 3: Run analyzer**

Run: `flutter analyze lib/data/repositories/theme_preferences_repository.dart`

- [ ] **Step 4: Commit**

```bash
git add lib/data/repositories/theme_preferences_repository.dart
git add lib/di/injection.dart
git commit -m "feat: add ThemePreferencesRepository for theme persistence"
```

---

### Task 11: Rework Settings View with new theme UI

**Files:**
- Modify: `lib/presentations/settings/view/settings_view.dart`

- [ ] **Step 1: Create theme settings section widget**

```dart
class _ThemeSettingsSection extends StatelessWidget {
  const _ThemeSettingsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Theme'),
            _AccentColorPicker(
              selectedKey: state.themePreferences.accentKey,
              onSelected: (key) {
                context.read<SettingsCubit>().updateAccentKey(key);
              },
            ),
            const SizedBox(height: 16),
            _DensitySelector(
              selected: state.themePreferences.density,
              onChanged: (density) {
                context.read<SettingsCubit>().updateDensity(density);
              },
            ),
            const SizedBox(height: 16),
            _CornerRadiusSelector(
              selected: state.themePreferences.cornerRadius,
              onChanged: (style) {
                context.read<SettingsCubit>().updateCornerRadius(style);
              },
            ),
            const SizedBox(height: 16),
            _TypographyScaleSelector(
              selected: state.themePreferences.typographyScale,
              onChanged: (scale) {
                context.read<SettingsCubit>().updateTypographyScale(scale);
              },
            ),
            const SizedBox(height: 16),
            _ThemePreviewCard(preferences: state.themePreferences),
          ],
        );
      },
    );
  }
}
```

- [ ] **Step 2: Create accent color picker widget**

```dart
class _AccentColorPicker extends StatelessWidget {
  final String selectedKey;
  final ValueChanged<String> onSelected;

  const _AccentColorPicker({
    required this.selectedKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accent Color',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: appAccentOptions.map((accent) {
            final isSelected = accent.key == selectedKey;
            return GestureDetector(
              onTap: () => onSelected(accent.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accent.container,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: accent.seed, width: 2)
                      : Border.all(color: Colors.transparent),
                ),
                child: isSelected
                    ? Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: accent.seed,
                          size: 24,
                        ),
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Create density selector widget**

```dart
class _DensitySelector extends StatelessWidget {
  final DisplayDensity selected;
  final ValueChanged<DisplayDensity> onChanged;

  const _DensitySelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Display Density',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SegmentedButton<DisplayDensity>(
          segments: const [
            ButtonSegment(
              value: DisplayDensity.compact,
              label: Text('Compact'),
              icon: Icon(Icons.density_small_rounded),
            ),
            ButtonSegment(
              value: DisplayDensity.standard,
              label: Text('Standard'),
              icon: Icon(Icons.density_medium_rounded),
            ),
            ButtonSegment(
              value: DisplayDensity.comfortable,
              label: Text('Comfortable'),
              icon: Icon(Icons.density_large_rounded),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (set) => onChanged(set.first),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Create corner radius selector widget**

```dart
class _CornerRadiusSelector extends StatelessWidget {
  final CornerRadiusStyle selected;
  final ValueChanged<CornerRadiusStyle> onChanged;

  const _CornerRadiusSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Corner Radius',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SegmentedButton<CornerRadiusStyle>(
          segments: const [
            ButtonSegment(
              value: CornerRadiusStyle.soft,
              label: Text('Soft'),
            ),
            ButtonSegment(
              value: CornerRadiusStyle.medium,
              label: Text('Medium'),
            ),
            ButtonSegment(
              value: CornerRadiusStyle.sharp,
              label: Text('Sharp'),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (set) => onChanged(set.first),
        ),
      ],
    );
  }
}
```

- [ ] **Step 5: Create typography scale selector widget**

```dart
class _TypographyScaleSelector extends StatelessWidget {
  final TypographyScale selected;
  final ValueChanged<TypographyScale> onChanged;

  const _TypographyScaleSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Typography Scale',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SegmentedButton<TypographyScale>(
          segments: const [
            ButtonSegment(
              value: TypographyScale.compact,
              label: Text('Compact'),
            ),
            ButtonSegment(
              value: TypographyScale.normal,
              label: Text('Normal'),
            ),
            ButtonSegment(
              value: TypographyScale.comfortable,
              label: Text('Comfortable'),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (set) => onChanged(set.first),
        ),
      ],
    );
  }
}
```

- [ ] **Step 6: Create live preview card widget**

```dart
class _ThemePreviewCard extends StatelessWidget {
  final ThemePreferences preferences;

  const _ThemePreviewCard({required this.preferences});

  @override
  Widget build(BuildContext context) {
    final accent = appAccentByKey(preferences.accentKey);
    final radius = _getRadiusForStyle(preferences.cornerRadius);
    final scale = _getScaleForStyle(preferences.typographyScale);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: accent.container, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sample Heading',
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              color: accent.seed,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is sample body text showing the current theme settings.',
            style: TextStyle(
              fontSize: 14 * scale,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 6 * scale,
                ),
                decoration: BoxDecoration(
                  color: accent.container,
                  borderRadius: BorderRadius.circular(radius * 0.5),
                ),
                child: Text(
                  'Sample Chip',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    color: accent.seed,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 8 * scale,
                ),
                decoration: BoxDecoration(
                  color: accent.seed,
                  borderRadius: BorderRadius.circular(radius * 0.5),
                ),
                child: Text(
                  'Button',
                  style: TextStyle(
                    fontSize: 13 * scale,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _getRadiusForStyle(CornerRadiusStyle style) {
    switch (style) {
      case CornerRadiusStyle.soft: return 16;
      case CornerRadiusStyle.medium: return 12;
      case CornerRadiusStyle.sharp: return 4;
    }
  }

  double _getScaleForStyle(TypographyScale scale) {
    switch (scale) {
      case TypographyScale.compact: return 0.9;
      case TypographyScale.normal: return 1.0;
      case TypographyScale.comfortable: return 1.1;
    }
  }
}
```

- [ ] **Step 7: Update SettingsCubit to handle theme preferences**

Add to `lib/presentations/settings/cubit/settings_cubit.dart`:
```dart
@override
SettingsState updateAccentKey(String key) {
  return state.copyWith(
    themePreferences: state.themePreferences.copyWith(accentKey: key),
  );
}

@override
SettingsState updateDensity(DisplayDensity density) {
  return state.copyWith(
    themePreferences: state.themePreferences.copyWith(density: density),
  );
}
```

- [ ] **Step 8: Run analyzer**

Run: `flutter analyze lib/presentations/settings/`
Expected: No errors

- [ ] **Step 9: Commit**

```bash
git add lib/presentations/settings/view/settings_view.dart
git add lib/presentations/settings/cubit/settings_cubit.dart
git commit -m "feat: complete theme settings rework with color picker and live preview"
```

---

## Phase 4: Integration & Polish

### Task 12: Update InitialCubit for theme initialization

**Files:**
- Modify: `lib/presentations/initial/cubit/initial_cubit.dart`

- [ ] **Step 1: Load theme preferences on app init**

Add to `InitialCubit`:

```dart
Future<void> _loadTheme() async {
  final themeRepo = di<ThemePreferencesRepository>();
  await themeRepo.init();
  final prefs = themeRepo.preferences;
  emit(state.copyWith(
    accentKey: prefs.accentKey,
    themePreferences: prefs,
  ));
}
```

- [ ] **Step 2: Save theme on change**

Add save call after updating preferences:
```dart
final themeRepo = di<ThemePreferencesRepository>();
await themeRepo.savePreferences(state.themePreferences);
```

- [ ] **Step 3: Run analyzer**

Run: `flutter analyze lib/presentations/initial/`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/presentations/initial/cubit/initial_cubit.dart
git commit -m "feat: integrate theme preferences loading on app initialization"
```

---

### Task 13: Final verification and build

- [ ] **Step 1: Run full analyzer**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 2: Run all tests**

Run: `flutter test`
Expected: All tests pass

- [ ] **Step 3: Build for web**

Run: `flutter build web`
Expected: Build successful

- [ ] **Step 4: Build for android**

Run: `flutter build apk --debug`
Expected: Build successful

- [ ] **Step 5: Commit final changes**

```bash
git add -A
git commit -m "feat: complete pastel UI redesign with customizable theme settings"
```

---

## Self-Review Checklist

- [ ] All pastel color presets implemented in app_accent.dart
- [ ] PastelPreset model created with 12 options
- [ ] design_system.dart updated with compact spacing
- [ ] default_theme.dart updated with refined component styles
- [ ] Dashboard view cleaned up (removed extra padding)
- [ ] Home view simplified (hero, cards, sections)
- [ ] Song list cleaned up (search, items)
- [ ] Bible, faith, literature views updated with consistent cards
- [ ] ThemePreferences model created
- [ ] ThemePreferencesRepository implemented
- [ ] Settings view reworked with color picker and live preview
- [ ] All files pass analyzer
- [ ] All tests pass

---

## Execution Options

**Plan complete and saved to `docs/superpowers/plans/2026-05-21-gys-church-redesign.md`.**

**Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**
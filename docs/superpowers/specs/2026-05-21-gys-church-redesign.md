# GYS Church App — Complete UI Redesign Specification

**Date:** 2026-05-21  
**Version:** 1.0  
**Status:** Draft — Pending User Approval  
**Approach:** Minimal Pastel (Material Design 3)

---

## 1. Overview

**Goal:** Redesign the entire GYS Church App UI with a soft, pastel Material Design 3 aesthetic that feels clean, modern, and welcoming — while removing all unnecessary padding, extra boxes, and visual clutter.

**Design Philosophy:**
- **Pastel-first:** Sky blue primary (#DBEAFE), cloud white surfaces (#F8FAFC)
- **Minimalist layouts:** Every pixel of space must be intentional
- **Fully customizable:** Users control accent colors, spacing, typography, and density
- **Performant:** No heavy shadows, gradients, or unnecessary repaints

---

## 2. Color System

### 2.1 Primary Palette (Default: Sky Blue & Cloud White)

| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | #93C5FD (Sky Blue 300) | Buttons, links, active states |
| `primaryContainer` | #DBEAFE (Sky Blue 100) | Cards, selected chips |
| `onPrimary` | #1E3A5F | Text/icons on primary |
| `onPrimaryContainer` | #1E3A8A | Text on primary container |
| `surface` | #FFFFFF | Main background |
| `surfaceContainerLowest` | #F8FAFC (Slate 50) | Lowest surface layer |
| `surfaceContainerLow` | #F1F5F9 (Slate 100) | Card backgrounds |
| `surfaceContainer` | #F8FAFC | Elevated containers |
| `onSurface` | #1E293B (Slate 800) | Primary text |
| `onSurfaceVariant` | #64748B (Slate 500) | Secondary text |
| `outline` | #CBD5E1 (Slate 300) | Borders, dividers |
| `outlineVariant` | #E2E8F0 (Slate 200) | Subtle borders |

### 2.2 Pastel Accent Options (User-Selectable)

| Key | Label | Seed Color | Primary Container |
|-----|-------|------------|-------------------|
| `skyBlue` | Sky Blue | #3B82F6 | #DBEAFE |
| `mintGreen` | Mint | #10B981 | #D1FAF5 |
| `softLavender` | Lavender | #8B5CF6 | #F3E8FF |
| `warmPeach` | Peach | #F97316 | #FFEDD5 |
| `dustyRose` | Rose | #F43F5E | #FFE4E6 |
| `softTeal` | Teal | #14B8A6 | #CCFBF1 |
| `softIndigo` | Indigo | #6366F1 | #E0E7FF |
| `softAmber` | Amber | #F59E0B | #FEF3C7 |
| `softCyan` | Cyan | #06B6D4 | #CFFAFE |
| `softViolet` | Violet | #7C3AED | #EDE9FE |
| `softPink` | Pink | #EC4899 | #FCE7F3 |
| `softGray` | Gray | #6B7280 | #F3F4F6 |

### 2.3 Dark Mode Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `surface` | #0F172A (Slate 900) | Main background |
| `surfaceContainerLow` | #1E293B (Slate 800) | Card backgrounds |
| `onSurface` | #F1F5F9 (Slate 100) | Primary text |
| `onSurfaceVariant` | #94A3B8 (Slate 400) | Secondary text |

---

## 3. Typography

### 3.1 Font Configuration

| Style | Font Family | Weight | Size | Line Height |
|-------|-------------|--------|------|-------------|
| `headlineLarge` | EB Garamond | 700 | 32sp | 1.2 |
| `headlineMedium` | EB Garamond | 700 | 28sp | 1.2 |
| `headlineSmall` | EB Garamond | 700 | 24sp | 1.25 |
| `titleLarge` | Manrope | 700 | 20sp | 1.3 |
| `titleMedium` | Manrope | 600 | 16sp | 1.4 |
| `bodyLarge` | Manrope | 500 | 16sp | 1.5 |
| `bodyMedium` | Manrope | 500 | 14sp | 1.5 |
| `labelLarge` | Manrope | 600 | 14sp | 1.4 |
| `labelMedium` | Manrope | 600 | 12sp | 1.4 |
| `labelSmall` | Manrope | 700 | 11sp | 1.3 |

### 3.2 Density Options

| Option | Touch Target | Padding | Font Scale |
|--------|-------------|---------|------------|
| `compact` | 40px min | 8px / 12px | 0.9x |
| `standard` | 48px min | 12px / 16px | 1.0x |
| `comfortable` | 56px min | 16px / 20px | 1.1x |

---

## 4. Layout System

### 4.1 Spacing Scale (4px Base Unit)

| Token | Value | Usage |
|-------|-------|-------|
| `xxs` | 2px | Minimal gaps |
| `xs` | 4px | Icon-to-text spacing |
| `sm` | 8px | Compact list item padding |
| `md` | 12px | Standard padding |
| `lg` | 16px | Card padding, section gaps |
| `xl` | 20px | Major section spacing |
| `xxl` | 24px | Screen edge margins |

### 4.2 Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `none` | 0px | Flat elements |
| `sm` | 4px | Small chips |
| `md` | 8px | Buttons, inputs |
| `lg` | 12px | Cards, dialogs |
| `xl` | 16px | Bottom sheets |
| `full` | 9999px | Pills, avatars |

### 4.3 Screen Layout Rules

1. **Horizontal margins:** 16px on compact, 24px on medium, 32px on expanded
2. **Vertical padding:** 12px between sections, 8px between list items
3. **Max content width:** 840px for readability on large screens
4. **Safe area:** Respect system safe areas, no extra bottom padding beyond nav bar
5. **No nested containers:** Each screen has ONE scrollable content area

---

## 5. Components

### 5.1 Cards

**Before (Current):**
```dart
Container(
  decoration: BoxDecoration(
    color: colors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
    boxShadow: [...], // Extra shadow
  ),
)
```

**After (Redesigned):**
```dart
Container(
  decoration: BoxDecoration(
    color: colors.surfaceContainerLow, // Softer fill
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
    // NO box shadow — subtle fill is enough
  ),
)
```

**Rules:**
- Use `surfaceContainerLow` instead of `surfaceContainerLowest`
- Border alpha: 0.3 (subtle, not dominant)
- NO box shadows on cards (they create visual noise)
- Padding: 16px horizontal, 12px vertical

### 5.2 Buttons

**Primary Button:**
- Background: `primary` (sky blue)
- Text: `onPrimary` (dark blue)
- Padding: 12px horizontal, 10px vertical
- Border radius: 8px
- NO elevation

**Secondary Button:**
- Background: `surfaceContainerLow`
- Text: `onSurfaceVariant`
- Border: 1px `outlineVariant`
- Padding: 12px horizontal, 10px vertical

**Text Button:**
- No background
- Text: `primary`
- Padding: 8px horizontal, 4px vertical

### 5.3 Navigation Bar (Bottom)

**Current Issues:**
- Too tall (84px portrait)
- Extra vertical padding
- Overly prominent indicator

**Redesigned:**
```dart
NavigationBar(
  height: 64, // Reduced from 84
  indicatorColor: primary.withValues(alpha: 0.2), // Subtle fill
  indicatorShape: RoundedRectangleBorder(radius: 12),
  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
)
```

**Rules:**
- Height: 64px (compact) / 56px (landscape)
- Indicator: 20% opacity fill, NOT 45%
- Icon size: 22px selected, 20px unselected
- Label: 11sp, weight 600
- Remove extra outer padding

### 5.4 App Bar / Header

**Current Issues:**
- Height: 74px (too tall)
- Extra top padding
- Double titles in some views

**Redesigned:**
```dart
AppBar(
  toolbarHeight: 56, // Reduced from 74
  titleSpacing: 0,
  scrolledUnderElevation: 0,
  // Clean, minimal header
)
```

**Rules:**
- Height: 56px
- Title: 20sp, Manrope 700
- No elevation on scroll
- Leading: 48px touch target

### 5.5 List Items

**Before:**
- Extra horizontal padding (20px+)
- Double dividers
- Large gaps between items

**After:**
```dart
ListTile(
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  // Vertical padding reduced from 8-12 to 4
)
```

**Rules:**
- Horizontal padding: 16px
- Vertical padding: 4px (compact) / 8px (standard)
- Single divider at bottom
- Remove "last item" dividers
- Touch target: minimum 48px

### 5.6 Input Fields

**Search Fields:**
- Height: 44px (compact touch target)
- Border radius: 8px
- Fill: `surfaceContainerLow`
- Border: 1px `outlineVariant`
- Focus border: 1.5px `primary`
- No extra padding inside

### 5.7 Empty States / No Data

**Before:**
- Large empty containers
- Excessive spacing
- Confusing layouts

**After:**
```dart
Center(
  child: Padding(
    padding: EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inbox_rounded, size: 48, color: onSurfaceVariant.withValues(alpha: 0.5)),
        SizedBox(height: 16),
        Text('No items', style: titleMedium),
        SizedBox(height: 8),
        Text('Description', style: bodyMedium.copyWith(color: onSurfaceVariant)),
      ],
    ),
  ),
)
```

---

## 6. Screen-Specific Changes

### 6.1 Dashboard

| Element | Before | After |
|---------|--------|-------|
| App bar | 74px, extra padding | 56px, minimal |
| Bottom nav | 84px, heavy indicator | 64px, subtle indicator |
| Body padding | Extra safety gap (14px) | No extra gap |
| Gradient bg | Complex multi-stop | Simple single tone |
| Drawer | Nested containers | Single scrollable column |

### 6.2 Home View

| Element | Before | After |
|---------|--------|-------|
| Hero panel | Complex gradient, 20px radius | Simple pastel fill, 12px radius |
| Quick launch tiles | InkWell + Ink wrapper | Simple GestureDetector |
| Section labels | Uppercase + extra spacing | Title case + compact gap |
| Daily verse card | Extra border, complex padding | Minimal padding, soft fill |
| Banner carousel | 132px height, heavy decoration | 100px height, simple border |

### 6.3 Song List

| Element | Before | After |
|---------|--------|-------|
| Search bar | Complex nested stack | Simple container |
| Book code selector | Heavy border, gradient | Simple outlined container |
| Song items | Extra border, large padding | Minimal padding, subtle border |
| Playlist card | Complex gradient | Simple pastel fill |

### 6.4 Bible View

| Element | Before | After |
|---------|--------|-------|
| Search bar | Nested containers | Simple input field |
| Verse cards | Extra padding, borders | Minimal padding |
| Chapter list | Large gaps | Compact gaps |

### 6.5 Settings View

**Full rework required — see Section 7**

---

## 7. Theme Settings — Full Redesign

### 7.1 Settings Structure

```
Settings
├── Theme
│   ├── Accent Color (color picker)
│   ├── Surface Tone (light/medium/dark)
│   ├── Corner Radius (soft/medium/sharp)
│   ├── Typography Scale (compact/normal/comfortable)
│   ├── Display Density (compact/standard/comfortable)
│   └── Dark Mode (system/light/dark)
│
├── Font Size
│   └── Slider: 80% - 120%
│
├── Layout
│   ├── Navigation Style (bottom rail / drawer / tabs)
│   └── Compact Mode (on/off)
│
└── About
    ├── Version info
    └── Licenses
```

### 7.2 Color Picker Design

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
  ),
  itemCount: accentOptions.length,
  itemBuilder: (context, index) {
    final accent = accentOptions[index];
    final isSelected = currentKey == accent.key;
    return GestureDetector(
      onTap: () => selectAccent(accent.key),
      child: Container(
        decoration: BoxDecoration(
          color: accent.seed.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
            ? Border.all(color: accent.seed, width: 2)
            : null,
        ),
        child: Center(
          child: isSelected 
            ? Icon(Icons.check, color: accent.seed)
            : null,
        ),
      ),
    );
  },
)
```

### 7.3 Live Preview Panel

Each setting shows a live mini-preview card that reflects changes in real-time:

```dart
Container(
  width: double.infinity,
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: previewSurface,
    borderRadius: BorderRadius.circular(previewRadius),
    border: Border.all(color: previewBorder),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Preview', style: previewTextStyle),
      SizedBox(height: 8),
      // Mini representation of current theme settings
    ],
  ),
)
```

### 7.4 Default Pastel Presets

```dart
const pastelPresets = [
  PastelPreset(
    key: 'skyBlue',
    name: 'Sky Blue',
    primary: Color(0xFF93C5FD),
    container: Color(0xFFDBEAFE),
    surface: Color(0xFFF8FAFC),
  ),
  PastelPreset(
    key: 'mintGreen', 
    name: 'Mint Green',
    primary: Color(0xFF6EE7B7),
    container: Color(0xFFD1FAF5),
    surface: Color(0xFFF0FDF4),
  ),
  PastelPreset(
    key: 'softLavender',
    name: 'Soft Lavender',
    primary: Color(0xFFC4B5FD),
    container: Color(0xFFF3E8FF),
    surface: Color(0xFFFAF5FF),
  ),
  PastelPreset(
    key: 'warmPeach',
    name: 'Warm Peach',
    primary: Color(0xFFFED7AA),
    container: Color(0xFFFFEDD5),
    surface: Color(0xFFFFFBF5),
  ),
];
```

---

## 8. Performance Considerations

1. **No heavy gradients** — Use solid fills with subtle opacity
2. **No box shadows on lists** — Use border only
3. **Const constructors** — Use `const` wherever possible
4. **Minimal repaints** — Avoid animated builders where static is fine
5. **Efficient list views** — Use `ListView.builder` with minimal children

---

## 9. Implementation Priority

### Phase 1: Core Theme System
1. Create new pastel color scheme
2. Update DesignSystem constants
3. Create PastelPreset model
4. Update theme generation functions

### Phase 2: Component Refinement
1. Simplify card decorations (remove shadows)
2. Clean up navigation bar (reduce height, subtle indicator)
3. Optimize app bar (reduce height)
4. Simplify list items (reduce padding)

### Phase 3: Screen-by-Screen Polish
1. Dashboard redesign
2. Home view redesign
3. Song list redesign
4. Bible view redesign
5. Other screens

### Phase 4: Settings Rework
1. New theme settings UI
2. Color picker with live preview
3. Density/scale options
4. Persistence layer

---

## 10. Files to Modify

| File | Changes |
|------|---------|
| `lib/components/themes/app_accent.dart` | Add pastel presets, update seed colors |
| `lib/components/themes/default_theme.dart` | Update spacing, radius, component styles |
| `lib/components/design_system/design_system.dart` | Update spacing constants, add pastel tokens |
| `lib/presentations/dashboard/view/dashboard_view.dart` | Remove extra padding, update nav bar |
| `lib/presentations/home/view/home_view.dart` | Clean up hero, sections, cards |
| `lib/presentations/song/view/song_list_view.dart` | Simplify search, list items |
| `lib/presentations/settings/view/settings_view.dart` | Full rework with new theme UI |
| `lib/data/services/settings_service.dart` | Add new theme preference keys |

---

## 11. Success Criteria

- [ ] All screens use consistent pastel color scheme
- [ ] No extra padding > 24px on any screen
- [ ] No nested Container decorations without purpose
- [ ] Navigation bar is 64px or less
- [ ] App bar is 56px or less
- [ ] Theme settings fully functional with live preview
- [ ] User can switch between 12+ pastel accent options
- [ ] Density and typography scale options work correctly
- [ ] No regression in functionality

---

**Next Step:** Proceed with implementation plan using writing-plans skill.
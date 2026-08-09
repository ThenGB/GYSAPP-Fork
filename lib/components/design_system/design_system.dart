import 'package:flutter/material.dart';

/// Unified design system constants for the GYS Church App.
/// Provides consistent spacing, radius, and typography values.
class DesignSystem {
  DesignSystem._();

  // ═══════════════════════════════════════════════════════════════
  // SPACING - Consistent spacing scale based on 4px base unit
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

  // ═══════════════════════════════════════════════════════════════
  // RADIUS - Consistent, softer border radius
  // ═══════════════════════════════════════════════════════════════

  static const double radiusNone = 0;
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radius2Xl = 20;
  static const double radiusXLarge = 24;
  static const double radiusFull = 9999;

  // ═══════════════════════════════════════════════════════════════
  // ICON SIZES - Consistent icon sizing
  // ═══════════════════════════════════════════════════════════════

  static const double iconSmall = 16;
  static const double iconMedium = 20;
  static const double iconLarge = 24;
  static const double iconXLarge = 32;

  // ═══════════════════════════════════════════════════════════════
  // ELEVATION - Minimal elevation (no heavy shadows)
  // ═══════════════════════════════════════════════════════════════

  static const double elevationNone = 0;
  static const double elevationLow = 1;
  static const double elevationMedium = 2;
  static const double elevationHigh = 4;

  // ═══════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS
  // ═══════════════════════════════════════════════════════════════

  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 400);

  // ═══════════════════════════════════════════════════════════════
  // TYPOGRAPHY - Font families (defined in themes)
  // ═══════════════════════════════════════════════════════════════

  static const String fontHeading = 'EB Garamond';
  static const String fontUI = 'Manrope';

  /// Single source of truth for the user-selectable reading fonts.
  /// Previously every screen shipped its own list (Bible had 6 entries,
  /// Faith/Song had 5, the font settings page had 9) — the pickers showed
  /// different options depending on where you opened them.
  static const List<String> appFontOptions = [
    'Roboto',
    'Roboto Serif',
    'Open Sans',
    'Gentium Basic',
    'Arial',
    'EB Garamond',
    'Lato',
    'Quicksand',
    'Inter',
  ];

  // ═══════════════════════════════════════════════════════════════
  // NAVIGATION - Compact navigation sizes
  // ═══════════════════════════════════════════════════════════════

  static const double navBarHeightPortrait = 64; // Reduced from 84
  static const double navBarHeightLandscape = 56; // Reduced from 66
  static const double navBarHeightCompact = 48;
}

/// Extension to create consistent padding
extension SpacingExtension on double {
  EdgeInsets get pAll => EdgeInsets.all(this);
  EdgeInsets get pHorizontal => EdgeInsets.symmetric(horizontal: this);
  EdgeInsets get pVertical => EdgeInsets.symmetric(vertical: this);
  EdgeInsets get pLeft => EdgeInsets.only(left: this);
  EdgeInsets get pRight => EdgeInsets.only(right: this);
  EdgeInsets get pTop => EdgeInsets.only(top: this);
  EdgeInsets get pBottom => EdgeInsets.only(bottom: this);

  EdgeInsets symmetricPadding({double? vertical, double? horizontal}) {
    return EdgeInsets.symmetric(
      vertical: vertical ?? this,
      horizontal: horizontal ?? this,
    );
  }
}

/// Extension to create consistent border radius
extension RadiusExtension on double {
  BorderRadius get radiusAll => BorderRadius.circular(this);
  BorderRadius get radiusTop =>
      BorderRadius.vertical(top: Radius.circular(this));
  BorderRadius get radiusBottom =>
      BorderRadius.vertical(bottom: Radius.circular(this));
  BorderRadius get radiusLeft =>
      BorderRadius.horizontal(left: Radius.circular(this));
  BorderRadius get radiusRight =>
      BorderRadius.horizontal(right: Radius.circular(this));
}

/// Creates a card decoration with consistent styling
BoxDecoration cardDecoration(
  BuildContext context, {
  double? radius,
  Color? color,
  Color? borderColor,
  double? borderWidth,
  List<BoxShadow>? shadows,
}) {
  final theme = Theme.of(context);
  return BoxDecoration(
    color: color ?? theme.colorScheme.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(radius ?? DesignSystem.radiusXl),
    border: borderColor != null
        ? Border.all(color: borderColor, width: borderWidth ?? 1)
        : null,
    boxShadow: shadows,
  );
}

/// Creates a subtle shadow for elevated elements
List<BoxShadow> get elevationShadows => [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 4,
    offset: const Offset(0, 1),
  ),
];

/// Creates a medium shadow for floating elements
List<BoxShadow> get floatingShadows => [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 8,
    offset: const Offset(0, 2),
  ),
];

/// Gradient overlays for decorative backgrounds
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

  static const LinearGradient subtleOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x0A000000)],
  );
}

/// Responsive breakpoints for adaptive layouts
class Breakpoints {
  Breakpoints._();

  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compact && width < expanded;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= expanded;
}

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
  // RADIUS - Consistent border radius values
  // ═══════════════════════════════════════════════════════════════

  static const double radiusSmall = 4;
  static const double radiusMedium = 6;
  static const double radiusLarge = 8;
  static const double radiusXLarge = 8;
  static const double radius2XLarge = 12;
  static const double radiusFull = 9999;

  // ═══════════════════════════════════════════════════════════════
  // ICON SIZES - Consistent icon sizing
  // ═══════════════════════════════════════════════════════════════

  static const double iconSmall = 16;
  static const double iconMedium = 20;
  static const double iconLarge = 24;
  static const double iconXLarge = 32;

  // ═══════════════════════════════════════════════════════════════
  // ELEVATION - Subtle shadows for depth
  // ═══════════════════════════════════════════════════════════════

  static const double elevationLow = 1;
  static const double elevationMedium = 4;
  static const double elevationHigh = 8;

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

  // ═══════════════════════════════════════════════════════════════
  // NAVIGATION - Navigation constants
  // ═══════════════════════════════════════════════════════════════

  static const double navBarHeightPortrait = 72;
  static const double navBarHeightLandscape = 56;
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
    borderRadius: BorderRadius.circular(radius ?? DesignSystem.radiusXLarge),
    border: borderColor != null
        ? Border.all(color: borderColor, width: borderWidth ?? 1)
        : null,
    boxShadow: shadows,
  );
}

/// Creates a subtle shadow for elevated elements
List<BoxShadow> get elevationShadows => [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 8,
    offset: const Offset(0, 2),
  ),
];

/// Creates a medium shadow for floating elements
List<BoxShadow> get floatingShadows => [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.12),
    blurRadius: 16,
    offset: const Offset(0, 4),
  ),
];

/// Gradient overlays for decorative backgrounds
class Gradients {
  Gradients._();

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF8F7), Color(0xFFFFF0F0)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF570013), Color(0xFF800020)],
  );

  static const LinearGradient subtleOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x1A000000)],
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

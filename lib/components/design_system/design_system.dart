import 'package:flutter/material.dart';

/// Shared design tokens for the GYS Church App.
///
/// Colour comes from ThemeData so the user can customise the accent and
/// surface tone. These constants intentionally focus on geometry, motion and
/// typography rhythm rather than hard-coded decorative palettes.
class DesignSystem {
  DesignSystem._();

  // ---------------------------------------------------------------------------
  // "Ruang Ibadah Tenang" semantic palette.
  // Single source of truth for the warm/quiet surfaces and the GYS accent.
  // Themes and platform surfaces (e.g. flutter_native_splash.yaml) reference
  // these values so the identity stays consistent everywhere.
  // ---------------------------------------------------------------------------

  /// Warm sanctuary surface used as the light scaffold background.
  static const Color colorWarmSurface = Color(0xFFFAF9F7);

  /// Deep quiet surface used as the dark scaffold background.
  static const Color colorDarkSurface = Color(0xFF171513);

  /// GYS Blue — the primary accent for actions, selection and identity.
  static const Color colorGysBlue = Color(0xFF3B82F6);

  // Accessibility-first touch targets (WCAG 2.5.5 guidance for seniors).
  /// Minimum tappable target for any interactive control.
  static const double touchTargetMin = 48;
  /// Primary actions (CTA) get an extra-generous hit area.
  static const double touchTargetPrimary = 56;

  // Reader comfort: default text sizes and the ideal measure for long-form
  // scripture/lyric reading. Users can still scale beyond these via the
  // system text scaler (never capped).
  static const double readerFontSizeMin = 19;
  static const double readerFontSizeDefault = 20;
  static const int readerLineLengthChars = 70; // 55–75 char editorial measure

  // 4px spacing rhythm.
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing14 = 14;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing40 = 40;
  static const double spacing48 = 48;
  static const double spacing64 = 64;

  // Radius scale. User-selected radius preferences are applied by ThemeData
  // and context.appRadius; use these values only as semantic base sizes.
  static const double radiusNone = 0;
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radius2Xl = 20;
  static const double radiusXLarge = 24;
  static const double radiusFull = 9999;

  static const double iconSmall = 16;
  static const double iconMedium = 20;
  static const double iconLarge = 24;
  static const double iconXLarge = 32;

  // Elevation stays intentionally restrained; borders and tonal surfaces carry
  // most hierarchy in a reading/worship application.
  static const double elevationNone = 0;
  static const double elevationLow = 1;
  static const double elevationMedium = 2;
  static const double elevationHigh = 4;

  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 240);
  static const Duration animSlow = Duration(milliseconds: 360);

  static const String fontHeading = 'EB Garamond';
  static const String fontUI = 'Manrope';

  /// Single source of truth for user-selectable reading fonts. Heading/UI
  /// chrome continues to use the church editorial pairing from ThemeData.
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

  // Matches DashboardView's floating navigation dock contract.
  static const double navBarHeightPortrait = 72;
  static const double navBarHeightLandscape = 72;
  static const double navBarHeightCompact = 56;
}

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
    border: Border.all(
      color:
          borderColor ?? theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
      width: borderWidth ?? 0.8,
    ),
    boxShadow: shadows,
  );
}

List<BoxShadow> get elevationShadows => [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.045),
        blurRadius: 5,
        offset: const Offset(0, 1),
      ),
    ];

List<BoxShadow> get floatingShadows => [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.07),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ];

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

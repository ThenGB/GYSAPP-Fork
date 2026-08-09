import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Theme-wide display preferences exposed as a ThemeExtension so views can
/// derive radii, font sizes and spacing from the user's Display Density /
/// Corner Radius / Typography Scale settings instead of hardcoding values.
class AppThemeExtras extends ThemeExtension<AppThemeExtras> {
  /// Multiplier for corner radii (soft 1.0 / medium 0.6 / sharp 0.25).
  final double radiusScale;

  /// Multiplier for font sizes (compact 0.9 / normal 1.0 / comfortable 1.1).
  final double typographyScale;

  /// Multiplier for padding/spacing (compact 0.92 / standard 1.0 /
  /// comfortable 1.08).
  final double densityFactor;

  const AppThemeExtras({
    required this.radiusScale,
    required this.typographyScale,
    required this.densityFactor,
  });

  @override
  AppThemeExtras copyWith({
    double? radiusScale,
    double? typographyScale,
    double? densityFactor,
  }) {
    return AppThemeExtras(
      radiusScale: radiusScale ?? this.radiusScale,
      typographyScale: typographyScale ?? this.typographyScale,
      densityFactor: densityFactor ?? this.densityFactor,
    );
  }

  @override
  AppThemeExtras lerp(ThemeExtension<AppThemeExtras>? other, double t) {
    if (other is! AppThemeExtras) return this;
    return AppThemeExtras(
      radiusScale: lerpDouble(radiusScale, other.radiusScale, t)!,
      typographyScale: lerpDouble(typographyScale, other.typographyScale, t)!,
      densityFactor: lerpDouble(densityFactor, other.densityFactor, t)!,
    );
  }
}

extension AppThemeExtrasX on BuildContext {
  AppThemeExtras get appThemeExtras =>
      Theme.of(this).extension<AppThemeExtras>() ?? const AppThemeExtras(
        radiusScale: 1,
        typographyScale: 1,
        densityFactor: 1,
      );

  /// Corner radius scaled by the user's Corner Radius preference.
  BorderRadius appRadius(double base) => BorderRadius.circular(
        (base * appThemeExtras.radiusScale).roundToDouble(),
      );

  /// Font size scaled by the user's Typography Scale preference.
  double appFontSize(double base) => base * appThemeExtras.typographyScale;

  /// Spacing scaled by the user's Display Density preference.
  double appSpace(double base) => base * appThemeExtras.densityFactor;
}

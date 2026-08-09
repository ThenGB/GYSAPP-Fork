import 'package:flutter/material.dart';

import '../themes/app_theme_extras.dart';
import 'design_system.dart';

/// Theme-aware card used across the app. It deliberately avoids decorative
/// gradients and heavy elevation so scripture, hymn and ministry content stays
/// visually dominant.
class UnifiedCard extends StatelessWidget {
  const UnifiedCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.elevation,
    this.clipBehavior,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? borderRadius;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final double? elevation;
  final Clip? clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final extras = context.appThemeExtras;
    final effectiveRadius =
        borderRadius ?? (18 * extras.radiusScale).clamp(6.0, 24.0);
    final effectiveColor = color ?? colors.surfaceContainerLowest;
    final effectivePadding =
        padding ?? EdgeInsets.all(16 * extras.densityFactor);

    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: Border.all(
          color: borderColor ?? colors.outlineVariant.withValues(alpha: 0.52),
          width: borderWidth ?? 0.8,
        ),
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.055),
                  blurRadius: elevation! * 2.4,
                  offset: Offset(0, elevation! * 0.7),
                ),
              ]
            : null,
      ),
      child: Padding(padding: effectivePadding, child: child),
    );

    if (clipBehavior != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        clipBehavior: clipBehavior!,
        child: content,
      );
    }

    if (onTap != null || onLongPress != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(effectiveRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: content,
        ),
      );
    }

    return Padding(padding: margin ?? EdgeInsets.zero, child: content);
  }
}

class UnifiedSectionHeader extends StatelessWidget {
  const UnifiedSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding:
          padding ??
          EdgeInsets.fromLTRB(
            context.appSpace(18),
            context.appSpace(22),
            context.appSpace(18),
            context.appSpace(10),
          ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: subtitle == null ? 20 : 36,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                if (subtitle case final s?) ...[
                  const SizedBox(height: 3),
                  Text(
                    s,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class UnifiedEmptyState extends StatelessWidget {
  const UnifiedEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.action,
    this.padding,
  });

  final IconData icon;
  final String message;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: padding ?? DesignSystem.spacing32.pAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.62),
                  borderRadius: context.appRadius(18),
                ),
                child: Icon(icon, size: 28, color: colors.onPrimaryContainer),
              ),
              const SizedBox(height: DesignSystem.spacing16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              if (action != null) ...[
                const SizedBox(height: DesignSystem.spacing20),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class UnifiedLoadingState extends StatelessWidget {
  const UnifiedLoadingState({super.key, this.message, this.padding});

  final String? message;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: padding ?? DesignSystem.spacing32.pAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: const LinearProgressIndicator(minHeight: 4),
              ),
              if (message != null) ...[
                const SizedBox(height: DesignSystem.spacing14),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class UnifiedListTile extends StatelessWidget {
  const UnifiedListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    this.borderRadius,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return UnifiedCard(
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: context.appSpace(16),
            vertical: context.appSpace(13),
          ),
      borderRadius: borderRadius,
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: DesignSystem.spacing14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle case final s?) ...[
                  const SizedBox(height: 3),
                  Text(
                    s,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}

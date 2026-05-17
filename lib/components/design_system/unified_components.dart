import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Unified card component that provides consistent styling across the app.
/// Replaces scattered card implementations with a single, themeable component.

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
    final effectiveRadius = borderRadius ?? DesignSystem.radiusXLarge;
    final effectiveColor = color ?? theme.colorScheme.surfaceContainerLowest;

    Widget content = Container(
      padding: padding ?? DesignSystem.spacing16.pAll,
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: Border.all(
          color:
              borderColor ??
              theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: borderWidth ?? 1,
        ),
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: elevation! * 2,
                  offset: Offset(0, elevation!),
                ),
              ]
            : null,
      ),
      child: child,
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
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Section header widget for consistent section titles across the app.
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

    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (subtitle case final s?) ...[
                  const SizedBox(height: 4),
                  Text(
                    s,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

/// Empty state widget for consistent empty state displays.
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

    return Center(
      child: Padding(
        padding: padding ?? DesignSystem.spacing32.pAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: DesignSystem.spacing16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: DesignSystem.spacing24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading state widget for consistent loading displays.
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
            if (message != null) ...[
              const SizedBox(height: DesignSystem.spacing16),
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
    );
  }
}

/// List tile wrapper for consistent list item styling.
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
          const EdgeInsets.symmetric(
            horizontal: DesignSystem.spacing16,
            vertical: DesignSystem.spacing12,
          ),
      borderRadius: borderRadius,
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: DesignSystem.spacing16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle case final s?) ...[
                  const SizedBox(height: 2),
                  Text(
                    s,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

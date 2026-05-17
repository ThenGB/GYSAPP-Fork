import 'package:flutter/material.dart';

import '../../data/utilities/extensions/context_ext.dart';

class Section extends StatelessWidget {
  final Widget Function(double gap) child;
  final String? label;

  const Section({super.key, this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 560;

    final horizontalMargin = compact ? 10.0 : 18.0;
    final innerGap = compact ? 14.0 : 20.0;
    final radius = compact ? 22.0 : 28.0;
    final panelGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colors.surfaceContainerLowest.withValues(alpha: 0.9),
        colors.surfaceContainerLow.withValues(alpha: 0.86),
        colors.surfaceContainerHighest.withValues(alpha: 0.78),
      ],
    );

    return AnimatedContainer(
      duration: kThemeAnimationDuration,
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.fromLTRB(
        horizontalMargin,
        compact ? 10 : 12,
        horizontalMargin,
        compact ? 14 : 18,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.48),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.12),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: panelGradient),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 14 : 18,
                    compact ? 14 : 16,
                    compact ? 14 : 18,
                    0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.primaryContainer.withValues(alpha: 0.82),
                          colors.secondaryContainer.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.24),
                      ),
                    ),
                    child: Text(
                      label!.toUpperCase(),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.onPrimaryContainer,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: compact ? 10 : 12),
              ],
              child(innerGap),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../themes/app_theme_extras.dart';
import '../../data/utilities/extensions/context_ext.dart';

class Section extends StatelessWidget {
  const Section({
    super.key,
    this.label,
    this.subtitle,
    required this.child,
  });

  final Widget Function(double gap) child;
  final String? label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 560;
    final horizontalMargin = context.appSpace(compact ? 10 : 18);
    final innerGap = context.appSpace(compact ? 14 : 20);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalMargin,
        context.appSpace(compact ? 10 : 14),
        horizontalMargin,
        context.appSpace(compact ? 5 : 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null || subtitle != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.appSpace(compact ? 7 : 6),
                0,
                context.appSpace(6),
                context.appSpace(subtitle == null ? 9 : 11),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3,
                    height: subtitle == null ? 18 : 32,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (label != null)
                          Text(
                            label!,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w750,
                              letterSpacing: 0.05,
                            ),
                          ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          child(innerGap),
        ],
      ),
    );
  }
}

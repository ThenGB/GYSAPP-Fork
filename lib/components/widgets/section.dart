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

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalMargin,
        compact ? 10 : 12,
        horizontalMargin,
        compact ? 4 : 6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Padding(
              padding: EdgeInsets.only(
                left: compact ? 8 : 6,
                bottom: compact ? 8 : 10,
              ),
              child: Text(
                label!.toUpperCase(),
                style: context.textTheme.labelMedium?.copyWith(
                  color: colors.onSurface,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w900,
                  fontSize: compact ? 13 : 14,
                ),
              ),
            ),
          ],
          child(innerGap),
        ],
      ),
    );
  }
}

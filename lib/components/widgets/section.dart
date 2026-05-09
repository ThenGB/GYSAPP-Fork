import 'package:flutter/material.dart';

import '../../data/utilities/extensions/context_ext.dart';

class Section extends StatelessWidget {
  final Widget Function(double gap) child;
  final String? label;
  const Section({super.key, this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                label!,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          child(20),
        ],
      ),
    );
  }
}

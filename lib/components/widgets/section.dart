import 'package:church/data/utilities/extensions/context_ext.dart';
import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  final Widget Function(double gap) child;
  final String? label;
  const Section({
    super.key,
    this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      color: context.colorScheme.background,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            )
          ],
          child(12),
        ],
      ),
    );
  }
}

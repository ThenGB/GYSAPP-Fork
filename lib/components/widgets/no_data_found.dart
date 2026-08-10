import 'package:flutter/material.dart';

import '../../data/utilities/extensions/context_ext.dart';
import '../../data/utilities/variables/assets.dart';
import '../themes/app_theme_extras.dart';

/// Empty/search-miss placeholder used across note lists, bible search,
/// hymnal management, and soundfont screens.
class NoDataFound extends StatelessWidget {
  final String title;
  final String description;
  final Widget? action;
  const NoDataFound({
    super.key,
    required this.title,
    required this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: context.appRadius(8),
          border: Border.all(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(Assets.assetsImagesEmpty, width: 180),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: context.appFontSize(16),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textTheme.bodyMedium?.color?.withValues(
                  alpha: .58,
                ),
              ),
            ),
            if (action != null) ...[SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

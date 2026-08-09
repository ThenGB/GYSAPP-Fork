from pathlib import Path
import re

path = Path('lib/presentations/dashboard/view/dashboard_view.dart')
text = path.read_text(encoding='utf-8')
text = text.replace("import 'package:flutter/cupertino.dart';\n", '')
text = text.replace("import 'package:simple_animations/simple_animations.dart';\n", '')

pattern = re.compile(
    r"          if \(state\.isLoading\) \{\n"
    r"[\s\S]*?"
    r"          \}\n          // ignore: deprecated_member_use",
)
replacement = '''          if (state.isLoading) {
            final colors = context.colorScheme;
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Scaffold(
              backgroundColor: colors.surface,
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.97, end: 1),
                            duration: const Duration(milliseconds: 360),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) =>
                                Transform.scale(scale: value, child: child),
                            child: Image.asset(
                              isDark
                                  ? Assets.assetsImagesLogoIndonesiaWhite
                                  : Assets.assetsImagesLogoIndonesiaColor,
                              width: 220,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Preparing dashboard',
                            textAlign: TextAlign.center,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Alkitab • Kidung • Iman • Pelayanan',
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 4,
                              backgroundColor: colors.surfaceContainerHighest,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          // ignore: deprecated_member_use'''
text, count = pattern.subn(replacement, text, count=1)
if count != 1:
    raise SystemExit(f'dashboard loading block replacement count={count}')
path.write_text(text, encoding='utf-8')

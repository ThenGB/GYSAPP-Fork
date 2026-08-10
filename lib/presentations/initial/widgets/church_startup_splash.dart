import 'package:flutter/material.dart';

import '../../../components/components.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/variables/assets.dart';

/// Flutter-owned startup surface shown immediately after the native splash.
///
/// It deliberately contains no visible copy: the complete church wordmark and
/// the quiet moving bar are enough to communicate identity and progress.
class ChurchStartupSplash extends StatefulWidget {
  const ChurchStartupSplash({super.key});

  @override
  State<ChurchStartupSplash> createState() => _ChurchStartupSplashState();
}

class _ChurchStartupSplashState extends State<ChurchStartupSplash>
    with TickerProviderStateMixin {
  late final AnimationController _introController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  );
  late final AnimationController _progressController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _introController,
    curve: const Interval(0, 0.72, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 0.965,
    end: 1,
  ).animate(
    CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic),
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 0.035),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic),
  );

  bool? _animationsDisabled;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.disableAnimationsOf(context);
    if (_animationsDisabled == disabled) return;
    _animationsDisabled = disabled;
    if (disabled) {
      _introController.value = 1;
      _progressController
        ..stop()
        ..value = 0.52;
    } else {
      if (!_introController.isCompleted) _introController.forward();
      _progressController.repeat();
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: colors.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.surface,
              Color.alphaBlend(
                colors.primary.withValues(alpha: isDark ? 0.045 : 0.025),
                colors.surface,
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final logoWidth = (constraints.maxWidth * 0.68)
                  .clamp(210.0, 290.0)
                  .toDouble();
              final barWidth = (constraints.maxWidth * 0.48)
                  .clamp(150.0, 200.0)
                  .toDouble();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: RepaintBoundary(
                    child: FadeTransition(
                      opacity: _opacity,
                      child: SlideTransition(
                        position: _offset,
                        child: ScaleTransition(
                          scale: _scale,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  ExcludeSemantics(
                                    child: Container(
                                      width: logoWidth + 72,
                                      height: 178,
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            colors.primary.withValues(
                                              alpha: isDark ? 0.1 : 0.07,
                                            ),
                                            colors.primary.withValues(alpha: 0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Semantics(
                                    label: 'Gereja Yesus Sejati',
                                    image: true,
                                    child: Image.asset(
                                      isDark
                                          ? Assets.assetsImagesLogoIndonesiaWhite
                                          : Assets.assetsImagesLogoIndonesiaColor,
                                      width: logoWidth,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: barWidth,
                                height: 5,
                                child: _ChurchLoadingBar(
                                  animation: _progressController,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChurchLoadingBar extends AnimatedWidget {
  const _ChurchLoadingBar({required Animation<double> animation})
    : super(listenable: animation);

  Animation<double> get animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return ClipRRect(
      borderRadius: context.appRadius(999),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth * 0.38;
          final left =
              (constraints.maxWidth + segmentWidth) * animation.value -
              segmentWidth;
          return Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.72),
              ),
              Positioned(
                left: left,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary.withValues(alpha: 0.42),
                        colors.primary,
                        colors.tertiary.withValues(alpha: 0.72),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../router/router.dart';
import '../bloc/initial_cubit.dart';

@RoutePage()
class InitialView extends StatefulWidget {
  const InitialView({super.key});

  @override
  State<InitialView> createState() => _InitialViewState();
}

bool shouldShowStartupPreparationDialog(InitialState state) {
  return !state.isLoaded && state.message == startupKrPreparationMessage;
}

class _InitialViewState extends State<InitialView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<InitialCubit>().initState();
    });
  }

  @override
  Widget build(BuildContext context) {
    timeago.LookupMessages message = EnShortMessages();
    switch (context.locale.languageCode) {
      case 'id':
        message = IndoShortMessages();
        break;
      case 'zh':
        message = timeago.ZhCnMessages();
        break;
      default:
    }
    timeago.setLocaleMessages(context.locale.languageCode, message);

    return BlocConsumer<InitialCubit, InitialState>(
      listenWhen: (previous, current) =>
          previous.isLoaded != current.isLoaded && current.isLoaded,
      listener: (context, state) {
        router.popUntilRoot();
        router.replace(const DashboardRoute());
      },
      builder: (context, state) {
        final colors = context.colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: colors.surface,
          body: Stack(
            fit: StackFit.expand,
            children: [
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.94, end: 1),
                            duration: const Duration(milliseconds: 520),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) => Opacity(
                              opacity: ((value - 0.94) / 0.06).clamp(0, 1),
                              child: Transform.scale(scale: value, child: child),
                            ),
                            child: Semantics(
                              label: 'Gereja Yesus Sejati',
                              image: true,
                              child: Image.asset(
                                isDark
                                    ? Assets.assetsImagesLogoIndonesiaWhite
                                    : Assets.assetsImagesLogoIndonesiaColor,
                                width: 250,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 34),
                          Text(
                            'GYS APP',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Alkitab • Kidung • Iman • Pelayanan',
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 30),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 5,
                              backgroundColor: colors.surfaceContainerHighest,
                            ),
                          ),
                          const SizedBox(height: 14),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: Text(
                              state.message.isEmpty
                                  ? 'Menyiapkan aplikasi…'
                                  : state.message,
                              key: ValueKey(state.message),
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: state.isFailed
                                    ? colors.error
                                    : colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (state.isFailed) ...[
                            const SizedBox(height: 18),
                            OutlinedButton.icon(
                              onPressed: context.read<InitialCubit>().initState,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Coba lagi'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (shouldShowStartupPreparationDialog(state))
                ColoredBox(
                  color: colors.scrim.withValues(alpha: 0.34),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Card(
                        margin: const EdgeInsets.all(24),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer,
                                  borderRadius: context.appRadius(16),
                                ),
                                child: Icon(
                                  Icons.library_music_outlined,
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Preparing Kidung Rohani',
                                textAlign: TextAlign.center,
                                style: context.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This first-time setup prepares KR for faster offline access later.',
                                textAlign: TextAlign.center,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: const LinearProgressIndicator(minHeight: 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Indonesian short Messages
class IndoShortMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'baru saja';
  @override
  String aboutAMinute(int minutes) => '1m';
  @override
  String minutes(int minutes) => '${minutes}m';
  @override
  String aboutAnHour(int minutes) => '1j';
  @override
  String hours(int hours) => '${hours}j';
  @override
  String aDay(int hours) => '1h';
  @override
  String days(int days) => '${days}h';
  @override
  String aboutAMonth(int days) => '1bln';
  @override
  String months(int months) => '${months}bln';
  @override
  String aboutAYear(int year) => '1th';
  @override
  String years(int years) => '${years}th';
  @override
  String wordSeparator() => ' ';
}

/// English short Messages
class EnShortMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'now';
  @override
  String aboutAMinute(int minutes) => '1m';
  @override
  String minutes(int minutes) => '${minutes}m';
  @override
  String aboutAnHour(int minutes) => '1h';
  @override
  String hours(int hours) => '${hours}h';
  @override
  String aDay(int hours) => '1d';
  @override
  String days(int days) => '${days}d';
  @override
  String aboutAMonth(int days) => '1mo';
  @override
  String months(int months) => '${months}mo';
  @override
  String aboutAYear(int year) => '1y';
  @override
  String years(int years) => '${years}y';
  @override
  String wordSeparator() => ' ';
}

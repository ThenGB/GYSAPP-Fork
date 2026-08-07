import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_animations/simple_animations.dart';
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
    return BlocBuilder<InitialCubit, InitialState>(
      builder: (context, state) => BlocListener<InitialCubit, InitialState>(
        listener: (context, state) {
          if (state.isLoaded) {
            router.popUntilRoot();
            router.replace(const DashboardRoute());
          }
        },
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: MirrorAnimationBuilder(
                        duration: const Duration(milliseconds: 1500),
                        tween: Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ),
                        builder: (context, value, child) {
                          double scale = 1 + (0.1 * value);
                          double opacity = 1 - (0.5 * value);
                          return state.isFailed
                              ? child!
                              : Transform.scale(
                                  scale: scale,
                                  child: Opacity(opacity: opacity, child: child),
                                );
                        },
                        child: Image.asset(Assets.assetsImagesAppicon),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CupertinoActivityIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (shouldShowStartupPreparationDialog(state))
                ColoredBox(
                  color: Colors.black.withValues(alpha: 0.34),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Card(
                        elevation: 18,
                        shape: RoundedRectangleBorder(
                          borderRadius: context.appRadius(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.offline_bolt_rounded,
                                size: 42,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Preparing Kidung Rohani',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This first-time setup prepares KR for faster offline access later.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 18),
                              const CupertinoActivityIndicator(radius: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
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

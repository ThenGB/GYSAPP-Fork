import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../data/data.dart';
import '../../../router/router.dart';
import '../bloc/initial_cubit.dart';

@RoutePage()
class InitialView extends StatelessWidget {
  const InitialView({super.key});

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
    context.read<InitialCubit>().initState();
    return BlocBuilder<InitialCubit, InitialState>(
      builder: (context, state) => BlocListener<InitialCubit, InitialState>(
        listener: (context, state) {
          if (state.isLoaded) {
            router.popUntilRoot();
            router.replace(
              const DashboardRoute(),
            );
          }
        },
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: MirrorAnimationBuilder(
                    duration: const Duration(milliseconds: 1500),
                    tween: Tween<double>(
                        begin: 0.0, end: 1.0), // Keep the original tween
                    builder: (context, value, child) {
                      double scale = 1 +
                          (0.1 *
                              value); // Interpolate to get scale between 1 and 1.3
                      double opacity = 1 -
                          (0.5 *
                              value); // Interpolate to get scale between 1 and 1.3
                      return state.isFailed
                          ? child!
                          : Transform.scale(
                              scale: scale, // Apply the interpolated scale
                              child: Opacity(opacity: opacity, child: child),
                            );
                    },
                    child: Image.asset(Assets.assetsImagesAppicon),
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoActivityIndicator(),
              ],
            ),
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

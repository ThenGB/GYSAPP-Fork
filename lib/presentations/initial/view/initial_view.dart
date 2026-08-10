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
          !previous.isLoaded && current.isLoaded,
      listener: (context, state) {
        router.popUntilRoot();
        router.replace(const DashboardRoute());
      },
      builder: (context, state) {
        final colors = context.colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: colors.surface,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        label: 'Gereja Yesus Sejati',
                        image: true,
                        child: Image.asset(
                          isDark
                              ? Assets.assetsImagesLogoIndonesiaWhite
                              : Assets.assetsImagesLogoIndonesiaColor,
                          width: 260,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 34),
                      ClipRRect(
                        borderRadius: context.appRadius(999),
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

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../router/router.dart';
import '../bloc/initial_cubit.dart';
import '../widgets/church_startup_splash.dart';

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
        router.replace(const AdaptiveAppShellRoute());
      },
      builder: (context, state) => const ChurchStartupSplash(),
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

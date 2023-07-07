import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../components/widgets/drag_handler.dart';
import '../../../components/widgets/section.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/extensions/int_ext.dart';
import '../../../data/utilities/extensions/locale_ext.dart';
import '../../../data/utilities/variables/assets.dart';
import '../../../router/router.dart';
import '../../bible/cubit/bible_cubit.dart';
import '../../bible/widget/bible_select_widget.dart';
import '../../dashboard/cubit/dashboard_cubit.dart';
import '../../dashboard/cubit/dashboard_state.dart';
import '../../initial/bloc/initial_cubit.dart';
import '../cubit/settings_cubit.dart';

@RoutePage()
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.background,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: (state.idToken == null
                            ? Image.asset(Assets.assetsImagesAppicon)
                            : ClipOval(
                                child: CachedNetworkImage(
                                    imageUrl:
                                        state.account?.profilePicture ?? ''),
                              )),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: state.idToken == null
                            ? Text(
                                'register_button_text'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.account?.name ?? 'Unknown'.tr(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    state.account?.email ?? 'Unknown'.tr(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: state.idToken == null
                                ? context.colorScheme.primaryContainer
                                : context.colorScheme.errorContainer,
                            foregroundColor: state.idToken == null
                                ? context.colorScheme.onPrimaryContainer
                                : context.colorScheme.onErrorContainer,
                          ),
                          onPressed: () {
                            if (context.read<DashboardCubit>().state.idToken ==
                                null) {
                              router.push(LoginRoute(
                                onLoggedIn: (token) {
                                  router.pop();
                                  context
                                      .read<DashboardCubit>()
                                      .loginSuccessCallback(token);
                                  Fluttertoast.cancel();
                                  Fluttertoast.showToast(
                                      msg: 'BERHASIL LOGIN!');
                                },
                              ));
                            } else {
                              context
                                  .showConfirmation(
                                      'Are you sure want to logout?'.tr())
                                  .then((yes) {
                                if (yes) {
                                  context
                                      .read<DashboardCubit>()
                                      .loginSuccessCallback(null);
                                }
                              });
                            }
                          },
                          child:
                              Text(state.idToken == null ? 'Login' : 'Logout')),
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: ListView(
                children: [
                  BlocBuilder<BibleCubit, BibleState>(
                    builder: (context, state) => Section(
                      label: 'Verse'.tr(),
                      child: (gap) => Column(
                        children: [
                          {
                            'label': 'Version'.tr(),
                            'desc': null,
                            'onTap': () {},
                            'trailing': ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () async {
                                log('onTapSelectBible');
                                context.read<BibleCubit>().getBibles();
                                var bibleCodes = context
                                    .read<BibleCubit>()
                                    .state
                                    .bibleCodes
                                    .map(
                                        (e) => e.split('.').first.toUpperCase())
                                    .toList();
                                await showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                  builder: (ctx) => BibleSelectWidget(
                                    bibleCodes: bibleCodes,
                                    onTap: (index) async {
                                      await context
                                          .read<BibleCubit>()
                                          .selectBibleCode(index);
                                      router.pop();
                                    },
                                  ),
                                );
                              },
                              child: Text(
                                  (state.currentBibleCode?.split('_').last ??
                                          'none')
                                      .toUpperCase()),
                            ),
                          },
                          {
                            'label': 'Today Reading'.tr(),
                            'desc': null,
                            'onTap': () {},
                            'trailing': ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () {
                                router.push(BibleListRoute(
                                  onSelected: (newBible) {
                                    context
                                        .read<BibleCubit>()
                                        .setTodayReading(newBible);
                                    router.pop();
                                  },
                                  getBibles: (bookId, chapterId) async {
                                    if (bookId == null || chapterId == null) {
                                      return [];
                                    }
                                    return await context
                                        .read<BibleCubit>()
                                        .getVersesByBook(bookId, chapterId);
                                  },
                                  books: state.books,
                                ));
                              },
                              child: FutureBuilder<String>(
                                  future: context
                                      .read<BibleCubit>()
                                      .getBibleTitle([state.todayReading]),
                                  builder: (context, snapshot) =>
                                      Text(snapshot.data ?? 'None'.tr())),
                            ),
                          },
                          {
                            'label': 'Bible Reminder'.tr(),
                            'desc': null,
                            'onTap': () {},
                            'trailing': ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () async {
                                var settingCubit =
                                    context.read<SettingsCubit>();

                                var weekdays =
                                    List.generate(7, (index) => index + 1);
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  context: context,
                                  builder: (context) {
                                    return BibleReminderDialog(
                                        weekdays: weekdays,
                                        settingCubit: settingCubit);
                                  },
                                );
                              },
                              child: Text((context
                                          .watch<SettingsCubit>()
                                          .state
                                          .isBibleReminderNotificationActive
                                      ? 'On'
                                      : 'Off')
                                  .tr()),
                            ),
                          },
                        ]
                            .map((e) => ListTile(
                                  dense: true,
                                  style: ListTileStyle.list,
                                  visualDensity: VisualDensity.compact,
                                  title: Text(
                                    e['label'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: e['trailing'] as Widget?,
                                  onTap: e['onTap'] as Function()?,
                                  subtitle: e['desc'] == null
                                      ? null
                                      : Text(e['desc'] as String),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  Section(
                    label: 'Notification'.tr(),
                    child: (gap) => Column(
                      children: [
                        {
                          'label': 'Sabat Notification'.tr(),
                          'desc': null,
                          'onTap': () {},
                          'trailing': ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.isSabatNotificationActive
                                  ? context.colorScheme.primaryContainer
                                  : context.colorScheme.errorContainer,
                              foregroundColor: state.isSabatNotificationActive
                                  ? context.colorScheme.onPrimaryContainer
                                  : context.colorScheme.onErrorContainer,
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () {
                              context
                                  .read<SettingsCubit>()
                                  .toggleSabatNotification();
                            },
                            child: Text(
                              (state.isSabatNotificationActive ? 'ON' : 'OFF')
                                  .tr(),
                            ),
                          ),
                        },
                      ]
                          .map((e) => ListTile(
                                dense: true,
                                style: ListTileStyle.list,
                                visualDensity: VisualDensity.compact,
                                title: Text(
                                  e['label'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: e['trailing'] as Widget?,
                                onTap: e['onTap'] as Function()?,
                                subtitle: e['desc'] == null
                                    ? null
                                    : Text(e['desc'] as String),
                              ))
                          .toList(),
                    ),
                  ),
                  Section(
                    label: 'Others'.tr(),
                    child: (gap) => Column(
                      children: [
                        {
                          'label': 'Theme'.tr(),
                          'desc': null,
                          'onTap': () {},
                          'trailing': ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () {
                              context.read<InitialCubit>().toggleTheme(
                                    context.theme.brightness == Brightness.light
                                        ? ThemeMode.dark
                                        : ThemeMode.light,
                                    context,
                                  );
                            },
                            child: Text(context
                                .read<InitialCubit>()
                                .state
                                .themeMode
                                .toUpperCase()),
                          ),
                        },
                        {
                          'label': 'Language'.tr(),
                          'desc': null,
                          'onTap': () {},
                          'trailing': ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () async {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                builder: (context) => SelectLanguageDialog(),
                              );
                            },
                            child: Text(context.locale.languageName),
                          ),
                        },
                      ]
                          .map((e) => ListTile(
                                dense: true,
                                style: ListTileStyle.list,
                                visualDensity: VisualDensity.compact,
                                title: Text(
                                  e['label'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: e['trailing'] as Widget?,
                                onTap: e['onTap'] as Function()?,
                                subtitle: e['desc'] == null
                                    ? null
                                    : Text(e['desc'] as String),
                              ))
                          .toList(),
                    ),
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}

class SelectLanguageDialog extends StatefulWidget {
  const SelectLanguageDialog({
    super.key,
  });

  @override
  State<SelectLanguageDialog> createState() => _SelectLanguageDialogState();
}

measureWidgetSize(
    {required BuildContext context,
    required List<GlobalKey> widgetKeys,
    required Function(double childHeight) setState}) {
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    double childHeight = 0;
    double boxHeight = 0;
    for (var widgetKey in widgetKeys) {
      final RenderBox? box =
          widgetKey.currentContext?.findRenderObject() as RenderBox?;
      boxHeight += box?.size.height ?? 0;
    }
    childHeight = (boxHeight) / (MediaQuery.of(context).size.height);
    await Future.delayed(kThemeAnimationDuration);
    setState(childHeight);
  });
}

class _SelectLanguageDialogState extends State<SelectLanguageDialog> {
  final GlobalKey widgetKey = GlobalKey();
  final GlobalKey handlerKey = GlobalKey();

  double childHeight = 0.000001;

  @override
  void initState() {
    measureWidgetSize(
      context: context,
      setState: (height) {
        childHeight = height;
        setState(() {});
      },
      widgetKeys: [widgetKey, handlerKey],
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DraggableScrollableSheet(
        expand: false,
        // controller: controller,
        snap: true,
        initialChildSize: childHeight.clamp(0.1, .9),
        minChildSize: (childHeight - .2).clamp(0.0000000001, .9),
        maxChildSize: childHeight.clamp(0.1, .9),
        builder: (context, scrollController) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.colorScheme.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DragHandler(key: handlerKey),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Section(
                      key: widgetKey,
                      label: 'Select Language'.tr(),
                      child: (gap) => Column(
                        children: context.supportedLocales
                            .map((e) => Column(
                                  children: [
                                    ListTile(
                                      onTap: () {
                                        context.setLocale(e);
                                        router.pop();
                                        Fluttertoast.cancel();
                                        Fluttertoast.showToast(
                                          msg: 'Language switched'.tr(),
                                        );
                                      },
                                      title: Text(e.languageName),
                                    ),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BibleReminderDialog extends StatefulWidget {
  const BibleReminderDialog({
    super.key,
    required this.weekdays,
    required this.settingCubit,
  });

  final List<int> weekdays;
  final SettingsCubit settingCubit;

  @override
  State<BibleReminderDialog> createState() => _BibleReminderDialogState();
}

class _BibleReminderDialogState extends State<BibleReminderDialog> {
  late Map<int, DateTime> data =
      Map<int, DateTime>.from(widget.settingCubit.state.bibleReminders);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: widget.settingCubit,
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text('Bible Reminder'),
        ),
        body: Container(
          color: context.colorScheme.background,
          child: ListView.builder(
            itemCount: widget.weekdays.length,
            itemBuilder: (context, index) {
              var item = widget.weekdays[index];
              return ListTile(
                onTap: () async {
                  if (data[item] != null) {
                    if (await context.showConfirmation(
                        'This will destroy the schedule. Tap Yes to destroy'
                            .tr())) {
                      data.remove(item);
                      setState(() {});
                      return;
                    }
                  }
                  // ignore: use_build_context_synchronously
                  var time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(
                      data[item] ?? DateTime.now(),
                    ),
                  );
                  if (time != null) {
                    /// kenapa 2023,05,01?
                    /// karena pada tanggal itu hari senin adalah tanggal 1
                    /// biar memudahkan aja, soalnya weekday di flutter itu senin = 1
                    data[item] = DateTime(2023, 5, 1).copyWith(
                      day: item,
                      hour: time.hour,
                      minute: time.minute,
                      second: 00,
                    );
                    setState(() {});
                  }
                },
                title: Text(widget.weekdays[index].toWeekdayName.tr()),
                trailing: Text(
                  widget.settingCubit.getTimeByWeekday(item, data),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: Container(
          color: context.colorScheme.background,
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              widget.settingCubit
                  .setBibleReminderDailyNotification(data)
                  .then((value) => Navigator.pop(context));
            },
            child: Text(
              'Set'.tr(),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../components/widgets/drag_handler.dart';
import '../../../components/widgets/section.dart';
import '../../../data/data.dart';
import '../../../data/utilities/functions/measurewidgetsize.dart';
import '../../../domain/domain.dart';
import '../../../router/router.dart';
import '../../presentations.dart';

@RoutePage()
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) => Scaffold(
        body: Column(
          children: [
            BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ).add(EdgeInsets.only(top: context.mediaQuery.padding.top)),
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
                                Fluttertoast.showToast(msg: 'BERHASIL LOGIN!');
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
                        child: Text(
                            (state.idToken == null ? 'Login' : 'Logout').tr())),
                  ],
                ),
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  BlocBuilder<BibleCubit, BibleState>(
                    builder: (context, state) => Section(
                      label: 'Verse'.tr(),
                      child: (gap) => Material(
                        child: Column(
                          children: [
                            {
                              'label': '📖 ${'Version'.tr()}',
                              'desc': 'bible_version_desc'.tr(),
                              'onTap': null,
                              'trailing': Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () {
                                      router.push(BibleVersionRoute(
                                        dashboardCubit: context.read(),
                                      ));
                                    },
                                    icon: Icon(Icons.settings),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  ElevatedButton(
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
                                          .map((e) =>
                                              e.split('.').first.toUpperCase())
                                          .toList();
                                      await showModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        isScrollControlled: true,
                                        useSafeArea: true,
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
                                        (state.currentBibleCode.split('_').last)
                                            .toUpperCase()),
                                  ),
                                ],
                              )
                            },
                            {
                              'label': '📅 ${'Today Reading'.tr()}',
                              'desc': 'today_reading_desc'.tr(),
                              'onTap': null,
                              'trailing': ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () {
                                  router.push(BibleListRoute(
                                    bibleCode: state.currentBibleCode,
                                    textScale: state.defaultTextScale,
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
                              'label': '🕰️ ${'Bible Reminder'.tr()}',
                              'desc': 'bible_reminder_desc'.tr(),
                              'onTap': null,
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
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    isScrollControlled: true,
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
                            {
                              'label': '🎧 ${'Audio Bible Config'.tr()}',
                              'desc': 'audio_bible_desc'.tr(),
                              'onTap': () {
                                router.push(
                                  BibleAudioSettingRoute(
                                    onSave: (voices, pitch, speed) {
                                      context
                                          .read<BibleCubit>()
                                          .applyTtsSetting(
                                              voices, pitch, speed);
                                    },
                                    initialPitchRate: context
                                        .read<BibleCubit>()
                                        .state
                                        .pitchRate,
                                    initialSpeedRate: context
                                        .read<BibleCubit>()
                                        .state
                                        .speedRate,
                                    initialVoices:
                                        context.read<BibleCubit>().state.voices,
                                  ),
                                );
                              },
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
                  ),
                  Section(
                    label: 'Notification'.tr(),
                    child: (gap) => Material(
                      child: Column(
                        children: [
                          {
                            'label': '🔔 ${'Sabat Notification'.tr()}',
                            'desc': state.isSabatNotificationActive
                                ? 'sabat_notification_enabled_desc'.tr()
                                : 'sabat_notification_disabled_desc'.tr(),
                            'onTap': null,
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
                                (state.isSabatNotificationActive ? 'On' : 'Off')
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
                  ),
                  Section(
                    label: 'Others'.tr(),
                    child: (gap) => Material(
                      child: Column(
                        children: [
                          {
                            'label': '🎨 ${'Theme'.tr()}',
                            'desc': 'theme_desc'.tr(),
                            'onTap': null,
                            'trailing': ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () {
                                context.read<InitialCubit>().toggleTheme(
                                      context.theme.brightness ==
                                              Brightness.light
                                          ? ThemeMode.dark
                                          : ThemeMode.light,
                                      () => context,
                                    );
                              },
                              child: Text(context
                                  .read<InitialCubit>()
                                  .state
                                  .themeMode
                                  .capitalize()
                                  .tr()),
                            ),
                          },
                          {
                            'label': '🌐 ${'Language'.tr()}',
                            'desc': 'language_desc'.tr(),
                            'onTap': null,
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
                                  builder: (c) => BlocProvider.value(
                                      value: context.read<BibleCubit>(),
                                      child: SelectLanguageDialog()),
                                );
                              },
                              child: Text(context.locale.languageName),
                            ),
                          },
                          {
                            'label': '💾 ${'Backup'.tr()}',
                            'desc': 'backup_desc'.tr(),
                            'onTap': () {
                              router.push(
                                BackupRoute(
                                  onSynced: (data) {
                                    if (data.bibleState != null) {
                                      context
                                          .read<BibleCubit>()
                                          .sync(data.bibleState!);
                                    }
                                    if (data.songState != null) {
                                      context
                                          .read<SongCubit>()
                                          .sync(data.songState!);
                                    }
                                    if (data.faithState != null) {
                                      context
                                          .read<FaithCubit>()
                                          .sync(data.faithState!);
                                    }
                                    if (data.settingsState != null) {
                                      context
                                          .read<SettingsCubit>()
                                          .sync(data.settingsState!);
                                    }

                                    Fluttertoast.cancel();
                                    Fluttertoast.showToast(
                                        msg: 'Sync success'.tr());
                                  },
                                  data: AppBackupData(
                                    bibleState:
                                        context.read<BibleCubit>().state,
                                    faithState:
                                        context.read<FaithCubit>().state,
                                    settingsState:
                                        context.read<SettingsCubit>().state,
                                    songState: context.read<SongCubit>().state,
                                  ),
                                ),
                              );
                            },
                          },
                          {
                            'label': '📢 ${'Report'.tr()}',
                            'desc': 'report_desc'.tr(),
                            'onTap': () {
                              router.push(ReportRoute(
                                account: context
                                    .read<DashboardCubit>()
                                    .state
                                    .account,
                                onLoggedIn: (token) async {
                                  await context
                                      .read<DashboardCubit>()
                                      .loginSuccessCallback(token);
                                  router.pop();
                                  Fluttertoast.cancel();
                                  Fluttertoast.showToast(
                                      msg: 'BERHASIL LOGIN!');
                                  // ignore: use_build_context_synchronously
                                  return context
                                      .read<DashboardCubit>()
                                      .state
                                      .account;
                                },
                              ));
                            },
                          },
                          {
                            'label': '🔤 ${'Font Settings'.tr()}',
                            'desc': 'font_desc'.tr(),
                            'onTap': () {
                              router.push(FontSettingRoute());
                            },
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
                  )
                ],
              ),
            ))
          ],
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

class _SelectLanguageDialogState extends State<SelectLanguageDialog> {
  final GlobalKey widgetKey = GlobalKey();
  final GlobalKey handlerKey = GlobalKey();

  double childHeight = 0.000001;

  @override
  void initState() {
    measureWidgetSize(
      context,
      callback: (height) {
        childHeight = height;
        setState(() {});
      },
      keys: [widgetKey, handlerKey],
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
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
              top: Radius.circular(12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DragHandler(key: handlerKey),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  // padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Section(
                    key: widgetKey,
                    label: 'Select Language'.tr(),
                    child: (gap) => Column(
                      children: [
                        ...context.supportedLocales
                            .map((e) => Material(
                                  color: Colors.transparent,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        onTap: () async {
                                          await context
                                              .setLocale(e)
                                              .then((value) {
                                            timeago.LookupMessages message =
                                                timeago.EnShortMessages();
                                            switch (e.languageCode) {
                                              case 'id':
                                                message =
                                                    timeago.IdShortMessages();
                                                break;
                                              case 'zh':
                                                message =
                                                    timeago.ZhCnMessages();
                                                break;
                                              default:
                                            }
                                            timeago.setLocaleMessages(
                                                e.languageCode, message);
                                            router.pop();
                                            Fluttertoast.cancel();
                                            Fluttertoast.showToast(
                                              msg: 'Language switched'.tr(),
                                            );
                                          });
                                        },
                                        title: Row(
                                          children: [
                                            Image.asset(
                                                'assets/images/${e.languageCode}_flag.png',
                                                width: 20,
                                                fit: BoxFit.cover,
                                                height: 14),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(e.languageName),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        // SizedBox(height: 24),
                      ],
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
  double childHeight = 0.00001;
  final GlobalKey widgetKey = GlobalKey();
  final GlobalKey handlerKey = GlobalKey();

  @override
  void initState() {
    measureWidgetSize(
      context,
      keys: [widgetKey, handlerKey],
      callback: (h) {
        childHeight = h;
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: widget.settingCubit,
      builder: (context, state) => DraggableScrollableSheet(
        initialChildSize: childHeight.clamp(0.00001, 1),
        maxChildSize: childHeight.clamp(0.00001, 1),
        minChildSize: (childHeight - .1).clamp(0.00001, 1),
        expand: false,
        snap: true,
        snapSizes: [childHeight],
        builder: (context, scrollController) => Material(
          color: context.colorScheme.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(children: [
              DragHandler(
                key: handlerKey,
              ),
              Section(
                key: widgetKey,
                label: 'Bible Reminder'.tr(),
                child: (gap) => SafeArea(
                  child: Column(
                    children: [
                      ...List.generate(widget.weekdays.length, (index) {
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
                          title: Text(
                            widget.weekdays[index].toWeekdayName.tr(),
                            style: TextStyle(
                              fontWeight: data[item] != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: Container(
                            padding: data[item] == null
                                ? null
                                : EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: data[item] != null
                                  ? context.colorScheme.primary
                                  : null,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (data[item] != null)
                                  Icon(Icons.notifications,
                                      size: 14, color: Colors.white),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  widget.settingCubit.getTimeByWeekday(
                                    item,
                                    data,
                                  ),
                                  style: TextStyle(
                                    color: data[item] != null
                                        ? Colors.white
                                        : context.theme.disabledColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      Container(
                        width: double.infinity,
                        color: context.colorScheme.background,
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colorScheme.primary,
                            foregroundColor: context.colorScheme.onPrimary,
                            minimumSize: Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            widget.settingCubit
                                .setBibleReminderDailyNotification(data)
                                .then((value) => Navigator.pop(context));
                          },
                          child: Text(
                            'Set Reminder'.tr(),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../data/utilities/firebase_utils.dart';
import '../../../data/utilities/platform_utils.dart';
import '../../../router/router.dart';
import 'settings_state.dart';

export 'settings_state.dart';

class SettingsCubit extends HydratedCubit<SettingsState> {
  SettingsCubit() : super(const SettingsState()) {
    if (isNotificationConfiguredForCurrentPlatform) {
      toggleSabatNotification(state.isSabatNotificationActive, true);
    }
  }

  Future<void> toggleSabatNotification([
    bool? value,
    bool isInit = false,
  ]) async {
    if (!isNotificationConfiguredForCurrentPlatform) {
      emit(state.copyWith(isSabatNotificationActive: false));
      return;
    }
    if (!(await AwesomeNotifications().isNotificationAllowed())) {
      var res = await AwesomeNotifications()
          .requestPermissionToSendNotifications();
      if (!res) return;
    }
    var data = value ?? !state.isSabatNotificationActive;
    var json = await FirebaseUtils.jsonConfig('notifikasi_sabat');
    if (data) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 31111,
          channelKey: 'gys',
          title: json['title'],
          body: json['body'],
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture: json['imageUrl'],
        ),
        schedule: NotificationCalendar(
          repeats: true,
          allowWhileIdle: true,
          weekday: DateTime.friday,
          hour: 17,
          minute: 0,
          second: 00,
        ),
      );
      if (!isInit) {
        // Fluttertoast.cancel();
        // Fluttertoast.showToast(msg: 'Sabat notification enabled'.tr());
      }
    } else {
      await AwesomeNotifications().cancel(31111);
      if (!isInit) {
        // Fluttertoast.cancel();
        // Fluttertoast.showToast(msg: 'Sabat notification disabled'.tr());
      }
    }
    emit(
      state.copyWith(
        isSabatNotificationActive: value ?? !state.isSabatNotificationActive,
      ),
    );
  }

  void sync(SettingsState settingsState) {
    emit(settingsState);
  }

  Future setBibleReminderDailyNotification(Map<int, DateTime> days) async {
    if (!isNotificationConfiguredForCurrentPlatform) {
      emit(
        state.copyWith(
          isBibleReminderNotificationActive: false,
          bibleReminders: {},
        ),
      );
      return;
    }
    if (!(await AwesomeNotifications().isNotificationAllowed())) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    List<int> weekdays = List.generate(7, (index) => index + 1);

    List<int> unactiveDays = weekdays
        .toSet()
        .difference(days.keys.toSet())
        .toList();
    var json = await FirebaseUtils.jsonConfig('notifikasi_bible');
    var lang = router.navigatorKey.currentContext?.locale.languageCode ?? '';
    for (int weekDay in days.keys) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 321000 + weekDay,
          channelKey: 'gys',
          title: json['title'][lang],
          body: json['body'][lang],
          bigPicture: json['imageUrl'],
          notificationLayout: NotificationLayout.BigPicture,
        ),
        schedule: NotificationCalendar(
          repeats: true,
          allowWhileIdle: true,
          weekday: weekDay,
          hour: days[weekDay]!.hour,
          minute: days[weekDay]!.minute,
          second: days[weekDay]!.second,
        ),
      );
    }
    await Future.delayed(Duration(milliseconds: 200));
    for (int weekDay in unactiveDays) {
      await AwesomeNotifications().cancel(321000 + weekDay);
    }

    emit(
      state.copyWith(
        isBibleReminderNotificationActive: days.isNotEmpty,
        bibleReminders: days,
      ),
    );
  }

  String getTimeByWeekday(int weekday, [Map<int, DateTime>? days]) {
    var data = days != null ? days[weekday] : state.bibleReminders[weekday];
    if (data != null) {
      return DateFormat('HH:mm').format(data);
    } else {
      return 'Not active'.tr();
    }
  }

  DateTime? getNotificationByWeekday(int weekday, [Map<int, DateTime>? days]) {
    return days != null ? days[weekday] : state.bibleReminders[weekday];
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    return SettingsState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return state.toJson();
  }
}

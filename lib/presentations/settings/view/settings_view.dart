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
import '../../../data/models/theme_preferences.dart';
import '../../../domain/domain.dart';
import '../../../router/router.dart';
import '../../presentations.dart';

const double _settingsMaxContentWidth = 1080;

List<String> settingsSoundFontMenuValues({
  required List<String>? availableSoundFonts,
  required String selectedSoundFont,
}) {
  final values = <String>[];
  void addValue(String value) {
    if (value.isNotEmpty && !values.contains(value)) {
      values.add(value);
    }
  }

  addValue(selectedSoundFont);
  for (final soundFont in availableSoundFonts ?? const ['TimGM6mb.sf2']) {
    addValue(soundFont);
  }
  return values;
}

@RoutePage()
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) => Scaffold(
        backgroundColor: context.colorScheme.surface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: context.colorScheme.surface.withValues(alpha: 0.88),
          toolbarHeight: 74,
          leading: IconButton(
            tooltip: 'Menu',
            onPressed: openDashboardDrawer,
            icon: const Icon(Icons.tune_rounded),
          ),
          title: const Text('Workspace Settings'),
          centerTitle: true,
          actions: const [SizedBox(width: 48)],
        ),
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.2,
                ),
                context.colorScheme.surfaceContainerLow.withValues(alpha: 0.34),
                context.colorScheme.surface,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: _settingsMaxContentWidth,
                ),
                child: Column(
                  children: [
                    const _SettingsHeader(),
                    BlocBuilder<DashboardCubit, DashboardState>(
                      builder: (context, state) => Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.84),
                              context.colorScheme.surfaceContainerLow
                                  .withValues(alpha: 0.84),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.colorScheme.outlineVariant
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxWidth < 560;
                            final profileSection = Expanded(
                              child: state.idToken == null
                                  ? Text(
                                      'register_button_text'.tr(),
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.account?.name ?? 'Unknown'.tr(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.textTheme.headlineSmall
                                              ?.copyWith(fontSize: 20),
                                        ),
                                        Text(
                                          state.account?.email ??
                                              'Unknown'.tr(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.textTheme.bodySmall
                                              ?.copyWith(
                                                color: context
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                            );
                            final authButton = ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: state.idToken == null
                                    ? context.colorScheme.primary
                                    : context.colorScheme.errorContainer,
                                foregroundColor: state.idToken == null
                                    ? context.colorScheme.onPrimary
                                    : context.colorScheme.onErrorContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                if (context
                                        .read<DashboardCubit>()
                                        .state
                                        .idToken ==
                                    null) {
                                  router.push(
                                    LoginRoute(
                                      onLoggedIn: (token) {
                                        router.maybePop();
                                        context
                                            .read<DashboardCubit>()
                                            .loginSuccessCallback(token);
                                        Fluttertoast.cancel();
                                        Fluttertoast.showToast(
                                          msg: 'BERHASIL LOGIN!',
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  final yes = await context.showConfirmation(
                                    'Are you sure want to logout?'.tr(),
                                  );
                                  if (!context.mounted || !yes) {
                                    return;
                                  }
                                  context
                                      .read<DashboardCubit>()
                                      .loginSuccessCallback(null);
                                }
                              },
                              child: Text(
                                (state.idToken == null ? 'Login' : 'Logout')
                                    .tr(),
                              ),
                            );
                            final avatar = Container(
                              width: 58,
                              height: 58,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.colorScheme.outlineVariant,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: state.idToken == null
                                    ? Image.asset(Assets.assetsImagesAppicon)
                                    : CachedNetworkImage(
                                        imageUrl:
                                            state.account?.profilePicture ?? '',
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                              Assets.assetsImagesAppicon,
                                            ),
                                      ),
                              ),
                            );

                            if (compact) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      avatar,
                                      const SizedBox(width: 16),
                                      profileSection,
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: authButton,
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                avatar,
                                const SizedBox(width: 16),
                                profileSection,
                                const SizedBox(width: 12),
                                authButton,
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const _AssetDistributionSection(),
                    Column(
                      children: [
                        BlocBuilder<BibleCubit, BibleState>(
                          builder: (context, state) => Section(
                            label: 'Verse'.tr(),
                            child: (gap) => Material(
                              color: context.colorScheme.surfaceContainerLowest,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: context.colorScheme.outlineVariant
                                      .withValues(alpha: 0.55),
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children:
                                    [
                                          {
                                            'icon': Icons.menu_book_outlined,
                                            'label': 'Version'.tr(),
                                            'desc': 'bible_version_desc'.tr(),
                                            'onTap': null,
                                            'trailing': Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  onPressed: () {
                                                    router.push(
                                                      BibleVersionRoute(
                                                        dashboardCubit: context
                                                            .read(),
                                                      ),
                                                    );
                                                  },
                                                  icon: Icon(Icons.settings),
                                                ),
                                                SizedBox(width: 4),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                      ),
                                                  onPressed: () async {
                                                    log('onTapSelectBible');
                                                    await context
                                                        .read<BibleCubit>()
                                                        .getBibles();
                                                    if (!context.mounted) {
                                                      return;
                                                    }
                                                    final state = context
                                                        .read<BibleCubit>()
                                                        .state;
                                                    var bibleCodes = state
                                                        .bibleCodes
                                                        .map(
                                                          (e) => e
                                                              .split('.')
                                                              .first,
                                                        )
                                                        .toList();
                                                    if (bibleCodes.isEmpty) {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            'No Bible versions available'
                                                                .tr(),
                                                      );
                                                      return;
                                                    }
                                                    var currentIndex =
                                                        bibleCodes.indexOf(
                                                          state
                                                              .currentBibleCode,
                                                        );
                                                    if (currentIndex < 0) {
                                                      currentIndex = 0;
                                                    }
                                                    await showModalBottomSheet(
                                                      context: context,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      isScrollControlled: true,
                                                      useSafeArea: true,
                                                      builder: (ctx) =>
                                                          BibleSelectWidget(
                                                            bibleCodes:
                                                                bibleCodes,
                                                            initialIndex:
                                                                currentIndex,
                                                            onTap: (index) async {
                                                              await context
                                                                  .read<
                                                                    BibleCubit
                                                                  >()
                                                                  .selectBibleCode(
                                                                    index,
                                                                  );
                                                              if (!ctx
                                                                  .mounted) {
                                                                return;
                                                              }
                                                              router.maybePop();
                                                            },
                                                          ),
                                                    );
                                                  },
                                                  child: Text(
                                                    (state.currentBibleCode
                                                            .split('_')
                                                            .last)
                                                        .toUpperCase(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          },
                                          {
                                            'icon': Icons.event_note_outlined,
                                            'label': 'Today Reading'.tr(),
                                            'desc': 'today_reading_desc'.tr(),
                                            'onTap': null,
                                            'trailing': ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                              onPressed: () {
                                                router.push(
                                                  BibleListRoute(
                                                    bibleCode:
                                                        state.currentBibleCode,
                                                    textScale:
                                                        state.defaultTextScale,
                                                    onSelected: (newBible) {
                                                      context
                                                          .read<BibleCubit>()
                                                          .setTodayReading(
                                                            newBible,
                                                          );
                                                      router.maybePop();
                                                    },
                                                    getBibles:
                                                        (
                                                          bookId,
                                                          chapterId,
                                                        ) async {
                                                          if (bookId == null ||
                                                              chapterId ==
                                                                  null) {
                                                            return [];
                                                          }
                                                          return await context
                                                              .read<
                                                                BibleCubit
                                                              >()
                                                              .getVersesByBook(
                                                                bookId,
                                                                chapterId,
                                                              );
                                                        },
                                                    books: state.books,
                                                  ),
                                                );
                                              },
                                              child: FutureBuilder<String>(
                                                future: context
                                                    .read<BibleCubit>()
                                                    .getBibleTitle([
                                                      state.todayReading,
                                                    ]),
                                                builder: (context, snapshot) =>
                                                    Text(
                                                      snapshot.data ??
                                                          'None'.tr(),
                                                    ),
                                              ),
                                            ),
                                          },
                                          {
                                            'icon': Icons.schedule_outlined,
                                            'label': 'Bible Reminder'.tr(),
                                            'desc': 'bible_reminder_desc'.tr(),
                                            'onTap': null,
                                            'trailing': ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                              onPressed: () async {
                                                var settingCubit = context
                                                    .read<SettingsCubit>();

                                                var weekdays = List.generate(
                                                  7,
                                                  (index) => index + 1,
                                                );
                                                await showModalBottomSheet(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  elevation: 0,
                                                  isScrollControlled: true,
                                                  context: context,
                                                  builder: (context) {
                                                    return BibleReminderDialog(
                                                      weekdays: weekdays,
                                                      settingCubit:
                                                          settingCubit,
                                                    );
                                                  },
                                                );
                                              },
                                              child: Text(
                                                (context
                                                            .watch<
                                                              SettingsCubit
                                                            >()
                                                            .state
                                                            .isBibleReminderNotificationActive
                                                        ? 'On'
                                                        : 'Off')
                                                    .tr(),
                                              ),
                                            ),
                                          },
                                          {
                                            'icon': Icons.headphones_outlined,
                                            'label': 'Audio Bible Config'.tr(),
                                            'desc': 'audio_bible_desc'.tr(),
                                            'onTap': () {
                                              router.push(
                                                BibleAudioSettingRoute(
                                                  onSave:
                                                      (voices, pitch, speed) {
                                                        context
                                                            .read<BibleCubit>()
                                                            .applyTtsSetting(
                                                              voices,
                                                              pitch,
                                                              speed,
                                                            );
                                                      },
                                                  initialPitchRate: context
                                                      .read<BibleCubit>()
                                                      .state
                                                      .pitchRate,
                                                  initialSpeedRate: context
                                                      .read<BibleCubit>()
                                                      .state
                                                      .speedRate,
                                                  initialVoices: context
                                                      .read<BibleCubit>()
                                                      .state
                                                      .voices,
                                                ),
                                              );
                                            },
                                          },
                                        ]
                                        .map(
                                          (e) => _SettingsTile(
                                            icon: e['icon'] as IconData,
                                            title: e['label'] as String,
                                            description: e['desc'] as String?,
                                            trailing: e['trailing'] as Widget?,
                                            onTap: e['onTap'] as VoidCallback?,
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                          ),
                        ),
                        const _SongSettingsSection(),
                        Section(
                          label: 'Notification'.tr(),
                          child: (gap) => Material(
                            color: context.colorScheme.surfaceContainerLowest,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: context.colorScheme.outlineVariant
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children:
                                  [
                                        {
                                          'icon': Icons
                                              .notifications_active_outlined,
                                          'label': 'Sabat Notification'.tr(),
                                          'desc':
                                              state.isSabatNotificationActive
                                              ? 'sabat_notification_enabled_desc'
                                                    .tr()
                                              : 'sabat_notification_disabled_desc'
                                                    .tr(),
                                          'onTap': null,
                                          'trailing': ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  state
                                                      .isSabatNotificationActive
                                                  ? context
                                                        .colorScheme
                                                        .secondaryContainer
                                                  : context
                                                        .colorScheme
                                                        .errorContainer,
                                              foregroundColor:
                                                  state
                                                      .isSabatNotificationActive
                                                  ? context
                                                        .colorScheme
                                                        .onSecondaryContainer
                                                  : context
                                                        .colorScheme
                                                        .onErrorContainer,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            onPressed: () {
                                              context
                                                  .read<SettingsCubit>()
                                                  .toggleSabatNotification();
                                            },
                                            child: Text(
                                              (state.isSabatNotificationActive
                                                      ? 'On'
                                                      : 'Off')
                                                  .tr(),
                                            ),
                                          ),
                                        },
                                      ]
                                      .map(
                                        (e) => _SettingsTile(
                                          icon: e['icon'] as IconData,
                                          title: e['label'] as String,
                                          description: e['desc'] as String?,
                                          trailing: e['trailing'] as Widget?,
                                          onTap: e['onTap'] as VoidCallback?,
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ),
                        const _ThemeSettingsSection(),
                        Section(
                          label: 'Others'.tr(),
                          child: (gap) => Material(
                            color: context.colorScheme.surfaceContainerLowest,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: context.colorScheme.outlineVariant
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children:
                                  [
                                        {
                                          'icon': Icons.palette_outlined,
                                          'label': 'Theme'.tr(),
                                          'desc': 'theme_desc'.tr(),
                                          'onTap': null,
                                          'trailing': ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            onPressed: () {
                                              context
                                                  .read<InitialCubit>()
                                                  .toggleTheme(
                                                    context.theme.brightness ==
                                                            Brightness.light
                                                        ? ThemeMode.dark
                                                        : ThemeMode.light,
                                                    () => context,
                                                  );
                                            },
                                            child: Text(
                                              context
                                                  .read<InitialCubit>()
                                                  .state
                                                  .themeMode
                                                  .capitalize()
                                                  .tr(),
                                            ),
                                          ),
                                        },
                                        {
                                          'icon': Icons.language_outlined,
                                          'label': 'Language'.tr(),
                                          'desc': 'language_desc'.tr(),
                                          'onTap': null,
                                          'trailing': ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            onPressed: () async {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                elevation: 0,
                                                builder: (c) =>
                                                    BlocProvider.value(
                                                      value: context
                                                          .read<BibleCubit>(),
                                                      child:
                                                          SelectLanguageDialog(),
                                                    ),
                                              );
                                            },
                                            child: Text(
                                              context.locale.languageName,
                                            ),
                                          ),
                                        },
                                        {
                                          'icon': Icons.backup_outlined,
                                          'label': 'Backup'.tr(),
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
                                                  if (data.settingsState !=
                                                      null) {
                                                    context
                                                        .read<SettingsCubit>()
                                                        .sync(
                                                          data.settingsState!,
                                                        );
                                                  }

                                                  Fluttertoast.cancel();
                                                  Fluttertoast.showToast(
                                                    msg: 'Sync success'.tr(),
                                                  );
                                                },
                                                data: AppBackupData(
                                                  bibleState: context
                                                      .read<BibleCubit>()
                                                      .state,
                                                  faithState: context
                                                      .read<FaithCubit>()
                                                      .state,
                                                  settingsState: context
                                                      .read<SettingsCubit>()
                                                      .state,
                                                  songState: context
                                                      .read<SongCubit>()
                                                      .state,
                                                ),
                                              ),
                                            );
                                          },
                                        },
                                        {
                                          'icon': Icons.campaign_outlined,
                                          'label': 'Report'.tr(),
                                          'desc': 'report_desc'.tr(),
                                          'onTap': () {
                                            router.push(
                                              ReportRoute(
                                                account: context
                                                    .read<DashboardCubit>()
                                                    .state
                                                    .account,
                                                onLoggedIn: (token) async {
                                                  await context
                                                      .read<DashboardCubit>()
                                                      .loginSuccessCallback(
                                                        token,
                                                      );
                                                  router.maybePop();
                                                  Fluttertoast.cancel();
                                                  Fluttertoast.showToast(
                                                    msg: 'BERHASIL LOGIN!',
                                                  );
                                                  // ignore: use_build_context_synchronously
                                                  return context
                                                      .read<DashboardCubit>()
                                                      .state
                                                      .account;
                                                },
                                              ),
                                            );
                                          },
                                        },
                                        {
                                          'icon': Icons.text_fields_rounded,
                                          'label': 'Font Settings'.tr(),
                                          'desc': 'font_desc'.tr(),
                                          'onTap': () {
                                            router.push(FontSettingRoute());
                                          },
                                        },
                                      ]
                                      .map(
                                        (e) => _SettingsTile(
                                          icon: e['icon'] as IconData,
                                          title: e['label'] as String,
                                          description: e['desc'] as String?,
                                          trailing: e['trailing'] as Widget?,
                                          onTap: e['onTap'] as VoidCallback?,
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colorScheme.primaryContainer.withValues(alpha: 0.44),
              context.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.9,
              ),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.colorScheme.primary.withValues(alpha: 0.24),
          ),
        ),
        child: Column(
          children: [
            Text(
              'Kontrol Aplikasi Gereja'.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Kelola Bible, Hymnal, tampilan, sinkronisasi, pengingat, dan akun dalam satu tempat.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.description,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final compactTrailing =
        trailing != null && MediaQuery.sizeOf(context).width < 420;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: compactTrailing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer.withValues(
                              alpha: 0.6,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.32),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(icon, size: 20, color: colors.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _SettingsTileText(
                            title: title,
                            description: description,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerRight, child: trailing),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(icon, size: 20, color: colors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _SettingsTileText(
                        title: title,
                        description: description,
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 10),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width < 560
                              ? 120
                              : 164,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: trailing,
                        ),
                      ),
                    ] else
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SettingsTileText extends StatelessWidget {
  const _SettingsTileText({required this.title, this.description});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 3),
          Text(
            description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.25,
            ),
          ),
        ],
      ],
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: icon,
      title: title,
      description: description,
      trailing: Switch(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }
}

class _AssetDistributionSection extends StatelessWidget {
  const _AssetDistributionSection();

  @override
  Widget build(BuildContext context) {
    return Section(
      label: 'Offline Library',
      child: (gap) => Padding(
        padding: EdgeInsets.symmetric(horizontal: gap),
        child: Material(
          color: context.colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _SettingsTile(
            icon: Icons.offline_bolt_rounded,
            title: 'Offline Library',
            description:
                'Kelola Alkitab dan hymnal terenkripsi, cek rilis terbaru GitHub, hapus aset terinstal, dan bersihkan cache cepat dari satu halaman khusus.',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              router.push(
                AssetManagementRoute(
                  assetManagementCubit: context.read<AssetManagementCubit>(),
                  bibleCubit: context.read<BibleCubit>(),
                  songCubit: context.read<SongCubit>(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SongSettingsSection extends StatelessWidget {
  const _SongSettingsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongCubit, SongState>(
      builder: (context, state) {
        final songCubit = context.read<SongCubit>();
        return Section(
          label: 'Pujian',
          child: (gap) => Container(
            margin: EdgeInsets.symmetric(horizontal: gap),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.colorScheme.surfaceContainerLowest,
                  context.colorScheme.surfaceContainerLow,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.colorScheme.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Column(
                children: [
                  _SettingsSwitchTile(
                    icon: Icons.piano_outlined,
                    title: 'Tampilkan chord',
                    description: 'Default overlay chord seperti gyschordweb',
                    value: state.showChord,
                    onChanged: songCubit.toggleChord,
                  ),
                  Divider(
                    height: 1,
                    color: context.colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  _SettingsSwitchTile(
                    icon: Icons.music_note_rounded,
                    title: 'Aktifkan MIDI player',
                    description: 'Tampilkan kontrol player di halaman pujian',
                    value: state.showAudio,
                    onChanged: songCubit.toggleAudio,
                  ),
                  Divider(
                    height: 1,
                    color: context.colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.library_music_outlined,
                    title: 'SoundFont',
                    description: 'Bank suara MIDI',
                    trailing: FutureBuilder<List<String>>(
                      future: songCubit.midiEngine.getAvailableSoundFonts(),
                      builder: (context, snapshot) {
                        final soundfonts = settingsSoundFontMenuValues(
                          availableSoundFonts: snapshot.data,
                          selectedSoundFont: state.soundFont,
                        );
                        return PopupMenuButton<String>(
                          initialValue: state.soundFont,
                          onSelected: songCubit.setSoundFont,
                          itemBuilder: (context) => soundfonts
                              .map(
                                (sf) => PopupMenuItem(
                                  value: sf,
                                  child: Text(sf.replaceAll('.sf2', '')),
                                ),
                              )
                              .toList(),
                          child: Text(state.soundFont.replaceAll('.sf2', '')),
                        );
                      },
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: context.colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  _SettingsSwitchTile(
                    icon: Icons.bolt_outlined,
                    title: 'Cache Ahead MIDI',
                    description: 'Render lagu berikutnya di latar belakang',
                    value: state.midiPreloadEnabled,
                    onChanged: songCubit.toggleWarmUp,
                  ),
                  if (state.midiPreloadEnabled)
                    Divider(
                      height: 1,
                      color: context.colorScheme.outlineVariant.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  if (state.midiPreloadEnabled)
                    _SettingsTile(
                      icon: Icons.queue_music_outlined,
                      title: 'Jumlah lagu di-cache',
                      description: 'Batas cache MIDI engine',
                      trailing: PopupMenuButton<int>(
                        initialValue: state.midiCacheMaxCount,
                        onSelected: songCubit.setMidiCacheMaxCount,
                        itemBuilder: (context) => [4, 8, 12, 16, 20, 24, 32]
                            .map(
                              (v) => PopupMenuItem(
                                value: v,
                                child: Text('$v lagu'),
                              ),
                            )
                            .toList(),
                        child: Text('${state.midiCacheMaxCount} lagu'),
                      ),
                    ),
                  if (state.midiPreloadEnabled)
                    Divider(
                      height: 1,
                      color: context.colorScheme.outlineVariant.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  if (state.midiPreloadEnabled)
                    _SettingsTile(
                      icon: Icons.cached_outlined,
                      title: 'Preload tetangga',
                      description:
                          'Berapa lagu di sekitar yang di-render lebih awal',
                      trailing: PopupMenuButton<int>(
                        initialValue: state.midiPreloadNeighborCount,
                        onSelected: songCubit.setMidiPreloadNeighborCount,
                        itemBuilder: (context) => [0, 1, 2, 3, 4, 5]
                            .map(
                              (v) => PopupMenuItem(
                                value: v,
                                child: Text(v == 0 ? 'Mati' : '$v lagu'),
                              ),
                            )
                            .toList(),
                        child: Text(
                          state.midiPreloadNeighborCount == 0
                              ? 'Mati'
                              : '${state.midiPreloadNeighborCount} lagu',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ThemeSettingsSection extends StatelessWidget {
  const _ThemeSettingsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InitialCubit, InitialState>(
      builder: (context, state) {
        return Section(
          label: 'Theme',
          child: (gap) => Padding(
            padding: EdgeInsets.symmetric(horizontal: gap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _AccentColorPicker(
                  selectedKey: state.accentKey,
                  onSelected: (key) {
                    context.read<InitialCubit>().changeAccentColor(key);
                  },
                ),
                const SizedBox(height: 24),
                _DensitySelector(
                  selected: state.themePreferences.density,
                  onChanged: (density) {
                    context.read<InitialCubit>().changeDensity(density);
                  },
                ),
                const SizedBox(height: 16),
                _CornerRadiusSelector(
                  selected: state.themePreferences.cornerRadius,
                  onChanged: (style) {
                    context.read<InitialCubit>().changeCornerRadius(style);
                  },
                ),
                const SizedBox(height: 16),
                _TypographyScaleSelector(
                  selected: state.themePreferences.typographyScale,
                  onChanged: (scale) {
                    context.read<InitialCubit>().changeTypographyScale(scale);
                  },
                ),
                const SizedBox(height: 24),
                _ThemePreviewCard(
                  accentKey: state.accentKey,
                  cornerRadius: state.themePreferences.cornerRadius,
                  typographyScale: state.themePreferences.typographyScale,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AccentColorPicker extends StatelessWidget {
  final String selectedKey;
  final ValueChanged<String> onSelected;

  const _AccentColorPicker({
    required this.selectedKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      ('skyBlue', 'Sky Blue', const Color(0xFF3B82F6), const Color(0xFFDBEAFE)),
      ('mintGreen', 'Mint', const Color(0xFF10B981), const Color(0xFFD1FAF5)),
      ('softLavender', 'Lavender', const Color(0xFF8B5CF6), const Color(0xFFF3E8FF)),
      ('warmPeach', 'Peach', const Color(0xFFF97316), const Color(0xFFFFEDD5)),
      ('dustyRose', 'Rose', const Color(0xFFF43F5E), const Color(0xFFFFE4E6)),
      ('softTeal', 'Teal', const Color(0xFF14B8A6), const Color(0xFFCCFBF1)),
      ('softIndigo', 'Indigo', const Color(0xFF6366F1), const Color(0xFFE0E7FF)),
      ('softAmber', 'Amber', const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accent Color',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((c) {
            final isSelected = c.$1 == selectedKey;
            return GestureDetector(
              onTap: () => onSelected(c.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: c.$4,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: c.$3, width: 2)
                      : Border.all(color: c.$3.withValues(alpha: 0.3)),
                ),
                child: isSelected
                    ? Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: c.$3,
                          size: 24,
                        ),
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DensitySelector extends StatelessWidget {
  final DisplayDensity selected;
  final ValueChanged<DisplayDensity> onChanged;

  const _DensitySelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Display Density',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<DisplayDensity>(
          segments: const [
            ButtonSegment(
              value: DisplayDensity.compact,
              label: Text('Compact'),
            ),
            ButtonSegment(
              value: DisplayDensity.standard,
              label: Text('Standard'),
            ),
            ButtonSegment(
              value: DisplayDensity.comfortable,
              label: Text('Comfortable'),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (set) => onChanged(set.first),
        ),
      ],
    );
  }
}

class _CornerRadiusSelector extends StatelessWidget {
  final CornerRadiusStyle selected;
  final ValueChanged<CornerRadiusStyle> onChanged;

  const _CornerRadiusSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Corner Radius',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<CornerRadiusStyle>(
          segments: const [
            ButtonSegment(
              value: CornerRadiusStyle.soft,
              label: Text('Soft'),
            ),
            ButtonSegment(
              value: CornerRadiusStyle.medium,
              label: Text('Medium'),
            ),
            ButtonSegment(
              value: CornerRadiusStyle.sharp,
              label: Text('Sharp'),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (set) => onChanged(set.first),
        ),
      ],
    );
  }
}

class _TypographyScaleSelector extends StatelessWidget {
  final TypographyScale selected;
  final ValueChanged<TypographyScale> onChanged;

  const _TypographyScaleSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Typography Scale',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<TypographyScale>(
          segments: const [
            ButtonSegment(
              value: TypographyScale.compact,
              label: Text('Compact'),
            ),
            ButtonSegment(
              value: TypographyScale.normal,
              label: Text('Normal'),
            ),
            ButtonSegment(
              value: TypographyScale.comfortable,
              label: Text('Comfortable'),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (set) => onChanged(set.first),
        ),
      ],
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  final String accentKey;
  final CornerRadiusStyle cornerRadius;
  final TypographyScale typographyScale;

  const _ThemePreviewCard({
    required this.accentKey,
    required this.cornerRadius,
    required this.typographyScale,
  });

  Color _getSeedColor() {
    switch (accentKey) {
      case 'skyBlue': return const Color(0xFF3B82F6);
      case 'mintGreen': return const Color(0xFF10B981);
      case 'softLavender': return const Color(0xFF8B5CF6);
      case 'warmPeach': return const Color(0xFFF97316);
      case 'dustyRose': return const Color(0xFFF43F5E);
      case 'softTeal': return const Color(0xFF14B8A6);
      case 'softIndigo': return const Color(0xFF6366F1);
      case 'softAmber': return const Color(0xFFF59E0B);
      default: return const Color(0xFF3B82F6);
    }
  }

  Color _getContainerColor() {
    switch (accentKey) {
      case 'skyBlue': return const Color(0xFFDBEAFE);
      case 'mintGreen': return const Color(0xFFD1FAF5);
      case 'softLavender': return const Color(0xFFF3E8FF);
      case 'warmPeach': return const Color(0xFFFFEDD5);
      case 'dustyRose': return const Color(0xFFFFE4E6);
      case 'softTeal': return const Color(0xFFCCFBF1);
      case 'softIndigo': return const Color(0xFFE0E7FF);
      case 'softAmber': return const Color(0xFFFEF3C7);
      default: return const Color(0xFFDBEAFE);
    }
  }

  double _getRadius() {
    switch (cornerRadius) {
      case CornerRadiusStyle.soft: return 16;
      case CornerRadiusStyle.medium: return 12;
      case CornerRadiusStyle.sharp: return 4;
    }
  }

  double _getScale() {
    switch (typographyScale) {
      case TypographyScale.compact: return 0.9;
      case TypographyScale.normal: return 1.0;
      case TypographyScale.comfortable: return 1.1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final seed = _getSeedColor();
    final container = _getContainerColor();
    final radius = _getRadius();
    final scale = _getScale();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: container, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PREVIEW',
            style: TextStyle(
              fontSize: 10 * scale,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sample Heading',
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              color: seed,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is sample body text showing the current theme settings.',
            style: TextStyle(
              fontSize: 14 * scale,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 6 * scale,
                ),
                decoration: BoxDecoration(
                  color: container,
                  borderRadius: BorderRadius.circular(radius * 0.5),
                ),
                child: Text(
                  'Sample Chip',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    color: seed,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 8 * scale,
                ),
                decoration: BoxDecoration(
                  color: seed,
                  borderRadius: BorderRadius.circular(radius * 0.5),
                ),
                child: Text(
                  'Button',
                  style: TextStyle(
                    fontSize: 13 * scale,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SelectLanguageDialog extends StatefulWidget {
  const SelectLanguageDialog({super.key});

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
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.colorScheme.surfaceContainerLowest,
                context.colorScheme.surface,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
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
                        ...context.supportedLocales.map(
                          (e) => Material(
                            color: Colors.transparent,
                            child: Column(
                              children: [
                                ListTile(
                                  tileColor:
                                      context.colorScheme.surfaceContainerLow,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: context.colorScheme.outlineVariant
                                          .withValues(alpha: 0.46),
                                    ),
                                  ),
                                  onTap: () async {
                                    await context.setLocale(e).then((value) {
                                      timeago.LookupMessages message =
                                          timeago.EnShortMessages();
                                      switch (e.languageCode) {
                                        case 'id':
                                          message = timeago.IdShortMessages();
                                          break;
                                        case 'zh':
                                          message = timeago.ZhCnMessages();
                                          break;
                                        default:
                                      }
                                      timeago.setLocaleMessages(
                                        e.languageCode,
                                        message,
                                      );
                                      router.maybePop();
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
                                        height: 14,
                                      ),
                                      SizedBox(width: 8),
                                      Text(e.languageName),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
  late Map<int, DateTime> data = Map<int, DateTime>.from(
    widget.settingCubit.state.bibleReminders,
  );
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
          color: context.colorScheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                DragHandler(key: handlerKey),
                Section(
                  key: widgetKey,
                  label: 'Bible Reminder'.tr(),
                  child: (gap) => SafeArea(
                    child: Column(
                      children: [
                        ...List.generate(widget.weekdays.length, (index) {
                          var item = widget.weekdays[index];
                          return Container(
                            margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                            decoration: BoxDecoration(
                              color: context.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.colorScheme.outlineVariant
                                    .withValues(alpha: 0.46),
                              ),
                            ),
                            child: ListTile(
                              onTap: () async {
                                if (data[item] != null) {
                                  if (await context.showConfirmation(
                                    'This will destroy the schedule. Tap Yes to destroy'
                                        .tr(),
                                  )) {
                                    data.remove(item);
                                    setState(() {});
                                    return;
                                  }
                                }
                                if (!context.mounted) {
                                  return;
                                }
                                var time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                    data[item] ?? DateTime.now(),
                                  ),
                                );
                                if (time != null) {
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
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                decoration: BoxDecoration(
                                  color: data[item] != null
                                      ? context.colorScheme.primary
                                      : null,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (data[item] != null)
                                      Icon(
                                        Icons.notifications,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    SizedBox(width: 8),
                                    Text(
                                      widget.settingCubit.getTimeByWeekday(
                                        item,
                                        data,
                                      ),
                                      style: TextStyle(
                                        color: data[item] != null
                                            ? Colors.white
                                            : context
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        Container(
                          width: double.infinity,
                          color: context.colorScheme.surface,
                          padding: const EdgeInsets.all(16),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colorScheme.primary,
                              foregroundColor: context.colorScheme.onPrimary,
                              minimumSize: Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              await widget.settingCubit
                                  .setBibleReminderDailyNotification(data);
                              if (!context.mounted) {
                                return;
                              }
                              Navigator.pop(context);
                            },
                            child: Text('Set Reminder'.tr()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

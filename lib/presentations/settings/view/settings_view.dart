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
import '../../../components/themes/app_accent.dart';
import '../../../data/data.dart';
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
        backgroundColor: context.colorScheme.surface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          shape: Border(
            bottom: BorderSide(color: context.colorScheme.secondaryContainer),
          ),
          leading: IconButton(
            tooltip: 'Menu',
            onPressed: openDashboardDrawer,
            icon: const Icon(Icons.menu_rounded),
          ),
          title: const Text('Kidung Rohani'),
          centerTitle: true,
          actions: const [SizedBox(width: 48)],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              const _SettingsHeader(),
              BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) => Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.colorScheme.secondaryContainer,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.colorScheme.secondaryContainer,
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
                                  imageUrl: state.account?.profilePicture ?? '',
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Image.asset(Assets.assetsImagesAppicon),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: state.idToken == null
                            ? Text(
                                'register_button_text'.tr(),
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.account?.name ?? 'Unknown'.tr(),
                                    style: context.textTheme.headlineSmall
                                        ?.copyWith(fontSize: 20),
                                  ),
                                  Text(
                                    state.account?.email ?? 'Unknown'.tr(),
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                          color: context
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.idToken == null
                              ? context.colorScheme.primary
                              : context.colorScheme.errorContainer,
                          foregroundColor: state.idToken == null
                              ? context.colorScheme.onPrimary
                              : context.colorScheme.onErrorContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () async {
                          if (context.read<DashboardCubit>().state.idToken ==
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
                            context.read<DashboardCubit>().loginSuccessCallback(
                              null,
                            );
                          }
                        },
                        child: Text(
                          (state.idToken == null ? 'Login' : 'Logout').tr(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  BlocBuilder<BibleCubit, BibleState>(
                    builder: (context, state) => Section(
                      label: 'Verse'.tr(),
                      child: (gap) => Material(
                        color: context.colorScheme.surfaceContainerLowest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
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
                                            style: ElevatedButton.styleFrom(
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            onPressed: () async {
                                              log('onTapSelectBible');
                                              await context
                                                  .read<BibleCubit>()
                                                  .getBibles();
                                              if (!context.mounted) return;
                                              final state = context
                                                  .read<BibleCubit>()
                                                  .state;
                                              var bibleCodes = state.bibleCodes
                                                  .map(
                                                    (e) => e.split('.').first,
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
                                              var currentIndex = bibleCodes
                                                  .indexOf(
                                                    state.currentBibleCode,
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
                                                      bibleCodes: bibleCodes,
                                                      initialIndex:
                                                          currentIndex,
                                                      onTap: (index) async {
                                                        await context
                                                            .read<BibleCubit>()
                                                            .selectBibleCode(
                                                              index,
                                                            );
                                                        if (!ctx.mounted) {
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
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        onPressed: () {
                                          router.push(
                                            BibleListRoute(
                                              bibleCode: state.currentBibleCode,
                                              textScale: state.defaultTextScale,
                                              onSelected: (newBible) {
                                                context
                                                    .read<BibleCubit>()
                                                    .setTodayReading(newBible);
                                                router.maybePop();
                                              },
                                              getBibles:
                                                  (bookId, chapterId) async {
                                                    if (bookId == null ||
                                                        chapterId == null) {
                                                      return [];
                                                    }
                                                    return await context
                                                        .read<BibleCubit>()
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
                                          builder: (context, snapshot) => Text(
                                            snapshot.data ?? 'None'.tr(),
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
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        onPressed: () async {
                                          var settingCubit = context
                                              .read<SettingsCubit>();

                                          var weekdays = List.generate(
                                            7,
                                            (index) => index + 1,
                                          );
                                          await showModalBottomSheet(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (context) {
                                              return BibleReminderDialog(
                                                weekdays: weekdays,
                                                settingCubit: settingCubit,
                                              );
                                            },
                                          );
                                        },
                                        child: Text(
                                          (context
                                                      .watch<SettingsCubit>()
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
                                            onSave: (voices, pitch, speed) {
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
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: context.colorScheme.outlineVariant.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children:
                            [
                                  {
                                    'icon': Icons.notifications_active_outlined,
                                    'label': 'Sabat Notification'.tr(),
                                    'desc': state.isSabatNotificationActive
                                        ? 'sabat_notification_enabled_desc'.tr()
                                        : 'sabat_notification_disabled_desc'
                                              .tr(),
                                    'onTap': null,
                                    'trailing': ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            state.isSabatNotificationActive
                                            ? context
                                                  .colorScheme
                                                  .secondaryContainer
                                            : context
                                                  .colorScheme
                                                  .errorContainer,
                                        foregroundColor:
                                            state.isSabatNotificationActive
                                            ? context
                                                  .colorScheme
                                                  .onSecondaryContainer
                                            : context
                                                  .colorScheme
                                                  .onErrorContainer,
                                        visualDensity: VisualDensity.compact,
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
                  const _AccentColorSection(),
                  Section(
                    label: 'Others'.tr(),
                    child: (gap) => Material(
                      color: context.colorScheme.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: context.colorScheme.outlineVariant.withValues(
                            alpha: 0.55,
                          ),
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
                                        visualDensity: VisualDensity.compact,
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
                                            child: SelectLanguageDialog(),
                                          ),
                                        );
                                      },
                                      child: Text(context.locale.languageName),
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
                                              context.read<BibleCubit>().sync(
                                                data.bibleState!,
                                              );
                                            }
                                            if (data.songState != null) {
                                              context.read<SongCubit>().sync(
                                                data.songState!,
                                              );
                                            }
                                            if (data.faithState != null) {
                                              context.read<FaithCubit>().sync(
                                                data.faithState!,
                                              );
                                            }
                                            if (data.settingsState != null) {
                                              context
                                                  .read<SettingsCubit>()
                                                  .sync(data.settingsState!);
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
                                                .loginSuccessCallback(token);
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
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        children: [
          Text(
            'Settings'.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colorScheme.primary,
              fontFamily: 'EB Garamond',
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 52,
            height: 4,
            decoration: BoxDecoration(
              color: context.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Atur tampilan, Alkitab, kidung, pengingat, dan akun e-GYS.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.secondaryContainer),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(icon, size: 20, color: colors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
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
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 132),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: trailing,
                  ),
                ),
              ] else
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
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

class _SongSettingsSection extends StatelessWidget {
  const _SongSettingsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongCubit, SongState>(
      builder: (context, state) {
        final songCubit = context.read<SongCubit>();
        return Section(
          label: 'Pujian',
          child: (gap) => Material(
            color: context.colorScheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: context.colorScheme.secondaryContainer),
            ),
            clipBehavior: Clip.antiAlias,
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
                  trailing: PopupMenuButton<String>(
                    initialValue: state.soundFont,
                    onSelected: songCubit.setSoundFont,
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'GeneralUser-GS.sf2',
                        child: Text('GeneralUser GS'),
                      ),
                      PopupMenuItem(
                        value: 'TimGM6mb.sf2',
                        child: Text('TimGM6mb'),
                      ),
                    ],
                    child: Text(
                      state.soundFont == 'GeneralUser-GS.sf2'
                          ? 'GeneralUser GS'
                          : 'TimGM6mb',
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: context.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
                _SettingsSwitchTile(
                  icon: Icons.download_rounded,
                  title: 'Preload MIDI',
                  description:
                      'Preload lagu sebelum & sesudah untuk transisi cepat',
                  value: state.preloadEnabled,
                  onChanged: songCubit.setPreloadEnabled,
                ),
                Divider(
                  height: 1,
                  color: context.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
                _SettingsTile(
                  icon: Icons.queue_music_rounded,
                  title: 'Jumlah Preload',
                  description: '${state.preloadCount} lagu sebelum & sesudah',
                  trailing: SizedBox(
                    width: 120,
                    child: Slider(
                      value: state.preloadCount.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (v) => songCubit.setPreloadCount(v.round()),
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: context.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
                _SettingsTile(
                  icon: Icons.storage_rounded,
                  title: 'Cache Maksimum',
                  description:
                      '${state.preloadCacheMax} lagu tersimpan di disk',
                  trailing: SizedBox(
                    width: 120,
                    child: Slider(
                      value: state.preloadCacheMax.toDouble(),
                      min: 4,
                      max: 32,
                      divisions: 7,
                      onChanged: (v) => songCubit.setPreloadCacheMax(v.round()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AccentColorSection extends StatelessWidget {
  const _AccentColorSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InitialCubit, InitialState>(
      builder: (context, state) {
        return Section(
          label: 'Warna Aksen',
          child: (gap) => Padding(
            padding: EdgeInsets.symmetric(horizontal: gap),
            child: Material(
              color: context.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: appAccentOptions.map((accent) {
                    final selected = state.accentKey == accent.key;
                    return InkWell(
                      onTap: () {
                        context.read<InitialCubit>().changeAccentColor(
                          accent.key,
                        );
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: AnimatedContainer(
                        duration: kThemeAnimationDuration,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? accent.fixed
                              : context.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: selected
                                ? context.colorScheme.primary
                                : context.colorScheme.outlineVariant,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: accent.seed,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              accent.label,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: selected
                                    ? accent.seed
                                    : context.colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (selected) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: accent.seed,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
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
            color: context.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
          color: context.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                          return ListTile(
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
                                borderRadius: BorderRadius.circular(12),
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

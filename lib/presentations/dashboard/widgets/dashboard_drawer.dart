import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../domain/entity/verse/verse.dart';
import '../../../router/router.dart';
import '../../presentations.dart';

final Future<PackageInfo> _packageInfoFuture = _loadPackageInfo();

Future<PackageInfo> _loadPackageInfo() async {
  if (kIsWeb) {
    return PackageInfo(
      appName: '',
      packageName: '',
      version: '',
      buildNumber: '',
      buildSignature: '',
      installerStore: null,
    );
  }
  try {
    return await PackageInfo.fromPlatform();
  } catch (_) {
    return PackageInfo(
      appName: '',
      packageName: '',
      version: '',
      buildNumber: '',
      buildSignature: '',
      installerStore: null,
    );
  }
}

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Drawer(
      width: (MediaQuery.sizeOf(context).width * 0.86)
          .clamp(320.0, 420.0)
          .toDouble(),
      backgroundColor: colors.surface,
      child: SafeArea(
        child: BlocBuilder<InitialCubit, InitialState>(
          builder: (context, initialState) {
            return Theme(
              data: Theme.of(context).copyWith(
                textTheme: Theme.of(
                  context,
                ).textTheme.apply(fontFamily: initialState.defaultFont),
              ),
              child: BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: _AccountPanel(state: state),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  18,
                                  24,
                                  8,
                                ),
                                child: Text(
                                  'quick_actions_label'.tr().toUpperCase(),
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.35,
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(child: _LastSongTile()),
                            const SliverToBoxAdapter(child: _ReadingTile()),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  10,
                                  16,
                                  8,
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.settings_rounded),
                                  title: Text('Pengaturan'.tr()),
                                  subtitle: Text(_settingsSubtitle(context)),
                                  trailing: const Icon(
                                    Icons.chevron_right_rounded,
                                  ),
                                  onTap: () {
                                    Scaffold.maybeOf(context)?.closeDrawer();
                                    AutoTabsRouter.of(
                                      context,
                                    ).setActiveIndex(4);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const _DrawerFooter(),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AccountPanel extends StatelessWidget {
  const _AccountPanel({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final account = state.account;
    final memberType = account?.resolvedMemberType;
    final branchName = account?.resolvedBranchName;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.primary.withValues(alpha: 0.055),
          colors.surfaceContainerLow,
        ),
        borderRadius: context.appRadius(22),
        border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AccountAvatar(state: state),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account?.name?.trim().isNotEmpty == true
                          ? account!.name!.trim()
                          : 'Gereja Yesus Sejati',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.isLoggedIn
                          ? (account?.email?.trim().isNotEmpty == true
                                ? account!.email!.trim()
                                : 'Akun GYS')
                          : 'not_logged_in'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (state.isLoggedIn)
                IconButton(
                  tooltip: 'open_egys'.tr(),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Scaffold.maybeOf(context)?.closeDrawer();
                    context.router.push(
                      WebpageRoute(url: 'https://e.gys.or.id'),
                    );
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 19),
                ),
            ],
          ),
          if (state.isLoggedIn &&
              ((memberType ?? '').isNotEmpty ||
                  (branchName ?? '').isNotEmpty)) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                if ((memberType ?? '').isNotEmpty)
                  _AccountBadge(
                    icon: memberType == 'Simpatisan'
                        ? Icons.favorite_outline_rounded
                        : Icons.church_rounded,
                    label: memberType!,
                  ),
                if ((branchName ?? '').isNotEmpty)
                  _AccountBadge(
                    icon: Icons.location_on_outlined,
                    label: _formatBranchName(branchName!),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: state.isLoggedIn
                ? TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: colors.error,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () {
                      context.read<DashboardCubit>().loginSuccessCallback(null);
                    },
                    icon: const Icon(Icons.logout_rounded, size: 17),
                    label: Text('logout'.tr()),
                  )
                : FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => _startLogin(context),
                    icon: const Icon(Icons.login_rounded, size: 17),
                    label: Text('Login'.tr()),
                  ),
          ),
        ],
      ),
    );
  }

  void _startLogin(BuildContext context) {
    final cubit = context.read<DashboardCubit>();
    Scaffold.maybeOf(context)?.closeDrawer();
    router.push(
      LoginRoute(
        onLoggedIn: (token) {
          router.maybePop();
          cubit.loginSuccessCallback(token);
        },
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.55),
          width: 1.4,
        ),
      ),
      child: ClipOval(
        child: state.account?.profilePicture == null
            ? Image.asset(Assets.assetsImagesAppicon)
            : CachedNetworkImage(
                imageUrl: state.account!.profilePicture!,
                fit: BoxFit.cover,
                memCacheWidth: 128,
                memCacheHeight: 128,
                placeholder: (_, _) => Image.asset(Assets.assetsImagesAppicon),
                errorWidget: (_, _, _) =>
                    Image.asset(Assets.assetsImagesAppicon),
              ),
      ),
    );
  }
}

class _AccountBadge extends StatelessWidget {
  const _AccountBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.72),
        borderRadius: context.appRadius(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onPrimaryContainer),
          const SizedBox(width: 5),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LastSongTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SongCubit>();
    final song = cubit.state.lastOpenedSong;
    return _ActivityTile(
      icon: Icons.music_note_rounded,
      label: 'last_opened'.tr(),
      value: song == null
          ? 'no_history'.tr()
          : '${song.code ?? ''} ${song.number ?? ''} — ${song.title ?? ''}',
      onTap: song == null
          ? null
          : () {
              Scaffold.maybeOf(context)?.closeDrawer();
              AutoTabsRouter.of(context).setActiveIndex(2);
              cubit.openSong(song);
            },
    );
  }
}

class _ReadingTile extends StatefulWidget {
  const _ReadingTile();

  @override
  State<_ReadingTile> createState() => _ReadingTileState();
}

class _ReadingTileState extends State<_ReadingTile> {
  Verse? _titleFor;
  Future<String?>? _titleFuture;

  Future<String?> _titleFutureFor(BibleCubit cubit, Verse? verse) {
    if (identical(_titleFor, verse) && _titleFuture != null) {
      return _titleFuture!;
    }
    _titleFor = verse;
    _titleFuture = verse == null
        ? Future<String?>.value(null)
        : cubit.getBibleTitle([verse]);
    return _titleFuture!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibleCubit, BibleState>(
      builder: (context, state) {
        final cubit = context.read<BibleCubit>();
        final target = state.todayReading;
        return FutureBuilder<String?>(
          future: _titleFutureFor(cubit, target),
          builder: (context, snapshot) => _ActivityTile(
            icon: Icons.auto_stories_rounded,
            label: 'daily_reading_label'.tr(),
            value: target == null
                ? 'no_daily_reading'.tr()
                : (snapshot.data?.trim().isNotEmpty == true
                      ? snapshot.data!.trim()
                      : 'Today Reading'.tr()),
            onTap: target == null
                ? null
                : () {
                    Scaffold.maybeOf(context)?.closeDrawer();
                    AutoTabsRouter.of(context).setActiveIndex(1);
                    cubit.setTodayReading(target);
                  },
          ),
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: 0.66),
            borderRadius: context.appRadius(12),
          ),
          child: Icon(icon, size: 20, color: colors.onPrimaryContainer),
        ),
        title: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.labelMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        trailing: onTap == null
            ? null
            : const Icon(Icons.chevron_right_rounded, size: 18),
        onTap: onTap,
      ),
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter();

  bool get _canExitApp {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.windows ||
      TargetPlatform.linux => true,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 14, 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.72),
        border: Border(
          top: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.45)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.church_outlined, size: 16, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: FutureBuilder<PackageInfo>(
              future: _packageInfoFuture,
              builder: (context, snapshot) {
                final version = snapshot.data?.version ?? '';
                return Text(
                  version.isEmpty ? 'GYS App' : 'GYS App · v$version',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          if (_canExitApp)
            IconButton(
              tooltip: 'close_app'.tr(),
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                foregroundColor: colors.onSurfaceVariant,
              ),
              onPressed: SystemNavigator.pop,
              icon: const Icon(Icons.power_settings_new_rounded, size: 19),
            ),
        ],
      ),
    );
  }
}

String _formatBranchName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return trimmed;
  return trimmed
      .split(RegExp(r'\s+'))
      .map((word) {
        if (word.isEmpty) return word;
        if (word.length <= 2) return word.toUpperCase();
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ');
}

String _settingsSubtitle(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
        ? 'Tema, bacaan, data, dan preferensi aplikasi'
        : 'Theme, reading, data, and app preferences';

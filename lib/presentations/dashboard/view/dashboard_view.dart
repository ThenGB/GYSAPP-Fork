import 'dart:developer';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../data/data.dart';
import '../../../di/injection.dart';
import '../../../router/router.dart';
import '../../song/widgets/draggable_midi_controls.dart';
import '../../presentations.dart';

class DashboardNavigationDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final PageRouteInfo<dynamic> page;

  const DashboardNavigationDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.page,
  });
}

const dashboardNavigationDestinations = [
  DashboardNavigationDestination(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'Dashboard',
    page: HomeRoute(),
  ),
  DashboardNavigationDestination(
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book_rounded,
    label: 'Bible',
    page: BibleRoute(),
  ),
  DashboardNavigationDestination(
    icon: Icons.music_note_outlined,
    selectedIcon: Icons.music_note_rounded,
    label: 'Hymnal',
    page: SongRoute(),
  ),
  DashboardNavigationDestination(
    icon: Icons.auto_stories_outlined,
    selectedIcon: Icons.auto_stories_rounded,
    label: 'Beliefs',
    page: FaithRoute(),
  ),
  DashboardNavigationDestination(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    label: 'Settings',
    page: SettingsRoute(),
  ),
];

const dashboardBottomNavigationDestinations = [
  DashboardNavigationDestination(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'Dashboard',
    page: HomeRoute(),
  ),
  DashboardNavigationDestination(
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book_rounded,
    label: 'Bible',
    page: BibleRoute(),
  ),
  DashboardNavigationDestination(
    icon: Icons.music_note_outlined,
    selectedIcon: Icons.music_note_rounded,
    label: 'Hymnal',
    page: SongRoute(),
  ),
  DashboardNavigationDestination(
    icon: Icons.auto_stories_outlined,
    selectedIcon: Icons.auto_stories_rounded,
    label: 'Beliefs',
    page: FaithRoute(),
  ),
];

final dashboardScaffoldKey = GlobalKey<ScaffoldState>();
const bool kDashboardExtendsBodyForMiniPlayerOverlay = true;
const double kDashboardMiniPlayerNavGap = 8;
const double kDashboardExpandedMiniPlayerHeight = 168;
const double kDashboardPortraitBottomNavHeight = 64;
const double kDashboardLandscapeBottomNavHeight = 56;
const double kDashboardCompactNavOuterVerticalPadding = 4;
const double kDashboardCompactNavInnerVerticalPadding = 5;
const double kDashboardCompactNavIconSize = 19;
const double kDashboardCompactNavLabelFontSize = 9.5;
const double kDashboardCompactNavIconLabelGap = 1;
const double kDashboardRegularNavOuterVerticalPadding = 7;
const double kDashboardRegularNavInnerVerticalPadding = 7;
const double kDashboardRegularNavIconSize = 21;
const double kDashboardRegularNavLabelFontSize = 10.5;
const double kDashboardRegularNavIconLabelGap = 3;
const double kDashboardNavMaxWidth = 700;
const double kDashboardNavMinInteractiveExtent = 48;

double dashboardMiniPlayerBottomOffset({
  required bool isExpanded,
  double navHeight = kDashboardPortraitBottomNavHeight,
}) {
  return navHeight + kDashboardMiniPlayerNavGap;
}

double dashboardMiniPlayerHeight({required bool isExpanded}) {
  return isExpanded
      ? kDashboardExpandedMiniPlayerHeight
      : kMidiCollapsedBarHeight;
}

double dashboardMiniPlayerHitTestHeight({
  required bool isVisible,
  required bool isExpanded,
  required double navHeight,
}) {
  if (!isVisible) {
    return navHeight;
  }
  return dashboardMiniPlayerBottomOffset(
        isExpanded: isExpanded,
        navHeight: navHeight,
      ) +
      dashboardMiniPlayerHeight(isExpanded: isExpanded);
}

double dashboardBottomNavContentHeight({
  required double navHeight,
  required double bottomInset,
}) {
  final availableHeight = navHeight - bottomInset;
  return availableHeight < 0 ? 0 : availableHeight;
}

double dashboardBottomNavItemHeight({
  required double outerVerticalPadding,
  required double innerVerticalPadding,
  required double iconSize,
  required double labelFontSize,
  required double iconLabelGap,
}) {
  final rawHeight =
      (outerVerticalPadding * 2) +
      (innerVerticalPadding * 2) +
      iconSize +
      iconLabelGap +
      labelFontSize;
  return rawHeight < kDashboardNavMinInteractiveExtent
      ? kDashboardNavMinInteractiveExtent
      : rawHeight;
}

void openDashboardDrawer() {
  dashboardScaffoldKey.currentState?.openDrawer();
}

@RoutePage()
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void dispose() {
    if (Platform.isAndroid) {
      WakelockPlus.disable();
    }
    super.dispose();
  }

  TabsRouter? tabRouter;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initUniLinks();
    });
    super.initState();
  }

  final _appLinks = AppLinks();

  Future<void> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _appLinks.uriLinkStream.listen((uri) {
        log(uri.toString());
        router.push(WebpageRoute(url: uri.toString()));
        // Do something (navigation, ...)
      });
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }
  }

  @override
  Widget build(BuildContext context) {
    const pages = dashboardNavigationDestinations;
    const bottomNavPages = dashboardBottomNavigationDestinations;
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardCubit>(create: (context) => di(), lazy: false),
        BlocProvider<BibleCubit>(create: (context) => di(), lazy: false),
        BlocProvider<HomeCubit>(create: (context) => di()),
        BlocProvider<FaithCubit>(create: (context) => di()),
        BlocProvider<SettingsCubit>(create: (context) => di()),
        BlocProvider<AssetManagementCubit>(create: (context) => di()),
      ],
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return SafeArea(
              child: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: MirrorAnimationBuilder(
                          duration: Duration(milliseconds: 1500),
                          tween: Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ), // Keep the original tween
                          builder: (context, value, child) {
                            double scale =
                                1 +
                                (0.1 *
                                    value); // Interpolate to get scale between 1 and 1.3
                            double opacity =
                                1 -
                                (0.5 *
                                    value); // Interpolate to get scale between 1 and 1.3
                            return Transform.scale(
                              scale: scale, // Apply the interpolated scale
                              child: Opacity(opacity: opacity, child: child),
                            );
                          },
                          child: Image.asset(Assets.assetsImagesAppicon),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CupertinoActivityIndicator(),
                          SizedBox(width: 8),
                          Text(
                            'Preparing dashboard',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: context.textColor?.withValues(alpha: .5),
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
          // ignore: deprecated_member_use
          return WillPopScope(
            onWillPop: () async {
              if (tabRouter?.activeIndex != 0) {
                context.read<BibleCubit>().stopSpeaking();
                var mustBeNot = [
                  context.read<BibleCubit>().isSelectingBible,
                  context.read<SongCubit>().isSelectingSong,
                  context.read<FaithCubit>().isSelectingFaith,
                ];
                var isContainTrue = mustBeNot.contains(true);
                if (isContainTrue) {
                  context.read<BibleCubit>().removeSelection();
                  context.read<SongCubit>().removeSelection();
                  context.read<FaithCubit>().removeSelection();
                  return false;
                }
                tabRouter?.setActiveIndex(0);
                return false;
              }

              return true;
            },
            child: BlocBuilder<SongCubit, SongState>(
              builder: (context, songState) => AutoTabsRouter(
                routes: pages.map((e) => e.page).toList(),
                transitionBuilder: (context, child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                builder: (context, child) {
                  final tabsRouter = AutoTabsRouter.of(context);
                  tabRouter = tabsRouter;
                  final isLandscape =
                      MediaQuery.orientationOf(context) ==
                      Orientation.landscape;
                  final bottomInset = MediaQuery.paddingOf(context).bottom;
                  final navHeight = isLandscape
                      ? kDashboardLandscapeBottomNavHeight
                      : kDashboardPortraitBottomNavHeight;
                  final bodyBottomPadding = navHeight + bottomInset;

                  final bottomNavItemCount = bottomNavPages.length;
                  final isBeyondBottomNav = tabsRouter.activeIndex >= bottomNavItemCount;
                  final safeSelectedIndex = isBeyondBottomNav
                      ? -1
                      : tabsRouter.activeIndex;

                  return Scaffold(
                    key: dashboardScaffoldKey,
                    backgroundColor: context.colorScheme.surface,
                    extendBody: kDashboardExtendsBodyForMiniPlayerOverlay,
                    drawer: const _DashboardDrawer(),
                    body: Stack(
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: context.colorScheme.surface,
                            ),
                            child: AnimatedPadding(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              padding: EdgeInsets.only(
                                bottom: bodyBottomPadding,
                              ),
                              child: child,
                            ),
                          ),
                        ),
                      ],
                    ),
                    bottomNavigationBar: _AnimatedRoundedNavBar(
                      selectedIndex: safeSelectedIndex,
                      onDestinationSelected: (value) {
                        context.read<BibleCubit>().stopSpeaking();
                        tabsRouter.setActiveIndex(value);
                      },
                      destinations: bottomNavPages,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardDrawer extends StatelessWidget {
  const _DashboardDrawer();

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Drawer(
      width: (MediaQuery.sizeOf(context).width * 0.84)
          .clamp(320.0, 410.0)
          .toDouble(),
      backgroundColor: colors.surface,
      child: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surfaceContainerHighest.withValues(alpha: 0.75),
                colors.surface,
              ],
            ),
          ),
          child: BlocBuilder<InitialCubit, InitialState>(
            builder: (context, initialState) {
              return Theme(
                data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.apply(
                    fontFamily: initialState.defaultFont,
                  ),
                ),
                child: BlocBuilder<DashboardCubit, DashboardState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _DrawerHeader(state: state),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Divider(
                                    color: colors.outlineVariant.withValues(
                                      alpha: 0.42,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                                  child: Text(
                                    'AKTIVITAS CEPAT',
                                    style: Theme.of(context).textTheme.labelSmall
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.5,
                                        ),
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    final songCubit = context.read<SongCubit>();
                                    final lastSong = songCubit.state.lastOpenedSong;
                                    return _DrawerActivityTile(
                                      icon: Icons.music_note_rounded,
                                      label: 'Terakhir dibuka',
                                      value: lastSong != null
                                          ? '${lastSong.code ?? ''} ${lastSong.number ?? ''} — ${lastSong.title ?? ''}'
                                          : 'Belum ada riwayat',
                                      onTap: lastSong != null
                                          ? () {
                                              Navigator.of(context).maybePop();
                                              AutoTabsRouter.of(
                                                context,
                                              ).setActiveIndex(2);
                                              songCubit.openSong(lastSong);
                                            }
                                          : null,
                                    );
                                  },
                                ),
                                const _DrawerProgressTile(),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Divider(
                                    color: colors.outlineVariant.withValues(
                                      alpha: 0.42,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  leading: Icon(
                                    Icons.settings_outlined,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  title: Text(
                                    'Pengaturan',
                                    style: Theme.of(context).textTheme.titleLarge
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).maybePop();
                                    AutoTabsRouter.of(context).setActiveIndex(4);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!state.isLoggedIn)
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: colors.onPrimary,
                                    minimumSize: const Size.fromHeight(56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    final cubit = context.read<DashboardCubit>();
                                    Navigator.of(context).maybePop();
                                    router.push(
                                      LoginRoute(
                                        onLoggedIn: (token) {
                                          try {
                                            router.maybePop();
                                            cubit.loginSuccessCallback(token);
                                          } catch (e, st) {
                                            debugPrint('[DashboardView] onLoggedIn ERROR: $e\n$st');
                                          }
                                        },
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.login_rounded),
                                  label: Text('Login'.tr()),
                                ),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: colors.outlineVariant),
                                  minimumSize: const Size.fromHeight(46),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).maybePop();
                                  SystemNavigator.pop();
                                },
                                icon: Icon(Icons.exit_to_app_rounded, color: colors.onSurfaceVariant),
                                label: Text(
                                  'Keluar'.tr(),
                                  style: TextStyle(color: colors.onSurfaceVariant),
                                ),
                              ),
                              const SizedBox(height: 8),
                              FutureBuilder<PackageInfo>(
                                future: PackageInfo.fromPlatform(),
                                builder: (context, snapshot) {
                                  final version = snapshot.data?.version ?? '';
                                  return Text(
                                    'v$version',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final DashboardState state;

  const _DrawerHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.5),
                      width: 1.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.16),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: state.account?.profilePicture == null
                        ? Image.asset(Assets.assetsImagesAppicon)
                        : Image.network(
                            state.account!.profilePicture!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(Assets.assetsImagesAppicon),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.account?.name ?? 'Gereja Yesus Sejati',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        !state.isLoggedIn
                            ? 'Belum login'
                            : state.account?.email ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      if (state.isLoggedIn) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            state.account?.memberType ?? 'Jemaat',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colors.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.tertiaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _formatBranchName(state.account?.branchName ?? ''),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colors.onTertiaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (state.isLoggedIn) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).maybePop();
                context.router.push(
                  WebpageRoute(url: 'https://e.gys.or.id'),
                );
              },
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Buka e-GYS'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                final cubit = context.read<DashboardCubit>();
                Navigator.of(context).maybePop();
                cubit.loginSuccessCallback(null);
              },
              child: Text(
                'Log Out',
                style: TextStyle(color: colors.error),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DrawerActivityTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _DrawerActivityTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: onTap != null
              ? colors.primaryContainer.withValues(alpha: 0.3)
              : colors.surfaceContainerLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: onTap != null
                ? colors.primary.withValues(alpha: 0.3)
                : colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.70),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colors.primary.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DrawerProgressTile extends StatelessWidget {
  const _DrawerProgressTile();

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surfaceContainerHighest.withValues(alpha: 0.92),
            colors.surfaceContainerLow.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.42),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PROGRESS ALKITAB',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                'HARI INI',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.primary, width: 2),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sudah baca hari ini',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontFamily: 'Manrope'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatBranchName(String name) {
  if (name.isEmpty) return name;
  final parts = name.split(' ');
  if (parts.length == 1) return parts[0].toUpperCase();
  return '${parts[0].toUpperCase()} ${parts.sublist(1).map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ')}';
}

class _AnimatedRoundedNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<DashboardNavigationDestination> destinations;

  const _AnimatedRoundedNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  State<_AnimatedRoundedNavBar> createState() => _AnimatedRoundedNavBarState();
}

class _AnimatedRoundedNavBarState extends State<_AnimatedRoundedNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _notchAnimation;
  int _previousIndex = 0;
  static const double _navBarHeight = 72;
  static const double _circleSize = 56;
  static const double _notchDepth = 24;
  static const double _notchWidth = 80;
  static const double _circleGap = 6;

  bool get _hasSelection => widget.selectedIndex >= 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.selectedIndex >= 0 ? widget.selectedIndex : 0;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    final idx = _previousIndex.toDouble();
    _notchAnimation = Tween<double>(
      begin: idx,
      end: idx,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void didUpdateWidget(_AnimatedRoundedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex >= 0 ? oldWidget.selectedIndex : _previousIndex;
      final beginIdx = _previousIndex.toDouble();
      final endIdx = widget.selectedIndex >= 0 ? widget.selectedIndex.toDouble() : beginIdx;
      _notchAnimation = Tween<double>(
        begin: beginIdx,
        end: endIdx,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final count = widget.destinations.length;
    final navBarColor = colors.surfaceContainerHighest;
    final circleColor = colors.primary;
    final iconColor = colors.onPrimary;
    final unselectedIconColor = colors.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final itemWidth = width / count;

          return AnimatedBuilder(
            animation: _notchAnimation,
            builder: (context, child) {
              final animatedIndex = _notchAnimation.value;
              final notchCenterX = (animatedIndex + 0.5) * itemWidth;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: Size(width, _navBarHeight),
                    painter: _NavBarPainter(
                      notchCenterX: notchCenterX,
                      notchWidth: _notchWidth,
                      notchDepth: _notchDepth,
                      color: navBarColor,
                      shadowColor: Colors.black.withValues(alpha: 0.15),
                    ),
                    child: SizedBox(
                      height: _navBarHeight,
                      child: Row(
                        children: List.generate(count, (index) {
                          final dest = widget.destinations[index];
                          final isSelected = _hasSelection && index == widget.selectedIndex;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => widget.onDestinationSelected(index),
                              behavior: HitTestBehavior.opaque,
                              child: SizedBox(
                                height: _navBarHeight,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: isSelected
                                      ? [
                                          Icon(
                                            dest.selectedIcon ?? dest.icon,
                                            color: Colors.transparent,
                                            size: 22,
                                          ),
                                        ]
                                      : [
                                          Icon(
                                            dest.icon,
                                            color: unselectedIconColor,
                                            size: 22,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            dest.label.tr(),
                                            style: TextStyle(
                                              color: unselectedIconColor
                                                  .withValues(alpha: 0.7),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  if (_hasSelection)
                  Positioned(
                    top: _notchDepth - _circleSize / 2 - _circleGap,
                    left: notchCenterX - _circleSize / 2,
                    child: Container(
                      width: _circleSize,
                      height: _circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                        boxShadow: [
                          BoxShadow(
                            color: circleColor.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        widget.destinations[widget.selectedIndex].selectedIcon ??
                            widget.destinations[widget.selectedIndex].icon,
                        color: iconColor,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _NavBarPainter extends CustomPainter {
  final double notchCenterX;
  final double notchWidth;
  final double notchDepth;
  final Color color;
  final Color shadowColor;

  _NavBarPainter({
    required this.notchCenterX,
    required this.notchWidth,
    required this.notchDepth,
    required this.color,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cornerRadius = 20.0;
    final halfNotch = notchWidth / 2;
    final w = size.width;
    final h = size.height;

    final path = Path();

    path.moveTo(cornerRadius, 0);

    final notchStart = notchCenterX - halfNotch;
    final notchEnd = notchCenterX + halfNotch;

    if (notchStart > cornerRadius) {
      path.lineTo(notchStart, 0);
    }

    path.cubicTo(
      notchCenterX - halfNotch * 0.65, 0,
      notchCenterX - halfNotch * 0.3, notchDepth * 0.85,
      notchCenterX, notchDepth,
    );
    path.cubicTo(
      notchCenterX + halfNotch * 0.3, notchDepth * 0.85,
      notchCenterX + halfNotch * 0.65, 0,
      notchEnd, 0,
    );

    if (notchEnd < w - cornerRadius) {
      path.lineTo(w - cornerRadius, 0);
    }

    path.arcToPoint(
      Offset(w, cornerRadius),
      radius: Radius.circular(cornerRadius),
    );
    path.lineTo(w, h - cornerRadius);
    path.arcToPoint(
      Offset(w - cornerRadius, h),
      radius: Radius.circular(cornerRadius),
    );
    path.lineTo(cornerRadius, h);
    path.arcToPoint(
      Offset(0, h - cornerRadius),
      radius: Radius.circular(cornerRadius),
    );
    path.lineTo(0, cornerRadius);
    path.arcToPoint(
      Offset(cornerRadius, 0),
      radius: Radius.circular(cornerRadius),
    );

    path.close();

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NavBarPainter oldDelegate) {
    return oldDelegate.notchCenterX != notchCenterX ||
        oldDelegate.color != color;
  }
}

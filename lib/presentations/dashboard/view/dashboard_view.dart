import 'dart:developer';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    icon: Icons.music_note_rounded,
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
    icon: Icons.music_note_rounded,
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
  final rawHeight = (outerVerticalPadding * 2) +
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
  bool _globalMidiExpanded = true;

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
        BlocProvider<HomeCubit>(create: (context) => di()),
        BlocProvider<BibleCubit>(create: (context) => di()),
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
          return MultiBlocListener(
            listeners: [
              BlocListener<DashboardCubit, DashboardState>(
                listener: (context, state) {},
                // listenWhen: (previous, current) {
                //   return previous.isSyncing != current.isSyncing;
                // },
              ),
            ],
            // ignore: deprecated_member_use
            child: WillPopScope(
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
                    final safeSelectedIndex = tabsRouter.activeIndex.clamp(0, bottomNavItemCount - 1);

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
                          // Global MIDI Player as an Overlay
                          if (songState.showAudio)
                            AnimatedBuilder(
                              animation: context.read<SongCubit>().midiEngine,
                              builder: (context, _) {
                                final cubit = context.read<SongCubit>();
                                final songState = cubit.state;
                                final midiState = cubit.midiEngine.state;

                                return DraggableMidiControls(
                                  key: const ValueKey('global-midi-player'),
                                  isExpanded: _globalMidiExpanded,
                                  onExpandedChanged: (value) {
                                    if (_globalMidiExpanded == value) return;
                                    setState(() => _globalMidiExpanded = value);
                                  },
                                  onPreviousSong: cubit.goToPreviousSong,
                                  onNextSong: cubit.goToNextSong,
                                  usePositioned: true,
                                  isPlaying: midiState.isPlaying,
                                  isLoading: midiState.isLoading,
                                  position: midiState.position,
                                  duration: midiState.duration,
                                  transposeStep: songState.transposeStep,
                                  currentKey: songState.activeKeyLabel,
                                  availableKeys: songState.transposeKeyOptions,
                                  tempoBpm: songState.tempoBpm,
                                  midiInstrument: songState.midiInstrument,
                                  soundFont: songState.soundFont,
                                  availableSoundFonts: const [
                                    'GeneralUser-GS.sf2',
                                    'TimGM6mb.sf2',
                                  ],
                                  availableInstruments:
                                      cubit.midiEngine.instruments,
                                  autoNextMode: songState.playlistAutoNextMode,
                                  onPlayPause: cubit.togglePlayPause,
                                  onLoopModeCycle: cubit.cycleLoopMode,
                                  onSeek: (seconds) => cubit.seek(
                                    Duration(seconds: seconds.toInt()),
                                  ),
                                  onTranspose: cubit.setTranspose,
                                  onKeySelected: cubit.setTransposeKey,
                                  onTempo: cubit.setTempo,
                                  onInstrument: cubit.setMidiInstrument,
                                  onSoundFont: cubit.setSoundFont,
                                  nowPlayingTitle: songState.getSongTitleAt(
                                    songState.pageIndex,
                                  ),
                                  runningFamilyChord:
                                      songState.originalFamilyChord != null
                                      ? ChordService.formatChordForDisplay(
                                          songState.originalFamilyChord!,
                                          accidentalMode:
                                              songState.chordAccidentalMode,
                                          baseTransposeOffset:
                                              songState.baseTransposeOffset,
                                        )
                                      : null,
                                  bottomOffset: dashboardMiniPlayerBottomOffset(
                                    isExpanded: _globalMidiExpanded,
                                    navHeight: navHeight + bottomInset,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      bottomNavigationBar: NavigationBar(
                        backgroundColor: context.colorScheme.surface,
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        indicatorColor: context.colorScheme.primary.withValues(alpha: 0.2),
                        selectedIndex: safeSelectedIndex,
                        onDestinationSelected: (value) {
                          context.read<BibleCubit>().stopSpeaking();
                          tabsRouter.setActiveIndex(value);
                        },
                        destinations: [
                          for (final dest in bottomNavPages)
                            NavigationDestination(
                              icon: Icon(dest.icon),
                              selectedIcon: Icon(dest.selectedIcon ?? dest.icon),
                              label: dest.label.tr(),
                            ),
                        ],
                      ),
                    );
                  },
                ),
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
                                    fontFamily: 'Lato',
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
                            Navigator.of(context).maybePop();
                            if (state.idToken == null) {
                              router.push(
                                LoginRoute(
                                  onLoggedIn: (token) {
                                    router.maybePop();
                                    context
                                        .read<DashboardCubit>()
                                        .loginSuccessCallback(token);
                                  },
                                ),
                              );
                            } else {
                              context
                                  .read<DashboardCubit>()
                                  .loginSuccessCallback(null);
                            }
                          },
                          icon: Icon(
                            state.idToken == null
                                ? Icons.login_rounded
                                : Icons.logout_rounded,
                          ),
                          label: Text(
                            (state.idToken == null ? 'Login' : 'Keluar').tr(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Versi 1.0.0',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colors.onSurfaceVariant.withValues(
                                  alpha: 0.75,
                                ),
                                letterSpacing: 1.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(4),
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.account?.name ?? 'Gereja Yesus Sejati',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: colors.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.idToken == null
                            ? 'Akun e-GYS'
                            : state.account?.email ?? 'Akun e-GYS',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.56),
              ),
            ),
            child: Column(
              children: [
                _DrawerProfileRow(
                  label: 'ID JEMAAT',
                  value: state.account?.name == null
                      ? '-'
                      : 'GYS-${state.account!.name.hashCode.abs().toString().padLeft(5, '0').substring(0, 5)}',
                ),
                const SizedBox(height: 10),
                const _DrawerProfileRow(
                  label: 'WILAYAH',
                  value: 'Jakarta Pusat',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).maybePop();
              AutoTabsRouter.of(context).setActiveIndex(4);
            },
            icon: const Icon(Icons.settings_rounded, size: 16),
            label: const Text('Buka Workspace Settings'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
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
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
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

class _DrawerProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _DrawerProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}


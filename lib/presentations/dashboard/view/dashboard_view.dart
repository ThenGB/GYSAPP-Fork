import 'dart:developer';
import 'dart:io';
import 'dart:ui';

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

final dashboardScaffoldKey = GlobalKey<ScaffoldState>();
const bool kDashboardExtendsBodyForMiniPlayerOverlay = false;
const double kDashboardMiniPlayerNavGap = 6;
const double kDashboardExpandedMiniPlayerHeight = 168;
const double kDashboardPortraitBottomNavHeight = 72;
const double kDashboardLandscapeBottomNavHeight = 56;
const double kDashboardCompactNavOuterVerticalPadding = 3;
const double kDashboardCompactNavInnerVerticalPadding = 3;
const double kDashboardCompactNavIconSize = 20;
const double kDashboardCompactNavLabelFontSize = 9;
const double kDashboardCompactNavIconLabelGap = 1;
const double kDashboardRegularNavOuterVerticalPadding = 6;
const double kDashboardRegularNavInnerVerticalPadding = 6;
const double kDashboardRegularNavIconSize = 22;
const double kDashboardRegularNavLabelFontSize = 10;
const double kDashboardRegularNavIconLabelGap = 2;

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
  return (outerVerticalPadding * 2) +
      (innerVerticalPadding * 2) +
      iconSize +
      iconLabelGap +
      labelFontSize;
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardCubit>(create: (context) => di(), lazy: false),
        BlocProvider<HomeCubit>(create: (context) => di()),
        BlocProvider<BibleCubit>(create: (context) => di()),
        BlocProvider<FaithCubit>(create: (context) => di()),
        BlocProvider<SettingsCubit>(create: (context) => di()),
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
              builder: (context, songState) => Stack(
                children: [
                  AutoTabsScaffold(
                    scaffoldKey: dashboardScaffoldKey,
                    backgroundColor: context.colorScheme.surface,
                    extendBody: false, 
                    drawer: const _DashboardDrawer(),
                    routes: pages.map((e) => e.page).toList(),
                    transitionBuilder: (context, child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    bottomNavigationBuilder: (context, tabsRouter) {
                      tabRouter = tabsRouter;
                      return _HymnalBottomNav(
                        destinations: pages,
                        activeIndex: tabsRouter.activeIndex,
                        onTap: (value) {
                          context.read<BibleCubit>().stopSpeaking();
                          tabsRouter.setActiveIndex(value);
                        },
                      );
                    },
                  ),

                  // Global MIDI Player as an Overlay
                  if (songState.showAudio)
                    AnimatedBuilder(
                      animation: context.read<SongCubit>().midiEngine,
                      builder: (context, _) {
                        final cubit = context.read<SongCubit>();
                        final songState = cubit.state;
                        final midiState = cubit.midiEngine.state;
                        
                        final isLandscape =
                            MediaQuery.orientationOf(context) == Orientation.landscape;
                        final navHeight = isLandscape
                            ? kDashboardLandscapeBottomNavHeight
                            : kDashboardPortraitBottomNavHeight;

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
                          availableInstruments: cubit.midiEngine.instruments,
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
                          // sit above the navbar
                          bottomOffset: navHeight + kDashboardMiniPlayerNavGap,
                        );
                      },
                    ),
                ],
              ),
            ),
            ),
          );
        },
      ),
    );
  }
}

class _HymnalBottomNav extends StatelessWidget {
  final List<DashboardNavigationDestination> destinations;
  final int activeIndex;
  final ValueChanged<int> onTap;

  const _HymnalBottomNav({
    required this.destinations,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final navHeight = isLandscape
        ? kDashboardLandscapeBottomNavHeight
        : kDashboardPortraitBottomNavHeight;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final contentHeight = dashboardBottomNavContentHeight(
      navHeight: navHeight,
      bottomInset: bottomInset,
    );
    return SizedBox(
      height: navHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.90),
          border: const Border(
            top: BorderSide(color: Color(0xFFD4AF37), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SizedBox(
                height: contentHeight,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var i = 0; i < destinations.length; i++)
                          Flexible(
                            child: _HymnalBottomNavItem(
                              destination: destinations[i],
                              selected: i == activeIndex,
                              compact: isLandscape || contentHeight < 60,
                              onTap: () => onTap(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HymnalBottomNavItem extends StatelessWidget {
  final DashboardNavigationDestination destination;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _HymnalBottomNavItem({
    required this.destination,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final foreground = selected
        ? colors.primary
        : colors.onSurface.withValues(alpha: 0.68);
    final outerVerticalPadding = compact
        ? kDashboardCompactNavOuterVerticalPadding
        : kDashboardRegularNavOuterVerticalPadding;
    final innerVerticalPadding = compact
        ? kDashboardCompactNavInnerVerticalPadding
        : kDashboardRegularNavInnerVerticalPadding;
    final iconSize = compact
        ? kDashboardCompactNavIconSize
        : kDashboardRegularNavIconSize;
    final labelFontSize = compact
        ? kDashboardCompactNavLabelFontSize
        : kDashboardRegularNavLabelFontSize;
    final iconLabelGap = compact
        ? kDashboardCompactNavIconLabelGap
        : kDashboardRegularNavIconLabelGap;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 2,
        vertical: outerVerticalPadding,
      ),
      child: AnimatedScale(
        scale: selected ? 0.96 : 1.0,
        duration: kThemeAnimationDuration,
        curve: Curves.easeOut,
        child: Material(
          color: selected ? colors.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: AnimatedContainer(
              duration: kThemeAnimationDuration,
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(
                horizontal: 2,
                vertical: innerVerticalPadding,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selected
                        ? (destination.selectedIcon ?? destination.icon)
                        : destination.icon,
                    size: iconSize,
                    color: foreground,
                  ),
                  SizedBox(height: iconLabelGap),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      destination.label.tr(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: foreground,
                        fontSize: labelFontSize,
                        height: 1,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
          .clamp(300.0, 360.0)
          .toDouble(),
      backgroundColor: colors.surface,
      child: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DrawerHeader(state: state),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Divider(
                            color: colors.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                          child: Text(
                            'AKTIVITAS TERAKHIR',
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
                            color: colors.outlineVariant.withValues(alpha: 0.5),
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
                                  fontFamily: 'Manrope',
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
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
                          minimumSize: const Size.fromHeight(58),
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
                            context.read<DashboardCubit>().loginSuccessCallback(
                              null,
                            );
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
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.secondaryContainer,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
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
                            color: colors.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
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
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.55),
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
              router.push(WebpageRoute(url: 'https://e.gys.or.id/u/home'));
            },
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('Buka Web e-GYS'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.secondaryContainer),
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
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
        margin: const EdgeInsets.fromLTRB(24, 8, 24, 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: onTap != null
              ? colors.primaryContainer.withValues(alpha: 0.35)
              : colors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: onTap != null
                ? colors.primary.withValues(alpha: 0.25)
                : colors.outlineVariant.withValues(alpha: 0.30),
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
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.20),
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

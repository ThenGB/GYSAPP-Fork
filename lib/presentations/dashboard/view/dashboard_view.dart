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
const double kDashboardMiniPlayerBottomOffset = 78;

double dashboardMiniPlayerBottomOffset({required bool isExpanded}) {
  return kDashboardMiniPlayerBottomOffset;
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
              child: AutoTabsScaffold(
                scaffoldKey: dashboardScaffoldKey,
                backgroundColor: context.colorScheme.surface,
                extendBody: kDashboardExtendsBodyForMiniPlayerOverlay,
                drawer: const _DashboardDrawer(),
                routes: pages.map((e) => e.page).toList(),
                transitionBuilder: (context, child, animation) {
                  return Column(
                    children: [
                      Expanded(
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      AnimatedSize(
                        alignment: Alignment.bottomCenter,
                        duration: kThemeAnimationDuration,
                        child: (state.isSyncing)
                            ? SafeArea(
                                top: false,
                                child: Text(
                                  state.message ?? 'Syncing',
                                  style: context.textTheme.labelSmall,
                                ),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                  );
                },
                bottomNavigationBuilder: (context, tabsRouter) {
                  tabRouter = tabsRouter;
                  return BlocBuilder<SongCubit, SongState>(
                    builder: (context, songState) => BlocBuilder<FaithCubit, FaithState>(
                      builder: (context, faithState) =>
                          BlocBuilder<BibleCubit, BibleState>(
                            builder: (context, state) => AnimatedSize(
                              duration: kThemeAnimationDuration,
                              alignment: Alignment.bottomCenter,
                              curve: Curves.easeOut,
                              child: OrientationBuilder(
                                builder: (context, orientation) {
                                  var bibleCondition =
                                      state.selectedVerse.isNotEmpty;
                                  var faithCondition =
                                      faithState.selectedFaith.isNotEmpty;
                                  var songCondition2 =
                                      songState.selectedSong != null;
                                  if (bibleCondition ||
                                      faithCondition ||
                                      songCondition2) {
                                    return const SizedBox(
                                      width: double.infinity,
                                    );
                                  }

                                  final nav = _HymnalBottomNav(
                                    destinations: pages,
                                    activeIndex: tabsRouter.activeIndex,
                                    onTap: (value) {
                                      context.read<BibleCubit>().stopSpeaking();
                                      tabsRouter.setActiveIndex(value);
                                      var list = [
                                        BibleRoute,
                                        FaithRoute,
                                        SongRoute,
                                      ];
                                      if (Platform.isAndroid) {
                                        if (list.contains(
                                          pages
                                              .elementAt(value)
                                              .page
                                              .runtimeType,
                                        )) {
                                          WakelockPlus.enable();
                                        } else {
                                          WakelockPlus.disable();
                                        }
                                      }
                                    },
                                  );

                                  final showGlobalPlayer = songState.showAudio;
                                  final isSongTab = tabsRouter.activeIndex == 2;
                                  final effectiveExpanded =
                                      showGlobalPlayer &&
                                      !isSongTab &&
                                      _globalMidiExpanded;
                                  final playerHeight =
                                      showGlobalPlayer && !isSongTab
                                      ? (effectiveExpanded ? 208.0 : 74.0)
                                      : 0.0;
                                  final size = 68.0;
                                  return PlayAnimationBuilder(
                                    duration: kThemeAnimationDuration,
                                    tween: Tween<double>(begin: 0, end: 1),
                                    delay: kThemeAnimationDuration,
                                    curve: Curves.easeOut,
                                    builder: (context, value, child) =>
                                        Transform.translate(
                                          offset: Offset(
                                            0,
                                            size - size * value,
                                          ),
                                          child: SizedBox(
                                            height: 72 + playerHeight,
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: nav,
                                                ),
                                                if (showGlobalPlayer &&
                                                    !isSongTab)
                                                  Positioned(
                                                    left: 0,
                                                    right: 0,
                                                    bottom:
                                                        dashboardMiniPlayerBottomOffset(
                                                          isExpanded:
                                                              effectiveExpanded,
                                                        ),
                                                    child: _DashboardMidiPlayer(
                                                      songState: songState,
                                                      isExpanded:
                                                          effectiveExpanded,
                                                      onExpandedChanged: (value) {
                                                        if (_globalMidiExpanded ==
                                                            value) {
                                                          return;
                                                        }
                                                        setState(() {
                                                          _globalMidiExpanded =
                                                              value;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                  );
                                },
                              ),
                            ),
                          ),
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

class _DashboardMidiPlayer extends StatelessWidget {
  final SongState songState;
  final bool isExpanded;
  final ValueChanged<bool> onExpandedChanged;

  const _DashboardMidiPlayer({
    required this.songState,
    required this.isExpanded,
    required this.onExpandedChanged,
  });

  String _formatTime(double seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toInt();
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final cubit = context.read<SongCubit>();
    final title = songState.getSongTitleAt(songState.pageIndex);
    return AnimatedBuilder(
      animation: cubit.midiEngine,
      builder: (context, _) {
        final midiState = cubit.midiEngine.state;
        if (!isExpanded) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 52,
                height: 52,
                child: FilledButton(
                  onPressed: () => onExpandedChanged(true),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Icon(Icons.music_note_rounded, size: 22),
                ),
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
                bottom: Radius.circular(12),
              ),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.75),
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.1),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => onExpandedChanged(false),
                  child: Container(
                    color: colors.primary,
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.music_note_rounded,
                          size: 16,
                          color: colors.onPrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title.trim().isEmpty
                                ? 'Mini Player'
                                : 'Mini Player: $title',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.labelLarge?.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colors.onPrimary,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: songState.songs.length > 1
                                ? () => cubit.goToPreviousSong()
                                : null,
                            icon: Icon(
                              Icons.skip_previous_rounded,
                              color: songState.songs.length > 1
                                  ? colors.onSurface
                                  : colors.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: FilledButton(
                              onPressed: songState.isAudioLoading
                                  ? null
                                  : cubit.togglePlayPause,
                              style: FilledButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: EdgeInsets.zero,
                                backgroundColor: colors.primary,
                              ),
                              child: songState.isAudioLoading
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          colors.onPrimary,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      midiState.isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: colors.onPrimary,
                                      size: 24,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const SizedBox(width: 4),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: songState.songs.length > 1
                                ? () => cubit.goToNextSong()
                                : null,
                            icon: Icon(
                              Icons.skip_next_rounded,
                              color: songState.songs.length > 1
                                  ? colors.onSurface
                                  : colors.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 0,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 0,
                                ),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: midiState.duration > 0
                                    ? midiState.position.clamp(
                                        0,
                                        midiState.duration,
                                      )
                                    : 0,
                                max: midiState.duration > 0
                                    ? midiState.duration
                                    : 1,
                                onChanged: midiState.duration > 0
                                    ? (seconds) => cubit.seek(
                                        Duration(seconds: seconds.toInt()),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_formatTime(midiState.position)} / ${_formatTime(midiState.duration)}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Transpose',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.outlineVariant),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => cubit.setTranspose(
                                    songState.transposeStep - 1,
                                  ),
                                  icon: const Icon(Icons.remove_rounded),
                                ),
                                SizedBox(
                                  width: 24,
                                  child: Text(
                                    '${songState.transposeStep}',
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.titleMedium,
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => cubit.setTranspose(
                                    songState.transposeStep + 1,
                                  ),
                                  icon: const Icon(Icons.add_rounded),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.outlineVariant),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () =>
                                      cubit.setTempo(songState.tempoBpm - 5),
                                  icon: const Icon(Icons.remove_rounded),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '${songState.tempoBpm.toInt()}',
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.titleSmall,
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () =>
                                      cubit.setTempo(songState.tempoBpm + 5),
                                  icon: const Icon(Icons.add_rounded),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.outlineVariant),
                            ),
                            child: IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () => cubit.toggleAccidentalMode(),
                              icon: Text(
                                songState.chordAccidentalMode ==
                                        ChordService.accidentalSharp
                                    ? '♯'
                                    : '♭',
                                style: context.textTheme.titleMedium,
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: midiLoopModeTooltip(
                              songState.playlistAutoNextMode,
                            ),
                            onPressed: cubit.cycleLoopMode,
                            icon: Icon(
                              midiLoopModeIcon(songState.playlistAutoNextMode),
                              color:
                                  midiLoopModeActive(
                                    songState.playlistAutoNextMode,
                                  )
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.90),
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
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
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var i = 0; i < destinations.length; i++)
                    Flexible(
                      child: _HymnalBottomNavItem(
                        destination: destinations[i],
                        selected: i == activeIndex,
                        onTap: () => onTap(i),
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

class _HymnalBottomNavItem extends StatelessWidget {
  final DashboardNavigationDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const _HymnalBottomNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final foreground = selected
        ? colors.primary
        : colors.onSurface.withValues(alpha: 0.68);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
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
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
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
                    size: 22,
                    color: foreground,
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      destination.label.tr(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: foreground,
                        fontSize: 10,
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
                                      AutoTabsRouter.of(context)
                                          .setActiveIndex(2);
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

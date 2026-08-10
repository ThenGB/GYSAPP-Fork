import 'package:app_links/app_links.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../components/components.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../di/injection.dart';
import '../../../router/router.dart';
import '../../initial/widgets/church_startup_splash.dart';
import '../../presentations.dart';
import '../../song/widgets/draggable_midi_controls.dart';
import '../widgets/dashboard_drawer.dart';

class DashboardNavigationDestination {
  const DashboardNavigationDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.page,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final PageRouteInfo<dynamic> page;
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

const bool kDashboardExtendsBodyForMiniPlayerOverlay = false;
const double kDashboardPortraitBottomNavHeight = 64;
const double kDashboardLandscapeBottomNavHeight = 60;
const double kDashboardNavMaxWidth = 700;
const double kDashboardNavMinInteractiveExtent = 48;
const double kDashboardNavHorizontalInset = 12;

void openDashboardDrawer() {
  dashboardScaffoldKey.currentState?.openDrawer();
}

@RoutePage()
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with WidgetsBindingObserver {
  final _appLinks = AppLinks();
  TabsRouter? tabRouter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => initUniLinks());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      WakelockPlus.disable();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      di<BibleCubit>().incrementTodayReading();
    }
  }

  Future<void> initUniLinks() async {
    if (kIsWeb) return;
    try {
      _appLinks.uriLinkStream.listen((uri) {
        router.push(WebpageRoute(url: uri.toString()));
      });
    } on PlatformException {
      // Deep links are optional and must not prevent startup.
    }
  }

  @override
  Widget build(BuildContext context) {
    const pages = dashboardNavigationDestinations;
    const bottomPages = dashboardBottomNavigationDestinations;

    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardCubit>(create: (_) => di(), lazy: false),
        BlocProvider<BibleCubit>(create: (_) => di(), lazy: false),
        BlocProvider<HomeCubit>(create: (_) => di()),
        BlocProvider<FaithCubit>(create: (_) => di()),
        BlocProvider<SettingsCubit>(create: (_) => di()),
        BlocProvider<AssetManagementCubit>(create: (_) => di()),
      ],
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.isLoading) return const _DashboardLoadingView();

          // ignore: deprecated_member_use
          return WillPopScope(
            onWillPop: () async {
              if (tabRouter?.activeIndex != 0) {
                context.read<BibleCubit>().stopSpeaking();
                final selecting = [
                  context.read<BibleCubit>().isSelectingBible,
                  context.read<SongCubit>().isSelectingSong,
                  context.read<FaithCubit>().isSelectingFaith,
                ].contains(true);
                if (selecting) {
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
            child: AutoTabsRouter(
              routes: pages.map((destination) => destination.page).toList(),
              transitionBuilder: (context, child, animation) => FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
                child: child,
              ),
              builder: (context, child) {
                final tabsRouter = AutoTabsRouter.of(context);
                tabRouter = tabsRouter;
                final selectedIndex = tabsRouter.activeIndex < bottomPages.length
                    ? tabsRouter.activeIndex
                    : -1;
                final navHeight =
                    MediaQuery.orientationOf(context) == Orientation.landscape
                    ? kDashboardLandscapeBottomNavHeight
                    : kDashboardPortraitBottomNavHeight;

                return Scaffold(
                  key: dashboardScaffoldKey,
                  backgroundColor: context.colorScheme.surface,
                  extendBody: kDashboardExtendsBodyForMiniPlayerOverlay,
                  drawer: const DashboardDrawer(),
                  body: Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(child: child),
                      BlocBuilder<SongCubit, SongState>(
                        buildWhen: (prev, curr) =>
                            prev.showAudio != curr.showAudio ||
                            prev.isAudioPlaying != curr.isAudioPlaying ||
                            prev.isAudioLoading != curr.isAudioLoading ||
                            prev.transposeStep != curr.transposeStep ||
                            prev.tempoBpm != curr.tempoBpm ||
                            prev.playlistAutoNextMode !=
                                curr.playlistAutoNextMode ||
                            prev.showChord != curr.showChord ||
                            prev.bookCode != curr.bookCode ||
                            prev.midiInstrument != curr.midiInstrument ||
                            prev.originalFamilyChord !=
                                curr.originalFamilyChord ||
                            prev.originalPdfKey != curr.originalPdfKey ||
                            prev.chordAccidentalMode !=
                                curr.chordAccidentalMode ||
                            prev.soundFont != curr.soundFont,
                        builder: (context, midiState) {
                          if (!midiState.showAudio) {
                            return const SizedBox.shrink();
                          }
                          final songCubit = context.read<SongCubit>();
                          return DraggableMidiControls(
                            key: const ValueKey('midi_overlay'),
                            isPlaying: midiState.isAudioPlaying,
                            isLoading: midiState.isAudioLoading,
                            position: 0,
                            duration: 0,
                            stateStream: songCubit.midiEngine.stateStream,
                            transposeStep: midiState.transposeStep,
                            currentKey: midiState.activeKeyLabel,
                            availableKeys: midiState.transposeKeyOptions,
                            tempoBpm: midiState.tempoBpm,
                            autoNextMode: midiState.playlistAutoNextMode,
                            midiInstrument: midiState.midiInstrument,
                            onMidiInstrument: songCubit.setMidiInstrument,
                            onPlayPause: songCubit.togglePlayPause,
                            onLoopModeCycle: songCubit.cycleLoopMode,
                            onSeek: (value) => songCubit.seek(
                              Duration(milliseconds: (value * 1000).round()),
                            ),
                            onTranspose: songCubit.setTranspose,
                            onKeySelected: songCubit.setTransposeKey,
                            onTempo: songCubit.setTempo,
                            onPreviousSong: songCubit.goToPreviousSong,
                            onNextSong: songCubit.goToNextSong,
                            showChord: midiState.showChord,
                            chordToggleEnabled: midiState.bookCode != 'HYMNE',
                            onToggleChord: songCubit.toggleChord,
                            chordAccidentalMode: midiState.chordAccidentalMode,
                            onToggleAccidental: songCubit.toggleAccidentalMode,
                          );
                        },
                      ),
                    ],
                  ),
                  // Visually floating, structurally reserved: the bubble keeps
                  // its airy dock appearance while Scaffold guarantees that
                  // reader content is never painted underneath it.
                  bottomNavigationBar: SafeArea(
                    top: false,
                    minimum: const EdgeInsets.fromLTRB(
                      kDashboardNavHorizontalInset,
                      6,
                      kDashboardNavHorizontalInset,
                      8,
                    ),
                    child: Center(
                      heightFactor: 1,
                      child: DashboardNavigationDock(
                        height: navHeight,
                        selectedIndex: selectedIndex,
                        destinations: bottomPages,
                        onDestinationSelected: (index) {
                          context.read<BibleCubit>().stopSpeaking();
                          tabsRouter.setActiveIndex(index);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _DashboardLoadingView extends StatelessWidget {
  const _DashboardLoadingView();

  @override
  Widget build(BuildContext context) => const ChurchStartupSplash();
}

class DashboardNavigationDock extends StatelessWidget {
  const DashboardNavigationDock({
    super.key,
    required this.height,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final double height;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<DashboardNavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kDashboardNavMaxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh.withValues(alpha: 0.97),
            borderRadius: context.appRadius(24),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.48),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.13),
                blurRadius: 18,
                spreadRadius: -4,
                offset: const Offset(0, 7),
              ),
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.07),
                blurRadius: 22,
                spreadRadius: -8,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: context.appRadius(24),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: height,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final count = destinations.length;
                  final hasSelection = selectedIndex >= 0 && selectedIndex < count;
                  final safeIndex = hasSelection ? selectedIndex : 0;
                  final indicatorX = count <= 1
                      ? 0.0
                      : -1 + (2 * safeIndex / (count - 1));
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: hasSelection ? 1 : 0,
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment(indicatorX, 0),
                          child: FractionallySizedBox(
                            widthFactor: 1 / count,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer.withValues(
                                    alpha: 0.82,
                                  ),
                                  borderRadius: context.appRadius(19),
                                  border: Border.all(
                                    color: colors.primary.withValues(alpha: 0.16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(count, (index) {
                          final destination = destinations[index];
                          final selected = index == selectedIndex;
                          final foreground = selected
                              ? colors.onPrimaryContainer
                              : colors.onSurfaceVariant;
                          return Expanded(
                            child: Semantics(
                              selected: selected,
                              button: true,
                              label: destination.label.tr(),
                              child: InkWell(
                                borderRadius: context.appRadius(19),
                                onTap: () => onDestinationSelected(index),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 5,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        switchInCurve: Curves.easeOutBack,
                                        switchOutCurve: Curves.easeIn,
                                        transitionBuilder: (child, animation) =>
                                            FadeTransition(
                                              opacity: animation,
                                              child: ScaleTransition(
                                                scale: Tween<double>(
                                                  begin: 0.78,
                                                  end: 1,
                                                ).animate(animation),
                                                child: child,
                                              ),
                                            ),
                                        child: Icon(
                                          selected
                                              ? destination.selectedIcon ??
                                                    destination.icon
                                              : destination.icon,
                                          key: ValueKey('$index-$selected'),
                                          size: selected ? 22 : 20,
                                          color: foreground,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        curve: Curves.easeOut,
                                        style:
                                            context.textTheme.labelSmall?.copyWith(
                                              fontSize: context.appFontSize(9.5),
                                              color: foreground,
                                              fontWeight: selected
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                            ) ??
                                            TextStyle(
                                              fontSize: context.appFontSize(9.5),
                                              color: foreground,
                                            ),
                                        child: Text(
                                          destination.label.tr(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

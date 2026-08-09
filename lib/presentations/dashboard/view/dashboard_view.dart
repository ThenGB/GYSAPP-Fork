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
import '../../../di/injection.dart';
import '../../../router/router.dart';
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

const bool kDashboardExtendsBodyForMiniPlayerOverlay = true;
const double kDashboardMiniPlayerNavGap = 8;
const double kDashboardExpandedMiniPlayerHeight = 168;
const double kDashboardPortraitBottomNavHeight = 72;
const double kDashboardLandscapeBottomNavHeight = 72;
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
const double kDashboardNavHorizontalInset = 12;
const double kDashboardNavBottomGap = 8;

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
  if (!isVisible) return navHeight;
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
                final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
                final selectedIndex = tabsRouter.activeIndex < bottomPages.length
                    ? tabsRouter.activeIndex
                    : -1;

                return Scaffold(
                  key: dashboardScaffoldKey,
                  backgroundColor: context.colorScheme.surface,
                  extendBody: true,
                  drawer: const DashboardDrawer(),
                  body: Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      // The active screen paints all the way to the bottom.
                      // Navigation is a true overlay instead of a
                      // bottomNavigationBar, so no rectangular strip is
                      // reserved behind the rounded dock.
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
                      Positioned(
                        left: kDashboardNavHorizontalInset,
                        right: kDashboardNavHorizontalInset,
                        bottom: kDashboardNavBottomGap + bottomInset,
                        child: DashboardNavigationDock(
                          selectedIndex: selectedIndex,
                          destinations: bottomPages,
                          onDestinationSelected: (index) {
                            context.read<BibleCubit>().stopSpeaking();
                            tabsRouter.setActiveIndex(index);
                          },
                        ),
                      ),
                    ],
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
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    isDark
                        ? Assets.assetsImagesLogoIndonesiaWhite
                        : Assets.assetsImagesLogoIndonesiaColor,
                    width: 260,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 34),
                  ClipRRect(
                    borderRadius: context.appRadius(999),
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: colors.surfaceContainerHighest,
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

class DashboardNavigationDock extends StatelessWidget {
  const DashboardNavigationDock({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

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
        child: Material(
          elevation: 5,
          shadowColor: colors.shadow.withValues(alpha: 0.22),
          color: Color.alphaBlend(
            colors.primary.withValues(alpha: 0.045),
            colors.surfaceContainerHigh.withValues(alpha: 0.98),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: context.appRadius(22),
            side: BorderSide(
              color: colors.primary.withValues(alpha: 0.14),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: kDashboardPortraitBottomNavHeight,
            child: Row(
              children: List.generate(destinations.length, (index) {
                final destination = destinations[index];
                final selected = index == selectedIndex;
                return Expanded(
                  child: Semantics(
                    selected: selected,
                    button: true,
                    label: destination.label.tr(),
                    child: InkWell(
                      onTap: () => onDestinationSelected(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            color: selected
                                ? colors.primaryContainer.withValues(alpha: 0.80)
                                : Colors.transparent,
                            borderRadius: context.appRadius(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                selected
                                    ? destination.selectedIcon ??
                                          destination.icon
                                    : destination.icon,
                                size: selected ? 22 : 21,
                                color: selected
                                    ? colors.onPrimaryContainer
                                    : colors.onSurfaceVariant,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                destination.label.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.labelSmall?.copyWith(
                                  fontSize: context.appFontSize(10),
                                  color: selected
                                      ? colors.onPrimaryContainer
                                      : colors.onSurfaceVariant,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

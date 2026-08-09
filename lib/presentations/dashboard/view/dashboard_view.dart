import 'dart:developer';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../di/injection.dart';
import '../../../domain/entity/verse/verse.dart';
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

/// Loaded once per process — the app version does not change at runtime.
/// Web-safe: package_info_plus' web plugin isn't bundled, so the channel
/// call would throw MissingPluginException — fall back to an empty version.
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

const bool kDashboardExtendsBodyForMiniPlayerOverlay = true;
const double kDashboardMiniPlayerNavGap = 8;
const double kDashboardExpandedMiniPlayerHeight = 168;
// Dock heights MUST match _AnimatedRoundedNavBar._navBarHeight (72).
// The old 64/56 values under-padded the body by 8–16px, so the last row
// of every tab sat partially behind the dock.
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

class _DashboardViewState extends State<DashboardView>
    with WidgetsBindingObserver {
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (!kIsWeb && Platform.isAndroid) {
      WakelockPlus.disable();
    }
    super.dispose();
  }

  TabsRouter? tabRouter;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initUniLinks();
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Advance the daily reading target when the app comes back to the
    // foreground — a user who kept the app open across midnight would
    // otherwise never get today's chapter.
    //
    // NOTE: this State's context sits ABOVE the MultiBlocProvider built in
    // build() below, so context.read<BibleCubit>() would throw
    // ProviderNotFoundException here. Read the DI singleton instead — it is
    // the exact instance the provider was created from.
    if (state == AppLifecycleState.resumed && mounted) {
      di<BibleCubit>().incrementTodayReading();
    }
  }

  final _appLinks = AppLinks();

  Future<void> initUniLinks() async {
    // On web, AppLinksPluginWeb emits the CURRENT page URL as the initial
    // "link" (Stream.value(window.location.href)). Pushing a WebpageView of
    // the app's own URL on every load would yank the user out of the
    // dashboard into the webview fallback screen right at startup. Web deep
    // links are handled by the browser + router itself.
    if (kIsWeb) return;
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
                              fontSize: context.appFontSize(12),
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
            child: AutoTabsRouter(
              routes: pages.map((e) => e.page).toList(),
              transitionBuilder: (context, child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              builder: (context, child) {
                final tabsRouter = AutoTabsRouter.of(context);
                tabRouter = tabsRouter;
                final isLandscape =
                    MediaQuery.orientationOf(context) == Orientation.landscape;
                // viewPadding (hardware safe area) is stable; padding
                // changes on keyboard open/close which is needless work.
                final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
                final navHeight = isLandscape
                    ? kDashboardLandscapeBottomNavHeight
                    : kDashboardPortraitBottomNavHeight;
                // 8px breathing room so the last content row never touches
                // or hides behind the dock.
                final bodyBottomPadding = navHeight + 8 + bottomInset;

                final bottomNavItemCount = bottomNavPages.length;
                final isBeyondBottomNav =
                    tabsRouter.activeIndex >= bottomNavItemCount;
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
                      // Anchors the Stack to the full body size. Without a
                      // non-positioned child the Stack shrinks to 0x0 when
                      // every other child is Positioned AND the MIDI overlay
                      // collapses to SizedBox.shrink() (audio hidden) — which
                      // made the whole body (all tabs) invisible.
                      const SizedBox.expand(),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.colorScheme.surface,
                          ),
                          child: AnimatedPadding(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            padding: EdgeInsets.only(bottom: bodyBottomPadding),
                            child: child,
                          ),
                        ),
                      ),
                      // Global MIDI player overlay — visible on every tab so
                      // playback controls never disappear when the user
                      // navigates away from the song page.
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
                          final songCubit = context.read<SongCubit>();
                          // When the PDF viewer's MIDI toggle turns audio
                          // off, hide the player completely (pill included).
                          // It comes back automatically when a song starts.
                          if (!midiState.showAudio) {
                            return const SizedBox.shrink();
                          }
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
                            onSeek: (v) => songCubit.seek(
                              Duration(milliseconds: (v * 1000).round()),
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
        child: ColoredBox(
          color: colors.surface,
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
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _DrawerHeader(state: state),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Divider(
                                    color: colors.outlineVariant.withValues(
                                      alpha: 0.42,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    18,
                                    24,
                                    8,
                                  ),
                                  child: Text(
                                    'quick_actions_label'.tr().toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
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
                                    final lastSong =
                                        songCubit.state.lastOpenedSong;
                                    return _DrawerActivityTile(
                                      icon: Icons.music_note_rounded,
                                      label: 'last_opened'.tr(),
                                      value: lastSong != null
                                          ? '${lastSong.code ?? ''} ${lastSong.number ?? ''} — ${lastSong.title ?? ''}'
                                          : 'no_history'.tr(),
                                      onTap: lastSong != null
                                          ? () {
                                              dashboardScaffoldKey.currentState
                                                  ?.closeDrawer();
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
                                const SizedBox(height: 8),
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  leading: Icon(
                                    Icons.settings_outlined,
                                    color: colors.primary,
                                    size: 22,
                                  ),
                                  title: Text(
                                    'Pengaturan'.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: colors.onSurface,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right_rounded,
                                    color: colors.onSurfaceVariant.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  onTap: () {
                                    dashboardScaffoldKey.currentState
                                        ?.closeDrawer();
                                    AutoTabsRouter.of(
                                      context,
                                    ).setActiveIndex(4);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!state.isLoggedIn) ...[
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: colors.onPrimary,
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: context.appRadius(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    final cubit = context
                                        .read<DashboardCubit>();
                                    dashboardScaffoldKey.currentState
                                        ?.closeDrawer();
                                    router.push(
                                      LoginRoute(
                                        onLoggedIn: (token) {
                                          try {
                                            router.maybePop();
                                            cubit.loginSuccessCallback(token);
                                          } catch (e, st) {
                                            debugPrint(
                                              '[DashboardView] onLoggedIn ERROR: $e\n$st',
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.login_rounded),
                                  label: Text('Login'.tr()),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: colors.outlineVariant,
                                    ),
                                    minimumSize: const Size.fromHeight(44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: context.appRadius(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    dashboardScaffoldKey.currentState
                                        ?.closeDrawer();
                                    SystemNavigator.pop();
                                  },
                                  icon: Icon(
                                    Icons.exit_to_app_rounded,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  label: Text(
                                    'close_app'.tr(),
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: colors.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                    minimumSize: const Size.fromHeight(44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: context.appRadius(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    dashboardScaffoldKey.currentState
                                        ?.closeDrawer();
                                    context.router.push(
                                      WebpageRoute(url: 'https://e.gys.or.id'),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 18,
                                  ),
                                  label: Text('open_egys'.tr()),
                                ),
                                const SizedBox(height: 6),
                                TextButton(
                                  onPressed: () {
                                    final cubit = context
                                        .read<DashboardCubit>();
                                    dashboardScaffoldKey.currentState
                                        ?.closeDrawer();
                                    cubit.loginSuccessCallback(null);
                                  },
                                  child: Text(
                                    'logout'.tr(),
                                    style: TextStyle(color: colors.error),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              FutureBuilder<PackageInfo>(
                                // Memoized: PackageInfo.fromPlatform() is a
                                // platform-channel call; creating it in build()
                                // fired a new channel round-trip on every
                                // drawer rebuild.
                                future: _packageInfoFuture,
                                builder: (context, snapshot) {
                                  final version = snapshot.data?.version ?? '';
                                  return Text(
                                    'v$version',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant
                                              .withValues(alpha: 0.4),
                                          fontSize: context.appFontSize(10),
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
    final memberType = state.account?.resolvedMemberType;
    final branchName = state.account?.resolvedBranchName;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Always-white backing: the church logo asset is transparent
              // around the dove, so without this it bleeds into the dark
              // drawer and becomes unreadable in dark theme.
              color: Colors.white,
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.5),
                width: 1.4,
              ),
            ),
            child: ClipOval(
              child: state.account?.profilePicture == null
                  ? Image.asset(Assets.assetsImagesAppicon)
                  : CachedNetworkImage(
                      imageUrl: state.account!.profilePicture!,
                      fit: BoxFit.cover,
                      memCacheWidth: 120,
                      memCacheHeight: 120,
                      placeholder: (context, url) =>
                          Image.asset(Assets.assetsImagesAppicon),
                      errorWidget: (context, url, error) =>
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
                if (state.isLoggedIn &&
                    ((memberType ?? '').isNotEmpty ||
                        (branchName ?? '').isNotEmpty)) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.tertiaryContainer,
                      borderRadius: context.appRadius(6),
                    ),
                    child: Text(
                      [memberType, _formatBranchName(branchName ?? '')]
                          .whereType<String>()
                          .where((s) => s.isNotEmpty)
                          .join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onTertiaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else
                  Text(
                    state.isLoggedIn
                        ? (state.account?.email?.trim().isNotEmpty == true
                              ? state.account!.email!
                              : 'Akun GYS')
                        : 'not_logged_in'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
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
    final hasAction = onTap != null;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: context.appRadius(14),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: context.appRadius(14),
        child: Padding(
          padding: EdgeInsets.all(context.appSpace(12)),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: context.appRadius(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: hasAction
                      ? colors.primary
                      : colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.70),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: hasAction
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: hasAction
                            ? colors.onSurface
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasAction) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerProgressTile extends StatefulWidget {
  const _DrawerProgressTile();

  @override
  State<_DrawerProgressTile> createState() => _DrawerProgressTileState();
}

class _DrawerProgressTileState extends State<_DrawerProgressTile> {
  Verse? _titleFor;
  Future<String?>? _titleFuture;

  Future<String?> _titleFutureFor(BibleCubit cubit, Verse? verse) {
    final current = _titleFuture;
    if (identical(_titleFor, verse) && current != null) return current;
    _titleFor = verse;
    final future = verse == null
        ? Future<String?>.value(null)
        : cubit.getBibleTitle([verse]);
    _titleFuture = future;
    return future;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return BlocBuilder<BibleCubit, BibleState>(
      builder: (context, bibleState) {
        final cubit = context.read<BibleCubit>();
        final target = bibleState.todayReading;
        final lastOpen = bibleState.lastOpenBible;
        final readToday =
            target != null &&
            lastOpen != null &&
            _isSameDay(lastOpen, DateTime.now());

        void openReading() {
          dashboardScaffoldKey.currentState?.closeDrawer();
          AutoTabsRouter.of(context).setActiveIndex(1);
          cubit.setTodayReading(target);
        }

        final IconData leadingIcon = target == null
            ? Icons.menu_book_outlined
            : readToday
            ? Icons.check_rounded
            : Icons.auto_stories_outlined;
        final Color iconColor = target == null
            ? colors.onSurfaceVariant.withValues(alpha: 0.5)
            : colors.primary;

        return Container(
          margin: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow.withValues(alpha: 0.5),
            borderRadius: context.appRadius(14),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: InkWell(
            borderRadius: context.appRadius(14),
            onTap: target == null ? null : openReading,
            child: Padding(
              padding: EdgeInsets.all(context.appSpace(12)),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.55),
                      borderRadius: context.appRadius(12),
                    ),
                    child: Icon(leadingIcon, size: 20, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'daily_reading_label'.tr().toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colors.onSurfaceVariant.withValues(
                                        alpha: 0.70,
                                      ),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: context.appRadius(999),
                              ),
                              child: Text(
                                'HARI INI',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colors.onPrimaryContainer,
                                      fontWeight: FontWeight.w800,
                                      fontSize: context.appFontSize(9),
                                      letterSpacing: 0.6,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (target == null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'no_daily_reading'.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: colors.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'set_daily_reading_hint'.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colors.onSurfaceVariant,
                                      height: 1.3,
                                    ),
                              ),
                            ],
                          )
                        else
                          FutureBuilder<String?>(
                            future: _titleFutureFor(cubit, target),
                            builder: (context, snapshot) {
                              final title = snapshot.data ?? '';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    readToday
                                        ? 'read_today_done'.tr()
                                        : 'Today Reading'.tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: readToday
                                              ? colors.primary
                                              : colors.onSurface,
                                        ),
                                  ),
                                  if (title.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                            height: 1.3,
                                          ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  if (target != null && !readToday) ...[
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onPressed: openReading,
                      child: Text('read_action'.tr()),
                    ),
                  ] else if (target != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
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
  // Deeper than the circle radius (28) so the floating circle sinks into
  // the notch instead of colliding with its rim.
  static const double _notchDepth = 36;
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
    _notchAnimation = Tween<double>(begin: idx, end: idx).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didUpdateWidget(_AnimatedRoundedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex >= 0
          ? oldWidget.selectedIndex
          : _previousIndex;
      final beginIdx = _previousIndex.toDouble();
      final endIdx = widget.selectedIndex >= 0
          ? widget.selectedIndex.toDouble()
          : beginIdx;
      _notchAnimation = Tween<double>(begin: beginIdx, end: endIdx).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
      );
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
                      // When no tab is selected (e.g. Settings page)
                      // flatten the notch so the bar is a clean
                      // rounded rectangle.
                      notchDepth: _hasSelection ? _notchDepth : 0,
                      color: navBarColor,
                      shadowColor: Colors.black.withValues(alpha: 0.15),
                    ),
                    child: SizedBox(
                      height: _navBarHeight,
                      child: Row(
                        children: List.generate(count, (index) {
                          final dest = widget.destinations[index];
                          final isSelected =
                              _hasSelection && index == widget.selectedIndex;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => widget.onDestinationSelected(index),
                              behavior: HitTestBehavior.opaque,
                              child: SizedBox(
                                height: _navBarHeight,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSelected
                                          ? dest.selectedIcon ?? dest.icon
                                          : dest.icon,
                                      color: isSelected
                                          ? Colors.transparent
                                          : unselectedIconColor,
                                      size: 22,
                                    ),
                                    const SizedBox(height: 4),
                                    // Fade the label out/in smoothly on
                                    // selection instead of a hard swap.
                                    AnimatedOpacity(
                                      opacity: isSelected ? 0.0 : 1.0,
                                      duration: const Duration(
                                        milliseconds: 240,
                                      ),
                                      curve: Curves.easeOut,
                                      child: Text(
                                        dest.label.tr(),
                                        style: TextStyle(
                                          color: unselectedIconColor.withValues(
                                            alpha: 0.7,
                                          ),
                                          fontSize: context.appFontSize(10),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                          widget
                                  .destinations[widget.selectedIndex]
                                  .selectedIcon ??
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

    // Clamp the notch so the curves stay within the rounded corners
    // and never clip asymmetrically against the right edge.
    final safeMin = cornerRadius + halfNotch;
    final safeMax = w - cornerRadius - halfNotch;
    final cx = notchCenterX.clamp(safeMin, safeMax);
    final notchStart = cx - halfNotch;
    final notchEnd = cx + halfNotch;

    if (notchDepth <= 0) {
      // No notch — draw a flat top edge.
      path.lineTo(w - cornerRadius, 0);
    } else {
      if (notchStart > cornerRadius) {
        path.lineTo(notchStart, 0);
      }

      path.cubicTo(
        cx - halfNotch * 0.65,
        0,
        cx - halfNotch * 0.3,
        notchDepth * 0.85,
        cx,
        notchDepth,
      );
      path.cubicTo(
        cx + halfNotch * 0.3,
        notchDepth * 0.85,
        cx + halfNotch * 0.65,
        0,
        notchEnd,
        0,
      );

      if (notchEnd < w - cornerRadius) {
        path.lineTo(w - cornerRadius, 0);
      }
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

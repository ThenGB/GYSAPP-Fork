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
import '../../presentations.dart';

@RoutePage()
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void dispose() {
    WakelockPlus.disable();
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
    List<Map<String, dynamic>> pages = [
      {
        'icon': Assets.assetsImagesAppicon,
        'label': 'Home',
        'page': const HomeRoute(),
      },
      {
        'icon': Assets.assetsIconsCross,
        'label': 'Bible',
        'page': const BibleRoute(),
      },
      {
        'icon': Assets.assetsIconsBook,
        'label': 'Song',
        'page': const SongRoute(),
      },
      {
        'icon': Assets.assetsIconsFaith,
        'label': 'Faith',
        'page': const FaithRoute(),
      },
      {
        'icon': Assets.assetsIconsCog,
        'label': 'Settings',
        'page': const SettingsRoute(),
      },
    ];
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardCubit>(
          create: (context) => di(),
          lazy: false,
        ),
        BlocProvider<HomeCubit>(
          create: (context) => di(),
        ),
        BlocProvider<BibleCubit>(
          create: (context) => di(),
        ),
        BlocProvider<FaithCubit>(
          create: (context) => di(),
        ),
        BlocProvider<SettingsCubit>(
          create: (context) => di(),
        ),
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
                              begin: 0.0, end: 1.0), // Keep the original tween
                          builder: (context, value, child) {
                            double scale = 1 +
                                (0.1 *
                                    value); // Interpolate to get scale between 1 and 1.3
                            double opacity = 1 -
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
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            'Preparing dashboard',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: context.textColor?.withOpacity(.5),
                            ),
                          )
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
            child: WillPopScope(
              onWillPop: () async {
                if (tabRouter?.activeIndex != 0) {
                  context.read<BibleCubit>().stopSpeaking();
                  context.read<SongCubit>().pause();
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
                backgroundColor: context.colorScheme.surface,
                routes: pages.map((e) => e['page'] as PageRouteInfo).toList(),
                transitionBuilder: (context, child, animation) {
                  return Column(
                    children: [
                      Expanded(
                          child:
                              FadeTransition(opacity: animation, child: child)),
                      AnimatedSize(
                        alignment: Alignment.bottomCenter,
                        duration: kThemeAnimationDuration,
                        child: (state.isSyncing)
                            ? SafeArea(
                                top: false,
                                child: Text(state.message ?? 'Syncing'),
                              )
                            : const SizedBox(
                                width: double.infinity,
                              ),
                      ),
                    ],
                  );
                },
                bottomNavigationBuilder: (context, tabsRouter) {
                  tabRouter = tabsRouter;
                  return BlocBuilder<SongCubit, SongState>(
                    builder: (context, songState) =>
                        BlocBuilder<FaithCubit, FaithState>(
                      builder: (context, faithState) =>
                          BlocBuilder<BibleCubit, BibleState>(
                        builder: (context, state) => AnimatedSize(
                          duration: kThemeAnimationDuration,
                          alignment: Alignment.bottomCenter,
                          curve: Curves.easeOut,
                          child: OrientationBuilder(
                            builder: (context, orientation) {
                              var isLandscape =
                                  context.mediaQuery.orientation ==
                                      Orientation.landscape;
                              var songCondition =
                                  isLandscape && tabsRouter.activeIndex == 2;
                              var bibleCondition =
                                  state.selectedVerse.isNotEmpty;
                              var faithCondition =
                                  faithState.selectedFaith.isNotEmpty;
                              var songCondition2 =
                                  songState.selectedSong != null;
                              if (songCondition ||
                                  bibleCondition ||
                                  faithCondition ||
                                  songCondition2) {
                                return SizedBox(
                                  width: double.infinity,
                                );
                              }
                              var size =
                                  58 + context.mediaQuery.viewPadding.bottom;
                              return PlayAnimationBuilder(
                                duration: kThemeAnimationDuration,
                                tween: Tween<double>(begin: 0, end: 1),
                                delay: kThemeAnimationDuration,
                                curve: Curves.easeOut,
                                builder: (context, value, child) =>
                                    Transform.translate(
                                  offset: Offset(0, size - size * value),
                                  child: SizedBox(
                                    height: size,
                                    child: BottomNavigationBar(
                                      elevation: 8,
                                      backgroundColor:
                                          context.colorScheme.surface,
                                      currentIndex: tabsRouter.activeIndex,
                                      selectedItemColor: context
                                          .primaryTextTheme.bodyMedium!.color,
                                      showUnselectedLabels: true,
                                      type: BottomNavigationBarType.fixed,
                                      selectedLabelStyle: TextStyle(
                                        color:
                                            context.textTheme.bodyMedium!.color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      unselectedLabelStyle: TextStyle(
                                        fontSize: 12,
                                        color:
                                            context.textTheme.bodyMedium!.color,
                                      ),
                                      onTap: (value) {
                                        context
                                            .read<BibleCubit>()
                                            .stopSpeaking();
                                        context.read<SongCubit>().pause();
                                        tabsRouter.setActiveIndex(value);
                                        var list = [
                                          BibleRoute,
                                          FaithRoute,
                                          SongRoute
                                        ];
                                        if (Platform.isAndroid) {
                                          // Permission.wakelockWakelockPlus;
                                          if (list.contains(pages
                                              .elementAt(value)['page']
                                              .runtimeType)) {
                                            WakelockPlus.enable();
                                            if (pages
                                                    .elementAt(value)['page']
                                                    .runtimeType !=
                                                SongRoute) {
                                              context
                                                  .read<SongCubit>()
                                                  .toggleAudio(false);
                                            }
                                          } else {
                                            WakelockPlus.disable();
                                          }
                                        }
                                      },
                                      items: pages
                                          .map(
                                            (e) => BottomNavigationBarItem(
                                              icon: Container(
                                                margin: const EdgeInsets.only(
                                                        bottom: 4)
                                                    .add(const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8)),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  color: pages.indexOf(e) ==
                                                          tabsRouter.activeIndex
                                                      ? context
                                                          .theme.disabledColor
                                                          .withOpacity(.1)
                                                      : null,
                                                ),
                                                width: double.infinity,
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                    tabsRouter.activeIndex ==
                                                            pages.indexOf(e)
                                                        ? context
                                                            .primaryTextTheme
                                                            .bodyMedium!
                                                            .color!
                                                        : context.textTheme
                                                            .bodyMedium!.color!
                                                            .withOpacity(0.5),
                                                    pages.indexOf(e) == 0
                                                        ? BlendMode.dstIn
                                                        : BlendMode.srcIn,
                                                  ),
                                                  child: Image.asset(
                                                    e['icon'] as String,
                                                    width: 24,
                                                    height: 24,
                                                  ),
                                                ),
                                              ),
                                              label:
                                                  (e['label'] as String).tr(),
                                            ),
                                          )
                                          .toList(),
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

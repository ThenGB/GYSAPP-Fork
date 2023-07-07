import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:wakelock/wakelock.dart';

import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/variables/assets.dart';
import '../../../di/injection.dart';
import '../../../router/router.dart';
import '../../bible/cubit/bible_cubit.dart';
import '../../faith/cubit/faith_cubit.dart';
import '../../faith/cubit/faith_state.dart';
import '../../home/bloc/home_cubit.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../song/cubit/song_cubit.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';

@RoutePage()
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }

  TabsRouter? tabRouter;

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
        BlocProvider<SongCubit>(
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
            return const Center(
              child: CircularProgressIndicator(),
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
                  tabRouter?.setActiveIndex(0);
                  return false;
                }
                return true;
              },
              child: AutoTabsScaffold(
                backgroundColor: context.colorScheme.background,
                routes: pages.map((e) => e['page'] as PageRouteInfo).toList(),
                transitionBuilder: (context, child, animation) {
                  return Column(
                    children: [
                      Expanded(child: child),
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

                              return PlayAnimationBuilder(
                                duration: kThemeAnimationDuration,
                                tween: Tween<double>(begin: 0, end: 1),
                                delay: kThemeAnimationDuration,
                                curve: Curves.easeOut,
                                builder: (context, value, child) =>
                                    Transform.translate(
                                  offset: Offset(0, 80 - 80 * value),
                                  child: SizedBox(
                                    height: 80,
                                    child: BottomNavigationBar(
                                      elevation: 8,
                                      backgroundColor:
                                          context.colorScheme.background,
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
                                        tabsRouter.setActiveIndex(value);
                                        var list = [
                                          BibleRoute,
                                          FaithRoute,
                                          SongRoute
                                        ];
                                        if (list.contains(pages
                                            .elementAt(value)['page']
                                            .runtimeType)) {
                                          Wakelock.enable();
                                        } else {
                                          Wakelock.disable();
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
                                                        horizontal: 4)),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
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
                                                    width: 32,
                                                    height: 32,
                                                  ),
                                                ),
                                              ),
                                              label: (e['label'] as String),
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

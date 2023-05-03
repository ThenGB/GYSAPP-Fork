import 'package:auto_route/auto_route.dart';
import 'package:church/data/utilities/extensions/context_ext.dart';
import 'package:church/presentations/bible/cubit/bible_cubit.dart';
import 'package:church/presentations/dashboard/cubit/dashboard_cubit.dart';
import 'package:church/presentations/dashboard/cubit/dashboard_state.dart';
import 'package:church/presentations/home/bloc/home_cubit.dart';
import 'package:church/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/utilities/variables/assets.dart';
import '../../../di/injection.dart';

@RoutePage()
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

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
            child: AutoTabsScaffold(
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
              bottomNavigationBuilder: (context, tabsRouter) =>
                  BottomNavigationBar(
                elevation: 8,
                backgroundColor: context.colorScheme.background,
                currentIndex: tabsRouter.activeIndex,
                selectedItemColor: context.primaryTextTheme.bodyMedium!.color,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                selectedLabelStyle: TextStyle(
                  color: context.textTheme.bodyMedium!.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 12,
                  color: context.textTheme.bodyMedium!.color,
                ),
                onTap: (value) {
                  tabsRouter.setActiveIndex(value);
                },
                items: pages
                    .map(
                      (e) => BottomNavigationBarItem(
                        icon: Container(
                          margin: const EdgeInsets.only(bottom: 4)
                              .add(const EdgeInsets.symmetric(horizontal: 4)),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: pages.indexOf(e) == tabsRouter.activeIndex
                                ? context.theme.disabledColor.withOpacity(.1)
                                : null,
                          ),
                          width: double.infinity,
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              tabsRouter.activeIndex == pages.indexOf(e)
                                  ? context.primaryTextTheme.bodyMedium!.color!
                                  : context.textTheme.bodyMedium!.color!
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
          );
        },
      ),
    );
  }
}

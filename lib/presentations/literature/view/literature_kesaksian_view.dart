import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/variables/assets.dart';
import '../../../di/injection.dart';
import '../../../router/router.dart';
import '../cubit/kesaksian/literature_kesaksian_cubit.dart';

@RoutePage()
class LiteratureKesaksianView extends StatelessWidget {
  const LiteratureKesaksianView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LiteratureKesaksianCubit>(
      create: (context) => di(),
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              BlocBuilder<LiteratureKesaksianCubit, LiteratureKesaksianState>(
                builder: (context, state) => SliverAppBar.large(
                  shape: Border(
                    bottom: BorderSide(
                      color: context.colorScheme.primary.withValues(
                        alpha: 0.55,
                      ),
                    ),
                  ),
                  backgroundColor: context.colorScheme.surface,
                  foregroundColor: context.colorScheme.primary,
                  surfaceTintColor: Colors.transparent,
                  actions: [
                    if (!state.isLoading)
                      IconButton(
                        tooltip: 'Reload'.tr(),
                        onPressed: () {
                          context.read<LiteratureKesaksianCubit>().getData();
                        },
                        icon: const Icon(Icons.replay),
                      ),
                  ],
                  forceElevated: innerBoxIsScrolled,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      foregroundDecoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.theme.scaffoldBackgroundColor,
                            context.theme.scaffoldBackgroundColor.withValues(
                              alpha: 0,
                            ),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Image.asset(
                        Assets.assetsImagesKesaksian,
                        fit: BoxFit.cover,
                      ),
                    ),
                    centerTitle: true,
                    title: const Text('Kesaksian'),
                  ),
                  pinned: true,
                ),
              ),
            ];
          },
          body: BlocBuilder<LiteratureKesaksianCubit, LiteratureKesaksianState>(
            builder: (context, state) => state.isLoading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator.adaptive())
                : state.items.isEmpty
                ? Center(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<LiteratureKesaksianCubit>().getData();
                      },
                      child: const Text('Reload'),
                    ),
                  )
                : Stack(
                    children: [
                      ListView.builder(
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          var item = state.items[index];
                          return Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: context.colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: context.colorScheme.outlineVariant
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  router.push(WebpageRoute(url: item.url));
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  height: 56,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(item.title)),
                                      const Icon(Icons.open_in_new),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      if (state.isLoading)
                        const LinearProgressIndicator(minHeight: 2),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

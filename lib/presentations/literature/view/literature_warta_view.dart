import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/variables/assets.dart';
import '../../../di/injection.dart';
import '../../../domain/entity/warta/warta_entity.dart';
import '../../../router/router.dart';
import '../cubit/warta/literature_warta_cubit.dart';

@RoutePage()
class LiteratureWartaView extends StatelessWidget {
  const LiteratureWartaView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LiteratureWartaCubit>(
      create: (context) => di(),
      child: Scaffold(
        body: BlocBuilder<LiteratureWartaCubit, LiteratureWartaState>(
          builder: (context, state) => NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar.large(
                  actions: [
                    if (!state.isLoading)
                      IconButton(
                        tooltip: 'Reload'.tr(),
                        onPressed: () {
                          context.read<LiteratureWartaCubit>().getData();
                        },
                        icon: const Icon(Icons.replay),
                      )
                  ],
                  forceElevated: innerBoxIsScrolled,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      foregroundDecoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.theme.scaffoldBackgroundColor,
                            context.theme.scaffoldBackgroundColor
                                .withValues(alpha: 0),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Image.asset(
                        Assets.assetsImagesWartasejati,
                        fit: BoxFit.cover,
                      ),
                    ),
                    centerTitle: true,
                    title: Text(
                      'Manna Magazine'.tr(),
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: state.isLoading && state.items.isEmpty
                ? const Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : state.items.isEmpty
                    ? Center(
                        child: ElevatedButton(
                            onPressed: () {
                              context.read<LiteratureWartaCubit>().getData();
                            },
                            child: const Text('Reload')),
                      )
                    : Stack(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.only(left: 16, top: 32),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double maxWidth =
                                    (constraints.maxWidth / 2 - 16)
                                        .clamp(0, 300);
                                return Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: state.items
                                      .asMap()
                                      .entries
                                      .map((e) => ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: GestureDetector(
                                              onTap: () {
                                                router.push(WebpageRoute(
                                                    url: e.value.url));
                                              },
                                              onLongPress: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  isScrollControlled: true,
                                                  elevation: 0,
                                                  builder: (context) {
                                                    return WartaSheet(
                                                      item: e.value,
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                width: maxWidth,
                                                color: Colors.blueGrey
                                                    .withValues(alpha: .3),
                                                child: AspectRatio(
                                                  aspectRatio: 3 / 4,
                                                  child: CachedNetworkImage(
                                                    imageUrl: e.value.imageUrl,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                );
                              },
                            ),
                          ),

                          // ListView.builder(
                          //   itemCount: state.items.length,
                          //   itemBuilder: (context, index) {
                          //     var item = state.items[index];
                          //     return Container(
                          //       clipBehavior: Clip.antiAlias,
                          //       decoration: BoxDecoration(
                          //           boxShadow: [
                          //             BoxShadow(
                          //               blurRadius: 2,
                          //               color: Colors.black.withValues(alpha: .2),
                          //               offset: const Offset(0, 1),
                          //             ),
                          //           ],
                          //           color: context.colorScheme.background,
                          //           borderRadius: BorderRadius.circular(8)),
                          //       margin: const EdgeInsets.symmetric(
                          //           horizontal: 8, vertical: 4),
                          //       child: Stack(
                          //         children: [
                          //           Align(
                          //             alignment: Alignment.centerRight,
                          //             child: Container(
                          //               foregroundDecoration: BoxDecoration(
                          //                 gradient: LinearGradient(
                          //                   colors: [
                          //                     context.colorScheme.background,
                          //                     context.colorScheme.background
                          //                         .withValues(alpha: .2),
                          //                   ],
                          //                   begin: Alignment.centerLeft,
                          //                   end: Alignment.centerRight,
                          //                 ),
                          //               ),
                          //               child: CachedNetworkImage(
                          //                 imageUrl: item.imageUrl,
                          //                 height: 56,
                          //                 width: context.width / 2,
                          //                 fit: BoxFit.cover,
                          //                 alignment: Alignment.centerRight,
                          //               ),
                          //             ),
                          //           ),
                          //           Material(
                          //             color: Colors.transparent,
                          //             child: InkWell(
                          //               onTap: () {
                          //                 router.push(
                          //                     WebpageRoute(url: item.url));
                          //               },
                          //               child: Container(
                          //                 padding: const EdgeInsets.symmetric(
                          //                     horizontal: 16),
                          //                 height: 56,
                          //                 alignment: Alignment.centerLeft,
                          //                 child: Text(item.title),
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     );
                          //   },
                          // ),

                          if (state.isLoading)
                            const LinearProgressIndicator(
                              minHeight: 2,
                            ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}

class WartaSheet extends StatelessWidget {
  final Warta item;
  const WartaSheet({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: .5,
      initialChildSize: .5,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: Scaffold(
            bottomNavigationBar: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    foregroundColor: context.colorScheme.onPrimary,
                    fixedSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () {
                    router.popAndPush(WebpageRoute(url: item.url));
                  },
                  child: const Text('Buka')),
            ),
            body: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Center(
                    child: SizedBox(
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: item.imageUrl,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

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
        backgroundColor: context.colorScheme.surface,
        body: BlocBuilder<LiteratureWartaCubit, LiteratureWartaState>(
          builder: (context, state) => NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar.large(
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
                          context.read<LiteratureWartaCubit>().getData();
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
                        Assets.assetsImagesWartasejati,
                        fit: BoxFit.cover,
                      ),
                    ),
                    centerTitle: true,
                    title: Text('Manna Magazine'.tr()),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: state.isLoading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator.adaptive())
                : state.items.isEmpty
                ? Center(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<LiteratureWartaCubit>().getData();
                      },
                      child: const Text('Reload'),
                    ),
                  )
                : Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double maxWidth = (constraints.maxWidth / 2 - 16)
                                .clamp(0, 300);
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: state.items
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: GestureDetector(
                                        onTap: () {
                                          router.push(
                                            WebpageRoute(url: e.value.url),
                                          );
                                        },
                                        onLongPress: () {
                                          showModalBottomSheet(
                                            context: context,
                                            backgroundColor: Colors.transparent,
                                            isScrollControlled: true,
                                            elevation: 0,
                                            builder: (context) {
                                              return WartaSheet(item: e.value);
                                            },
                                          );
                                        },
                                        child: Container(
                                          width: maxWidth,
                                          decoration: BoxDecoration(
                                            color: context
                                                .colorScheme
                                                .surfaceContainerLowest,
                                            border: Border.all(
                                              color: context
                                                  .colorScheme
                                                  .outlineVariant
                                                  .withValues(alpha: 0.55),
                                            ),
                                          ),
                                          child: AspectRatio(
                                            aspectRatio: 3 / 4,
                                            child: CachedNetworkImage(
                                              imageUrl: e.value.imageUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
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

class WartaSheet extends StatelessWidget {
  final Warta item;
  const WartaSheet({super.key, required this.item});

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
                child: const Text('Buka'),
              ),
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
                        borderRadius: BorderRadius.circular(16),
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
                  const SizedBox(height: 16),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/components.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../router/router.dart';

/// Normalized feed item shared by every literature section. All four content
/// types (warta, kesaksian, renungan, panduan) expose title/url/imageUrl.
class LiteratureFeedItem {
  const LiteratureFeedItem({
    required this.url,
    required this.imageUrl,
    required this.title,
  });

  final String url;
  final String imageUrl;
  final String title;
}

/// One parameterized feed screen for every literature section. The four
/// legacy views were structurally identical (SliverAppBar + NestedScrollView +
/// item list) and only differed in their cubit, title, header image, and
/// whether items render as cover tiles or text rows.
///
/// The owning view keeps ownership of the cubit; this widget only listens to
/// it through [BlocBuilder]'s `bloc:` parameter.
class LiteratureFeedScaffold<C extends StateStreamable<S>, S>
    extends StatelessWidget {
  const LiteratureFeedScaffold({
    super.key,
    required this.cubit,
    required this.title,
    required this.isLoadingOf,
    required this.itemsOf,
    required this.reload,
    this.headerAsset,
    this.gridCovers = false,
    this.onItemLongPress,
  });

  final C cubit;
  final String title;
  final String? headerAsset;
  final bool Function(S state) isLoadingOf;
  final List<LiteratureFeedItem> Function(S state) itemsOf;
  final Future<void> Function() reload;

  /// When true, items render as a 3:4 cover grid (warta); otherwise as
  /// text rows with an open-in-new affordance.
  final bool gridCovers;

  final void Function(BuildContext context, LiteratureFeedItem item)?
  onItemLongPress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: BlocBuilder<C, S>(
        bloc: cubit,
        builder: (context, state) {
          final items = itemsOf(state);
          final isLoading = isLoadingOf(state);
          return NestedScrollView(
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
                    if (!isLoading)
                      IconButton(
                        tooltip: 'Reload'.tr(),
                        onPressed: reload,
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
                      child: headerAsset == null
                          ? null
                          : Image.asset(
                              headerAsset!,
                              fit: BoxFit.cover,
                            ),
                    ),
                    centerTitle: true,
                    title: Text(title),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: isLoading && items.isEmpty
                ? const Center(child: CircularProgressIndicator.adaptive())
                : items.isEmpty
                ? Center(
                    child: ElevatedButton(
                      onPressed: reload,
                      child: Text('Reload'.tr()),
                    ),
                  )
                : Stack(
                    children: [
                      if (gridCovers)
                        SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final maxWidth = (constraints.maxWidth / 2 - 16)
                                  .clamp(0, 300)
                                  .toDouble();
                              return Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  for (final item in items)
                                    _CoverTile(
                                      item: item,
                                      width: maxWidth,
                                      onItemLongPress: onItemLongPress,
                                    ),
                                ],
                              );
                            },
                          ),
                        )
                      else
                        ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: items.length,
                          itemBuilder: (context, index) =>
                              _TextRow(item: items[index]),
                        ),
                      if (isLoading)
                        const LinearProgressIndicator(minHeight: 2),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _CoverTile extends StatelessWidget {
  const _CoverTile({
    required this.item,
    required this.width,
    this.onItemLongPress,
  });

  final LiteratureFeedItem item;
  final double width;
  final void Function(BuildContext context, LiteratureFeedItem item)?
  onItemLongPress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: context.appRadius(18),
      child: GestureDetector(
        onTap: () {
          router.push(WebpageRoute(url: item.url));
        },
        onLongPress: onItemLongPress == null
            ? null
            : () => onItemLongPress!(context, item),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLowest,
            border: Border.all(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class _TextRow extends StatelessWidget {
  const _TextRow({required this.item});

  final LiteratureFeedItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: context.appRadius(18),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            router.push(WebpageRoute(url: item.url));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
  }
}

/// Shared long-press sheet for cover items: preview + open button.
class LiteratureItemSheet extends StatelessWidget {
  const LiteratureItemSheet({super.key, required this.item});

  final LiteratureFeedItem item;

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
                child: Text('Buka'.tr()),
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
                        borderRadius: context.appRadius(16),
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


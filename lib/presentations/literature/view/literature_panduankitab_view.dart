import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/variables/assets.dart';
import '../../../di/injection.dart';
import '../../../router/router.dart';
import '../cubit/panduan/literature_panduan_cubit.dart';

@RoutePage()
class LiteraturePanduanKitabView extends StatelessWidget {
  const LiteraturePanduanKitabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LiteraturePanduanCubit>(
      create: (context) => di(),
      child: Scaffold(
        body: BlocBuilder<LiteraturePanduanCubit, LiteraturePanduanState>(
          builder: (context, state) => NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar.large(
                  actions: [
                    if (!state.isLoading)
                      IconButton(
                        tooltip: 'Reload'.tr(),
                        onPressed: () {
                          context.read<LiteraturePanduanCubit>().getData();
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
                      'Panduan Alkitab'.tr(),
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
                              context.read<LiteraturePanduanCubit>().getData();
                            },
                            child: const Text('Reload')),
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
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 2,
                                        color: Colors.black.withValues(alpha: .2),
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                    color: context.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8)),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      router.push(WebpageRoute(url: item.url));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
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


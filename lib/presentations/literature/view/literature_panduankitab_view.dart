import 'package:auto_route/auto_route.dart';
import 'package:church/data/utilities/extensions/context_ext.dart';
import 'package:church/data/utilities/variables/assets.dart';
import 'package:church/di/injection.dart';
import 'package:church/presentations/literature/cubit/panduan/literature_panduan_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

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
                                .withOpacity(0),
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
                                        color: Colors.black.withOpacity(.2),
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                    color: context.colorScheme.background,
                                    borderRadius: BorderRadius.circular(8)),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Scaffold(
                                              appBar: AppBar(),
                                              body: const PDF(
                                                swipeHorizontal: true,
                                              ).cachedFromUrl(
                                                item.url,
                                                placeholder: (progress) =>
                                                    Center(
                                                        child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text('Downloading'),
                                                    const SizedBox(
                                                      height: 16,
                                                    ),
                                                    Text('$progress %'),
                                                  ],
                                                )),
                                                errorWidget: (error) => Center(
                                                    child:
                                                        Text(error.toString())),
                                              ),
                                            ),
                                          ));

                                      // router.push(WebpageRoute(url: item.url));
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

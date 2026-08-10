import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../data/utilities/variables/assets.dart';
import '../../../di/injection.dart';
import '../cubit/panduan/literature_panduan_cubit.dart';
import '../widgets/literature_feed_scaffold.dart';

@RoutePage()
class LiteraturePanduanKitabView extends StatelessWidget {
  const LiteraturePanduanKitabView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = di<LiteraturePanduanCubit>();
    return LiteratureFeedScaffold<LiteraturePanduanCubit, LiteraturePanduanState>(
      cubit: cubit,
      title: 'Panduan Alkitab'.tr(),
      headerAsset: Assets.assetsImagesWartasejati,
      isLoadingOf: (state) => state.isLoading,
      itemsOf: (state) => [
        for (final item in state.items)
          LiteratureFeedItem(
            url: item.url,
            imageUrl: item.imageUrl,
            title: item.title,
          ),
      ],
      reload: cubit.getData,
    );
  }
}

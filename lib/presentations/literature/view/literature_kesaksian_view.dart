import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../data/utilities/variables/assets.dart';
import '../../../di/injection.dart';
import '../cubit/kesaksian/literature_kesaksian_cubit.dart';
import '../widgets/literature_feed_scaffold.dart';

@RoutePage()
class LiteratureKesaksianView extends StatelessWidget {
  const LiteratureKesaksianView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = di<LiteratureKesaksianCubit>();
    return LiteratureFeedScaffold<
        LiteratureKesaksianCubit,
        LiteratureKesaksianState
      >(
      cubit: cubit,
      title: 'kesaksian_title'.tr(),
      headerAsset: Assets.assetsImagesKesaksian,
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

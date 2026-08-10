import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../data/utilities/variables/assets.dart';
import '../../../di/injection.dart';
import '../cubit/warta/literature_warta_cubit.dart';
import '../widgets/literature_feed_scaffold.dart';

@RoutePage()
class LiteratureWartaView extends StatelessWidget {
  const LiteratureWartaView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = di<LiteratureWartaCubit>();
    return LiteratureFeedScaffold<LiteratureWartaCubit, LiteratureWartaState>(
      cubit: cubit,
      title: 'Manna Magazine'.tr(),
      headerAsset: Assets.assetsImagesWartasejati,
      gridCovers: true,
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
      onItemLongPress: (context, item) {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          elevation: 0,
          builder: (context) => LiteratureItemSheet(item: item),
        );
      },
    );
  }
}

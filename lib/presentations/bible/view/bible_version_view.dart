import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../di/injection.dart';
import '../../../router/router.dart';
import '../../presentations.dart';

@RoutePage()
class BibleVersionView extends StatefulWidget {
  final DashboardCubit dashboardCubit;

  const BibleVersionView({super.key, required this.dashboardCubit});

  @override
  State<BibleVersionView> createState() => _BibleVersionViewState();
}

class _BibleVersionViewState extends State<BibleVersionView> {
  late final AssetManagementCubit _assetCubit = di<AssetManagementCubit>();

  @override
  void initState() {
    super.initState();
    _assetCubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(color: context.colorScheme.outlineVariant),
        ),
        title: Text('Bible Versions'.tr()),
        centerTitle: true,
      ),
      body: BlocBuilder<AssetManagementCubit, AssetManagementState>(
        bloc: _assetCubit,
        builder: (context, state) {
          if (state.isLoading && state.statuses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final bibles = state.statuses
              .where(
                (s) =>
                    s.definition.kind == DistributedAssetKind.bible,
              )
              .toList();
          if (bibles.isEmpty) {
            return Center(
              child: NoDataFound(
                title: 'No Data',
                description: 'No bundled bible versions are available.'.tr(),
              ),
            );
          }
          final currentCode = di<BibleCubit>().state.currentBibleCode;
          return ListView.separated(
            itemCount: bibles.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: context.colorScheme.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final status = bibles[index];
              final code = status.definition.code;
              final isActive = code == currentCode;
              return DistributedAssetTile(
                status: status,
                cubit: _assetCubit,
                isActive: isActive,
                onSelect: () async {
                  final cubit = di<BibleCubit>();
                  await cubit.selectBibleCodeByName(code);
                  if (!context.mounted) return;
                  router.maybePop();
                },
              );
            },
          );
        },
      ),
    );
  }
}

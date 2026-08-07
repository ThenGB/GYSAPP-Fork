import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../di/injection.dart';
import '../../presentations.dart';

@RoutePage()
class HymnalManagementView extends StatefulWidget {
  const HymnalManagementView({super.key});

  @override
  State<HymnalManagementView> createState() => _HymnalManagementViewState();
}

class _HymnalManagementViewState extends State<HymnalManagementView> {
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
        title: Text('hymn_book_management'.tr()),
        centerTitle: true,
      ),
      body: BlocBuilder<AssetManagementCubit, AssetManagementState>(
        bloc: _assetCubit,
        builder: (context, state) {
          if (state.isLoading && state.statuses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final hymnals = state.statuses
              .where((s) => s.definition.kind == DistributedAssetKind.hymnal)
              .toList();
          if (hymnals.isEmpty) {
            return Center(
              child: NoDataFound(
                title: 'No Data',
                description: 'hymn_book_management'.tr(),
              ),
            );
          }
          return ListView.separated(
            itemCount: hymnals.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: context.colorScheme.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final status = hymnals[index];
              return DistributedAssetTile(
                status: status,
                cubit: _assetCubit,
                onSelect: null,
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../data/data.dart';
import '../../../di/injection.dart';
import '../../presentations.dart';

@RoutePage()
class BibleVersionView extends StatelessWidget {
  final DashboardCubit dashboardCubit;

  const BibleVersionView({super.key, required this.dashboardCubit});

  @override
  Widget build(BuildContext context) {
    final bibleAssetService = di<LocalBibleAssetService>();

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(color: context.colorScheme.outlineVariant),
        ),
        title: Text('Bible Versions'.tr()),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: bibleAssetService.getBundledBibleCodes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: NoDataFound(
                title: 'Error',
                description: snapshot.error.toString(),
              ),
            );
          }

          final codes = snapshot.data ?? const <String>[];
          if (codes.isEmpty) {
            return Center(
              child: NoDataFound(
                title: 'No Data',
                description: 'No bundled bible versions are available.'.tr(),
              ),
            );
          }

          return ListView.separated(
            itemCount: codes.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: context.colorScheme.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final code = codes[index];
              return FutureBuilder<String>(
                future: getBibleCodeName(code),
                builder: (context, nameSnapshot) {
                  final displayName = nameSnapshot.data ?? code.toUpperCase();
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: context.colorScheme.primaryContainer,
                      foregroundColor: context.colorScheme.onPrimaryContainer,
                      child: const Icon(Icons.offline_pin_rounded),
                    ),
                    title: Text(
                      displayName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Bundled locally with the app for offline reading.'.tr(),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Ready'.tr(),
                        style: TextStyle(
                          color: context.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

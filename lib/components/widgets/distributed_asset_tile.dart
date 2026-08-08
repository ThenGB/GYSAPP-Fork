import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/services/asset_distribution/models.dart';
import '../../presentations/settings/cubit/asset_management_cubit.dart';

/// A single managed asset row (bible version, hymn book or soundfont) that
/// shows its install state and offers Download / Update / Delete actions.
///
/// Bundled assets (definition.bundledByDefault without an install record)
/// can never be deleted.
class DistributedAssetTile extends StatelessWidget {
  final ManagedAssetStatus status;
  final AssetManagementCubit cubit;
  final bool isActive;
  final VoidCallback? onSelect;

  /// Optional override for the download/update action (lets callers pass
  /// consumer cubits like [BibleCubit] so lists refresh after install).
  final VoidCallback? onDownload;
  final String? subtitleOverride;

  const DistributedAssetTile({
    super.key,
    required this.status,
    required this.cubit,
    this.isActive = false,
    this.onSelect,
    this.onDownload,
    this.subtitleOverride,
  });

  String _statusText(BuildContext context) {
    if (subtitleOverride != null) {
      return subtitleOverride!;
    }
    if (status.isBundled) {
      return 'bundled_asset'.tr();
    }
    if (status.isDownloaded) {
      return 'installed_v'.tr(namedArgs: {
        'v': status.installedVersion ?? '',
      });
    }
    if (status.hasRemotePackage) {
      return 'available_to_download'.tr();
    }
    return 'not_downloaded'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress = cubit.state.progressByCode[status.definition.code];
    final downloading = progress != null;
    final canDelete = status.canDelete;
    final updateAvailable = status.hasUpdateAvailable && !downloading;
    final canDownload = status.hasRemotePackage && !status.isInstalled;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: isActive
            ? colors.primary
            : colors.primaryContainer,
        foregroundColor:
            isActive ? colors.onPrimary : colors.onPrimaryContainer,
        child: Icon(
          status.definition.kind == DistributedAssetKind.bible
              ? Icons.menu_book_outlined
              : status.definition.kind == DistributedAssetKind.hymnal
              ? Icons.library_music_outlined
              : Icons.piano_outlined,
          size: 20,
        ),
      ),
      title: Text(
        status.definition.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: downloading
          ? LinearProgressIndicator(value: progress.clamp(0.0, 1.0))
          : Text(_statusText(context)),
      trailing: isActive
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'active'.tr(),
                style: TextStyle(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : updateAvailable
          ? TextButton.icon(
              onPressed: onDownload ??
                  () => cubit.downloadAsset(status.definition),
              icon: const Icon(Icons.system_update_alt_rounded, size: 18),
              label: Text('update'.tr()),
            )
          : canDownload
          ? TextButton.icon(
              onPressed: onDownload ??
                  () => cubit.downloadAsset(status.definition),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text('download'.tr()),
            )
          : canDelete
          ? IconButton(
              tooltip: 'delete'.tr(),
              onPressed: () async {
                final confirmed = await _confirmDelete(context);
                if (confirmed) {
                  await cubit.deleteAsset(status.definition);
                }
              },
              icon: Icon(Icons.delete_outline_rounded, color: colors.error),
            )
          : null,
      onTap: status.isInstalled ? onSelect : null,
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete'.tr()),
        content: Text(
          'confirm_delete_asset'.tr(
            namedArgs: {'name': status.definition.title},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('No'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Yes'.tr()),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

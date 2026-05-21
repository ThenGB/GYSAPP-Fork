import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/widgets/section.dart';
import '../../../data/data.dart';
import '../../../router/router.dart';
import '../../backup/cubit/backup_cubit.dart';
import '../../bible/cubit/bible_cubit.dart';
import '../../initial/bloc/initial_cubit.dart';
import '../../song/cubit/song_cubit.dart';
import '../cubit/asset_management_cubit.dart';
import '../cubit/asset_management_state.dart';

@RoutePage()
class AssetManagementView extends StatefulWidget {
  const AssetManagementView({
    super.key,
    required this.assetManagementCubit,
    required this.bibleCubit,
    required this.songCubit,
  });

  final AssetManagementCubit assetManagementCubit;
  final BibleCubit bibleCubit;
  final SongCubit songCubit;

  @override
  State<AssetManagementView> createState() => _AssetManagementViewState();
}

class _AssetManagementViewState extends State<AssetManagementView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.assetManagementCubit.state.statuses.isEmpty) {
        widget.assetManagementCubit.refresh();
      }
    });
  }

  Future<void> _resetWholeApp() async {
    final confirmed = await context.showConfirmation(
      'Wipe all app data and return to first-time setup? This removes downloaded assets, notes, reminders, login state, cache, and preferences.',
    );
    if (!mounted || !confirmed) return;

    await _releaseResourcesForMaintenance();
    await widget.songCubit.prepareForAppReset();
    final success = await widget.assetManagementCubit.resetAppData();
    if (!mounted || !success) return;

    await widget.songCubit.resetToDefaults();
    if (!mounted) return;
    context.read<BackupCubit>().resetToDefaults();
    context.read<InitialCubit>().resetToDefaults();
    router.popUntilRoot();
    router.replace(const InitialRoute());
  }

  Future<void> _releaseResourcesForMaintenance() async {
    await widget.songCubit.releaseResourcesForMaintenance();
    await widget.bibleCubit.releaseResourcesForMaintenance();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await WidgetsBinding.instance.endOfFrame;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.assetManagementCubit,
      child: BlocBuilder<AssetManagementCubit, AssetManagementState>(
        builder: (context, state) => Scaffold(
          backgroundColor: context.colorScheme.surface,
          appBar: AppBar(
            title: const Text('Offline Library'),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'Check latest release',
                onPressed: state.isLoading || state.isResettingApp
                    ? null
                    : () => widget.assetManagementCubit.refresh(),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.22,
                  ),
                  context.colorScheme.surfaceContainerLow.withValues(
                    alpha: 0.34,
                  ),
                  context.colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    _AssetLibraryHero(
                      isLoading: state.isLoading || state.isResettingApp,
                      onRefresh: () => widget.assetManagementCubit.refresh(),
                    ),
                    _AssetGroupSection(
                      title: 'Alkitab',
                      subtitle:
                          'TB tetap dibundel. Versi lain diunduh dari public GitHub Releases tanpa login lalu dipasang untuk offline reading.',
                      statuses: state.bibleStatuses,
                      assetManagementCubit: widget.assetManagementCubit,
                      bibleCubit: widget.bibleCubit,
                      songCubit: widget.songCubit,
                    ),
                    _AssetGroupSection(
                      title: 'Pujian',
                      subtitle:
                          'KR tetap dibundel. Hymne lain diunduh terenkripsi dari public GitHub releases dan dibuka hanya di dalam aplikasi ini.',
                      statuses: state.hymnalStatuses,
                      assetManagementCubit: widget.assetManagementCubit,
                      bibleCubit: widget.bibleCubit,
                      songCubit: widget.songCubit,
                    ),
                    _CacheMaintenanceSection(
                      state: state,
                      assetManagementCubit: widget.assetManagementCubit,
                      onPrepareForMaintenance: _releaseResourcesForMaintenance,
                    ),
                    _FullResetSection(state: state, onReset: _resetWholeApp),
                    if ((state.message ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: context.colorScheme.outlineVariant
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: context.colorScheme.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    state.message!,
                                    style: context.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AssetLibraryHero extends StatelessWidget {
  const _AssetLibraryHero({required this.isLoading, required this.onRefresh});

  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colorScheme.primaryContainer.withValues(alpha: 0.62),
              context.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.94,
              ),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.colorScheme.primary.withValues(alpha: 0.24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Encrypted Release Library',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Public GitHub releases, no GitHub sign-in required. Check the latest release, install offline Bible and hymnal packages, remove installed files, clear preparation caches, or wipe the app back to first-launch state.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonalIcon(
                  onPressed: isLoading ? null : onRefresh,
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: const Text('Check latest release'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    router.push(
                      WebpageRoute(
                        url: 'https://github.com/ThenGB/GYSApp-Data/releases',
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open release page'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetGroupSection extends StatelessWidget {
  const _AssetGroupSection({
    required this.title,
    required this.subtitle,
    required this.statuses,
    required this.assetManagementCubit,
    required this.bibleCubit,
    required this.songCubit,
  });

  final String title;
  final String subtitle;
  final List<ManagedAssetStatus> statuses;
  final AssetManagementCubit assetManagementCubit;
  final BibleCubit bibleCubit;
  final SongCubit songCubit;

  @override
  Widget build(BuildContext context) {
    return Section(
      label: title,
      child: (gap) => Padding(
        padding: EdgeInsets.symmetric(horizontal: gap),
        child: Column(
          children: [
            _AssetSectionIntro(title: title, subtitle: subtitle),
            const SizedBox(height: 12),
            ...statuses.map(
              (status) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ManagedAssetCard(
                  status: status,
                  progress: assetManagementCubit
                      .state
                      .progressByCode[status.definition.code],
                  assetManagementCubit: assetManagementCubit,
                  bibleCubit: bibleCubit,
                  songCubit: songCubit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetSectionIntro extends StatelessWidget {
  const _AssetSectionIntro({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagedAssetCard extends StatelessWidget {
  const _ManagedAssetCard({
    required this.status,
    required this.progress,
    required this.assetManagementCubit,
    required this.bibleCubit,
    required this.songCubit,
  });

  final ManagedAssetStatus status;
  final double? progress;
  final AssetManagementCubit assetManagementCubit;
  final BibleCubit bibleCubit;
  final SongCubit songCubit;

  @override
  Widget build(BuildContext context) {
    final canInstall = status.hasRemotePackage;
    final installLabel = status.hasUpdateAvailable
        ? 'Install update'
        : (status.isDownloaded ? 'Reinstall' : 'Install');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.44),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    status.definition.kind == DistributedAssetKind.bible
                        ? Icons.menu_book_outlined
                        : Icons.library_music_outlined,
                    color: context.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.definition.title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _AssetStatusChip(
                            label: _assetStatusLabel(status),
                            color: _assetStatusColor(context, status),
                          ),
                          if ((status.remoteVersion ?? '').isNotEmpty)
                            _AssetStatusChip(
                              label: 'Release ${status.remoteVersion}',
                              color: context.colorScheme.secondaryContainer,
                              foreground:
                                  context.colorScheme.onSecondaryContainer,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _assetDescription(status),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 4),
              Text(
                '${(progress! * 100).round()}%',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonalIcon(
                  onPressed: progress != null || !canInstall
                      ? null
                      : () => assetManagementCubit.downloadAsset(
                          status.definition,
                          bibleCubit: bibleCubit,
                          songCubit: songCubit,
                        ),
                  icon: const Icon(Icons.download_rounded),
                  label: Text(installLabel),
                ),
                if (status.canDelete)
                  OutlinedButton.icon(
                    onPressed: progress != null
                        ? null
                        : () async {
                            final confirmed = await context.showConfirmation(
                              'Remove installed ${status.definition.title} from this device?',
                            );
                            if (!context.mounted || !confirmed) return;
                            await assetManagementCubit.deleteAsset(
                              status.definition,
                              bibleCubit: bibleCubit,
                              songCubit: songCubit,
                            );
                          },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Remove installed'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _assetDescription(ManagedAssetStatus status) {
    final location = status.definition.bundledByDefault
        ? 'Bundled base asset is always available.'
        : 'Installed locally after encrypted download.';
    if (status.canDelete) {
      return '$location Current installed version: ${status.installedVersion ?? '-'}';
    }
    if (status.hasRemotePackage) {
      return '$location Latest release ready: ${status.remoteVersion ?? '-'}';
    }
    return '$location No remote release detected yet.';
  }

  String _assetStatusLabel(ManagedAssetStatus status) {
    if (status.hasUpdateAvailable) return 'Update available';
    if (status.isDownloaded) return 'Installed';
    if (status.isBundled) return 'Bundled';
    if (status.hasRemotePackage) return 'Ready to install';
    return 'Waiting for release';
  }

  Color _assetStatusColor(BuildContext context, ManagedAssetStatus status) {
    if (status.hasUpdateAvailable) {
      return context.colorScheme.tertiaryContainer;
    }
    if (status.isDownloaded) {
      return context.colorScheme.primaryContainer;
    }
    if (status.isBundled) {
      return context.colorScheme.surfaceContainerHighest;
    }
    return context.colorScheme.surfaceContainerHigh;
  }
}

class _AssetStatusChip extends StatelessWidget {
  const _AssetStatusChip({
    required this.label,
    required this.color,
    this.foreground,
  });

  final String label;
  final Color color;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: foreground ?? context.colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CacheMaintenanceSection extends StatelessWidget {
  const _CacheMaintenanceSection({
    required this.state,
    required this.assetManagementCubit,
    required this.onPrepareForMaintenance,
  });

  final AssetManagementState state;
  final AssetManagementCubit assetManagementCubit;
  final Future<void> Function() onPrepareForMaintenance;

  @override
  Widget build(BuildContext context) {
    return Section(
      label: 'Cache',
      child: (gap) => Padding(
        padding: EdgeInsets.symmetric(horizontal: gap),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delete app cache',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Delete app cache removes fast-access PDF prep, PDF note cache, MIDI render cache, and leftover temporary packages. Installed Bible DBs and installed hymnals stay preserved.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.tonalIcon(
                  onPressed: state.isClearingCache
                      ? null
                      : () async {
                          final confirmed = await context.showConfirmation(
                            'Delete the fast-access cache now?',
                          );
                          if (!context.mounted || !confirmed) return;
                          await onPrepareForMaintenance();
                          await assetManagementCubit.clearFastAccessCache();
                        },
                  icon: state.isClearingCache
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cleaning_services_outlined),
                  label: Text(
                    state.isClearingCache ? 'Working...' : 'Clear Cache',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullResetSection extends StatelessWidget {
  const _FullResetSection({required this.state, required this.onReset});

  final AssetManagementState state;
  final Future<void> Function() onReset;

  @override
  Widget build(BuildContext context) {
    return Section(
      label: 'Reset',
      child: (gap) => Padding(
        padding: EdgeInsets.symmetric(horizontal: gap),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.errorContainer.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colorScheme.error.withValues(alpha: 0.24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Full App Reset',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Wipe everything from this device and return to the first-launch setup. This removes downloaded assets, notes, reminders, login state, cache, and local preferences.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colorScheme.error,
                    foregroundColor: context.colorScheme.onError,
                  ),
                  onPressed: state.isResettingApp ? null : onReset,
                  icon: state.isResettingApp
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.restart_alt_rounded),
                  label: Text(
                    state.isResettingApp
                        ? 'Resetting...'
                        : 'Reset All App Data',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

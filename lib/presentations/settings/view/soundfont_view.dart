import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../di/injection.dart';
import '../../../router/router.dart';
import '../../presentations.dart';

/// SoundFont picker page — the same managed-asset layout as the Bible
/// versions page: bundled fonts are selectable, downloaded fonts can be
/// deleted, remote fonts can be downloaded, and the active font carries
/// an "Active" badge.
@RoutePage()
class SoundFontView extends StatefulWidget {
  const SoundFontView({super.key});

  @override
  State<SoundFontView> createState() => _SoundFontViewState();
}

class _SoundFontViewState extends State<SoundFontView> {
  late final AssetManagementCubit _assetCubit = di<AssetManagementCubit>();
  // Bundled + installed font files not tracked by the release manifest
  // (e.g. TimGM6mb.sf2).  Only the bundled set matters — manifest-managed
  // fonts are filtered out by code.
  late Future<List<String>> _installedFonts;

  @override
  void initState() {
    super.initState();
    _assetCubit.refresh();
    _installedFonts = di<SongCubit>().midiEngine.getAvailableSoundFonts();
  }

  Future<void> _select(String fileName) async {
    di<SongCubit>().setSoundFont(fileName);
    if (!mounted) return;
    router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(color: context.colorScheme.outlineVariant),
        ),
        title: Text('soundfont_title'.tr()),
        centerTitle: true,
      ),
      body: BlocBuilder<AssetManagementCubit, AssetManagementState>(
        bloc: _assetCubit,
        builder: (context, state) {
          final soundfonts = state.statuses
              .where((s) => s.definition.kind == DistributedAssetKind.soundfont)
              .toList();
          final currentFont = di<SongCubit>().state.soundFont;
          return FutureBuilder<List<String>>(
            future: _installedFonts,
            builder: (context, snapshot) {
              final manifestCodes = {
                for (final s in soundfonts) s.definition.code,
              };
              final extraFonts = (snapshot.data ?? const <String>[])
                  .where(
                    (f) => !manifestCodes.contains(f.replaceAll('.sf2', '')),
                  )
                  .toList();
              if (state.isLoading &&
                  state.statuses.isEmpty &&
                  snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (soundfonts.isEmpty && extraFonts.isEmpty) {
                return Center(
                  child: NoDataFound(
                    title: 'No Data',
                    description: 'No soundfonts are available.'.tr(),
                  ),
                );
              }
              return ListView.separated(
                itemCount: soundfonts.length + extraFonts.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: context.colorScheme.outlineVariant,
                ),
                itemBuilder: (context, index) {
                  if (index < soundfonts.length) {
                    final status = soundfonts[index];
                    final isActive =
                        status.definition.code ==
                        currentFont.replaceAll('.sf2', '');
                    return DistributedAssetTile(
                      status: status,
                      cubit: _assetCubit,
                      isActive: isActive,
                      onSelect: () => _select('${status.definition.code}.sf2'),
                    );
                  }
                  final fileName = extraFonts[index - soundfonts.length];
                  final isActive = fileName == currentFont;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isActive
                          ? context.colorScheme.primary
                          : context.colorScheme.primaryContainer,
                      foregroundColor: isActive
                          ? context.colorScheme.onPrimary
                          : context.colorScheme.onPrimaryContainer,
                      child: const Icon(Icons.piano_outlined, size: 20),
                    ),
                    title: Text(
                      fileName.replaceAll('.sf2', ''),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text('bundled_asset'.tr()),
                    trailing: isActive
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'active'.tr(),
                              style: TextStyle(
                                color: context.colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : null,
                    onTap: () => _select(fileName),
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

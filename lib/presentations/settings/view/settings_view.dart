import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../data/models/theme_preferences.dart';
import '../../../di/injection.dart';
import '../../../domain/domain.dart';
import '../../../router/router.dart';
import '../../presentations.dart';

const double _settingsMaxContentWidth = 1080;

List<String> settingsSoundFontMenuValues({
  required List<String>? availableSoundFonts,
  required String selectedSoundFont,
}) {
  final values = <String>[];
  void addValue(String value) {
    if (value.isNotEmpty && !values.contains(value)) {
      values.add(value);
    }
  }

  addValue(selectedSoundFont);
  for (final soundFont in availableSoundFonts ?? const ['TimGM6mb.sf2']) {
    addValue(soundFont);
  }
  return values;
}

@RoutePage()
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: context.colorScheme.surface.withValues(alpha: 0.88),
        toolbarHeight: 74,
        leading: IconButton(
          tooltip: 'Menu',
          onPressed: openDashboardDrawer,
          icon: const Icon(Icons.menu_outlined),
        ),
        title: Text('workspace_settings'.tr()),
        centerTitle: true,
        actions: const [SizedBox(width: 48)],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.2,
              ),
              context.colorScheme.surfaceContainerLow.withValues(alpha: 0.34),
              context.colorScheme.surface,
            ],
          ),
        ),
        // Each section is scoped to the bloc it actually reads. The old
        // layout wrapped every section in a single BlocBuilder<SettingsCubit>
        // so toggling one switch rebuilt the whole page (theme preview,
        // asset card, song section included).
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _settingsMaxContentWidth,
              ),
              child: const Column(
                children: [
                  _VerseSettingsSection(),
                  _SongSettingsSection(),
                  _ThemeSettingsSection(),
                  _NotificationSettingsSection(),
                  _OtherSettingsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Base card used by every settings section so spacing, radius, border and
/// elevation stay identical across the page.
class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: context.appRadius(12),
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.description,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.appRadius(16),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.appSpace(16),
            context.appSpace(14),
            context.appSpace(12),
            context.appSpace(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: context.appRadius(12),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, size: 20, color: colors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SettingsTileText(
                  title: title,
                  description: description,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width < 560
                        ? 120
                        : 164,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: trailing,
                  ),
                ),
              ] else
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTileText extends StatelessWidget {
  const _SettingsTileText({required this.title, this.description});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 3),
          Text(
            description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.25,
            ),
          ),
        ],
      ],
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: icon,
      title: title,
      description: description,
      trailing: Switch(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
    );
  }
}

class _VerseSettingsSection extends StatefulWidget {
  const _VerseSettingsSection();

  @override
  State<_VerseSettingsSection> createState() => _VerseSettingsSectionState();
}

class _VerseSettingsSectionState extends State<_VerseSettingsSection> {
  // Memoized so FutureBuilder does not re-create the future (and re-run the
  // title lookup) on every unrelated BibleCubit emit.
  Verse? _titleForVerse;
  Future<String?>? _todayTitleFuture;

  Future<String?> _titleFutureFor(BibleCubit cubit, Verse? verse) {
    final current = _todayTitleFuture;
    if (identical(_titleForVerse, verse) && current != null) {
      return current;
    }
    _titleForVerse = verse;
    final future = verse == null
        ? Future<String?>.value(null)
        : cubit.getBibleTitle([verse]);
    _todayTitleFuture = future;
    return future;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibleCubit, BibleState>(
      builder: (context, state) {
        final cubit = context.read<BibleCubit>();
        return Section(
          label: 'Verse'.tr(),
          child: (gap) => Padding(
            padding: EdgeInsets.symmetric(horizontal: gap),
            child: _SettingsCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.menu_book_outlined,
                    title: 'Version'.tr(),
                    description: 'bible_version_desc'.tr(),
                    onTap: () {
                      router.push(
                        BibleVersionRoute(dashboardCubit: context.read()),
                      );
                    },
                    trailing: Text(
                      state.currentBibleCode
                          .split('_')
                          .last
                          .toUpperCase(),
                      style: TextStyle(
                        color: context.colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.event_note_outlined,
                    title: 'Today Reading'.tr(),
                    description: 'today_reading_desc'.tr(),
                    onTap: () {
                      router.push(
                        BibleListRoute(
                          bibleCode: state.currentBibleCode,
                          textScale: state.defaultTextScale,
                          onSelected: (newBible) {
                            cubit.setTodayReading(newBible);
                            router.maybePop();
                          },
                          getBibles: (bookId, chapterId) async {
                            if (bookId == null || chapterId == null) {
                              return [];
                            }
                            return await cubit.getVersesByBook(
                              bookId,
                              chapterId,
                            );
                          },
                          books: state.books,
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FutureBuilder<String?>(
                          future: _titleFutureFor(cubit, state.todayReading),
                          builder: (context, snapshot) => Text(
                            snapshot.data ?? 'None'.tr(),
                            style: TextStyle(
                              color: context.colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (state.todayReading != null)
                          IconButton(
                            tooltip: 'clear_reading'.tr(),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => cubit.setTodayReading(null),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.schedule_outlined,
                    title: 'Bible Reminder'.tr(),
                    description: 'bible_reminder_desc'.tr(),
                    onTap: () async {
                      var weekdays = List.generate(7, (index) => index + 1);
                      await showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        isScrollControlled: true,
                        context: context,
                        builder: (context) => BibleReminderDialog(
                          weekdays: weekdays,
                          settingCubit: context.read<SettingsCubit>(),
                        ),
                      );
                    },
                    trailing: BlocBuilder<SettingsCubit, SettingsState>(
                      builder: (context, settingsState) => Text(
                        (settingsState.isBibleReminderNotificationActive
                                ? 'On'
                                : 'Off')
                            .tr(),
                        style: TextStyle(
                          color: context.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.headphones_outlined,
                    title: 'Audio Bible Config'.tr(),
                    description: 'audio_bible_desc'.tr(),
                    onTap: () {
                      router.push(
                        BibleAudioSettingRoute(
                          onSave: (voices, pitch, speed) {
                            cubit.applyTtsSetting(voices, pitch, speed);
                          },
                          initialPitchRate: cubit.state.pitchRate,
                          initialSpeedRate: cubit.state.speedRate,
                          initialVoices: cubit.state.voices,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SongSettingsSection extends StatefulWidget {
  const _SongSettingsSection();

  @override
  State<_SongSettingsSection> createState() => _SongSettingsSectionState();
}

class _SongSettingsSectionState extends State<_SongSettingsSection> {
  Future<List<String>>? _soundFontsFuture;

  @override
  void initState() {
    super.initState();
    _soundFontsFuture = context.read<SongCubit>().midiEngine
        .getAvailableSoundFonts();
  }

  bool _canDeleteFont(AssetManagementState assetState, String sfFile) {
    final code = sfFile.replaceAll('.sf2', '');
    for (final status in assetState.statuses) {
      if (status.definition.kind == DistributedAssetKind.soundfont &&
          status.definition.code == code &&
          status.canDelete) {
        return true;
      }
    }
    return false;
  }

  Future<bool> _confirmDeleteSoundFont(
    BuildContext context,
    String title,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete'.tr()),
        content: Text('confirm_delete_asset'.tr(namedArgs: {'name': title})),
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

  Future<void> _showSoundFontMenu(
    BuildContext context, {
    required String currentFont,
    required List<({String code, String title})> remoteFonts,
    required AssetManagementState assetState,
    required Future<void> Function() onDownloaded,
  }) async {
    final songCubit = context.read<SongCubit>();
    // Resolve the anchor synchronously (no async gap) so the context
    // use below is safe.
    final box = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    // Fetch the current font list fresh so a just-downloaded font
    // appears as selectable immediately (the FutureBuilder snapshot
    // may be stale).
    final soundfonts = await songCubit.midiEngine.getAvailableSoundFonts();
    if (!context.mounted) return;
    // If the manifest state is empty (offline/first run) fall back to the
    // bundled definitions — excluding anything already installed.
    final remoteList = <({String code, String title})>[
      ...remoteFonts,
    ];
    if (remoteList.isEmpty) {
      final installedCodes = <String>{
        ...soundfonts.map((f) => f.replaceAll('.sf2', '')),
        ...assetState.statuses
            .where(
              (s) =>
                  s.definition.kind == DistributedAssetKind.soundfont &&
                  s.isInstalled,
            )
            .map((s) => s.definition.code),
      };
      remoteList.addAll(
        supportedDistributedAssets
            .where(
              (d) =>
                  d.kind == DistributedAssetKind.soundfont &&
                  !installedCodes.contains(d.code),
            )
            .map(
              (d) => (code: d.code, title: d.title),
            ),
      );
    }
    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          box.localToGlobal(Offset.zero, ancestor: overlay),
          box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      ),
      initialValue: currentFont,
      items: [
        for (final sf in soundfonts)
          PopupMenuItem(
            value: 'select:$sf',
            child: Row(
              children: [
                Expanded(
                  child: Text(sf.replaceAll('.sf2', '')),
                ),
                if (sf == currentFont)
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: context.colorScheme.primary,
                  ),
                if (_canDeleteFont(assetState, sf))
                  Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: context.colorScheme.error,
                  ),
              ],
            ),
          ),
        for (final remote in remoteList)
          PopupMenuItem(
            value: 'download:${remote.code}',
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    remote.title,
                    style: TextStyle(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.download_rounded,
                  size: 18,
                  color: context.colorScheme.primary,
                ),
              ],
            ),
          ),
      ],
    );
    if (action == null || !context.mounted) return;

    if (action.startsWith('select:')) {
      songCubit.setSoundFont(action.substring(7));
      return;
    }
    if (action.startsWith('download:')) {
      final definition = assetDefinitionForCode(
        DistributedAssetKind.soundfont,
        action.substring(9),
      );
      if (definition != null) {
        await di<AssetManagementCubit>().downloadAsset(definition);
        await onDownloaded();
      }
      return;
    }
    if (action.startsWith('delete:')) {
      final code = action.substring(7);
      final status = assetState.statuses
          .where(
            (s) => s.definition.code == code && s.canDelete,
          )
          .firstOrNull;
      if (status != null) {
        final confirmed = await _confirmDeleteSoundFont(
          context,
          status.definition.title,
        );
        if (confirmed) {
          await di<AssetManagementCubit>().deleteAsset(status.definition);
          await onDownloaded();
        }
      }
    }
  }

  Future<void> _resetChords(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('reset_chords'.tr()),
        content: Text('reset_chords_confirm'.tr()),
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
    if (!context.mounted || confirmed != true) return;

    final service = di<ChordSyncService>();
    await service.reset();
    final result = await service.sync();
    if (!context.mounted) return;
    Fluttertoast.cancel();
    if (result.failed > 0) {
      Fluttertoast.showToast(msg: 'chords_sync_failed'.tr());
    } else {
      Fluttertoast.showToast(msg: 'chords_synced'.tr());
    }
    // Reload chords for the current song so the reset is visible at once.
    final songCubit = context.read<SongCubit>();
    if (songCubit.state.songs.isNotEmpty) {
      songCubit.reloadChordsForCurrentSong();
      songCubit.refreshLibraryAvailability();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongCubit, SongState>(
      builder: (context, state) {
        final songCubit = context.read<SongCubit>();
        return Section(
          label: 'song_section'.tr(),
          child: (gap) => Padding(
            padding: EdgeInsets.symmetric(horizontal: gap),
            child: _SettingsCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.library_music_outlined,
                    title: 'soundfont_title'.tr(),
                    description: 'soundfont_desc'.tr(),
                    trailing: FutureBuilder<List<String>>(
                      future: _soundFontsFuture,
                      builder: (context, snapshot) {
                        return BlocBuilder<AssetManagementCubit,
                            AssetManagementState>(
                          bloc: di<AssetManagementCubit>(),
                          builder: (context, assetState) {
                            // SoundFonts from the release manifest that are
                            // not installed locally yet.
                            final remoteFonts = <({String code, String title})>[
                              ...assetState.statuses
                                  .where(
                                    (s) =>
                                        s.definition.kind ==
                                            DistributedAssetKind.soundfont &&
                                        !s.isInstalled &&
                                        s.hasRemotePackage,
                                  )
                                  .map(
                                    (s) => (
                                      code: s.definition.code,
                                      title: s.definition.title,
                                    ),
                                  ),
                            ];
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  shape: StadiumBorder(
                                    side: BorderSide(
                                      color: context
                                          .colorScheme
                                          .outlineVariant
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  // Builder anchors the menu to THIS pill
                                  // (the section context made it pop up far
                                  // left / wrong position).
                                  child: Builder(
                                    builder: (pillContext) => InkWell(
                                      borderRadius:
                                          BorderRadius.circular(999),
                                      onTap: () => _showSoundFontMenu(
                                        pillContext,
                                        currentFont: state.soundFont,
                                        remoteFonts: remoteFonts,
                                        assetState: assetState,
                                        onDownloaded: () async {
                                          _soundFontsFuture = songCubit
                                              .midiEngine
                                              .getAvailableSoundFonts();
                                          if (mounted) setState(() {});
                                        },
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              state.soundFont
                                                  .replaceAll('.sf2', ''),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: context
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color: context
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Download progress for the soundfont
                                // currently being fetched (32MB+ takes a
                                // while — show it instead of a silent wait).
                                if (assetState.progressByCode.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: 120,
                                    child: LinearProgressIndicator(
                                      minHeight: 4,
                                      borderRadius:
                                          BorderRadius.circular(2),
                                      value: assetState.progressByCode.values
                                          .reduce((a, b) => a > b ? a : b),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.library_books_outlined,
                    title: 'hymn_book'.tr(),
                    description: 'hymn_book_management'.tr(),
                    onTap: () {
                      router.push(HymnalManagementRoute());
                    },
                  ),
                  const _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.music_note_outlined,
                    title: 'reset_chords'.tr(),
                    description: 'reset_chords_desc'.tr(),
                    onTap: () => _resetChords(context),
                  ),
                  const _SettingsDivider(),
                  _SettingsSwitchTile(
                    icon: Icons.bolt_outlined,
                    title: 'midi_cache_title'.tr(),
                    description: 'midi_cache_desc'.tr(),
                    value: state.midiPreloadEnabled,
                    onChanged: songCubit.toggleWarmUp,
                  ),
                  if (state.midiPreloadEnabled) ...[
                    const _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.queue_music_outlined,
                      title: 'midi_cache_count_title'.tr(),
                      description: 'midi_cache_count_desc'.tr(),
                      trailing: PopupMenuButton<int>(
                        initialValue: state.midiCacheMaxCount,
                        onSelected: songCubit.setMidiCacheMaxCount,
                        itemBuilder: (context) => [4, 8, 12, 16, 20, 24, 32]
                            .map(
                              (v) => PopupMenuItem(
                                value: v,
                                child: Text(
                                  'song_count'.tr(namedArgs: {'n': '$v'}),
                                ),
                              ),
                            )
                            .toList(),
                        child: Text(
                          'song_count'.tr(namedArgs: {
                            'n': '${state.midiCacheMaxCount}',
                          }),
                          style: TextStyle(
                            color: context.colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.cached_outlined,
                      title: 'midi_neighbor_title'.tr(),
                      description: 'midi_neighbor_desc'.tr(),
                      trailing: PopupMenuButton<int>(
                        initialValue: state.midiPreloadNeighborCount,
                        onSelected: songCubit.setMidiPreloadNeighborCount,
                        itemBuilder: (context) => [0, 1, 2, 3, 4, 5]
                            .map(
                              (v) => PopupMenuItem(
                                value: v,
                                child: Text(
                                  v == 0
                                      ? 'off'.tr()
                                      : 'song_count'.tr(
                                          namedArgs: {'n': '$v'},
                                        ),
                                ),
                              ),
                            )
                            .toList(),
                        child: Text(
                          state.midiPreloadNeighborCount == 0
                              ? 'off'.tr()
                              : 'song_count'.tr(namedArgs: {
                                  'n': '${state.midiPreloadNeighborCount}',
                                }),
                          style: TextStyle(
                            color: context.colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ThemeSettingsSection extends StatelessWidget {
  const _ThemeSettingsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InitialCubit, InitialState>(
      builder: (context, state) {
        return Section(
          label: 'appearance_section'.tr(),
          child: (gap) => Padding(
            padding: EdgeInsets.symmetric(horizontal: gap),
            child: _SettingsCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'theme_mode'.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PreferenceSelector<ThemeMode>(
                      label: 'theme_mode'.tr(),
                      selected: {state.themeMode.toThemeMode},
                      onChanged: (mode) {
                        context
                            .read<InitialCubit>()
                            .toggleTheme(mode, () => context);
                      },
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('system'.tr()),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('light'.tr()),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('dark'.tr()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _AccentColorPicker(
                      selectedKey: state.accentKey,
                      onSelected: (key) {
                        context.read<InitialCubit>().changeAccentColor(key);
                      },
                    ),
                    const SizedBox(height: 16),
                    _DensitySelector(
                      selected: state.themePreferences.density,
                      onChanged: (density) {
                        context.read<InitialCubit>().changeDensity(density);
                      },
                    ),
                    const SizedBox(height: 16),
                    _CornerRadiusSelector(
                      selected: state.themePreferences.cornerRadius,
                      onChanged: (style) {
                        context.read<InitialCubit>().changeCornerRadius(style);
                      },
                    ),
                    const SizedBox(height: 16),
                    _TypographyScaleSelector(
                      selected: state.themePreferences.typographyScale,
                      onChanged: (scale) {
                        context
                            .read<InitialCubit>()
                            .changeTypographyScale(scale);
                      },
                    ),
                    const SizedBox(height: 16),
                    _ThemePreviewCard(
                      accentKey: state.accentKey,
                      cornerRadius: state.themePreferences.cornerRadius,
                      typographyScale: state.themePreferences.typographyScale,
                    ),
                    const SizedBox(height: 16),
                    const _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.text_fields_rounded,
                      title: 'Font Settings'.tr(),
                      description: 'font_desc'.tr(),
                      onTap: () {
                        router.push(FontSettingRoute());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotificationSettingsSection extends StatelessWidget {
  const _NotificationSettingsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) => Section(
        label: 'Notification'.tr(),
        child: (gap) => Padding(
          padding: EdgeInsets.symmetric(horizontal: gap),
          child: _SettingsCard(
            child: _SettingsSwitchTile(
              icon: Icons.notifications_active_outlined,
              title: 'Sabat Notification'.tr(),
              description: state.isSabatNotificationActive
                  ? 'sabat_notification_enabled_desc'.tr()
                  : 'sabat_notification_disabled_desc'.tr(),
              value: state.isSabatNotificationActive,
              onChanged: (value) {
                context.read<SettingsCubit>().toggleSabatNotification();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _OtherSettingsSection extends StatelessWidget {
  const _OtherSettingsSection();

  @override
  Widget build(BuildContext context) {
    return Section(
      label: 'Others'.tr(),
      child: (gap) => Padding(
        padding: EdgeInsets.symmetric(horizontal: gap),
        child: _SettingsCard(
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.language_outlined,
                title: 'Language'.tr(),
                description: 'language_desc'.tr(),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    builder: (c) => BlocProvider.value(
                      value: context.read<BibleCubit>(),
                      child: const SelectLanguageDialog(),
                    ),
                  );
                },
              ),
              const _SettingsDivider(),
              _SettingsTile(
                icon: Icons.backup_outlined,
                title: 'Backup'.tr(),
                description: 'backup_desc'.tr(),
                onTap: () {
                  router.push(
                    BackupRoute(
                      onSynced: (data) {
                        if (data.bibleState != null) {
                          context.read<BibleCubit>().sync(data.bibleState!);
                        }
                        if (data.songState != null) {
                          context.read<SongCubit>().sync(data.songState!);
                        }
                        if (data.faithState != null) {
                          context.read<FaithCubit>().sync(data.faithState!);
                        }
                        if (data.settingsState != null) {
                          context
                              .read<SettingsCubit>()
                              .sync(data.settingsState!);
                        }
                        Fluttertoast.cancel();
                        Fluttertoast.showToast(msg: 'Sync success'.tr());
                      },
                      data: AppBackupData(
                        bibleState: context.read<BibleCubit>().state,
                        faithState: context.read<FaithCubit>().state,
                        settingsState: context.read<SettingsCubit>().state,
                        songState: context.read<SongCubit>().state,
                      ),
                    ),
                  );
                },
              ),
              const _SettingsDivider(),
              _SettingsTile(
                icon: Icons.campaign_outlined,
                title: 'Report'.tr(),
                description: 'report_desc'.tr(),
                onTap: () {
                  final cubit = context.read<DashboardCubit>();
                  router.push(
                    ReportRoute(
                      account: cubit.state.account,
                      onLoggedIn: (token) async {
                        try {
                          await cubit.loginSuccessCallback(token);
                          router.maybePop();
                          Fluttertoast.cancel();
                          Fluttertoast.showToast(msg: 'BERHASIL LOGIN!');
                          return cubit.state.account;
                        } catch (e, st) {
                          debugPrint(
                            '[SettingsView] onLoggedIn ERROR: $e\n$st',
                          );
                          rethrow;
                        }
                      },
                    ),
                  );
                },
              ),
              const _SettingsDivider(),
              BlocBuilder<AssetManagementCubit, AssetManagementState>(
                bloc: di<AssetManagementCubit>(),
                builder: (context, assetState) => Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.cleaning_services_outlined,
                      title: 'delete_app_cache'.tr(),
                      description: 'delete_app_cache_desc'.tr(),
                      onTap: assetState.isClearingCache
                          ? null
                          : () {
                              di<AssetManagementCubit>()
                                  .clearFastAccessCache();
                            },
                      trailing: assetState.isClearingCache
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                    const _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.restart_alt_rounded,
                      title: 'full_app_reset'.tr(),
                      description: 'full_app_reset_desc'.tr(),
                      onTap: assetState.isResettingApp
                          ? null
                          : () => _resetWholeApp(context),
                      trailing: assetState.isResettingApp
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resetWholeApp(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('full_app_reset'.tr()),
        content: Text(
          'Wipe all app data and return to first-time setup? This removes downloaded assets, notes, reminders, login state, cache, and preferences.',
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
    if (!context.mounted || confirmed != true) return;

    final assetCubit = di<AssetManagementCubit>();
    final songCubit = context.read<SongCubit>();
    final bibleCubit = context.read<BibleCubit>();

    await songCubit.releaseResourcesForMaintenance();
    await bibleCubit.releaseResourcesForMaintenance();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await WidgetsBinding.instance.endOfFrame;

    await songCubit.prepareForAppReset();
    final success = await assetCubit.resetAppData();
    if (!context.mounted || !success) return;

    await songCubit.resetToDefaults();
    if (!context.mounted) return;
    context.read<BackupCubit>().resetToDefaults();
    context.read<InitialCubit>().resetToDefaults();
    router.popUntilRoot();
    router.replace(const InitialRoute());
  }
}

class _AccentColorPicker extends StatelessWidget {
  final String selectedKey;
  final ValueChanged<String> onSelected;

  const _AccentColorPicker({
    required this.selectedKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      ('skyBlue', 'Sky Blue', const Color(0xFF3B82F6), const Color(0xFFDBEAFE)),
      ('mintGreen', 'Mint', const Color(0xFF10B981), const Color(0xFFD1FAF5)),
      ('softLavender', 'Lavender', const Color(0xFF8B5CF6), const Color(0xFFF3E8FF)),
      ('warmPeach', 'Peach', const Color(0xFFF97316), const Color(0xFFFFEDD5)),
      ('dustyRose', 'Rose', const Color(0xFFF43F5E), const Color(0xFFFFE4E6)),
      ('softTeal', 'Teal', const Color(0xFF14B8A6), const Color(0xFFCCFBF1)),
      ('softIndigo', 'Indigo', const Color(0xFF6366F1), const Color(0xFFE0E7FF)),
      ('softAmber', 'Amber', const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'accent_color'.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((c) {
            final isSelected = c.$1 == selectedKey;
            return GestureDetector(
              onTap: () => onSelected(c.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: c.$4,
                  borderRadius: context.appRadius(12),
                  border: isSelected
                      ? Border.all(color: c.$3, width: 2)
                      : Border.all(color: c.$3.withValues(alpha: 0.3)),
                ),
                child: isSelected
                    ? Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: c.$3,
                          size: 24,
                        ),
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PreferenceSelector<T> extends StatelessWidget {
  final String label;
  final Set<T> selected;
  final List<ButtonSegment<T>> segments;
  final ValueChanged<T> onChanged;

  const _PreferenceSelector({
    required this.label,
    required this.selected,
    required this.segments,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<T>(
          segments: segments,
          selected: selected,
          expandedInsets: EdgeInsets.zero,
          showSelectedIcon: false,
          onSelectionChanged: (set) => onChanged(set.first),
        ),
      ],
    );
  }
}

class _DensitySelector extends StatelessWidget {
  final DisplayDensity selected;
  final ValueChanged<DisplayDensity> onChanged;

  const _DensitySelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _PreferenceSelector<DisplayDensity>(
      label: 'display_density'.tr(),
      selected: {selected},
      onChanged: onChanged,
      segments: [
        ButtonSegment(
          value: DisplayDensity.compact,
          label: Text('density_compact'.tr()),
        ),
        ButtonSegment(
          value: DisplayDensity.standard,
          label: Text('density_standard'.tr()),
        ),
        ButtonSegment(
          value: DisplayDensity.comfortable,
          label: Text('density_comfortable'.tr()),
        ),
      ],
    );
  }
}

class _CornerRadiusSelector extends StatelessWidget {
  final CornerRadiusStyle selected;
  final ValueChanged<CornerRadiusStyle> onChanged;

  const _CornerRadiusSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _PreferenceSelector<CornerRadiusStyle>(
      label: 'corner_radius'.tr(),
      selected: {selected},
      onChanged: onChanged,
      segments: [
        ButtonSegment(
          value: CornerRadiusStyle.soft,
          label: Text('radius_soft'.tr()),
        ),
        ButtonSegment(
          value: CornerRadiusStyle.medium,
          label: Text('radius_medium'.tr()),
        ),
        ButtonSegment(
          value: CornerRadiusStyle.sharp,
          label: Text('radius_sharp'.tr()),
        ),
      ],
    );
  }
}

class _TypographyScaleSelector extends StatelessWidget {
  final TypographyScale selected;
  final ValueChanged<TypographyScale> onChanged;

  const _TypographyScaleSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _PreferenceSelector<TypographyScale>(
      label: 'typography_scale'.tr(),
      selected: {selected},
      onChanged: onChanged,
      segments: [
        ButtonSegment(
          value: TypographyScale.compact,
          label: Text('type_compact'.tr()),
        ),
        ButtonSegment(
          value: TypographyScale.normal,
          label: Text('type_normal'.tr()),
        ),
        ButtonSegment(
          value: TypographyScale.comfortable,
          label: Text('type_comfortable'.tr()),
        ),
      ],
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  final String accentKey;
  final CornerRadiusStyle cornerRadius;
  final TypographyScale typographyScale;

  const _ThemePreviewCard({
    required this.accentKey,
    required this.cornerRadius,
    required this.typographyScale,
  });

  Color _getSeedColor() {
    switch (accentKey) {
      case 'skyBlue': return const Color(0xFF3B82F6);
      case 'mintGreen': return const Color(0xFF10B981);
      case 'softLavender': return const Color(0xFF8B5CF6);
      case 'warmPeach': return const Color(0xFFF97316);
      case 'dustyRose': return const Color(0xFFF43F5E);
      case 'softTeal': return const Color(0xFF14B8A6);
      case 'softIndigo': return const Color(0xFF6366F1);
      case 'softAmber': return const Color(0xFFF59E0B);
      default: return const Color(0xFF3B82F6);
    }
  }

  Color _getContainerColor() {
    switch (accentKey) {
      case 'skyBlue': return const Color(0xFFDBEAFE);
      case 'mintGreen': return const Color(0xFFD1FAF5);
      case 'softLavender': return const Color(0xFFF3E8FF);
      case 'warmPeach': return const Color(0xFFFFEDD5);
      case 'dustyRose': return const Color(0xFFFFE4E6);
      case 'softTeal': return const Color(0xFFCCFBF1);
      case 'softIndigo': return const Color(0xFFE0E7FF);
      case 'softAmber': return const Color(0xFFFEF3C7);
      default: return const Color(0xFFDBEAFE);
    }
  }

  double _getRadius() {
    switch (cornerRadius) {
      case CornerRadiusStyle.soft: return 16;
      case CornerRadiusStyle.medium: return 12;
      case CornerRadiusStyle.sharp: return 4;
    }
  }

  double _getScale() {
    switch (typographyScale) {
      case TypographyScale.compact: return 0.9;
      case TypographyScale.normal: return 1.0;
      case TypographyScale.comfortable: return 1.1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final seed = _getSeedColor();
    final container = _getContainerColor();
    final radius = _getRadius();
    final scale = _getScale();

    // Surface-based palette (not hardcoded white/grey) so the preview card
    // stays legible in dark mode.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: colors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'preview_label'.tr().toUpperCase(),
            style: TextStyle(
              fontSize: 10 * scale,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sample Heading',
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              color: seed,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is sample body text showing the current theme settings.',
            style: TextStyle(
              fontSize: 14 * scale,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 6 * scale,
                ),
                decoration: BoxDecoration(
                  color: container,
                  borderRadius: BorderRadius.circular(radius * 0.5),
                ),
                child: Text(
                  'Sample Chip',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    color: seed,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 8 * scale,
                ),
                decoration: BoxDecoration(
                  color: seed,
                  borderRadius: BorderRadius.circular(radius * 0.5),
                ),
                child: Text(
                  'Button',
                  style: TextStyle(
                    fontSize: 13 * scale,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SelectLanguageDialog extends StatefulWidget {
  const SelectLanguageDialog({super.key});

  @override
  State<SelectLanguageDialog> createState() => _SelectLanguageDialogState();
}

class _SelectLanguageDialogState extends State<SelectLanguageDialog> {
  final GlobalKey widgetKey = GlobalKey();
  final GlobalKey handlerKey = GlobalKey();

  double childHeight = 0.000001;

  @override
  void initState() {
    measureWidgetSize(
      context,
      callback: (height) {
        childHeight = height;
        setState(() {});
      },
      keys: [widgetKey, handlerKey],
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      initialChildSize: childHeight.clamp(0.1, .9),
      minChildSize: (childHeight - .2).clamp(0.0000000001, .9),
      maxChildSize: childHeight.clamp(0.1, .9),
      builder: (context, scrollController) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.colorScheme.surfaceContainerLowest,
                context.colorScheme.surface,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DragHandler(key: handlerKey),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Section(
                    key: widgetKey,
                    label: 'Select Language'.tr(),
                    child: (gap) => Column(
                      children: [
                        ...context.supportedLocales.map(
                          (e) => Material(
                            color: Colors.transparent,
                            child: Column(
                              children: [
                                ListTile(
                                  tileColor: context
                                      .colorScheme
                                      .surfaceContainerLow,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: context.appRadius(8),
                                    side: BorderSide(
                                      color: context
                                          .colorScheme
                                          .outlineVariant
                                          .withValues(alpha: 0.46),
                                    ),
                                  ),
                                  onTap: () async {
                                    await context.setLocale(e).then((value) {
                                      timeago.LookupMessages message =
                                          timeago.EnShortMessages();
                                      switch (e.languageCode) {
                                        case 'id':
                                          message = timeago.IdShortMessages();
                                          break;
                                        case 'zh':
                                          message = timeago.ZhCnMessages();
                                          break;
                                        default:
                                      }
                                      timeago.setLocaleMessages(
                                        e.languageCode,
                                        message,
                                      );
                                      router.maybePop();
                                      Fluttertoast.cancel();
                                      Fluttertoast.showToast(
                                        msg: 'Language switched'.tr(),
                                      );
                                    });
                                  },
                                  title: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/${e.languageCode}_flag.png',
                                        width: 20,
                                        fit: BoxFit.cover,
                                        height: 14,
                                      ),
                                      SizedBox(width: 8),
                                      Text(e.languageName),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BibleReminderDialog extends StatefulWidget {
  const BibleReminderDialog({
    super.key,
    required this.weekdays,
    required this.settingCubit,
  });

  final List<int> weekdays;
  final SettingsCubit settingCubit;

  @override
  State<BibleReminderDialog> createState() => _BibleReminderDialogState();
}

class _BibleReminderDialogState extends State<BibleReminderDialog> {
  late Map<int, DateTime> data = Map<int, DateTime>.from(
    widget.settingCubit.state.bibleReminders,
  );
  double childHeight = 0.00001;
  final GlobalKey widgetKey = GlobalKey();
  final GlobalKey handlerKey = GlobalKey();

  @override
  void initState() {
    measureWidgetSize(
      context,
      keys: [widgetKey, handlerKey],
      callback: (h) {
        childHeight = h;
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: widget.settingCubit,
      builder: (context, state) => DraggableScrollableSheet(
        initialChildSize: childHeight.clamp(0.00001, 1),
        maxChildSize: childHeight.clamp(0.00001, 1),
        minChildSize: (childHeight - .1).clamp(0.00001, 1),
        expand: false,
        snap: true,
        snapSizes: [childHeight],
        builder: (context, scrollController) => Material(
          color: context.colorScheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                DragHandler(key: handlerKey),
                Section(
                  key: widgetKey,
                  label: 'Bible Reminder'.tr(),
                  child: (gap) => SafeArea(
                    child: Column(
                      children: [
                        ...List.generate(widget.weekdays.length, (index) {
                          var item = widget.weekdays[index];
                          return Container(
                            margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                            decoration: BoxDecoration(
                              color: context.colorScheme.surfaceContainerLow,
                              borderRadius: context.appRadius(8),
                              border: Border.all(
                                color: context.colorScheme.outlineVariant
                                    .withValues(alpha: 0.46),
                              ),
                            ),
                            child: ListTile(
                              onTap: () async {
                                if (data[item] != null) {
                                  if (await context.showConfirmation(
                                    'This will destroy the schedule. Tap Yes to destroy'
                                        .tr(),
                                  )) {
                                    data.remove(item);
                                    setState(() {});
                                    return;
                                  }
                                }
                                if (!context.mounted) {
                                  return;
                                }
                                var time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                    data[item] ?? DateTime.now(),
                                  ),
                                );
                                if (time != null) {
                                  data[item] = DateTime(2023, 5, 1).copyWith(
                                    day: item,
                                    hour: time.hour,
                                    minute: time.minute,
                                    second: 00,
                                  );
                                  setState(() {});
                                }
                              },
                              title: Text(
                                widget.weekdays[index].toWeekdayName.tr(),
                                style: TextStyle(
                                  fontWeight: data[item] != null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              trailing: Container(
                                padding: data[item] == null
                                    ? null
                                    : EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                decoration: BoxDecoration(
                                  color: data[item] != null
                                      ? context.colorScheme.primary
                                      : null,
                                  borderRadius: context.appRadius(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (data[item] != null)
                                      Icon(
                                        Icons.notifications,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    SizedBox(width: 8),
                                    Text(
                                      widget.settingCubit.getTimeByWeekday(
                                        item,
                                        data,
                                      ),
                                      style: TextStyle(
                                        color: data[item] != null
                                            ? Colors.white
                                            : context
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        Container(
                          width: double.infinity,
                          color: context.colorScheme.surface,
                          padding: const EdgeInsets.all(16),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colorScheme.primary,
                              foregroundColor: context.colorScheme.onPrimary,
                              minimumSize: Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: context.appRadius(8),
                              ),
                            ),
                            onPressed: () async {
                              await widget.settingCubit
                                  .setBibleReminderDailyNotification(data);
                              if (!context.mounted) {
                                return;
                              }
                              Navigator.pop(context);
                            },
                            child: Text('Set Reminder'.tr()),
                          ),
                        ),
                      ],
                    ),
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

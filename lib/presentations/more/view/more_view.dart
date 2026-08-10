import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../components/components.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../di/injection.dart';
import '../../../domain/domain.dart';
import '../../../router/router.dart';
import '../../bible/bible.dart';
import '../../dashboard/dashboard.dart';
import '../../faith/faith.dart';
import '../../settings/settings.dart';
import '../../song/song.dart';

/// The "Lainnya" hub: every feature that is not one of the four primary tabs
/// lives here in large, predictable groups. Compact layouts show a single
/// column of wide tiles; wider layouts switch to two columns.
///
/// Content is grouped the way a first-time visitor thinks about the app:
/// reading, worship media, notes, downloads, and account/settings. Maximum
/// two levels of navigation below this hub.
@RoutePage()
class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lainnya'.tr())),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final twoColumns = constraints.maxWidth >= 720;
          return ListView(
            padding: EdgeInsets.fromLTRB(
              twoColumns ? 48 : 20,
              16,
              twoColumns ? 48 : 20,
              32,
            ),
            children: [
              const _MoreAccountPanel(),
              _MoreGroup(
                title: 'Literatur & Bacaan'.tr(),
                tiles: [
                  _MoreTile(
                    icon: Icons.auto_stories_outlined,
                    title: 'Literatur'.tr(),
                    subtitle: 'Manna, kesaksian, renungan, panduan kitab'.tr(),
                    onTap: () => router.push(const LiteratureRoute()),
                  ),
                  _MoreTile(
                    icon: Icons.newspaper_outlined,
                    title: 'Warta (Manna)'.tr(),
                    subtitle: 'Terbitan warta gereja'.tr(),
                    onTap: () => router.push(const LiteratureWartaRoute()),
                  ),
                  _MoreTile(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'Kesaksian'.tr(),
                    subtitle: 'Pengalaman iman para saudara seiman'.tr(),
                    onTap: () => router.push(const LiteratureKesaksianRoute()),
                  ),
                  _MoreTile(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Renungan'.tr(),
                    subtitle: 'Bacaan rohani harian'.tr(),
                    onTap: () => router.push(const LiteratureRenunganRoute()),
                  ),
                  _MoreTile(
                    icon: Icons.menu_book_outlined,
                    title: 'Panduan Alkitab'.tr(),
                    subtitle: 'Panduan belajar kitab'.tr(),
                    onTap: () => router.push(const LiteraturePanduanKitabRoute()),
                  ),
                ],
              ),
              _MoreGroup(
                title: 'Ibadah & Media'.tr(),
                tiles: [
                  _MoreTile(
                    icon: Icons.church_outlined,
                    title: 'Ibadah Online'.tr(),
                    onTap: () => router.push(
                      WebpageRoute(url: 'https://tjc.org/id/sabat/'),
                    ),
                  ),
                  _MoreTile(
                    icon: Icons.headphones_outlined,
                    title: 'Audio Khotbah'.tr(),
                    onTap: () => router.push(
                      WebpageRoute(url: 'https://tjc.org/id/audio-khotbah/'),
                    ),
                  ),
                  _MoreTile(
                    icon: Icons.videocam_outlined,
                    title: 'Video Khotbah'.tr(),
                    onTap: () => router.push(
                      WebpageRoute(url: 'https://tjc.org/id/video-khotbah/'),
                    ),
                  ),
                ],
              ),
              _MoreGroup(
                title: 'Catatan & Koleksi'.tr(),
                tiles: [
                  _MoreTile(
                    icon: Icons.bookmark_outlined,
                    title: 'Catatan Alkitab'.tr(),
                    onTap: () => router.push(
                      BibleNoteListRoute(cubit: di<BibleCubit>()),
                    ),
                  ),
                  _MoreTile(
                    icon: Icons.favorite_outline,
                    title: 'Catatan Iman'.tr(),
                    onTap: () => router.push(
                      FaithNoteListRoute(cubit: di<FaithCubit>()),
                    ),
                  ),
                  _MoreTile(
                    icon: Icons.library_music_outlined,
                    title: 'Catatan Pujian'.tr(),
                    onTap: () => router.push(
                      SongNotesListRoute(cubit: di<SongCubit>()),
                    ),
                  ),
                ],
              ),
              _MoreGroup(
                title: 'Unduhan & Data'.tr(),
                tiles: [
                  _MoreTile(
                    icon: Icons.menu_book_outlined,
                    title: 'Versi Alkitab'.tr(),
                    subtitle: 'Kelola Alkitab terpasang'.tr(),
                    onTap: () => router.push(
                      BibleVersionRoute(dashboardCubit: di<DashboardCubit>()),
                    ),
                  ),
                  _MoreTile(
                    icon: Icons.library_books_outlined,
                    title: 'Buku Kidung'.tr(),
                    subtitle: 'Kelola paket buku pujian'.tr(),
                    onTap: () => router.push(const HymnalManagementRoute()),
                  ),
                  _MoreTile(
                    icon: Icons.piano_outlined,
                    title: 'Suara Instrumen (SoundFont)'.tr(),
                    onTap: () => router.push(const SoundFontRoute()),
                  ),
                  _MoreTile(
                    icon: Icons.sync_alt_outlined,
                    title: 'Backup & Sinkronisasi'.tr(),
                    subtitle: 'Simpan dan pulihkan data aplikasi'.tr(),
                    onTap: () => _openBackup(context),
                  ),
                ],
              ),
              _MoreGroup(
                title: 'Akun & Pengaturan'.tr(),
                tiles: [
                  _MoreTile(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan'.tr(),
                    subtitle: 'Tema, ukuran huruf, audio, dan lainnya'.tr(),
                    onTap: () => router.push(const SettingsRoute()),
                  ),
                  _MoreTile(
                    icon: Icons.text_fields_outlined,
                    title: 'Ukuran Huruf'.tr(),
                    onTap: () => router.push(const FontSettingRoute()),
                  ),
                  _MoreTile(
                    icon: Icons.record_voice_over_outlined,
                    title: 'Audio Alkitab'.tr(),
                    onTap: () {
                      final cubit = di<BibleCubit>();
                      router.push(
                        BibleAudioSettingRoute(
                          initialState: cubit.state,
                          onSave: (state) {
                            cubit.applyTtsSetting(
                              state.voices,
                              state.pitchRate,
                              state.speedRate,
                            );
                            cubit.setTtsEngine(state.ttsEngine);
                            cubit.setAutoNextChapter(state.autoNextChapter);
                            cubit.setEdgeVoice(state.edgeVoice);
                            cubit.setEdgeRate(state.edgeRate);
                            cubit.setEdgePitch(state.edgePitch);
                            cubit.setEdgeVolume(state.edgeVolume);
                            cubit.initTts();
                          },
                        ),
                      );
                    },
                  ),
                  _MoreTile(
                    icon: Icons.feedback_outlined,
                    title: 'Kirim Masukan'.tr(),
                    subtitle: 'Lapor masalah atau beri saran'.tr(),
                    onTap: () => _openReport(context),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _openBackup(BuildContext context) {
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
            context.read<SettingsCubit>().sync(data.settingsState!);
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
  }

  void _openReport(BuildContext context) {
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
            debugPrint('[MoreView] onLoggedIn ERROR: $e\n$st');
            return null;
          }
        },
      ),
    );
  }
}

/// Compact account summary: shows the signed-in identity (or a prominent
/// login action) exactly where the old drawer's account panel lived.
class _MoreAccountPanel extends StatelessWidget {
  const _MoreAccountPanel();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final colors = context.colorScheme;
        final account = state.account;
        final isLoggedIn = state.isLoggedIn;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              colors.primary.withValues(alpha: 0.055),
              colors.surfaceContainerLow,
            ),
            borderRadius: context.appRadius(20),
            border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primaryContainer,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.5),
                    width: 1.4,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: colors.onPrimaryContainer,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoggedIn && account?.name?.trim().isNotEmpty == true
                          ? account!.name!.trim()
                          : 'Gereja Yesus Sejati',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLoggedIn
                          ? (account?.email?.trim().isNotEmpty == true
                                ? account!.email!.trim()
                                : 'Akun GYS')
                          : 'not_logged_in'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (isLoggedIn)
                IconButton(
                  tooltip: 'logout'.tr(),
                  onPressed: () {
                    context.read<DashboardCubit>().loginSuccessCallback(null);
                  },
                  icon: Icon(Icons.logout_rounded, color: colors.error),
                )
              else
                FilledButton.tonalIcon(
                  onPressed: () {
                    final cubit = context.read<DashboardCubit>();
                    router.push(
                      LoginRoute(
                        onLoggedIn: (token) {
                          router.maybePop();
                          cubit.loginSuccessCallback(token);
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: Text('Login'.tr()),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MoreGroup extends StatelessWidget {
  const _MoreGroup({required this.title, required this.tiles});

  final String title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 720;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
              child: Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            if (twoColumns)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.9,
                children: tiles,
              )
            else
              Column(
                children: [
                  for (final tile in tiles) tile,
                  const SizedBox(height: 8),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: context.appRadius(16),
        child: InkWell(
          borderRadius: context.appRadius(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    borderRadius: context.appRadius(13),
                  ),
                  child: Icon(icon, color: colors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../../router/router.dart';
import '../../presentations.dart';

const double _homeMaxContentWidth = 1080;

bool _isHttpImageUrl(String? imageUrl) {
  final uri = Uri.tryParse(imageUrl ?? '');
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
}

Widget _safeNetworkImage(
  String? imageUrl, {
  BoxFit fit = BoxFit.cover,
  double? height,
  double? width,
  Widget? fallback,
}) {
  final fallbackWidget = SizedBox(
    height: height,
    width: width,
    child: fallback ?? const ColoredBox(color: Color(0x14000000)),
  );
  if (!_isHttpImageUrl(imageUrl)) return fallbackWidget;

  return CachedNetworkImage(
    imageUrl: imageUrl!,
    fit: fit,
    height: height,
    width: width,
    memCacheWidth: width != null && width.isFinite
        ? (width * 2.5).round()
        : 800,
    memCacheHeight: height != null && height.isFinite
        ? (height * 2.5).round()
        : 360,
    placeholder: (context, url) => fallbackWidget,
    errorWidget: (context, url, error) => fallbackWidget,
  );
}

/// Beranda — the quiet landing page for everyday reading.
///
/// Structure is deliberately minimal and predictable: wordmark, two large
/// primary actions (Buka Alkitab / Cari Pujian), continue-reading shortcuts,
/// today's verse, and one announcements area. The old link grids and media
/// feeds moved to the "Lainnya" hub.
@RoutePage()
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.sauhs != current.sauhs ||
          previous.trueVoices != current.trueVoices ||
          previous.menuLinks != current.menuLinks ||
          previous.isSauhEnabled != current.isSauhEnabled ||
          previous.isSuaraSejatiEnabled != current.isSuaraSejatiEnabled,
      builder: (context, state) {
        final colors = context.colorScheme;
        return ColoredBox(
          color: colors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HomeHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: context.read<HomeCubit>().refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _homeMaxContentWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _WelcomeVersePanel(),
                            const _HomeQuickActions(),
                            const _ContinueReadingSection(),
                            _HomeBannerCarousel(
                              stream: context
                                  .read<HomeCubit>()
                                  .bannerObservable,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
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

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: colors.surface.withValues(alpha: 0.96),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.32),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    isDark
                        ? Assets.assetsImagesLogoIndonesiaWhite
                        : Assets.assetsImagesLogoIndonesiaColor,
                    height: 27,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selamat datang + Ayat Hari Ini in one compact panel. Wide layouts put the
/// two sections side by side; narrow phones stack them inside the same box.
class _WelcomeVersePanel extends StatelessWidget {
  const _WelcomeVersePanel();

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.todayVerse != current.todayVerse,
      builder: (context, state) {
        final hasVerse = state.hasTodayVerse;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: context.appRadius(24),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.28),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (!hasVerse) return const _WelcomeContent();
                if (constraints.maxWidth >= 560) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(child: _WelcomeContent()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Container(
                          width: 1,
                          color: colors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      const Expanded(child: _VerseContent()),
                    ],
                  );
                }
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _WelcomeContent(),
                    Divider(height: 24),
                    _VerseContent(),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _WelcomeContent extends StatelessWidget {
  const _WelcomeContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (previous, current) =>
          previous.idToken != current.idToken ||
          previous.account != current.account,
      builder: (context, state) {
        final colors = context.colorScheme;
        final isLoggedIn = state.isLoggedIn;
        final displayName = state.account?.name?.trim();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: context.appRadius(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.wb_sunny_outlined,
                color: colors.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shalom',
                    style: context.textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isLoggedIn
                        ? (displayName?.isNotEmpty == true
                              ? displayName!
                              : 'Jemaat Terkasih')
                        : 'Selamat datang',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          DateFormat(
                            'EEEE, d MMMM yyyy',
                            context.locale.languageCode,
                          ).format(DateTime.now()),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The two primary actions, sized for a senior thumb and always labelled.
class _HomeQuickActions extends StatelessWidget {
  const _HomeQuickActions();

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final twoColumns = constraints.maxWidth >= 560;
          final actions = [
            _QuickAction(
              icon: Icons.menu_book_rounded,
              title: 'Buka Alkitab',
              subtitle: 'Bacaan dan renungan harian',
              color: colors.primary,
              onTap: () => dashboardTabsRouter?.setActiveIndex(1),
            ),
            _QuickAction(
              icon: Icons.music_note_rounded,
              title: 'Cari Pujian',
              subtitle: 'Cari lagu berdasarkan nomor',
              color: colors.tertiary,
              onTap: () => router.push(
                GlobalSearchRoute(
                  initialSection: GlobalSearchSection.song,
                ),
              ),
            ),
          ];
          if (twoColumns) {
            return Row(
              children: [
                Expanded(child: actions[0]),
                const SizedBox(width: 12),
                Expanded(child: actions[1]),
              ],
            );
          }
          return Column(
            children: [
              for (final action in actions) ...[
                action,
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: context.appRadius(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(
              color: color.withValues(alpha: 0.28),
            ),
            borderRadius: context.appRadius(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: context.appRadius(17),
                  ),
                  child: Icon(icon, size: 30, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 26,
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

/// Continue-reading shortcuts: the last opened hymn and the last Bible
/// chapter, so one tap resumes either one.
class _ContinueReadingSection extends StatelessWidget {
  const _ContinueReadingSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongCubit, SongState>(
      buildWhen: (previous, current) =>
          previous.lastOpenedSong != current.lastOpenedSong,
      builder: (context, songState) {
        final lastSong = songState.lastOpenedSong;
        return BlocBuilder<BibleCubit, BibleState>(
          buildWhen: (previous, current) =>
              previous.currentBible != current.currentBible ||
              previous.lastOpenBible != current.lastOpenBible,
          builder: (context, bibleState) {
            final lastBible = bibleState.currentBible;
            final hasSong = lastSong != null;
            final hasBible = lastBible != null && bibleState.lastOpenBible != null;
            if (!hasSong && !hasBible) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'LANJUTKAN MEMBACA',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colorScheme.primary,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (hasSong)
                    _ContinueTile(
                      icon: Icons.music_note_rounded,
                      title:
                          '${lastSong.code ?? ''} ${lastSong.number ?? ''} — ${lastSong.title ?? ''}',
                      subtitle: 'Pujian terakhir',
                      onTap: () {
                        dashboardTabsRouter?.setActiveIndex(2);
                        unawaited(context.read<SongCubit>().openSong(lastSong));
                      },
                    ),
                  if (hasSong && hasBible) const SizedBox(height: 8),
                  if (hasBible)
                    _ContinueBibleTile(
                      cubit: context.read<BibleCubit>(),
                      verse: lastBible,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ContinueTile extends StatelessWidget {
  const _ContinueTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: context.appRadius(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.28),
            ),
            borderRadius: context.appRadius(18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.66),
                    borderRadius: context.appRadius(13),
                  ),
                  child: Icon(icon, size: 22, color: colors.onPrimaryContainer),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
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

class _ContinueBibleTile extends StatefulWidget {
  const _ContinueBibleTile({required this.cubit, required this.verse});

  final BibleCubit cubit;
  final Verse verse;

  @override
  State<_ContinueBibleTile> createState() => _ContinueBibleTileState();
}

class _ContinueBibleTileState extends State<_ContinueBibleTile> {
  Verse? _titleFor;
  Future<String?>? _titleFuture;

  Future<String?> _titleFutureFor() {
    if (identical(_titleFor, widget.verse) && _titleFuture != null) {
      return _titleFuture!;
    }
    _titleFor = widget.verse;
    _titleFuture = widget.cubit.getBibleTitle([widget.verse]);
    return _titleFuture!;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return FutureBuilder<String?>(
      future: _titleFutureFor(),
      builder: (context, snapshot) {
        final title = snapshot.data?.trim().isNotEmpty == true
            ? snapshot.data!.trim()
            : 'Bacaan terakhir';
        return Material(
          color: colors.surfaceContainerLow,
          borderRadius: context.appRadius(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              dashboardTabsRouter?.setActiveIndex(1);
              unawaited(widget.cubit.getContent(widget.verse));
            },
            child: Ink(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.28),
                ),
                borderRadius: context.appRadius(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withValues(alpha: 0.66),
                        borderRadius: context.appRadius(13),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 22,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Bacaan terakhir',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
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
      },
    );
  }
}

class _VerseContent extends StatelessWidget {
  const _VerseContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.todayVerse != current.todayVerse,
      builder: (context, state) {
        if (!state.hasTodayVerse) return const SizedBox.shrink();

        final verse = state.todayVerse!;
        final colors = context.colorScheme;
        final homeCubit = context.read<HomeCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: context.appRadius(10),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: colors.onPrimaryContainer,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AYAT HARI INI',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '“${verse.text}”',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _VerseChip(
                  label: verse.reference,
                  color: colors.primaryContainer,
                  foreground: colors.onPrimaryContainer,
                ),
                if (verse.bibleCodeName != null)
                  InkWell(
                    borderRadius: context.appRadius(999),
                    onTap: () => _showBibleVersionPicker(context, homeCubit),
                    child: _VerseChip(
                      label: verse.bibleCodeName!,
                      color: colors.tertiaryContainer,
                      foreground: colors.onTertiaryContainer,
                      trailing: Icons.keyboard_arrow_down_rounded,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showBibleVersionPicker(BuildContext context, HomeCubit homeCubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) => BibleSelectWidget(
        bibleCodes: homeCubit.bibleCodes,
        onTap: (index) {
          final code = homeCubit.bibleCodes[index].split('.').first;
          homeCubit.switchTodayVerseBible(code);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _VerseChip extends StatelessWidget {
  const _VerseChip({
    required this.label,
    required this.color,
    required this.foreground,
    this.trailing,
  });

  final String label;
  final Color color;
  final Color foreground;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.72),
        borderRadius: context.appRadius(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 2),
            Icon(trailing, size: 16, color: foreground),
          ],
        ],
      ),
    );
  }
}

class _HomeBannerCarousel extends StatelessWidget {
  const _HomeBannerCarousel({required this.stream});

  final Stream<List<ImageBanner>> stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ImageBanner>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError) {
          return const SizedBox.shrink();
        }
        final banners = (snapshot.data ?? const <ImageBanner>[])
            .where((element) => !element.isExpired)
            .toList(growable: false);
        if (banners.isEmpty) return const SizedBox.shrink();

        return Section(
          label: 'Pengumuman',
          child: (gap) => CarouselSlider.builder(
            itemCount: banners.length,
            itemBuilder: (context, index, realIndex) {
              final banner = banners[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: gap),
                child: Material(
                  color: context.colorScheme.surfaceContainerLow,
                  borderRadius: context.appRadius(20),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: banner.linkUrl == null
                        ? null
                        : () {
                            final link = banner.linkUrl!;
                            if (link.startsWith('http')) {
                              router.push(WebpageRoute(url: link));
                            } else {
                              router.pushPath(link);
                            }
                          },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _safeNetworkImage(banner.imageUrl, fit: BoxFit.cover),
                        if (banner.linkUrl != null)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.42),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.open_in_new_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 158,
              enlargeFactor: 1,
              autoPlay: banners.length > 1,
              viewportFraction: 1,
            ),
          ),
        );
      },
    );
  }
}

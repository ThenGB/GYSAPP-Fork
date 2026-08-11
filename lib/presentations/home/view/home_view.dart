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
                  child: _AutoHideNavScroll(
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
                              const _HomeQuickNav(),
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

/// Selamat datang + Sauh Bagi Jiwa joined in ONE box, always side by side
/// horizontally — on every layout, including portrait phones.
class _WelcomeVersePanel extends StatelessWidget {
  const _WelcomeVersePanel();

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.sauhs != current.sauhs ||
          previous.isSauhEnabled != current.isSauhEnabled,
      builder: (context, state) {
        final hasSauh = state.isSauhEnabled && state.sauhs.isNotEmpty;
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
            child: !hasSauh
                ? const _WelcomeContent()
                : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(child: _WelcomeContent()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Container(
                            width: 1,
                            height: double.infinity,
                            color: colors.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        const Expanded(child: _SauhContent()),
                      ],
                    ),
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
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
            // Auto-fits so long names are scaled down instead of clipped.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
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
        );
      },
    );
  }
}

/// Four large, elderly-friendly navigation icons into the app's main areas:
/// Kidung, Alkitab, Dasar Kepercayaan, and Lainnya.
class _HomeQuickNav extends StatelessWidget {
  const _HomeQuickNav();

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final items = [
      _QuickNavItem(
        icon: Icons.music_note_rounded,
        label: 'Kidung',
        color: colors.tertiary,
        onTap: () => dashboardTabsRouter?.setActiveIndex(2),
      ),
      _QuickNavItem(
        icon: Icons.menu_book_rounded,
        label: 'Alkitab',
        color: colors.primary,
        onTap: () => dashboardTabsRouter?.setActiveIndex(1),
      ),
      _QuickNavItem(
        icon: Icons.auto_stories_rounded,
        label: 'Dasar Kepercayaan',
        color: colors.secondary,
        onTap: () => dashboardTabsRouter?.setActiveIndex(3),
      ),
      _QuickNavItem(
        icon: Icons.more_horiz_rounded,
        label: 'Lainnya',
        color: colors.tertiaryContainer,
        onTap: () => dashboardTabsRouter?.setActiveIndex(4),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      // Always ONE row of four, even on portrait phones. Note: NOT
      // stretch — this Row lives inside the dashboard's unbounded-height
      // scroll view, and stretch would force infinite child heights.
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: items[i]),
          ],
        ],
      ),
    );
  }
}

class _QuickNavItem extends StatelessWidget {
  const _QuickNavItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        // The icon scales with the tile so all four fit on a narrow phone.
        final iconSide = (constraints.maxWidth - 14).clamp(42.0, 64.0);
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: iconSide,
                      height: iconSide,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.16),
                        borderRadius: context.appRadius(18),
                      ),
                      child: Icon(icon, size: iconSide * 0.55, color: color),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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

/// Reports the Beranda scroll direction so the shell can auto-hide the
/// bottom dock: scrolling down hides it, scrolling up (or reaching the top)
/// reveals it again.
class _AutoHideNavScroll extends StatefulWidget {
  const _AutoHideNavScroll({required this.child});

  final Widget child;

  @override
  State<_AutoHideNavScroll> createState() => _AutoHideNavScrollState();
}

class _AutoHideNavScrollState extends State<_AutoHideNavScroll> {
  double _lastOffset = 0;

  bool _onScroll(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification) return false;
    final pixels = notification.metrics.pixels;
    final delta = pixels - _lastOffset;
    _lastOffset = pixels;
    if (pixels <= 8) {
      dashboardNavBarVisible.value = true;
    } else if (delta < -1) {
      dashboardNavBarVisible.value = true;
    } else if (delta > 1 && pixels > 48) {
      dashboardNavBarVisible.value = false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: widget.child,
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

class _SauhContent extends StatelessWidget {
  const _SauhContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.sauhs != current.sauhs ||
          previous.isSauhEnabled != current.isSauhEnabled,
      builder: (context, state) {
        if (!state.isSauhEnabled || state.sauhs.isEmpty) {
          return const SizedBox.shrink();
        }
        final sauh = state.sauhs.first;
        final colors = context.colorScheme;
        // Tapping anywhere on the card (except nothing special anymore —
        // the reference/version chips are gone) opens today's sauh article.
        return InkWell(
          borderRadius: context.appRadius(18),
          onTap: () {
            router.push(WebpageRoute(url: sauh.url));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'SAUH BAGI JIWA',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SauhThumbnail(imageUrl: sauh.imageUrl),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                sauh.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sauh.description,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  // Deliberately not bold so the panel stays compact.
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Small cover image of today's sauh with a hint overlay in the top-right
/// corner.
class _SauhThumbnail extends StatelessWidget {
  const _SauhThumbnail({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: context.appRadius(10),
      child: SizedBox(
        width: 76,
        height: 56,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _safeNetworkImage(imageUrl, fit: BoxFit.cover),
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Tekan untuk baca lebih lanjut',
                  style: TextStyle(
                    fontSize: context.appFontSize(7),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
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

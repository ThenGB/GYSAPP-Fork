import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../domain/entity/banner/banner.dart';
import '../../../domain/entity/menulink/menulink_entity.dart';
import '../../../domain/entity/sauh/sauh_entity.dart';
import '../../../domain/entity/truevoice/truevoice_entity.dart';
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
    memCacheWidth: width != null && width.isFinite ? (width * 2.5).round() : 800,
    memCacheHeight:
        height != null && height.isFinite ? (height * 2.5).round() : 360,
    placeholder: (context, url) => fallbackWidget,
    errorWidget: (context, url, error) => fallbackWidget,
  );
}

bool _isYouTubeUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  final host = uri.host.toLowerCase();
  return host.contains('youtube.com') || host.contains('youtu.be');
}

bool _isSpotifyUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  return uri.host.toLowerCase().contains('spotify.com');
}

String? _extractYouTubeVideoId(Uri uri) {
  final host = uri.host.toLowerCase();
  if (host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  }
  if (!host.contains('youtube.com')) return null;
  final fromQuery = uri.queryParameters['v'];
  if (fromQuery != null && fromQuery.isNotEmpty) return fromQuery;
  if (uri.pathSegments.length >= 2) {
    final type = uri.pathSegments.first;
    if (type == 'shorts' || type == 'embed' || type == 'live') {
      return uri.pathSegments[1];
    }
  }
  return null;
}

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
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.surface,
                colors.surfaceContainerLowest,
                colors.surface,
              ],
              stops: const [0, 0.38, 1],
            ),
          ),
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
                            const _HomeWelcomeSection(),
                            const _DailyVerseCard(),
                            _HomeBannerCarousel(
                              stream: context.read<HomeCubit>().bannerObservable,
                            ),
                            if (state.sauhs.isNotEmpty && state.isSauhEnabled)
                              SauhBagiJiwa(item: state.sauhs.first),
                            if (state.isSuaraSejatiEnabled)
                              SuaraSejati(trueVoices: state.trueVoices),
                            LinkLainnya(menuLinks: state.menuLinks),
                            const SizedBox(height: 20),
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
              _HeaderAction(
                tooltip: 'Menu',
                icon: Icons.menu_rounded,
                onPressed: openDashboardDrawer,
              ),
              const SizedBox(width: 12),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: context.appRadius(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.church_rounded, size: 15, color: colors.primary),
                    const SizedBox(width: 5),
                    Text(
                      'GYS',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
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
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: context.appRadius(14),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 21),
      ),
    );
  }
}

class _HomeWelcomeSection extends StatelessWidget {
  const _HomeWelcomeSection();

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
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primaryContainer.withValues(alpha: 0.58),
                  colors.secondaryContainer.withValues(alpha: 0.28),
                  colors.surfaceContainerLow,
                ],
              ),
              borderRadius: context.appRadius(24),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.28),
              ),
            ),
            child: Row(
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
            ),
          ),
        );
      },
    );
  }
}

class _DailyVerseCard extends StatelessWidget {
  const _DailyVerseCard();

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
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: Container(
            padding: EdgeInsets.all(context.appSpace(18)),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: context.appRadius(22),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: context.appRadius(11),
                      ),
                      child: Icon(
                        Icons.auto_stories_rounded,
                        color: colors.onPrimaryContainer,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'AYAT HARI INI',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.format_quote_rounded,
                      color: colors.primary.withValues(alpha: 0.45),
                      size: 26,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '“${verse.text}”',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.55,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
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
            ),
          ),
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
                              launchUrl(
                                Uri.parse(link),
                                mode: LaunchMode.externalApplication,
                              );
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

class LinkLainnya extends StatelessWidget {
  const LinkLainnya({super.key, required this.menuLinks});

  final List<Menulink> menuLinks;

  @override
  Widget build(BuildContext context) {
    final spotifyLinks = <Menulink>[];
    final youtubeLinks = <Menulink>[];
    final otherLinks = <Menulink>[];
    for (final link in menuLinks) {
      final url = link.url.toLowerCase();
      if (url.contains('spotify')) {
        spotifyLinks.add(link);
      } else if (url.contains('youtube') || url.contains('youtu.be')) {
        youtubeLinks.add(link);
      } else {
        otherLinks.add(link);
      }
    }

    return Column(
      children: [
        if (spotifyLinks.isNotEmpty)
          _LinkGroup(
            title: 'Spotify GYS',
            menuLinks: spotifyLinks,
            icon: Icons.music_note_rounded,
          ),
        if (youtubeLinks.isNotEmpty)
          _LinkGroup(
            title: 'YouTube GYS',
            menuLinks: youtubeLinks,
            icon: Icons.smart_display_rounded,
          ),
        if (otherLinks.isNotEmpty)
          _LinkGroup(
            title: 'Link lainnya'.tr(),
            menuLinks: otherLinks,
            icon: Icons.link_rounded,
          ),
      ],
    );
  }
}

class _LinkGroup extends StatelessWidget {
  const _LinkGroup({
    required this.title,
    required this.menuLinks,
    required this.icon,
  });

  final String title;
  final List<Menulink> menuLinks;
  final IconData icon;

  Future<void> _handleTap(BuildContext context, Menulink link) async {
    if (!link.enabled) {
      context.showSnackBar('Fitur ini tidak tersedia');
      return;
    }
    if (link.url.startsWith('app://') && !kIsWeb && Platform.isAndroid) {
      context.showSnackBar('Aplikasi tidak ditemukan');
      return;
    }
    if (link.url.startsWith('http')) {
      await launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication);
      return;
    }
    if (link.url == 'khotbah') {
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        builder: (context) => const IbadahPopup(),
      );
      return;
    }
    router.pushPath(link.url);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Section(
      label: title,
      child: (gap) => Padding(
        padding: EdgeInsets.symmetric(horizontal: gap),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            final columns = constraints.maxWidth >= 760 ? 4 : 2;
            final width = ((constraints.maxWidth - spacing * (columns - 1)) /
                    columns)
                .clamp(0.0, double.infinity);
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: menuLinks
                  .take(4)
                  .map(
                    (link) => SizedBox(
                      width: width,
                      child: Material(
                        color: colors.surfaceContainerLow,
                        borderRadius: context.appRadius(16),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _handleTap(context, link),
                          child: Ink(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colors.outlineVariant.withValues(
                                  alpha: 0.28,
                                ),
                              ),
                              borderRadius: context.appRadius(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: context.appRadius(11),
                                    child: Container(
                                      width: 42,
                                      height: 42,
                                      color: colors.surfaceContainerHighest,
                                      child: _LinkThumbnail(
                                        link: link,
                                        fallbackIcon: icon,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          link.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _linkSubtitle(link.url),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.textTheme.bodySmall
                                              ?.copyWith(
                                                color: colors.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      ),
    );
  }

  String _linkSubtitle(String url) {
    final host = Uri.tryParse(url)?.host ?? '';
    return host.isEmpty ? 'Gereja Yesus Sejati' : host;
  }
}

class _LinkThumbnail extends StatefulWidget {
  const _LinkThumbnail({required this.link, required this.fallbackIcon});

  final Menulink link;
  final IconData fallbackIcon;

  @override
  State<_LinkThumbnail> createState() => _LinkThumbnailState();
}

class _LinkThumbnailState extends State<_LinkThumbnail> {
  static final Map<String, String?> _thumbnailCache = {};
  late Future<String?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _thumbnailFuture = _resolveThumbnail(widget.link.url);
  }

  @override
  void didUpdateWidget(covariant _LinkThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.link.url != widget.link.url) {
      _thumbnailFuture = _resolveThumbnail(widget.link.url);
    }
  }

  Future<String?> _resolveThumbnail(String url) async {
    if (_thumbnailCache.containsKey(url)) return _thumbnailCache[url];
    final uri = Uri.tryParse(url);
    if (uri == null) return _thumbnailCache[url] = null;

    if (_isYouTubeUrl(url)) {
      final videoId = _extractYouTubeVideoId(uri);
      final thumbnail = videoId == null || videoId.isEmpty
          ? null
          : 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
      _thumbnailCache[url] = thumbnail;
      return thumbnail;
    }

    if (_isSpotifyUrl(url)) {
      final oembedUri = Uri.https('open.spotify.com', '/oembed', {'url': url});
      try {
        final response = await http
            .get(oembedUri)
            .timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          if (body is Map<String, dynamic>) {
            final thumbnail = body['thumbnail_url'];
            if (thumbnail is String && _isHttpImageUrl(thumbnail)) {
              _thumbnailCache[url] = thumbnail;
              return thumbnail;
            }
          }
        }
      } catch (_) {}
    }

    _thumbnailCache[url] = null;
    return null;
  }

  Widget _fallbackTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Image(
        image: widget.link.iconImageProvider,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => Icon(
          widget.fallbackIcon,
          color: context.colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canResolve =
        _isYouTubeUrl(widget.link.url) || _isSpotifyUrl(widget.link.url);
    if (!canResolve) return _fallbackTile(context);

    return FutureBuilder<String?>(
      future: _thumbnailFuture,
      builder: (context, snapshot) {
        final thumbnail = snapshot.data;
        if (thumbnail == null || thumbnail.isEmpty) {
          return _fallbackTile(context);
        }
        return _safeNetworkImage(
          thumbnail,
          fit: BoxFit.cover,
          height: 42,
          width: 42,
          fallback: _fallbackTile(context),
        );
      },
    );
  }
}

class IbadahPopup extends StatefulWidget {
  const IbadahPopup({super.key});

  @override
  State<IbadahPopup> createState() => _IbadahPopupState();
}

class _IbadahPopupState extends State<IbadahPopup> {
  final ValueNotifier<double> childHeight = ValueNotifier(0.001);
  final GlobalKey widgetKey = GlobalKey();
  final GlobalKey handlerKey = GlobalKey();

  @override
  void didChangeDependencies() {
    measureWidgetSize(
      context,
      keys: [widgetKey, handlerKey],
      callback: (result) => childHeight.value = result,
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    childHeight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: childHeight,
      builder: (context, height, child) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: height,
        initialChildSize: height,
        minChildSize: (height - .2).clamp(0.001, 1),
        snap: true,
        builder: (context, scrollController) => Container(
          padding: context.mediaQuery.viewInsets,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: context.appRadius(20).copyWith(
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
            ),
          ),
          child: Column(
            children: [
              DragHandler(key: handlerKey),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Section(
                    key: widgetKey,
                    label: 'Ibadah'.tr(),
                    child: (gap) => Material(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () => router.popAndPush(
                              WebpageRoute(url: 'https://tjc.org/id/sabat/'),
                            ),
                            leading: const Icon(Icons.church_outlined),
                            title: Text('Ibadah online'.tr()),
                          ),
                          ListTile(
                            onTap: () => router.popAndPush(
                              WebpageRoute(
                                url: 'https://tjc.org/id/audio-khotbah/',
                              ),
                            ),
                            leading: const Icon(Icons.headphones_outlined),
                            title: Text('Audio Khotbah'.tr()),
                          ),
                          ListTile(
                            onTap: () => router.popAndPush(
                              WebpageRoute(
                                url: 'https://tjc.org/id/video-khotbah/',
                              ),
                            ),
                            leading: const Icon(Icons.videocam_outlined),
                            title: Text('Video Khotbah'.tr()),
                          ),
                        ],
                      ),
                    ),
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

class SauhBagiJiwa extends StatelessWidget {
  const SauhBagiJiwa({super.key, required this.item});

  final Sauh item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Section(
      label: 'Sauh Bagi Jiwa'.tr(),
      child: (gap) => Padding(
        padding: EdgeInsets.symmetric(horizontal: gap),
        child: Material(
          color: colors.surfaceContainerLow,
          borderRadius: context.appRadius(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => router.push(WebpageRoute(url: item.url)),
            child: Ink(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.28),
                ),
                borderRadius: context.appRadius(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _safeNetworkImage(
                    item.imageUrl,
                    height: 160,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SuaraSejati extends StatelessWidget {
  const SuaraSejati({super.key, required this.trueVoices});

  final List<TrueVoice> trueVoices;

  @override
  Widget build(BuildContext context) {
    if (trueVoices.isEmpty) return const SizedBox.shrink();
    final colors = context.colorScheme;
    return Section(
      label: 'Suara Sejati'.tr(),
      child: (gap) => SizedBox(
        height: 186,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: trueVoices.length,
          itemBuilder: (context, index) {
            final item = trueVoices[index];
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? gap : 4, right: 6),
              child: SizedBox(
                width: 166,
                child: Material(
                  color: colors.surfaceContainerLow,
                  borderRadius: context.appRadius(16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => router.push(WebpageRoute(url: item.url)),
                    child: Ink(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.28),
                        ),
                        borderRadius: context.appRadius(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 166,
                            height: 112,
                            child: _safeNetworkImage(
                              item.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    item.title,
                                    maxLines: 1,
                                    minFontSize: 8,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (item.creator.trim().isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      item.creator.trim(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.bodySmall?.copyWith(
                                        color: colors.onSurfaceVariant,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

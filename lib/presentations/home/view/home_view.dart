import 'dart:convert';
import 'dart:developer';
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
    child:
        fallback ??
        ColoredBox(color: Colors.grey.shade300, child: const SizedBox.expand()),
  );
  if (!_isHttpImageUrl(imageUrl)) {
    return fallbackWidget;
  }
  return CachedNetworkImage(
    imageUrl: imageUrl!,
    fit: fit,
    height: height,
    width: width,
    memCacheWidth: width != null && width.isFinite ? (width * 2.5).round() : 800,
    memCacheHeight: height != null && height.isFinite ? (height * 2.5).round() : 360,
    placeholder: (context, url) =>
        const Center(child: CircularProgressIndicator()),
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

const double _homeMaxContentWidth = 1080;

@RoutePage()
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) => ColoredBox(
        color: context.colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.only(top: context.mediaQuery.padding.top),
              color: context.colorScheme.surface,
              child: const HomeHeader(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    context.read<HomeCubit>().refresh(),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
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
                          StreamBuilder(
                            stream: context.read<HomeCubit>().bannerObservable,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox.shrink();
                              }
                              if (snapshot.hasError) {
                                return const SizedBox.shrink();
                              }
                              final banners =
                                  (snapshot.data as List<ImageBanner>)
                                      .where((element) => !element.isExpired)
                                      .toList();
                              if (banners.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Section(
                                child: (gap) => CarouselSlider.builder(
                                  itemCount: banners.length,
                                  itemBuilder: (context, index, realIndex) {
                                    var banner = banners[index];
                                    return GestureDetector(
                                      onTap: banner.linkUrl == null
                                          ? null
                                          : () {
                                              if (banner.linkUrl!.contains(
                                                'http',
                                              )) {
                                                launchUrl(
                                                  Uri.parse(banner.linkUrl!),
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                              } else {
                                                router.pushPath(
                                                  banner.linkUrl!,
                                                );
                                              }
                                            },
                                      child: Container(
                                        width: double.infinity,
                                        clipBehavior: Clip.hardEdge,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: gap,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: context.appRadius(20),
                                          color: context
                                              .colorScheme
                                              .surfaceContainer,
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: _safeNetworkImage(
                                                banner.imageUrl,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            if (banner.linkUrl != null)
                                              Positioned.fill(
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          8.0,
                                                        ),
                                                    child: Icon(
                                                      Icons.link,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  options: CarouselOptions(
                                    height: 150,
                                    enlargeFactor: 1,
                                    autoPlay: true,
                                    enlargeStrategy:
                                        CenterPageEnlargeStrategy.scale,
                                    viewportFraction: 1,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (state.sauhs.isNotEmpty && state.isSauhEnabled)
                            SauhBagiJiwa(item: state.sauhs.first),
                          if (state.isSuaraSejatiEnabled)
                            SuaraSejati(trueVoices: state.trueVoices),
                          LinkLainnya(menuLinks: state.menuLinks),
                          SizedBox(height: 12),
                        ],
                      ),
                    ),
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

class LinkLainnya extends StatelessWidget {
  final List<Menulink> menuLinks;
  const LinkLainnya({super.key, required this.menuLinks});

  @override
  Widget build(BuildContext context) {
    final spotifyLinks = menuLinks
        .where((e) => e.url.toLowerCase().contains('spotify'))
        .toList();
    final youtubeLinks = menuLinks
        .where(
          (e) =>
              e.url.toLowerCase().contains('youtube') ||
              e.url.toLowerCase().contains('youtu.be'),
        )
        .toList();
    final otherLinks = menuLinks
        .where((e) => !spotifyLinks.contains(e) && !youtubeLinks.contains(e))
        .toList();

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
  final String title;
  final List<Menulink> menuLinks;
  final IconData icon;

  const _LinkGroup({
    required this.title,
    required this.menuLinks,
    required this.icon,
  });

  Future<void> _handleTap(BuildContext context, Menulink link) async {
    if (!link.enabled) {
      context.showSnackBar('Fitur ini tidak tersedia');
      return;
    }
    if (link.url.startsWith('app://') && !kIsWeb && Platform.isAndroid) {
      context.showSnackBar('Aplikasi tidak ditemukan');
      return;
    }
    if (link.url.contains('http')) {
      final res = await launchUrl(
        Uri.parse(link.url),
        mode: LaunchMode.externalApplication,
      );
      log(res.toString());
      return;
    }
    if (link.url == 'khotbah') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        builder: (context) => IbadahPopup(),
      );
      return;
    }
    router.pushPath(link.url);
  }

  @override
  Widget build(BuildContext context) {
    return Section(
      label: title,
      child: (gap) => Padding(
        padding: EdgeInsets.symmetric(horizontal: gap),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            // Guard against a degenerate (0-width) layout pass — e.g. the
            // first frame after launch or an extreme window resize — which
            // would otherwise produce a negative SizedBox width and crash
            // with "BoxConstraints has a negative minimum width".
            final width = ((constraints.maxWidth - spacing) / 2)
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
                        color: context.colorScheme.surfaceContainer,
                        borderRadius: context.appRadius(16),
                        child: InkWell(
                          borderRadius: context.appRadius(16),
                          onTap: () => _handleTap(context, link),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: context.appRadius(10),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    color: context.colorScheme.surfaceContainerHighest,
                                    child: _LinkThumbnail(
                                      link: link,
                                      fallbackIcon: icon,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        link.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: context.appFontSize(15),
                                            ),
                                      ),
                                      Text(
                                        (() {
                                          final host =
                                              Uri.tryParse(link.url)?.host ??
                                              '';
                                          return host.isEmpty
                                              ? 'Gereja Yesus Sejati'
                                              : host;
                                        })(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              color: context
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              fontSize: context.appFontSize(12),
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
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

class _LinkThumbnail extends StatefulWidget {
  final Menulink link;
  final IconData fallbackIcon;

  const _LinkThumbnail({required this.link, required this.fallbackIcon});

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
    if (uri == null) {
      _thumbnailCache[url] = null;
      return null;
    }
    if (_isYouTubeUrl(url)) {
      final videoId = _extractYouTubeVideoId(uri);
      final thumb = videoId == null || videoId.isEmpty
          ? null
          : 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
      _thumbnailCache[url] = thumb;
      return thumb;
    }
    if (_isSpotifyUrl(url)) {
      final oembedUri = Uri.https('open.spotify.com', '/oembed', {'url': url});
      try {
        final res = await http
            .get(oembedUri)
            .timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);
          if (body is Map<String, dynamic>) {
            final thumbnailUrl = body['thumbnail_url'];
            if (thumbnailUrl is String && _isHttpImageUrl(thumbnailUrl)) {
              _thumbnailCache[url] = thumbnailUrl;
              return thumbnailUrl;
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
        errorBuilder: (context, error, stack) =>
            Icon(widget.fallbackIcon, color: context.colorScheme.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canResolve =
        _isYouTubeUrl(widget.link.url) || _isSpotifyUrl(widget.link.url);
    if (!canResolve) {
      return _fallbackTile(context);
    }
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
  ValueNotifier<double> childHeight = ValueNotifier(0.001);

  GlobalKey widgetKey = GlobalKey();
  GlobalKey handlerKey = GlobalKey();

  @override
  void didChangeDependencies() {
    measureWidgetSize(
      context,
      keys: [widgetKey, handlerKey],
      callback: (result) {
        childHeight.value = result;
      },
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
    return ValueListenableBuilder(
      valueListenable: childHeight,
      builder: (context, childHeight, child) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: childHeight,
        initialChildSize: childHeight,
        minChildSize: (childHeight - .2).clamp(0.001, 1),
        snap: true,
        builder: (context, scrollController) => Container(
          padding: context.mediaQuery.viewInsets,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
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
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () {
                              router.popAndPush(
                                WebpageRoute(url: 'https://tjc.org/id/sabat/'),
                              );
                            },
                            leading: Icon(Icons.church_outlined),
                            title: Text('Ibadah online'.tr()),
                          ),
                          ListTile(
                            onTap: () {
                              router.popAndPush(
                                WebpageRoute(
                                  url: 'https://tjc.org/id/audio-khotbah/',
                                ),
                              );
                            },
                            leading: Icon(Icons.headphones_outlined),
                            title: Text('Audio Khotbah'.tr()),
                          ),
                          ListTile(
                            onTap: () {
                              router.popAndPush(
                                WebpageRoute(
                                  url: 'https://tjc.org/id/video-khotbah/',
                                ),
                              );
                            },
                            leading: Icon(Icons.videocam_outlined),
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
  final Sauh item;
  const SauhBagiJiwa({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Section(
      label: 'Sauh Bagi Jiwa'.tr(),
      child: (gap) => InkWell(
        onTap: () {
          router.push(WebpageRoute(url: item.url));
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          margin: EdgeInsets.symmetric(horizontal: gap),
          decoration: BoxDecoration(
            borderRadius: context.appRadius(20),
            color: context.colorScheme.surfaceContainer,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _safeNetworkImage(
                item.imageUrl,
                height: 150,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        fontSize: context.appFontSize(14),
                        fontStyle: FontStyle.italic,
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

class SuaraSejati extends StatefulWidget {
  final List<TrueVoice> trueVoices;
  const SuaraSejati({super.key, required this.trueVoices});

  @override
  State<SuaraSejati> createState() => _SuaraSejatiState();
}

class _SuaraSejatiState extends State<SuaraSejati> {
  @override
  Widget build(BuildContext context) {
    if (widget.trueVoices.isEmpty) return SizedBox();
    return Section(
      label: 'Suara Sejati'.tr(),
      child: (gap) => SizedBox(
        height: 175,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: widget.trueVoices.length,
          itemBuilder: (context, index) {
            final item = widget.trueVoices[index];
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? gap : 4, right: 4),
              child: SizedBox(
                width: 160,
                child: InkWell(
                  onTap: () {
                    router.push(WebpageRoute(url: item.url));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainer,
                      borderRadius: context.appRadius(16),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 160,
                          height: 110,
                          child: _safeNetworkImage(
                            item.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                item.title,
                                maxLines: 1,
                                minFontSize: 8,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: context.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: context.appFontSize(12),
                                ),
                              ),
                              if (item.creator.trim().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.creator.trim(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                    fontSize: context.appFontSize(10),
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
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

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: context.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Menu',
            onPressed: openDashboardDrawer,
            icon: const Icon(Icons.menu_outlined),
          ),
          Expanded(
            child: Image.asset(
              isDark
                  ? Assets.assetsImagesLogoIndonesiaWhite
                  : Assets.assetsImagesLogoIndonesiaColor,
              height: 26,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeWelcomeSection extends StatelessWidget {
  const _HomeWelcomeSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final isLoggedIn = state.isLoggedIn;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLoggedIn ? 'Shalom,' : 'Shalom',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isLoggedIn) ...[
                const SizedBox(height: 2),
                Text(
                  state.account?.name?.trim().isNotEmpty == true
                      ? state.account!.name!
                      : 'Jemaat Terkasih',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, d MMMM yyyy', context.locale.languageCode)
                    .format(DateTime.now()),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
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
      builder: (context, state) {
        // Only show if verse is available
        if (!state.hasTodayVerse) {
          return const SizedBox.shrink();
        }

        final verse = state.todayVerse!;
        final colors = context.colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final homeCubit = context.read<HomeCubit>();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        colors.secondaryContainer.withValues(alpha: 0.5),
                        colors.tertiaryContainer.withValues(alpha: 0.3),
                      ]
                    : [
                        colors.secondaryContainer.withValues(alpha: 0.35),
                        colors.secondaryContainer.withValues(alpha: 0.15),
                      ],
              ),
              borderRadius: context.appRadius(20),
              boxShadow: [
                BoxShadow(
                  color: colors.secondary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(context.appSpace(18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      color: colors.onSecondaryContainer.withValues(alpha: 0.6),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'TODAY VERSE',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.onSecondaryContainer.withValues(alpha: 0.7),
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '"${verse.text}"',
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.onSecondaryContainer,
                    height: 1.55,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: isDark ? 0.25 : 0.15),
                        borderRadius: context.appRadius(8),
                      ),
                      child: Text(
                        verse.reference,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (verse.bibleCodeName != null) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _showBibleVersionPicker(context, homeCubit),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.tertiary.withValues(alpha: isDark ? 0.25 : 0.15),
                            borderRadius: context.appRadius(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                verse.bibleCodeName!,
                                style: context.textTheme.labelMedium?.copyWith(
                                  color: colors.tertiary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: colors.tertiary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

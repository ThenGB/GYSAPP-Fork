import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                onRefresh: () {
                  context.read<HomeCubit>().refresh();
                  return Future.value();
                },
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
                          const _HomeHeroPanel(),
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
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          color: context
                                              .colorScheme
                                              .surfaceContainerLowest,
                                          border: Border.all(
                                            color: context
                                                .colorScheme
                                                .outlineVariant,
                                          ),
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
                                    height: 132,
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
    if (link.url.startsWith('app://') && Platform.isAndroid) {
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
            final width = (constraints.maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: menuLinks
                  .take(4)
                  .map(
                    (link) => SizedBox(
                      width: width,
                      child: Material(
                        color: context.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _handleTap(context, link),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    color: context.colorScheme.surfaceContainer,
                                    child: _LinkThumbnail(
                                      link: link,
                                      fallbackIcon: icon,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                                              fontWeight: FontWeight.w600,
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
                            title: Text('⛪ ${'Ibadah online'.tr()}'),
                          ),
                          ListTile(
                            onTap: () {
                              router.popAndPush(
                                WebpageRoute(
                                  url: 'https://tjc.org/id/audio-khotbah/',
                                ),
                              );
                            },
                            title: Text('🎤 ${'Audio Khotbah'.tr()}'),
                          ),
                          ListTile(
                            onTap: () {
                              router.popAndPush(
                                WebpageRoute(
                                  url: 'https://tjc.org/id/video-khotbah/',
                                ),
                              );
                            },
                            title: Text('📹 ${'Video Khotbah'.tr()}'),
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
          // FlutterWebBrowser.openWebPage(url: item.url);
          router.push(WebpageRoute(url: item.url));
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          margin: EdgeInsets.symmetric(horizontal: gap),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: context.colorScheme.surfaceContainerLow,
            border: Border.all(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.65),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _safeNetworkImage(
                item.imageUrl,
                height: 130,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
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
  late PageController _pageController;
  int _currentPage = 0;
  double _scrollAccumulator = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.24, initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleScroll(PointerScrollEvent event) {
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    final isShiftPressed =
        keys.contains(LogicalKeyboardKey.shiftLeft) ||
        keys.contains(LogicalKeyboardKey.shiftRight);

    // Get deltas
    final dx = event.scrollDelta.dx;
    final dy = event.scrollDelta.dy;

    // We decide whether to handle this scroll horizontally or let it be vertical
    bool shouldHandleHorizontally = false;
    double delta = 0;

    if (isShiftPressed) {
      // If shift is held, we always want to scroll horizontally
      // We take the dominant delta (usually dy on Windows shift+scroll)
      shouldHandleHorizontally = true;
      delta = dx != 0 ? dx : dy;
    } else if (dx.abs() > dy.abs()) {
      // If not shift, only handle if it's already a horizontal scroll event (e.g. side-tilt wheel)
      shouldHandleHorizontally = true;
      delta = dx;
    }

    if (shouldHandleHorizontally && delta != 0) {
      _scrollAccumulator += delta;

      // Sensitivity threshold
      if (_scrollAccumulator.abs() > 20) {
        final direction = _scrollAccumulator > 0 ? 1 : -1;
        final targetPage = (_currentPage + direction).clamp(
          0,
          widget.trueVoices.length - 1,
        );

        if (targetPage != _currentPage) {
          _pageController.animateToPage(
            targetPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutQuart,
          );
          setState(() {
            _currentPage = targetPage;
          });
        }
        _scrollAccumulator = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trueVoices.isEmpty) return SizedBox();
    return Section(
      label: 'Suara Sejati'.tr(),
      child: (gap) => SizedBox(
        height: 280,
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              _handleScroll(event);
            }
          },
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            controller: _pageController,
            padEnds: false,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.trueVoices.length,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final item = widget.trueVoices[index];
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? gap : 3, right: 3),
                child: InkWell(
                  onTap: () {
                    router.push(WebpageRoute(url: item.url));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: context.colorScheme.outlineVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 110,
                            child: _safeNetworkImage(
                              item.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ARTIKEL',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: context.colorScheme.primary,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: context.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.creator.trim(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                  fontSize: 11,
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
            },
          ),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
            context.colorScheme.surfaceContainerLow.withValues(alpha: 0.92),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Menu',
            onPressed: openDashboardDrawer,
            icon: const Icon(Icons.widgets_rounded),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Liturgical Workspace',
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  'Hymnal • Bible • Beliefs',
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Search'.tr(),
            onPressed: () {
              router.push(
                BibleSearchRoute(
                  cubit: context.read<BibleCubit>(),
                  onTap: (item) {
                    context.read<BibleCubit>().saveToHistory(item);
                    context.read<BibleCubit>().getContent(item);
                    router.maybePop();
                    AutoTabsRouter.of(context).setActiveIndex(1);
                  },
                ),
              );
            },
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
    );
  }
}

class _HomeHeroPanel extends StatelessWidget {
  const _HomeHeroPanel();

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 640;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, compact ? 14 : 20, 16, 12),
          child: Container(
            padding: EdgeInsets.all(compact ? 18 : 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primaryContainer.withValues(alpha: 0.44),
                  colors.surfaceContainerHighest.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(compact ? 20 : 24),
              border: Border.all(color: colors.primary.withValues(alpha: 0.26)),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.14),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'One Desk For Worship Flow',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                    fontSize: compact ? 25 : 30,
                  ),
                ),
                SizedBox(height: compact ? 10 : 8),
                Text(
                  'Open hymns, scripture, and doctrine from one modern control room built for daily ministry rhythm.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: compact ? 15 : 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _QuickLaunchTile(
                      icon: Icons.music_note_rounded,
                      label: 'Open Hymnal',
                      tabIndex: 2,
                    ),
                    _QuickLaunchTile(
                      icon: Icons.menu_book_rounded,
                      label: 'Open Bible',
                      tabIndex: 1,
                    ),
                    _QuickLaunchTile(
                      icon: Icons.auto_stories_rounded,
                      label: 'Open Beliefs',
                      tabIndex: 3,
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
}

class _QuickLaunchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int tabIndex;

  const _QuickLaunchTile({
    required this.icon,
    required this.label,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 430;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => AutoTabsRouter.of(context).setActiveIndex(tabIndex),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: compact ? 160 : 176,
          maxWidth: compact ? 220 : 236,
        ),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.62),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: colors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
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
    );
  }
}

class _HomeWelcomeSection extends StatelessWidget {
  const _HomeWelcomeSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLow.withValues(
              alpha: 0.72,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shalom,',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
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
          ),
        ),
      ),
    );
  }
}

class _DailyVerseCard extends StatelessWidget {
  const _DailyVerseCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colorScheme.secondaryContainer.withValues(alpha: 0.34),
                context.colorScheme.surfaceContainerLow.withValues(alpha: 0.9),
              ],
            ),
            border: Border.all(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.64),
            ),
          ),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TODAY VERSE',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.primary,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '"Berbahagialah orang yang suci hatinya, karena mereka akan melihat Allah."',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Matius 5:8',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.onPrimaryContainer,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.ios_share_rounded,
                        size: 18,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ],
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

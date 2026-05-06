import 'dart:developer';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../domain/entity/banner/banner.dart';
import '../../../domain/entity/menulink/menulink_entity.dart';
import '../../../domain/entity/sauh/sauh_entity.dart';
import '../../../domain/entity/truevoice/truevoice_entity.dart';
import '../../../router/router.dart';
import '../../presentations.dart';

@RoutePage()
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) => Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                padding: EdgeInsets.only(top: context.mediaQuery.padding.top),
                color: context.colorScheme.surface,
                child: const HomeHeader()),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () {
                  context.read<HomeCubit>().refresh();
                  return Future.value();
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          final banners = (snapshot.data as List<ImageBanner>)
                              .where(
                                (element) => !element.isExpired,
                              )
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
                                          if (banner.linkUrl!
                                              .contains('http')) {
                                            launchUrl(
                                              Uri.parse(banner.linkUrl!),
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          } else {
                                            router.pushPath(banner.linkUrl!);
                                          }
                                        },
                                  child: Container(
                                    width: double.infinity,
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: Colors.transparent,
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: CachedNetworkImage(
                                            imageUrl: banner.imageUrl ?? '',
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                        if (banner.linkUrl != null)

                                          /// add link icon on topRight
                                          Positioned.fill(
                                            child: Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
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
                                height: 110,
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
                        SuaraSejati(
                          trueVoices: state.trueVoices,
                        ),
                      LinkLainnya(
                        menuLinks: state.menuLinks,
                      ),
                      SizedBox(height: 12)
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LinkLainnya extends StatelessWidget {
  final List<Menulink> menuLinks;
  const LinkLainnya({
    super.key,
    required this.menuLinks,
  });

  @override
  Widget build(BuildContext context) {
    return Section(
      label: 'Link lainnya'.tr(),
      child: (gap) => Container(
        padding: EdgeInsets.symmetric(horizontal: gap),
        child: LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: menuLinks
                .asMap()
                .entries
                .map(
                  (e) => Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        if (!e.value.enabled) {
                          context.showSnackBar('Fitur ini tidak tersedia');
                          return;
                        }

                        // FlutterWebBrowser.openWebPage(url: e.value.url);
                        if (e.value.url.startsWith('app://') &&
                            Platform.isAndroid) {
                          // var appId = e.value.url.replaceFirst('app://', '');
                          context.showSnackBar(
                            'Aplikasi tidak ditemukan',
                          );
                          // DeviceApps.isAppInstalled(appId).then((value) async {
                          //   if (value) {
                          //     DeviceApps.openApp(appId);
                          //   } else {
                          //     context.showSnackBar(
                          //       'Aplikasi tidak ditemukan',
                          //     );
                          //     if (await canLaunchUrl(Uri.parse(
                          //         'https://play.google.com/store/apps/details?id=$appId'))) {
                          //       /// open playstore
                          //       launchUrl(
                          //         Uri.parse(
                          //             'https://play.google.com/store/apps/details?id=$appId'),
                          //         mode: LaunchMode.externalApplication,
                          //       );
                          //     } else {
                          //       // ignore: use_build_context_synchronously
                          //       context.showSnackBar(
                          //         'Tidak dapat membuka link',
                          //       );
                          //     }
                          //   }
                          // });
                          return;
                        }
                        if (e.value.url.contains('http')) {
                          final res = await launchUrl(
                            Uri.parse(e.value.url),
                            mode: LaunchMode.externalApplication,
                          );
                          log(res.toString());
                          // router.push(WebpageRoute(url: e.value.url));
                        } else {
                          if (e.value.url == 'khotbah') {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              builder: (context) => IbadahPopup(),
                            );
                            return;
                          }
                          router.pushPath(e.value.url);
                        }
                        // await launchUrl(
                        //   Uri.parse(e.value.url),
                        //   webViewConfiguration: const WebViewConfiguration(
                        //     enableJavaScript: true,
                        //   ),
                        //   mode: LaunchMode.inAppWebView,
                        // );
                      },
                      child: SizedBox(
                        width: constraints.maxWidth / 4 - 8,
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            e.value.enabled
                                ? Colors.black.withValues(alpha: 1)
                                : Colors.black.withValues(alpha: .3),
                            BlendMode.dstIn,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image(
                                    width: 40,
                                    height: 40,
                                    image: e.value.iconImageProvider,
                                  ),
                                ),
                              ),
                              Text(
                                e.value.label,
                                textAlign: TextAlign.center,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class IbadahPopup extends StatefulWidget {
  const IbadahPopup({
    super.key,
  });

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
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
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
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () {
                              router.popAndPush(WebpageRoute(
                                  url: 'https://tjc.org/id/sabat/'));
                            },
                            title: Text('⛪ ${'Ibadah online'.tr()}'),
                          ),
                          ListTile(
                            onTap: () {
                              router.popAndPush(WebpageRoute(
                                  url: 'https://tjc.org/id/audio-khotbah/'));
                            },
                            title: Text('🎤 ${'Audio Khotbah'.tr()}'),
                          ),
                          ListTile(
                            onTap: () {
                              router.popAndPush(WebpageRoute(
                                  url: 'https://tjc.org/id/video-khotbah/'));
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
  const SauhBagiJiwa({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Section(
      label: 'Sauh Bagi Jiwa'.tr(),
      child: (gap) => InkWell(
        onTap: () {
          // FlutterWebBrowser.openWebPage(url: item.url);
          router.push(WebpageRoute(
            url: item.url,
          ));
        },
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            color: Colors.white,
          ),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
            ),
            margin: EdgeInsets.symmetric(horizontal: gap),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  height: 111,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                SizedBox(
                    height: 111,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SuaraSejati extends StatelessWidget {
  final List<TrueVoice> trueVoices;
  const SuaraSejati({
    super.key,
    required this.trueVoices,
  });

  @override
  Widget build(BuildContext context) {
    if (trueVoices.isEmpty) return SizedBox();
    return Section(
        label: 'Suara Sejati'.tr(),
        child: (gap) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: gap),
              child: Row(
                children: trueVoices
                    .map(
                      (e) => InkWell(
                        onTap: () {
                          // FlutterWebBrowser.openWebPage(url: e.url);
                          router.push(WebpageRoute(url: e.url));
                        },
                        child: Container(
                          width: 165 * context.mediaQuery.textScaler.scale(1),
                          margin: const EdgeInsets.only(right: 4),
                          height: 143 * context.mediaQuery.textScaler.scale(1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: context.theme.dividerColor,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  color: Colors.grey,
                                  height: 95 *
                                      context.mediaQuery.textScaler.scale(1),
                                  width: double.infinity,
                                  child: CachedNetworkImage(
                                    imageUrl: e.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8 *
                                        context.mediaQuery.textScaler.scale(1),
                                    vertical: 4 *
                                        context.mediaQuery.textScaler.scale(1)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: context.textColor
                                            ?.withValues(alpha: .87),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      e.description.trim(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: context.textColor
                                              ?.withValues(alpha: .65)),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ));
  }
}

class HomeHeader extends StatefulWidget {
  const HomeHeader({
    super.key,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  String get greetings {
    var now = DateTime.now();
    if (now.hour > 4 && now.hour < 11) {
      return 'Good morning'.tr();
    } else if (now.hour >= 11 && now.hour < 13) {
      return 'Good afternoon'.tr();
    } else if (now.hour >= 13 && now.hour < 18) {
      return 'Good evening'.tr();
    } else {
      return 'Good night'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) => Container(
        color: context.colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              child: Center(
                child: state.account == null
                    ? Image.asset(Assets.assetsImagesAppicon, width: 32)
                    : ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: state.account?.profilePicture ?? '',
                        ),
                      ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (context.watch<DashboardCubit>().state.idToken == null)
                        ? 'Haleluya, $greetings'
                        : '$greetings, ${context.watch<DashboardCubit>().state.account?.name ?? ''}!',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (context.watch<DashboardCubit>().state.idToken ==
                      null) ...[
                    Text.rich(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                        ),
                        buildRichTextWithClickableWord(
                          'register_button_text'.tr(),
                          'register_word'.tr(),
                          context.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                          ),
                          () {
                            router.push(LoginRoute(
                              onLoggedIn: (token) {
                                router.maybePop();
                                context
                                    .read<DashboardCubit>()
                                    .loginSuccessCallback(token);
                                Fluttertoast.cancel();
                                Fluttertoast.showToast(msg: 'BERHASIL LOGIN!');
                              },
                            ));
                          },
                        )),
                  ] else
                    FutureBuilder(
                      future: FirebaseUtils.boolConfig('enable_memberarea'),
                      builder: (context, snapshot) => Visibility(
                        visible: snapshot.data == true,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            textStyle: TextStyle(
                              fontSize: 10,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.all(12),
                            backgroundColor: context.colorScheme.primary,
                            foregroundColor: context.colorScheme.onPrimary,
                          ),
                          onPressed: () {
                            var url =
                                'https://e.gys.or.id/u/home?token=${context.read<DashboardCubit>().state.idToken}';
                            router.push(WebpageRoute(
                                url: url,
                                getNavColor: (controller) async {
                                  var color = await controller.evaluateJavascript(
                                      source:
                                          "window.getComputedStyle( document.getElementsByClassName('navbar')[0] ,null).getPropertyValue('background-color');");
                                  if (color.toString().contains('rgb')) {
                                    var temp = color.toString();
                                    temp = temp.substring(temp.indexOf('(') + 1,
                                        temp.indexOf(')'));
                                    var rgb = temp
                                        .split(',')
                                        .map((e) => int.parse(e))
                                        .toList();
                                    var navColor = Color.fromRGBO(
                                        rgb[0], rgb[1], rgb[2], 1);
                                    return navColor;
                                  }
                                  return null;
                                }));
                          },
                          child: Text('Member Area'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            if (1 + 1 == 3)
              Material(
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {},
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Image.asset(Assets.assetsIconsBell, width: 15),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  TextSpan buildRichTextWithClickableWord(String fullText, String clickableWord,
      TextStyle? style, Function() onTap) {
    final span = TextSpan(
      children: [
        TextSpan(
          text: fullText.substring(0, fullText.indexOf(clickableWord)),
        ),
        TextSpan(
          text: clickableWord,
          style: style?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
          recognizer: TapGestureRecognizer()..onTap = onTap,
        ),
        TextSpan(
          text: fullText.substring(
              fullText.indexOf(clickableWord) + clickableWord.length),
        ),
      ],
    );

    return span;
  }
}

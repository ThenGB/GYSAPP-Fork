import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:church/components/widgets/section.dart';
import 'package:church/data/utilities/extensions/context_ext.dart';
import 'package:church/data/utilities/variables/assets.dart';
import 'package:church/domain/entity/menulink/menulink_entity.dart';
import 'package:church/domain/entity/sauh/sauh_entity.dart';
import 'package:church/presentations/home/bloc/home_cubit.dart';
import 'package:church/router/router.dart';
import 'package:device_apps/device_apps.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/entity/banner/banner.dart';
import '../../../domain/entity/truevoice/truevoice_entity.dart';

@RoutePage()
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) => Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HomeHeader(),
              Expanded(
                child: SingleChildScrollView(
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
                          final banners = snapshot.data as List<ImageBanner>;
                          if (banners.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Section(
                            child: (gap) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: gap),
                              child: CarouselSlider.builder(
                                itemCount: banners.length,
                                itemBuilder: (context, index, realIndex) {
                                  var banner = banners[index];
                                  return Container(
                                    width: double.infinity,
                                    color: Colors.transparent,
                                    child: CachedNetworkImage(
                                      imageUrl: banner.imageUrl ?? '',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  );
                                },
                                options: CarouselOptions(
                                  height: 110,
                                  enlargeFactor: 1,
                                  enlargeStrategy:
                                      CenterPageEnlargeStrategy.scale,
                                  viewportFraction: 1,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      if (state.sauhs.isNotEmpty)
                        SauhBagiJiwa(item: state.sauhs.first),
                      SuaraSejati(
                        trueVoices: state.trueVoices,
                      ),
                      LinkLainnya(
                        menuLinks: state.menuLinks,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
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
      label: 'Link lainnya',
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
                          var appId = e.value.url.replaceFirst('app://', '');
                          DeviceApps.isAppInstalled(appId).then((value) async {
                            if (value) {
                              DeviceApps.openApp(appId);
                            } else {
                              context.showSnackBar(
                                'Aplikasi tidak ditemukan',
                              );
                              if (await canLaunchUrl(Uri.parse(
                                  'https://play.google.com/store/apps/details?id=$appId'))) {
                                /// open playstore
                                launchUrl(
                                  Uri.parse(
                                      'https://play.google.com/store/apps/details?id=$appId'),
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                // ignore: use_build_context_synchronously
                                context.showSnackBar(
                                  'Tidak dapat membuka link',
                                );
                              }
                            }
                          });
                          return;
                        }
                        if (e.value.url.contains('http')) {
                          launchUrl(
                            Uri.parse(e.value.url),
                            mode: LaunchMode.externalNonBrowserApplication,
                          );
                          // router.push(WebpageRoute(url: e.value.url));
                        } else {
                          if (e.value.url == 'khotbah') {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              builder: (context) => DraggableScrollableSheet(
                                expand: false,
                                maxChildSize: .3,
                                initialChildSize: .3,
                                minChildSize: .2,
                                builder: (context, scrollController) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    color: context.colorScheme.background,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(32),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.all(16),
                                        height: 4,
                                        width: 64,
                                        decoration: BoxDecoration(
                                          color: context.theme.disabledColor,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView(
                                          shrinkWrap: true,
                                          controller: scrollController,
                                          children: [
                                            ListTile(
                                              onTap: () {
                                                router.popAndPush(WebpageRoute(
                                                    url:
                                                        'https://tjc.org/id/sabat/'));
                                              },
                                              title: Text('Ibadah online'.tr()),
                                            ),
                                            ListTile(
                                              onTap: () {
                                                router.popAndPush(WebpageRoute(
                                                    url:
                                                        'https://tjc.org/id/audio-khotbah/'));
                                              },
                                              title: Text('Audio Khotbah'.tr()),
                                            ),
                                            ListTile(
                                              onTap: () {
                                                router.popAndPush(WebpageRoute(
                                                    url:
                                                        'https://tjc.org/id/video-khotbah/'));
                                              },
                                              title: Text('Video Khotbah'.tr()),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                            return;
                          }
                          router.pushNamed(e.value.url);
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
                                ? Colors.black.withOpacity(1)
                                : Colors.black.withOpacity(.3),
                            BlendMode.dstIn,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image(
                                  width: 40,
                                  height: 40,
                                  image: e.value.iconImageProvider,
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                              ),
                              Text(e.value.label),
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

class SauhBagiJiwa extends StatelessWidget {
  final Sauh item;
  const SauhBagiJiwa({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Section(
      label: 'Sauh Bagi Jiwa',
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
            padding: EdgeInsets.symmetric(horizontal: gap),
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
    return Section(
        label: 'Suara Sejati',
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
                          width: 165,
                          margin: const EdgeInsets.only(right: 4),
                          height: 143,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: context.theme.dividerColor,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                child: Container(
                                  color: Colors.grey,
                                  height: 95,
                                  width: double.infinity,
                                  child: CachedNetworkImage(
                                    imageUrl: e.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      e.description.trim(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                      ),
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
    return Container(
      color: context.colorScheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            child: Center(
              child: Image.asset(Assets.assetsImagesAppicon, width: 32),
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
                  'Haleluya, $greetings',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text.rich(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                  ),
                  registerButton(),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 8,
          ),
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
    );
  }

  TextSpan registerButton() {
    return TextSpan(
      children: [
        const TextSpan(text: 'Yuk '),
        TextSpan(
          text: 'daftar',
          style: context.primaryTextTheme.bodySmall?.copyWith(
            fontSize: 12,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              router.push(const LoginRoute());
            },
        ),
        const TextSpan(text: ' untuk menikmati lebih banyak fitur'),
      ],
    );
  }
}

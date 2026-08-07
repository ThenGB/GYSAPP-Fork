import 'dart:developer';
import '../../../components/components.dart';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/variables/assets.dart';
import '../../../router/router.dart';

@RoutePage()
class LiteratureView extends StatefulWidget {
  const LiteratureView({super.key});

  @override
  State<LiteratureView> createState() => _LiteratureViewState();
}

class _LiteratureViewState extends State<LiteratureView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log(router.currentPath);
    return Scaffold(
      backgroundColor: context.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: context.colorScheme.surfaceContainerLowest,
        shape: Border(
          bottom: BorderSide(color: context.colorScheme.outlineVariant),
        ),
        title: const Text('Kidung Rohani'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              children: [
                Text(
                  'Literature'.tr(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colorScheme.outlineVariant,
                    borderRadius: context.appRadius(999),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Kumpulan bacaan rohani dan literatur gereja.',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          ..._buildGridItems(context),
        ],
      ),
    );
  }

  List<Widget> _buildGridItems(BuildContext context) {
    final items = <(String, String, PageRouteInfo)>[
      (
        'Kesaksian',
        Assets.assetsImagesKesaksian,
        const LiteratureKesaksianRoute(),
      ),
      (
        'Manna Magazine'.tr(),
        Assets.assetsImagesWartasejati,
        const LiteratureWartaRoute(),
      ),
      (
        'Panduan Pemahaman Alkitab',
        Assets.assetsImagesPanduankitab,
        const LiteraturePanduanKitabRoute(),
      ),
      (
        'Kumpulan Renungan'.tr(),
        Assets.assetsImagesKumpulanrenungan,
        const LiteratureRenunganRoute(),
      ),
      (
        'Pujian',
        Assets.assetsImagesPujian,
        LiteraturePujianRoute(url: 'https://tjc.org/id/pujian/pujian-padus'),
      ),
      (
        'Buku',
        Assets.assetsImagesBuku,
        LiteratureBukuRoute(url: 'https://tjc.org/id/literatur/buku'),
      ),
    ];

    return items
        .map(
          (e) => Container(
            height: 108,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: context.appRadius(18),
              border: Border.all(
                color: context.colorScheme.outlineVariant.withValues(
                  alpha: 0.55,
                ),
              ),
              color: context.colorScheme.surfaceContainerLowest,
            ),
            child: Material(
              color: Colors.transparent,
              child: Ink.image(
                image: AssetImage(e.$2),
                fit: BoxFit.cover,
                child: InkWell(
                  onTap: () {
                    router.push(e.$3);
                  },
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0x8A000000), Color(0x22000000)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Text(
                      e.$1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: context.appFontSize(17),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }
}

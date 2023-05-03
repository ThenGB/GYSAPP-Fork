import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:church/data/utilities/variables/assets.dart';
import 'package:church/router/router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: Text('Literature'.tr()),
      ),
      body: ListView(
        children: [
          [
            'Kesaksian',
            Assets.assetsImagesKesaksian,
            const LiteratureKesaksianRoute()
          ],
          [
            'Manna Magazine'.tr(),
            Assets.assetsImagesWartasejati,
            const LiteratureWartaRoute(),
          ],
          [
            'Panduan Pemahaman Alkitab',
            Assets.assetsImagesPanduankitab,
            const LiteraturePanduanKitabRoute(),
          ],
          [
            'Kumpulan Renungan',
            Assets.assetsImagesKumpulanrenungan,
            const LiteratureRenunganRoute(),
          ],
          [
            'Pujian',
            Assets.assetsImagesPujian,
            WebpageRoute(url: 'https://tjc.org/id/pujian/pujian-padus')
          ],
          [
            'Buku',
            Assets.assetsImagesBuku,
            WebpageRoute(url: 'https://tjc.org/id/literatur/buku')
          ],
        ]
            .map((e) => Container(
                  height: 100,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(e[1] as String),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      router.push(e[2] as PageRouteInfo);
                    },
                    child: Container(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        e[0] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 8,
                                color: Colors.black,
                              ),
                              Shadow(
                                offset: Offset(0, 0),
                                blurRadius: 4,
                                color: Colors.black,
                              ),
                              Shadow(
                                offset: Offset(0, 0),
                                blurRadius: 2,
                                color: Colors.black,
                              ),
                            ]),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

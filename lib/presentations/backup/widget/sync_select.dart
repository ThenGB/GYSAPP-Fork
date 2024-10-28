import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../data/data.dart';
import '../../../router/router.dart';

class SyncSelectDialog extends StatefulWidget {
  final Function() fromLocal;
  final Function() fromNetwork;
  const SyncSelectDialog(
      {super.key, required this.fromLocal, required this.fromNetwork});

  @override
  State<SyncSelectDialog> createState() => _SyncSelectDialogState();
}

class _SyncSelectDialogState extends State<SyncSelectDialog> {
  GlobalKey widgetKey = GlobalKey();
  GlobalKey appbarKey = GlobalKey();
  late ValueNotifier<double> childHeight = ValueNotifier(0.0001);
  late DraggableScrollableController controller =
      DraggableScrollableController();
  @override
  void initState() {
    measure('initState');
    super.initState();
  }

  measure([String? logt]) {
    if (logt != null) {
      log(logt);
    }
    measureWidgetSize(
      context,
      keys: [widgetKey],
      callback: (result) {
        childHeight.value = result;
        Future.delayed(
          kThemeAnimationDuration,
          () {
            controller.animateTo(childHeight.value,
                duration: kThemeAnimationDuration, curve: Curves.ease);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    childHeight.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (mounted) {
      measure('didChangeDependencies');
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: childHeight,
      builder: (context, childHeight, child) => DraggableScrollableSheet(
        initialChildSize: childHeight,
        maxChildSize: childHeight,
        minChildSize: (childHeight - .05).clamp(0.0001, 1),
        controller: controller,
        expand: false,
        snap: true,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Container(
              key: widgetKey,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: context.colorScheme.background),
              margin: context.mediaQuery.viewInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Choose where you want to sync'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  ListTile(
                    leading: Icon(Icons.insert_drive_file_rounded),
                    title: Text('From local'.tr()),
                    onTap: () {
                      router.maybePop();
                      widget.fromLocal();
                    },
                  ),
                  ListTile(
                    onTap: () {
                      router.maybePop();
                      widget.fromNetwork();
                    },
                    leading: Icon(Icons.filter_drama_rounded),
                    title: Text('From my account'.tr()),
                  ),
                  SizedBox(
                    height: context.mediaQuery.viewPadding.bottom,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

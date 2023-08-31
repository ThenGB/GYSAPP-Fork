import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../data/data.dart';
import '../../../data/utilities/functions/measurewidgetsize.dart';
import '../../../router/router.dart';

class SyncConfirmDialog extends StatefulWidget {
  final Function() onConfirmed;
  const SyncConfirmDialog({super.key, required this.onConfirmed});

  @override
  State<SyncConfirmDialog> createState() => _SyncConfirmDialogState();
}

class _SyncConfirmDialogState extends State<SyncConfirmDialog> {
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
                    'Are you sure want to sync now?'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    'Your current data at local will be overriden'.tr(),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 48,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      fixedSize: Size.fromHeight(56),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      router.pop();
                      widget.onConfirmed();
                    },
                    child: Text(
                      'Sync now'.tr(),
                    ),
                  ),
                  SizedBox(
                    height: 16,
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

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../components/widgets/drag_handler.dart';
import '../../../components/widgets/section.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../settings/view/settings_view.dart';
import '../cubit/bible_cubit.dart';

class BibleSelectWidget extends StatefulWidget {
  const BibleSelectWidget(
      {super.key, required this.bibleCodes, required this.onTap});
  final List<String> bibleCodes;
  final Function(int index) onTap;

  @override
  State<BibleSelectWidget> createState() => _BibleSelectWidgetState();
}

class _BibleSelectWidgetState extends State<BibleSelectWidget> {
  late final DraggableScrollableController controller =
      DraggableScrollableController();
  final GlobalKey handlerKey = GlobalKey();
  final GlobalKey bodyKey = GlobalKey();
  double childHeight = 0.00001;
  @override
  void initState() {
    measureWidgetSize(
      context: context,
      widgetKeys: [handlerKey, bodyKey],
      setState: (height) {
        childHeight = height;
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: childHeight.clamp(0.00001, 1),
      maxChildSize: childHeight.clamp(0.00001, 1),
      minChildSize: (childHeight - .1).clamp(0.00001, 1),
      expand: false,
      snap: true,
      snapSizes: [childHeight],
      builder: (context, scrollController) {
        return Material(
          color: context.colorScheme.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DragHandler(
                  key: handlerKey,
                ),
                Section(
                    key: bodyKey,
                    label: 'Select Bible Version'.tr(),
                    child: (gap) => SingleChildScrollView(
                          child: SafeArea(
                            child: Column(
                              children: [
                                ...List.generate(
                                  widget.bibleCodes.length,
                                  (index) => ListTile(
                                    onTap: () {
                                      widget.onTap(index);
                                    },
                                    title: Text(
                                      '${widget.bibleCodes[index].split('_').last.toUpperCase()} - ${getBibleCodeName(widget.bibleCodes[index].split('_').last.toUpperCase())}',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:church/components/widgets/drag_handler.dart';
import 'package:church/data/utilities/extensions/context_ext.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: 0.5,
      expand: false,
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
                const DragHandler(),
                const Text(
                  'Select bible version',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...List.generate(
                    widget.bibleCodes.length,
                    (index) => ListTile(
                          onTap: () {
                            widget.onTap(index);
                          },
                          title: Text(widget.bibleCodes[index]),
                        )),
              ],
            ),
          ),
        );
      },
    );
  }
}

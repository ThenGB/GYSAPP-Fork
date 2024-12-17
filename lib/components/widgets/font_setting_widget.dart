import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/utilities/extensions/context_ext.dart';
import '../../data/utilities/functions/measurewidgetsize.dart';
import '../../data/utilities/variables/assets.dart';

openDefaultBottomSheet(BuildContext context,
    {required Widget Function(BuildContext context) builder}) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.transparent,
    builder: builder,
  );
}

class FontSettingWidget extends StatefulWidget {
  const FontSettingWidget({
    super.key,
    required this.availableFonts,
    required this.onFontSelected,
    required this.selectedFont,
    required this.textHeight,
    required this.textScale,
    required this.onTextScaleChanged,
    required this.onTextHeightChanged,
    required this.getTextStyle,
  });
  final List<String> availableFonts;
  final String selectedFont;
  final double textHeight;
  final double textScale;
  final TextStyle Function(String font) getTextStyle;
  final Function(String font) onFontSelected;
  final Function(double value) onTextScaleChanged;
  final Function(double value) onTextHeightChanged;

  @override
  State<FontSettingWidget> createState() => _FontSettingWidgetState();
}

class _FontSettingWidgetState extends State<FontSettingWidget> {
  late final GlobalKey appbarKey = GlobalKey();
  late final GlobalKey widgetKey = GlobalKey();
  late final GlobalKey handlerKey = GlobalKey();
  late double childHeight = 0.0000001;
  @override
  void initState() {
    measure();
    super.initState();
  }

  measure() {
    measureWidgetSize(
      context,
      keys: [widgetKey],
      callback: (h) {
        childHeight = h;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          setState(() {});
        });
      },
    );
  }

  bool isSelectingFont = false;

  Timer? timerSlider1;
  Timer? timerSlider2;
  debouncer1(Function() callback) async {
    if (timerSlider1?.isActive == true) {
      timerSlider1!.cancel();
    }
    timerSlider1 = Timer(Duration(milliseconds: 300), callback);
  }

  debouncer2(Function() callback) async {
    if (timerSlider2?.isActive == true) {
      timerSlider2!.cancel();
    }
    timerSlider2 = Timer(Duration(milliseconds: 300), callback);
  }

  Duration delayDuration = Duration(milliseconds: 300);
  DateTime? lastCallTime;

  void rateLimitedFunction(Function() callback) {
    DateTime now = DateTime.now();
    if (lastCallTime != null && now.difference(lastCallTime!) < delayDuration) {
      // Delay execution of function
      Timer(
        delayDuration,
        () => rateLimitedFunction(callback),
      );
      return;
    }

    // Your function logic goes here
    callback();

    // Update last call time
    lastCallTime = now;
  }

  @override
  void dispose() {
    timerSlider1?.cancel();
    timerSlider2?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: childHeight.clamp(.1, .9),
      maxChildSize: childHeight.clamp(.1, .9),
      minChildSize: (childHeight * .8).clamp(.1, .9),
      expand: false,
      builder: (context, scrollController) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(blurRadius: 160, color: Colors.black.withOpacity(.2)),
            ],
            color: context.colorScheme.surface,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              controller: scrollController,
              child: Container(
                key: widgetKey,
                child: Padding(
                  padding: context.mediaQuery.viewPadding,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 24,
                      ),
                      if (isSelectingFont) ...[
                        ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding: EdgeInsets.zero,
                          leading: BackButton(
                            onPressed: () {
                              setState(() {
                                isSelectingFont = false;
                              });
                              measure();
                            },
                          ),
                        ),
                        Divider(),
                        ...widget.availableFonts.map(
                          (e) => ListTile(
                            title: Text(
                              e,
                              style: widget
                                  .getTextStyle(e)
                                  .apply(
                                    color: e == widget.selectedFont
                                        ? context.colorScheme.primary
                                        : context.theme.disabledColor,
                                  )
                                  .copyWith(
                                    fontWeight: e == widget.selectedFont
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                            ),
                            onTap: () {
                              widget.onFontSelected(e);
                              setState(() {
                                isSelectingFont = false;
                              });
                              measure();
                            },
                          ),
                        )
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                      context.colorScheme.primary,
                                      BlendMode.srcIn,
                                    ),
                                    child: Image.asset(
                                      Assets.assetsIconsFontSizeMin,
                                      width: 24,
                                    ),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: convertToPercentage(
                                          widget.textScale, 0.8, 2),
                                      onChanged: (value) {
                                        widget.onTextScaleChanged(
                                            convertToValue(value, .8, 2));
                                      },
                                    ),
                                  ),
                                  ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                      context.colorScheme.primary,
                                      BlendMode.srcIn,
                                    ),
                                    child: Image.asset(
                                      Assets.assetsIconsFontSizePlus,
                                      width: 24,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                      context.colorScheme.primary,
                                      BlendMode.srcIn,
                                    ),
                                    child: Image.asset(
                                      Assets.assetsIconsFontGapMin,
                                      width: 24,
                                    ),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: convertToPercentage(
                                          widget.textHeight, 1, 2.5),
                                      onChanged: (value) {
                                        widget.onTextHeightChanged(
                                            convertToValue(value, 1, 2.5));
                                      },
                                    ),
                                  ),
                                  ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                      context.colorScheme.primary,
                                      BlendMode.srcIn,
                                    ),
                                    child: Image.asset(
                                      Assets.assetsIconsFontGapPlus,
                                      width: 24,
                                    ),
                                  ),
                                ],
                              ),
                              ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  side: BorderSide(
                                      width: 1,
                                      color: context.theme.disabledColor),
                                ),
                                titleTextStyle:
                                    context.textTheme.bodyMedium?.copyWith(
                                  fontSize: 10,
                                ),
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                contentPadding: EdgeInsets.only(left: 16),
                                title: Text(
                                  'Font',
                                  style: context.textTheme.bodySmall,
                                ),
                                subtitle: Text(
                                  widget.selectedFont,
                                  style: context.textTheme.bodyMedium,
                                ),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: context.theme.disabledColor,
                                ),
                                onTap: () {
                                  setState(() {
                                    isSelectingFont = true;
                                  });
                                  measure();
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                      SizedBox(
                        height: 16 + context.mediaQuery.viewPadding.vertical,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

double convertToPercentage(double value, double minValue, double maxValue) =>
    ((value - minValue) / (maxValue - minValue)).clamp(0, 1);
double convertToValue(double percentage, double minValue, double maxValue) =>
    ((percentage * (maxValue - minValue)) + minValue);

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../router/router.dart';
import '../../presentations.dart';

@RoutePage()
class FontSettingView extends StatefulWidget {
  const FontSettingView({super.key});

  @override
  State<FontSettingView> createState() => _FontSettingViewState();
}

class _FontSettingViewState extends State<FontSettingView> {
  late double defaultTextScale =
      context.read<InitialCubit>().state.defaultTextScale;
  late String defaultFontStyle = context.read<InitialCubit>().state.defaultFont;
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: context.mediaQuery.copyWith(textScaleFactor: 1),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Font Settings'.tr(),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: context.theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.primary,
                foregroundColor: context.colorScheme.onPrimary,
              ),
              onPressed: () async {
                await context
                    .showConfirmation(
                        'Are you sure want to change this preference?'.tr())
                    .then((value) {
                  if (value) {
                    context
                        .read<InitialCubit>()
                        .changeTextScale(defaultTextScale);
                    context
                        .read<InitialCubit>()
                        .changeFontStyle(defaultFontStyle);
                    Fluttertoast.cancel();
                    Fluttertoast.showToast(msg: 'Settings saved'.tr());
                    router.maybePop();
                  }
                });
              },
              child: Text('Apply'.tr())),
        ),
        body: BlocBuilder<InitialCubit, InitialState>(
          builder: (context, state) => SingleChildScrollView(
            child: Column(
              children: [
                Section(
                  label: 'Preview'.tr(),
                  child: (gap) => Padding(
                    padding: EdgeInsets.all(gap),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 160,
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              child: Text(
                                'font_size_placeholder'.tr(),
                                textScaleFactor: defaultTextScale,
                                style: TextStyle(
                                  fontFamily: defaultFontStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: ButtonTheme(
                                alignedDropdown: true,
                                padding: EdgeInsets.zero,
                                child: DropdownButtonFormField(
                                  value: defaultFontStyle,
                                  padding: EdgeInsets.zero,
                                  decoration: InputDecoration(
                                    filled: true,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  items:
                                      ['Roboto', 'Lato', 'Quicksand', 'Inter']
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(
                                                e,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: e,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    defaultFontStyle = value!;
                                    setState(() {});
                                  },
                                  isExpanded: true,
                                  alignment: Alignment.centerLeft,
                                  iconSize: 12,
                                  selectedItemBuilder: (context) => [
                                    ...['Roboto', 'Lato', 'Quicksand', 'Inter']
                                        .map(
                                      (e) => Text(
                                        e,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          fontFamily: e,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Slider(
                                value: convertToPercentage(
                                    defaultTextScale, .7, 1.7),
                                onChanged: (value) {
                                  defaultTextScale =
                                      convertToValue(value, .7, 1.7);
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
  late double defaultTextScale = context
      .read<InitialCubit>()
      .state
      .defaultTextScale;
  late double defaultTextHeight = context
      .read<InitialCubit>()
      .state
      .defaultTextHeight;
  late String defaultFontStyle = context.read<InitialCubit>().state.defaultFont;

  static const _availableFonts = [
    'Roboto',
    'Roboto Serif',
    'Open Sans',
    'Gentium Basic',
    'Arial',
    'EB Garamond',
    'Lato',
    'Quicksand',
    'Inter',
  ];

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: context.mediaQuery.copyWith(textScaler: TextScaler.linear(1)),
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        appBar: AppBar(
          shape: Border(
            bottom: BorderSide(color: context.colorScheme.outlineVariant),
          ),
          title: const Text('Pengaturan Font'),
          centerTitle: true,
        ),
        bottomNavigationBar: BottomAppBar(
          color: context.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () async {
              final value = await context.showConfirmation(
                'Are you sure want to change this preference?'.tr(),
              );
              if (!context.mounted || !value) {
                return;
              }
              context.read<InitialCubit>().changeTextScale(defaultTextScale);
              context.read<InitialCubit>().changeTextHeight(defaultTextHeight);
              context.read<InitialCubit>().changeFontStyle(defaultFontStyle);
              Fluttertoast.cancel();
              Fluttertoast.showToast(msg: 'Settings saved'.tr());
              router.maybePop();
            },
            child: Text('Apply'.tr()),
          ),
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
                                textScaler: TextScaler.linear(defaultTextScale),
                                style: TextStyle(
                                  fontFamily: defaultFontStyle,
                                  height: defaultTextHeight,
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
                                  initialValue: defaultFontStyle,
                                  padding: EdgeInsets.zero,
                                  decoration: InputDecoration(
                                    filled: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color:
                                            context.colorScheme.outlineVariant,
                                      ),
                                    ),
                                  ),
                                  items: _availableFonts
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
                                  selectedItemBuilder: (context) =>
                                      _availableFonts
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
                                          )
                                          .toList(),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.text_fields,
                                        size: 16,
                                        color: context.colorScheme.primary,
                                      ),
                                      Expanded(
                                        child: Slider(
                                          value: convertToPercentage(
                                            defaultTextScale,
                                            .7,
                                            1.7,
                                          ),
                                          onChanged: (value) {
                                            defaultTextScale = convertToValue(
                                              value,
                                              .7,
                                              1.7,
                                            );
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.format_line_spacing,
                                        size: 16,
                                        color: context.colorScheme.primary,
                                      ),
                                      Expanded(
                                        child: Slider(
                                          value: convertToPercentage(
                                            defaultTextHeight,
                                            1.0,
                                            2.5,
                                          ),
                                          onChanged: (value) {
                                            defaultTextHeight = convertToValue(
                                              value,
                                              1.0,
                                              2.5,
                                            );
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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

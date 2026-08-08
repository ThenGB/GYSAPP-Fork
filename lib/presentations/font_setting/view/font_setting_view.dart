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

  // Single source of truth lives in DesignSystem.appFontOptions so the
  // font pickers match everywhere (Bible, Faith, Song, global settings).
  final _availableFonts = DesignSystem.appFontOptions;

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
          title: Text('font_setting_title'.tr()),
          centerTitle: true,
        ),
        bottomNavigationBar: BottomAppBar(
          color: context.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: context.appRadius(18),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Live preview card.
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainerLow,
                        borderRadius: context.appRadius(16),
                        border: Border.all(
                          color: context.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preview'.tr(),
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: context
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 150,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: context.appRadius(12),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                'font_size_placeholder'.tr(),
                                textScaler: TextScaler.linear(
                                  defaultTextScale,
                                ),
                                style: TextStyle(
                                  fontFamily: defaultFontStyle,
                                  height: defaultTextHeight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Font family picker.
                    DropdownButtonFormField<String>(
                      initialValue: defaultFontStyle,
                      decoration: InputDecoration(
                        labelText: 'font_setting_font'.tr(),
                        filled: true,
                        fillColor: context.colorScheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: context.appRadius(16),
                          borderSide: BorderSide(
                            color: context.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      items: _availableFonts
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, style: TextStyle(fontFamily: e)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        defaultFontStyle = value;
                        setState(() {});
                      },
                      isExpanded: true,
                    ),
                    const SizedBox(height: 16),
                    // Text scale slider.
                    _FontSlider(
                      label: 'font_setting_text_size'.tr(),
                      icon: Icons.text_fields_rounded,
                      value: convertToPercentage(defaultTextScale, 0.7, 1.7),
                      displayValue: '${(defaultTextScale * 100).round()}%',
                      onChanged: (fraction) {
                        defaultTextScale = convertToValue(fraction, 0.7, 1.7);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    // Line height slider.
                    _FontSlider(
                      label: 'font_setting_line_spacing'.tr(),
                      icon: Icons.format_line_spacing_rounded,
                      value: convertToPercentage(defaultTextHeight, 1.0, 2.5),
                      displayValue: defaultTextHeight.toStringAsFixed(1),
                      onChanged: (fraction) {
                        defaultTextHeight = convertToValue(
                          fraction,
                          1.0,
                          2.5,
                        );
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A labeled slider row used by the font-settings page.
class _FontSlider extends StatelessWidget {
  const _FontSlider({
    required this.label,
    required this.icon,
    required this.value,
    required this.displayValue,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final double value;
  final String displayValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: context.appRadius(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                displayValue,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Slider(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

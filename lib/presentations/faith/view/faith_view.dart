import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../data/services/faith_pdf_service.dart';
import '../../../domain/domain.dart';
import '../../../router/router.dart';
import '../../presentations.dart';
import 'faith_pdf_viewer.dart';

const double _faithMaxContentWidth = 920;

@RoutePage()
class FaithView extends StatefulWidget {
  const FaithView({super.key});

  @override
  State<FaithView> createState() => _FaithViewState();
}

class _FaithViewState extends State<FaithView> {
  final FaithPdfService _pdfService = FaithPdfService();
  List<dynamic> _data = const [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFaithData();
  }

  Future<void> _loadFaithData() async {
    try {
      final source = await rootBundle.loadString(Assets.assetsDataFaith);
      final decoded = jsonDecode(source);
      final faith = decoded is Map<String, dynamic> ? decoded['faith'] : null;
      if (!mounted) return;
      setState(() {
        _data = faith is List ? faith : const [];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _pdfService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _contentFor(String languageCode) {
    final target = languageCode.toUpperCase();
    for (final item in _data) {
      if (item is Map && item['language']?.toString().toUpperCase() == target) {
        final content = item['content'];
        return content is List ? content : const [];
      }
    }
    return const [];
  }

  String _titleFor(String languageCode) {
    final target = languageCode.toUpperCase();
    for (final item in _data) {
      if (item is Map && item['language']?.toString().toUpperCase() == target) {
        final title = item['title']?.toString().trim() ?? '';
        if (title.isNotEmpty) return title;
      }
    }
    return _introTitle(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaithCubit, FaithState>(
      builder: (context, state) {
        final colors = context.colorScheme;
        final content = _contentFor(state.language);
        final title = _titleFor(state.language);

        return ColoredBox(
          color: colors.surface,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  _FaithHeader(state: state),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: _loadFaithData,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                16,
                                18,
                                16,
                                104 + MediaQuery.viewPaddingOf(context).bottom,
                              ),
                              children: [
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: _faithMaxContentWidth,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        if (content.isNotEmpty) ...[
                                          const SizedBox(height: 10),
                                          _FaithSearchField(
                                            controller: _searchController,
                                          ),
                                        ],
                                        const SizedBox(height: 14),
                                        AnimatedBuilder(
                                          animation: _searchController,
                                          builder: (context, _) {
                                            final filtered =
                                                _filteredContent(content);
                                            if (content.isEmpty) {
                                              return _FaithEmptyState(
                                                onRetry: _loadFaithData,
                                              );
                                            }
                                            if (filtered.isEmpty) {
                                              return NoDataFound(
                                                title: 'not found'.tr(
                                                  args: [
                                                    '"${_searchController.text}"',
                                                  ],
                                                ),
                                                description:
                                                    'Correct your spellings or search another terms'
                                                        .tr(),
                                              );
                                            }
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: List.generate(
                                                filtered.length,
                                                (index) {
                                                  final raw = filtered[index];
                                                  if (raw is! Map) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          bottom: 10,
                                                        ),
                                                    child: _FaithBeliefCard(
                                                      item: raw,
                                                      index:
                                                          content.indexOf(raw),
                                                      state: state,
                                                      pdfService: _pdfService,
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
              if (state.selectedFaith.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _FaithSelectionBar(
                    indexes: state.selectedFaith,
                    currentData: content,
                    title: title,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Case-insensitive search over topic number and text.
  List<dynamic> _filteredContent(List<dynamic> content) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return content;
    return content.where((raw) {
      if (raw is! Map) return false;
      final number = raw['number']?.toString().toLowerCase() ?? '';
      final text = raw['text']?.toString().toLowerCase() ?? '';
      return number.contains(query) || text.contains(query);
    }).toList(growable: false);
  }
}

class _FaithSearchField extends StatelessWidget {
  const _FaithSearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: colors.surfaceContainerLow,
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: 'Cari topik iman'.tr(),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: context.appRadius(16),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: context.appRadius(16),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: context.appRadius(16),
          borderSide: BorderSide(color: colors.primary, width: 1.3),
        ),
      ),
    );
  }
}

class _FaithHeader extends StatelessWidget {
  const _FaithHeader({required this.state});

  final FaithState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: colors.surface.withValues(alpha: 0.98),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _introTitle(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontSize: context.appFontSize(15),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 19,
                      child: Image.asset(
                        isDark
                            ? Assets.assetsImagesLogoIndonesiaWhite
                            : Assets.assetsImagesLogoIndonesiaColor,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: _readingSettingsLabel(context),
                onPressed: () => _showReadingSettings(context, state),
                icon: Text(
                  'Aa',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Notes'.tr(),
                onPressed: () => router.push(
                  FaithNoteListRoute(cubit: context.read<FaithCubit>()),
                ),
                icon: const Icon(Icons.sticky_note_2_outlined),
              ),
              PopupMenuButton<Locale>(
                tooltip: _languageLabel(context),
                initialValue: state.locale,
                onSelected: context.read<FaithCubit>().setLanguage,
                icon: const Icon(Icons.translate_rounded),
                itemBuilder: (context) => [
                  for (final locale in context.supportedLocales)
                    PopupMenuItem(
                      value: locale,
                      child: Row(
                        children: [
                          Icon(
                            locale == state.locale
                                ? Icons.check_circle_rounded
                                : Icons.language_rounded,
                            size: 18,
                            color: locale == state.locale
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 10),
                          Text(_localeLabel(locale)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaithBeliefCard extends StatelessWidget {
  const _FaithBeliefCard({
    required this.item,
    required this.index,
    required this.state,
    required this.pdfService,
  });

  final Map item;
  final int index;
  final FaithState state;
  final FaithPdfService pdfService;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final selected = state.selectedFaith.contains(index);
    final textStyle = state
        .getTextThemeByFontName(state.defaultFont)
        .bodyLarge
        ?.copyWith(
          fontSize: context.appFontSize(15) * state.defaultTextScale,
          height: state.language == 'zh' ? 1.7 : state.defaultTextHeight,
          color: colors.onSurface,
          fontWeight: FontWeight.w400,
        );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? Color.alphaBlend(
                colors.primary.withValues(alpha: 0.08),
                colors.surfaceContainerLow,
              )
            : colors.surfaceContainerLow,
        borderRadius: context.appRadius(20),
        border: Border.all(
          color: selected
              ? colors.primary.withValues(alpha: 0.52)
              : colors.outlineVariant.withValues(alpha: 0.42),
          width: selected ? 1.3 : 0.8,
        ),
      ),
      child: InkWell(
        borderRadius: context.appRadius(20),
        onTap: () => context.read<FaithCubit>().selectVerse(index),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    constraints: const BoxConstraints(minWidth: 38),
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? colors.primary : colors.primaryContainer,
                      borderRadius: context.appRadius(12),
                    ),
                    child: Text(
                      '${item['number'] ?? index + 1}',
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: selected
                            ? colors.onPrimary
                            : colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item['text']?.toString() ?? '',
                      style: textStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (selected)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 15,
                        color: colors.primary,
                      ),
                    ),
                  const Spacer(),
                  _FaithPdfButton(
                    beliefNumber: index + 1,
                    pdfService: pdfService,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaithPdfButton extends StatefulWidget {
  const _FaithPdfButton({
    required this.beliefNumber,
    required this.pdfService,
  });

  final int beliefNumber;
  final FaithPdfService pdfService;

  @override
  State<_FaithPdfButton> createState() => _FaithPdfButtonState();
}

class _FaithPdfButtonState extends State<_FaithPdfButton> {
  bool _loading = false;

  Future<void> _openPdf() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final document = await widget.pdfService.documentFor(widget.beliefNumber);
      if (!mounted) return;
      if (document == null) {
        _showUnavailable();
        return;
      }
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => FaithPdfViewerPage(document: document),
          settings: RouteSettings(name: 'faith-pdf-${widget.beliefNumber}'),
        ),
      );
    } catch (_) {
      if (mounted) _showUnavailable();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showUnavailable() {
    Fluttertoast.cancel();
    Fluttertoast.showToast(msg: _pdfUnavailable(context));
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _loading ? null : _openPdf,
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        foregroundColor: context.colorScheme.primary,
      ),
      child: _loading
          ? const SizedBox.square(
              dimension: 15,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_pdfButtonLabel(context)),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
    );
  }
}

class _FaithSelectionBar extends StatelessWidget {
  const _FaithSelectionBar({
    required this.indexes,
    required this.currentData,
    required this.title,
  });

  final List<int> indexes;
  final List<dynamic> currentData;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final sorted = [...indexes]..sort();

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(10, 0, 10, 86),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _faithMaxContentWidth),
          child: Material(
            elevation: 8,
            shadowColor: colors.shadow.withValues(alpha: 0.22),
            color: colors.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
              borderRadius: context.appRadius(18),
              side: BorderSide(
                color: colors.primary.withValues(alpha: 0.16),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: context.appRadius(999),
                    ),
                    child: Text(
                      '${sorted.length}',
                      style: context.textTheme.labelLarge?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedLabel(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (sorted.length == 1)
                    IconButton(
                      tooltip: 'Note'.tr(),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _openNote(context, sorted.first),
                      icon: const Icon(Icons.note_add_outlined),
                    ),
                  IconButton(
                    tooltip: 'Share'.tr(),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _shareSelection(
                      context,
                      sorted,
                      currentData,
                      title,
                    ),
                    icon: const Icon(Icons.share_outlined),
                  ),
                  IconButton(
                    tooltip: 'Copy'.tr(),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _copySelection(
                      context,
                      sorted,
                      currentData,
                      title,
                    ),
                    icon: const Icon(Icons.copy_outlined),
                  ),
                  IconButton(
                    tooltip: 'Close'.tr(),
                    visualDensity: VisualDensity.compact,
                    onPressed: context.read<FaithCubit>().removeSelection,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openNote(BuildContext context, int index) {
    final cubit = context.read<FaithCubit>();
    router.push(
      FaithNoteRoute(
        initialData: FaithNote.empty([index]),
        cubit: cubit,
        mode: NoteMode.write,
        onSave: (data) {
          cubit.saveNote(data);
          router.maybePop();
          router.push(FaithNoteListRoute(cubit: cubit));
        },
      ),
    );
  }
}

class _FaithEmptyState extends StatelessWidget {
  const _FaithEmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: context.appRadius(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.menu_book_outlined, size: 40, color: colors.primary),
          const SizedBox(height: 12),
          Text(
            _emptyLabel(context),
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(_retryLabel(context)),
          ),
        ],
      ),
    );
  }
}

Future<void> _showReadingSettings(
  BuildContext context,
  FaithState state,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => BlocProvider.value(
      value: context.read<FaithCubit>(),
      child: const _FaithReadingSettingsSheet(),
    ),
  );
}

class _FaithReadingSettingsSheet extends StatelessWidget {
  const _FaithReadingSettingsSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaithCubit, FaithState>(
      builder: (context, state) {
        final colors = context.colorScheme;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _readingSettingsLabel(context),
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Text(_fontLabel(context), style: context.textTheme.labelLarge),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: state.defaultFont,
                  decoration: const InputDecoration(isDense: true),
                  items: [
                    for (final font in state.availableFonts)
                      DropdownMenuItem(value: font, child: Text(font)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      context.read<FaithCubit>().changeFont(value);
                    }
                  },
                ),
                const SizedBox(height: 18),
                _SettingSlider(
                  label: _textSizeLabel(context),
                  value: state.defaultTextScale,
                  min: 0.85,
                  max: 1.55,
                  divisions: 14,
                  onChanged: context.read<FaithCubit>().changeTextScale,
                ),
                const SizedBox(height: 10),
                _SettingSlider(
                  label: _lineHeightLabel(context),
                  value: state.defaultTextHeight,
                  min: 1.2,
                  max: 2,
                  divisions: 8,
                  onChanged: context.read<FaithCubit>().changeTextHeight,
                ),
                const SizedBox(height: 8),
                Text(
                  _settingsHint(context),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingSlider extends StatelessWidget {
  const _SettingSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: context.textTheme.labelLarge)),
            Text(
              value.toStringAsFixed(2),
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

Future<String> _selectionText(
  BuildContext context,
  List<int> indexes,
  List<dynamic> currentData,
  String title,
) async {
  final languageCode = Localizations.localeOf(context).languageCode;
  final buffer = StringBuffer(title);
  for (final index in indexes) {
    if (index < 0 || index >= currentData.length) continue;
    final raw = currentData[index];
    if (raw is! Map) continue;
    buffer.write('\n${index + 1}. ${raw['text'] ?? ''}');
  }
  try {
    final json = await AppConfigStore.jsonConfig('footer_copied_text');
    final footer = json[languageCode];
    if (footer != null && footer.toString().trim().isNotEmpty) {
      buffer.write('\n\n$footer');
    }
  } catch (_) {}
  return buffer.toString();
}

Future<void> _shareSelection(
  BuildContext context,
  List<int> indexes,
  List<dynamic> currentData,
  String title,
) async {
  final text = await _selectionText(context, indexes, currentData, title);
  try {
    await SharePlus.instance.share(ShareParams(text: text));
  } catch (_) {}
}

Future<void> _copySelection(
  BuildContext context,
  List<int> indexes,
  List<dynamic> currentData,
  String title,
) async {
  final text = await _selectionText(context, indexes, currentData, title);
  await Clipboard.setData(ClipboardData(text: text));
  Fluttertoast.cancel();
  Fluttertoast.showToast(msg: 'Copied!'.tr());
}

String _localeLabel(Locale locale) => switch (locale.languageCode) {
  'id' => 'Indonesia',
  'en' => 'English',
  'zh' => '中文',
  _ => locale.languageCode,
};

String _introTitle(BuildContext context) =>
    switch (Localizations.localeOf(context).languageCode) {
      'id' => 'Dasar Kepercayaan',
      'zh' => '基本信条',
      _ => 'Basic Beliefs',
    };

String _pdfButtonLabel(BuildContext context) =>
    switch (Localizations.localeOf(context).languageCode) {
      'id' => 'Baca Lebih Lanjut',
      'zh' => '了解更多',
      _ => 'Read More',
    };

String _pdfUnavailable(BuildContext context) =>
    switch (Localizations.localeOf(context).languageCode) {
      'id' => 'PDF belum tersedia atau koneksi sedang bermasalah.',
      'zh' => 'PDF 暂不可用或网络连接有问题。',
      _ => 'The PDF is unavailable or the connection failed.',
    };

String _selectedLabel(BuildContext context) =>
    switch (Localizations.localeOf(context).languageCode) {
      'id' => 'Dasar Kepercayaan Dipilih',
      'zh' => '项信条已选择',
      _ => 'Belief(s) Selected',
    };

String _readingSettingsLabel(BuildContext context) =>
    switch (Localizations.localeOf(context).languageCode) {
      'id' => 'Tampilan Bacaan',
      'zh' => '阅读显示',
      _ => 'Reading Appearance',
    };

String _languageLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id' ? 'Bahasa' : 'Language';

String _fontLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
    ? 'Font Bacaan'
    : 'Reading Font';

String _textSizeLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
    ? 'Ukuran Teks'
    : 'Text Size';

String _lineHeightLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
    ? 'Jarak Baris'
    : 'Line Height';

String _settingsHint(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
    ? 'Pengaturan ini disimpan dan dipakai kembali saat Anda membuka bagian Iman.'
    : 'These reading preferences are saved for your next visit.';

String _emptyLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
    ? 'Data dasar kepercayaan belum dapat dimuat.'
    : 'Belief content could not be loaded.';

String _retryLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id'
    ? 'Coba Lagi'
    : 'Retry';

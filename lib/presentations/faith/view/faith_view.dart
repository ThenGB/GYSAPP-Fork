// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/components.dart';
import '../../../data/data.dart';
import '../../../data/services/faith_pdf_service.dart';
import '../../../domain/domain.dart';
import '../../../router/router.dart';
import '../../presentations.dart';

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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadFaithData);
  }

  Future<void> _loadFaithData() async {
    final jsonString = await rootBundle.loadString(Assets.assetsDataFaith);
    final decoded = jsonDecode(jsonString);
    final faith = decoded is Map<String, dynamic> ? decoded['faith'] : null;
    if (!mounted) return;
    setState(() {
      _data = faith is List ? faith : const [];
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _pdfService.dispose();
    super.dispose();
  }

  List<dynamic> get currentData {
    final language = context.read<FaithCubit>().state.locale.languageCode;
    final selected = _data.firstWhereOrNull(
      (element) =>
          element is Map && element['language'] == language.toUpperCase(),
    );
    if (selected is! Map) return const [];
    final content = selected['content'];
    return content is List ? content : const [];
  }

  String get currentTitle {
    final language = context.read<FaithCubit>().state.locale.languageCode;
    final selected = _data.firstWhereOrNull(
      (element) =>
          element is Map && element['language'] == language.toUpperCase(),
    );
    if (selected is! Map) return 'faith_section_title'.tr();
    return selected['title']?.toString() ?? 'faith_section_title'.tr();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocBuilder<FaithCubit, FaithState>(
      builder: (context, state) {
        final initialState = context.read<InitialCubit>().state;
        return Scaffold(
          backgroundColor: context.colorScheme.surface,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              tooltip: 'Menu',
              onPressed: openDashboardDrawer,
              icon: const Icon(Icons.menu_rounded),
            ),
            title: Text(currentTitle),
            actions: [
              Builder(
                builder: (pillContext) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: OutlinedButton.icon(
                    onPressed: () => _showLanguageMenu(pillContext, state),
                    icon: const Icon(Icons.translate_rounded, size: 17),
                    label: Text(_localeLabel(state.locale)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'See all notes'.tr(),
                onPressed: () =>
                    router.push(FaithNoteListRoute(cubit: context.read())),
                icon: const Icon(Icons.note_alt_outlined),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    context.appSpace(12),
                    0,
                    context.appSpace(28),
                  ),
                  itemCount: currentData.length + 1,
                  itemBuilder: (context, listIndex) {
                    if (listIndex == 0) {
                      return const _FaithIntroduction();
                    }
                    final index = listIndex - 1;
                    final raw = currentData[index];
                    if (raw is! Map) return const SizedBox.shrink();
                    final item = Map<String, dynamic>.from(raw);
                    return Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _faithMaxContentWidth,
                        ),
                        child: FaithWidget(
                          fontHeight: initialState.defaultTextHeight,
                          index: index,
                          item: item,
                          scale: initialState.defaultTextScale,
                          pdfService: _pdfService,
                        ),
                      ),
                    );
                  },
                ),
              ),
              AnimatedSize(
                curve: Curves.easeOutCubic,
                alignment: Alignment.bottomCenter,
                duration: const Duration(milliseconds: 220),
                child: state.selectedFaith.isEmpty
                    ? const SizedBox.shrink()
                    : SelectedFaithMenu(
                        title: currentTitle,
                        indexes: state.selectedFaith,
                        currentData: currentData,
                        viewPadding: context.mediaQuery.viewPadding.vertical,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FaithIntroduction extends StatelessWidget {
  const _FaithIntroduction();

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _faithMaxContentWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.appSpace(16),
            context.appSpace(4),
            context.appSpace(16),
            context.appSpace(12),
          ),
          child: Container(
            padding: EdgeInsets.all(context.appSpace(18)),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: context.appRadius(18),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: context.appRadius(13),
                  ),
                  child: Icon(
                    Icons.church_outlined,
                    color: colors.onPrimaryContainer,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _introTitle(context),
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _introBody(context),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
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

class FaithWidget extends StatelessWidget {
  const FaithWidget({
    super.key,
    required this.item,
    required this.scale,
    required this.index,
    required this.fontHeight,
    required this.pdfService,
  });

  final Map<String, dynamic> item;
  final double scale;
  final double fontHeight;
  final int index;
  final FaithPdfService pdfService;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaithCubit, FaithState>(
      buildWhen: (previous, current) =>
          previous.selectedFaith != current.selectedFaith ||
          previous.language != current.language,
      builder: (context, state) {
        final selected = state.selectedFaith.contains(index);
        final colors = context.colorScheme;
        final isChinese = state.locale.languageCode == 'zh';
        final initialCubit = context.read<InitialCubit>();

        return Padding(
          padding: EdgeInsets.fromLTRB(
            context.appSpace(16),
            context.appSpace(6),
            context.appSpace(16),
            context.appSpace(6),
          ),
          child: Material(
            color: selected
                ? colors.primaryContainer.withValues(alpha: 0.72)
                : colors.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: context.appRadius(18),
              side: BorderSide(
                color: selected
                    ? colors.primary.withValues(alpha: 0.38)
                    : colors.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async {
                context.read<FaithCubit>().selectVerse(index);
                await Future<void>.delayed(const Duration(milliseconds: 80));
                if (!context.mounted) return;
                if (context.read<FaithCubit>().state.selectedFaith.contains(index)) {
                  Scrollable.ensureVisible(
                    context,
                    alignment: 0.26,
                    curve: Curves.easeOutCubic,
                    duration: const Duration(milliseconds: 280),
                  );
                }
              },
              child: Padding(
                padding: EdgeInsets.all(context.appSpace(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: const BoxConstraints(minWidth: 36),
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? colors.primary
                                : colors.primaryContainer,
                            borderRadius: context.appRadius(11),
                          ),
                          child: Text(
                            '${item['number']}',
                            style: context.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
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
                            textScaler: TextScaler.linear(scale),
                            style: TextStyle(
                              fontFamily: initialCubit.state.defaultFont,
                              height: isChinese ? null : fontHeight,
                              fontWeight: FontWeight.w400,
                              fontSize: context.appFontSize(15),
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.appSpace(14)),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectHint(context, selected),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              letterSpacing: 0.15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
          ),
        );
      },
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
        _showPdfUnavailable();
        return;
      }
      final opened = await launchUrl(document.uri, mode: LaunchMode.platformDefault);
      if (!opened && mounted) _showPdfUnavailable();
    } catch (_) {
      if (mounted) _showPdfUnavailable();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showPdfUnavailable() {
    Fluttertoast.cancel();
    Fluttertoast.showToast(msg: _pdfUnavailable(context));
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _pdfButtonLabel(context),
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _openPdf,
        icon: _loading
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.picture_as_pdf_outlined, size: 18),
        label: Text(_pdfButtonLabel(context)),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

Future<void> _showLanguageMenu(BuildContext context, FaithState state) async {
  final box = context.findRenderObject() as RenderBox;
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final locale = await showMenu<Locale>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    ),
    initialValue: state.locale,
    items: [
      for (final locale in context.supportedLocales)
        PopupMenuItem(
          value: locale,
          child: Row(
            children: [
              const Icon(Icons.language_rounded, size: 18),
              const SizedBox(width: 10),
              Text(
                _localeLabel(locale),
                style: locale == state.locale
                    ? TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.colorScheme.primary,
                      )
                    : null,
              ),
            ],
          ),
        ),
    ],
  );
  if (locale != null && context.mounted) {
    context.read<FaithCubit>().setLanguage(locale);
  }
}

String _localeLabel(Locale locale) => switch (locale.languageCode) {
      'id' => 'Indonesia',
      'en' => 'English',
      'zh' => '中文',
      _ => locale.languageCode,
    };

String _introTitle(BuildContext context) => switch (context.locale.languageCode) {
      'id' => 'Sepuluh Dasar Kepercayaan',
      'zh' => '十大信条',
      _ => 'Ten Basic Beliefs',
    };

String _introBody(BuildContext context) => switch (context.locale.languageCode) {
      'id' =>
        'Baca setiap dasar kepercayaan dengan tenang. Ketuk kartu untuk memilih, mencatat, menyalin, atau membagikan; gunakan tombol PDF untuk membuka penjelasan lengkapnya.',
      'zh' => '阅读每一项信条。点按卡片可选择、记录、复制或分享；使用 PDF 按钮查看完整说明。',
      _ =>
        'Read each belief at your own pace. Tap a card to select, note, copy, or share it; use the PDF button for the full explanation.',
    };

String _selectHint(BuildContext context, bool selected) {
  if (selected) {
    return switch (context.locale.languageCode) {
      'id' => 'Dipilih untuk tindakan',
      'zh' => '已选择',
      _ => 'Selected for actions',
    };
  }
  return switch (context.locale.languageCode) {
    'id' => 'Ketuk kartu untuk memilih',
    'zh' => '点按卡片以选择',
    _ => 'Tap card to select',
  };
}

String _pdfButtonLabel(BuildContext context) =>
    switch (context.locale.languageCode) {
      'id' => 'Penjelasan PDF',
      'zh' => 'PDF 说明',
      _ => 'PDF explanation',
    };

String _pdfUnavailable(BuildContext context) =>
    switch (context.locale.languageCode) {
      'id' => 'PDF belum tersedia atau koneksi sedang bermasalah.',
      'zh' => 'PDF 暂不可用或网络连接有问题。',
      _ => 'The PDF is unavailable or the connection failed.',
    };

class SelectedFaithMenu extends StatelessWidget {
  const SelectedFaithMenu({
    super.key,
    required this.indexes,
    required this.currentData,
    required this.title,
    required this.viewPadding,
  });

  final List<int> indexes;
  final String title;
  final List<dynamic> currentData;
  final double viewPadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _faithMaxContentWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            border: Border(
              top: BorderSide(color: colors.outlineVariant),
              left: BorderSide(color: colors.outlineVariant),
              right: BorderSide(color: colors.outlineVariant),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${indexes.length} ${_selectedLabel(context)}',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close'.tr(),
                    visualDensity: VisualDensity.compact,
                    onPressed: context.read<FaithCubit>().removeSelection,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (indexes.length == 1)
                    FilledButton.tonalIcon(
                      onPressed: () {
                        router.push(
                          FaithNoteRoute(
                            initialData: FaithNote.empty(indexes),
                            cubit: context.read<FaithCubit>(),
                            mode: NoteMode.write,
                            onSave: (data) {
                              context.read<FaithCubit>().saveNote(data);
                              router.maybePop();
                              router.push(
                                FaithNoteListRoute(cubit: context.read()),
                              );
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.note_add_outlined, size: 18),
                      label: Text('Note'.tr()),
                    ),
                  FilledButton.tonalIcon(
                    onPressed: () => _shareFaith(context),
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: Text('Share'.tr()),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _copyFaith(context),
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    label: Text('Copy'.tr()),
                  ),
                ],
              ),
              SizedBox(height: 12 + viewPadding + 72),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareFaith(BuildContext context) async {
    final text = await _selectedText(context);
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (_) {}
  }

  Future<void> _copyFaith(BuildContext context) async {
    final text = await _selectedText(context);
    await Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.cancel();
    Fluttertoast.showToast(msg: 'Copied!'.tr());
  }

  Future<String> _selectedText(BuildContext context) async {
    final ordered = indexes.sorted((a, b) => a.compareTo(b));
    final buffer = StringBuffer(title);
    for (final index in ordered) {
      if (index < 0 || index >= currentData.length) continue;
      final raw = currentData[index];
      if (raw is! Map) continue;
      buffer.write('\n${index + 1}. ${raw['text'] ?? ''}');
    }
    final json = await AppConfigStore.jsonConfig('footer_copied_text');
    final footer = json[context.locale.languageCode];
    if (footer != null && footer.toString().isNotEmpty) {
      buffer.write('\n\n$footer');
    }
    return buffer.toString();
  }
}

String _selectedLabel(BuildContext context) =>
    switch (context.locale.languageCode) {
      'id' => 'dasar kepercayaan dipilih',
      'zh' => '项已选择',
      _ => 'belief(s) selected',
    };

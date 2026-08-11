import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/components.dart';
import '../../../data/services/faith_pdf_service.dart';
import '../../../data/utilities/extensions/context_ext.dart';

class FaithPdfViewerPage extends StatefulWidget {
  const FaithPdfViewerPage({super.key, required this.document});

  final FaithPdfDocument document;

  @override
  State<FaithPdfViewerPage> createState() => _FaithPdfViewerPageState();
}

class _FaithPdfViewerPageState extends State<FaithPdfViewerPage> {
  final pdfrx.PdfViewerController _controller = pdfrx.PdfViewerController();

  int _currentPage = 1;
  int _pageCount = 0;
  int _savedPage = 1;
  bool _showResume = false;

  String get _lastPageKey =>
      'faith_pdf_last_page_v1_${widget.document.beliefNumber}';

  @override
  void initState() {
    super.initState();
    unawaited(_loadLastPage());
  }

  Future<void> _loadLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_lastPageKey) ?? 1;
    if (!mounted) return;
    setState(() => _savedPage = saved < 1 ? 1 : saved);
    _updateResumeVisibility();
  }

  Future<void> _savePage(int pageNumber) async {
    if (pageNumber < 1) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPageKey, pageNumber);
  }

  void _onViewerReady(
    pdfrx.PdfDocument document,
    pdfrx.PdfViewerController controller,
  ) {
    if (!mounted) return;
    setState(() {
      _pageCount = controller.pageCount;
      _currentPage = controller.pageNumber ?? 1;
    });
    _updateResumeVisibility();
  }

  void _onPageChanged(int? pageNumber) {
    if (pageNumber == null || pageNumber < 1) return;
    if (mounted && pageNumber != _currentPage) {
      setState(() => _currentPage = pageNumber);
    }
    unawaited(_savePage(pageNumber));
    if (_showResume && pageNumber == _savedPage && mounted) {
      setState(() => _showResume = false);
    }
  }

  void _updateResumeVisibility() {
    if (!mounted || _pageCount <= 0) return;
    final shouldShow =
        _savedPage > 1 && _savedPage <= _pageCount && _savedPage != _currentPage;
    if (shouldShow != _showResume) {
      setState(() => _showResume = shouldShow);
    }
  }

  Future<void> _resumeReading() async {
    if (_pageCount <= 0) return;
    final target = _savedPage.clamp(1, _pageCount).toInt();
    if (mounted) setState(() => _showResume = false);
    await _controller.goToPage(
      pageNumber: target,
      anchor: pdfrx.PdfPageAnchor.top,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          // Small floating back affordance (top-left) since the document
          // opens without a header.
          Positioned(
            top: 10 + MediaQuery.paddingOf(context).top,
            left: 10,
            child: SafeArea(
              child: Material(
                color: colors.surface.withValues(alpha: 0.88),
                elevation: 0,
                shape: CircleBorder(
                  side: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  tooltip: 'Kembali',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 22),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ColoredBox(
              color: Color.alphaBlend(
                colors.primary.withValues(alpha: 0.025),
                colors.surfaceContainerLowest,
              ),
              child: pdfrx.PdfViewer.uri(
                widget.document.uri,
                controller: _controller,
                preferRangeAccess: true,
                timeout: const Duration(seconds: 25),
                params: pdfrx.PdfViewerParams(
                  margin: isWide ? 18 : 10,
                  backgroundColor: Colors.transparent,
                  maxImageBytesCachedOnMemory: isWide
                      ? 96 * 1024 * 1024
                      : 64 * 1024 * 1024,
                  pageDropShadow: BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                  onViewerReady: _onViewerReady,
                  onPageChanged: _onPageChanged,
                ),
              ),
            ),
          ),
          // Centered loading progress while the PDF document is still
          // downloading/parsing (before onViewerReady sets _pageCount).
          if (_pageCount == 0)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (_pageCount > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 14 + MediaQuery.viewPaddingOf(context).bottom,
              child: Center(
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.inverseSurface.withValues(alpha: 0.90),
                      borderRadius: context.appRadius(999),
                    ),
                    child: Text(
                      _pageLabel(context, _currentPage, _pageCount),
                      style: context.textTheme.labelMedium?.copyWith(
                        color: colors.onInverseSurface,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: isWide ? 22 : 12,
            right: isWide ? 18 : 12,
            left: isWide ? null : 12,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: !_showResume
                  ? const SizedBox.shrink()
                  : _ResumeReadingCard(
                      key: ValueKey(_savedPage),
                      pageNumber: _savedPage,
                      wide: isWide,
                      onResume: _resumeReading,
                      onDismiss: () => setState(() => _showResume = false),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeReadingCard extends StatelessWidget {
  const _ResumeReadingCard({
    super.key,
    required this.pageNumber,
    required this.wide,
    required this.onResume,
    required this.onDismiss,
  });

  final int pageNumber;
  final bool wide;
  final VoidCallback onResume;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Material(
      elevation: 0,
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: context.appRadius(18),
        side: BorderSide(color: colors.primary.withValues(alpha: 0.22)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: wide ? 320 : double.infinity),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: context.appRadius(12),
                ),
                child: Icon(
                  Icons.bookmark_rounded,
                  size: 20,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _resumeTitle(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _resumePageLabel(context, pageNumber),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onResume,
                child: Text(_resumeAction(context)),
              ),
              IconButton(
                tooltip: _dismissLabel(context),
                visualDensity: VisualDensity.compact,
                onPressed: onDismiss,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _resumeTitle(BuildContext context) =>
    switch (Localizations.localeOf(context).languageCode) {
      'id' => 'Kembali ke halaman terakhir dibuka?',
      'zh' => '返回上次阅读的位置？',
      _ => 'Return to your last page?',
    };

String _resumePageLabel(BuildContext context, int page) =>
    switch (Localizations.localeOf(context).languageCode) {
      'id' => 'Terakhir dibaca di halaman $page',
      'zh' => '上次读到第 $page 页',
      _ => 'Last read on page $page',
    };

String _resumeAction(BuildContext context) =>
    switch (Localizations.localeOf(context).languageCode) {
      'id' => 'Kembali',
      'zh' => '返回',
      _ => 'Resume',
    };

String _pageLabel(BuildContext context, int current, int total) =>
    switch (Localizations.localeOf(context).languageCode) {
      'id' => 'Halaman $current / $total',
      'zh' => '第 $current / $total 页',
      _ => 'Page $current / $total',
    };

String _dismissLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'id' ? 'Tutup' : 'Dismiss';

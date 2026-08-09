import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Crash-free web replacement for pages that rely on
/// `flutter_inappwebview` (which has no web implementation — building the
/// widget on web throws UnsupportedError). Renders a simple card that opens
/// [url] in a new browser tab instead.
class WebFallbackView extends StatelessWidget {
  final String title;
  final String url;
  const WebFallbackView({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        shape: Border(bottom: BorderSide(color: colors.secondaryContainer)),
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: Text(title),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: colors.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.language_rounded,
                      size: 40,
                      color: colors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Halaman ini hanya tersedia di aplikasi',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buka konten di tab browser baru.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () async {
                        try {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (_) {}
                      },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Buka di browser'),
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

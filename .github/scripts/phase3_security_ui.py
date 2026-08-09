import json
from pathlib import Path


def replace(path: str, old: str, new: str, count: int = -1) -> None:
    target = Path(path)
    text = target.read_text(encoding="utf-8-sig")
    if old not in text:
        raise SystemExit(f"pattern not found in {path}: {old[:120]!r}")
    target.write_text(text.replace(old, new, count), encoding="utf-8")


# Secure storage dependency.
pubspec = Path("pubspec.yaml")
text = pubspec.read_text(encoding="utf-8-sig")
if "flutter_secure_storage:" not in text:
    text = text.replace(
        "  shared_preferences: ^2.5.5\n",
        "  shared_preferences: ^2.5.5\n  flutter_secure_storage: ^10.3.1\n",
        1,
    )
pubspec.write_text(text, encoding="utf-8")

# All production endpoints are HTTPS. Disable Android clear-text transport.
manifest = Path("android/app/src/main/AndroidManifest.xml")
text = manifest.read_text(encoding="utf-8-sig")
text = text.replace(
    'android:usesCleartextTraffic="true"',
    'android:usesCleartextTraffic="false"',
)
manifest.write_text(text, encoding="utf-8")

# Fix real UTF-8 mojibake in translation values while leaving genuine Unicode
# (notably Chinese) untouched. A conversion is accepted only when the marker
# score improves.
markers = ("Ã", "Â", "â", "ð", "�")


def marker_score(value: str) -> int:
    return sum(value.count(marker) for marker in markers)


def repair_string(value: str) -> str:
    current = value
    for _ in range(3):
        if marker_score(current) == 0:
            break
        try:
            candidate = current.encode("cp1252").decode("utf-8")
        except (UnicodeEncodeError, UnicodeDecodeError):
            break
        if marker_score(candidate) >= marker_score(current):
            break
        current = candidate
    return current


def repair_value(value):
    if isinstance(value, str):
        return repair_string(value)
    if isinstance(value, list):
        return [repair_value(item) for item in value]
    if isinstance(value, dict):
        return {key: repair_value(item) for key, item in value.items()}
    return value


for translation in Path("assets/translations").glob("*.json"):
    data = json.loads(translation.read_text(encoding="utf-8-sig"))
    repaired = repair_value(data)
    translation.write_text(
        json.dumps(repaired, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

# Improve split-mode semantics and replace the fixed 5-column popup with a
# responsive, accessible 4x2 action grid.
bible = Path("lib/presentations/bible/view/bible_view.dart")
text = bible.read_text(encoding="utf-8-sig")
text = text.replace(
    "tooltip: splitAxis == Axis.horizontal ? 'Horiz' : 'Vert',",
    "tooltip: splitAxis == Axis.horizontal\n          ? 'Tata letak split: horizontal'\n          : 'Tata letak split: vertikal',",
    1,
)
marker = "class _BibleMenuGrid extends StatelessWidget {"
start = text.find(marker)
if start < 0:
    raise SystemExit("Bible menu grid marker not found")
menu = r'''class _BibleMenuGrid extends StatelessWidget {
  final bool isAudioOn;
  final ValueChanged<String> onAction;

  const _BibleMenuGrid({
    required this.isAudioOn,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final availableWidth = MediaQuery.sizeOf(context).width - 40;
    final width = availableWidth.clamp(280.0, 360.0).toDouble();
    final items = <({String action, IconData icon, String label, bool active})>[
      (
        action: 'version',
        icon: Icons.menu_book_outlined,
        label: 'Version',
        active: false,
      ),
      (
        action: 'histories',
        icon: Icons.history_rounded,
        label: 'Histories',
        active: false,
      ),
      (
        action: 'font',
        icon: Icons.text_fields_rounded,
        label: 'Font Settings',
        active: false,
      ),
      (
        action: 'notes',
        icon: Icons.sticky_note_2_outlined,
        label: 'See all notes',
        active: false,
      ),
      (
        action: 'bookmarkNow',
        icon: Icons.bookmark_add_outlined,
        label: 'Bookmark current chapter',
        active: false,
      ),
      (
        action: 'bookmarks',
        icon: Icons.bookmarks_outlined,
        label: 'Bookmarks',
        active: false,
      ),
      (
        action: 'search',
        icon: Icons.search_rounded,
        label: 'Search',
        active: false,
      ),
      (
        action: 'audio',
        icon: isAudioOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
        label: 'Audio',
        active: isAudioOn,
      ),
    ];

    return SizedBox(
      width: width,
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 0.96,
        children: [
          for (final item in items)
            Semantics(
              button: true,
              selected: item.active,
              label: item.label.tr(),
              child: InkWell(
                borderRadius: context.appRadius(14),
                onTap: () => onAction(item.action),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: context.appRadius(14),
                    color: item.active
                        ? colors.primaryContainer.withValues(alpha: 0.72)
                        : colors.surfaceContainerLow,
                    border: Border.all(
                      color: item.active
                          ? colors.primary.withValues(alpha: 0.34)
                          : colors.outlineVariant.withValues(alpha: 0.34),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: item.active
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.label.tr(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelSmall?.copyWith(
                          height: 1.12,
                          color: item.active
                              ? colors.onPrimaryContainer
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
'''
bible.write_text(text[:start] + menu, encoding="utf-8")

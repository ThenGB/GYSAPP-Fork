import json
from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file_path = Path(path)
    text = file_path.read_text(encoding='utf-8')
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{path}: expected 1 match, found {count}')
    file_path.write_text(text.replace(old, new), encoding='utf-8')


replace_once(
    'lib/components/themes/app_accent.dart',
    "    key: 'skyBlue',\n    label: 'Sky Blue',",
    "    key: 'skyBlue',\n    label: 'GYS Blue',",
)

replace_once(
    'lib/presentations/initial/bloc/initial_cubit.dart',
    "  void changeDensity(DisplayDensity density) {\n"
    "    final updatedPrefs = state.themePreferences.copyWith(density: density);\n"
    "    emit(state.copyWith(themePreferences: updatedPrefs));\n"
    "    _saveThemePreferences();\n"
    "  }\n",
    "  void changeDensity(DisplayDensity density) {\n"
    "    final updatedPrefs = state.themePreferences.copyWith(density: density);\n"
    "    emit(state.copyWith(themePreferences: updatedPrefs));\n"
    "    _saveThemePreferences();\n"
    "  }\n\n"
    "  void changeSurfaceTone(SurfaceTone tone) {\n"
    "    final updatedPrefs = state.themePreferences.copyWith(surfaceTone: tone);\n"
    "    emit(state.copyWith(themePreferences: updatedPrefs));\n"
    "    _saveThemePreferences();\n"
    "  }\n",
)

settings = Path('lib/presentations/settings/view/settings_view.dart')
text = settings.read_text(encoding='utf-8')
old = '''                    _AccentColorPicker(
                      selectedKey: state.accentKey,
                      customAccentSeed: state.themePreferences.customAccentSeed,
                      onSelected: (key, customColor) {
                        if (customColor != null) {
                          context.read<InitialCubit>().changeCustomAccentColor(
                            customColor,
                          );
                        } else {
                          context.read<InitialCubit>().changeAccentColor(key);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _DensitySelector(
'''
new = '''                    _AccentColorPicker(
                      selectedKey: state.accentKey,
                      customAccentSeed: state.themePreferences.customAccentSeed,
                      onSelected: (key, customColor) {
                        if (customColor != null) {
                          context.read<InitialCubit>().changeCustomAccentColor(
                            customColor,
                          );
                        } else {
                          context.read<InitialCubit>().changeAccentColor(key);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _SurfaceToneSelector(
                      selected: state.themePreferences.surfaceTone,
                      onChanged: context.read<InitialCubit>().changeSurfaceTone,
                    ),
                    const SizedBox(height: 16),
                    _DensitySelector(
'''
if text.count(old) != 1:
    raise SystemExit('settings appearance insertion anchor mismatch')
text = text.replace(old, new)

marker = 'class _DensitySelector extends StatelessWidget {'
selector = '''class _SurfaceToneSelector extends StatelessWidget {
  const _SurfaceToneSelector({required this.selected, required this.onChanged});

  final SurfaceTone selected;
  final ValueChanged<SurfaceTone> onChanged;

  @override
  Widget build(BuildContext context) {
    return _PreferenceSelector<SurfaceTone>(
      label: 'surface_tone'.tr(),
      selected: {selected},
      onChanged: onChanged,
      segments: [
        ButtonSegment(
          value: SurfaceTone.light,
          label: Text('surface_light'.tr()),
        ),
        ButtonSegment(
          value: SurfaceTone.medium,
          label: Text('surface_medium'.tr()),
        ),
        ButtonSegment(
          value: SurfaceTone.dark,
          label: Text('surface_dark'.tr()),
        ),
      ],
    );
  }
}

'''
if text.count(marker) != 1:
    raise SystemExit('surface selector class anchor mismatch')
text = text.replace(marker, selector + marker)

settings_gradient = '''      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.2,
              ),
              context.colorScheme.surfaceContainerLow.withValues(alpha: 0.34),
              context.colorScheme.surface,
            ],
          ),
        ),
'''
settings_surface = '''      body: ColoredBox(
        color: context.colorScheme.surface,
'''
if text.count(settings_gradient) != 1:
    raise SystemExit('settings background gradient anchor mismatch')
text = text.replace(settings_gradient, settings_surface)
text = text.replace('toolbarHeight: 74,', 'toolbarHeight: 64,', 1)
settings.write_text(text, encoding='utf-8')

home = Path('lib/presentations/home/view/home_view.dart')
text = home.read_text(encoding='utf-8')
home_gradient = '''        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.surface,
                colors.surfaceContainerLowest,
                colors.surface,
              ],
              stops: const [0, 0.38, 1],
            ),
          ),
'''
home_surface = '''        return ColoredBox(
          color: colors.surface,
'''
if text.count(home_gradient) != 1:
    raise SystemExit('home background gradient anchor mismatch')
text = text.replace(home_gradient, home_surface)

welcome_gradient = '''            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primaryContainer.withValues(alpha: 0.58),
                  colors.secondaryContainer.withValues(alpha: 0.28),
                  colors.surfaceContainerLow,
                ],
              ),
'''
welcome_surface = '''            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
'''
if text.count(welcome_gradient) != 1:
    raise SystemExit('home welcome gradient anchor mismatch')
text = text.replace(welcome_gradient, welcome_surface)
home.write_text(text, encoding='utf-8')

dashboard = Path('lib/presentations/dashboard/view/dashboard_view.dart')
text = dashboard.read_text(encoding='utf-8')
drawer_gradient = '''        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surfaceContainerHighest.withValues(alpha: 0.75),
                colors.surface,
              ],
            ),
          ),
'''
drawer_surface = '''        child: ColoredBox(
          color: colors.surface,
'''
if text.count(drawer_gradient) != 1:
    raise SystemExit('drawer gradient anchor mismatch')
text = text.replace(drawer_gradient, drawer_surface)
dashboard.write_text(text, encoding='utf-8')

for path in [
    'lib/components/widgets/section.dart',
    'lib/components/design_system/unified_components.dart',
]:
    file_path = Path(path)
    value = file_path.read_text(encoding='utf-8')
    value = value.replace('FontWeight.w750', 'FontWeight.w700')
    value = value.replace('FontWeight.w650', 'FontWeight.w600')
    file_path.write_text(value, encoding='utf-8')

translations = {
    'assets/translations/id.json': {
        'surface_tone': 'Nuansa permukaan',
        'surface_light': 'Terang',
        'surface_medium': 'Teduh',
        'surface_dark': 'Dalam',
    },
    'assets/translations/en.json': {
        'surface_tone': 'Surface tone',
        'surface_light': 'Light',
        'surface_medium': 'Soft',
        'surface_dark': 'Deep',
    },
    'assets/translations/zh.json': {
        'surface_tone': '表面色调',
        'surface_light': '明亮',
        'surface_medium': '柔和',
        'surface_dark': '深色',
    },
}
for path, additions in translations.items():
    file_path = Path(path)
    data = json.loads(file_path.read_text(encoding='utf-8'))
    data.update(additions)
    file_path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + '\n',
        encoding='utf-8',
    )

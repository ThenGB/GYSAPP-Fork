#!/usr/bin/env python3
"""Replace piano button with tempo control button."""

import re

file_path = r'd:\GitHub Repo\church\lib\presentations\dashboard\view\dashboard_view.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the piano button with a tempo control button
pattern = r'IconButton\(\s+visualDensity: VisualDensity\.compact,\s+onPressed: \(\) => \{\},\s+icon: Icon\(\s+Icons\.piano_rounded,\s+color: colors\.onSurfaceVariant,\s+\),\s+\),'

replacement = '''Container(
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.outlineVariant),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => cubit.setTempo(songState.tempoBpm - 5),
                                  icon: const Icon(Icons.remove_rounded),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '${songState.tempoBpm.toInt()}',
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.titleSmall,
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => cubit.setTempo(songState.tempoBpm + 5),
                                  icon: const Icon(Icons.add_rounded),
                                ),
                              ],
                            ),
                          ),'''

new_content = re.sub(pattern, replacement, content)

with open(file_path, 'w', encoding='utf-8', newline='') as f:
    f.write(new_content)

print("Replaced piano button with tempo control")

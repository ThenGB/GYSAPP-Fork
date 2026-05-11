#!/usr/bin/env python3
"""Add accidental toggle button after tempo control."""

import re

file_path = r'd:\GitHub Repo\church\lib\presentations\dashboard\view\dashboard_view.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Find the end of the tempo control Container and add the accidental toggle button
pattern = r'(\),\s+\),\s+\),\s+const Spacer\(\),\s+IconButton\()'

replacement = r'''),\
                          ),\
                          const SizedBox(width: 8),\
                          Container(\
                            decoration: BoxDecoration(\
                              color: colors.surfaceContainerLowest,\
                              borderRadius: BorderRadius.circular(12),\
                              border: Border.all(color: colors.outlineVariant),\
                            ),\
                            child: IconButton(\
                              visualDensity: VisualDensity.compact,\
                              onPressed: () => cubit.toggleAccidentalMode(),\
                              icon: Text(\
                                songState.chordAccidentalMode == ChordService.accidentalSharp ? "♯" : "♭",\
                                style: context.textTheme.titleMedium,\
                              ),\
                            ),\
                          ),\
                          const Spacer(),\
                          IconButton('''

new_content = re.sub(pattern, replacement, content)

with open(file_path, 'w', encoding='utf-8', newline='') as f:
    f.write(new_content)

print("Added accidental toggle button")

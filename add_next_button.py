#!/usr/bin/env python3
"""Add Next button to mini player after the Play button."""

import re

file_path = r'd:\GitHub Repo\church\lib\presentations\dashboard\view\dashboard_view.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Find the pattern after the Play button SizedBox and add the Next button
pattern = r'(\s+const SizedBox\(width: 10\),)\s+(Expanded\()'
replacement = r'''\1
                          const SizedBox(width: 4),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: songState.pageIndex < songState.totalSongs - 1
                                ? () => cubit.goToNextSong()
                                : null,
                            icon: Icon(
                              Icons.skip_next_rounded,
                              color: songState.pageIndex < songState.totalSongs - 1
                                  ? colors.onSurface
                                  : colors.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          \2'''

new_content = re.sub(pattern, replacement, content)

with open(file_path, 'w', encoding='utf-8', newline='') as f:
    f.write(new_content)

print("Added Next button to mini player")

import re

# Read the file
with open('lib/presentations/dashboard/view/dashboard_view.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add accidental button after the transpose controls
old_pattern = r'\),\s+\],\s+\),\s+\),\s+\),\s+const Spacer\(\),'
new_section = '''),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.outlineVariant),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => cubit.toggleAccidentalMode(),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        songState.chordAccidentalMode == 'sharp' ? '♯' : '♭',
                                        style: context.textTheme.titleMedium?.copyWith(
                                          color: colors.onSurfaceVariant,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ),
                          const Spacer(),'''

# Replace
new_content = re.sub(old_pattern, new_section, content, count=1)

# Write back
with open('lib/presentations/dashboard/view/dashboard_view.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)

print('File updated successfully')
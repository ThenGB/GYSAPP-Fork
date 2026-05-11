#!/usr/bin/env python3
"""Add MarionetteBinding initialization to main.dart for screenshot support"""

import re

file_path = r'd:\GitHub Repo\church\lib\main.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add MarionetteBinding initialization before runZonedGuarded
pattern = r'(void main\(\) async \{)'
replacement = r'''void main() async {
  // Initialize MarionetteBinding for screenshot support in debug mode
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }

'''

new_content = re.sub(pattern, replacement, content)

with open(file_path, 'w', encoding='utf-8', newline='') as f:
    f.write(new_content)

print("Added MarionetteBinding initialization")

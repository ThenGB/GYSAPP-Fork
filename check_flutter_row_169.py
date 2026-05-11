#!/usr/bin/env python3
"""
Check if Flutter now extracts row at yPct=16.9%.
"""
import json

# Load Flutter note positions
with open("flutter_note_positions.json", "r") as f:
    flutter_data = json.load(f)

print(f"Flutter extracted {len(flutter_data)} notes")

# Group by Y position
rows = {}
for note_idx, pos in flutter_data.items():
    row_y = round(pos['yPct'], 1)
    if row_y not in rows:
        rows[row_y] = []
    rows[row_y].append(int(note_idx))

print(f"Flutter found {len(rows)} distinct rows:")
for row_y in sorted(rows.keys()):
    print(f"  Row yPct={row_y}%: {len(rows[row_y])} notes")

# Check for row at 16.9%
if 16.9 in rows:
    print(f"\n[SUCCESS] Flutter now extracts row at yPct=16.9%!")
    print(f"  Notes in this row: {len(rows[16.9])}")
else:
    print(f"\n[PROBLEM] Flutter still does not extract row at yPct=16.9%")
    print(f"  Closest rows: {sorted(rows.keys(), key=lambda x: abs(x - 16.9))[:5]}")
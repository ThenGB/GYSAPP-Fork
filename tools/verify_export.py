import sqlite3
import json

conn = sqlite3.connect('assets/data/song.db.20251218a.bak')
conn.row_factory = sqlite3.Row
cursor = conn.cursor()

# List tables
cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
print("Tables:", [r['name'] for r in cursor.fetchall()])

# Count songs per code
for code in ['KR','HYMNE','MDR','ASM-I','ASM-M','ASM-P']:
    cursor.execute("SELECT COUNT(DISTINCT number) FROM lyric WHERE code=? AND seq=0", (code,))
    count = cursor.fetchone()[0]
    print(f'{code}: {count} songs')

# Verify each JSON matches
db_counts = {}
for code in ['KR','HYMNE','MDR','ASM-I','ASM-M','ASM-P']:
    cursor.execute("SELECT number, lyric FROM lyric WHERE code=? AND seq=0 ORDER BY number", (code,))
    db_counts[code] = {r['number']: r['lyric'] for r in cursor.fetchall()}

conn.close()

# Load JSON and compare
for code in ['KR','HYMNE','MDR','ASM-I','ASM-M','ASM-P']:
    fname = f"assets/data/index/{code.lower().replace('-', '_')}_index.json"
    with open(fname, 'r', encoding='utf-8') as f:
        data = json.load(f)
    json_nums = {s['number'] for s in data}
    db_nums = set(db_counts[code].keys())
    
    missing_in_json = db_nums - json_nums
    extra_in_json = json_nums - db_nums
    
    print(f"\n{code}: JSON={len(json_nums)} DB={len(db_nums)}")
    if missing_in_json:
        print(f"  MISSING in JSON: {sorted(missing_in_json)}")
    if extra_in_json:
        print(f"  EXTRA in JSON: {sorted(extra_in_json)}")
    if not missing_in_json and not extra_in_json:
        print(f"  ✓ PERFECT MATCH")

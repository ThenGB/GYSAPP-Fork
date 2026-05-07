import json
import sqlite3

# Verify JSON counts
for code in ['kr', 'hymne', 'mdr', 'asm_i', 'asm_m', 'asm_p']:
    with open(f'assets/data/index/{code}_index.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    print(f'{code.upper()}: {len(data)} songs in JSON')

# Check HYMNE 417
with open('assets/data/index/hymne_index.json', 'r', encoding='utf-8') as f:
    hymne = json.load(f)
entries = [s for s in hymne if s['number'] == '417']
print(f'\nHYMNE 417 entries: {len(entries)}')
for e in entries:
    print(f'  {e["number"]} - {e["title"]}')

# Compare with DB
conn = sqlite3.connect('assets/data/song.db')
conn.row_factory = sqlite3.Row
cursor = conn.cursor()

print('\n--- Database vs JSON comparison ---')
for code in ['KR', 'HYMNE', 'MDR', 'ASM-I', 'ASM-M', 'ASM-P']:
    cursor.execute('SELECT number, lyric FROM lyric WHERE code=? AND seq=0 ORDER BY rowid', (code,))
    db_entries = [(r['number'], r['lyric']) for r in cursor.fetchall()]
    
    fname = f'assets/data/index/{code.lower().replace("-", "_")}_index.json'
    with open(fname, 'r', encoding='utf-8') as f:
        json_entries = json.load(f)
    
    db_count = len(db_entries)
    json_count = len(json_entries)
    
    if db_count != json_count:
        print(f'{code}: MISMATCH! DB={db_count} JSON={json_count}')
    else:
        print(f'{code}: MATCH ({db_count} songs)')

conn.close()

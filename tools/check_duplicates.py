import sqlite3

conn = sqlite3.connect('assets/data/song.db')
conn.row_factory = sqlite3.Row
cursor = conn.cursor()

# Check HYMNE 417 duplicates
cursor.execute("SELECT number, number2, lyric FROM lyric WHERE code='HYMNE' AND seq=0 AND number='417'")
print('HYMNE 417 entries:')
for row in cursor.fetchall():
    print(f"  number={row['number']} number2={row['number2']} title={row['lyric']}")

# Total rows per code (including duplicates)
for code in ['KR','HYMNE','MDR','ASM-I','ASM-M','ASM-P']:
    cursor.execute('SELECT COUNT(*) FROM lyric WHERE code=? AND seq=0', (code,))
    total = cursor.fetchone()[0]
    cursor.execute('SELECT COUNT(DISTINCT number) FROM lyric WHERE code=? AND seq=0', (code,))
    distinct = cursor.fetchone()[0]
    print(f"{code}: total={total} distinct={distinct}")

conn.close()

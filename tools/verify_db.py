import sqlite3

conn = sqlite3.connect('assets/data/song.db')
cursor = conn.cursor()

cursor.execute("SELECT DISTINCT code FROM lyric WHERE code IS NOT NULL ORDER BY code")
print('Codes:', [r[0] for r in cursor.fetchall()])

for code in ['KR','HYMNE','MDR','ASM-I','ASM-M','ASM-P']:
    cursor.execute('SELECT COUNT(DISTINCT number) FROM lyric WHERE code=? AND seq=0', (code,))
    count = cursor.fetchone()[0]
    print(f'  {code}: {count}')

conn.close()

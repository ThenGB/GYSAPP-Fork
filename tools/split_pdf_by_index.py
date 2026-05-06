#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Split combined PDFs (MDR, ASM) into per-song PDFs using SQLite index data."""

import sys
import sqlite3
from pathlib import Path
import fitz

sys.stdout.reconfigure(encoding='utf-8')

DB_PATH = Path("assets/data/song.db")
OUTPUT_BASE = Path("assets/data/pdf")

BOOKS = {
    'MDR': {'input': 'assets/data/songs/MDR.pdf', 'output': 'mdr'},
    'ASM-I': {'input': 'assets/data/songs/ASM-I.pdf', 'output': 'asm_i'},
    'ASM-M': {'input': 'assets/data/songs/ASM-M.pdf', 'output': 'asm_m'},
    'ASM-P': {'input': 'assets/data/songs/ASM-P.pdf', 'output': 'asm_p'},
}

def sanitize_filename(title):
    import re
    sanitized = re.sub(r'[^\w\s\-\']', '', title)
    sanitized = sanitized.replace(' ', '_')
    return sanitized

def main():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    for code, config in BOOKS.items():
        input_path = Path(config['input'])
        output_dir = OUTPUT_BASE / config['output']
        output_dir.mkdir(parents=True, exist_ok=True)
        
        if not input_path.exists():
            print(f"Skipping {code}: {input_path} not found")
            continue
        
        print(f"\nProcessing {code}...")
        doc = fitz.open(input_path)
        total_pages = len(doc)
        print(f"  Total pages: {total_pages}")
        
        cursor.execute(
            "SELECT number, lyric, page, pages FROM lyric WHERE code = ? AND seq = 0 ORDER BY number",
            (code,)
        )
        songs = cursor.fetchall()
        
        print(f"  Songs to extract: {len(songs)}")
        
        extracted = 0
        skipped = 0
        for number, title, page_start, page_count in songs:
            if page_start is None or page_count is None or page_count <= 0:
                skipped += 1
                continue
            
            start_idx = page_start - 1
            end_idx = start_idx + page_count
            
            if start_idx < 0 or end_idx > total_pages:
                print(f"  Warning: {code} {number} page range {start_idx}-{end_idx} out of bounds {total_pages}")
                skipped += 1
                continue
            
            try:
                new_doc = fitz.open()
                for i in range(start_idx, end_idx):
                    new_doc.insert_pdf(doc, from_page=i, to_page=i)
                
                sanitized = sanitize_filename(title or '')
                output_name = f"{number}_{sanitized}.pdf"
                output_path = output_dir / output_name
                new_doc.save(output_path)
                new_doc.close()
                extracted += 1
            except Exception as e:
                print(f"  Error extracting {code} {number}: {e}")
                skipped += 1
        
        doc.close()
        print(f"  Done! Extracted {extracted}, skipped {skipped} from {code}")
    
    conn.close()
    print("\nAll PDFs split successfully!")

if __name__ == "__main__":
    main()

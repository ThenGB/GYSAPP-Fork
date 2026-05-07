#!/usr/bin/env python3
"""Export SQLite song.db to JSON index files for each book code.
Generates mapping for MIDI references, including MDR cross-references."""

import sqlite3
import json
import re
import os
from pathlib import Path

DB_PATH = Path("assets/data/song.db")
OUTPUT_DIR = Path("assets/data/index")

def sanitize_filename(title):
    """Sanitize title for use in filenames (matches gyschordweb convention)."""
    sanitized = re.sub(r'[^\w\s\-\']', '', title)
    sanitized = sanitized.replace(' ', '_')
    return sanitized

def get_midi_filename(number, title):
    """Generate MIDI filename matching gyschordweb convention."""
    sanitized = sanitize_filename(title)
    return f"{number}_{sanitized}.mid"

def get_pdf_filename(number, title):
    """Generate PDF filename matching gyschordweb convention."""
    sanitized = sanitize_filename(title)
    return f"{number}_{sanitized}.pdf"

def get_chord_filename(number, title):
    """Generate chord filename matching gyschordweb convention."""
    sanitized = sanitize_filename(title)
    return f"{number}_{sanitized}.chord.json"

def parse_mdr_kr_reference(title):
    """Parse KR reference from MDR title, e.g. '歸家 (456)' -> '456'."""
    refs = re.findall(r'\((\d+)[^\)]*\)', title)
    if refs:
        return refs[-1].zfill(3)
    return None

def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    # Get all book codes
    cursor.execute("SELECT DISTINCT code FROM lyric WHERE code IS NOT NULL ORDER BY code")
    book_codes = [row['code'] for row in cursor.fetchall()]
    
    print(f"Found book codes: {book_codes}")
    
    master_index = {}
    
    for code in book_codes:
        print(f"\nProcessing {code}...")
        
        # Get title rows (seq=0)
        cursor.execute(
            "SELECT number, number2, lyric, song, page, pages FROM lyric WHERE code = ? AND seq = 0 ORDER BY number",
            (code,)
        )
        songs_meta = cursor.fetchall()
        
        # Get all verses
        cursor.execute(
            "SELECT number, seq, lyric FROM lyric WHERE code = ? AND seq > 0 ORDER BY number, seq",
            (code,)
        )
        verses_raw = cursor.fetchall()
        
        # Group verses by number
        verses_by_number = {}
        for v in verses_raw:
            num = v['number']
            if num not in verses_by_number:
                verses_by_number[num] = []
            verses_by_number[num].append(v['lyric'])
        
        songs = []
        for meta in songs_meta:
            number = meta['number']
            title = meta['lyric'] or ''
            
            # Determine MIDI mapping
            has_midi = False
            midi_file = None
            midi_mapped_from = None
            midi_mapped_number = None
            
            if code == 'KR':
                # KR has direct MIDI files
                midi_file = f"midi/kr/{get_midi_filename(number, title)}"
                has_midi = True
                midi_mapped_from = 'kr'
                midi_mapped_number = number
            elif code in ('HYMNE', 'MDR'):
                # HYMNE and MDR map to KR MIDI
                kr_number = number
                
                if code == 'MDR':
                    # Check for explicit KR reference in title
                    ref = parse_mdr_kr_reference(title)
                    if ref:
                        kr_number = ref
                
                # Get KR title for the referenced number to build correct filename
                cursor.execute(
                    "SELECT lyric FROM lyric WHERE code = 'KR' AND seq = 0 AND number = ?",
                    (kr_number,)
                )
                kr_row = cursor.fetchone()
                if kr_row:
                    kr_title = kr_row['lyric'] or ''
                    midi_file = f"midi/kr/{get_midi_filename(kr_number, kr_title)}"
                    has_midi = True
                    midi_mapped_from = 'kr'
                    midi_mapped_number = kr_number
            # ASM has no MIDI
            
            # PDF file path
            pdf_file = f"pdf/{code.lower().replace('-', '_')}/{get_pdf_filename(number, title)}"
            
            # Chord file path (only KR has chord data)
            chord_file = None
            has_chord = False
            if code == 'KR':
                chord_file = f"chord/kr/{get_chord_filename(number, title)}"
                # Will check if file actually exists later
                has_chord = True
            
            song_entry = {
                "number": number,
                "number2": meta['number2'],
                "title": title,
                "verses": verses_by_number.get(number, []),
                "pdfFile": pdf_file,
                "hasMidi": has_midi,
                "midiFile": midi_file,
                "midiMappedFrom": midi_mapped_from,
                "midiMappedNumber": midi_mapped_number,
                "hasChord": has_chord,
                "chordFile": chord_file,
                "page": meta['page'],
                "pages": meta['pages'],
                "song": meta['song']  # Original MP3 reference (for backward compat)
            }
            songs.append(song_entry)
        
        # Write book index
        output_file = OUTPUT_DIR / f"{code.lower().replace('-', '_')}_index.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(songs, f, ensure_ascii=False, indent=2)
        
        master_index[code] = {
            "code": code,
            "songCount": len(songs),
            "hasMidi": code in ('KR', 'HYMNE', 'MDR'),
            "indexFile": str(output_file.relative_to(Path("assets")))
        }
        
        print(f"  Written {len(songs)} songs to {output_file}")
    
    # Write master index
    master_file = OUTPUT_DIR / "master_index.json"
    with open(master_file, 'w', encoding='utf-8') as f:
        json.dump(master_index, f, ensure_ascii=False, indent=2)
    
    print(f"\nMaster index written to {master_file}")
    conn.close()

if __name__ == "__main__":
    main()

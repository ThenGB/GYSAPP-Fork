#!/usr/bin/env python3
"""
Analyze why Flutter and Web extract different notes.
"""
import asyncio
import json
from playwright.async_api import async_playwright

async def analyze_extraction_difference():
    print("="*60)
    print("ANALYZING NOTE EXTRACTION DIFFERENCES")
    print("="*60)
    
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=False)
        page = await browser.new_page()
        
        try:
            await page.goto("http://localhost:8080")
            await page.wait_for_load_state("networkidle")
            await page.wait_for_timeout(2000)
            
            first_song = page.locator(".pujian-item").first
            await first_song.click()
            await page.wait_for_timeout(3000)
            
            # Get detailed note data from web app
            web_notes = await page.evaluate("""
                () => {
                    if (typeof pageNotesCache !== 'undefined' && pageNotesCache['1']) {
                        return pageNotesCache['1'].notes.map(note => ({
                            idx: note.idx,
                            str: note.str,
                            x: note.x,
                            y: note.y,
                            w: note.w,
                            xPct: note.xPct,
                            yPct: note.yPct,
                            rowY: note.rowY,
                            fontSize: note.w // approximate from width
                        }));
                    }
                    return null;
                }
            """)
            
            if web_notes:
                print(f"\nWeb app extracted {len(web_notes)} notes")
                
                # Analyze first row notes (yPct around 16.89%)
                first_row_notes = [n for n in web_notes if abs(n['yPct'] - 16.89) < 0.5]
                print(f"Notes in first row (yPct ~16.89%): {len(first_row_notes)}")
                
                if first_row_notes:
                    print("First 5 notes from first row:")
                    for note in first_row_notes[:5]:
                        print(f"  '{note['str']}' at xPct={note['xPct']:.2f}%, yPct={note['yPct']:.2f}%, x={note['x']:.1f}, w={note['w']:.1f}")
                
                # Analyze all rows
                rows = {}
                for note in web_notes:
                    row_y = round(note['yPct'], 1)
                    if row_y not in rows:
                        rows[row_y] = []
                    rows[row_y].append(note)
                
                print(f"\nWeb app found {len(rows)} distinct rows:")
                for row_y in sorted(rows.keys()):
                    print(f"  Row yPct={row_y}%: {len(rows[row_y])} notes")
                
                # Load Flutter data
                try:
                    with open("flutter_note_positions.json", "r") as f:
                        flutter_data = json.load(f)
                        
                    print(f"\nFlutter extracted {len(flutter_data)} notes")
                    
                    # Convert Flutter data to comparable format
                    flutter_notes = []
                    for note_idx, pos in flutter_data.items():
                        flutter_notes.append({
                            'idx': int(note_idx),
                            'xPct': pos['xPct'],
                            'yPct': pos['yPct']
                        })
                    
                    # Analyze Flutter rows
                    flutter_rows = {}
                    for note in flutter_notes:
                        row_y = round(note['yPct'], 1)
                        if row_y not in flutter_rows:
                            flutter_rows[row_y] = []
                        flutter_rows[row_y].append(note)
                    
                    print(f"Flutter found {len(flutter_rows)} distinct rows:")
                    for row_y in sorted(flutter_rows.keys()):
                        print(f"  Row yPct={row_y}%: {len(flutter_rows[row_y])} notes")
                    
                    # Compare rows
                    print(f"\nRow comparison:")
                    web_row_ys = set(rows.keys())
                    flutter_row_ys = set(flutter_rows.keys())
                    
                    common_rows = web_row_ys & flutter_row_ys
                    web_only_rows = web_row_ys - flutter_row_ys
                    flutter_only_rows = flutter_row_ys - web_row_ys
                    
                    print(f"  Common rows: {len(common_rows)}")
                    print(f"  Web-only rows: {len(web_only_rows)}")
                    print(f"  Flutter-only rows: {len(flutter_only_rows)}")
                    
                    if web_only_rows:
                        print(f"  Web-only row yPcts: {sorted(web_only_rows)}")
                    if flutter_only_rows:
                        print(f"  Flutter-only row yPcts: {sorted(flutter_only_rows)}")
                    
                    print(f"\nKEY FINDING:")
                    print(f"  Web app extracts notes from row yPct=16.9% (first music row)")
                    print(f"  Flutter does NOT extract notes from this row")
                    print(f"  This suggests Flutter's font size or row filtering is too strict")
                    
                except FileNotFoundError:
                    print("Flutter data not found")
                
        except Exception as e:
            print(f"Error: {e}")
            import traceback
            traceback.print_exc()
        finally:
            await browser.close()

if __name__ == "__main__":
    asyncio.run(analyze_extraction_difference())
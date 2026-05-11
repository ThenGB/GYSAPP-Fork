#!/usr/bin/env python3
"""
Analyze xPct offset pattern across all rows.
"""
import json
import asyncio
from playwright.async_api import async_playwright

async def analyze_xpct_offset():
    # Load Flutter data
    with open("flutter_note_positions.json", "r") as f:
        flutter_data = json.load(f)
    
    # Get Web data
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
            
            web_notes = await page.evaluate("""
                () => {
                    if (typeof pageNotesCache !== 'undefined' && pageNotesCache['1']) {
                        return pageNotesCache['1'].notes;
                    }
                    return null;
                }
            """)
            
            if web_notes:
                # Group web notes by yPct
                web_rows = {}
                for note in web_notes:
                    row_y = round(note['yPct'], 1)
                    if row_y not in web_rows:
                        web_rows[row_y] = []
                    web_rows[row_y].append(note)
                
                # Group Flutter notes by yPct
                flutter_rows = {}
                for note_idx, pos in flutter_data.items():
                    row_y = round(pos['yPct'], 1)
                    if row_y not in flutter_rows:
                        flutter_rows[row_y] = []
                    flutter_rows[row_y].append({
                        'idx': int(note_idx),
                        'xPct': pos['xPct'],
                        'yPct': pos['yPct']
                    })
                
                # Compare common rows
                common_rows = set(web_rows.keys()) & set(flutter_rows.keys())
                print(f"Common rows: {len(common_rows)}")
                
                offsets = []
                for row_y in sorted(common_rows):
                    web_row_notes = sorted(web_rows[row_y], key=lambda n: n['xPct'])
                    flutter_row_notes = sorted(flutter_rows[row_y], key=lambda n: n['xPct'])
                    
                    min_len = min(len(web_row_notes), len(flutter_row_notes))
                    for i in range(min_len):
                        web_note = web_row_notes[i]
                        flutter_note = flutter_row_notes[i]
                        offset = flutter_note['xPct'] - web_note['xPct']
                        offsets.append(offset)
                
                if offsets:
                    avg_offset = sum(offsets) / len(offsets)
                    min_offset = min(offsets)
                    max_offset = max(offsets)
                    
                    print(f"xPct offset analysis:")
                    print(f"  Average offset: {avg_offset:.2f}%")
                    print(f"  Min offset: {min_offset:.2f}%")
                    print(f"  Max offset: {max_offset:.2f}%")
                    print(f"  Std deviation: {(sum((o - avg_offset) ** 2 for o in offsets) / len(offsets)) ** 0.5:.2f}%")
                    
                    if abs(avg_offset) < 1.0:
                        print(f"\n[OK] Average offset is small (<1%)")
                    else:
                        print(f"\n[WARN] Average offset is significant: {avg_offset:.2f}%")
                        print(f"Consider applying correction factor to Flutter xPct calculation")
                
        except Exception as e:
            print(f"Error: {e}")
        finally:
            await browser.close()

if __name__ == "__main__":
    asyncio.run(analyze_xpct_offset())
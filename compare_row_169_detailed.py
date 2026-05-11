#!/usr/bin/env python3
"""
Compare note indices in row yPct=16.9% between Web and Flutter.
"""
import json
import asyncio
from playwright.async_api import async_playwright

async def compare_row_169():
    # Load Flutter data
    with open("flutter_note_positions.json", "r") as f:
        flutter_data = json.load(f)
    
    # Get Flutter notes in row 16.9%
    flutter_row_169 = []
    for note_idx, pos in flutter_data.items():
        if abs(pos['yPct'] - 16.9) < 0.5:
            flutter_row_169.append({
                'idx': int(note_idx),
                'xPct': pos['xPct'],
                'yPct': pos['yPct']
            })
    
    print(f"Flutter notes in row 16.9%: {len(flutter_row_169)}")
    flutter_row_169.sort(key=lambda x: x['xPct'])
    print("Flutter notes (sorted by xPct):")
    for note in flutter_row_169:
        print(f"  Note {note['idx']}: xPct={note['xPct']:.2f}%")
    
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
                web_row_169 = []
                for note in web_notes:
                    if abs(note['yPct'] - 16.89) < 0.5:
                        web_row_169.append(note)
                
                print(f"\nWeb notes in row 16.9%: {len(web_row_169)}")
                web_row_169.sort(key=lambda x: x['xPct'])
                print("Web notes (sorted by xPct):")
                for note in web_row_169:
                    print(f"  Note {note['idx']}: '{note['str']}' xPct={note['xPct']:.2f}%")
                
                # Compare positions
                print(f"\nPosition comparison:")
                for i in range(min(len(flutter_row_169), len(web_row_169))):
                    flutter_note = flutter_row_169[i]
                    web_note = web_row_169[i]
                    x_diff = abs(flutter_note['xPct'] - web_note['xPct'])
                    print(f"  Position {i}: Flutter xPct={flutter_note['xPct']:.2f}%, Web xPct={web_note['xPct']:.2f}%, Diff={x_diff:.2f}%")
                    
                    if x_diff < 0.5:
                        print(f"    [OK] Positions match!")
                    else:
                        print(f"    [WARN] Positions differ")
                
        except Exception as e:
            print(f"Error: {e}")
        finally:
            await browser.close()

if __name__ == "__main__":
    asyncio.run(compare_row_169())

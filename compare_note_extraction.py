#!/usr/bin/env python3
"""
Compare note extraction results between web and Flutter.
"""
import json
import asyncio
from playwright.async_api import async_playwright

async def compare_note_extraction():
    print("="*60)
    print("NOTE EXTRACTION COMPARISON: Web vs Flutter")
    print("="*60)
    
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=False)
        page = await browser.new_page()
        
        try:
            await page.goto("http://localhost:8080")
            await page.wait_for_load_state("networkidle")
            await page.wait_for_timeout(2000)
            
            # Load first song
            first_song = page.locator(".pujian-item").first
            await first_song.click()
            await page.wait_for_timeout(3000)
            
            # Get note positions from web app
            web_notes = await page.evaluate("""
                () => {
                    if (typeof pageNotesCache !== 'undefined' && pageNotesCache['1']) {
                        return pageNotesCache['1'].notes;
                    }
                    return null;
                }
            """)
            
            if web_notes:
                print(f"\nWeb app extracted {len(web_notes)} notes")
                print("First 10 web notes:")
                for i, note in enumerate(web_notes[:10]):
                    print(f"  Note {i}: '{note['str']}' at xPct={note['xPct']:.2f}%, yPct={note['yPct']:.2f}%")
                
                # Load Flutter test results
                try:
                    with open("flutter_note_positions.json", "r") as f:
                        flutter_data = json.load(f)
                        print(f"\nFlutter extracted {len(flutter_data)} notes")
                        print("First 10 Flutter notes:")
                        for i in range(min(10, len(flutter_data))):
                            note = flutter_data[str(i)]
                            print(f"  Note {i}: xPct={note['xPct']:.2f}%, yPct={note['yPct']:.2f}%")
                except FileNotFoundError:
                    print("\nFlutter note positions not found")
                    print("Run the Flutter test first to generate comparison data")
                
                print(f"\nDifference: Web {len(web_notes)} notes vs Flutter {len(flutter_data) if 'flutter_data' in locals() else 0} notes")
                
            else:
                print("Could not extract web note positions")
                
        except Exception as e:
            print(f"Error: {e}")
        finally:
            await browser.close()

if __name__ == "__main__":
    asyncio.run(compare_note_extraction())

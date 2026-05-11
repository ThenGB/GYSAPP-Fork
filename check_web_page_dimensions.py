#!/usr/bin/env python3
"""
Check web app PDF page dimensions.
"""
import asyncio
from playwright.async_api import async_playwright

async def check_web_dimensions():
    print("="*60)
    print("WEB APP PDF PAGE DIMENSIONS")
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
            
            # Get PDF page dimensions from web app
            pdf_info = await page.evaluate("""
                () => {
                    if (typeof pageNotesCache !== 'undefined' && pageNotesCache['1']) {
                        return {
                            pageWidth: pageNotesCache['1'].pageWidth,
                            pageHeight: pageNotesCache['1'].pageHeight,
                            notesCount: pageNotesCache['1'].notes.length
                        };
                    }
                    return null;
                }
            """)
            
            if pdf_info:
                print(f"Web app PDF dimensions:")
                print(f"  Width: {pdf_info['pageWidth']} points")
                print(f"  Height: {pdf_info['pageHeight']} points")
                print(f"  Notes extracted: {pdf_info['notesCount']}")
                
                print(f"\nComparison with Flutter:")
                print(f"  Flutter: 425.16 x 651.96 points")
                print(f"  Web: {pdf_info['pageWidth']} x {pdf_info['pageHeight']} points")
                
                width_diff = abs(pdf_info['pageWidth'] - 425.16)
                height_diff = abs(pdf_info['pageHeight'] - 651.96)
                
                print(f"  Width difference: {width_diff:.2f} points")
                print(f"  Height difference: {height_diff:.2f} points")
                
                if width_diff > 10 or height_diff > 10:
                    print(f"\n[ERROR] Page dimensions differ significantly!")
                    print(f"This will cause positioning discrepancies")
                else:
                    print(f"\n[OK] Page dimensions are similar")
                
        except Exception as e:
            print(f"Error: {e}")
        finally:
            await browser.close()

if __name__ == "__main__":
    asyncio.run(check_web_dimensions())
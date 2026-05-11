"""
Test script to understand gyschordweb edit mode and note detection
"""
import asyncio
from playwright.async_api import async_playwright
import json

async def test_web_edit_mode():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=False)
        page = await browser.new_page()
        
        try:
            # Navigate to the web app
            await page.goto('http://localhost:8080')
            await page.wait_for_load_state('networkidle')
            
            print("Page loaded, waiting for content...")
            await asyncio.sleep(3)
            
            # Try to find and click on a song to open PDF viewer
            print("Looking for song items...")
            
            # Try to find song links or buttons
            song_items = await page.query_selector_all('.song-item, a[href*="pdf"], .pujian-item')
            print(f"Found {len(song_items)} potential song items")
            
            if len(song_items) > 0:
                # Click the first song
                await song_items[0].click()
                print("Clicked on first song")
                await asyncio.sleep(3)
                
                # Check if PDF viewer is active
                viewer_active = await page.evaluate('() => document.body.classList.contains("viewer-active")')
                print(f"PDF viewer active: {viewer_active}")
                
                if viewer_active:
                    # Try to enable edit mode by tapping title multiple times
                    print("Attempting to enable edit mode...")
                    
                    # Find the title element
                    title_element = await page.query_selector('.song-title, h1, .title')
                    if title_element:
                        print("Found title element, tapping 10 times...")
                        for i in range(10):
                            await title_element.click()
                            await asyncio.sleep(0.1)
                        
                        await asyncio.sleep(2)
                        
                        # Check if edit mode is enabled
                        edit_mode_enabled = await page.evaluate('() => typeof chordEditorEnabled !== "undefined" && chordEditorEnabled')
                        print(f"Edit mode enabled: {edit_mode_enabled}")
                        
                        if edit_mode_enabled:
                            # Look for note targets
                            print("Looking for note targets...")
                            note_targets = await page.query_selector_all('.note-target')
                            print(f"Found {len(note_targets)} note targets")
                            
                            if len(note_targets) > 0:
                                # Get information about first few note targets
                                for i, target in enumerate(note_targets[:5]):
                                    note_idx = await target.get_attribute('data-note-idx')
                                    text_content = await target.text_content()
                                    style = await target.get_attribute('style')
                                    print(f"Note target {i}: idx={note_idx}, text='{text_content}', style={style}")
                            else:
                                print("No note targets found - checking for chord layer...")
                                chord_layer = await page.query_selector('.chord-layer')
                                if chord_layer:
                                    print("Chord layer exists but no note targets - edit mode might work differently")
                                    # Check if there are chord markers
                                    chord_markers = await page.query_selector_all('.chord-marker, .note-chord-marker')
                                    print(f"Found {len(chord_markers)} chord markers")
                        else:
                            print("Failed to enable edit mode - trying alternative method")
                            # Try to find edit button
                            edit_button = await page.query_selector('button[title*="edit"], .edit-button, #edit-mode-toggle')
                            if edit_button:
                                await edit_button.click()
                                await asyncio.sleep(2)
                                print("Clicked edit button")
                    else:
                        print("Could not find title element")
                else:
                    print("PDF viewer not active, trying alternative approach")
                    # Try to directly access a PDF
                    await page.goto('http://localhost:8080/assets/pdf/sample.pdf')
                    await asyncio.sleep(3)
            else:
                print("No song items found, checking page structure...")
                page_content = await page.content()
                print(f"Page content length: {len(page_content)}")
                
                # Save page content for inspection
                with open('web_page_structure.html', 'w', encoding='utf-8') as f:
                    f.write(page_content)
                print("Page structure saved to web_page_structure.html")
                
        except Exception as e:
            print(f"Error: {e}")
            import traceback
            traceback.print_exc()
        
        await asyncio.sleep(5)
        await browser.close()

if __name__ == '__main__':
    asyncio.run(test_web_edit_mode())
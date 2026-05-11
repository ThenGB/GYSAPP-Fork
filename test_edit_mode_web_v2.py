"""
Test script to understand gyschordweb edit mode and note detection
"""
import asyncio
from playwright.async_api import async_playwright
import json

async def test_web_edit_mode():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=False, slow_mo=1000)
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
                await asyncio.sleep(5)
                
                # Check if PDF viewer is active
                viewer_active = await page.evaluate('() => document.body.classList.contains("viewer-active")')
                print(f"PDF viewer active: {viewer_active}")
                
                if viewer_active:
                    # Take a screenshot to see the current state
                    await page.screenshot(path='web_viewer_state.png')
                    print("Screenshot saved to web_viewer_state.png")
                    
                    # Try to enable edit mode via JavaScript
                    print("Attempting to enable edit mode via JavaScript...")
                    edit_enabled = await page.evaluate('''
                        () => {
                            if (typeof chordEditorEnabled !== 'undefined') {
                                chordEditorEnabled = true;
                                return true;
                            }
                            return false;
                        }
                    ''')
                    print(f"Edit mode enabled via JS: {edit_enabled}")
                    
                    if edit_enabled:
                        await asyncio.sleep(2)
                        
                        # Force re-render to show edit mode elements
                        await page.evaluate('''
                            () => {
                                if (typeof renderPage === 'function') {
                                    renderPage(currentPageNum);
                                }
                            }
                        ''')
                        await asyncio.sleep(3)
                        
                        # Look for note targets
                        print("Looking for note targets after re-render...")
                        note_targets = await page.query_selector_all('.note-target')
                        print(f"Found {len(note_targets)} note targets")
                        
                        if len(note_targets) > 0:
                            # Get information about first few note targets
                            for i, target in enumerate(note_targets[:10]):
                                note_idx = await target.get_attribute('data-note-idx')
                                text_content = await target.text_content()
                                style = await target.get_attribute('style')
                                left = style.split('left:')[1].split('%')[0] if 'left:' in style else 'N/A'
                                top = style.split('top:')[1].split('%')[0] if 'top:' in style else 'N/A'
                                # Handle Unicode characters safely
                                safe_text = text_content.encode('ascii', 'replace').decode('ascii')
                                print(f"Note target {i}: idx={note_idx}, text='{safe_text}', left={left}%, top={top}%")
                                
                                # Check if it has a chord
                                has_chord_class = await target.evaluate('el => el.classList.contains("has-chord")')
                                print(f"  Has chord: {has_chord_class}")
                        else:
                            print("No note targets found - checking page structure...")
                            # Get the chord layer HTML
                            chord_layer = await page.query_selector('.chord-layer')
                            if chord_layer:
                                chord_html = await chord_layer.inner_html()
                                print(f"Chord layer HTML length: {len(chord_html)}")
                                
                                # Save to file for inspection
                                with open('chord_layer.html', 'w', encoding='utf-8') as f:
                                    f.write(chord_html)
                                print("Chord layer HTML saved to chord_layer.html")
                                
                                # Check for existing chords
                                chord_markers = await page.query_selector_all('.chord-marker, .note-chord-marker')
                                print(f"Found {len(chord_markers)} chord markers")
                                
                                if len(chord_markers) > 0:
                                    for i, marker in enumerate(chord_markers[:5]):
                                        note_idx = await marker.get_attribute('data-note-idx')
                                        chord_text = await marker.text_content()
                                        print(f"Chord marker {i}: idx={note_idx}, chord='{chord_text}'")
                        
                        # Take another screenshot after edit mode
                        await page.screenshot(path='web_edit_mode_state.png')
                        print("Screenshot saved to web_edit_mode_state.png")
                    else:
                        print("Could not enable edit mode via JavaScript")
                        # Try to find the actual function
                        js_functions = await page.evaluate('''
                            () => {
                                return Object.keys(window).filter(key => key.includes('edit') || key.includes('Edit') || key.includes('chord'));
                            }
                        ''')
                        print(f"Relevant JS functions: {js_functions}")
                else:
                    print("PDF viewer not active")
            else:
                print("No song items found")
                
        except Exception as e:
            print(f"Error: {e}")
            import traceback
            traceback.print_exc()
        
        await asyncio.sleep(5)
        await browser.close()

if __name__ == '__main__':
    asyncio.run(test_web_edit_mode())
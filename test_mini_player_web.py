"""
Test script to understand gyschordweb mini player implementation
"""
import asyncio
from playwright.async_api import async_playwright
import json

async def test_mini_player():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=False, slow_mo=500)
        page = await browser.new_page()
        
        try:
            # Navigate to the web app
            await page.goto('http://localhost:8080')
            await page.wait_for_load_state('networkidle')
            
            print("Page loaded, waiting for content...")
            await asyncio.sleep(3)
            
            # Look for mini player elements
            print("Looking for mini player elements...")
            
            # Check for mini player container
            mini_player = await page.query_selector('#mini-player, .mini-player, [class*="mini"][class*="player"]')
            if mini_player:
                print("[OK] Found mini player container")
                
                # Get mini player HTML structure
                mini_html = await mini_player.inner_html()
                print(f"Mini player HTML length: {len(mini_html)}")
                
                # Save to file for inspection
                with open('mini_player_structure.html', 'w', encoding='utf-8') as f:
                    f.write(mini_html)
                print("Mini player structure saved to mini_player_structure.html")
                
                # Get mini player classes
                classes = await mini_player.get_attribute('class')
                print(f"Mini player classes: {classes}")
                
                # Check if it's visible
                is_visible = await mini_player.is_visible()
                print(f"Mini player visible: {is_visible}")
                
                # Look for play/pause buttons
                play_button = await mini_player.query_selector('button[title*="play"], .play-button, #play, [class*="play"]')
                pause_button = await mini_player.query_selector('button[title*="pause"], .pause-button, #pause, [class*="pause"]')
                stop_button = await mini_player.query_selector('button[title*="stop"], .stop-button, #stop, [class*="stop"]')
                
                print(f"Play button found: {play_button is not None}")
                print(f"Pause button found: {pause_button is not None}")
                print(f"Stop button found: {stop_button is not None}")
                
                # Look for progress bar
                progress_bar = await mini_player.query_selector('[class*="progress"], [class*="seek"], input[type="range"]')
                if progress_bar:
                    print("[OK] Found progress bar")
                    progress_type = await progress_bar.get_attribute('type')
                    print(f"Progress bar type: {progress_type}")
                
                # Look for time display
                time_display = await mini_player.query_selector('[class*="time"], .time-display, [class*="duration"]')
                if time_display:
                    print("[OK] Found time display")
                    time_text = await time_display.text_content()
                    print(f"Time display text: {time_text}")
                
                # Look for song info
                song_info = await mini_player.query_selector('[class*="song"], [class*="title"], .song-info')
                if song_info:
                    print("[OK] Found song info")
                    song_text = await song_info.text_content()
                    print(f"Song info text: {song_text}")
                    
                # Check for visibility toggle
                is_hidden = await mini_player.evaluate('el => el.classList.contains("is-hidden")')
                print(f"Mini player hidden: {is_hidden}")
                
                # Take screenshot
                await page.screenshot(path='mini_player_state.png', full_page=False)
                print("Screenshot saved to mini_player_state.png")
                
            else:
                print("❌ Mini player container not found")
                print("Looking for alternative mini player selectors...")
                
                # Try broader search
                all_divs = await page.query_selector_all('div')
                print(f"Total divs on page: {len(all_divs)}")
                
                # Look for player-related divs
                player_divs = []
                for div in all_divs[:50]:  # Check first 50 divs
                    classes = await div.get_attribute('class')
                    if classes and ('player' in classes.lower() or 'mini' in classes.lower()):
                        player_divs.append(classes)
                        print(f"Found player-related div: {classes}")
                
                if not player_divs:
                    print("No player-related divs found in first 50 elements")
                    
                    # Check if mini player is in the DOM but hidden
                    mini_player_hidden = await page.query_selector('#mini-player.is-hidden, .mini-player.is-hidden')
                    if mini_player_hidden:
                        print("[OK] Found hidden mini player")
                        # Try to make it visible
                        await page.evaluate('document.getElementById("mini-player").classList.remove("is-hidden")')
                        await asyncio.sleep(1)
                        await page.screenshot(path='mini_player_revealed.png')
                        print("Revealed and screenshot saved")
            
            # Check for MIDI-related functionality
            print("\nChecking for MIDI functionality...")
            midi_enabled = await page.evaluate('''
                () => {
                    return typeof MidiEngine !== 'undefined' || 
                           typeof midiEngine !== 'undefined' ||
                           typeof window.MidiEngine !== 'undefined';
                }
            ''')
            print(f"MIDI engine available: {midi_enabled}")
            
            if midi_enabled:
                # Get MIDI functions
                midi_functions = await page.evaluate('''
                    () => {
                        const midiObj = window.MidiEngine || window.midiEngine;
                        if (midiObj) {
                            return Object.keys(midiObj).filter(key => typeof midiObj[key] === 'function');
                        }
                        return [];
                    }
                ''')
                print(f"MIDI functions available: {midi_functions[:10]}")  # Show first 10
            
            # Check for mini player toggle functionality
            print("\nChecking for mini player toggle...")
            toggle_functions = await page.evaluate('''
                () => {
                    return Object.keys(window).filter(key => 
                        key.toLowerCase().includes('mini') || 
                        key.toLowerCase().includes('player')
                    );
                }
            ''')
            print(f"Mini player related functions: {toggle_functions}")
            
        except Exception as e:
            print(f"Error: {e}")
            import traceback
            traceback.print_exc()
        
        await asyncio.sleep(5)
        await browser.close()

if __name__ == '__main__':
    asyncio.run(test_mini_player())
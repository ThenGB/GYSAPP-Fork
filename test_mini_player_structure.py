"""
Test script to get the actual mini player HTML structure
"""
import asyncio
from playwright.async_api import async_playwright

async def get_mini_player_structure():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=False)
        page = await browser.new_page()
        
        try:
            await page.goto('http://localhost:8080')
            await page.wait_for_load_state('networkidle')
            await asyncio.sleep(3)
            
            # Get the mini player element specifically
            mini_player_html = await page.evaluate('''
                () => {
                    const miniPlayer = document.getElementById('mini-player');
                    if (miniPlayer) {
                        return miniPlayer.outerHTML;
                    }
                    return 'Mini player not found';
                }
            ''')
            
            # Save to file
            with open('mini_player_actual.html', 'w', encoding='utf-8') as f:
                f.write(mini_player_html)
            print("Saved mini player HTML to mini_player_actual.html")
            
            # Get mini player CSS
            mini_player_css = await page.evaluate('''
                () => {
                    const miniPlayer = document.getElementById('mini-player');
                    if (miniPlayer) {
                        const computed = window.getComputedStyle(miniPlayer);
                        return {
                            position: computed.position,
                            bottom: computed.bottom,
                            left: computed.left,
                            right: computed.right,
                            width: computed.width,
                            height: computed.height,
                            zIndex: computed.zIndex,
                            backgroundColor: computed.backgroundColor,
                            display: computed.display
                        };
                    }
                    return null;
                }
            ''')
            
            print("\nMini player CSS styles:")
            print(mini_player_css)
            
        except Exception as e:
            print(f"Error: {e}")
            import traceback
            traceback.print_exc()
        
        await asyncio.sleep(3)
        await browser.close()

if __name__ == '__main__':
    asyncio.run(get_mini_player_structure())
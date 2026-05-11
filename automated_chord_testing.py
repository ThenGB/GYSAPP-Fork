#!/usr/bin/env python3
"""
Automated chord positioning testing script.
Compares web and Flutter implementations to identify discrepancies.
"""
import asyncio
import json
import os
from playwright.async_api import async_playwright
from datetime import datetime

class ChordPositionTester:
    def __init__(self):
        self.web_results = {}
        self.flutter_results = {}
        self.discrepancies = []
        
    async def test_web_app(self, song_indices=[0, 1, 2]):
        """Test the web app implementation for multiple songs."""
        print("Testing Web App...")
        async with async_playwright() as p:
            browser = await p.chromium.launch(headless=False)
            page = await browser.new_page()
            
            try:
                # Navigate to web app
                await page.goto("http://localhost:8080")
                await page.wait_for_load_state("networkidle")
                await page.wait_for_timeout(2000)
                
                self.web_results = {"songs": {}}
                
                for song_idx in song_indices:
                    print(f"  Testing song {song_idx}...")
                    
                    try:
                        # Navigate back to song list if needed
                        if song_idx > 0:
                            await page.goto("http://localhost:8080")
                            await page.wait_for_load_state("networkidle")
                            await page.wait_for_timeout(2000)
                        
                        # Click on the specific song
                        song_items = await page.locator(".pujian-item").all()
                        if song_idx < len(song_items):
                            await song_items[song_idx].click()
                            print(f"    [OK] Loaded song {song_idx} in web app")
                            await page.wait_for_timeout(3000)
                        else:
                            print(f"    [SKIP] Song {song_idx} not found")
                            continue
                        
                        # Extract chord markers
                        chord_markers = await page.locator(".chord-marker").all()
                        print(f"    Found {len(chord_markers)} chord markers")
                        
                        chord_data = []
                        for i, marker in enumerate(chord_markers):
                            bbox = await marker.bounding_box()
                            if bbox:
                                text = await marker.text_content()
                                chord_data.append({
                                    "index": i,
                                    "text": text,
                                    "x": bbox["x"],
                                    "y": bbox["y"],
                                    "width": bbox["width"],
                                    "height": bbox["height"],
                                    "center_x": bbox["x"] + bbox["width"] / 2,
                                    "center_y": bbox["y"] + bbox["height"] / 2
                                })
                        
                        # Extract note positions from internal state
                        note_positions = await page.evaluate("""
                            () => {
                                if (typeof pageNotesCache !== 'undefined') {
                                    return pageNotesCache;
                                }
                                return null;
                            }
                        """)
                        
                        song_info = await page.evaluate("""
                            () => {
                                if (typeof currentSongIndex !== 'undefined' && typeof pujianItems !== 'undefined') {
                                    return {
                                        index: currentSongIndex,
                                        song: pujianItems[currentSongIndex]
                                    };
                                }
                                return null;
                            }
                        """)
                        
                        # Take screenshot
                        screenshot_path = f"web_app_screenshot_song{song_idx}.png"
                        await page.screenshot(path=screenshot_path, full_page=True)
                        print(f"    [OK] Saved screenshot: {screenshot_path}")
                        
                        self.web_results["songs"][str(song_idx)] = {
                            "chord_markers": chord_data,
                            "note_positions": note_positions,
                            "song_info": song_info,
                            "screenshot": screenshot_path,
                            "timestamp": datetime.now().isoformat()
                        }
                        
                        print(f"    [OK] Extracted {len(chord_data)} chord positions")
                        print(f"    [OK] Extracted note positions: {len(note_positions) if note_positions else 0} notes")
                        
                    except Exception as e:
                        print(f"    [ERROR] Error testing song {song_idx}: {e}")
                        self.web_results["songs"][str(song_idx)] = {
                            "error": str(e),
                            "status": "failed"
                        }
                
                self.web_results["status"] = "success"
                self.web_results["timestamp"] = datetime.now().isoformat()
                
            except Exception as e:
                print(f"[ERROR] Web app testing failed: {e}")
                self.web_results = {
                    "status": "error",
                    "error": str(e),
                    "timestamp": datetime.now().isoformat()
                }
            finally:
                await browser.close()
    
    async def test_flutter_app(self):
        """Test the Flutter app implementation."""
        print("Testing Flutter App...")
        
        try:
            # Try to connect to Flutter app via Marionette or Flutter Driver
            # For now, we'll use a simpler approach with manual data collection
            
            # Check if Flutter app is accessible
            print("  Attempting to connect to Flutter app...")
            
            # Since the Flutter app is running in debug mode, we'll collect data
            # by asking the user to provide screenshots or coordinate data
            
            print("  Flutter app is running in debug mode")
            print("  To collect Flutter chord positions, please:")
            print("  1. Navigate to song 001 (Pujilah Allah Yang Maha Esa) in the Flutter app")
            print("  2. Enable chord display")
            print("  3. Take a screenshot or provide coordinate data")
            
            # Placeholder for Flutter results - would be populated with actual data
            self.flutter_results = {
                "status": "awaiting_user_input",
                "message": "Flutter app detected - awaiting coordinate data",
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            print(f"  [ERROR] Flutter app testing failed: {e}")
            self.flutter_results = {
                "status": "error",
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
    
    def compare_results(self):
        """Compare web and Flutter results to find discrepancies."""
        print("\nComparing Results...")
        
        if not self.web_results or not self.flutter_results:
            print("  Cannot compare - missing data from one or both implementations")
            return
        
        # This would be expanded once Flutter testing is implemented
        print("  Comparison logic to be implemented with Flutter data")
    
    def generate_report(self):
        """Generate a detailed report of findings."""
        print("\n" + "="*60)
        print("CHORD POSITIONING TEST REPORT")
        print("="*60)
        print(f"Test Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print()
        
        print("WEB APP RESULTS:")
        if self.web_results:
            if self.web_results.get("status") == "success":
                print(f"  Status: [OK] Success")
                if "songs" in self.web_results:
                    print(f"  Songs Tested: {len(self.web_results['songs'])}")
                    for song_id, song_data in self.web_results["songs"].items():
                        if song_data.get("song_info"):
                            song = song_data["song_info"].get("song", {})
                            chord_count = len(song_data.get("chord_markers", []))
                            note_count = 0
                            if song_data.get("note_positions"):
                                note_count = sum(len(page.get('notes', [])) for page in song_data["note_positions"].values())
                            print(f"    Song {song_id}: {song.get('nomor', 'N/A')} - {song.get('judul', 'N/A')}")
                            print(f"      Chords: {chord_count}, Notes: {note_count}")
            else:
                print(f"  Status: [ERROR] {self.web_results.get('error', 'Unknown error')}")
        else:
            print(f"  Status: No data collected")
        
        print()
        print("FLUTTER APP RESULTS:")
        if self.flutter_results:
            print(f"  Status: {self.flutter_results.get('status', 'Unknown')}")
            if "message" in self.flutter_results:
                print(f"  Message: {self.flutter_results['message']}")
        else:
            print(f"  Status: Not tested")
        
        print()
        print("ANALYSIS:")
        if self.web_results and self.web_results.get("status") == "success":
            if "songs" in self.web_results:
                total_chords = sum(len(song_data.get("chord_markers", [])) for song_data in self.web_results["songs"].values())
                total_notes = 0
                for song_data in self.web_results["songs"].values():
                    if song_data.get("note_positions"):
                        total_notes += sum(len(page.get('notes', [])) for page in song_data["note_positions"].values())
                
                print(f"  Total chords across all songs: {total_chords}")
                print(f"  Total note positions across all songs: {total_notes}")
                print(f"  Average chords per song: {total_chords / len(self.web_results['songs']):.1f}")
                print()
                print("  Web app chord positioning data successfully collected")
                print("  Vertical centering fix applied to Flutter app:")
                print("    - Changed from: FractionalTranslation(Offset(-0.5, 0))")
                print("    - Changed to: FractionalTranslation(Offset(-0.5, -0.5))")
                print("    - This should match web app's transform: translate(-50%, -50%)")
        
        print()
        print("DISCREPANCIES:")
        if self.discrepancies:
            for discrepancy in self.discrepancies:
                print(f"  • {discrepancy}")
        else:
            print("  None identified yet (Flutter data needed for comparison)")
        
        print()
        print("="*60)
        
        # Save detailed report to JSON
        report = {
            "timestamp": datetime.now().isoformat(),
            "web_results": self.web_results,
            "flutter_results": self.flutter_results,
            "discrepancies": self.discrepancies,
            "analysis": {
                "vertical_centering_fix_applied": True,
                "fix_description": "Changed Flutter FractionalTranslation from Offset(-0.5, 0) to Offset(-0.5, -0.5) to match web app's CSS transform: translate(-50%, -50%)"
            }
        }
        
        with open("chord_positioning_report.json", "w") as f:
            json.dump(report, f, indent=2)
        
        print("Detailed report saved to: chord_positioning_report.json")
        print("="*60)

async def main():
    tester = ChordPositionTester()
    
    # Test web app with multiple songs
    print("="*60)
    print("Starting Automated Chord Positioning Tests")
    print("="*60)
    
    await tester.test_web_app(song_indices=[0, 1, 2, 3, 4])  # Test first 5 songs
    
    # Test Flutter app (pending setup)
    await tester.test_flutter_app()
    
    # Compare results
    tester.compare_results()
    
    # Generate report
    tester.generate_report()
    
    print("\n" + "="*60)
    print("Automated Testing Complete")
    print("="*60)
    print("\nNext Steps:")
    print("1. Review the generated report: chord_positioning_report.json")
    print("2. Compare screenshots: web_app_screenshot_song*.png")
    print("3. For Flutter comparison, either:")
    print("   - Provide Flutter app screenshot/coordinate data")
    print("   - Run the Flutter Driver test when ready")
    print("   - Enable debug output in Flutter app for position data")
    print("="*60)

if __name__ == "__main__":
    asyncio.run(main())
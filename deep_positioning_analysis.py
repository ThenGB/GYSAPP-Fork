#!/usr/bin/env python3
"""
Deep analysis of chord positioning logic.
Compares note positions vs chord positions to identify discrepancies.
"""
import asyncio
import json
import os
from playwright.async_api import async_playwright
from datetime import datetime

class DeepPositioningAnalyzer:
    def __init__(self):
        self.analysis_data = {}
        
    async def analyze_web_app_positioning(self):
        """Deep analysis of web app positioning logic."""
        print("Deep Analysis of Web App Positioning...")
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
                
                # Get detailed positioning data
                analysis = await page.evaluate("""
                    () => {
                        const result = {
                            chord_markers: [],
                            note_positions: null,
                            positioning_logic: {}
                        };
                        
                        // Get chord markers with detailed positioning
                        const markers = document.querySelectorAll('.chord-marker');
                        markers.forEach((marker, index) => {
                            const rect = marker.getBoundingClientRect();
                            const computedStyle = window.getComputedStyle(marker);
                            const transform = computedStyle.transform;
                            
                            result.chord_markers.push({
                                index: index,
                                text: marker.textContent,
                                left: rect.left,
                                top: rect.top,
                                width: rect.width,
                                height: rect.height,
                                css_left: marker.style.left,
                                css_top: marker.style.top,
                                css_transform: transform,
                                parent_offset: marker.offsetParent ? {
                                    left: marker.offsetParent.offsetLeft,
                                    top: marker.offsetParent.offsetTop
                                } : null
                            });
                        });
                        
                        // Get note positions
                        if (typeof pageNotesCache !== 'undefined' && pageNotesCache['1']) {
                            result.note_positions = pageNotesCache['1'].notes.slice(0, 10); // First 10 notes
                        }
                        
                        // Get positioning constants
                        result.positioning_logic = {
                            chord_y_offset: typeof NOTE_CHORD_Y_OFFSET_PCT !== 'undefined' ? NOTE_CHORD_Y_OFFSET_PCT : 'not found',
                            chord_marker_css: window.getComputedStyle(markers[0]).cssText
                        };
                        
                        return result;
                    }
                """)
                
                self.analysis_data = analysis
                print(f"  Analyzed {len(analysis['chord_markers'])} chord markers")
                print(f"  Chord Y Offset: {analysis['positioning_logic']['chord_y_offset']}")
                
                # Analyze positioning relationships
                self.analyze_positioning_relationships(analysis)
                
                # Take screenshot
                await page.screenshot(path="deep_analysis_screenshot.png", full_page=True)
                
            except Exception as e:
                print(f"  Error: {e}")
            finally:
                await browser.close()
    
    def analyze_positioning_relationships(self, analysis):
        """Analyze relationships between note positions and chord positions."""
        print("\nPositioning Relationship Analysis:")
        
        if not analysis['note_positions']:
            print("  No note positions available")
            return
        
        chord_markers = analysis['chord_markers']
        note_positions = analysis['note_positions']
        
        print(f"  First 5 chord markers:")
        for i, marker in enumerate(chord_markers[:5]):
            print(f"    Chord {i}: '{marker['text']}' at ({marker['left']:.1f}, {marker['top']:.1f})")
            print(f"      CSS: left={marker['css_left']}, top={marker['css_top']}")
            print(f"      Transform: {marker['css_transform']}")
        
        print(f"\n  First 5 note positions:")
        for i, note in enumerate(note_positions[:5]):
            print(f"    Note {i}: '{note['str']}' at xPct={note['xPct']:.2f}%, yPct={note['yPct']:.2f}%")
        
        # Calculate expected vs actual positioning
        print(f"\n  Positioning Logic Analysis:")
        if note_positions and chord_markers:
            # For each chord, find corresponding note
            for i, chord in enumerate(chord_markers[:3]):
                if i < len(note_positions):
                    note = note_positions[i]
                    expected_y = note['yPct'] - analysis['positioning_logic']['chord_y_offset']
                    print(f"    Chord {i} vs Note {i}:")
                    print(f"      Note yPct: {note['yPct']:.2f}%")
                    print(f"      Expected chord yPct: {expected_y:.2f}%")
                    print(f"      Actual chord top: {chord['top']:.1f}px")
    
    def compare_flutter_implementation(self):
        """Compare with Flutter implementation logic."""
        print("\nFlutter Implementation Analysis:")
        print("  Current Flutter logic:")
        print("    - FractionalTranslation(Offset(-0.5, -0.5))")
        print("    - Y offset applied: pos.yPct - 2.5")
        print("    - Positioning: (pos.yPct - 2.5) / 100.0 * pageSize.height")
        print("    - Then FractionalTranslation centers vertically")
        
        print("\n  Web implementation logic:")
        print("    - CSS transform: translate(-50%, -50%)")
        print("    - Y offset applied: pos.yPct - 2.5")
        print("    - Positioning: top: (pos.yPct - 2.5)%")
        print("    - Then CSS transform centers vertically")
        
        print("\n  Key difference:")
        print("    - Flutter: applies offset, then centers with FractionalTranslation")
        print("    - Web: applies offset in CSS top, then centers with transform")
        print("    - Both should be equivalent, but coordinate systems may differ")

async def main():
    analyzer = DeepPositioningAnalyzer()
    
    print("="*60)
    print("DEEP CHORD POSITIONING ANALYSIS")
    print("="*60)
    
    await analyzer.analyze_web_app_positioning()
    analyzer.compare_flutter_implementation()
    
    # Save analysis
    with open("deep_positioning_analysis.json", "w") as f:
        json.dump(analyzer.analysis_data, f, indent=2)
    
    print("\n" + "="*60)
    print("Analysis complete. Data saved to deep_positioning_analysis.json")
    print("="*60)

if __name__ == "__main__":
    asyncio.run(main())
#!/usr/bin/env python3
"""
Mathematical analysis of positioning calculations.
Compares web vs Flutter positioning formulas.
"""

def analyze_positioning_math():
    print("="*60)
    print("POSITIONING MATHEMATICAL ANALYSIS")
    print("="*60)
    
    # Sample data from web app analysis
    note_y_pct = 16.89  # from web app
    chord_y_offset = 2.5
    page_height = 600  # approximate
    
    print("\nSample Data:")
    print(f"  Note yPct: {note_y_pct}%")
    print(f"  Chord Y Offset: {chord_y_offset}%")
    print(f"  Page Height: {page_height}px")
    
    print("\n" + "-"*60)
    print("WEB APP CALCULATION:")
    print("-"*60)
    
    # Web app calculation
    web_expected_y_pct = note_y_pct - chord_y_offset
    web_top_px = (web_expected_y_pct / 100.0) * page_height
    print(f"1. Apply offset: {note_y_pct}% - {chord_y_offset}% = {web_expected_y_pct}%")
    print(f"2. Convert to pixels: {web_expected_y_pct}% of {page_height}px = {web_top_px}px")
    print(f"3. CSS top: {web_expected_y_pct}%")
    print(f"4. CSS transform: translate(-50%, -50%)")
    print(f"   - This centers the element: moves -50% of element width/height")
    print(f"   - Final position: element center at {web_top_px}px from top")
    
    print("\n" + "-"*60)
    print("FLUTTER CALCULATION:")
    print("-"*60)
    
    # Flutter calculation
    flutter_y = (note_y_pct - chord_y_offset) / 100.0 * page_height
    print(f"1. Apply offset: {note_y_pct}% - {chord_y_offset}% = {note_y_pct - chord_y_offset}%")
    print(f"2. Convert to pixels: {(note_y_pct - chord_y_offset)}% of {page_height}px = {flutter_y}px")
    print(f"3. Positioned top: {flutter_y}px")
    print(f"4. FractionalTranslation(Offset(-0.5, -0.5))")
    print(f"   - This centers the element: moves -50% of element size")
    print(f"   - Final position: element center at {flutter_y}px from top")
    
    print("\n" + "-"*60)
    print("COMPARISON:")
    print("-"*60)
    
    print(f"Web final position: {web_top_px}px (element center)")
    print(f"Flutter final position: {flutter_y}px (element center)")
    print(f"Difference: {abs(web_top_px - flutter_y):.2f}px")
    
    if abs(web_top_px - flutter_y) < 0.1:
        print("[OK] Positioning calculations are EQUIVALENT")
    else:
        print("[ERROR] Positioning calculations DIFFER")
    
    print("\n" + "-"*60)
    print("POTENTIAL ISSUES:")
    print("-"*60)
    
    print("1. Page size differences:")
    print("   - Web: uses actual viewport size")
    print("   - Flutter: uses pageSize from pageRectInViewer")
    print("   - If these differ, positioning will be off")
    
    print("\n2. Coordinate system differences:")
    print("   - Web: CSS percentages relative to container")
    print("   - Flutter: pixels relative to pageSize")
    print("   - Need to ensure pageSize matches web viewport")
    
    print("\n3. Element size differences:")
    print("   - Web: chord badge size determined by CSS")
    print("   - Flutter: chord badge size determined by Flutter widgets")
    print("   - If sizes differ, centering will be off")
    
    print("\n4. PDF rendering differences:")
    print("   - Web: PDF.js rendering")
    print("   - Flutter: pdfrx rendering")
    print("   - Note positions may differ between PDF libraries")
    
    print("\n" + "-"*60)
    print("RECOMMENDED FIXES:")
    print("-"*60)
    
    print("1. Verify pageSize matches web viewport size")
    print("2. Ensure chord badge sizes match between implementations")
    print("3. Add debug logging to compare actual vs expected positions")
    print("4. Test with same PDF file and viewport dimensions")
    print("5. Consider using percentage-based positioning in Flutter too")

if __name__ == "__main__":
    analyze_positioning_math()
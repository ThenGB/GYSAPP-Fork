---
name: Sacred Hymnal Design System
colors:
  surface: '#fff8f7'
  surface-dim: '#edd4d4'
  surface-bright: '#fff8f7'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fff0f0'
  surface-container: '#ffe9e8'
  surface-container-high: '#fbe2e2'
  surface-container-highest: '#f5dddd'
  on-surface: '#251819'
  on-surface-variant: '#584141'
  inverse-surface: '#3b2d2d'
  inverse-on-surface: '#ffedec'
  outline: '#8c7071'
  outline-variant: '#e0bfbf'
  surface-tint: '#af2b3e'
  primary: '#570013'
  on-primary: '#ffffff'
  primary-container: '#800020'
  on-primary-container: '#ff828a'
  inverse-primary: '#ffb3b5'
  secondary: '#735c00'
  on-secondary: '#ffffff'
  secondary-container: '#fed65b'
  on-secondary-container: '#745c00'
  tertiary: '#272821'
  on-tertiary: '#ffffff'
  tertiary-container: '#3d3e36'
  on-tertiary-container: '#a9a99e'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdada'
  primary-fixed-dim: '#ffb3b5'
  on-primary-fixed: '#40000b'
  on-primary-fixed-variant: '#8e0f28'
  secondary-fixed: '#ffe088'
  secondary-fixed-dim: '#e9c349'
  on-secondary-fixed: '#241a00'
  on-secondary-fixed-variant: '#574500'
  tertiary-fixed: '#e4e3d7'
  tertiary-fixed-dim: '#c7c7bc'
  on-tertiary-fixed: '#1b1c15'
  on-tertiary-fixed-variant: '#46473f'
  background: '#fff8f7'
  on-background: '#251819'
  surface-variant: '#f5dddd'
typography:
  h1:
    fontFamily: EB Garamond
    fontSize: 34px
    fontWeight: '600'
    lineHeight: 42px
    letterSpacing: -0.02em
  h2:
    fontFamily: EB Garamond
    fontSize: 28px
    fontWeight: '500'
    lineHeight: 36px
  h3:
    fontFamily: EB Garamond
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-caps:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.1em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-margin: 24px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
  section-gap: 48px
---

## Brand & Style

The design system is anchored in the concepts of reverence, heritage, and spiritual peace. It is designed for the 'Kidung Rohani Gereja Yesus Sejati' mobile application, catering to a diverse congregation that seeks both liturgical tradition and modern accessibility. 

The aesthetic direction is **Modern Classicism**. It blends the timeless authority of ecclesiastical manuscripts with the clean, airy layouts of high-end editorial design. The UI prioritizes a "content-first" approach where the sacred lyrics and musical notation are treated as the centerpiece. Visual flourishes are used sparingly to signify quality and devotion rather than to distract. The interface aims to evoke a sense of quietude, transforming the mobile device into a digital sanctuary.

## Colors

This design system utilizes a sophisticated palette centered on **Deep Maroon** and **Champagne Gold**. 

- **Deep Maroon (#800020):** Used as the primary brand color for critical actions, headers, and spiritual emphasis. It symbolizes the weight of tradition and the blood of the covenant.
- **Champagne Gold (#D4AF37):** Employed as an accent color for iconography, thin borders, and decorative elements. It adds a layer of "sacred quality" and luminosity.
- **Soft Cream (#FDFCF0):** The primary background color in light mode, chosen specifically to reduce eye strain compared to pure white, mimicking the aged parchment of traditional songbooks.

In Dark Mode, the palette shifts to deep umber and charcoal tones to maintain the "sacred" feel without becoming overly "tech-focused," using the gold accents to provide warmth and legibility.

## Typography

Typography is the primary vehicle for the "sacred" aesthetic. 

- **Headlines:** We use **EB Garamond**, a classic humanist serif. It provides a literary and historical weight necessary for hymn titles and biblical passages. High-level headers should use a medium or semi-bold weight to command presence.
- **Body & UI:** We use **Manrope** for all functional text and long-form lyrics. Manrope was selected for its modern, open counters and high legibility, ensuring that the congregation can read lyrics easily at a distance or in low-light environments.
- **Hierarchy:** Clear distinction is made between the "Sacred Text" (Serif) and the "Functional Interface" (Sans-serif). Uppercase tracking is used for labels to denote navigation categories without cluttering the visual space.

## Layout & Spacing

This design system employs a **Fluid Grid** model with generous margins to evoke a sense of serenity and breathing room.

- **Margins:** A standard 24px horizontal margin ensures content feels contained and focused, like the text block on a printed page.
- **Rhythm:** An 8px base grid governs all spacing. Vertical rhythm is emphasized, with large "section-gaps" (48px) used to separate different liturgical sections or thematic hymn groupings.
- **Safe Areas:** Special attention is given to bottom-sheet height and navigation bars to ensure they do not obstruct lyric viewing during worship.

## Elevation & Depth

To maintain a serene and "flat-plus" aesthetic, this design system avoids aggressive shadows. Instead, it uses:

1.  **Tonal Layering:** Depth is communicated by subtle shifts in surface color. In light mode, cards may be pure white against a Soft Cream background.
2.  **Subtle Gold Outlines:** Instead of heavy shadows, active states or featured cards use a 1px Gold (#D4AF37) border to lift the element.
3.  **Ambient Glow:** For high-priority elements (like the 'Now Playing' hymn), a very soft, high-diffusion maroon shadow (10% opacity) is used to create a "halo" effect rather than a physical drop-shadow.

## Shapes

The shape language is defined by **Softened Rectangles**. 

- **Rounded Corners:** A 16px (1rem) corner radius is standard for cards and primary containers. This "Rounded" setting removes harsh edges, contributing to the "serene" and "gentle" brand personality.
- **Iconography:** Icons should feature rounded terminals and consistent stroke weights (1.5px to 2px). 
- **Buttons:** Buttons use a fully rounded (pill-shaped) style for secondary actions, but primary "CTA" buttons maintain the standard 16px radius to match the card language.

## Components

### Buttons
- **Primary:** Solid Deep Maroon with White or Cream text. High corner radius (16px).
- **Secondary:** Transparent background with a thin Champagne Gold border.
- **Text Buttons:** EB Garamond in Semi-bold, Deep Maroon, used for navigation within liturgical flows.

### Cards
- **Hymn Cards:** White surfaces (Light mode) with 16px rounded corners. Includes a thin gold accent bar on the left edge to indicate the "active" or "category" color.
- **Content Cards:** Uses generous padding (24px) to ensure lyrics or sheet music previews do not feel cramped.

### Input Fields
- Underlined style rather than boxed, to mimic the lines of a musical staff. Focused state turns the underline to Champagne Gold with a small serif label above.

### Elegant Iconography
- Custom icons for "Hymn," "Prayer," "Bible," and "Settings" using a thin-line Gold style. Icons should feel illustrative and graceful rather than purely functional.

### Lists
- Clean, spacious list items with Maroon numerals (using EB Garamond) to denote hymn numbers. Dividers are low-contrast and never extend to the full width of the screen.

### Navigation
- A bottom navigation bar with a subtle blur effect (Glassmorphism Lite) and a top border of 1px Champagne Gold.
# Visual Design System

## Overview

This document outlines the visual design system for the Bitcoin Protozoa project, including color palettes, typography, UI components, and visual style guidelines. A consistent visual design system ensures a cohesive user experience and reinforces the project's identity.

## Color Palette

### Primary Colors

| Color Name | Hex Code | RGB | Description | Usage |
|------------|----------|-----|-------------|-------|
| **Bitcoin Orange** | #F7931A | rgb(247, 147, 26) | The iconic Bitcoin orange | Primary accent color, important UI elements, highlights |
| **Dark Gray** | #4D4D4D | rgb(77, 77, 77) | Bitcoin's complementary gray | Text, secondary UI elements, borders |
| **Deep Space** | #1A1A1A | rgb(26, 26, 26) | Near-black background | Main background color |
| **Cosmic White** | #F5F5F5 | rgb(245, 245, 245) | Off-white | Text on dark backgrounds, subtle highlights |

### Secondary Colors

| Color Name | Hex Code | RGB | Description | Usage |
|------------|----------|-----|-------------|-------|
| **Protozoa Blue** | #00A3E0 | rgb(0, 163, 224) | Vibrant blue | Core particle group, water-like effects |
| **Protozoa Green** | #2ECC71 | rgb(46, 204, 113) | Vibrant green | Movement particle group, growth indicators |
| **Protozoa Purple** | #9B59B6 | rgb(155, 89, 182) | Rich purple | Control particle group, special effects |
| **Protozoa Red** | #E74C3C | rgb(231, 76, 60) | Vibrant red | Attack particle group, warnings |
| **Protozoa Yellow** | #F1C40F | rgb(241, 196, 15) | Bright yellow | Defense particle group, highlights |

### Accent Colors

| Color Name | Hex Code | RGB | Description | Usage |
|------------|----------|-----|-------------|-------|
| **Mutation Pink** | #FF5E94 | rgb(255, 94, 148) | Bright pink | Mutation indicators, special events |
| **Confirmation Teal** | #1ABC9C | rgb(26, 188, 156) | Turquoise teal | Confirmation indicators, success states |
| **Energy Cyan** | #00F0FF | rgb(0, 240, 255) | Electric cyan | Energy indicators, particle effects |
| **Blockchain Gold** | #FFD700 | rgb(255, 215, 0) | Metallic gold | Rare traits, achievements, special states |

### Gradients

| Gradient Name | Colors | Usage |
|---------------|--------|-------|
| **Orange Glow** | #F7931A to #FFC107 | Buttons, important UI elements |
| **Deep Space** | #1A1A1A to #2C3E50 | Background variations |
| **Protozoa Life** | #00A3E0 to #2ECC71 | Particle effects, visualizations |
| **Mutation Spectrum** | #9B59B6 to #FF5E94 | Mutation effects, special states |
| **Bitcoin Energy** | #F7931A to #E74C3C | Energy indicators, force fields |

### Opacity Variations

For UI elements that require transparency:

- **High Emphasis**: 100% opacity
- **Medium Emphasis**: 80% opacity
- **Low Emphasis**: 60% opacity
- **Subtle Elements**: 30% opacity
- **Background Elements**: 10% opacity

## Color Usage Guidelines

### Particle Color Mapping

Each particle role has a designated color to ensure visual consistency:

- **CORE**: Bitcoin Orange (#F7931A)
- **CONTROL**: Protozoa Purple (#9B59B6)
- **ATTACK**: Protozoa Red (#E74C3C)
- **DEFENSE**: Protozoa Yellow (#F1C40F)
- **MOVEMENT**: Protozoa Green (#2ECC71)

### Force Field Visualization

Force fields should use color gradients with reduced opacity:

- **CORE Force Field**: Orange Glow gradient at 30% opacity
- **CONTROL Force Field**: Purple to Pink gradient at 20% opacity
- **ATTACK Force Field**: Red to Orange gradient at 25% opacity
- **DEFENSE Force Field**: Yellow to Gold gradient at 20% opacity
- **MOVEMENT Force Field**: Green to Blue gradient at 20% opacity

### UI Elements

- **Buttons**: Orange Glow gradient with Dark Gray text
- **Headers**: Dark Gray with Bitcoin Orange accents
- **Body Text**: Cosmic White on Deep Space background
- **Links**: Bitcoin Orange
- **Borders**: Dark Gray at 60% opacity
- **Tooltips**: Dark Gray background with Cosmic White text
- **Alerts**: Role-appropriate colors (e.g., warnings use Protozoa Red)

### Background

The main application background should use a subtle gradient of Deep Space, creating a space-like environment that allows the colorful particles to stand out.

## Typography

### Font Families

- **Primary Font**: 'Inter', sans-serif
  - Clean, modern sans-serif font with excellent readability
  - Use for all UI elements, body text, and headers

- **Monospace Font**: 'Roboto Mono', monospace
  - Use for code, technical data, and blockchain information

### Font Weights

- **Light**: 300 - Use for large headings and subtle text
- **Regular**: 400 - Use for body text and general UI
- **Medium**: 500 - Use for subheadings and emphasized text
- **Bold**: 700 - Use for main headings and important UI elements

### Font Sizes

- **Extra Small**: 12px - Fine print, footnotes
- **Small**: 14px - Secondary text, labels
- **Body**: 16px - Main body text
- **Large**: 18px - Important information, subheadings
- **Extra Large**: 24px - Section headings
- **Heading**: 32px - Main headings
- **Display**: 48px - Hero text, major headings

### Line Heights

- **Tight**: 1.2 - Headings
- **Normal**: 1.5 - Body text
- **Loose**: 1.8 - Large blocks of text

## UI Components

### Buttons

- **Primary Button**: Bitcoin Orange background, Cosmic White text, subtle shadow
- **Secondary Button**: Dark Gray background, Cosmic White text
- **Tertiary Button**: Transparent background, Bitcoin Orange text and border
- **Disabled Button**: Dark Gray at 30% opacity, text at 50% opacity

### Cards

- **Standard Card**: Dark Gray background, subtle shadow, rounded corners
- **Highlighted Card**: Dark Gray background with Bitcoin Orange border
- **Interactive Card**: Dark Gray background with hover effect (slight glow)

### Inputs

- **Text Input**: Dark Gray background, Cosmic White text, Bitcoin Orange focus state
- **Checkbox/Radio**: Bitcoin Orange for selected state
- **Dropdown**: Dark Gray background, Bitcoin Orange highlight for selected item
- **Slider**: Bitcoin Orange track and thumb

### Navigation

- **Main Navigation**: Dark Gray background, Bitcoin Orange for active state
- **Tabs**: Underline style with Bitcoin Orange for active tab
- **Breadcrumbs**: Cosmic White text with Bitcoin Orange separators

### Overlays

- **Modal**: Deep Space background with 90% opacity overlay
- **Tooltip**: Dark Gray background, Cosmic White text, subtle shadow
- **Popover**: Dark Gray background, subtle shadow, Bitcoin Orange accents

## Iconography

### Style Guidelines

- **Line Weight**: 2px consistent stroke weight
- **Corner Radius**: 2px for sharp corners, 4px for rounded elements
- **Size**: 24px × 24px standard size (scale proportionally)
- **Color**: Inherit from text color or specified UI component
- **States**: Normal, Hover (+15% brightness), Active (+30% brightness), Disabled (30% opacity)

### System Icons

A consistent set of system icons should be used throughout the application:

- **Navigation**: Home, Back, Forward, Menu
- **Actions**: Add, Remove, Edit, Delete, Save
- **Communication**: Share, Message, Notification
- **Media**: Play, Pause, Stop, Volume
- **Data**: Download, Upload, Sync, Refresh
- **Status**: Success, Warning, Error, Information

## Particle Visual Effects

### Glow Effects

- **Core Particles**: Strong orange glow (20px blur radius)
- **Other Particles**: Role-appropriate color glow (10px blur radius)
- **Mutation Events**: Pink/purple pulsing glow (30px blur radius)

### Motion Effects

- **Particle Trails**: Fading trails in role-appropriate colors (30% to 0% opacity)
- **Force Field Pulses**: Subtle pulsing effect (opacity variation of ±10%)
- **Mutation Transitions**: Sparkle effect with role transition colors

### Special States

- **Confirmation Milestone**: Gold particle burst effect
- **Evolution Event**: Rippling wave effect in mutation pink
- **Energy Transfer**: Electricity-like effect in Energy Cyan

## Responsive Design

### Breakpoints

- **Mobile**: 320px - 480px
- **Tablet**: 481px - 768px
- **Desktop**: 769px - 1279px
- **Large Desktop**: 1280px and above

### Scaling Guidelines

- **Particle Size**: Scale proportionally based on screen size
- **UI Elements**: Maintain consistent padding and spacing ratios
- **Typography**: Scale font sizes by 0.9x on tablet, 0.8x on mobile
- **Effects**: Reduce visual effects intensity on lower-powered devices

## Accessibility Guidelines

### Color Contrast

- Maintain minimum contrast ratios:
  - 4.5:1 for normal text
  - 3:1 for large text and UI components
- Provide alternative visual indicators beyond color alone

### Text Readability

- Minimum text size of 14px for body text
- Avoid using light text weights on dark backgrounds at small sizes
- Maintain adequate line spacing (1.5x for body text)

### Focus States

- Clearly visible focus indicators using Bitcoin Orange
- Minimum 2px border for focus states
- Ensure all interactive elements are keyboard accessible

## Animation Guidelines

### Timing

- **Fast**: 100ms - 200ms (micro-interactions)
- **Medium**: 200ms - 300ms (standard transitions)
- **Slow**: 300ms - 500ms (emphasis transitions)

### Easing

- **Standard**: ease-in-out (most transitions)
- **Entrance**: ease-out (elements entering the screen)
- **Exit**: ease-in (elements leaving the screen)
- **Emphasis**: cubic-bezier(0.2, 0.8, 0.2, 1) (attention-grabbing animations)

### Particle Animation

- **Movement**: Smooth, fluid motion with slight randomness
- **Interactions**: Quick, responsive reactions to forces
- **Formations**: Gradual, organic transitions between states

## Implementation Notes

### CSS Variables

Implement the color system using CSS variables for easy theming and consistency:

```css
:root {
  /* Primary Colors */
  --bitcoin-orange: #F7931A;
  --dark-gray: #4D4D4D;
  --deep-space: #1A1A1A;
  --cosmic-white: #F5F5F5;
  
  /* Secondary Colors */
  --protozoa-blue: #00A3E0;
  --protozoa-green: #2ECC71;
  --protozoa-purple: #9B59B6;
  --protozoa-red: #E74C3C;
  --protozoa-yellow: #F1C40F;
  
  /* Accent Colors */
  --mutation-pink: #FF5E94;
  --confirmation-teal: #1ABC9C;
  --energy-cyan: #00F0FF;
  --blockchain-gold: #FFD700;
  
  /* Typography */
  --font-primary: 'Inter', sans-serif;
  --font-mono: 'Roboto Mono', monospace;
}
```

### Three.js Material Guidelines

For Three.js materials, use these settings for consistent particle rendering:

```javascript
// Core particle material
const coreParticleMaterial = new THREE.MeshStandardMaterial({
  color: 0xF7931A,
  emissive: 0xF7931A,
  emissiveIntensity: 0.5,
  roughness: 0.2,
  metalness: 0.8
});

// Generic particle material function
function createParticleMaterial(colorHex, emissiveIntensity = 0.3) {
  return new THREE.MeshStandardMaterial({
    color: colorHex,
    emissive: colorHex,
    emissiveIntensity: emissiveIntensity,
    roughness: 0.3,
    metalness: 0.5
  });
}
```

## Asset Creation Guidelines

### Textures

- **Particle Textures**: High-resolution (512×512px minimum), with alpha channel
- **UI Textures**: SVG preferred, PNG with @2x versions for high-DPI displays
- **Background Textures**: Subtle, dark patterns that don't distract from particles

### 3D Models

- **Particle Models**: Low-poly models optimized for instanced rendering
- **Force Field Models**: Procedurally generated for performance
- **Level of Detail**: Implement LOD for complex particle shapes

## Conclusion

This visual design system provides a comprehensive guide for maintaining visual consistency throughout the Bitcoin Protozoa project. By adhering to these guidelines, we ensure a cohesive, engaging, and accessible user experience that reinforces the project's identity and enhances its functionality.

The design system should be treated as a living document, updated as the project evolves and new visual requirements emerge.

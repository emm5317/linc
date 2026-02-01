# Art Pipeline

## Style Rules
- Internal resolution target: `960x540`
- Pixel-forward visuals, nearest filtering, mipmaps off
- Limited palette (16-32 colors)
- Top-left light source, 2-3 tone shading

## Sprite Targets
- Player: `32x32`
- Asteroids: `48x48`, `32x32`, `16x16`
- Bullet: `8x2`
- Pickup: `12x12`
- UI icon: `16x16`

## Source and Export Workflow
1. Edit source files in `art_source/` (`.ase`/`.aseprite`).
2. Export PNGs to `art_source/exports/`.
3. Copy PNGs to `assets/sprites/`.
4. In Godot import: nearest filter, mipmaps off.

## Current Codebase Note
Scenes currently use placeholder `Sprite2D` nodes with no texture assignments. Final art import and wiring is still pending.

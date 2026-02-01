# SpaceSalvage

Asteroid shooter prototype with a tractor beam heat mechanic, built in Godot 4.x using GDScript.

## Current State (Codebase Truth)
Implemented now:
- Scene scaffold for `Main`, `Player`, `Asteroid`, `Bullet`, `Pickup`, `HUD`, `Menu`
- Core player movement, turning, shooting signal, tractor heat logic
- Player + asteroid screen wrap with collider-aware padding
- Asteroid spawning loop with max asteroid cap
- Bullet instancing from player fire signal
- Asteroid pop scoring + pickup spawn
- Pickup collection scoring
- Spawn difficulty ramp through `SpawnController`
- Best score load/save through `SaveSystem` (`res://data/save.cfg`)

Not implemented yet:
- Asteroid splitting (large -> medium -> small)
- Reliable player damage/game-over collision path from asteroid contact
- Restart input (`R`) behavior wiring
- Menu-to-main flow wiring
- Power-ups, particles, screen shake, and final art/audio pass

## Controls (Target)
- `W` / `Up`: thrust
- `A` / `Left`: turn left
- `D` / `Right`: turn right
- `Space`: shoot
- `Shift`: tractor beam
- `R`: restart (planned, not wired yet)

## Stack
- Engine: Godot 4.x
- Language: GDScript
- Art tooling: LibreSprite
- SFX tooling: jsfxr (optional Audacity cleanup)

## Project Layout
```text
scenes/
  main/Main.tscn
  player/Player.tscn
  asteroid/Asteroid.tscn
  bullet/Bullet.tscn
  pickup/Pickup.tscn
  ui/HUD.tscn
  ui/Menu.tscn
scripts/
  globals.gd
  main.gd
  player.gd
  asteroid.gd
  bullet.gd
  pickup.gd
  hud.gd
  menu.gd
  systems/save_system.gd
  systems/spawn_controller.gd
docs/
assets/
art_source/
data/
```

## Documentation Index
- `docs/ARCHITECTURE.md`
- `docs/BUILD_PLAN.md`
- `docs/ART_PIPELINE.md`
- `docs/TESTING_QA.md`
- `docs/ENDSTATE.md`
- `docs/CURRENT_PROGRESS.md`
- `docs/HANDOFF.md`
- `docs/RELEASE_CHECKLIST.md`
- `docs/SCRIPT_CONTRACTS.md`
- `docs/SCENE_BUILD_CHECKLIST.md`

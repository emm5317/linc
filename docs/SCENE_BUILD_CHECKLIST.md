# Scene Build Checklist

## Current State
All planned starter scenes already exist in the repository:
- `scenes/player/Player.tscn`
- `scenes/bullet/Bullet.tscn`
- `scenes/asteroid/Asteroid.tscn`
- `scenes/pickup/Pickup.tscn`
- `scenes/ui/HUD.tscn`
- `scenes/ui/Menu.tscn`
- `scenes/main/Main.tscn`

## Keep These Node Names Stable
- Player children: `Muzzle`, `TractorArea`
- Main children: `Player`, `HUD`, `SpawnTimer`, `Asteroids`, `Bullets`, `Pickups`, `SpawnController`, `SaveSystem`
- HUD children: `ScoreLabel`, `BestLabel`, `HeatBar`, `OverheatLabel`, `GameOverLabel`

## Required Signal Wiring (Current)
- `SpawnTimer.timeout -> Main._on_spawn_timer_timeout`
- `Player.shot_requested -> Main._on_player_shot_requested`
- `Player.player_hit -> Main._on_player_hit`
- `Player.tractor_heat_changed -> HUD.set_heat`
- Runtime dynamic connections in `Main`:
  - asteroid `popped`
  - pickup `collected`

## Validation Gate
- `Main.tscn` runs without missing-node errors.
- Shooting spawns bullets and pops asteroids.
- Asteroid pop spawns pickup and score updates.
- Heat bar reacts to tractor usage.

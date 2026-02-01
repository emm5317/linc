# Architecture

## 1) Runtime Overview
- `Main` is the orchestrator for run state, spawning, scoring, and persistence integration.
- `Player` owns movement, shooting requests, tractor heat/overheat, and wrap behavior.
- `Asteroid` owns drift, wrap behavior, and pop scoring emission.
- `Bullet` owns projectile travel and asteroid pop trigger.
- `Pickup` owns collection scoring and optional tractor targeting.
- `HUD` is a passive UI target updated by `Main` and `Player` signals.
- `SpawnController` computes dynamic spawn interval from score.
- `SaveSystem` persists best score in `res://data/save.cfg`.

## 2) Scene Graph (As Built)
### `scenes/main/Main.tscn`
- Root `Node2D`
- Children:
  - `Player` (instance)
  - `HUD` (instance)
  - `SpawnTimer` (`Timer`)
  - `Asteroids` (`Node2D`)
  - `Bullets` (`Node2D`)
  - `Pickups` (`Node2D`)
  - `SpawnController` (`Node` + script)
  - `SaveSystem` (`Node` + script)

### `scenes/player/Player.tscn`
- Root `CharacterBody2D`
- Children: `Sprite2D`, `CollisionShape2D`, `Muzzle`, `TractorArea`, two `AudioStreamPlayer2D`

### `scenes/asteroid/Asteroid.tscn`
- Root `Area2D`
- Children: `Sprite2D`, `CollisionShape2D`

### `scenes/bullet/Bullet.tscn`
- Root `Area2D`
- Children: `Sprite2D`, `CollisionShape2D`

### `scenes/pickup/Pickup.tscn`
- Root `RigidBody2D`
- Children: `Sprite2D`, `CollisionShape2D`

### `scenes/ui/HUD.tscn`
- Root `CanvasLayer`
- Children: `ScoreLabel`, `BestLabel`, `HeatBar`, `OverheatLabel`, `GameOverLabel`

### `scenes/ui/Menu.tscn`
- Root `Control`
- Children include title, controls text, start/quit buttons

## 3) Signal/Data Flow (Current)
- `Player.shot_requested -> Main._on_player_shot_requested`
- `Player.player_hit -> Main._on_player_hit`
- `Player.tractor_heat_changed -> HUD.set_heat`
- `SpawnTimer.timeout -> Main._on_spawn_timer_timeout`
- `Asteroid.popped -> Main._on_asteroid_popped` (connected at runtime per instance)
- `Pickup.collected -> Main._on_pickup_collected` (connected at runtime per instance)

## 4) Collision Layers (Current)
- Layer 1: Player
- Layer 2: Asteroids
- Layer 3: Bullets
- Layer 4: Pickups

Current masks in scenes:
- Player mask `10` (asteroids + pickups)
- Asteroid mask `5` (player + bullets)
- Bullet mask `2` (asteroids)
- Pickup mask `1` (player)
- Tractor area mask `8` (pickups)

## 5) Persistence
- Path: `res://data/save.cfg`
- Section/key: `[score] best=<int>`
- Load on `_ready` in `Main`, save when best score improves

## 6) Known Gaps
- Player hit is signal-ready, but asteroid->player hit triggering is not fully wired.
- Asteroid splitting is not implemented.
- Menu scene exists but is not yet integrated as startup flow.

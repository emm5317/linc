# Script Contracts

This is the source-of-truth API contract for scripts currently in the repo.

## Shared Conventions
- Engine target: Godot 4.x
- Groups in `GameGlobals`:
  - `player`
  - `asteroid`
  - `bullet`
  - `pickup`

## `scripts/globals.gd`
- `class_name GameGlobals`
- Constants:
  - score values
  - tractor heat tuning
  - spawn tuning
- Utility:
  - `wrap_position(p: Vector2, w: float, h: float) -> Vector2`

## `scripts/main.gd`
- Extends `Node2D`
- Exported scenes:
  - `asteroid_scene`
  - `pickup_scene`
  - `bullet_scene`
  - `max_asteroids`
- Public methods:
  - `start_run() -> void`
  - `end_run() -> void`
  - `restart_run() -> void`
- Signal handlers:
  - `_on_spawn_timer_timeout()`
  - `_on_player_shot_requested(spawn_position, direction)`
  - `_on_player_hit()`
  - `_on_asteroid_popped(global_pos, _size_tier, score_value)`
  - `_on_pickup_collected(value)`

## `scripts/player.gd`
- Extends `CharacterBody2D`
- Signals:
  - `shot_requested(spawn_position: Vector2, direction: Vector2)`
  - `player_hit()`
  - `tractor_heat_changed(current: float, max_value: float, overheated: bool)`
- Public methods:
  - `set_controls_enabled(value: bool) -> void`
  - `apply_hit() -> void`
- Wrap exports:
  - `wrap_padding`
  - `debug_wrap_log`

## `scripts/asteroid.gd`
- Extends `Area2D`
- Signal:
  - `popped(global_pos: Vector2, size_tier: int, score_value: int)`
- Public method:
  - `pop() -> void`
- Wrap exports:
  - `wrap_padding`
  - `debug_wrap_log`

## `scripts/bullet.gd`
- Extends `Area2D`
- Signal: `expired()`
- Public method: `setup(direction: Vector2) -> void`

## `scripts/pickup.gd`
- Extends `RigidBody2D`
- Signal: `collected(score_value: int)`
- Public method: `set_tractor_target(target: Node2D) -> void`

## `scripts/hud.gd`
- Extends `CanvasLayer`
- Public methods:
  - `set_score(value: int) -> void`
  - `set_best(value: int) -> void`
  - `set_heat(current: float, max_value: float, overheated: bool) -> void`
  - `show_game_over(visible: bool) -> void`

## `scripts/menu.gd`
- Extends `Control`
- Signals:
  - `start_pressed()`
  - `quit_pressed()`

## `scripts/systems/save_system.gd`
- Extends `Node`
- `class_name SaveSystem`
- Methods:
  - `load_best_score() -> int`
  - `save_best_score(value: int) -> void`

## `scripts/systems/spawn_controller.gd`
- Extends `Node`
- `class_name SpawnController`
- Methods:
  - `reset() -> void`
  - `register_score(total_score: int) -> void`
  - `get_interval() -> float`

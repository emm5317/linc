# Testing and QA

## Current Priority Smoke Test (Main.tscn)
1. Run `scenes/main/Main.tscn`.
2. Verify player can move, turn, and shoot.
3. Verify asteroids spawn continuously and wrap at edges.
4. Verify bullets pop asteroids.
5. Verify pickup spawns on pop and can be collected.
6. Verify score and best score labels update.
7. Verify heat bar/overheat label react to tractor usage.

## Known Unverified Paths
- Player damage/game-over from asteroid contact
- Restart key flow (`R`)
- Menu flow start/quit behavior in full game boot
- Verify `user://save.cfg` persists between runs in editor and export builds

## Feature Matrix (Current)
- Movement + turn + damping: implemented
- Player wrap: implemented
- Asteroid drift + wrap: implemented
- Bullet lifetime + pop trigger: implemented
- Difficulty ramp: implemented
- Best score load/save: implemented
- Asteroid splitting: missing
- Power-ups: missing
- Particle/shake polish: missing

## Performance Guardrails
- Keep `max_asteroids` at or below 30 while iterating.
- Keep bullet lifetime short (currently 1.2s).
- Add caps before introducing particles.

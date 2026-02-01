# Handoff

## Snapshot
- Project: SpaceSalvage
- Engine: Godot 4.x
- State: Prototype baseline implemented; gameplay loop still missing final loss/restart and splitting features.

## Start Here
1. Open `scenes/main/Main.tscn` and run smoke test from `docs/TESTING_QA.md`.
2. Review `docs/ARCHITECTURE.md` for current signal/data flow.
3. Implement next actions from `docs/CURRENT_PROGRESS.md`.

## Immediate Priorities
1. Player-hit collision path and game-over validation.
2. Restart input (`R`) wiring.
3. Asteroid splitting implementation.

## Working Agreements
- Keep scene node names aligned with `docs/SCRIPT_CONTRACTS.md`.
- Update `docs/CURRENT_PROGRESS.md` at end of each work session.
- If signals or node structure changes, update `docs/ARCHITECTURE.md` and `docs/SCRIPT_CONTRACTS.md` in the same change.

## Open Decisions
- Exact split scoring for child asteroids.
- Whether tractor affects only pickups or also small asteroids.
- Whether menu becomes startup scene before core loop is finalized.

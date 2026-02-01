# Build Plan

## Phase Status Snapshot
- Phase 0 Foundations: COMPLETE
- Phase 1 Movement + Combat Baseline: COMPLETE
- Phase 2 Core Gameplay Baseline: IN PROGRESS
- Phase 3 Tractor Twist Baseline: COMPLETE
- Phase 4 Difficulty + Persistence Baseline: COMPLETE
- Phase 5 Polish: NOT STARTED
- Phase 6 Ship: NOT STARTED

## Next Execution Order
1. Finish player damage and game-over collision path.
2. Add restart input flow (`R`) in run state.
3. Implement asteroid splitting by size tier.
4. Wire menu as entry scene and start action into main run.
5. Run QA matrix and tune values.
6. Add polish set (power-ups, particles, shake, SFX pass).

## Completion Criteria for Current Milestone
- End-to-end loop works without manual editor intervention:
  - spawn -> shoot -> pop -> pickup -> score -> hit -> game over -> restart
- No missing-node or signal errors in `Main.tscn` play session.

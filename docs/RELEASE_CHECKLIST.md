# Release Checklist

## Gameplay Readiness
- [x] Player movement and screen wrap baseline implemented.
- [x] Shooting pipeline (signal -> bullet instance -> asteroid pop) implemented.
- [x] Pickup collection and scoring baseline implemented.
- [x] Tractor heat/overheat HUD feedback implemented.
- [ ] Player hit -> game over collision path validated.
- [ ] Restart flow (`R`) implemented and validated.
- [ ] Asteroid split behavior implemented.

## Systems
- [x] Difficulty ramp (`SpawnController`) integrated.
- [x] Best score load/save (`SaveSystem`) integrated.
- [ ] Save behavior verified in exported builds.

## Content and Polish
- [x] HUD and Menu scenes scaffolded.
- [ ] Final sprite pass applied.
- [ ] SFX hookup and balancing pass.
- [ ] Particles and camera shake integrated.
- [ ] Power-ups implemented.

## Packaging
- [ ] Export templates installed.
- [ ] Windows export tested.
- [ ] macOS export tested.
- [ ] Release zip includes player controls readme.

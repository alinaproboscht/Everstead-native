# EVERSTEAD Native 0.33 — Living Village Core

This update extends the 0.32 foundation already stored in `Everstead-native`.

## New modules
- `EversteadSchedule.swift` — autonomous daily routine decisions
- `EversteadEconomy.swift` — production sites and production chains
- `EversteadFamilySystem.swift` — households, partners and parent/child links
- `EversteadSimulationEngine.swift` — observable simulation clock/controller

## Existing 0.32 modules required
- `EversteadLivingVillage.swift`
- `EversteadNativeSave.swift`
- `EversteadPathfinding.swift`

## Next integration
The next package connects these systems to the authoritative native files:
`GameModels.swift`, `Everstead3DWorld.swift` and `ContentView.swift`.

Those files should be stored as individual source files in the GitHub repository before they are replaced, so the working RealityKit world can be preserved exactly.

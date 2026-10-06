# EVERSTEAD Native 0.34 — Integration Update

This package upgrades the existing native Living Village modules without replacing the working RealityKit world.

## Replace
- `EversteadPathfinding.swift`

## Add
- `EversteadGameLivingVillage.swift`
- `EversteadNativeIntegration.swift`

## What 0.34 adds
- road-graph routing based on the existing `EversteadGame.roads`
- intersections and the historic market square as navigation connections
- conversion of existing villagers into Living Village residents
- household generation from existing homes
- mapping between old and new needs/activity models
- production-site discovery from farm, mill, bakery and fishing pier
- an integration controller connecting `EversteadGame` and `EversteadSimulationEngine`

## Important
The package is source-level integration infrastructure. The working RealityKit world is not replaced.

To make the new simulation advance automatically in the live game, the next wiring step is to instantiate `EversteadNativeIntegration` in the app/game layer and invoke it from the authoritative simulation tick. That change should be made against the exact current app files to avoid breaking the working build.

Version: 0.34

# EVERSTEAD 0.37 — EversteadCore Swift Package

This package extracts the independent Living Village simulation into a reusable Swift Package for the native iPad Swift Playgrounds app.

## Package module
`EversteadCore`

## Included
- Living Village models and needs
- Households and family relationships
- Daily schedules
- Production-chain economy
- Simulation engine
- Native simulation save store

## Deliberately kept in the app target
Files that directly depend on the app's `EversteadGame` model or RealityKit remain local:
- EversteadPathfinding.swift
- EversteadGameLivingVillage.swift
- EversteadLiveSimulation.swift
- EversteadRuntime.swift
- RealityKit / UI files

## Swift Playgrounds
After this package structure exists in the GitHub repository, add the repository as a Swift Package and use:

```swift
import EversteadCore
```

The local bridge files must then import EversteadCore.

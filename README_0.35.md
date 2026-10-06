# EVERSTEAD Native 0.35 — Live Simulation

0.35 turns the 0.34 integration layer into a live synchronized layer around the existing `EversteadGame`.

## Replace
- `EversteadNativeIntegration.swift`

## Add
- `EversteadLiveSimulation.swift`
- `EversteadLiveSimulationHost.swift`

The controller observes the existing game state, mirrors villagers and households, refreshes production sites when buildings change, exposes road routes and supports native Living Village saves.

### Important architecture decision
`EversteadGame` 0.25 already advances needs, AI and production. 0.35 therefore does not run a second competing clock. This prevents double-decaying needs and double-producing goods.

The next app-layer step is to retain `EversteadLiveSimulationHost(game:)` beside the existing `EversteadGame` in the current `ContentView`.

# EVERSTEAD 0.36 — Living Village Connected

## Important correction

The existing `ContentView.swift` 0.24 creates its own private `EversteadGame` with `@StateObject`.
A second runtime around that view would create **two game instances**. That is not acceptable.

Therefore this package contains the safe runtime foundation, but **do not replace `MyApp.swift` yet** unless `ContentView.swift` has also been migrated to consume `EversteadRuntime.game`.

### Files
- `EversteadRuntime.swift` — shared game + live simulation runtime
- `EversteadConnectedRootView.swift` — future root host
- `MyApp_0.36.swift` — target app entry point after ContentView migration
- `Everstead036ConnectionState.swift` — explicit migration guard
- `VERSION_0.36.json`

### Next required change
`ContentView.swift` must stop creating `EversteadGame()` internally and instead receive the shared `EversteadGame` from `EversteadRuntime`. The main menu's “NEUES SPIEL” action must call `runtime.newGame()`.

This package intentionally does not claim that 0.36 is fully wired until that replacement is made.

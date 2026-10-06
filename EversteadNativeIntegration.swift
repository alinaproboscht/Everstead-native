import Foundation
import Combine

// MARK: - EVERSTEAD 0.34
// Native simulation integration controller.
//
// Add one instance beside EversteadGame in the app layer and call
// synchronizeAfterGameTick() after a game simulation tick.

@MainActor
final class EversteadNativeIntegration: ObservableObject {

    @Published private(set) var engine: EversteadSimulationEngine

    private weak var game: EversteadGame?

    init(game: EversteadGame) {
        self.game = game

        self.engine = EversteadSimulationEngine(
            simulation: game.makeLivingVillageSimulation(),
            productionSites: game.makeNativeProductionSites(),
            day: game.date.day,
            hour: Double(game.date.hour)
        )
    }

    func rebuildFromGame() {
        guard let game else { return }

        engine = EversteadSimulationEngine(
            simulation: game.makeLivingVillageSimulation(),
            productionSites: game.makeNativeProductionSites(),
            day: game.date.day,
            hour: Double(game.date.hour)
        )
    }

    func synchronizeAfterGameTick(hours: Double = 1) {
        guard let game else { return }

        engine.advance(hours: hours)
        game.applyLivingVillageSimulation(engine.simulation)
    }

    func saveLivingVillage() throws {
        try engine.save()
    }
}

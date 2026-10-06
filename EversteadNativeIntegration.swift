import Foundation
import Combine

// MARK: - EVERSTEAD 0.35
// Live compatibility controller. EversteadGame remains the authoritative clock.

@MainActor
final class EversteadNativeIntegration: ObservableObject {
    @Published private(set) var simulation: EversteadVillageSimulation
    @Published private(set) var productionSites: [EversteadProductionSite]
    private weak var game: EversteadGame?

    init(game: EversteadGame) {
        self.game = game
        self.simulation = game.makeLivingVillageSimulation()
        self.productionSites = game.makeNativeProductionSites()
    }

    func rebuildFromGame() {
        guard let game else { return }
        simulation = game.makeLivingVillageSimulation()
        productionSites = game.makeNativeProductionSites()
    }

    func synchronizeAfterGameTick(hours: Double = 1) {
        // Do not advance a second clock: GameModels 0.25 already advances
        // needs, AI and production. Mirror that authoritative state instead.
        rebuildFromGame()
    }

    func roadRoute(
        for villagerID: UUID,
        to destination: EversteadPathPoint
    ) -> EversteadRoadPath? {
        guard let game,
              let villager = game.villagers.first(where: { $0.id == villagerID }) else {
            return nil
        }

        return game.roadRoute(
            from: EversteadPathPoint(x: villager.x, y: villager.y),
            to: destination
        )
    }

    func saveLivingVillage() throws {
        try EversteadNativeSaveStore.save(simulation)
    }
}

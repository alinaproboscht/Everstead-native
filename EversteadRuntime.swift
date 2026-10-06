import SwiftUI
import Combine

// =====================================================
// EVERSTEAD 0.36
// LIVING VILLAGE CONNECTED
//
// Central runtime for the native game.
// One EversteadGame instance + one permanently retained
// EversteadLiveSimulation instance.
// =====================================================

@MainActor
final class EversteadRuntime: ObservableObject {

    let game: EversteadGame
    let liveSimulation: EversteadLiveSimulation

    init() {
        let game = EversteadGame()
        self.game = game
        self.liveSimulation = EversteadLiveSimulation(game: game)
    }

    func newGame() {
        game.createStarterWorld()
        game.buildingToPlace = nil
        game.cancelRoadBuilding()
        game.selectedBuildingID = nil
        game.selectedVillagerID = nil
        liveSimulation.rebuildFromGame()
    }

    func synchronizeLivingVillage() {
        liveSimulation.rebuildFromGame()
    }
}

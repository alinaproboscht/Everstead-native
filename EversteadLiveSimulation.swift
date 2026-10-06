import Foundation
import Combine

// =====================================================
// EVERSTEAD 0.35
// LIVE SIMULATION
// =====================================================

@MainActor
final class EversteadLiveSimulation: ObservableObject {
    @Published private(set) var simulation = EversteadVillageSimulation()
    @Published private(set) var productionSites: [EversteadProductionSite] = []
    @Published private(set) var lastSynchronizedDay: Int = 1
    @Published private(set) var lastSynchronizedHour: Int = 8

    private weak var game: EversteadGame?
    private var cancellables: Set<AnyCancellable> = []

    init(game: EversteadGame) {
        self.game = game
        rebuildFromGame()
        observeGame()
    }

    private func observeGame() {
        guard let game else { return }

        game.$date
            .sink { [weak self] _ in
                Task { @MainActor in self?.synchronizeFromGame() }
            }
            .store(in: &cancellables)

        game.$buildings
            .sink { [weak self] _ in
                Task { @MainActor in self?.refreshProductionSites() }
            }
            .store(in: &cancellables)

        game.$villagers
            .sink { [weak self] _ in
                Task { @MainActor in self?.synchronizeFromGame() }
            }
            .store(in: &cancellables)
    }

    func rebuildFromGame() {
        guard let game else { return }
        simulation = game.makeLivingVillageSimulation()
        productionSites = game.makeNativeProductionSites()
        lastSynchronizedDay = game.date.day
        lastSynchronizedHour = game.date.hour
    }

    func synchronizeFromGame() {
        guard let game else { return }

        let previousHouseholds = simulation.households
        var fresh = game.makeLivingVillageSimulation()

        for index in fresh.households.indices {
            guard let homeID = fresh.households[index].homeBuildingID,
                  let previous = previousHouseholds.first(where: {
                      $0.homeBuildingID == homeID
                  }) else { continue }

            fresh.households[index] = EversteadHousehold(
                id: previous.id,
                name: fresh.households[index].name,
                memberIDs: fresh.households[index].memberIDs,
                homeBuildingID: homeID,
                money: fresh.households[index].money
            )

            for residentIndex in fresh.residents.indices
            where fresh.households[index].memberIDs.contains(
                fresh.residents[residentIndex].villagerID
            ) {
                fresh.residents[residentIndex].householdID = previous.id
            }
        }

        simulation = fresh
        lastSynchronizedDay = game.date.day
        lastSynchronizedHour = game.date.hour
    }

    func refreshProductionSites() {
        guard let game else { return }

        let oldSites = productionSites
        productionSites = game.makeNativeProductionSites().map { fresh in
            guard let buildingID = fresh.buildingID,
                  let old = oldSites.first(where: { $0.buildingID == buildingID }) else {
                return fresh
            }

            return EversteadProductionSite(
                id: old.id,
                buildingID: buildingID,
                recipe: fresh.recipe,
                progressHours: old.progressHours,
                enabled: old.enabled
            )
        }
    }

    func route(
        villagerID: UUID,
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

    func save() throws {
        try EversteadNativeSaveStore.save(simulation)
    }
}

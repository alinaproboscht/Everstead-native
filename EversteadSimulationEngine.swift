import Foundation
import Combine

// MARK: - EVERSTEAD 0.33
// Observable simulation controller kept separate from RealityKit rendering.

@MainActor
final class EversteadSimulationEngine: ObservableObject {
    @Published private(set) var simulation: EversteadVillageSimulation
    @Published private(set) var productionSites: [EversteadProductionSite]
    @Published private(set) var day: Int
    @Published private(set) var hour: Double

    var dailyPlan = EversteadDailyPlan()

    init(
        simulation: EversteadVillageSimulation = EversteadVillageSimulation(),
        productionSites: [EversteadProductionSite] = [],
        day: Int = 1,
        hour: Double = 7
    ) {
        self.simulation = simulation
        self.productionSites = productionSites
        self.day = max(1, day)
        self.hour = hour.truncatingRemainder(dividingBy: 24)
    }

    func advance(hours: Double) {
        guard hours > 0 else { return }

        simulation.tick(hours: hours)

        var sites = productionSites
        simulation.runProduction(sites: &sites, hours: hours)
        productionSites = sites

        let total = hour + hours
        if total >= 24 {
            day += Int(total / 24)
        }
        hour = total.truncatingRemainder(dividingBy: 24)

        for index in simulation.residents.indices {
            simulation.residents[index].activity = dailyPlan.scheduledActivity(
                at: hour,
                resident: simulation.residents[index]
            )
        }
    }

    func registerResident(
        villagerID: UUID,
        ageYears: Int = 25,
        lifeStage: EversteadLifeStage = .adult,
        workplaceBuildingID: UUID? = nil
    ) {
        guard !simulation.residents.contains(where: { $0.villagerID == villagerID }) else {
            return
        }

        simulation.residents.append(
            EversteadResidentLife(
                villagerID: villagerID,
                workplaceBuildingID: workplaceBuildingID,
                lifeStage: lifeStage,
                ageYears: ageYears
            )
        )
    }

    func addProductionSite(
        buildingID: UUID?,
        recipe: EversteadProductionRecipe
    ) {
        productionSites.append(
            EversteadProductionSite(
                buildingID: buildingID,
                recipe: recipe
            )
        )
    }

    func save() throws {
        try EversteadNativeSaveStore.save(simulation)
    }
}

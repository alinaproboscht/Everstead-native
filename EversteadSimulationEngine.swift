import Foundation
import Combine

// MARK: - EVERSTEAD 0.37
// Public observable Living Village simulation controller.

@MainActor
public final class EversteadSimulationEngine: ObservableObject {
    @Published public private(set) var simulation: EversteadVillageSimulation
    @Published public private(set) var productionSites: [EversteadProductionSite]
    @Published public private(set) var day: Int
    @Published public private(set) var hour: Double

    public var dailyPlan: EversteadDailyPlan

    public init(
        simulation: EversteadVillageSimulation = EversteadVillageSimulation(),
        productionSites: [EversteadProductionSite] = [],
        day: Int = 1,
        hour: Double = 7,
        dailyPlan: EversteadDailyPlan = EversteadDailyPlan()
    ) {
        self.simulation = simulation
        self.productionSites = productionSites
        self.day = max(1, day)
        self.hour = hour.truncatingRemainder(dividingBy: 24)
        self.dailyPlan = dailyPlan
    }

    public func advance(hours: Double) {
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

    public func registerResident(
        villagerID: UUID,
        ageYears: Int = 25,
        lifeStage: EversteadLifeStage = .adult,
        workplaceBuildingID: UUID? = nil
    ) {
        guard !simulation.residents.contains(where: {
            $0.villagerID == villagerID
        }) else {
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

    public func addProductionSite(
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

    public func save() throws {
        try EversteadNativeSaveStore.save(simulation)
    }
}

import Foundation

// MARK: - EVERSTEAD 0.34
// Bridges the existing EversteadGame with the Living Village modules.

@MainActor
extension EversteadGame {

    func makeLivingVillageSimulation() -> EversteadVillageSimulation {
        var simulation = EversteadVillageSimulation()

        for villager in villagers {
            let stage: EversteadLifeStage
            switch villager.age {
            case ..<6: stage = .infant
            case 6..<13: stage = .child
            case 13..<18: stage = .teen
            case 65...: stage = .senior
            default: stage = .adult
            }

            simulation.residents.append(
                EversteadResidentLife(
                    villagerID: villager.id,
                    partnerVillagerID: villager.partnerID,
                    childVillagerIDs: villager.childrenIDs,
                    workplaceBuildingID: villager.workplaceID,
                    lifeStage: stage,
                    ageYears: villager.age,
                    needs: EversteadNeeds(
                        hunger: villager.needs.hunger,
                        energy: villager.needs.energy,
                        social: villager.needs.social,
                        hygiene: 80,
                        fun: villager.needs.fun
                    ),
                    activity: livingActivity(from: villager.activity)
                )
            )
        }

        let grouped = Dictionary(grouping: villagers.compactMap { villager -> (UUID, Villager)? in
            guard let homeID = villager.homeID else { return nil }
            return (homeID, villager)
        }, by: { $0.0 })

        for (homeID, entries) in grouped {
            let members = entries.map { $0.1 }
            let householdName = members.first.map { "\($0.lastName)-Haushalt" } ?? "Haushalt"
            let householdID = simulation.createHousehold(
                name: householdName,
                memberVillagerIDs: members.map(\.id),
                homeBuildingID: homeID,
                money: Double(members.reduce(0) { $0 + $1.money })
            )

            for index in simulation.residents.indices
            where members.contains(where: { $0.id == simulation.residents[index].villagerID }) {
                simulation.residents[index].householdID = householdID
            }
        }

        return simulation
    }

    func applyLivingVillageSimulation(
        _ simulation: EversteadVillageSimulation
    ) {
        for resident in simulation.residents {
            guard let index = villagers.firstIndex(where: { $0.id == resident.villagerID }) else {
                continue
            }

            villagers[index].needs.hunger = resident.needs.hunger
            villagers[index].needs.energy = resident.needs.energy
            villagers[index].needs.social = resident.needs.social
            villagers[index].needs.fun = resident.needs.fun

            if !villagers[index].isPlayerControlled {
                villagers[index].activity = gameActivity(from: resident.activity)
            }
        }
    }

    func makeNativeProductionSites() -> [EversteadProductionSite] {
        buildings.compactMap { building in
            let recipe: EversteadProductionRecipe?

            switch building.type {
            case .farm:
                recipe = EversteadProduction.farm
            case .mill:
                recipe = EversteadProduction.mill
            case .bakery:
                recipe = EversteadProduction.bakery
            case .fishingPier:
                recipe = EversteadProduction.fishing
            default:
                recipe = nil
            }

            guard let recipe else { return nil }
            return EversteadProductionSite(
                buildingID: building.id,
                recipe: recipe
            )
        }
    }

    func livingActivity(
        from activity: VillagerActivity
    ) -> EversteadActivity {
        switch activity {
        case .sleeping: return .sleeping
        case .eating: return .eating
        case .working, .fishing, .riding, .gardening: return .working
        case .shopping: return .shopping
        case .socializing: return .socializing
        case .walking: return .travelling
        case .idle: return .idle
        case .playerControlled: return .travelling
        }
    }

    func gameActivity(
        from activity: EversteadActivity
    ) -> VillagerActivity {
        switch activity {
        case .sleeping: return .sleeping
        case .eating: return .eating
        case .working: return .working
        case .shopping: return .shopping
        case .socializing: return .socializing
        case .leisure: return .walking
        case .travelling: return .walking
        case .idle: return .idle
        }
    }
}

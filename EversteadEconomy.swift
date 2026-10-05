import Foundation

// MARK: - EVERSTEAD 0.33
// Native production-chain simulation.

struct EversteadProductionSite: Identifiable, Codable, Hashable {
    let id: UUID
    var buildingID: UUID?
    var recipe: EversteadProductionRecipe
    var progressHours: Double
    var enabled: Bool

    init(
        id: UUID = UUID(),
        buildingID: UUID? = nil,
        recipe: EversteadProductionRecipe,
        progressHours: Double = 0,
        enabled: Bool = true
    ) {
        self.id = id
        self.buildingID = buildingID
        self.recipe = recipe
        self.progressHours = progressHours
        self.enabled = enabled
    }
}

extension EversteadInventory {
    func canConsume(_ goods: [EversteadGood: Double]) -> Bool {
        goods.allSatisfy { amount(of: $0.key) >= $0.value }
    }

    mutating func consume(_ goods: [EversteadGood: Double]) -> Bool {
        guard canConsume(goods) else { return false }
        for (good, quantity) in goods {
            _ = remove(good, amount: quantity)
        }
        return true
    }

    mutating func add(_ goods: [EversteadGood: Double]) {
        for (good, quantity) in goods {
            add(good, amount: quantity)
        }
    }
}

extension EversteadVillageSimulation {
    mutating func runProduction(
        sites: inout [EversteadProductionSite],
        hours: Double
    ) {
        guard hours > 0 else { return }

        for index in sites.indices where sites[index].enabled {
            sites[index].progressHours += hours

            while sites[index].progressHours >= sites[index].recipe.hours {
                let recipe = sites[index].recipe

                guard inventory.consume(recipe.inputs) else {
                    sites[index].progressHours = min(
                        sites[index].progressHours,
                        recipe.hours
                    )
                    break
                }

                inventory.add(recipe.outputs)
                sites[index].progressHours -= recipe.hours
            }
        }
    }
}

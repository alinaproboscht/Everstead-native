import Foundation

// MARK: - EVERSTEAD 0.37
// Public production-chain simulation.

public struct EversteadProductionSite: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var buildingID: UUID?
    public var recipe: EversteadProductionRecipe
    public var progressHours: Double
    public var enabled: Bool

    public init(
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

public extension EversteadInventory {
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

public extension EversteadVillageSimulation {
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

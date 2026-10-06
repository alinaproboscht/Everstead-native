import Foundation

// MARK: - EVERSTEAD 0.37
// Public Living Village models for EversteadCore.

public enum EversteadLifeStage: String, Codable, CaseIterable, Sendable {
    case infant, child, teen, adult, senior
}

public enum EversteadNeedKind: String, Codable, CaseIterable, Sendable {
    case hunger, energy, social, hygiene, fun
}

public struct EversteadNeeds: Codable, Hashable, Sendable {
    public var hunger: Double
    public var energy: Double
    public var social: Double
    public var hygiene: Double
    public var fun: Double

    public init(
        hunger: Double = 85,
        energy: Double = 85,
        social: Double = 75,
        hygiene: Double = 80,
        fun: Double = 70
    ) {
        self.hunger = hunger
        self.energy = energy
        self.social = social
        self.hygiene = hygiene
        self.fun = fun
    }

    public mutating func clamp() {
        hunger = min(100, max(0, hunger))
        energy = min(100, max(0, energy))
        social = min(100, max(0, social))
        hygiene = min(100, max(0, hygiene))
        fun = min(100, max(0, fun))
    }

    public mutating func decay(hours: Double) {
        hunger -= 4.0 * hours
        energy -= 2.6 * hours
        social -= 1.5 * hours
        hygiene -= 1.1 * hours
        fun -= 1.3 * hours
        clamp()
    }

    public var mostUrgent: EversteadNeedKind {
        let values: [(EversteadNeedKind, Double)] = [
            (.hunger, hunger), (.energy, energy), (.social, social),
            (.hygiene, hygiene), (.fun, fun)
        ]
        return values.min(by: { $0.1 < $1.1 })?.0 ?? .hunger
    }
}

public enum EversteadActivity: String, Codable, CaseIterable, Sendable {
    case sleeping, eating, working, shopping, socializing, leisure, travelling, idle
}

public struct EversteadHousehold: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var memberIDs: [UUID]
    public var homeBuildingID: UUID?
    public var money: Double

    public init(
        id: UUID = UUID(),
        name: String,
        memberIDs: [UUID] = [],
        homeBuildingID: UUID? = nil,
        money: Double = 120
    ) {
        self.id = id
        self.name = name
        self.memberIDs = memberIDs
        self.homeBuildingID = homeBuildingID
        self.money = money
    }
}

public struct EversteadResidentLife: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var villagerID: UUID
    public var householdID: UUID?
    public var partnerVillagerID: UUID?
    public var parentVillagerIDs: [UUID]
    public var childVillagerIDs: [UUID]
    public var workplaceBuildingID: UUID?
    public var lifeStage: EversteadLifeStage
    public var ageYears: Int
    public var needs: EversteadNeeds
    public var activity: EversteadActivity

    public init(
        id: UUID = UUID(),
        villagerID: UUID,
        householdID: UUID? = nil,
        partnerVillagerID: UUID? = nil,
        parentVillagerIDs: [UUID] = [],
        childVillagerIDs: [UUID] = [],
        workplaceBuildingID: UUID? = nil,
        lifeStage: EversteadLifeStage = .adult,
        ageYears: Int = 25,
        needs: EversteadNeeds = EversteadNeeds(),
        activity: EversteadActivity = .idle
    ) {
        self.id = id
        self.villagerID = villagerID
        self.householdID = householdID
        self.partnerVillagerID = partnerVillagerID
        self.parentVillagerIDs = parentVillagerIDs
        self.childVillagerIDs = childVillagerIDs
        self.workplaceBuildingID = workplaceBuildingID
        self.lifeStage = lifeStage
        self.ageYears = ageYears
        self.needs = needs
        self.activity = activity
    }
}

public enum EversteadGood: String, Codable, CaseIterable, Sendable {
    case grain, flour, bread, fish, vegetables, wood, tools
}

public struct EversteadInventory: Codable, Hashable, Sendable {
    public private(set) var amounts: [EversteadGood: Double]

    public init(amounts: [EversteadGood: Double] = [:]) {
        self.amounts = amounts
    }

    public func amount(of good: EversteadGood) -> Double {
        amounts[good, default: 0]
    }

    public mutating func add(_ good: EversteadGood, amount: Double) {
        guard amount > 0 else { return }
        amounts[good, default: 0] += amount
    }

    @discardableResult
    public mutating func remove(_ good: EversteadGood, amount: Double) -> Bool {
        guard amount > 0, self.amount(of: good) >= amount else { return false }
        amounts[good, default: 0] -= amount
        return true
    }
}

public struct EversteadProductionRecipe: Codable, Hashable, Sendable {
    public var inputs: [EversteadGood: Double]
    public var outputs: [EversteadGood: Double]
    public var hours: Double

    public init(
        inputs: [EversteadGood: Double],
        outputs: [EversteadGood: Double],
        hours: Double
    ) {
        self.inputs = inputs
        self.outputs = outputs
        self.hours = hours
    }
}

public enum EversteadProduction {
    public static let farm = EversteadProductionRecipe(
        inputs: [:], outputs: [.grain: 6, .vegetables: 3], hours: 6
    )
    public static let mill = EversteadProductionRecipe(
        inputs: [.grain: 4], outputs: [.flour: 3], hours: 3
    )
    public static let bakery = EversteadProductionRecipe(
        inputs: [.flour: 2], outputs: [.bread: 4], hours: 2
    )
    public static let fishing = EversteadProductionRecipe(
        inputs: [:], outputs: [.fish: 3], hours: 4
    )
}

public struct EversteadVillageSimulation: Codable, Sendable {
    public var households: [EversteadHousehold]
    public var residents: [EversteadResidentLife]
    public var inventory: EversteadInventory
    public var elapsedHours: Double

    public init(
        households: [EversteadHousehold] = [],
        residents: [EversteadResidentLife] = [],
        inventory: EversteadInventory = EversteadInventory(),
        elapsedHours: Double = 0
    ) {
        self.households = households
        self.residents = residents
        self.inventory = inventory
        self.elapsedHours = elapsedHours
    }

    public mutating func tick(hours: Double) {
        guard hours > 0 else { return }
        elapsedHours += hours

        for index in residents.indices {
            residents[index].needs.decay(hours: hours)
            residents[index].activity = suggestedActivity(for: residents[index])
        }
    }

    private func suggestedActivity(for resident: EversteadResidentLife) -> EversteadActivity {
        switch resident.needs.mostUrgent {
        case .hunger: return .eating
        case .energy: return .sleeping
        case .social: return .socializing
        case .hygiene: return .idle
        case .fun: return .leisure
        }
    }
}

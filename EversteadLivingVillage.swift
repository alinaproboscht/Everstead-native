import Foundation

// MARK: - EVERSTEAD 0.32
// Living Village simulation layer.
// This file deliberately keeps the simulation independent from RealityKit.

enum EversteadLifeStage: String, Codable, CaseIterable {
    case infant
    case child
    case teen
    case adult
    case senior
}

enum EversteadNeedKind: String, Codable, CaseIterable {
    case hunger
    case energy
    case social
    case hygiene
    case fun
}

struct EversteadNeeds: Codable, Hashable {
    var hunger: Double = 85
    var energy: Double = 85
    var social: Double = 75
    var hygiene: Double = 80
    var fun: Double = 70

    mutating func clamp() {
        hunger = min(100, max(0, hunger))
        energy = min(100, max(0, energy))
        social = min(100, max(0, social))
        hygiene = min(100, max(0, hygiene))
        fun = min(100, max(0, fun))
    }

    mutating func decay(hours: Double) {
        hunger -= 4.0 * hours
        energy -= 2.6 * hours
        social -= 1.5 * hours
        hygiene -= 1.1 * hours
        fun -= 1.3 * hours
        clamp()
    }

    var mostUrgent: EversteadNeedKind {
        let values: [(EversteadNeedKind, Double)] = [
            (.hunger, hunger), (.energy, energy), (.social, social),
            (.hygiene, hygiene), (.fun, fun)
        ]
        return values.min(by: { $0.1 < $1.1 })?.0 ?? .hunger
    }
}

enum EversteadActivity: String, Codable, CaseIterable {
    case sleeping
    case eating
    case working
    case shopping
    case socializing
    case leisure
    case travelling
    case idle
}

struct EversteadHousehold: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var memberIDs: [UUID]
    var homeBuildingID: UUID?
    var money: Double

    init(
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

struct EversteadResidentLife: Identifiable, Codable, Hashable {
    let id: UUID
    var villagerID: UUID
    var householdID: UUID?
    var partnerVillagerID: UUID?
    var parentVillagerIDs: [UUID]
    var childVillagerIDs: [UUID]
    var workplaceBuildingID: UUID?
    var lifeStage: EversteadLifeStage
    var ageYears: Int
    var needs: EversteadNeeds
    var activity: EversteadActivity

    init(
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

enum EversteadGood: String, Codable, CaseIterable {
    case grain
    case flour
    case bread
    case fish
    case vegetables
    case wood
    case tools
}

struct EversteadInventory: Codable, Hashable {
    private(set) var amounts: [EversteadGood: Double] = [:]

    func amount(of good: EversteadGood) -> Double {
        amounts[good, default: 0]
    }

    mutating func add(_ good: EversteadGood, amount: Double) {
        guard amount > 0 else { return }
        amounts[good, default: 0] += amount
    }

    @discardableResult
    mutating func remove(_ good: EversteadGood, amount: Double) -> Bool {
        guard amount > 0, self.amount(of: good) >= amount else { return false }
        amounts[good, default: 0] -= amount
        return true
    }
}

struct EversteadProductionRecipe: Codable, Hashable {
    var inputs: [EversteadGood: Double]
    var outputs: [EversteadGood: Double]
    var hours: Double
}

enum EversteadProduction {
    static let farm = EversteadProductionRecipe(
        inputs: [:],
        outputs: [.grain: 6, .vegetables: 3],
        hours: 6
    )

    static let mill = EversteadProductionRecipe(
        inputs: [.grain: 4],
        outputs: [.flour: 3],
        hours: 3
    )

    static let bakery = EversteadProductionRecipe(
        inputs: [.flour: 2],
        outputs: [.bread: 4],
        hours: 2
    )

    static let fishing = EversteadProductionRecipe(
        inputs: [:],
        outputs: [.fish: 3],
        hours: 4
    )
}

struct EversteadVillageSimulation: Codable {
    var households: [EversteadHousehold] = []
    var residents: [EversteadResidentLife] = []
    var inventory = EversteadInventory()
    var elapsedHours: Double = 0

    mutating func tick(hours: Double) {
        guard hours > 0 else { return }
        elapsedHours += hours

        for index in residents.indices {
            residents[index].needs.decay(hours: hours)
            residents[index].activity = suggestedActivity(for: residents[index])
        }
    }

    private func suggestedActivity(for resident: EversteadResidentLife) -> EversteadActivity {
        switch resident.needs.mostUrgent {
        case .hunger:
            return .eating
        case .energy:
            return .sleeping
        case .social:
            return .socializing
        case .hygiene:
            return .idle
        case .fun:
            return .leisure
        }
    }
}

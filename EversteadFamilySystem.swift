import Foundation

// MARK: - EVERSTEAD 0.37
// Public household and family helpers.

public extension EversteadVillageSimulation {
    @discardableResult
    mutating func createHousehold(
        name: String,
        memberVillagerIDs: [UUID],
        homeBuildingID: UUID? = nil,
        money: Double = 120
    ) -> UUID {
        let household = EversteadHousehold(
            name: name,
            memberIDs: memberVillagerIDs,
            homeBuildingID: homeBuildingID,
            money: money
        )
        households.append(household)

        for index in residents.indices
        where memberVillagerIDs.contains(residents[index].villagerID) {
            residents[index].householdID = household.id
        }

        return household.id
    }

    mutating func setPartners(_ first: UUID, _ second: UUID) {
        guard first != second else { return }

        if let index = residents.firstIndex(where: { $0.villagerID == first }) {
            residents[index].partnerVillagerID = second
        }

        if let index = residents.firstIndex(where: { $0.villagerID == second }) {
            residents[index].partnerVillagerID = first
        }
    }

    mutating func connectParent(_ parent: UUID, child: UUID) {
        if let childIndex = residents.firstIndex(where: { $0.villagerID == child }),
           !residents[childIndex].parentVillagerIDs.contains(parent) {
            residents[childIndex].parentVillagerIDs.append(parent)
        }

        if let parentIndex = residents.firstIndex(where: { $0.villagerID == parent }),
           !residents[parentIndex].childVillagerIDs.contains(child) {
            residents[parentIndex].childVillagerIDs.append(child)
        }
    }

    func household(for villagerID: UUID) -> EversteadHousehold? {
        guard let resident = residents.first(where: { $0.villagerID == villagerID }),
              let householdID = resident.householdID else {
            return nil
        }
        return households.first(where: { $0.id == householdID })
    }
}

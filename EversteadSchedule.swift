import Foundation

// MARK: - EVERSTEAD 0.33
// Daily routines for autonomous residents.

enum EversteadDayPeriod: String, Codable, CaseIterable {
    case night
    case morning
    case workday
    case evening

    static func from(hour: Double) -> EversteadDayPeriod {
        let h = hour.truncatingRemainder(dividingBy: 24)
        switch h {
        case 0..<6: return .night
        case 6..<9: return .morning
        case 9..<18: return .workday
        default: return .evening
        }
    }
}

struct EversteadDailyPlan: Codable, Hashable {
    var wakeHour: Double = 6.5
    var workStartHour: Double = 8.0
    var workEndHour: Double = 17.0
    var sleepHour: Double = 22.0

    func scheduledActivity(
        at hour: Double,
        resident: EversteadResidentLife
    ) -> EversteadActivity {
        let h = hour.truncatingRemainder(dividingBy: 24)

        if resident.needs.energy < 22 || h >= sleepHour || h < wakeHour {
            return .sleeping
        }

        if resident.needs.hunger < 35 {
            return .eating
        }

        if resident.lifeStage == .adult,
           resident.workplaceBuildingID != nil,
           h >= workStartHour,
           h < workEndHour {
            return .working
        }

        if resident.needs.social < 35 {
            return .socializing
        }

        if resident.needs.fun < 40 {
            return .leisure
        }

        if h >= 17.5 && h < 19.5 {
            return .shopping
        }

        return .idle
    }
}

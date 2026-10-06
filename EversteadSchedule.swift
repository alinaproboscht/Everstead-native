import Foundation

// MARK: - EVERSTEAD 0.37
// Public daily routines for autonomous residents.

public enum EversteadDayPeriod: String, Codable, CaseIterable, Sendable {
    case night, morning, workday, evening

    public static func from(hour: Double) -> EversteadDayPeriod {
        let h = hour.truncatingRemainder(dividingBy: 24)
        switch h {
        case 0..<6: return .night
        case 6..<9: return .morning
        case 9..<18: return .workday
        default: return .evening
        }
    }
}

public struct EversteadDailyPlan: Codable, Hashable, Sendable {
    public var wakeHour: Double
    public var workStartHour: Double
    public var workEndHour: Double
    public var sleepHour: Double

    public init(
        wakeHour: Double = 6.5,
        workStartHour: Double = 8.0,
        workEndHour: Double = 17.0,
        sleepHour: Double = 22.0
    ) {
        self.wakeHour = wakeHour
        self.workStartHour = workStartHour
        self.workEndHour = workEndHour
        self.sleepHour = sleepHour
    }

    public func scheduledActivity(
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

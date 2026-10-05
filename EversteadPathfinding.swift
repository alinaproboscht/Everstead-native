import Foundation

// MARK: - EVERSTEAD 0.32
// Road-based navigation foundation for the native RealityKit game.

struct EversteadPathPoint: Hashable {
    var x: Double
    var y: Double

    func distance(to other: EversteadPathPoint) -> Double {
        let dx = x - other.x
        let dy = y - other.y
        return (dx * dx + dy * dy).squareRoot()
    }
}

struct EversteadRoadPath {
    let points: [EversteadPathPoint]

    var isEmpty: Bool { points.isEmpty }
}

/// Lightweight navigation helpers that can be used by the existing EversteadGame.
/// The existing GameModels.swift remains the authoritative source for roads/buildings/villagers.
enum EversteadNavigation {
    static func simplified(_ points: [EversteadPathPoint], tolerance: Double = 0.0025) -> [EversteadPathPoint] {
        guard !points.isEmpty else { return [] }

        var result: [EversteadPathPoint] = []
        for point in points {
            if let last = result.last, last.distance(to: point) <= tolerance {
                continue
            }
            result.append(point)
        }

        guard result.count > 2 else { return result }

        var simplified: [EversteadPathPoint] = [result[0]]
        for index in 1..<(result.count - 1) {
            let a = simplified.last!
            let b = result[index]
            let c = result[index + 1]

            let abx = b.x - a.x
            let aby = b.y - a.y
            let bcx = c.x - b.x
            let bcy = c.y - b.y
            let cross = abs(abx * bcy - aby * bcx)

            if cross > 0.0005 {
                simplified.append(b)
            }
        }
        simplified.append(result[result.count - 1])
        return simplified
    }
}

import Foundation

// MARK: - EVERSTEAD 0.34
// Road graph navigation for the native RealityKit game.

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

enum EversteadNavigation {
    static func simplified(
        _ points: [EversteadPathPoint],
        tolerance: Double = 0.0025
    ) -> [EversteadPathPoint] {
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

private struct EversteadGraphEdge {
    let target: Int
    let cost: Double
}

extension EversteadGame {

    func roadRoute(
        from start: EversteadPathPoint,
        to destination: EversteadPathPoint
    ) -> EversteadRoadPath {

        var nodes: [EversteadPathPoint] = []
        var edges: [[EversteadGraphEdge]] = []

        func addNode(_ point: EversteadPathPoint) -> Int {
            if let index = nodes.firstIndex(where: { $0.distance(to: point) < 0.0035 }) {
                return index
            }
            nodes.append(point)
            edges.append([])
            return nodes.count - 1
        }

        func connect(_ a: Int, _ b: Int) {
            guard a != b else { return }
            let cost = nodes[a].distance(to: nodes[b])
            edges[a].append(EversteadGraphEdge(target: b, cost: cost))
            edges[b].append(EversteadGraphEdge(target: a, cost: cost))
        }

        var roadNodePairs: [(road: EversteadRoad, a: Int, b: Int)] = []

        for road in roads {
            let a = addNode(EversteadPathPoint(x: road.startX, y: road.startY))
            let b = addNode(EversteadPathPoint(x: road.endX, y: road.endY))
            connect(a, b)
            roadNodePairs.append((road, a, b))
        }

        // Connect intersecting/crossing roads and close historic-road gaps.
        for i in roads.indices {
            for j in roads.indices where j > i {
                let first = roads[i]
                let second = roads[j]

                if first.orientation != second.orientation {
                    let horizontal = first.orientation == .horizontal ? first : second
                    let vertical = first.orientation == .vertical ? first : second

                    let minHX = min(horizontal.startX, horizontal.endX) - 0.018
                    let maxHX = max(horizontal.startX, horizontal.endX) + 0.018
                    let minVY = min(vertical.startY, vertical.endY) - 0.018
                    let maxVY = max(vertical.startY, vertical.endY) + 0.018

                    if vertical.centerX >= minHX,
                       vertical.centerX <= maxHX,
                       horizontal.centerY >= minVY,
                       horizontal.centerY <= maxVY {
                        let intersection = addNode(
                            EversteadPathPoint(
                                x: vertical.centerX,
                                y: horizontal.centerY
                            )
                        )

                        let hStart = addNode(EversteadPathPoint(x: horizontal.startX, y: horizontal.startY))
                        let hEnd = addNode(EversteadPathPoint(x: horizontal.endX, y: horizontal.endY))
                        let vStart = addNode(EversteadPathPoint(x: vertical.startX, y: vertical.startY))
                        let vEnd = addNode(EversteadPathPoint(x: vertical.endX, y: vertical.endY))

                        connect(hStart, intersection)
                        connect(intersection, hEnd)
                        connect(vStart, intersection)
                        connect(intersection, vEnd)
                    }
                }
            }
        }

        // Historic market square is an intentional pedestrian hub.
        let marketHub = addNode(EversteadPathPoint(x: 0.50, y: 0.50))
        for index in nodes.indices where index != marketHub {
            let p = nodes[index]
            if p.distance(to: nodes[marketHub]) <= 0.19 {
                connect(index, marketHub)
            }
        }

        guard !nodes.isEmpty else {
            return EversteadRoadPath(points: [destination])
        }

        let startRoadNode = nodes.indices.min {
            nodes[$0].distance(to: start) < nodes[$1].distance(to: start)
        }!

        let endRoadNode = nodes.indices.min {
            nodes[$0].distance(to: destination) < nodes[$1].distance(to: destination)
        }!

        let startNode = addNode(start)
        let destinationNode = addNode(destination)
        connect(startNode, startRoadNode)
        connect(endRoadNode, destinationNode)

        var distances = Array(repeating: Double.greatestFiniteMagnitude, count: nodes.count)
        var previous = Array<Int?>(repeating: nil, count: nodes.count)
        var visited = Set<Int>()
        distances[startNode] = 0

        while visited.count < nodes.count {
            guard let current = nodes.indices
                .filter({ !visited.contains($0) })
                .min(by: { distances[$0] < distances[$1] }),
                  distances[current] < Double.greatestFiniteMagnitude else {
                break
            }

            if current == destinationNode { break }
            visited.insert(current)

            for edge in edges[current] {
                let candidate = distances[current] + edge.cost
                if candidate < distances[edge.target] {
                    distances[edge.target] = candidate
                    previous[edge.target] = current
                }
            }
        }

        guard distances[destinationNode] < Double.greatestFiniteMagnitude else {
            return EversteadRoadPath(points: [destination])
        }

        var indices: [Int] = []
        var cursor: Int? = destinationNode
        while let current = cursor {
            indices.append(current)
            if current == startNode { break }
            cursor = previous[current]
        }

        let route = indices.reversed().map { nodes[$0] }
        return EversteadRoadPath(
            points: EversteadNavigation.simplified(Array(route))
        )
    }
}

import CoreGraphics

final class TerritoryHitTester {
    private let territories: [Territory]
    private var pathCache: [String: CGPath] = [:]

    init(territories: [Territory]) {
        self.territories = territories.filter { $0.parentTerritory == nil }
        buildPathCache()
    }

    /// Hit test: returns territory with lowest disambiguationPriority among all containing polygons.
    func territory(at normalizedPoint: CGPoint) -> Territory? {
        var best: Territory?
        for t in territories {
            guard let path = pathCache[t.id] else { continue }
            guard path.contains(normalizedPoint) else { continue }
            if let current = best {
                if t.disambiguationPriority < current.disambiguationPriority {
                    best = t
                }
            } else {
                best = t
            }
        }
        return best
    }

    /// Returns territories within `radius` normalized units (for disambiguation popup).
    func territoriesNear(_ point: CGPoint, radius: Double = 0.008) -> [Territory] {
        territories.filter { t in
            guard let path = pathCache[t.id] else { return false }
            let expanded = path.copy(strokingWithWidth: CGFloat(radius * 2),
                lineCap: .round, lineJoin: .round, miterLimit: 0)
            return expanded.contains(point)
        }
    }

    private func buildPathCache() {
        for territory in territories {
            guard let polygon = territory.polygon, polygon.count >= 3 else { continue }
            let path = CGMutablePath()
            path.move(to: polygon[0])
            for vertex in polygon.dropFirst() { path.addLine(to: vertex) }
            path.closeSubpath()
            pathCache[territory.id] = path
        }
    }
}

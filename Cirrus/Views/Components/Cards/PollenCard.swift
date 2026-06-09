import SwiftUI

struct PollenCard: WeatherCard {
    let name: String
    let grains: Double?
    var cardID: String { "pollen_\(name)" }
    var title: String { name }
    var icon: String { "leaf.fill" }
    var iconColor: Color { pollenColor }
    var isRelevant: Bool { (grains ?? 0) >= 1 }
    var value: String {
        guard let grains else { return "" }
        let level = PollenLevel(grainsPerM3: grains)
        return "\(Int(grains)) · \(level.displayName)"
    }
    private var pollenColor: Color {
        guard let grains else { return .gray }
        switch PollenLevel(grainsPerM3: grains) {
            case .low: return .green
            case .moderate: return .yellow
            case .high: return .orange
            case .veryHigh: return .red
        }
    }
    var customVisual: AnyView? {
        guard let grains else { return nil }
        let level = PollenLevel(grainsPerM3: grains)
        let levelInt: Int = switch level {
            case .low: 1
            case .moderate: 2
            case .high: 3
            case .veryHigh: 4
        }
        return AnyView(
            SeverityDotsView(level: levelInt, maxLevel: 4, activeColor: pollenColor)
        )
    }
}

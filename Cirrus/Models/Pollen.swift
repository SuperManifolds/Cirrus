import Foundation

struct Pollen: Sendable {
    let alder: Double?
    let birch: Double?
    let grass: Double?
    let mugwort: Double?
    let olive: Double?
    let ragweed: Double?
    let timestamp: Date

    var hasData: Bool {
        [alder, birch, grass, mugwort, olive, ragweed].contains { ($0 ?? 0) > 0 }
    }
}

enum PollenLevel: Sendable {
    case low
    case moderate
    case high
    case veryHigh

    var displayName: String {
        switch self {
            case .low: String(localized: "Low")
            case .moderate: String(localized: "Moderate")
            case .high: String(localized: "High")
            case .veryHigh: String(localized: "Very High")
        }
    }

    init(grainsPerM3: Double) {
        switch grainsPerM3 {
            case ..<10: self = .low
            case 10..<50: self = .moderate
            case 50..<100: self = .high
            default: self = .veryHigh
        }
    }
}

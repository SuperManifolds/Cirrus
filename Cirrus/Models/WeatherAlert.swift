import Foundation

struct WeatherAlert: Sendable, Codable, Identifiable {
    let id: String
    let event: String
    let severity: AlertSeverity
    let headline: String
    let description: String
    let startDate: Date
    let endDate: Date?
    let source: String?
}

enum AlertSeverity: String, Sendable, Codable {
    case extreme
    case severe
    case moderate
    case minor
    case unknown

    var displayName: String {
        switch self {
            case .extreme: String(localized: "Extreme")
            case .severe: String(localized: "Severe")
            case .moderate: String(localized: "Moderate")
            case .minor: String(localized: "Minor")
            case .unknown: String(localized: "Alert")
        }
    }

    var iconColor: String {
        switch self {
            case .extreme: "red"
            case .severe: "orange"
            case .moderate: "yellow"
            case .minor: "blue"
            case .unknown: "gray"
        }
    }
}

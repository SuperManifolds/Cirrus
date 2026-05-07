import Foundation

enum TemperatureUnit: String, Sendable, CaseIterable, Identifiable, Codable {
    case celsius
    case fahrenheit

    var id: String { rawValue }

    var displayName: String {
        switch self {
            case .celsius: String(localized: "Celsius (\u{00B0}C)")
            case .fahrenheit: String(localized: "Fahrenheit (\u{00B0}F)")
        }
    }

    var unitTemperature: UnitTemperature {
        switch self {
            case .celsius: .celsius
            case .fahrenheit: .fahrenheit
        }
    }
}

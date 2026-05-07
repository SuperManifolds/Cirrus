import Foundation

struct AirQuality: Sendable {
    let aqi: Int
    let aqiCategory: AQICategory
    let pm25: Double
    let pm10: Double
    let ozone: Double?
    let nitrogenDioxide: Double?
    let sulphurDioxide: Double?
    let carbonMonoxide: Double?
    let timestamp: Date
}

enum AQICategory: Sendable {
    case good
    case fair
    case moderate
    case poor
    case veryPoor
    case hazardous

    var displayName: String {
        switch self {
            case .good: String(localized: "Good")
            case .fair: String(localized: "Fair")
            case .moderate: String(localized: "Moderate")
            case .poor: String(localized: "Poor")
            case .veryPoor: String(localized: "Very Poor")
            case .hazardous: String(localized: "Hazardous")
        }
    }

    init(europeanAQI: Int) {
        switch europeanAQI {
            case 0...20: self = .good
            case 21...40: self = .fair
            case 41...60: self = .moderate
            case 61...80: self = .poor
            case 81...100: self = .veryPoor
            default: self = .hazardous
        }
    }

    init(usAQI: Int) {
        switch usAQI {
            case 0...50: self = .good
            case 51...100: self = .fair
            case 101...150: self = .moderate
            case 151...200: self = .poor
            case 201...300: self = .veryPoor
            default: self = .hazardous
        }
    }
}

import Foundation

enum WeatherCondition: String, Sendable, CaseIterable, Codable {
    case clear
    case mainlyClear
    case partlyCloudy
    case cloudy
    case fog
    case drizzle
    case freezingDrizzle
    case rain
    case freezingRain
    case heavyRain
    case snow
    case heavySnow
    case sleet
    case snowShowers
    case showers
    case heavyShowers
    case thunderstorm
    case thunderstormWithHail

    var sfSymbol: String {
        switch self {
            case .clear: "sun.max.fill"
            case .mainlyClear: "sun.min.fill"
            case .partlyCloudy: "cloud.sun.fill"
            case .cloudy: "cloud.fill"
            case .fog: "cloud.fog.fill"
            case .drizzle: "cloud.drizzle.fill"
            case .freezingDrizzle: "cloud.sleet.fill"
            case .rain: "cloud.rain.fill"
            case .freezingRain: "cloud.sleet.fill"
            case .heavyRain: "cloud.heavyrain.fill"
            case .snow: "cloud.snow.fill"
            case .heavySnow: "cloud.snow.fill"
            case .sleet: "cloud.sleet.fill"
            case .snowShowers: "cloud.snow.fill"
            case .showers: "cloud.rain.fill"
            case .heavyShowers: "cloud.heavyrain.fill"
            case .thunderstorm: "cloud.bolt.fill"
            case .thunderstormWithHail: "cloud.bolt.rain.fill"
        }
    }

    var sfSymbolNight: String {
        switch self {
            case .clear: "moon.stars.fill"
            case .mainlyClear: "moon.fill"
            case .partlyCloudy: "cloud.moon.fill"
            default: sfSymbol
        }
    }

    func symbol(isDaytime: Bool) -> String {
        isDaytime ? sfSymbol : sfSymbolNight
    }

    var displayName: String {
        switch self {
            case .clear: String(localized: "Clear")
            case .mainlyClear: String(localized: "Mainly Clear")
            case .partlyCloudy: String(localized: "Partly Cloudy")
            case .cloudy: String(localized: "Cloudy")
            case .fog: String(localized: "Foggy")
            case .drizzle: String(localized: "Drizzle")
            case .freezingDrizzle: String(localized: "Freezing Drizzle")
            case .rain: String(localized: "Rain")
            case .freezingRain: String(localized: "Freezing Rain")
            case .heavyRain: String(localized: "Heavy Rain")
            case .snow: String(localized: "Snow")
            case .heavySnow: String(localized: "Heavy Snow")
            case .sleet: String(localized: "Sleet")
            case .snowShowers: String(localized: "Snow Showers")
            case .showers: String(localized: "Showers")
            case .heavyShowers: String(localized: "Heavy Showers")
            case .thunderstorm: String(localized: "Thunderstorm")
            case .thunderstormWithHail: String(localized: "Thunderstorm with Hail")
        }
    }

    init(wmoCode: Int) {
        switch wmoCode {
            case 0: self = .clear
            case 1: self = .mainlyClear
            case 2: self = .partlyCloudy
            case 3: self = .cloudy
            case 45, 48: self = .fog
            case 51, 53, 55: self = .drizzle
            case 56, 57: self = .freezingDrizzle
            case 61, 63: self = .rain
            case 65: self = .heavyRain
            case 66, 67: self = .freezingRain
            case 71, 73: self = .snow
            case 75: self = .heavySnow
            case 77: self = .sleet
            case 80, 81: self = .showers
            case 82: self = .heavyShowers
            case 85, 86: self = .snowShowers
            case 95: self = .thunderstorm
            case 96, 99: self = .thunderstormWithHail
            default: self = .cloudy
        }
    }
}

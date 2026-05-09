import Foundation

enum PrecipitationType: String, Sendable, Codable {
    case rain
    case snow
    case sleet
    case none
}

struct MinuteForecast: Sendable, Codable, Identifiable {
    let date: Date
    let precipitationIntensity: Double
    let precipitationChance: Double
    let precipitationType: PrecipitationType?

    var id: Date { date }
}

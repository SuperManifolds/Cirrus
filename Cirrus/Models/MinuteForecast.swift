import Foundation

struct MinuteForecast: Sendable, Identifiable {
    let date: Date
    let precipitationIntensity: Double
    let precipitationChance: Double

    var id: Date { date }
}

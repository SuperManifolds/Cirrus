import Foundation

struct DailyForecast: Sendable, Identifiable {
    let date: Date
    let highTemperature: Measurement<UnitTemperature>
    let lowTemperature: Measurement<UnitTemperature>
    let condition: WeatherCondition
    let precipitationProbability: Double
    let precipitationSum: Measurement<UnitLength>
    let rainSum: Measurement<UnitLength>?
    let snowfallSum: Measurement<UnitLength>?
    let uvIndexMax: Double
    let windSpeedMax: Measurement<UnitSpeed>
    let windDirectionDominant: Double?
    let sunrise: Date?
    let sunset: Date?

    var id: Date { date }
}

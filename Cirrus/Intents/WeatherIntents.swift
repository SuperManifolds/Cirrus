import AppIntents
import Foundation

// MARK: - Errors

enum WeatherIntentError: Error, CustomLocalizedStringResourceConvertible {
    case appNotRunning
    case noWeatherData

    var localizedStringResource: LocalizedStringResource {
        switch self {
            case .appNotRunning: "Cirrus is not running."
            case .noWeatherData: "No weather data available. Open Cirrus first."
        }
    }
}

// MARK: - Get Current Weather

struct GetCurrentWeather: AppIntent {
    static var title: LocalizedStringResource = "Get Current Weather"
    static var description = IntentDescription("Get the current weather conditions.")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let vm = AppState.shared.weatherViewModel else {
            throw WeatherIntentError.appNotRunning
        }

        guard let snapshot = vm.snapshot else {
            throw WeatherIntentError.noWeatherData
        }

        let unit = vm.temperatureUnit
        let current = snapshot.current
        let temp = current.temperature.formatted(as: unit)
        let feelsLike = current.apparentTemperature.formatted(as: unit)
        let condition = current.condition.displayName
        let location = snapshot.location.name

        return .result(
            dialog: "\(location): \(temp), \(condition). Feels like \(feelsLike)."
        )
    }
}

// MARK: - Get Temperature

struct GetTemperature: AppIntent {
    static var title: LocalizedStringResource = "Get Temperature"
    static var description = IntentDescription("Get the current temperature.")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let vm = AppState.shared.weatherViewModel else {
            throw WeatherIntentError.appNotRunning
        }

        guard let snapshot = vm.snapshot else {
            throw WeatherIntentError.noWeatherData
        }

        let temp = snapshot.current.temperature.formatted(as: vm.temperatureUnit)
        let location = snapshot.location.name

        return .result(dialog: "It's \(temp) in \(location).")
    }
}

// MARK: - Get Forecast

struct GetForecast: AppIntent {
    static var title: LocalizedStringResource = "Get Forecast"
    static var description = IntentDescription("Get today's weather forecast.")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let vm = AppState.shared.weatherViewModel else {
            throw WeatherIntentError.appNotRunning
        }

        guard let snapshot = vm.snapshot else {
            throw WeatherIntentError.noWeatherData
        }

        let unit = vm.temperatureUnit
        let location = snapshot.location.name

        guard let today = snapshot.daily.first else {
            let temp = snapshot.current.temperature.formatted(as: unit)
            return .result(dialog: "\(location): Currently \(temp).")
        }

        let high = today.highTemperature.formatted(as: unit)
        let low = today.lowTemperature.formatted(as: unit)
        let condition = today.condition.displayName

        let precip = today.precipitationProbability > 20
            ? " \(Int(today.precipitationProbability))% chance of precipitation."
            : ""

        return .result(
            dialog: "\(location): \(condition), high of \(high), low of \(low).\(precip)"
        )
    }
}

// MARK: - Will It Rain

struct WillItRain: AppIntent {
    static var title: LocalizedStringResource = "Will It Rain"
    static var description = IntentDescription("Check if rain is expected.")
    static var openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let vm = AppState.shared.weatherViewModel else {
            throw WeatherIntentError.appNotRunning
        }

        guard let snapshot = vm.snapshot else {
            throw WeatherIntentError.noWeatherData
        }

        // Check minutely data first
        if let minutely = snapshot.minutely,
           let firstRain = minutely.first(where: { $0.precipitationIntensity > 0 }) {
            let time = firstRain.date.formatted(date: .omitted, time: .shortened)
            if firstRain.date <= Date() {
                return .result(dialog: "Yes, it's raining now.")
            }
            return .result(dialog: "Rain is expected around \(time).")
        }

        // Check hourly precipitation probability
        let rainyHours = snapshot.hourly.filter { $0.precipitationProbability > 50 }
        if let firstRainy = rainyHours.first {
            let time = firstRainy.date.formatted(.dateTime.hour())
            let chance = Int(firstRainy.precipitationProbability)
            return .result(dialog: "There's a \(chance)% chance of rain around \(time).")
        }

        return .result(dialog: "No rain is expected in the coming hours.")
    }
}

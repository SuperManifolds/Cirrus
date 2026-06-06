import Foundation

@MainActor
final class AppState {
    static let shared = AppState()

    var weatherViewModel: WeatherViewModel?
    var settingsViewModel: SettingsViewModel?

    private init() {}
}

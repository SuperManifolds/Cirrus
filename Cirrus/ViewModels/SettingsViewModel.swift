import Combine
import Foundation
import OSLog
import ServiceManagement
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var temperatureUnit: TemperatureUnit {
        didSet { UserDefaults.standard.set(temperatureUnit.rawValue, forKey: Keys.temperatureUnit) }
    }

    @Published var weatherProvider: WeatherProviderKind {
        didSet { UserDefaults.standard.set(weatherProvider.rawValue, forKey: Keys.weatherProvider) }
    }

    @Published var menuBarDisplayMode: MenuBarDisplayMode {
        didSet { UserDefaults.standard.set(menuBarDisplayMode.rawValue, forKey: Keys.menuBarDisplayMode) }
    }

    @Published var refreshInterval: RefreshInterval {
        didSet { UserDefaults.standard.set(refreshInterval.rawValue, forKey: Keys.refreshInterval) }
    }

    @Published var useCurrentLocation: Bool {
        didSet { UserDefaults.standard.set(useCurrentLocation, forKey: Keys.useCurrentLocation) }
    }

    @Published var pinnedLocation: Location? {
        didSet {
            if let data = try? JSONEncoder().encode(pinnedLocation) {
                UserDefaults.standard.set(data, forKey: Keys.pinnedLocation)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.pinnedLocation)
            }
        }
    }

    @Published var favoriteLocations: [Location] {
        didSet {
            if let data = try? JSONEncoder().encode(favoriteLocations) {
                UserDefaults.standard.set(data, forKey: Keys.favoriteLocations)
            }
        }
    }

    @Published var coloredMenuBarIcon: Bool {
        didSet { UserDefaults.standard.set(coloredMenuBarIcon, forKey: Keys.coloredMenuBarIcon) }
    }

    @Published var showAirQuality: Bool {
        didSet { UserDefaults.standard.set(showAirQuality, forKey: Keys.showAirQuality) }
    }

    @Published var showAISummary: Bool {
        didSet { UserDefaults.standard.set(showAISummary, forKey: Keys.showAISummary) }
    }

    @Published var showNotifications: Bool {
        didSet { UserDefaults.standard.set(showNotifications, forKey: Keys.showNotifications) }
    }

    @Published var hiddenCardIDs: Set<String> {
        didSet {
            if let data = try? JSONEncoder().encode(hiddenCardIDs) {
                UserDefaults.standard.set(data, forKey: Keys.hiddenCardIDs)
            }
        }
    }

    @Published var launchAtLogin: Bool {
        didSet { updateLaunchAtLogin() }
    }

    init() {
        let defaults = UserDefaults.standard

        temperatureUnit = TemperatureUnit(
            rawValue: defaults.string(forKey: Keys.temperatureUnit) ?? ""
        ) ?? .celsius

        weatherProvider = WeatherProviderKind(
            rawValue: defaults.string(forKey: Keys.weatherProvider) ?? ""
        ) ?? .openMeteo

        menuBarDisplayMode = MenuBarDisplayMode(
            rawValue: defaults.string(forKey: Keys.menuBarDisplayMode) ?? ""
        ) ?? .iconAndTemperature

        refreshInterval = RefreshInterval(
            rawValue: defaults.integer(forKey: Keys.refreshInterval)
        ) ?? .tenMinutes

        useCurrentLocation = defaults.object(forKey: Keys.useCurrentLocation) == nil
            ? true
            : defaults.bool(forKey: Keys.useCurrentLocation)

        if let data = defaults.data(forKey: Keys.pinnedLocation) {
            pinnedLocation = try? JSONDecoder().decode(Location.self, from: data)
        } else {
            pinnedLocation = nil
        }

        if let data = defaults.data(forKey: Keys.favoriteLocations) {
            favoriteLocations = (try? JSONDecoder().decode([Location].self, from: data)) ?? []
        } else {
            favoriteLocations = []
        }

        coloredMenuBarIcon = defaults.bool(forKey: Keys.coloredMenuBarIcon)

        showAirQuality = defaults.object(forKey: Keys.showAirQuality) == nil
            ? true
            : defaults.bool(forKey: Keys.showAirQuality)

        showAISummary = defaults.object(forKey: Keys.showAISummary) == nil
            ? true
            : defaults.bool(forKey: Keys.showAISummary)

        showNotifications = defaults.object(forKey: Keys.showNotifications) == nil
            ? true
            : defaults.bool(forKey: Keys.showNotifications)

        if let data = defaults.data(forKey: Keys.hiddenCardIDs) {
            hiddenCardIDs = (try? JSONDecoder().decode(Set<String>.self, from: data)) ?? []
        } else {
            hiddenCardIDs = []
        }

        launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            Log.settings.error("Launch at login failed: \(error.localizedDescription)")
        }
    }

    static let maxFavorites = 5

    func addFavorite(_ location: Location) {
        guard !favoriteLocations.contains(where: { $0.id == location.id }) else { return }
        var updated = favoriteLocations
        if updated.count >= Self.maxFavorites {
            updated.removeLast()
        }
        updated.append(location)
        favoriteLocations = updated
    }

    func removeFavorite(_ location: Location) {
        favoriteLocations.removeAll { $0.id == location.id }
    }

    func isFavorite(_ location: Location) -> Bool {
        favoriteLocations.contains { $0.id == location.id }
    }

    private enum Keys {
        static let temperatureUnit = "temperatureUnit"
        static let weatherProvider = "weatherProvider"
        static let menuBarDisplayMode = "menuBarDisplayMode"
        static let refreshInterval = "refreshInterval"
        static let useCurrentLocation = "useCurrentLocation"
        static let pinnedLocation = "pinnedLocation"
        static let coloredMenuBarIcon = "coloredMenuBarIcon"
        static let showAirQuality = "showAirQuality"
        static let favoriteLocations = "favoriteLocations"
        static let showAISummary = "showAISummary"
        static let showNotifications = "showNotifications"
        static let hiddenCardIDs = "hiddenCardIDs"
    }

    #if DEBUG
    static func preview() -> SettingsViewModel {
        SettingsViewModel()
    }
    #endif
}

// MARK: - Display Mode

enum MenuBarDisplayMode: String, CaseIterable, Identifiable, Sendable {
    case iconOnly = "icon_only"
    case iconAndTemperature = "icon_and_temperature"
    case iconAndFeelsLike = "icon_and_feels_like"
    case iconTemperatureAndCondition = "icon_temperature_and_condition"

    var id: String { rawValue }

    var displayName: String {
        switch self {
            case .iconOnly: String(localized: "Icon Only")
            case .iconAndTemperature: String(localized: "Icon & Temperature")
            case .iconAndFeelsLike: String(localized: "Icon & Feels Like")
            case .iconTemperatureAndCondition: String(localized: "Icon, Temperature & Condition")
        }
    }
}

// MARK: - Refresh Interval

enum RefreshInterval: Int, CaseIterable, Identifiable, Sendable {
    case fiveMinutes = 300
    case tenMinutes = 600
    case fifteenMinutes = 900
    case thirtyMinutes = 1800

    var id: Int { rawValue }

    var displayName: String {
        switch self {
            case .fiveMinutes: String(localized: "5 minutes")
            case .tenMinutes: String(localized: "10 minutes")
            case .fifteenMinutes: String(localized: "15 minutes")
            case .thirtyMinutes: String(localized: "30 minutes")
        }
    }

    var duration: Duration {
        .seconds(rawValue)
    }
}

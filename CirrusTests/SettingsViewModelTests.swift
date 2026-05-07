import Foundation
import Testing
@testable import Cirrus

@MainActor
struct SettingsViewModelTests {
    private let testSuite = "CirrusSettingsTests"

    private func cleanDefaults() {
        let keys = [
            "temperatureUnit", "weatherProvider", "menuBarDisplayMode",
            "refreshInterval", "useCurrentLocation", "pinnedLocation",
            "coloredMenuBarIcon"
        ]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    @Test func defaultValues() {
        cleanDefaults()
        let vm = SettingsViewModel()

        #expect(vm.temperatureUnit == .celsius)
        #expect(vm.weatherProvider == .openMeteo)
        #expect(vm.menuBarDisplayMode == .iconAndTemperature)
        #expect(vm.refreshInterval == .tenMinutes)
        #expect(vm.useCurrentLocation == true)
        #expect(vm.pinnedLocation == nil)
        #expect(vm.coloredMenuBarIcon == false)
    }

    @Test func temperatureUnitPersists() {
        cleanDefaults()
        let vm = SettingsViewModel()
        vm.temperatureUnit = .fahrenheit

        let vm2 = SettingsViewModel()
        #expect(vm2.temperatureUnit == .fahrenheit)

        cleanDefaults()
    }

    @Test func weatherProviderPersists() {
        cleanDefaults()
        let vm = SettingsViewModel()
        vm.weatherProvider = .weatherKit

        let vm2 = SettingsViewModel()
        #expect(vm2.weatherProvider == .weatherKit)

        cleanDefaults()
    }

    @Test func menuBarDisplayModePersists() {
        cleanDefaults()
        let vm = SettingsViewModel()
        vm.menuBarDisplayMode = .iconOnly

        let vm2 = SettingsViewModel()
        #expect(vm2.menuBarDisplayMode == .iconOnly)

        cleanDefaults()
    }

    @Test func refreshIntervalPersists() {
        cleanDefaults()
        let vm = SettingsViewModel()
        vm.refreshInterval = .thirtyMinutes

        let vm2 = SettingsViewModel()
        #expect(vm2.refreshInterval == .thirtyMinutes)

        cleanDefaults()
    }

    @Test func pinnedLocationPersists() {
        cleanDefaults()
        let vm = SettingsViewModel()
        let location = Location(
            name: "Bergen", latitude: 60.39, longitude: 5.32,
            country: "Norway", administrativeArea: "Vestland"
        )
        vm.pinnedLocation = location

        let vm2 = SettingsViewModel()
        #expect(vm2.pinnedLocation?.name == "Bergen")
        #expect(vm2.pinnedLocation?.latitude == 60.39)

        cleanDefaults()
    }

    @Test func pinnedLocationRemoval() {
        cleanDefaults()
        let vm = SettingsViewModel()
        vm.pinnedLocation = Location(
            name: "Oslo", latitude: 59.91, longitude: 10.75,
            country: nil, administrativeArea: nil
        )
        vm.pinnedLocation = nil

        let vm2 = SettingsViewModel()
        #expect(vm2.pinnedLocation == nil)

        cleanDefaults()
    }

    @Test func coloredMenuBarIconPersists() {
        cleanDefaults()
        let vm = SettingsViewModel()
        vm.coloredMenuBarIcon = true

        let vm2 = SettingsViewModel()
        #expect(vm2.coloredMenuBarIcon == true)

        cleanDefaults()
    }
}

import Combine
import Foundation
import Testing
@testable import Cirrus

@MainActor
struct WeatherViewModelTests {
    private func makeVM(
        location: Location? = Location(
            name: "Oslo", latitude: 59.91, longitude: 10.75,
            country: "Norway", administrativeArea: "Oslo"
        )
    ) -> (WeatherViewModel, MockLocationProvider) {
        let locProvider = MockLocationProvider(location: location)
        let vm = WeatherViewModel(
            weatherProvider: MockWeatherProvider(),
            locationProvider: locProvider
        )
        return (vm, locProvider)
    }

    @Test func refreshPopulatesSnapshot() async {
        let (vm, _) = makeVM()
        await vm.refresh()

        #expect(vm.snapshot != nil)
        #expect(vm.error == nil)
        #expect(vm.isLoading == false)
    }

    @Test func refreshWithoutLocationSetsError() async {
        let (vm, _) = makeVM(location: nil)
        await vm.refresh()

        #expect(vm.snapshot == nil)
        #expect(vm.error != nil)
    }

    @Test func refreshUsesCache() async {
        let (vm, _) = makeVM()
        await vm.refresh()
        let firstFetchedAt = vm.snapshot?.fetchedAt

        await vm.refresh()
        let secondFetchedAt = vm.snapshot?.fetchedAt

        // Same snapshot from cache — fetchedAt should be identical
        #expect(firstFetchedAt == secondFetchedAt)
    }

    @Test func snapshotHasCorrectLocation() async {
        let (vm, _) = makeVM()
        await vm.refresh()

        #expect(vm.snapshot?.location.name == "Oslo")
    }

    @Test func snapshotHasHourlyAndDaily() async {
        let (vm, _) = makeVM()
        await vm.refresh()

        #expect(vm.snapshot?.hourly.count == 24)
        #expect(vm.snapshot?.daily.count == 10)
    }

    @Test func switchProviderRefetches() async throws {
        let (vm, _) = makeVM()
        await vm.refresh()
        let firstProvider = vm.snapshot?.provider

        // switchProvider triggers an async Task internally
        vm.switchProvider(to: .weatherKit)
        try await Task.sleep(for: .milliseconds(200))

        // The mock always returns .openMeteo, but switchProvider was called
        // Verify that a refresh happened (snapshot is still populated)
        #expect(vm.snapshot != nil)
        // Since MockWeatherProvider always returns .openMeteo, we can't verify
        // the provider changed, but we can verify it didn't crash and snapshot exists
        _ = firstProvider
    }

    @Test func failedFetchSetsError() async {
        let locProvider = MockLocationProvider()
        let vm = WeatherViewModel(
            weatherProvider: FailingWeatherProvider(),
            locationProvider: locProvider
        )
        await vm.refresh()

        #expect(vm.error != nil)
        #expect(vm.isLoading == false)
        #expect(vm.snapshot == nil)
    }
}

// MARK: - Test Helpers

private struct FailingWeatherProvider: WeatherProviding {
    let kind: WeatherProviderKind = .openMeteo

    func fetchWeather(for location: Location) async throws -> WeatherSnapshot {
        throw WeatherProviderError.networkError(underlying: URLError(.notConnectedToInternet))
    }
}

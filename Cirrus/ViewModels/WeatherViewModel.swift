import Combine
import Foundation
import OSLog

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published private(set) var snapshot: WeatherSnapshot?
    @Published private(set) var airQuality: AirQuality?
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?

    private var weatherProvider: any WeatherProviding
    private let locationProvider: any LocationProviding
    private let airQualityProvider: any AirQualityProviding
    private let cache: WeatherCacheService
    private var refreshTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    var activeLocation: Location? {
        locationProvider.currentLocation
    }

    init(
        weatherProvider: any WeatherProviding,
        locationProvider: any LocationProviding,
        airQualityProvider: any AirQualityProviding = OpenMeteoAirQualityService(),
        cache: WeatherCacheService = WeatherCacheService()
    ) {
        self.weatherProvider = weatherProvider
        self.locationProvider = locationProvider
        self.airQualityProvider = airQualityProvider
        self.cache = cache

        locationProvider.currentLocationPublisher
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] location in
                guard let self, location != nil else { return }
                Task { await self.refresh() }
            }
            .store(in: &cancellables)
    }

    func refresh() async {
        guard let location = locationProvider.currentLocation else {
            error = WeatherProviderError.locationUnavailable.localizedDescription
            return
        }

        if let cached = await cache.get(for: location) {
            snapshot = cached
            return
        }

        isLoading = true
        error = nil

        do {
            async let weatherFetch = weatherProvider.fetchWeather(for: location)
            async let aqFetch = airQualityProvider.fetchAirQuality(for: location)

            let result = try await weatherFetch
            snapshot = result
            await cache.store(result)
            airQuality = try? await aqFetch
            Log.weather.debug("Fetched weather for \(location.name)")
        } catch {
            self.error = error.localizedDescription
            Log.weather.error("Weather fetch failed: \(error.localizedDescription)")
        }

        isLoading = false
    }

    func switchProvider(to kind: WeatherProviderKind) {
        switch kind {
            case .openMeteo:
                weatherProvider = OpenMeteoService()
            case .weatherKit:
                weatherProvider = WeatherKitService()
        }
        Task {
            await cache.invalidate()
            await refresh()
        }
    }

    func startAutoRefresh(interval: Duration) {
        stopAutoRefresh()
        refreshTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: interval)
                await self?.refresh()
            }
        }
    }

    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    #if DEBUG
    static func preview() -> WeatherViewModel {
        let vm = WeatherViewModel(
            weatherProvider: MockWeatherProvider(),
            locationProvider: MockLocationProvider()
        )
        Task { await vm.refresh() }
        return vm
    }
    #endif
}

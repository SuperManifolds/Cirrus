import Combine
import Foundation
import OSLog

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published private(set) var snapshot: WeatherSnapshot?
    @Published private(set) var airQuality: AirQuality?
    @Published private(set) var pollen: Pollen?
    @Published private(set) var summary: String?
    @Published private(set) var isLoading = false
    var enableAISummary = true
    var enableNotifications = true
    var temperatureUnit: TemperatureUnit = .celsius
    @Published private(set) var error: String?

    private var weatherProvider: any WeatherProviding
    private let locationProvider: any LocationProviding
    private let airQualityProvider: any AirQualityProviding
    private let pollenProvider: any PollenProviding
    private let summaryService = WeatherSummaryService()
    private let notificationService = NotificationService()
    private let cache: WeatherCacheService
    private var previousAlertIDs: Set<String> = []
    private var previousHadRain = false
    private var refreshTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    var activeLocation: Location? {
        locationProvider.currentLocation
    }

    init(
        weatherProvider: any WeatherProviding,
        locationProvider: any LocationProviding,
        airQualityProvider: any AirQualityProviding = OpenMeteoAirQualityService(),
        pollenProvider: any PollenProviding = OpenMeteoPollenService(),
        cache: WeatherCacheService = WeatherCacheService()
    ) {
        self.weatherProvider = weatherProvider
        self.locationProvider = locationProvider
        self.airQualityProvider = airQualityProvider
        self.pollenProvider = pollenProvider
        self.cache = cache

        locationProvider.currentLocationPublisher
            .receive(on: RunLoop.main)
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

        let useCache = await cache.get(for: location)
        if let cached = useCache {
            snapshot = cached
        }

        if useCache == nil {
            isLoading = true
            error = nil
        }

        await fetchFresh(for: location, skipWeather: useCache != nil)

        if useCache == nil {
            isLoading = false
        }
    }

    private func fetchFresh(for location: Location, skipWeather: Bool = false) async {
        do {
            if !skipWeather {
                async let weatherFetch = weatherProvider.fetchWeather(for: location)
                async let aqFetch = airQualityProvider.fetchAirQuality(for: location)
                async let pollenFetch = pollenProvider.fetchPollen(for: location)

                let result = try await weatherFetch
                snapshot = result
                await cache.store(result)
                airQuality = try? await aqFetch
                pollen = try? await pollenFetch
            } else {
                async let aqFetch = airQualityProvider.fetchAirQuality(for: location)
                async let pollenFetch = pollenProvider.fetchPollen(for: location)
                airQuality = try? await aqFetch
                pollen = try? await pollenFetch
            }
            Log.weather.debug("Fetched data for \(location.name)")

            if let currentSnapshot = snapshot {
                if enableAISummary && !skipWeather {
                    summary = await summaryService.generateSummary(
                        from: currentSnapshot,
                        airQuality: airQuality,
                        pollen: pollen,
                        unit: temperatureUnit
                    )
                }

                if enableNotifications && !skipWeather {
                    checkNotifications(result: currentSnapshot, pollen: pollen)
                }
            }
        } catch {
            self.error = error.localizedDescription
            Log.weather.error("Weather fetch failed: \(error.localizedDescription)")
        }
    }

    private func checkNotifications(result: WeatherSnapshot, pollen: Pollen?) {
        // New weather alerts
        let currentAlertIDs = Set(result.alerts.map(\.id))
        let newAlertIDs = currentAlertIDs.subtracting(previousAlertIDs)
        for alert in result.alerts where newAlertIDs.contains(alert.id) {
            notificationService.postWeatherAlert(alert)
        }
        previousAlertIDs = currentAlertIDs

        // Rain warning
        let hasRain = result.minutely?.contains { $0.precipitationIntensity > 0 } ?? false
        if hasRain && !previousHadRain {
            if let minutely = result.minutely,
               let firstRain = minutely.first(where: { $0.precipitationIntensity > 0 }) {
                let time = firstRain.date.formatted(date: .omitted, time: .shortened)
                notificationService.postRainWarning(
                    summary: String(localized: "Rain expected around \(time)")
                )
            }
        }
        previousHadRain = hasRain

        // Pollen alerts (once per type per calendar day)
        if let pollen {
            let today = Calendar.current.startOfDay(for: Date())
            let types: [(String, Double?)] = [
                ("Birch", pollen.birch),
                ("Grass", pollen.grass),
                ("Alder", pollen.alder)
            ]
            for (name, value) in types {
                guard let amount = value else { continue }
                let level = PollenLevel(grainsPerM3: amount)
                guard level == .high || level == .veryHigh else { continue }

                let key = "lastPollenNotification_\(name)"
                let lastNotified = UserDefaults.standard.object(forKey: key) as? Date ?? .distantPast
                guard lastNotified < today else { continue }

                notificationService.postPollenAlert(type: name, level: level)
                UserDefaults.standard.set(Date(), forKey: key)
            }
        }
    }

    func switchProvider(to kind: WeatherProviderKind) {
        weatherProvider = WeatherProviderRegistry.provider(for: kind)
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

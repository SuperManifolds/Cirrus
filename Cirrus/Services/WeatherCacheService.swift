import Foundation

actor WeatherCacheService {
    private var cache: [String: WeatherSnapshot] = [:]
    private let maxAge: TimeInterval

    init(maxAge: TimeInterval = WeatherDefaults.cacheMaxAge) {
        self.maxAge = maxAge
    }

    func get(for location: Location) -> WeatherSnapshot? {
        let key = cacheKey(for: location)
        guard let snapshot = cache[key] else { return nil }
        guard Date().timeIntervalSince(snapshot.fetchedAt) < maxAge else {
            cache.removeValue(forKey: key)
            return nil
        }
        return snapshot
    }

    func store(_ snapshot: WeatherSnapshot) {
        let key = cacheKey(for: snapshot.location)
        cache[key] = snapshot
    }

    func invalidate() {
        cache.removeAll()
    }

    private func cacheKey(for location: Location) -> String {
        let lat = (location.latitude * 100).rounded() / 100
        let lon = (location.longitude * 100).rounded() / 100
        return "\(lat),\(lon)"
    }
}

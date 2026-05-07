import Foundation
import OSLog

actor WeatherCacheService {
    private var cache: [String: WeatherSnapshot] = [:]
    private let maxAge: TimeInterval
    private let diskURL: URL?

    init(maxAge: TimeInterval = WeatherDefaults.cacheMaxAge, persistToDisk: Bool = true) {
        self.maxAge = maxAge
        let url = persistToDisk ? Self.cacheFileURL() : nil
        self.diskURL = url
        if let url,
           let data = try? Data(contentsOf: url),
           let loaded = try? JSONDecoder().decode([String: WeatherSnapshot].self, from: data) {
            let now = Date()
            self.cache = loaded.filter { now.timeIntervalSince($0.value.fetchedAt) < maxAge }
        }
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
        saveToDisk()
    }

    func invalidate() {
        cache.removeAll()
        saveToDisk()
    }

    private func cacheKey(for location: Location) -> String {
        let lat = (location.latitude * 100).rounded() / 100
        let lon = (location.longitude * 100).rounded() / 100
        return "\(lat),\(lon)"
    }

    // MARK: - Disk Persistence

    private static func cacheFileURL() -> URL? {
        FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(AppIdentifiers.bundleID)
            .appendingPathComponent("weather_cache.json")
    }

    private func saveToDisk() {
        guard let url = diskURL else { return }
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try JSONEncoder().encode(cache)
            try data.write(to: url, options: .atomic)
        } catch {
            Log.weather.error("Cache write failed: \(error.localizedDescription)")
        }
    }

}

import Foundation

enum AppIdentifiers: Sendable {
    nonisolated static let bundleID = "io.sorlie.Cirrus"
}

enum WeatherDefaults: Sendable {
    nonisolated static let refreshInterval: TimeInterval = 600
    nonisolated static let cacheMaxAge: TimeInterval = 600
    nonisolated static let popoverWidth: CGFloat = 320
}

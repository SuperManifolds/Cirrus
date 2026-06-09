import OSLog

enum Log: Sendable {
    nonisolated static let weather = Logger(subsystem: AppIdentifiers.bundleID, category: "weather")
    nonisolated static let location = Logger(subsystem: AppIdentifiers.bundleID, category: "location")
    nonisolated static let api = Logger(subsystem: AppIdentifiers.bundleID, category: "api")
    nonisolated static let settings = Logger(subsystem: AppIdentifiers.bundleID, category: "settings")
}

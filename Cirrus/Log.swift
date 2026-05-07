import OSLog

enum Log {
    static let weather = Logger(subsystem: AppIdentifiers.bundleID, category: "weather")
    static let location = Logger(subsystem: AppIdentifiers.bundleID, category: "location")
    static let api = Logger(subsystem: AppIdentifiers.bundleID, category: "api")
    static let settings = Logger(subsystem: AppIdentifiers.bundleID, category: "settings")
}

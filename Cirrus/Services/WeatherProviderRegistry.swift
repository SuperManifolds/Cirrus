import Foundation

enum WeatherProviderRegistry {
    static func provider(for kind: WeatherProviderKind) -> any WeatherProviding {
        providers.first { $0.kind == kind } ?? OpenMeteoService()
    }

    static let providers: [any WeatherProviding] = [
        OpenMeteoService(),
        WeatherKitService()
    ]
}

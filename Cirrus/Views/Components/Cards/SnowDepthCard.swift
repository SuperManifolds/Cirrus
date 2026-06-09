import SwiftUI

struct SnowDepthCard: WeatherCard {
    let current: CurrentWeather
    var cardID: String { "snowDepth" }
    var title: String { String(localized: "Snow Depth") }
    var icon: String { "snowflake" }
    var iconColor: Color { .blue }
    var isRelevant: Bool {
        guard let depth = current.snowDepth else { return false }
        return depth.converted(to: .centimeters).value >= 1
    }
    var value: String {
        current.snowDepth?.formattedSnowDepth ?? ""
    }
    var customVisual: AnyView? {
        guard let depth = current.snowDepth else { return nil }
        let cm = depth.converted(to: .centimeters).value
        return AnyView(
            DepthBarView(depth: cm, maxDepth: 50)
                .frame(width: LayoutConstants.Size.depthBarWidth, height: LayoutConstants.Size.depthBarHeight)
        )
    }
}

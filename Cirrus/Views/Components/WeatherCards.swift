import SwiftUI

enum CardVisualPlacement {
    case inline
    case fullWidth
}

protocol WeatherCard {
    var cardID: String { get }
    var title: String { get }
    var value: String { get }
    var icon: String { get }
    var iconColor: Color { get }
    var isRelevant: Bool { get }
    var directionDegrees: Double? { get }
    var trendValues: [Double]? { get }
    var trendColor: Color? { get }
    var customVisual: AnyView? { get }
    var visualPlacement: CardVisualPlacement { get }
}

extension WeatherCard {
    var directionDegrees: Double? { nil }
    var trendValues: [Double]? { nil }
    var trendColor: Color? { nil }
    var customVisual: AnyView? { nil }
    var visualPlacement: CardVisualPlacement { .inline }
}

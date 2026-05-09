import SwiftUI

enum LayoutConstants {
    enum CornerRadius {
        static let card: CGFloat = 8
        static let button: CGFloat = 6
        static let searchField: CGFloat = 6
        static let hourlyRow: CGFloat = 4
        static let depthBar: CGFloat = 2
    }

    enum Spacing {
        static let cardGrid: CGFloat = 6
        static let sectionGap: CGFloat = 10
        static let severityDots: CGFloat = 3
        static let hourlyRow: CGFloat = 4
    }

    enum Padding {
        static let card: CGFloat = 8
        static let footer: CGFloat = 8
        static let sectionVertical: CGFloat = 14
        static let sectionHorizontal: CGFloat = 8
        static let searchField: CGFloat = 6
        static let precipChart: CGFloat = 12
        static let precipChartVertical: CGFloat = 8
        static let errorState: CGFloat = 20
    }

    enum Offset {
        static let searchDropdown: CGFloat = 36
    }

    enum Size {
        static let conditionIcon: CGFloat = 36
        static let conditionTemperature: CGFloat = 34
        static let hourlyIcon: CGFloat = 18
        static let hourlyColumnWidth: CGFloat = 44
        static let hourlyScrollHeight: CGFloat = 90
        static let hourlyTimeHeight: CGFloat = 14
        static let hourlyTempHeight: CGFloat = 14
        static let hourlyPrecipTextHeight: CGFloat = 12
        static let hourlyPrecipBarHeight: CGFloat = 8
        static let hourlyVerticalPadding: CGFloat = 4
        static let dailyDayWidth: CGFloat = 44
        static let dailyPrecipWidth: CGFloat = 30
        static let dailyTempWidth: CGFloat = 32
        static let dailyBarHeight: CGFloat = 4
        static let precipBarHeight: CGFloat = 30
        static let precipBarMinHeight: CGFloat = 2
        static let precipBarCornerRadius: CGFloat = 1.5
        static let precipMinIntensity: Double = 0.5
        static let settingsWidth: CGFloat = 420
        static let settingsHeight: CGFloat = 320
        static let sparklineWidth: CGFloat = 40
        static let sparklineHeight: CGFloat = 16
        static let arcDotSize: CGFloat = 6
        static let arcStrokeWidth: CGFloat = 1.5
        static let gaugeStrokeWidth: CGFloat = 3
        static let severityDotSize: CGFloat = 5
        static let dayArcWidth: CGFloat = 44
        static let dayArcHeight: CGFloat = 20
        static let gaugeArcWidth: CGFloat = 44
        static let gaugeArcHeight: CGFloat = 20
        static let depthBarWidth: CGFloat = 8
        static let depthBarHeight: CGFloat = 16
        static let precipBarWidth: CGFloat = 16
    }

    enum Opacity {
        static let cardFill: Double = 0.2
        static let cardBorderTop: Double = 0.3
        static let cardBorderBottom: Double = 0.08
        static let cardBorderWidth: CGFloat = 0.75
        static let buttonResting: Double = 0.04
        static let buttonPressed: Double = 0.1
        static let searchFieldBackground: Double = 0.05
        static let precipBarEmpty: Double = 0.15
        static let snowPrecip: Double = 0.7
        static let snowTint: Double = 0.08
        static let rainTint: Double = 0.08
        static let searchShadow: Double = 0.2
        static let searchShadowRadius: CGFloat = 8
        static let searchShadowY: CGFloat = 4
    }

    enum Delay {
        static let settingsActivation: Double = 0.1
    }
}

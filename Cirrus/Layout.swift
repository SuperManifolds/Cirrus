import SwiftUI

enum LayoutConstants {
    enum CornerRadius {
        static let card: CGFloat = 8
        static let button: CGFloat = 6
        static let searchField: CGFloat = 6
    }

    enum Spacing {
        static let cardGrid: CGFloat = 6
        static let sectionGap: CGFloat = 10
    }

    enum Padding {
        static let card: CGFloat = 8
        static let footer: CGFloat = 8
        static let sectionVertical: CGFloat = 14
        static let sectionHorizontal: CGFloat = 8
    }

    enum Size {
        static let conditionIcon: CGFloat = 36
        static let conditionTemperature: CGFloat = 34
        static let hourlyIcon: CGFloat = 18
        static let hourlyColumnWidth: CGFloat = 44
        static let hourlyScrollHeight: CGFloat = 90
        static let dailyDayWidth: CGFloat = 44
        static let dailyPrecipWidth: CGFloat = 30
        static let dailyTempWidth: CGFloat = 32
        static let dailyBarHeight: CGFloat = 4
        static let precipBarHeight: CGFloat = 30
        static let precipBarMinHeight: CGFloat = 2
        static let precipBarCornerRadius: CGFloat = 1.5
        static let settingsWidth: CGFloat = 420
        static let settingsHeight: CGFloat = 320
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
    }
}

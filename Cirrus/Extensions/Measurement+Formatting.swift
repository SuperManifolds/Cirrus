import Foundation

extension Measurement where UnitType == UnitTemperature {
    func formatted(as unit: TemperatureUnit) -> String {
        let converted = self.converted(to: unit.unitTemperature)
        return converted.formatted(
            .measurement(width: .narrow, usage: .asProvided,
                         numberFormatStyle: .number.precision(.fractionLength(0)))
        )
    }
}

extension Measurement where UnitType == UnitSpeed {
    var formattedWindSpeed: String {
        formatted(.measurement(width: .abbreviated, usage: .wind,
                               numberFormatStyle: .number.precision(.fractionLength(0))))
    }
}

extension Measurement where UnitType == UnitPressure {
    var formattedPressure: String {
        formatted(.measurement(width: .abbreviated, usage: .barometric,
                               numberFormatStyle: .number.precision(.fractionLength(0))))
    }
}

extension Measurement where UnitType == UnitLength {
    var formattedVisibility: String {
        formatted(.measurement(width: .abbreviated, usage: .road,
                               numberFormatStyle: .number.precision(.fractionLength(0))))
    }

    var formattedSnowDepth: String {
        formatted(.measurement(width: .abbreviated, usage: .snowfall,
                               numberFormatStyle: .number.precision(.fractionLength(0))))
    }
}

func compassDirection(from degrees: Double) -> String {
    let directions = [
        String(localized: "N"), String(localized: "NE"),
        String(localized: "E"), String(localized: "SE"),
        String(localized: "S"), String(localized: "SW"),
        String(localized: "W"), String(localized: "NW")
    ]
    let index = Int((degrees + 22.5).truncatingRemainder(dividingBy: 360) / 45)
    return directions[index]
}

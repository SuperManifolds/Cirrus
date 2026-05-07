import Foundation

extension Measurement where UnitType == UnitTemperature {
    func formatted(as unit: TemperatureUnit) -> String {
        let converted = self.converted(to: unit.unitTemperature)
        return "\(Int(converted.value.rounded()))\u{00B0}"
    }
}

extension Measurement where UnitType == UnitSpeed {
    var formattedKmh: String {
        let kmh = self.converted(to: .kilometersPerHour)
        return "\(Int(kmh.value.rounded())) km/h"
    }
}

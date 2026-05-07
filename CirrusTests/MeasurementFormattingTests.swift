import Foundation
import Testing
@testable import Cirrus

struct MeasurementFormattingTests {

    // MARK: - Temperature Formatting

    @Test func celsiusFormattedAsCelsius() {
        let temp = Measurement(value: 22, unit: UnitTemperature.celsius)
        #expect(temp.formatted(as: .celsius) == "22°")
    }

    @Test func celsiusFormattedAsFahrenheit() {
        let temp = Measurement(value: 0, unit: UnitTemperature.celsius)
        #expect(temp.formatted(as: .fahrenheit) == "32°")
    }

    @Test func negativeTemperature() {
        let temp = Measurement(value: -5, unit: UnitTemperature.celsius)
        let result = temp.formatted(as: .celsius)
        #expect(result == "-5°")
    }

    @Test func roundsDown() {
        let temp = Measurement(value: 22.4, unit: UnitTemperature.celsius)
        #expect(temp.formatted(as: .celsius) == "22°")
    }

    @Test func roundsUp() {
        let temp = Measurement(value: 22.6, unit: UnitTemperature.celsius)
        #expect(temp.formatted(as: .celsius) == "23°")
    }

    @Test func zeroTemperature() {
        let temp = Measurement(value: 0, unit: UnitTemperature.celsius)
        #expect(temp.formatted(as: .celsius) == "0°")
    }

    // MARK: - Wind Speed Formatting

    @Test func windSpeedKmh() {
        let speed = Measurement(value: 12, unit: UnitSpeed.kilometersPerHour)
        #expect(speed.formattedKmh == "12 km/h")
    }

    @Test func windSpeedConvertsFromMps() {
        let speed = Measurement(value: 10, unit: UnitSpeed.metersPerSecond)
        let result = speed.formattedKmh
        #expect(result == "36 km/h")
    }
}

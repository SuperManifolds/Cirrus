import Foundation
import Testing
@testable import Cirrus

struct MeasurementFormattingTests {

    // MARK: - Temperature Formatting

    @Test func celsiusFormattedAsCelsius() {
        let temp = Measurement(value: 22, unit: UnitTemperature.celsius)
        let result = temp.formatted(as: .celsius)
        #expect(result.contains("22"))
    }

    @Test func celsiusFormattedAsFahrenheit() {
        let temp = Measurement(value: 0, unit: UnitTemperature.celsius)
        let result = temp.formatted(as: .fahrenheit)
        // 0°C = 32°F
        #expect(result.contains("32"))
    }

    @Test func negativeTemperature() {
        let temp = Measurement(value: -5, unit: UnitTemperature.celsius)
        let result = temp.formatted(as: .celsius)
        #expect(result.contains("5"))
    }

    @Test func roundsDown() {
        let temp = Measurement(value: 22.4, unit: UnitTemperature.celsius)
        let result = temp.formatted(as: .celsius)
        #expect(result.contains("22"))
    }

    @Test func roundsUp() {
        let temp = Measurement(value: 22.6, unit: UnitTemperature.celsius)
        let result = temp.formatted(as: .celsius)
        #expect(result.contains("23"))
    }

    @Test func zeroTemperature() {
        let temp = Measurement(value: 0, unit: UnitTemperature.celsius)
        let result = temp.formatted(as: .celsius)
        #expect(result.contains("0"))
    }

    // MARK: - Wind Speed Formatting

    @Test func windSpeedFormattedNotEmpty() {
        let speed = Measurement(value: 12, unit: UnitSpeed.kilometersPerHour)
        let result = speed.formattedWindSpeed
        #expect(!result.isEmpty)
    }

    @Test func windSpeedConvertedNotEmpty() {
        let speed = Measurement(value: 10, unit: UnitSpeed.metersPerSecond)
        let result = speed.formattedWindSpeed
        #expect(!result.isEmpty)
    }

    // MARK: - Pressure Formatting

    @Test func pressureFormattedNotEmpty() {
        let pressure = Measurement(value: 1013, unit: UnitPressure.hectopascals)
        let result = pressure.formattedPressure
        #expect(!result.isEmpty)
        #expect(result.contains("1"))
    }

    // MARK: - Visibility Formatting

    @Test func visibilityFormattedNotEmpty() {
        let vis = Measurement(value: 15000, unit: UnitLength.meters)
        let result = vis.formattedVisibility
        #expect(!result.isEmpty)
    }

    @Test func visibilityLowFormattedNotEmpty() {
        let vis = Measurement(value: 2500, unit: UnitLength.meters)
        let result = vis.formattedVisibility
        #expect(!result.isEmpty)
    }

    // MARK: - Snow Depth Formatting

    @Test func snowDepthFormattedNotEmpty() {
        let depth = Measurement(value: 0.25, unit: UnitLength.meters)
        let result = depth.formattedSnowDepth
        #expect(!result.isEmpty)
    }

    // MARK: - Compass Direction

    @Test func compassDirectionNorth() {
        #expect(compassDirection(from: 0) == String(localized: "N"))
    }

    @Test func compassDirectionSouthWest() {
        #expect(compassDirection(from: 225) == String(localized: "SW"))
    }
}

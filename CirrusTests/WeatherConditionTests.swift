import Testing
@testable import Cirrus

struct WeatherConditionTests {

    // MARK: - WMO Code Mapping

    @Test func wmoCodeClear() {
        #expect(WeatherCondition(wmoCode: 0) == .clear)
    }

    @Test func wmoCodeMainlyClear() {
        #expect(WeatherCondition(wmoCode: 1) == .mainlyClear)
    }

    @Test func wmoCodePartlyCloudy() {
        #expect(WeatherCondition(wmoCode: 2) == .partlyCloudy)
    }

    @Test func wmoCodeCloudy() {
        #expect(WeatherCondition(wmoCode: 3) == .cloudy)
    }

    @Test func wmoCodeFog() {
        #expect(WeatherCondition(wmoCode: 45) == .fog)
        #expect(WeatherCondition(wmoCode: 48) == .fog)
    }

    @Test func wmoCodeDrizzle() {
        for code in [51, 53, 55] {
            #expect(WeatherCondition(wmoCode: code) == .drizzle)
        }
    }

    @Test func wmoCodeFreezingDrizzle() {
        #expect(WeatherCondition(wmoCode: 56) == .freezingDrizzle)
        #expect(WeatherCondition(wmoCode: 57) == .freezingDrizzle)
    }

    @Test func wmoCodeRain() {
        #expect(WeatherCondition(wmoCode: 61) == .rain)
        #expect(WeatherCondition(wmoCode: 63) == .rain)
    }

    @Test func wmoCodeHeavyRain() {
        #expect(WeatherCondition(wmoCode: 65) == .heavyRain)
    }

    @Test func wmoCodeFreezingRain() {
        #expect(WeatherCondition(wmoCode: 66) == .freezingRain)
        #expect(WeatherCondition(wmoCode: 67) == .freezingRain)
    }

    @Test func wmoCodeSnow() {
        #expect(WeatherCondition(wmoCode: 71) == .snow)
        #expect(WeatherCondition(wmoCode: 73) == .snow)
    }

    @Test func wmoCodeHeavySnow() {
        #expect(WeatherCondition(wmoCode: 75) == .heavySnow)
    }

    @Test func wmoCodeSleet() {
        #expect(WeatherCondition(wmoCode: 77) == .sleet)
    }

    @Test func wmoCodeShowers() {
        #expect(WeatherCondition(wmoCode: 80) == .showers)
        #expect(WeatherCondition(wmoCode: 81) == .showers)
    }

    @Test func wmoCodeHeavyShowers() {
        #expect(WeatherCondition(wmoCode: 82) == .heavyShowers)
    }

    @Test func wmoCodeSnowShowers() {
        #expect(WeatherCondition(wmoCode: 85) == .snowShowers)
        #expect(WeatherCondition(wmoCode: 86) == .snowShowers)
    }

    @Test func wmoCodeThunderstorm() {
        #expect(WeatherCondition(wmoCode: 95) == .thunderstorm)
    }

    @Test func wmoCodeThunderstormWithHail() {
        #expect(WeatherCondition(wmoCode: 96) == .thunderstormWithHail)
        #expect(WeatherCondition(wmoCode: 99) == .thunderstormWithHail)
    }

    @Test func wmoCodeUnknownDefaultsToCloudy() {
        #expect(WeatherCondition(wmoCode: -1) == .cloudy)
        #expect(WeatherCondition(wmoCode: 100) == .cloudy)
        #expect(WeatherCondition(wmoCode: 42) == .cloudy)
    }

    // MARK: - SF Symbols

    @Test func allCasesHaveNonEmptySFSymbol() {
        for condition in WeatherCondition.allCases {
            #expect(!condition.sfSymbol.isEmpty)
        }
    }

    @Test func nightSymbolDiffersForClearConditions() {
        #expect(WeatherCondition.clear.sfSymbolNight != WeatherCondition.clear.sfSymbol)
        #expect(WeatherCondition.mainlyClear.sfSymbolNight != WeatherCondition.mainlyClear.sfSymbol)
        #expect(WeatherCondition.partlyCloudy.sfSymbolNight != WeatherCondition.partlyCloudy.sfSymbol)
    }

    @Test func nightSymbolSameForNonClearConditions() {
        #expect(WeatherCondition.rain.sfSymbolNight == WeatherCondition.rain.sfSymbol)
        #expect(WeatherCondition.snow.sfSymbolNight == WeatherCondition.snow.sfSymbol)
        #expect(WeatherCondition.thunderstorm.sfSymbolNight == WeatherCondition.thunderstorm.sfSymbol)
    }

    @Test func symbolIsDaytimeDispatches() {
        let clear = WeatherCondition.clear
        #expect(clear.symbol(isDaytime: true) == clear.sfSymbol)
        #expect(clear.symbol(isDaytime: false) == clear.sfSymbolNight)
    }

    // MARK: - Display Names

    @Test func allCasesHaveNonEmptyDisplayName() {
        for condition in WeatherCondition.allCases {
            #expect(!condition.displayName.isEmpty)
        }
    }
}

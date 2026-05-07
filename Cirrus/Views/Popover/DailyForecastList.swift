import SwiftUI

struct DailyForecastList: View {
    let forecasts: [DailyForecast]
    let unit: TemperatureUnit

    private var weekMin: Double {
        forecasts.map { $0.lowTemperature.converted(to: .celsius).value }.min() ?? 0
    }

    private var weekMax: Double {
        forecasts.map { $0.highTemperature.converted(to: .celsius).value }.max() ?? 30
    }

    var body: some View {
        VStack(spacing: 4) {
            ForEach(forecasts) { forecast in
                DailyForecastRow(
                    forecast: forecast,
                    unit: unit,
                    weekMin: weekMin,
                    weekMax: weekMax
                )
            }
        }
        .padding(.vertical, 4)
    }
}

#if DEBUG
#Preview {
    let daily = MockWeatherProvider.mockDaily()
    DailyForecastList(forecasts: daily, unit: .celsius)
        .frame(width: 320)
}
#endif
